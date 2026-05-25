# rag_idea_generator.py
# -*- coding: utf-8 -*-

import argparse
import json
import os
import shutil
import uuid
from typing import Any, Dict, List, Optional

import chromadb
from chromadb.config import Settings
from dotenv import load_dotenv
from openai import OpenAI
from sentence_transformers import SentenceTransformer


load_dotenv()

CHROMA_DB_DIR = os.getenv("CHROMA_DB_DIR", "./chroma_db")
CHROMA_COLLECTION_NAME = os.getenv("CHROMA_COLLECTION_NAME", "experiment_phenomena")

DEFAULT_LOCAL_EMBEDDING_MODEL = "./models/BAAI/bge-small-zh-v1___5"
EMBEDDING_MODEL_NAME = os.getenv("EMBEDDING_MODEL_NAME", DEFAULT_LOCAL_EMBEDDING_MODEL)

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-v4")


def normalize_text(text: Any) -> str:
    if not isinstance(text, str):
        return ""
    return text.strip()


def load_embedding_model() -> SentenceTransformer:
    """Load embedding model from local path first, then ModelScope if needed."""
    if os.path.exists(EMBEDDING_MODEL_NAME):
        return SentenceTransformer(EMBEDDING_MODEL_NAME)

    if os.path.exists(DEFAULT_LOCAL_EMBEDDING_MODEL):
        return SentenceTransformer(DEFAULT_LOCAL_EMBEDDING_MODEL)

    try:
        from modelscope import snapshot_download

        local_model_dir = snapshot_download(
            model_id=EMBEDDING_MODEL_NAME,
            cache_dir="./models",
        )
        return SentenceTransformer(local_model_dir)
    except Exception as exc:
        raise RuntimeError(
            f"Embedding model load failed: {EMBEDDING_MODEL_NAME}\n"
            "Set EMBEDDING_MODEL_NAME to a local model path, or install modelscope.\n"
            f"Original error: {exc}"
        ) from exc


embedding_model = load_embedding_model()


def embed_text(text: str) -> List[float]:
    text = normalize_text(text)
    if not text:
        raise ValueError("text must be a non-empty string.")

    vector = embedding_model.encode(text, normalize_embeddings=True)
    return vector.tolist()


def get_chroma_client():
    return chromadb.PersistentClient(
        path=CHROMA_DB_DIR,
        settings=Settings(anonymized_telemetry=False),
    )


def get_collection():
    return get_chroma_client().get_or_create_collection(
        name=CHROMA_COLLECTION_NAME,
        metadata={
            "description": "Experiment phenomena conclusions for RAG idea generation."
        },
    )


def delete_local_chroma() -> None:
    if os.path.exists(CHROMA_DB_DIR):
        shutil.rmtree(CHROMA_DB_DIR)


def is_chroma_empty() -> bool:
    return get_collection().count() == 0


def write_chroma(inserted_phen: str) -> Optional[str]:
    """
    Write inserted_phen into local Chroma.

    If inserted_phen is an empty string or only whitespace, nothing is written.
    """
    inserted_phen = normalize_text(inserted_phen)
    if not inserted_phen:
        return None

    doc_id = str(uuid.uuid4())
    get_collection().add(
        ids=[doc_id],
        documents=[inserted_phen],
        embeddings=[embed_text(inserted_phen)],
        metadatas=[{"source": "experiment_phenomenon", "doc_id": doc_id}],
    )
    return doc_id


def retrieve_matched_phens(query_phen: str, top_k: int = 5) -> List[str]:
    query_phen = normalize_text(query_phen)
    if not query_phen:
        return []

    collection = get_collection()
    collection_count = collection.count()
    if collection_count == 0:
        return []

    # main writes query_phen first, so fetch extras and filter out itself.
    n_results = min(top_k + 5, collection_count)
    results = collection.query(
        query_embeddings=[embed_text(query_phen)],
        n_results=n_results,
        include=["documents", "distances", "metadatas"],
    )

    matched_phens: List[str] = []
    seen = set()
    for doc in results.get("documents", [[]])[0]:
        doc = normalize_text(doc)
        if not doc or doc == query_phen or doc in seen:
            continue
        matched_phens.append(doc)
        seen.add(doc)
        if len(matched_phens) >= top_k:
            break

    return matched_phens


def get_llm_client() -> OpenAI:
    if not DEEPSEEK_API_KEY:
        raise ValueError(
            "DEEPSEEK_API_KEY is missing. Add it to .env, for example:\n"
            "DEEPSEEK_API_KEY=your_api_key"
        )
    return OpenAI(api_key=DEEPSEEK_API_KEY, base_url=DEEPSEEK_BASE_URL)


def build_idea_prompt(query_phen: str, matched_phens: List[str]) -> List[Dict[str, str]]:
    matched_text = "\n".join(
        f"{index}. {phen}" for index, phen in enumerate(matched_phens, start=1)
    )

    system_prompt = """
你是一名严谨的科研创意助手，擅长从新旧实验现象之间发现潜在机制、可检验假设和下一步探索方向。

你必须只输出一个合法 JSON 对象，不要输出 Markdown，不要输出解释性前后缀。
JSON 只能包含两个字段：
{
  "new_idea_title": "不超过10个字的标题",
  "new_idea": "新的可探索方向"
}

要求：
1. new_idea_title 必须限制在 10 个字以内。
2. new_idea 需要说明新现象与旧现象的关键联系、可能机制、下一步验证实验。
3. 不要编造输入中没有依据的结论；证据不足时明确写成可探索假设。
""".strip()

    user_prompt = f"""
这是本次实验的现象结论：
{query_phen}

以下是之前的实验现象结论中，与本次现象结论语义最相近的五条现象：
{matched_text}

请你观察新现象和旧现象之间的共性、差异和可能机制，提出一个新的可探索方向。
只输出 JSON，对象字段只能包括 new_idea_title 和 new_idea。
""".strip()

    return [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
    ]


def parse_idea_json(raw_content: str) -> Dict[str, str]:
    raw_content = normalize_text(raw_content)
    if raw_content.startswith("```"):
        raw_content = raw_content.strip("`").strip()
        if raw_content.lower().startswith("json"):
            raw_content = raw_content[4:].strip()

    data = json.loads(raw_content)
    title = normalize_text(data.get("new_idea_title"))
    idea = normalize_text(data.get("new_idea"))

    return {
        "new_idea_title": title[:10],
        "new_idea": idea,
    }


def prompt_new_idea(query_phen: str) -> Dict[str, str]:
    query_phen = normalize_text(query_phen)
    if not query_phen:
        return {"new_idea_title": "", "new_idea": ""}

    matched_phens = retrieve_matched_phens(query_phen=query_phen, top_k=5)
    if not matched_phens:
        return {"new_idea_title": "", "new_idea": ""}

    response = get_llm_client().chat.completions.create(
        model=DEEPSEEK_MODEL,
        messages=build_idea_prompt(query_phen, matched_phens),
        temperature=0.7,
        max_tokens=1200,
        response_format={"type": "json_object"},
    )

    return parse_idea_json(response.choices[0].message.content or "")


def main(new_phen: str, delete_chroma: bool = False) -> Dict[str, Any]:
    """
    Main function. new_phen keeps the current input type: plain string.

    Empty string input will not be written into Chroma.
    """
    new_phen = normalize_text(new_phen)

    if delete_chroma:
        delete_local_chroma()

    if not new_phen:
        return {
            "input_new_phen": "",
            "delete_chroma": delete_chroma,
            "inserted_doc_id": None,
            "chroma_was_empty": None,
            "generated": False,
            "new_idea_title": "",
            "new_idea": "",
        }

    chroma_was_empty = is_chroma_empty()
    flag = 0 if chroma_was_empty else 1

    inserted_doc_id = write_chroma(new_phen)

    idea_result = {"new_idea_title": "", "new_idea": ""}
    generated = False
    if flag == 1:
        idea_result = prompt_new_idea(new_phen)
        generated = bool(idea_result["new_idea"])

    return {
        "input_new_phen": new_phen,
        "delete_chroma": delete_chroma,
        "inserted_doc_id": inserted_doc_id,
        "chroma_was_empty": chroma_was_empty,
        "generated": generated,
        "new_idea_title": idea_result["new_idea_title"],
        "new_idea": idea_result["new_idea"],
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="RAG-based experiment idea generator.")
    parser.add_argument("new_phen", type=str, nargs="?", default="")
    parser.add_argument(
        "--delete-chroma",
        action="store_true",
        help="Delete local Chroma database before running.",
    )

    args = parser.parse_args()
    output = main(new_phen=args.new_phen, delete_chroma=args.delete_chroma)
    print(json.dumps(output, ensure_ascii=False, indent=2))
