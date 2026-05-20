# Magic-Potions

A personal Elixir / Phoenix sandbox from **2022** (commits span April – September 2022).
At the time I was juggling university and work, so this repo grew as a series of
self-directed exercises I came back to whenever I had a free evening.

I'm pinning it because — even years later — I still think it's a fun snapshot of how
much ground Elixir / OTP / Phoenix lets you cover in a short stretch of focused play.

## What's in here

| Folder | What it is |
| --- | --- |
| `saturday/` | **The real one.** A Phoenix app that was actually used in production by my university to handle large waves of applicants self-scheduling appointments to submit their documents. Phoenix LiveView, SQLite, releases, the works. |
| `chat/` | A small Phoenix LiveView chat — my first proper LiveView project. |
| `servy/` | The classic [Pragmatic Studio "Developing with Elixir/OTP"](https://pragmaticstudio.com/courses/elixir) hand-rolled HTTP server. Useful for understanding how Plug/Cowboy work under the hood. |
| `benchmarks/` | Throwaway perf experiments. |
| `examples/` | Bite-sized projects, mostly from working through Elixir books and tutorials: |
| `examples/kv` & `examples/kv_umbrella` | The official [Mix & OTP guide](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) distributed key-value store. |
| `examples/advanced` | Protocol & metaprogramming exercises. |
| `examples/licorice` | A tiny templating / routing toy built on Plug. |
| `examples/tierlist`, `examples/marshall`, `examples/postgecto`, `examples/games` | Various Phoenix / Ecto / OTP playground apps. |

## About `saturday/`

The application-scheduling system. A few notable bits:

- Phoenix LiveView for the realtime self-scheduling UI.
- A per-user / per-IP rate-limit on application submissions to stop spam.
- A configurable ruleset for valid date slots (windows the university actually opened).
- Pagination on the management table (the last feature before things wound down).
- Deployed as a `mix release` to a small VPS behind nginx — scripts live in `saturday/deploy/`.

It kept running through roughly three admissions seasons (August–September **2022, 2023, and 2024**)
without any real maintenance in between — the 2022 build was already good enough that it just
quietly did its job every year until the university stopped using it.

Nothing in here is actively maintained today — it's preserved for context, not for production use.

## Status

Archive / read-only. Dev secrets in the config files were rotated before publishing
and are inert (every project reads its real production `secret_key_base` from
`SECRET_KEY_BASE` at runtime). If you want to run anything, expect to:

- Install Elixir / Erlang versions roughly contemporary with mid-2022 (Elixir ~1.13,
  OTP 24/25).
- Run `mix deps.get` inside whichever subdirectory you're poking at.
- For Phoenix apps, set `SECRET_KEY_BASE` (and `DATABASE_PATH` for `saturday/`)
  before running in `prod`.

## License

[MIT](./LICENSE).
