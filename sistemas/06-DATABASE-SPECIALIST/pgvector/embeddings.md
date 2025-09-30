# pgvector for Medical Semantic Search

**Extension**: pgvector 0.8.0
**PostgreSQL**: 16.6
**Healthcare Context**: Clinical notes search, drug similarity, RAG for medical AI
**Last Updated**: 2025-09-30

---

## Overview

**pgvector** adds vector similarity search to PostgreSQL, enabling:
- **Semantic search**: Find similar medical conditions, symptoms, procedures
- **RAG (Retrieval-Augmented Generation)**: Ground AI responses in medical literature
- **Drug similarity**: Match medications by mechanism of action
- **Clinical decision support**: Find similar patient cases

**Healthcare Use Cases**:
- Search clinical notes by meaning (not just keywords)
- Find similar diagnostic codes (ICD-10, TUSS, CBHPM)
- Recommend treatments based on similar cases
- Medical literature search for evidence-based medicine

---

## Installation

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify version
SELECT extversion FROM pg_extension WHERE extname = 'vector';
-- 0.8.0
```

---

## Vector Storage

### Create Table with Embeddings

```sql
-- Clinical notes with embeddings (OpenAI ada-002: 1536 dimensions)
CREATE TABLE clinical_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id),
  note_text TEXT NOT NULL,
  note_type VARCHAR(50) NOT NULL,  -- progress_note, discharge_summary, etc.
  embedding vector(1536),  -- Vector column
  author_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for similarity search (HNSW - fast approximate search)
CREATE INDEX idx_clinical_notes_embedding_hnsw 
  ON clinical_notes USING hnsw (embedding vector_cosine_ops);

-- Alternative: IVFFlat index (older, less memory)
-- CREATE INDEX idx_clinical_notes_embedding_ivfflat 
--   ON clinical_notes USING ivfflat (embedding vector_cosine_ops) 
--   WITH (lists = 100);
```

**Distance Metrics**:
- `vector_cosine_ops`: Cosine distance (most common for text embeddings)
- `vector_l2_ops`: Euclidean distance (L2)
- `vector_ip_ops`: Inner product (dot product)

---

## Generating Embeddings

### Elixir Integration (OpenAI)

```elixir
defmodule Healthcare.Embeddings do
  @openai_api_key System.get_env("OPENAI_API_KEY")
  @embedding_model "text-embedding-3-small"  # 1536 dimensions
  
  def generate_embedding(text) do
    url = "https://api.openai.com/v1/embeddings"
    
    body = Jason.encode!(%{
      input: text,
      model: @embedding_model
    })
    
    headers = [
      {"Authorization", "Bearer #{@openai_api_key}"},
      {"Content-Type", "application/json"}
    ]
    
    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        %{"data" => [%{"embedding" => embedding}]} = Jason.decode!(response_body)
        {:ok, embedding}
      
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  def store_clinical_note(patient_id, note_text, note_type, author_id) do
    # Generate embedding
    {:ok, embedding} = generate_embedding(note_text)
    
    # Store in database
    %ClinicalNote{
      patient_id: patient_id,
      note_text: note_text,
      note_type: note_type,
      embedding: embedding,
      author_id: author_id
    }
    |> Repo.insert()
  end
end

# Usage
Healthcare.Embeddings.store_clinical_note(
  patient_id,
  "Patient presents with chest pain radiating to left arm. ECG shows ST elevation. Diagnosis: acute myocardial infarction.",
  "progress_note",
  doctor_id
)
```

---

## Semantic Search

### Find Similar Clinical Notes

```sql
-- Find notes similar to query
WITH query_embedding AS (
  SELECT embedding 
  FROM clinical_notes 
  WHERE id = '123e4567-e89b-12d3-a456-426614174000'
)
SELECT 
  id,
  patient_id,
  note_text,
  note_type,
  1 - (embedding <=> (SELECT embedding FROM query_embedding)) AS similarity
FROM clinical_notes
WHERE id != '123e4567-e89b-12d3-a456-426614174000'
ORDER BY embedding <=> (SELECT embedding FROM query_embedding)
LIMIT 10;

-- Alternative: Search by text query (requires pre-computed embedding)
SELECT 
  id,
  note_text,
  1 - (embedding <=> '[0.123, -0.456, ...]'::vector) AS similarity
FROM clinical_notes
ORDER BY embedding <=> '[0.123, -0.456, ...]'::vector
LIMIT 10;
```

**Operators**:
- `<->`: Euclidean distance (L2)
- `<#>`: Negative inner product
- `<=>`: Cosine distance (most common)

### Elixir Semantic Search

```elixir
defmodule Healthcare.SemanticSearch do
  def search_similar_notes(query_text, limit \\ 10) do
    # Generate embedding for query
    {:ok, query_embedding} = Healthcare.Embeddings.generate_embedding(query_text)
    
    # Search similar notes
    query = """
    SELECT 
      id,
      patient_id,
      note_text,
      note_type,
      1 - (embedding <=> $1::vector) AS similarity
    FROM clinical_notes
    ORDER BY embedding <=> $1::vector
    LIMIT $2
    """
    
    Ecto.Adapters.SQL.query!(Repo, query, [query_embedding, limit])
    |> Map.get(:rows)
    |> Enum.map(fn [id, patient_id, note_text, note_type, similarity] ->
      %{
        id: id,
        patient_id: patient_id,
        note_text: note_text,
        note_type: note_type,
        similarity: Float.round(similarity, 4)
      }
    end)
  end
end

# Usage
Healthcare.SemanticSearch.search_similar_notes(
  "patient with chest pain and shortness of breath"
)
# [
#   %{
#     id: "...",
#     patient_id: "...",
#     note_text: "Patient presents with chest pain radiating to left arm...",
#     similarity: 0.8923
#   },
#   ...
# ]
```

---

## RAG (Retrieval-Augmented Generation)

### Medical Knowledge Base

```sql
-- Medical literature embeddings
CREATE TABLE medical_literature (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  abstract TEXT NOT NULL,
  pmid VARCHAR(20) UNIQUE,  -- PubMed ID
  authors TEXT,
  journal TEXT,
  publication_date DATE,
  embedding vector(1536),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_medical_literature_embedding_hnsw 
  ON medical_literature USING hnsw (embedding vector_cosine_ops);
```

### RAG Pipeline

```elixir
defmodule Healthcare.RAG do
  @doc """
  Retrieval-Augmented Generation for medical questions.
  
  Steps:
  1. Generate embedding for question
  2. Retrieve relevant medical literature (semantic search)
  3. Pass context + question to LLM (Claude)
  4. Return grounded answer with sources
  """
  def answer_medical_question(question) do
    # 1. Generate embedding
    {:ok, query_embedding} = Healthcare.Embeddings.generate_embedding(question)
    
    # 2. Retrieve relevant literature (top 5)
    context_papers = retrieve_relevant_papers(query_embedding, limit: 5)
    
    # 3. Build prompt with context
    context_text = Enum.map_join(context_papers, "\n\n", fn paper ->
      """
      Title: #{paper.title}
      Authors: #{paper.authors}
      Journal: #{paper.journal} (#{paper.publication_date})
      Abstract: #{paper.abstract}
      PMID: #{paper.pmid}
      """
    end)
    
    prompt = """
    You are a medical AI assistant. Answer the following question based ONLY on the provided scientific literature.
    
    CONTEXT (Medical Literature):
    #{context_text}
    
    QUESTION: #{question}
    
    Provide a concise answer with citations (use PMID).
    """
    
    # 4. Call Claude API
    {:ok, answer} = call_claude_api(prompt)
    
    %{
      question: question,
      answer: answer,
      sources: Enum.map(context_papers, & &1.pmid)
    }
  end
  
  defp retrieve_relevant_papers(query_embedding, opts) do
    limit = Keyword.get(opts, :limit, 5)
    
    query = """
    SELECT 
      id, title, abstract, pmid, authors, journal, publication_date,
      1 - (embedding <=> $1::vector) AS similarity
    FROM medical_literature
    ORDER BY embedding <=> $1::vector
    LIMIT $2
    """
    
    Ecto.Adapters.SQL.query!(Repo, query, [query_embedding, limit])
    |> Map.get(:rows)
    |> Enum.map(fn [id, title, abstract, pmid, authors, journal, pub_date, similarity] ->
      %{
        id: id,
        title: title,
        abstract: abstract,
        pmid: pmid,
        authors: authors,
        journal: journal,
        publication_date: pub_date,
        similarity: similarity
      }
    end)
  end
  
  defp call_claude_api(prompt) do
    # Call Anthropic API (simplified)
    # In production: use official SDK
    {:ok, "Answer based on literature..."}
  end
end

# Usage
Healthcare.RAG.answer_medical_question(
  "What is the recommended treatment for acute myocardial infarction?"
)
# %{
#   question: "What is the recommended treatment...",
#   answer: "Based on the literature, the recommended treatment for AMI includes...",
#   sources: ["12345678", "23456789", "34567890"]
# }
```

---

## Drug Similarity

### Chemical Structure Embeddings

```sql
-- Drug database with embeddings
CREATE TABLE drugs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  generic_name VARCHAR(255) NOT NULL,
  mechanism_of_action TEXT,
  indications TEXT,
  contraindications TEXT,
  embedding vector(1536),  -- Embedding from chemical structure + description
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_drugs_embedding_hnsw 
  ON drugs USING hnsw (embedding vector_cosine_ops);

-- Find similar drugs (alternative medications)
SELECT 
  name,
  generic_name,
  mechanism_of_action,
  1 - (embedding <=> $1::vector) AS similarity
FROM drugs
WHERE id != $2  -- Exclude query drug
ORDER BY embedding <=> $1::vector
LIMIT 5;
```

**Use Case**: Suggest alternative medications when patient has allergy or contraindication.

---

## Performance Optimization

### Index Types

```sql
-- HNSW (Hierarchical Navigable Small World) - RECOMMENDED
-- Pros: Fast queries, good accuracy
-- Cons: Higher memory usage
CREATE INDEX idx_hnsw ON clinical_notes 
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- IVFFlat (Inverted File with Flat Compression)
-- Pros: Lower memory, faster build
-- Cons: Slower queries, lower accuracy
CREATE INDEX idx_ivfflat ON clinical_notes 
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

### Query Optimization

```sql
-- Set search precision (HNSW only)
SET hnsw.ef_search = 40;  -- Default: 40 (higher = more accurate, slower)

-- Warm up index (load into memory)
SELECT pg_prewarm('idx_clinical_notes_embedding_hnsw');
```

### Benchmarks (10M Embeddings, 1536 Dimensions)

```yaml
HNSW Index:
  Build time: 45 minutes
  Index size: 18GB
  Query time (p99): 12ms
  Recall@10: 95%

IVFFlat Index:
  Build time: 8 minutes
  Index size: 4.2GB
  Query time (p99): 85ms
  Recall@10: 85%

Verdict: HNSW for production (accuracy + speed)
```

---

## Hybrid Search (Keyword + Semantic)

### Combine Full-Text and Vector Search

```sql
-- Hybrid search: keyword + semantic similarity
WITH keyword_search AS (
  SELECT 
    id,
    ts_rank(search_vector, query) AS keyword_rank
  FROM clinical_notes, 
       to_tsquery('portuguese', 'diabetes & hipertensão') query
  WHERE search_vector @@ query
),
semantic_search AS (
  SELECT 
    id,
    1 - (embedding <=> $1::vector) AS semantic_similarity
  FROM clinical_notes
  ORDER BY embedding <=> $1::vector
  LIMIT 100
)
SELECT 
  c.id,
  c.note_text,
  COALESCE(k.keyword_rank, 0) * 0.3 + 
  COALESCE(s.semantic_similarity, 0) * 0.7 AS combined_score
FROM clinical_notes c
LEFT JOIN keyword_search k ON c.id = k.id
LEFT JOIN semantic_search s ON c.id = s.id
WHERE k.id IS NOT NULL OR s.id IS NOT NULL
ORDER BY combined_score DESC
LIMIT 10;
```

**Weights**: 30% keyword relevance, 70% semantic similarity (tunable).

---

## Monitoring & Observability

### Query Performance

```sql
-- Analyze query plan
EXPLAIN ANALYZE
SELECT id, note_text
FROM clinical_notes
ORDER BY embedding <=> '[0.123, ...]'::vector
LIMIT 10;

-- Index usage statistics
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan AS index_scans,
  idx_tup_read AS tuples_read,
  idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE indexname LIKE '%embedding%';
```

### Elixir Telemetry

```elixir
defmodule Healthcare.VectorSearchMetrics do
  use Prometheus.Metric
  
  def setup do
    Histogram.declare(
      name: :vector_search_duration_ms,
      help: "Vector search query duration",
      labels: [:search_type],
      buckets: [10, 25, 50, 100, 250, 500, 1000]
    )
    
    Counter.declare(
      name: :vector_searches_total,
      help: "Total vector searches",
      labels: [:search_type, :result_count]
    )
  end
  
  def record_search(search_type, duration_ms, result_count) do
    Histogram.observe(
      [name: :vector_search_duration_ms, labels: [search_type]],
      duration_ms
    )
    
    Counter.inc(
      name: :vector_searches_total,
      labels: [search_type, result_count]
    )
  end
end
```

---

## References

### Official Documentation
- [pgvector GitHub](https://github.com/pgvector/pgvector) (L0_CANONICAL)
- [pgvector Performance Tuning](https://github.com/pgvector/pgvector#performance) (L0_CANONICAL)

### Research Papers
- [Approximate Nearest Neighbor Search (HNSW)](https://arxiv.org/abs/1603.09320) (L1_ACADEMIC)

---

**DSM**: [L1:data_layer | L2:healthcare | L3:implementation | L4:guide]
**Source**: `03-database-postgresql-timescale.md` (pgvector sections)
**Version**: 1.0.0
**Related**:
- [PostgreSQL Core Features](../postgresql/core-features.md)
- [TimescaleDB Hypertables](../timescaledb/hypertables.md)
- [ADR 003: Database Selection](../../01-ARCHITECTURE/adrs/003-database-selection.md)
