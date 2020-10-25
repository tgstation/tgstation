# Dynamic Mode

## Roundstart

Dynamic rolls threat based on a special sauce formula:

> [dynamic_curve_width][/datum/controller/global_vars/var/dynamic_curve_width] \* tan((3.1416 \* (rand() - 0.5) \* 57.2957795)) + [dynamic_curve_centre][/datum/controller/global_vars/var/dynamic_curve_centre]

Latejoin and midround injection cooldowns are set using exponential distribution between

- 5 minutes and 25 for latejoin
- 15 minutes and 35 for midround

this value is then added to `world.time` and assigned to the injection cooldown variables.

[rigged_roundstart][/datum/game_mode/dynamic/proc/rigged_roundstart] is called instead if there are forced rules (an admin set the mode)

1. [can_start][/datum/game_mode/proc/can_start]\()
2. [pre_setup][/datum/game_mode/proc/pre_setup]\()
3. [roundstart][/datum/game_mode/dynamic/proc/roundstart]\() OR [rigged_roundstart][/datum/game_mode/dynamic/proc/rigged_roundstart]\()
4. [picking_roundstart_rule][/datum/game_mode/dynamic/proc/picking_roundstart_rule]\(drafted_rules)
5. [post_setup][/datum/game_mode/proc/post_setup]\()

## Process

Calls [rule_process][/datum/dynamic_ruleset/proc/rule_process] on every rule which is in the current_rules list.
Every sixty seconds, update_playercounts()
Midround injection time is checked against world.time to see if an injection should happen.
If midround injection time is lower than world.time, it updates playercounts again, then tries to inject and generates a new cooldown regardless of whether a rule is picked.

## Latejoin

make_antag_chance(newPlayer) -> (For each latespawn rule...)
-> acceptable(living players, threat_level) -> trim_candidates() -> ready(forced=FALSE)
**If true, add to drafted rules
**NOTE that acceptable uses threat_level not threat!
**NOTE Latejoin timer is ONLY reset if at least one rule was drafted.
**NOTE the new_player.dm AttemptLateSpawn() calls OnPostSetup for all roles (unless assigned role is MODE)

(After collecting all draftble rules...)
-> picking_latejoin_ruleset(drafted_rules) -> spend threat -> ruleset.execute()

## Midround

process() -> (For each midround rule...
-> acceptable(living players, threat_level) -> trim_candidates() -> ready(forced=FALSE)
(After collecting all draftble rules...)
-> picking_midround_ruleset(drafted_rules) -> spend threat -> ruleset.execute()

## Forced

For latejoin, it simply sets forced_latejoin_rule
make_antag_chance(newPlayer) -> trim_candidates() -> ready(forced=TRUE) **NOTE no acceptable() call

For midround, calls the below proc with forced = TRUE
picking_specific_rule(ruletype,forced) -> forced OR acceptable(living_players, threat_level) -> trim_candidates() -> ready(forced) -> spend threat -> execute()
**NOTE specific rule can be called by RS traitor->MR autotraitor w/ forced=FALSE
**NOTE that due to short circuiting acceptable() need not be called if forced.

## Ruleset

acceptable(population,threat) just checks if enough threat_level for population indice.
**NOTE that we currently only send threat_level as the second arg, not threat.
ready(forced) checks if enough candidates and calls the map's map_ruleset(dynamic_ruleset) at the parent level

trim_candidates() varies significantly according to the ruleset type
Roundstart: All candidates are new_player mobs. Check them for standard stuff: connected, desire role, not banned, etc.
**NOTE Roundstart deals with both candidates (trimmed list of valid players) and mode.candidates (everyone readied up). Don't confuse them!
Latejoin: Only one candidate, the latejoiner. Standard checks.
Midround: Instead of building a single list candidates, candidates contains four lists: living, dead, observing, and living antags. Standard checks in trim_list(list).

Midround - Rulesets have additional types
/from_ghosts: execute() -> send_applications() -> review_applications() -> finish_setup(mob/newcharacter, index) -> setup_role(role)
**NOTE: execute() here adds dead players and observers to candidates list
