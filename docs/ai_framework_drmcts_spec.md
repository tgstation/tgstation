# AI Framework (DR-MCTS + Small LLM) for /tg/station

## 1. Objectives (v1 Foundations)

Believable, useful NPC crew that: (a) perceive world/radio text, (b) act via macro-options, (c) plan with DR-MCTS under a strict tick budget, (d) expose clear admin controls.

The LLM is not "the brain." It only parses noisy text (radio, nearby speech, logs) into structured facts/events that feed heuristics and priors; DR-MCTS chooses actions.

Sample-efficient planning: DR-MCTS leaves mix short rollouts with a doubly-robust off-policy estimator to reduce variance and bias—so we can decide well with few simulations.

Non-goals (v1): No job automation trees beyond macro-options; no cross-round memory; no TTS; no direct LLM "free text" action planning.

## 2. High-Level Architecture

BYOND (DM/TGUI)
```
SS_AI (subsystem)   ← tick-aware scheduler using world.tick_usage
├─ /datum/ai_controller/crew_human
│   ├─ Blackboard (BB)     ← typed keys, ring buffers
│   ├─ Perception          ← speech/radio/alarms → BB
│   ├─ OptionRunner        ← executes chosen macro-option
│   └─ GatewayClient       ← request + poll (Planner, LLM)
├─ OptionLibrary (role packs)
└─ Admin Console (TGUI)

Logs/Replay → datasets (π_b, V/Q baselines)

Config & Flags (AI_CREW_ENABLED, AI_DEBUG, AI_GATEWAY_URL)
```

External services (same host, localhost HTTP):
```
Planner Service (DR-MCTS engine)
├─ PUCT selection + priors
├─ DR leaf estimator (β-hybrid backup)
└─ Interfaces for macro-options, models, constraints

LLM Parser (llama.cpp with GBNF JSON grammar)
└─ “radio/say → structured event” only; no free-form control
```

BYOND is single-threaded; heavy search runs off-process. Use non-blocking world.Export with backpressure tied to world.tick_usage.

## 3. Core Algorithms

### 3.1 DR-MCTS (planner)

- Selection: PUCT with role-driven priors.
- Actions: Macro-options (temporal abstractions) to keep branching manageable.
- Leaf evaluation: Doubly-robust off-policy estimator combining learned value/Q baseline with importance sampling from a behavior policy.

### 3.2 Small LLM (parser only)

Local llama.cpp with GBNF → JSON events: `{type, channel, targets, urgency, entities[]}`. No direct action control.

## 4. Modules & Interfaces (DM side)

### 4.1 Subsystem & Controllers

- `/datum/controller/subsystem/ai` (SS_AI) budgets work via world.tick_usage.
- `/datum/ai_controller/crew_human` owns Blackboard, Perception, OptionRunner, GatewayClient.

### 4.2 Blackboard

Typed keys: persona, zone, path, last_heard, hazards, timers, admin flags. Size-capped ring buffers.

### 4.3 Perception

Hooks COMSIG_SAY_HEARD, radio monitor, alarms to normalize events into the Blackboard. LLM parses text batches into heuristics/prior hints.

### 4.4 Option Library

`/datum/ai_option`: `precond()`, `propose()`, `step()`, `done()`, `timeout`. Role packs (Med/Eng/Sec/Cargo/Generic) provide macro-options.

### 4.5 Gateway Client

Queue + poller built on `world.Export()`. Tick-aware backoff; localhost only; short timeouts.

### 4.6 Admin Console

TGUI panel listing AIs (zone, option, budget, last utterance) with actions: Send to Zone, Freeze, Mute, View Logs.

## 5. External Services

### 5.1 Planner Service (DR-MCTS)

Endpoints:
- `POST /plan` → `{state_summary, option_set, priors, budget_ms}` → `{chosen_option_id, meta}`
- `POST /update-models`
- `GET /health`

Input includes zone state, entities, incidents, Blackboard flags, option set.

### 5.2 LLM Parser

`POST /parse` → `{utterances:[{text,channel,who}]}` → grammar-constrained JSON events. Runs locally with llama.cpp GBNF.

## 6. Data & Models

Replay logs build datasets for behavior policy and value/Q baselines per role. Doubly-robust estimator supports offline evaluation.

Contracts:
- Plan request: `{ ai_id, tick, state, options:[{id,args}], priors, budget_ms }`
- Plan response: `{ chosen:{id,args}, alt, stats:{n_sims,depth,beta} }`
- LLM events: bounded JSON defined by GBNF.

## 7. Performance & Tick Budget

- Target ≤0.3 ms DM time per AI per tick; keep world.tick_usage ≤80–85%, hard stop at ~90–92%.
- Backpressure trims speech, polling cadence, rollout horizon, low-priority AIs.
- Export to localhost, timeouts <50–80 ms; queue requests to avoid blocking.

## 8. Security, Safety & Operations

Feature flags (`AI_CREW_ENABLED`, `AI_DEBUG`, `AI_GATEWAY_URL`), audit logs, localhost-only services. Deploy via tgstation-server; rollback by flag/branch.

## 9. Extensibility

- New role pack: add `ai_option` set; Planner unaffected.
- New heuristic: tweak priors or Blackboard flags.
- New parser events: extend GBNF and Blackboard mapping.
- Multi-agent scaling: independent planners with light intention board.

## 10. File Layout (proposed)

```
code/
  __DEFINES/ai/ai_flags.dm
  controllers/subsystem/ai.dm
  modules/ai/core/{controller,blackboard,perception,speech,gateway}.dm
  modules/ai/options/[role]/*.dm
  modules/ai/admin/console_tgui.tsx

external/
  planner/
  parser/

config/ai.cfg

docs/ai_framework.md
```

## 11. Acceptance Criteria (v1)

- Tick safety with ≥12 AIs; logs show backpressure.
- Planner beats greedy baselines in canned scenarios; β sweeps stable.
- Parser outputs: ≥95% valid JSON, ≥90% F1; no free-form control strings.
- Admin console functional and audited.
- Planner/parser deployments roll out via tgstation-server; disabling flag works live.

## 12. Rollout Plan

1. Bootstrap & Flags — SS_AI scaffold; config/verbs.
2. Perception & BB — speech/radio normalization and inspector tools.
3. Parser — llama.cpp GBNF integration.
4. Options — base option type + role packs (10–20 macro-options).
5. Planner — DR-MCTS service wired to SS_AI.
6. Backpressure — tick-aware throttles; I/O cadence management.
7. Admin Console & Logs — controls and observability.
8. Replay → Models — training pipelines for priors/values.
9. Soak & Beta — Med/Eng focus, expand later.
10. Extensibility Pass — documentation for new role packs.

## 13. Appendix

### A. DR-MCTS Summary

Use PUCT for selection; child prior blends heuristics and learned policy. Leaf evaluation performs short rollouts, computes doubly-robust estimate, and backs up with β-hybrid.

### B. Sample GBNF

```
event   ::= "{" ws
            "\"type\"" ":" string "," ws
            "\"channel\"" ":" string "," ws
            "\"targets\"" ":" "[" (string ("," string)*)? "]" "," ws
            "\"urgency\"" ":" ("\"low\""|"\"normal\""|"\"high\"")
            "}" ws
```

## References

- DR-MCTS and doubly-robust off-policy evaluation literature.
- VirtualHome multi-room task planning research.
- llama.cpp GBNF documentation.
- BYOND tick usage and `world.Export` best practices.
