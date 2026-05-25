# BT (Behavior Tree) AI Controller Knowledge

**Auto-update directive:** If you discover new important facts about the BT system during a refactor session — new procs, architectural decisions, gotchas, or design constraints — append them to the relevant section of this file before the session ends. Do not wait to be asked.

C:\Users\Floyd\Documents\tgstation\.claude\skills\bt-refactor\references\bt-knowledge.md

---

## Architecture Overview

The BT system lives in `code/datums/ai/`. Controllers tick a tree of `bt_node` instances each process cycle. The main entry point is `ai_controller/SelectBehaviors()` which iterates `behavior_nodes` and ticks each root node until one returns `BT_RUNNING`.

### Key type hierarchy

- `/datum/ai_controller` — base controller, owns the blackboard and BT root
- `/datum/bt_node` — base BT node
  - `/datum/bt_node/composite/selector` — tries children left-to-right, stops on first SUCCESS
  - `/datum/bt_node/composite/sequence` — tries children left-to-right, stops on first FAILURE
  - `/datum/bt_node/composite/parallel` — ticks all children, failure policy configurable
  - `/datum/bt_node/decorator` — wraps one child, can gate or transform its result
  - `/datum/bt_node/ai_behavior` — leaf node that wraps actual behavior logic

### Legacy compatibility

`/datum/ai_behavior` is the old planning-system base. Most legacy types now use `parent_type = /datum/bt_node/ai_behavior/...` to inherit BT behavior while keeping their old typepath for modules that still reference them. **Do not remove these stubs until all module files are ported.**

### Typepath rule for BT trees

**`BT_LEAF` must always use `/datum/bt_node/ai_behavior/...` paths — never `/datum/ai_behavior/...`.** Using a legacy `ai_behavior` path in a `BT_LEAF` is not allowed even if that type redirects via `parent_type`. The correct fix is to create a proper `/datum/bt_node/ai_behavior/` type and reduce the legacy stub to a redirect-only stub (or remove it entirely if no planning code uses it).

Stubs that are only referenced from BT trees (no `queue_behavior` callers) should be deleted outright rather than kept as redirects.

---

## Blackboard System

The blackboard (`controller.blackboard`) is an alist of key→value. **Always use the setter procs** — never assign directly — because they handle reference tracking and fire signals.

### Setter procs

| Proc                                                   | Use case                                                                                                                                                                                                                       |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `set_blackboard_key(key, value)`                       | Single non-list value. Fires `COMSIG_AI_BLACKBOARD_KEY_SET`. Crashes if key already holds a list.                                                                                                                              |
| `override_blackboard_key(key, value)`                  | Force-replaces any existing value including lists.                                                                                                                                                                             |
| `clear_blackboard_key(key)`                            | Sets to null. Fires `COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)` — distinct from KEY_SET. Decorators watching `observer_abort` on KEY_SET will NOT react, but any `RegisterSignal` on `COMSIG_AI_BLACKBOARD_KEY_CLEARED` will fire. |
| `insert_blackboard_key_lazylist(key, thing)`           | Adds `thing` to a lazylist using `\|=` (no duplicates). Fires `COMSIG_AI_BLACKBOARD_KEY_SET`.                                                                                                                                  |
| `set_blackboard_key_assoc_lazylist(key, thing, value)` | Adds `thing→value` to an assoc lazylist. Fires signal. Used by `ai_retaliate` and `capricious_retaliate`.                                                                                                                      |
| `add_blackboard_key_assoc_lazylist(key, thing, value)` | Like above but `+=` instead of `=` for inner value.                                                                                                                                                                            |
| `post_blackboard_key_set(key)`                         | Manually fires `COMSIG_AI_BLACKBOARD_KEY_SET(key)`. Call after any direct list mutation if observer aborts need to trigger.                                                                                                    |

### Critical: `insert_blackboard_key_lazylist` did NOT fire the signal before the BT refactor

Fixed — it now calls `post_blackboard_key_set`. Any workarounds that called `set_blackboard_key` redundantly after insertion should be removed.

---

## Observer / Interrupt System

Decorators can register as observers on blackboard keys. When `COMSIG_AI_BLACKBOARD_KEY_SET(key)` fires, matching observers evaluate `evaluate_for_observer()` and abort nodes based on `observer_abort`.

### `observer_abort` values

- `BT_ABORT_NONE` — no interrupt
- `BT_ABORT_SELF` — abort and replan this decorator when the key changes
- `BT_ABORT_LOWER_PRIORITY` — abort lower-priority running nodes (used to preempt idle walk)
- `BT_ABORT_BOTH` — both of the above

### Pattern: interrupt idle on attack

```dm
BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,
    child,
    "key" = BB_BASIC_MOB_RETALIATE_LIST,
    "observed_keys" = list(BB_BASIC_MOB_RETALIATE_LIST),
    "observer_abort" = BT_ABORT_LOWER_PRIORITY
)
```

When `ai_retaliate` fires, the signal triggers this decorator to interrupt lower-priority nodes (e.g. idle walk) and replan immediately.

---

## Retaliate System

### How it works (post-refactor)

1. `/datum/element/ai_retaliate` attaches to a mob and listens for `COMSIG_ATOM_WAS_ATTACKED`.
2. On attack: calls `set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker, world.time)`.
3. This fires `COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_RETALIATE_LIST)`.
4. BT trees watching this key (via `bb_key_set` + `LOWER_PRIORITY`) interrupt idle behavior.
5. `target_from_retaliate_list` BT leaf picks a valid visible attacker and sets `BB_BASIC_MOB_CURRENT_TARGET`.

### `BB_BASIC_MOB_ATTACKED_BY` is GONE

The old single-attacker key and the `attacked_by_enemy` decorator were removed. All retaliation goes through `BB_BASIC_MOB_RETALIATE_LIST`.

### `target_from_retaliate_list` BT leaf (`target_retaliate.dm`)

- Reads `BB_BASIC_MOB_RETALIATE_LIST` — iterating the assoc list keys gives the attacker mobs
- Respects `BB_TARGET_PRIORITY_STRATEGY` via `GET_TARGET_PRIORITY_STRATEGY`
- 2-second cooldown but fast-paths if the existing target is still valid and visible
- `/nearest` subtype picks the closest valid attacker

### Standard retaliate tree pattern

```dm
BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,
    BT_SEQUENCE(
        BT_LEAF(/datum/bt_node/ai_behavior/target_from_retaliate_list,
            BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION
        ),
        BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,
            BT_LEAF(/* attack leaf */, ...),
            BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_BASIC_MOB_CURRENT_TARGET, 1)
        )
    ),
    "key" = BB_BASIC_MOB_RETALIATE_LIST,
    "observed_keys" = list(BB_BASIC_MOB_RETALIATE_LIST),
    "observer_abort" = BT_ABORT_LOWER_PRIORITY
)
```

---

## Behavior Design Rules

### Behaviors are pure actions (design goal)

Behaviors (`/datum/bt_node/ai_behavior`) must be **pure actions** — they do not manage their own movement. Movement always lives in the tree structure via decorators or explicit `move_to_target` leaves. This is a deliberate design goal: granular behaviors + decorators give finer tree control, making it easier to reason about, debug, and reconfigure AI logic.

**`AI_BEHAVIOR_REQUIRE_MOVEMENT` and `AI_BEHAVIOR_REQUIRE_REACH` are NO-OPS in the BT tick** — legacy planning flags that do nothing. Do not rely on them; put movement in the tree.

### Move + Act: always use a behavior leaf for movement

**Decorators are conditionals only — they must never drive movement.** `is_at_distance` is a pure gate: it returns FAILURE when the pawn is out of range and SUCCESS when in range, but it does NOT call `start_moving_towards` or otherwise move the pawn. Relying on it for movement means the bot will never move.

Movement must always go through a behavior leaf such as `move_to_target`. The standard pattern for "move to target then act" is a `BT_SEQUENCE`:

```dm
BT_SEQUENCE(
    BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_CLEAN_TARGET, 0),
    BT_LEAF(/datum/bt_node/ai_behavior/execute_clean, BB_CLEAN_TARGET),
)
```

The sequence stops at `move_to_target` (returns RUNNING) until the pawn is adjacent, then advances to the action leaf. `is_at_distance` may be used as an additional conditional gate on top if you need to express a range condition elsewhere in the tree, but it must never be the sole thing responsible for getting the bot to its target.

**Don't use `BT_PARALLEL` for move + act** — parallel ticks both every tick; a sequence stops trying to act when the movement leg fails. The sequence is usually correct and cheaper.

**`BT_PARALLEL` is for truly concurrent actions only**, e.g. combat where the mob should simultaneously attack AND keep moving:

```dm
BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,
    BT_LEAF(basic_melee_attack, BB_BASIC_MOB_CURRENT_TARGET),
    BT_LEAF(move_to_target, BB_BASIC_MOB_CURRENT_TARGET, 1)
)
```

### Composites have memory — resume from last RUNNING child

Both `sequence` and `selector` store the last-RUNNING child index per controller in `running_child_index` (alist). On subsequent ticks they resume from that index rather than restarting from child 1.

- **Sequence**: skips children 0..N-1 that already succeeded last tick.
- **Selector**: skips children 0..N-1 that already failed last tick.

This is reset by `CancelActions()` → `reset_bt_tick_states()`, which calls `reset_tick_state(controller)` on each node. Observer/interrupt decorators (`BT_ABORT_LOWER_PRIORITY`, `BT_ABORT_SELF`) already call `CancelActions()`, so high-priority preemption still works correctly.

**Design consequence**: individual steps still benefit from being idempotent (fast-return SUCCESS if work already done), but it is no longer necessary to keep them cheap just to avoid repeated evaluation on the path to the running child.

### Decorator vs. behavior check rule

**Decorators are conditionals only.** They must never drive movement, trigger actions, or produce side effects. A decorator that calls `set_movement_target()`, `start_moving_towards()`, or anything that changes world state is wrong.

Move a check to a **decorator** when:

1. It's a gate that prevents the entire subtree from running
2. It can be evaluated without side effects
3. It would be evaluated redundantly by multiple behaviors in the same branch

Leave a check **inside `perform()`** when:

1. It's a runtime safety guard (`QDELETED(target)`)
2. It's a behavioral parameter affecting HOW the action runs, not WHETHER
3. It requires async context or side effects to evaluate

---

## Combat Tree Design Rules

### The parallel structure rule

A `BT_PARALLEL` should contain **logically concurrent** actions only — typically one attack branch and movement. **Mutually exclusive attack modes (melee vs ranged) must be a `BT_SELECTOR`, not a `BT_PARALLEL`.**

### Multi-attack pattern

```dm
BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,
    BT_SELECTOR(
        BT_LEAF(attack_obstructions, ...),  // FAILURE when path clear — self-gating
        BT_LEAF(basic_melee_attack, ...),   // FAILURE when not adjacent — self-gating
        BT_LEAF(basic_ranged_attack, ...)   // fallback
    ),
    BT_LEAF(move_to_target, ...)
)
```

Range-check decorators (`target_in_melee_range`, `target_outside_melee_range`) exist in `basic_decorators.dm` for explicit gating when needed, but the selector pattern usually suffices since leaves self-gate.

### Decorator grouping rule

When multiple adjacent branches in a selector share the same gate condition, wrap them together under **one** decorator with a `BT_SELECTOR` child — do not repeat the same decorator on each branch.

**Wrong (repeated decorator):**

```dm
BT_DECORATOR(bot_not_emagged, <branch_A>),
BT_DECORATOR(bot_not_emagged, <branch_B>),
BT_DECORATOR(bot_not_emagged, <branch_C>),
BT_DECORATOR(bot_is_emagged, <branch_D>),
BT_DECORATOR(bot_is_emagged, <branch_E>),
```

**Right (grouped):**

```dm
BT_DECORATOR(bot_not_emagged,
    BT_SELECTOR(
        <branch_A>,
        <branch_B>,
        <branch_C>,
    )
),
BT_DECORATOR(bot_is_emagged,
    BT_SELECTOR(
        <branch_D>,
        <branch_E>,
    )
),
```

This applies to any repeated decorator: `bb_key_set`, `bot_mode_flag`, `bb_key_cooldown`, etc.

### `targeted_mob_ability` argument order

`perform(seconds_per_tick, controller, ability_key, target_key)` — ability key first, target key second.

```dm
BT_LEAF(/datum/bt_node/ai_behavior/targeted_mob_ability,
    BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET
)
```

**Common bug**: passing targeting strategy keys instead. This was present in the generic trees and fixed during the BT refactor.

---

## Capricious Retaliate

`/datum/bt_node/ai_behavior/capricious_retaliate` manages `BB_BASIC_MOB_RETALIATE_LIST` directly:

- If list exists: rolls `BB_RANDOM_DEAGGRO_CHANCE` (default 10%/tick) to clear list + current target.
- If no list: rolls `BB_RANDOM_AGGRO_CHANCE` (default 50%/tick) to pick a random nearby mob and add via `set_blackboard_key_assoc_lazylist`.

Runs in `BT_PARALLEL(FAILURE_ALL)` alongside the combat branch so de-aggro can interrupt mid-combat. When de-aggro clears the list, `bb_key_set` condition fails → combat branch returns FAILURE → `FAILURE_ALL` → parent fails → controller idles.

---

## Subsystem: `SSai_behaviors`

`/datum/controller/subsystem/processing/ai_behaviors` holds three singleton registries:

- `ai_behaviors` — all `/datum/bt_node/ai_behavior` subtypes (legacy stubs included via `parent_type`)
- `targeting_strategies` — all `/datum/targeting_strategy` subtypes
- `target_priority_strategies` — all `/datum/target_priority_strategy` subtypes

Access macros:

```dm
GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[BB_TARGET_PRIORITY_STRATEGY])
```

---

## Generic Controllers (`generic_controllers.dm`)

Standard controller subtypes under `/datum/ai_controller/basic_controller/simple/`:

| Controller                 | Combat style                             |
| -------------------------- | ---------------------------------------- |
| `simple_hostile`           | Melee, active target search              |
| `simple_hostile_obstacles` | Melee + obstacle smashing                |
| `simple_ranged`            | Ranged, active target search             |
| `simple_ranged_retaliate`  | Ranged, retaliate-only                   |
| `simple_skirmisher`        | Selector: obstacles → melee → ranged     |
| `simple_ability`           | Ability only                             |
| `simple_ability_retaliate` | Ability, retaliate-only                  |
| `simple_ability_melee`     | Selector: obstacles → ability → melee    |
| `simple_ability_ranged`    | Selector: ability → ranged               |
| `simple_retaliate`         | Melee, retaliate-only                    |
| `simple_capricious`        | Random aggro/de-aggro via retaliate list |
| `simple_fearful`           | Flees nearest target                     |
| `simple_skittish`          | Flees attackers only                     |
| `simple_goon`              | Pet commands (TODO: full BT port)        |

---

## EVlogging System

All macros short-circuit on `!GLOB.event_logger.running || !(datum_flags & DF_EVLOGGING)` — free when not in use.

### Macros (defined in `code/__DEFINES/event_logger.dm`)

| Macro                                                | Use                                 |
| ---------------------------------------------------- | ----------------------------------- |
| `EVLOG_TEXT(datum, category, info)`                  | Plain text decision log             |
| `EVLOG_LOCATION(datum, category, info, turf)`        | Single tile highlight               |
| `EVLOG_TURFS(datum, category, info, turfs)`          | Multi-tile highlight                |
| `EVLOG_LINES(datum, category, info, turf_a, turf_b)` | A→B path line                       |
| `EVLOG_MAPTEXT(datum, category, info, turf, text)`   | Floating text on map                |
| `IS_EVLOGGING`                                       | Check if logger is globally running |

### Categories for BT nodes

- `EVLOG_CATEGORY_AI_DECISIONMAKING` — tree traversal decisions
- `EVLOG_CATEGORY_AI_BEHAVIORS` — behavior performs (target selection, actions)
- `EVLOG_CATEGORY_AI_TARGETING` — target acquisition / blacklist events

### When to add

In `perform()`: log what target was selected and why — use `EVLOG_MAPTEXT` + `EVLOG_LINES`.
In decorator `check_condition()`: log condition failures — use `EVLOG_TEXT` with `EVLOG_CATEGORY_AI_DECISIONMAKING`.

### Activation

`DF_EVLOGGING` flag on the datum. Enable per-instance with `enable_evlogging()`.

---

## Bot AI Infrastructure

Bot controllers: `code/modules/mob/living/basic/bots/`. Bot BT infrastructure: `code/datums/ai/bots/`.

### Bot decorators (`code/datums/ai/bots/bot_decorators.dm`)

- `bot_is_emagged` — gates on `pawn.bot_access_flags & BOT_COVER_EMAGGED`. Use `"invert" = TRUE` for "not emagged". No observer signal — checked each tick.
- `bot_mode_flag` — gates on `pawn.bot_mode_flags & flag`. Observes `COMSIG_BOT_MODE_FLAGS_SET`.
- `bb_key_cooldown` — gates on `isnull(blackboard[cooldown_key]) || blackboard[cooldown_key] <= world.time`. Evaluated each tick.
- `bot_medical_flag` — gates on `(pawn as medbot).medical_mode_flags & flag`. Use `"invert" = TRUE` for "does not have flag".
- `secbot_target_valid` — checks target not handcuffed/paralyzed; clears `BB_BASIC_MOB_CURRENT_TARGET` if invalid.

### Decorator `invert` flag

All decorators support `"invert" = TRUE` (a `var/invert` on `/datum/bt_node/decorator`). When set, `check_condition()` result is inverted before gating the child — equivalent to a logical NOT. This replaces the old pattern of creating a separate `foo_not_bar` type for every negation. Do not create `_not_` decorator subtypes; use `"invert" = TRUE` on the positive variant instead.

### `set_bb_cooldown` utility leaf

`/datum/bt_node/ai_behavior/set_bb_cooldown` is defined in `bot_subtrees.dm`. Takes `(cooldown_key, cooldown_duration)` as BT args and writes `world.time + cooldown_duration` to the blackboard. Returns `AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED`.

Use it as the last leaf of a sequence to set a `bb_key_cooldown`-managed rate limit after a successful action:

```dm
BT_DECORATOR(/datum/bt_node/decorator/bb_key_cooldown,
    BT_SEQUENCE(
        BT_LEAF(/datum/bt_node/ai_behavior/find_spray_target, BB_ACID_SPRAY_TARGET),
        BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_ACID_SPRAY_TARGET, 0, TRUE),
        BT_LEAF(/datum/bt_node/ai_behavior/execute_clean, BB_ACID_SPRAY_TARGET),
        BT_LEAF(/datum/bt_node/ai_behavior/set_bb_cooldown, BB_ACID_SPRAY_COOLDOWN, 30 SECONDS)
    ),
    "cooldown_key" = BB_ACID_SPRAY_COOLDOWN
)
```

The sequence only advances to `set_bb_cooldown` on a full success path; a failure on any earlier leaf means the cooldown key is never set and the whole branch retries next tick (modulo earlier gates). **Always use `set_bb_cooldown` as the trailing leaf — never set cooldown timestamps in `PostPerform()` or `finish_action()`.**

### Shared bot subtrees (`code/datums/ai/bots/bot_subtrees.dm`)

- `bot_respond_to_summon` — `bb_key_set`-gated travel to `BB_BOT_SUMMON_TARGET`
- `bot_salute_authority` — `bb_key_cooldown`-gated sequence: find commissioned officer → salute → set `BB_SALUTE_COOLDOWN` to `BOT_COMMISSIONED_SALUTE_DELAY`. No emag check — callers that want to suppress saluting while emagged add their own `bot_is_emagged` gate above this subtree.
- `bot_find_patrol_beacon` — find/travel to beacon with cooldown and autopatrol mode gate

### `travel_towards` is broken in BT context

`set_movement_target()` is a NO-OP shim on `bt_node/ai_behavior`. Use `is_at_distance` decorator for movement + a pure completion action leaf instead.

### `use_mob_ability` BT-native version (created)

`/datum/bt_node/ai_behavior/use_mob_ability` is defined in `code/datums/ai/bots/bot_subtrees.dm`. It calls `using_action.Trigger()` and returns INSTANT SUCCESS/FAILURE. The `/random_honk` subtype overrides `perform()` to add `SPT_PROB(5, seconds_per_tick)` gating before calling `..()`. Use `AI_BEHAVIOR_INSTANT` (no delay) so it doesn't block the parallel track.

### `ranged_skirmish` is planning-only

`/datum/ai_planning_subtree/ranged_skirmish` is a planning subtree. No BT version exists. In BT trees, replace with `basic_ranged_attack` which is already BT-native.

### `find_and_set` stays at `ai_behavior/` path

`/datum/ai_behavior/find_and_set` and its subtypes must remain at the `ai_behavior/` path — they are used by non-ported mobs (e.g. `basic_ai_behaviors/`). When porting bots: do **not** try to subtype `find_and_set` for BT. Instead write **direct BT search behaviors** (`find_clean_target`, `find_spray_target`, etc.) that put the search logic in their own `perform()`. Same rule for `befriend_target` — keep `ai_behavior/befriend_target` for `pet_cult_ai`; create `bt_node/ai_behavior/befriend_target` for cleanbot.

### `ai_behavior/drag_target` dual-path requirement

`/datum/ai_behavior/drag_target` is defined in `basic_subtrees/drag_items.dm` and used by the `steal_items` planning subtree. **Do not remove or move it.** For bots (honkbot, repairbot) that need drag-and-drop in BT trees, create a separate `bt_node/ai_behavior/drag_target` that does NOT auto-clear the target key on finish — the planning version's `finish_action` clears the key unconditionally, which causes grab+release in the same tick.

### Honkbot slip bug (original code)

`drag_target/finish_action` calls `controller.clear_blackboard_key(BB_SLIP_TARGET)`. This fires `COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_SLIP_TARGET)`. The controller's `on_clear_target` handler fires → `stop_pulling()`. Net effect: bot grabs AND releases the victim in the same tick, never drags. **Fix in BT port**: use an idempotent `grab_victim` leaf (fast-returns SUCCESS if already pulling the target), do NOT clear `BB_SLIP_TARGET` in finish_action, remove `on_clear_target` handler, rely on `on_stop_pulling` for external-pull interruption instead.

---

## Documentation

Avoid long-tangential, or overly specific comments. Focus on the basics:

e.g. // This decorator returns X if you are within range, and Y if not.

## Known Open Issues

- **Pet commands** (`simple_goon` / `pet_planning`): `execute_action` in command datums still uses legacy `queue_behavior`. The `pet_planning` node is a bridge stub. Full parity requires porting each pet command datum.
- **`setup_subtrees`** is a no-op — legacy planning subtree registry was removed.
- **`CancelActions`** calls `reset_bt_tick_states()`. Legacy code that expected `finish_action` to be called on cancellation may not behave identically.

---

## Bot Tree Patterns (from cleanbot)

These patterns were extracted from the cleanbot BT descriptor (`cleanbot.bt.json`) and apply to all service-style bots.

### `key_off_cooldown` decorator

The correct decorator type for cooldown-gating in **JSON descriptors** is `/datum/bt_node/decorator/key_off_cooldown` (config key: `"cooldown_key"`). In DM macro trees this is occasionally written as `bb_key_cooldown` in comments/docs, but the actual type is `key_off_cooldown`. Both refer to the same type.

```json
{
    "type": "decorator",
    "decorator": "/datum/bt_node/decorator/key_off_cooldown",
    "config": { "cooldown_key": "BB_POST_CLEAN_COOLDOWN" },
    "child": { ... }
}
```

### `bb_key_set` with `"invert": true` — "find if not set" gate

Using `"invert": true` on a `bb_key_set` decorator inverts the condition: the child only runs when the key is **null/not set**. This is the canonical "lazy find" pattern — run the find behavior only when we don't already have a target.

```json
{
	"type": "decorator",
	"decorator": "/datum/bt_node/decorator/bb_key_set",
	"config": { "key": "BB_CLEAN_TARGET", "invert": true },
	"child": {
		"type": "leaf",
		"behavior": "/datum/bt_node/ai_behavior/find_clean_target",
		"args": ["BB_CLEAN_TARGET"]
	}
}
```

`observer_abort` works correctly on inverted `bb_key_set` decorators. `setup_bt_observers()` registers **both** `COMSIG_AI_BLACKBOARD_KEY_SET` and `COMSIG_AI_BLACKBOARD_KEY_CLEARED` for any decorator with `observer_abort != BT_ABORT_NONE`. On each signal, `on_observed_change` calls `check_condition()` which respects `invert` — so an inverted decorator with `BT_ABORT_BOTH` will self-abort when the key is set (condition flips false) and preempt lower-priority nodes when it is cleared (condition flips true). Add `"observer_abort"` to inverted find-gate decorators when you want reactive interrupts on target loss.

### Canonical bot tree skeleton

Every service-bot BT descriptor follows this top-level selector ordering:

```
SELECTOR
├── subtree: escape_captivity/pacifist       (highest priority — always try to flee captivity)
├── subtree: bot_respond_to_summon           (travel to owner if summoned)
├── leaf: pet_planning                       (WIP — pet commands bridge)
├── DECORATOR(bot_is_emagged, invert=true)   (normal operation branch)
│   └── <normal work parallel>
└── DECORATOR(bot_is_emagged)                (emagged operation branch)
    └── <emagged work parallel>
```

`escape_captivity/pacifist` and `bot_respond_to_summon` must come before the emagged branch so they fire even when emagged.

### bot parallel structure

The non-emag and emag work block use a parallel with specific flags to create a "work + background" split:

```json
{
	"type": "parallel",
	"failure_policy": "BT_PARALLEL_FAILURE_CHILD_ONE",
	"success_policy": "BT_PARALLEL_SUCCESS_CHILD_ONE",
	"repeat_secondary": true,
	"finish_on_primary": true,
	"children": [
		{
			/* PRIMARY: action selector — does the actual work */
		},
		{
			/* SECONDARY: background selector — finds targets, salutes, etc. */
		}
	]
}
```

- `finish_on_primary: true` — when child 1 finishes (success or failure), cancel all secondaries and return child 1's result immediately. The bot doesn't keep looping background tasks after the primary task resolves.
- `repeat_secondary: true` — background children that finish non-RUNNING are auto-reset and reticked, so the background track keeps running in a tight loop while the primary works.

**Primary child (action selector)** — tries in order:

1. `bb_key_set(target, observer_abort=BT_ABORT_BOTH)` → move + act sequence
2. Fallback actions (befriend janitor, etc.)
3. `key_off_cooldown(post_action_cooldown)` → patrol subtree

**Secondary child (background selector)** — tries in order:

1. `bb_key_set(target, invert=true)` → find target leaf (only runs when no target)
2. `bot_salute_authority` subtree (background filler)

**Why `BT_ABORT_BOTH` on the action branch**: if the target key changes (externally cleared or replaced), `BT_ABORT_BOTH` restarts the decorator itself so the new target is processed immediately without waiting for the old move sequence to fail naturally.

### Emagged-mode bot parallel structure

The emagged work block uses the same `finish_on_primary` + `repeat_secondary` flags as the normal-mode parallel — the secondary track keeps looping to find a target while the primary action runs:

```json
{
	"type": "parallel",
	"failure_policy": "BT_PARALLEL_FAILURE_CHILD_ONE",
	"success_policy": "BT_PARALLEL_SUCCESS_CHILD_ONE",
	"repeat_secondary": true,
	"finish_on_primary": true,
	"children": [
		{
			/* PRIMARY: emagged action selector */
		},
		{
			/* SECONDARY: find emagged target */
		}
	]
}
```

`finish_on_primary: true` + `repeat_secondary: true` ensures the target-find secondary keeps looping while the bot acts, and the parallel resolves as soon as the primary action branch finishes — identical semantics to the normal-mode parallel.
