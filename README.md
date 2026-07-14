<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo/dumalog-white.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/logo/dumalog-black.svg">
    <img alt="dumalog — a portrait of Alexandre Dumas" src="assets/logo/dumalog-black.svg" width="240">
  </picture>
</p>

<h1 align="center">dumalog</h1>

<p align="center"><em>From dev chats to blog posts — an AI writing agent inspired by Dumas.</em></p>

**dumalog** analyzes your development conversations (Codex CLI, Claude Code),
stores them verbatim in a local [memPalace](https://github.com/MemPalace/mempalace)
vector index, and turns the interesting parts into structured, publish-ready
Jekyll blog posts — the format most GitHub Pages blogs run on.

Everything runs locally. Your chat history never leaves the machine except
as the anonymized context sent to the model you configured.

> **Themes.** dumalog produces standard Jekyll posts, so any Chirpy-style blog
> works out of the box — including the multilingual
> [**NLO**](https://github.com/GoXLd/NLO) theme, which is **fully supported** as
> a publishing target. NLO renders dumalog's front matter as-is (`title`,
> `date`, `categories`, `tags`, `image`, and the `language` / `translation_key`
> multilingual fields), so generated posts publish with no extra formatting.

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

At the end of the install, `dumalog setup` runs automatically: it finds
local Jekyll blogs (`_config.yml` + `_posts/` under `~/Git`, `~/Projects`,
etc.), asks which one to analyze, lets you pick the posts whose formatting
you like, and generates a per-blog **style guide** from them
(`~/.dumalog/styles/<blog>.md`) that every future post will follow.
Re-run it anytime with `dumalog setup`.

Prefer to register a blog manually? One command, give it the repo and
(optionally) a link to a post whose style you want to match:

```bash
dumalog add-blog git@github.com:you/you.github.io.git \
  --posts-dir _posts \
  --example https://raw.githubusercontent.com/you/you.github.io/main/_posts/2026-07-10-my-best-post.md
```

Without `--example` the newest post in `--posts-dir` is used as the style
reference. Local paths work too: `dumalog add-blog ~/Git/my-blog`.

Write a post — with no arguments, dumalog analyzes your recent coding-agent
activity and suggests topics to pick from:

```bash
dumalog write
# Topics for a post (window: 24h):
#   1. Safe VACUUM FULL in production: picking a quiet window...
#   2. ...
# Topic number (0 to exit, or type your own topic):
```

Suggestions exclude what you already wrote about (existing post titles +
dumalog's own history in `~/.dumalog/topics.json`), so no repeats. The
activity window defaults to 24 hours; change it per run with
`dumalog write --window 72` or permanently with `dumalog set window_hours 72`.

Or skip the menu and name the topic yourself:

```bash
dumalog write "how I sped up my API 35x by killing an N+1"
```

Either way dumalog searches your mined chat history for relevant context,
combines it with the writing guide ([prompts/write-post.md](prompts/write-post.md))
and your example post, and runs the agent inside the blog repo. By default
the agent **commits the post directly to `main` and pushes** — on GitHub
Pages that means immediate publication.

Want a review step or a staging branch instead? Set the `branch` option:

```bash
dumalog set branch pr      # post/<slug> branch + pull request, you merge
dumalog set branch drafts  # commit to a fixed branch named "drafts"
dumalog set branch main    # back to the default: straight to main
```

Keep the palace fresh — mining is incremental (already-filed sessions are
skipped), so run it nightly. On macOS:

```bash
sed "s|\$HOME|$HOME|g" examples/com.dumalog.mine.plist \
  > ~/Library/LaunchAgents/com.dumalog.mine.plist
launchctl load -w ~/Library/LaunchAgents/com.dumalog.mine.plist
```

(The `sed` is needed because launchd does not expand `~` or env vars in
paths.) The agent appears as **dumalog** in *System Settings → General →
Login Items & Extensions → Allow in the Background* — that's this nightly
mine; leave it enabled.

On Linux, a cron line does the same: `0 5 * * * ~/.local/bin/dumalog mine`.
Manual refresh anytime: `dumalog mine`.

Chroma's FTS5 search index can desync after an interrupted write ("malformed
inverted index" — mempalace then refuses to mine). `dumalog mine` self-heals
this: it checks the palace DB before mining and rebuilds the index in place,
leaving a `chroma.sqlite3.pre-heal-*` backup next to it. Anything worse than
FTS5 desync makes it exit non-zero with recovery instructions — check
`~/.dumalog/mine.log` if the nightly run's last exit code isn't 0
(`launchctl print gui/$UID/com.dumalog.mine | grep "last exit"`).

Other commands: `dumalog status`.

Using [hermes-agent](https://github.com/NousResearch/hermes-agent)'s desktop
app or chat instead of the CLI? Install the bundled skill so Hermes can write
posts natively (it reads the same config and writing guide):

```bash
cp -r examples/hermes-skill/dumalog ~/.hermes/skills/software-development/
```

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
- The writing guide forbids the agent to invent numbers or leak secrets.
- By default posts go straight to `main` (instant publish on GitHub Pages);
  set `dumalog set branch pr` if you want a human-reviewed PR flow instead.

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
