# dumalog

From dev chats to blog posts — an AI writing agent inspired by Dumas.

**dumalog** analyzes your development conversations (Codex CLI, Claude Code),
stores them verbatim in a local [memPalace](https://github.com/MemPalace/mempalace)
vector index, and turns the interesting parts into structured, publish-ready
Jekyll blog posts — the format most GitHub Pages blogs run on.

Everything runs locally. Your chat history never leaves the machine except
as the anonymized context sent to the model you configured.

## Install (macOS / Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/GoXLd/dumalog/main/install.sh | bash
```

The installer:

1. installs [`uv`](https://docs.astral.sh/uv/) if missing;
2. installs **memPalace** (`uv tool install mempalace`);
3. installs **[hermes-agent](https://github.com/NousResearch/hermes-agent)**
   (the writing agent, works with OpenAI-compatible models) — skipped if
   already present;
4. detects existing **Claude Code** (`~/.claude/projects`) and **Codex CLI**
   (`~/.codex/sessions`) histories and mines them into the palace;
5. installs the `dumalog` CLI into `~/.local/bin`.

## Usage

Register a blog — one command, give it the repo and (optionally) a link to
a post whose style you want to match:

```bash
dumalog add-blog git@github.com:you/you.github.io.git \
  --posts-dir _posts \
  --example https://raw.githubusercontent.com/you/you.github.io/main/_posts/2026-07-10-my-best-post.md
```

Without `--example` the newest post in `--posts-dir` is used as the style
reference. Local paths work too: `dumalog add-blog ~/Git/my-blog`.

Write a post:

```bash
dumalog write "how I sped up my API 35x by killing an N+1"
```

This searches your mined chat history for relevant context, combines it
with the writing guide ([prompts/write-post.md](prompts/write-post.md)) and
your example post, and runs the agent inside the blog repo. The agent
commits the draft on a `post/<slug>` branch and opens a PR — **it never
pushes to main**; you review and merge.

Keep the palace fresh (e.g. nightly via cron/launchd):

```bash
dumalog mine
```

Other commands: `dumalog status`.

## Configuration

- Config lives in `~/.dumalog/config.json` (multiple blogs supported,
  `--blog <name>` selects one).
- `DUMALOG_AGENT=hermes|codex` forces the agent; by default hermes is
  preferred, codex is the fallback.
- The writing rules are plain markdown in `prompts/write-post.md` —
  edit them to change the voice, structure, or hard rules
  (no invented numbers, anonymization, PR-only publishing).

## Safety model

- memPalace stores everything **locally** (embedded ChromaDB).
- The writing guide forbids the agent to invent numbers, leak secrets,
  or push to the default branch. A human merges every post.

## License

dumalog is dual-licensed:

- **[AGPL-3.0](LICENSE)** — free for personal, internal, and open-source
  use. If you distribute dumalog or offer it as part of a network service,
  your derived work must be released under AGPL-3.0 as well.
- **Commercial license** — if you want to embed dumalog in a proprietary
  product or SaaS without the AGPL obligations, contact
  [goxld@linux.com](mailto:goxld@linux.com) for terms.

Copyright © 2026 Alexandre Vandemoortèle (GoXLd).

By submitting a contribution you agree to license it under AGPL-3.0 and
grant the project owner the right to relicense it under the commercial
license above.
