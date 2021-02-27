# Dynamic Mode

## Roundstart

Dynamic rolls threat based on a special sauce formula:

> [dynamic_curve_width][/datum/controller/global_vars/var/dynamic_curve_width] \* tan((3.1416 \* (rand() - 0.5) \* 57.2957795)) + [dynamic_curve_centre][/datum/controller/global_vars/var/dynamic_curve_centre]

This threat is split into two separate budgets--`round_start_budget` and `mid_round_budget`. For example, a round with 50 threat might be split into a 30 roundstart budget, and a 20 midround budget. The roundstart budget is used to apply antagonists applied on readied players when the roundstarts (`/datum/dynamic_ruleset/roundstart`). The midround budget is used for two types of rulesets:
- `/datum/dynamic_ruleset/midround` - Rulesets that apply to either existing alive players, or to ghosts. Think Blob or Space Ninja, which poll ghosts asking if they want to play as these roles.
- `/datum/dynamic_ruleset/latejoin` - Rulesets that apply to the next player that joins. Think Syndicate Infiltrator, which converts a player just joining an existing round into traitor.

This split is done with a similar method, known as the ["lorentz distribution"](https://en.wikipedia.org/wiki/Cauchy_distribution), exists to create a bell curve that ensures that while most rounds will have a threat level around ~50, chaotic and tame rounds still exist for variety.

The process of creating these numbers occurs in `/datum/game_mode/dynamic/proc/generate_threat` (for creating the threat level) and `/datum/game_mode/dynamic/proc/generate_budgets` (for splitting the threat level into budgets).

## Deciding roundstart threats
In `/datum/game_mode/dynamic/proc/roundstart()` (called when no admin chooses the rulesets explicitly), Dynamic uses the available roundstart budget to pick threats. This is done through the following system:

- All roundstart rulesets (remember, `/datum/dynamic_ruleset/roundstart`) are put into an associative list with their weight as the values (`drafted_rules`).
- Until there is either no roundstart budget left, or until there is no ruleset we can choose from with the available threat, a `pickweight` is done based on the drafted_rules. If the same threat is picked twice, it will "scale up". The meaning of this depends on the ruleset itself, using the `scaled_times` variable; traitors for instance will create more the higher they scale.
	- If a ruleset is chosen with the `HIGH_IMPACT_RULESET` in its `flags`, then all other `HIGH_IMPACT_RULESET`s will be removed from `drafted_rules`. This is so that only one can ever be chosen.
	- If a ruleset has `LONE_RULESET` in its `flags`, then it will be removed from `drafted_rules`. This is to ensure it will only ever be picked once. An example of this in use is Wizard, to avoid creating multiple wizards.
- After all roundstart threats are chosen, `/datum/dynamic_ruleset/proc/picking_roundstart_rule` is called for each, passing in the ruleset and the number of times it is scaled.
	- In this stage, `pre_execute` is called, which is the function that will determine what players get what antagonists. If this function returns FALSE for whatever reason (in the case of an error), then its threat is refunded.

After this process is done, any leftover roundstart threat will be given to the existing midround budget (done in `/datum/game_mode/dynamic/pre_setup()`).

## Deciding midround threats

Latejoin and midround injection cooldowns are set using exponential distribution between

- 5 minutes and 25 for latejoin (configurable as latejoin_delay_min and latejoin_delay_max)
- 15 minutes and 35 for midround (configurable as midround_delay_min and midround_delay_max)

this value is then added to `world.time` and assigned to the injection cooldown variables.

[rigged_roundstart][/datum/game_mode/dynamic/proc/rigged_roundstart] is called instead if there are forced rules (an admin set the mode)

1. [setup_parameters][/datum/game_mode/proc/setup_parameters]\()
2. [pre_setup][/datum/game_mode/proc/pre_setup]\()
3. [roundstart][/datum/game_mode/dynamic/proc/roundstart]\() OR [rigged_roundstart][/datum/game_mode/dynamic/proc/rigged_roundstart]\()
4. [picking_roundstart_rule][/datum/game_mode/dynamic/proc/picking_roundstart_rule]\(drafted_rules)
5. [post_setup][/datum/game_mode/proc/post_setup]\()

## Rule Processing

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

## Configuration and variables

### Configuration
Configuration can be done through a `config/dynamic.json` file. One is provided as example in the codebase. This config file, loaded in `/datum/game_mode/dynamic/pre_setup()`, directly overrides the values in the codebase, and so is perfect for making some rulesets harder/easier to get, turning them off completely, changing how much they cost, etc.

The format of this file is:
```json
{
	"Dynamic": {
		/* Configuration in here will directly override `/datum/game_mode/dynamic` itself. */
		/* Keys are variable names, values are their new values. */
	},

	"Roundstart": {
		/* Configuration in here will apply to `/datum/dynamic_ruleset/roundstart` instances. */
		/* Keys are the ruleset names, values are another associative list with keys being variable names and values being new values. */
		"Wizard": {
			/* I, a head admin, have died to wizard, and so I made it cost a lot more threat than it does in the codebase. */
			"cost": 80
		}
	},

	"Midround": {
		/* Same as "Roundstart", but for `/datum/dynamic_ruleset/midround` instead. */
	},

	"Latejoin": {
		/* Same as "Roundstart", but for `/datum/dynamic_ruleset/latejoin` instead. */
	}
}
```

Note: Comments are not possible in this format, and are just in this document for the sake of readability.

### Rulesets
Rulesets have the following variables notable to developers and those interested in tuning.

- `required_candidates` - The number of people that *must be willing* (in their preferences) to be an antagonist with this ruleset. If the candidates do not meet this requirement, then the ruleset will not bother to be drafted.
- `antag_cap` - Judges the amount of antagonists to apply, for both solo and teams. Note that some antagonists (such as traitors, lings, heretics, etc) will add more based on how many times they've been scaled. Written as a linear equation--ceil(x/denominator) + offset, or as a fixed constant. If written as a linear equation, will be in the form of `list("denominator" = denominator, "offset" = offset)`.
	- Examples include:
		- Traitor: `antag_cap = list("denominator" = 24)`. This means that for every 24 players, 1 traitor will be added (assuming no scaling).
		- Nuclear Emergency: `antag_cap = list("denominator" = 18, "offset" = 1)`. For every 18 players, 1 nuke op will be added. Starts at 1, meaning at 30 players, 3 nuke ops will be created, rather than 2.
		- Revolution: `antag_cap = 3`. There will always be 3 rev-heads, no matter what.
- `minimum_required_age` - The minimum age in order to apply for the ruleset.
- `weight` - How likely this ruleset is to be picked. A higher weight results in a higher chance of drafting.
- `cost` - The initial cost of the ruleset. This cost is taken from either the roundstart or midround budget, depending on the ruleset.
- `scaling_cost` - Cost for every *additional* application of this ruleset.
	- Suppose traitors has a `cost` of 8, and a `scaling_cost` of 5. This means that buying 1 application of the traitor ruleset costs 8 threat, but buying two costs 13 (8 + 5). Buying it a third time is 18 (8 + 5 + 5), etc.
- `pop_per_requirement` - The range of population each value in `requirements` represents. By default, this is 6.
	- If the value is five the range is 0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+.
	- If it is six the range is 0-5, 6-11, 12-17, 18-23, 24-29, 30-35, 36-41, 42-47, 48-53, 54+.
	- If it is seven the range is 0-6, 7-13, 14-20, 21-27, 28-34, 35-41, 42-48, 49-55, 56-62, 63+.
- `requirements` - A list that represents, per population range (see: `pop_per_requirement`), how much threat is required to *consider* this ruleset. This is independent of how much it'll actually cost. This uses *threat level*, not the budget--meaning if a round has 50 threat level, but only 10 points of round start threat, a ruleset with a requirement of 40 can still be picked if it can be bought.
	- Suppose wizard has a `requirements` of `list(90,90,70,40,30,20,10,10,10,10)`. This means that, at 0-5 and 6-11 players, A station must have 90 threat in order for a wizard to be possible. At 12-17, 70 threat is required instead, etc.
- `restricted_roles` - A list of jobs that *can't* be drafted by this ruleset. For example, cyborgs cannot be changelings, and so are in the `restricted_roles`.
- `protected_roles` - Serves the same purpose of `restricted_roles`, except it can be turned off through configuration (`protect_roles_from_antagonist`). For example, security officers *shouldn't* be made traitor, so they are in Traitor's `protected_roles`.
	- When considering putting a role in `protected_roles` or `restricted_roles`, the rule of thumb is if it is *technically infeasible* to support that job in that role. There's no *technical* reason a security officer can't be a traitor, and so they are simply in `protected_roles`. There *are* technical reasons a cyborg can't be a changeling, so they are in `restricted_roles` instead.

### Dynamic

The "Dynamic" key has the following configurable values:
- `pop_per_requirement` - The default value of `pop_per_requirement` for any ruleset that does not explicitly set it. Defaults to 6.
- `latejoin_delay_min`, `latejoin_delay_max` - The time range, in deciseconds (take your seconds, and multiply by 10), for a latejoin to attempt rolling. Once this timer is finished, a new one will be created within the same range.
	- Suppose you have a `latejoin_delay_min` of 600 (60 seconds, 1 minute) and a `latejoin_delay_max` of 1800 (180 seconds, 3 minutes). Once the round starts, a random number in this range will be picked--let's suppose 1.5 minutes. After 1.5 minutes, Dynamic will decide if a latejoin threat should be created (a probability of `/datum/game_mode/dynamic/proc/get_injection_chance()`). Regardless of its decision, a new timer will be started within the range of 1 to 3 minutes, repeatedly.
- `midround_delay_min`, `midround_delay_max` - Same as `latejoin_delay_min` and `latejoin_delay_max`, except for midround threats instead of latejoin ones.
- `higher_injection_chance`, `higher_injection_chance_minimum_threat` - Manipulates the injection chance (`/datum/game_mode/dynamic/proc/get_injection_chance()`). If the *current midround budget* is above `higher_injection_chance_minimum_threat`, then this chance will be increased by `higher_injection_chance`.
	- For example: suppose you have a `higher_injection_chance_minimum_threat` of 70, and a `higher_injection_chance` of 15. This means that, if when a midround threat is trying to roll, there is 75 midround budget left, then the injection chance will go up 15%.
- `lower_injection_chance`, `lower_injection_chance_minimum_threat` - The inverse of the `higher_injection_chance` variables. If the *current midround budget* is *below* `lower_injection_chance`, then the chance is lowered by `lower_injection_chance_minimum_threat`.
	- For example: suppose you have a `lower_injection_chance_minimum_threat` of 30, and a `lower_injection_chance` of 15. This means if there is 20 midround budget left, then the chance will lower by 15%.
- `threat_curve_centre` - A number between -5 and +5. A negative value will give a more peaceful round and a positive value will give a round with higher threat.
- `threat_curve_width` - A number between 0.5 and 4. Higher value will favour extreme rounds and lower value rounds closer to the average.
- `roundstart_split_curve_centre` - A number between -5 and +5. Equivalent to threat_curve_centre, but for the budget split. A negative value will weigh towards midround rulesets, and a positive value will weight towards roundstart ones.
- `roundstart_split_curve_width` - A number between 0.5 and 4. Equivalent to threat_curve_width, but for the budget split. Higher value will favour more variance in splits and lower value rounds closer to the average.
