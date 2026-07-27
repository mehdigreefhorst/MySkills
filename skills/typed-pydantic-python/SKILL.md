---
name: typed-pydantic-python
description: "Use when writing or refactoring Python (FastAPI services, shared libs) and deciding how to model data, type signatures, or structure modules — a new Pydantic model, a raw dict/Any about to cross a boundary, an untyped parameter, a settings/config class, splitting a god-model, or choosing inheritance vs Protocol vs concrete. Triggers: new pydantic model, dict/list[dict] on the wire, `def f(x):` untyped, BaseSettings, 'how should I structure this'."
---

# Typed Pydantic Python

## Overview

One house style for Python services and libraries:

```
Pydantic in → Pydantic out  ·  every signature typed  ·  small atomic models,
composed and shared by inheritance  ·  no raw dict on data you own  ·  mypy --strict is the gate
```

The typed model *is* the contract and the single place validation lives. A raw `dict` crossing a
boundary is a bug waiting to happen; `dict.get` on data you own is that bug.

## When to use

- Writing or refactoring any Python service or shared lib (FastAPI especially).
- A `dict`, `list[dict]`, or `Any` is about to be a request body, response, stored record, or config.
- A function has an untyped parameter or return, or an injected dependency typed `object`.
- Adding a settings/config class, or a model is growing too many fields.

**Not for:** throwaway scripts; non-Python code; a genuine third-party `**kwargs` boundary (rule 5).

## The conventions

1. **Pydantic for every boundary or stored shape** — request bodies, responses, SSE/event
   payloads, log/provenance records, config. **Separate request from response models** — don't
   reuse one loose shape for both. Never a raw `dict` / `list[dict]` as a body, response, or record.
2. **Share config by inheritance.** One base per stance; everything inherits it — never repeat
   `model_config`:
   - `_Frozen` = `ConfigDict(frozen=True, extra="forbid")` for domain / stored models.
   - `_Strict` = `ConfigDict(extra="forbid")` for wire models.
3. **Atomic models.** One model = one concern. *Compose* (`Response` holds `list[Choice]`, a
   `Choice` holds a `Message`) instead of one god-model with twenty fields. Many small files by
   feature/domain (~200–400 lines). If a model or file is hard to name, split it.
4. **Type every parameter and return.** No bare `Callable`, no `object`, no untyped inner
   functions. Give a callable seam a type alias:
   `GenerateFn = Callable[[list[Message], str], AsyncIterator[str]]`.
5. **Never `dict.get` / index data you own** — read typed attributes on a model. `dict[str, Any]`
   is allowed ONLY at a genuine third-party boundary (an SDK's `**kwargs`, an opaque passthrough)
   and must carry a comment saying so.
6. **Settings via `pydantic-settings`.** `BaseSettings` with `extra="ignore"`; a per-field
   `validation_alias` when env names don't share one prefix; a fail-fast `validate()` that refuses
   to boot on a placeholder secret. Not scattered `os.environ.get(...)`.
7. **The gate.** Each service/lib ships `pyproject.toml` `[tool.mypy] strict = true`,
   `plugins = ["pydantic.mypy"]`, plus ruff — both clean before a change is done. Shared libs ship a
   `py.typed` marker so consumers get the types.

## Inheritance vs Protocol vs concrete (the "reuse when possible" call)

| Situation | Use |
|---|---|
| Shared config/fields across *your own* models | **Inherit a base model** (`_Frozen` / `_Strict`) |
| A dependency you inject and fake in tests | **`Protocol`** — a structural, duck-typed seam |
| A downstream function needs the concrete type | **Annotate the concrete class** (don't over-abstract) |

Reach for inheritance first for your own data; a `Protocol` for a seam; only name a concrete
third-party class when something downstream demands it.

## One example (everything above, one screen)

```python
from collections.abc import AsyncIterator, Callable
from typing import Any, Protocol

from pydantic import BaseModel, ConfigDict
from pydantic_settings import BaseSettings, SettingsConfigDict


class _Strict(BaseModel):                       # 2: one base, inherited everywhere
    model_config = ConfigDict(extra="forbid")


class Message(_Strict):                         # 3: atomic — one concern
    role: str
    content: str


class SearchRequest(_Strict):                   # 1: request model, strict
    query: str
    top_k: int = 5
    temperature: float | None = None

    def extra_params(self) -> dict[str, Any]:   # 4: typed return
        return self.model_dump(exclude_unset=True, exclude={"query", "top_k"})


class Result(_Strict):
    id: str
    score: float


class SearchResponse(_Strict):                  # 1 + 3: composed, not a god-model
    results: list[Result]
    count: int


class Embedder(Protocol):                       # decision: injected seam → Protocol
    def embed(self, text: str) -> list[float]: ...


GenerateFn = Callable[[list[Message]], AsyncIterator[str]]   # 4: typed callable seam


class Settings(BaseSettings):                   # 6: pydantic-settings, not os.environ
    model_config = SettingsConfigDict(extra="ignore")
    api_key: str = ""
    port: int = 8200

    def validate(self) -> None:                 # fail-fast
        if self.api_key in {"", "change-me"}:
            raise RuntimeError("SEARCH_API_KEY unset — refusing to boot")
```

The FastAPI handler is then `async def search(body: SearchRequest) -> SearchResponse:` — no
`body.get(...)`, no raw dict, no untyped parameter.

## Apply to an existing project (audit)

1. **Find violations:**
   `grep -rnE '\.get\(|: dict[^[]|-> dict[^[]|list\[dict\]|: object|: Callable[^[]' <package>`
   (surviving hits should only be commented third-party `dict[str, Any]` boundaries).
2. Introduce the base class(es); convert raw dicts and plain dataclasses → models.
3. Split any god-model into atomic, composed models.
4. Type the seams — `Protocol` / type alias / concrete, per the table.
5. Migrate config to `pydantic-settings`; add the mypy + ruff gate and `py.typed`.
6. Run `mypy --strict` down to zero; commit.

## Common mistakes

| Rationalization | Reality |
|---|---|
| "It's just internal, a dict is fine" | Internal data is data you own — model it. Dicts lose types and invite `.get`. |
| "One big model is simpler" | A god-model hides concerns and can't be reused. Compose atomic models. |
| "The test fake isn't the real type, leave it `object`" | Type the seam with a `Protocol`; the fake satisfies it structurally. |
| "Settings are just env reads" | `pydantic-settings` gives typed, validated, fail-fast config in one place. |
| "`dict[str, Any]` everywhere is technically typed" | Only at a real SDK boundary, commented. Elsewhere it's an untyped shape. |
| "It compiles / tests pass, ship it" | `mypy --strict` is the gate. A clean compile is not a type check. |

## Red flags — stop

- `body: dict`, `-> dict`, or `list[dict]` on data you own.
- `.get(` or `[...]` indexing on a shape you defined.
- A model that doesn't inherit the shared base, or repeats `model_config`.
- A second model restating another's fields instead of composing it.
- Reaching for a `Protocol` when plain inheritance of your own base would do.
- Claiming done without running `mypy --strict`.
