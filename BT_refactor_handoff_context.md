# BT Refactor Handoff Context

## Goal

Port generic basic mob AI controllers from legacy planning subtrees to BT descriptors and BT-native leaves/decorators, while preserving legacy compatibility where still referenced by module-specific AI files.

## Current Status

- Compile status: clean build on DreamMaker (0 errors, 4 existing warnings from compile options/comments).
- Major BT port work is in place for generic controllers.
- Compatibility stubs were restored for legacy ai_behavior subtype trees that still exist in module files.

## Key Design Decisions Already Agreed

- Retaliate controllers should use attacked_by_enemy decorator to interrupt lower-priority behavior.
- Do not add a new movement type for run_away_from_target.
- New refactored BT implementations should avoid parent_type, but deprecated compatibility stubs are acceptable where needed for legacy compile compatibility.

## Important Behavior/Engine Notes

- insert_blackboard_key_lazylist does not fire COMSIG_AI_BLACKBOARD_KEY_SET.
- A dedicated single-value key BB_BASIC_MOB_ATTACKED_BY was added and set via set_blackboard_key so observer abort works.
- setup_subtrees is intentionally no-op; legacy planning-subtree registry removed.
- Legacy queue_behavior path is a no-op in deprecated ai_behavior base and must be replaced with BT-native direct behavior execution for real migration.

## Files Changed So Far

- code/\_\_DEFINES/ai/ai_blackboard.dm
- code/datums/elements/ai_retaliate.dm
- code/datums/ai/basic_mobs/basic_decorators.dm
- code/datums/ai/basic_mobs/basic_ai_behaviors/basic_attacking.dm
- code/datums/ai/basic_mobs/basic_ai_behaviors/run_away_from_target.dm
- code/datums/ai/basic_mobs/basic_ai_behaviors/targeted_mob_ability.dm
- code/datums/ai/basic_mobs/basic_ai_behaviors/nearest_targeting.dm
- code/datums/ai/basic_mobs/basic_subtrees/attack_obstacle_in_path.dm
- code/datums/ai/basic_mobs/basic_subtrees/capricious_retaliate.dm
- code/datums/ai/basic_mobs/basic_subtrees/speech_subtree.dm
- code/datums/ai/basic_mobs/basic_subtrees/target_retaliate.dm
- code/datums/ai/basic_mobs/pet_commands/pet_command_planning.dm
- code/datums/ai/basic_mobs/generic_controllers.dm
- code/datums/ai/\_ai_behavior.dm
- tgstation.dme

## What Was Added

- BT decorator file for basic mobs:
  - random_chance
  - attacked_by_enemy
- BT-native leaves:
  - basic_ranged_attack
  - run_away_from_target
  - targeted_mob_ability
  - attack_obstructions
  - capricious_retaliate
  - random_speech_blackboard
  - target_from_retaliate_list plus nearest subtype
  - find_potential_targets nearest subtype
- BT subtree for pet_planning (with TODO caveat)
- Generic controller BT subtree/controller rewrites in generic_controllers.dm
- DME include for basic_decorators.dm
- Compatibility shims and deprecated stubs restored for legacy module subtype paths.

## Latest User Feedback To Apply Next

User feedback:

- Too much logic was pushed into single large parallels.
- One parallel is fine, but branch A should be a selector deciding melee versus ranged (or other attack mode).
- Condition checks like target reachable should ideally be decorators/gates rather than buried entirely inside leaves.
- Apply this style consistently across all new controllers.

## What I Was About To Do Next

1. Add small selector-ready leaf variants for clean branch selection.

- Add a ranged variant suitable for close-range gating (for example only fire when not in melee range).
- Add ability variants with explicit argument ordering and optional gate behavior where needed.

2. Fix argument wiring for targeted_mob_ability calls in BT subtrees.

- Current perform signature expects ability_key, target_key.
- Several subtree calls currently pass target-related keys in the old ordering and must be corrected.

3. Restructure multi-attack combat trees in generic_controllers.dm.

- Keep one top-level parallel where appropriate.
- Make branch A a selector of attack modes, example pattern:
  - selector
    - melee path (gated by reachable/in-range condition decorator)
    - ranged path (gated by not-in-melee condition decorator)
    - ability path where appropriate
- Keep branch B as movement.
- Keep find target as fallback branch outside that combat parallel where relevant.

4. Introduce dedicated decorators for attack-mode gating and reuse across trees.

- Candidate decorators:
  - has_valid_target style gate
  - target_reachable_for_melee style gate
  - target_not_reachable_for_melee style gate
- Use observer-aware settings where useful, otherwise regular check_condition decorators.

5. Rebuild and iterate until clean.

## Known Caveat Still Open

- Pet commands are not fully BT-native yet; execute_action paths in command datums still rely on legacy queue_behavior behavior in many cases. Current BT pet_planning node is a bridge and may not produce full behavior parity until command datums are ported.

## Practical Handoff Prompt For Next Agent

Please continue from current workspace state and refactor generic BT combat trees so they follow this structure:

- Avoid giant all-in-one parallel combat logic.
- Choose carefully what should be parallel; doing 2 actions (ranged and melee) that arent compatible doesn't make sense for parallel. Decorators should decide which of those should be active.
- In that parallel, A branch should be a selector that chooses melee versus ranged (and ability where applicable) using explicit decorators/gates.
- Move range/reachability decision logic into reusable decorators where possible.
- Verify targeted_mob_ability argument order in all BT subtree calls.
- Preserve compile compatibility with existing legacy module ai_behavior subtype trees.
- Rebuild and confirm 0 compile errors.
