---
name: bt-refactor
description: 'Port or write DreamMaker AI controllers to the behavior tree (BT) descriptor system in tgstation. Use when: refactoring legacy planning subtrees to BT, writing new bt_node types, debugging BT tree logic, checking blackboard setter patterns, designing combat or bot trees, or reviewing BT architecture decisions.'
argument-hint: 'Which controller or file to port/review'
---

# BT Refactor Skill

Porting tgstation AI controllers from the legacy planning system to the BT descriptor system, and writing or reviewing new BT nodes.

## When to Use

- Porting a controller that still has `planning_subtrees` to a full BT tree
- Writing a new `/datum/bt_node/ai_behavior/` leaf
- Debugging a BT tree that isn't ticking correctly
- Designing combat trees, bot trees, or retaliate patterns
- Reviewing blackboard key usage or observer interrupt logic

## Full Reference

Load the complete architecture, rules, and patterns from [bt-knowledge.md](./references/bt-knowledge.md) before proceeding. It covers:

- Key type hierarchy and legacy compatibility
- Blackboard setter procs and when to use each
- Observer/interrupt (`observer_abort`) system
- Retaliate system and `BB_BASIC_MOB_RETALIATE_LIST`
- Behavior design rules (movement, decorators vs behaviors)
- Combat tree patterns (parallel, selector, multi-attack)
- Bot AI infrastructure (decorators, subtrees, known gotchas)
- Generic controller catalog
- EVlogging macros

## Refactor Procedure

### 1. Audit the existing controller

- Find the controller file (`code/modules/mob/living/basic/` or `code/modules/mob/living/basic/bots/`)
- List all entries in `planning_subtrees`
- Identify any direct `queue_behavior` calls

### 2. Map legacy subtrees to BT equivalents

For each planning subtree, find or create the BT equivalent:

| If legacy uses…              | BT equivalent                                            |
| ---------------------------- | -------------------------------------------------------- |
| `basic_melee_attack`         | `bt_node/ai_behavior/basic_melee_attack`                 |
| `basic_ranged_attack`        | `bt_node/ai_behavior/basic_ranged_attack`                |
| `ai_retaliate` element       | `BB_BASIC_MOB_RETALIATE_LIST` + `target_from_retaliate_list` |
| `find_and_set` subtrees      | Keep at `ai_behavior/` path — write direct BT search leaf |
| `targeted_mob_ability`       | `bt_node/ai_behavior/targeted_mob_ability`               |
| Move + act planning          | `BT_SEQUENCE(move_to_target, action_leaf)`               |

See [bt-knowledge.md](./references/bt-knowledge.md) for full rules on typepath requirements and stubs.

### 3. Write the BT descriptor

Follow the tree structure rules:
- `BT_LEAF` paths **must** be `/datum/bt_node/ai_behavior/...` — never `/datum/ai_behavior/...`
- Use `BT_SEQUENCE` for move-then-act; use `BT_PARALLEL(BT_PARALLEL_FAILURE_ONE, …)` for combat
- Use `BT_SELECTOR` for mutually exclusive attack modes — not `BT_PARALLEL`
- Group repeated decorators under a single decorator with a `BT_SELECTOR` child (decorator grouping rule)
- Decorators are **conditionals only** — never drive movement from a decorator

### 4. Port blackboard keys

- Declare all required `BB_*` keys in `required_blackboard_keys` on the controller
- Use setter procs — never assign `controller.blackboard[key]` directly
- For observer interrupts, set `"observed_keys"` and `"observer_abort"` on the decorator

### 5. Remove legacy artifacts

- Clear `planning_subtrees` — a fully ported controller must have zero entries
- Remove any `setup_subtrees` override (it's a no-op)
- Remove `AI_BEHAVIOR_REQUIRE_MOVEMENT` / `AI_BEHAVIOR_REQUIRE_REACH` flags (no-ops in BT)
- Delete stubs only referenced from BT trees (no `queue_behavior` callers)

### 6. Validate

- Compile and confirm no DM errors
- Trace the tree mentally: verify every code path has a movement leaf where movement is needed
- Confirm `BT_PARALLEL` is not used where `BT_SEQUENCE` is correct
- Check that all `BT_LEAF` paths are `/datum/bt_node/ai_behavior/` paths
