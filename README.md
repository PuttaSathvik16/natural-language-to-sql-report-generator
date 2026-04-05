# 🤖 Slack @databot — Natural Language to SQL Query Assistant

> Ask questions in plain English. Get data back in seconds. No SQL knowledge required.

Built with **n8n** · **OpenAI GPT-4o** · **Supabase (PostgreSQL)** · **Slack**

---
## Workflow Sample
<img width="1800" height="866" alt="Screenshot 2026-04-05 at 12 21 47 AM" src="https://github.com/user-attachments/assets/f83e98bb-9682-4589-b64e-aa79c38c0521" />


## What it does

@databot is an AI-powered Slack bot that lets anyone on your team query a database using plain English. Just mention `@databot` in a Slack channel and ask a question — the bot converts it to SQL, runs it safely against your database, and replies with a formatted table and a plain-English summary.

**Example:**
```
@databot show me all delivered orders from the North region
```

**databot replies:**
```
Here are the delivered orders from the North region:

| order_id | customer | total_amount | order_date  |
|----------|----------|--------------|-------------|
| 1        | Alice    | $1,299.99    | 2024-03-01  |
| 4        | Alice    | $399.99      | 2024-04-10  |

Summary: There are 2 delivered orders from the North region totalling $1,699.98.
Alice Johnson is the only customer in this segment with completed orders.
```

---

## Architecture

```
Slack (#data-queries)
    │
    ▼
n8n Webhook Trigger (app_mention event)
    │
    ▼
Extract Question (Set node)
    │
    ▼
Generate SQL Query (OpenAI GPT-4o)
    │  ← Schema injected in system prompt
    ▼
Validate SQL (Block destructive keywords)
    │
    ├── UNSAFE → Reply with error message to Slack
    │
    ▼
Execute Query on Postgres (Supabase)
    │
    ▼
Format Results as Table (Code node)
    │
    ▼
Generate Plain English Summary (OpenAI GPT-4o)
    │
    ├──────────────────────────────────┐
    ▼                                  ▼
Send Summary to Slack         Log to Google Sheets
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Automation engine | [n8n](https://n8n.io) (cloud) |
| AI / SQL generation | OpenAI GPT-4o |
| Database | Supabase (PostgreSQL) |
| Input channel | Slack (app_mention event) |
| Output channel | Slack (post message) |
| Audit logging | Google Sheets |

---

## Features

- **Natural language to SQL** — converts plain English questions to valid PostgreSQL SELECT queries
- **Safety validation** — blocks any destructive SQL keywords (DROP, DELETE, UPDATE, INSERT, ALTER, TRUNCATE)
- **AI-written summaries** — results are explained in plain English, not just raw tables
- **Schema-aware** — full database schema is injected into the AI prompt for accurate query generation
- **Audit logging** — every query, generated SQL, and result is logged to Google Sheets
- **Multi-channel support** — works in any Slack channel where the bot is invited
- **Row limit guard** — automatically adds LIMIT 500 to prevent runaway queries

---

## Database Schema

The demo uses three tables in Supabase:

```sql
CREATE TABLE customers (
  id bigserial PRIMARY KEY,
  name text,
  email text,
  region text,
  created_at date
);

CREATE TABLE products (
  id bigserial PRIMARY KEY,
  name text,
  category text,
  price float4
);

CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  customer_id bigint REFERENCES customers(id),
  order_date date,
  total_amount float4,
  status text  -- pending, shipped, delivered
);
```

See [`schema.sql`](./schema.sql) for the full schema including seed data.

---

## Setup Instructions

### Prerequisites

- [n8n cloud account](https://app.n8n.cloud) (free tier works)
- [Supabase account](https://supabase.com) (free tier works)
- [OpenAI API key](https://platform.openai.com)
- Slack workspace with admin access

---

### Step 1 — Set up Supabase

1. Create a new Supabase project
2. Go to **SQL Editor** and run the contents of [`schema.sql`](./schema.sql)
3. Go to **Connect → Direct → Session pooler** and copy the connection details

### Step 2 — Create the Slack App

1. Go to [api.slack.com/apps](https://api.slack.com/apps) → **Create New App** → From scratch
2. Name it `databot`, select your workspace
3. Go to **OAuth & Permissions** → add these Bot Token Scopes:
   - `app_mentions:read`
   - `chat:write`
   - `channels:history`
4. Click **Install to Workspace** → copy the `xoxb-...` Bot Token
5. Go to **Basic Information** → copy the **Signing Secret**

### Step 3 — Import the n8n workflow

1. In n8n, click **+** → **Import from file**
2. Upload [`workflow.json`](./workflow.json)
3. Configure credentials:
   - **Slack**: paste Bot Token + Signing Secret
   - **OpenAI**: paste your API key
   - **Postgres**: paste Supabase Session Pooler connection details (SSL enabled)
4. Update the system prompt in the **Generate SQL Query** node with your actual schema

### Step 4 — Connect Slack webhook

1. In n8n, open the **Slack trigger node** → copy the **production webhook URL**
2. In your Slack app → **Event Subscriptions** → enable → paste the URL
3. Add bot event: `app_mention`
4. Save and reinstall the app

### Step 5 — Activate and test

1. In n8n → click **Publish** to activate the workflow
2. In Slack → invite `@databot` to a channel: `/invite @databot`
3. Send a test message:
   ```
   @databot show me all customers from the North region
   ```

---

## Example Queries

```
@databot how many orders are pending?
@databot show me all electronics products under $500
@databot which customers placed orders in April 2024?
@databot what is the total revenue from delivered orders?
@databot show me the top 5 most expensive orders
```

---

## AI System Prompt

The core prompt used in the **Generate SQL Query** node:

```
You are an expert SQL analyst. Your only job is to convert natural language 
questions into safe PostgreSQL SELECT queries.

RULES:
- Output ONLY the raw SQL query. No explanation, no markdown, no backticks.
- Only use SELECT statements. Never use DROP, DELETE, UPDATE, INSERT, ALTER, TRUNCATE.
- Always add LIMIT 500 to prevent large result sets.
- Use only the tables and columns defined in the schema below.

DATABASE SCHEMA:
[your schema here]
```

---

## Project Structure

```
nl-to-sql-slack-bot/
├── workflow.json        # n8n workflow (import this)
├── schema.sql           # Database schema + seed data
└── README.md            # This file
```

---

## Future Improvements

- [ ] Add support for chart generation (bar/line charts from query results)
- [ ] Multi-database support (BigQuery, Snowflake, MySQL)
- [ ] Query history and caching
- [ ] Role-based access control (restrict certain tables per Slack user)
- [ ] Microsoft Teams support
- [ ] Web UI for non-Slack users

---

## Built By

**Putta Sathvik** — Data Analytics Automation Project

Built as part of a series of high-impact n8n automation workflows for data analysts.

---
