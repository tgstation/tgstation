///Deathmatch modifiers are little options the host can choose to spice the match a bit.
/datum/deathmatch_modifier
	///The name of the modifier
	var/name = "Unnamed Modifier"
	///A small description/tooltip shown in the UI
	var/description = "What the heck does this do?"
	///The color of the button shown in the UI
	var/color = "blue"
	///A list of modifiers this is incompatible with.
	var/list/blacklisted_modifiers

///Whether or not this modifier can be selected.
/datum/deathmatch_modifier/proc/selectable(datum/deathmatch_lobby/lobby)
	SHOULD_CALL_PARENT(TRUE)
	if(length(lobby.modifiers & blacklisted_modifiers))
		return FALSE
	for(var/datum/deathmatch_modifier/modifier as anything in lobby.modifiers)
		if(src in GLOB.deathmatch_game.modifiers[modifier].blacklisted_modifiers)
			return FALSE
	return TRUE

///Called when selecting the deathmatch modifier.
/datum/deathmatch_modifier/proc/on_select(datum/deathmatch_lobby/lobby)

///When the host changes his mind and unselects it.
/datum/deathmatch_modifier/proc/unselect(datum/deathmatch_lobby/lobby)
	return

///Called when the host chooses to change map
/datum/deathmatch_modifier/proc/on_map_changed(datum/deathmatch_lobby/lobby)
	return

///Apply the modifier to the newly spawned player as the game is about to start
/datum/deathmatch_modifier/proc/apply(mob/living/player)
	return

/datum/deathmatch_modifier/health
	name = "Double-Health"
	description = "Doubles your starting health."

/datum/deathmatch_modifier/health/apply(mob/living/player)
	player.maxHealth *= 2
	player.health += 2

/datum/deathmatch_modifier/tenacity
	name = "Tenacity"
	description = "Unaffected by being in critical condition and pain."

/datum/deathmatch_modifier/tenacity/apply(mob/living/player)
	player.add_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), DEATHMATCH_TRAIT)

/datum/deathmatch_modifier/ocelot
	name = "Ocelot"
	description = "Shoot faster, with extra ricochet and less spread. You're pretty good!"

/datum/deathmatch_modifier/ocelot/apply(mob/living/player)
	player.add_traits(list(TRAIT_NICE_SHOT, TRAIT_DOUBLE_TAP), DEATHMATCH_TRAIT)
	RegisterSignal(player, COMSIG_MOB_FIRED_GUN, PROC_REF(reduce_spread))
	RegisterSignal(player, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, PROC_REF(apply_ricochet))

/datum/deathmatch_modifier/ocelot/proc/reduce_spread(mob/user, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	bonus_spread_values[MIN_BONUS_SPREAD_INDEX] -= 50
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] -= 50

/datum/deathmatch_modifier/ocelot/proc/apply_ricochet(mob/user, obj/projectile/projectile, datum/fired_from, atom/clicked_atom)
	SIGNAL_HANDLER
	projectile.ricochets_max += 2
	projectile.min_ricochets += 2
	projectile.ricochet_incidence_leeway = 0
	ADD_TRAIT(projectile, TRAIT_ALWAYS_HIT_ZONE, DEATHMATCH_TRAIT)

/datum/deathmatch_modifier/four_hands
	name = "Four Hands"
	description = "When one pair isn't enough..."

/datum/deathmatch_modifier/four_hands/apply(mob/living/player)
	player.change_number_of_hands(4)

/datum/deathmatch_modifier/paraplegic
	name = "Paraplegic"
	description = "Wheelchairs. For. Everyone."

/datum/deathmatch_modifier/paraplegic/applyapply(mob/living/player)
	player.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)
	var/obj/vehicle/ridden/wheelchair/motorized/improved/wheels = new (player.loc)
	wheels.setDir(player.dir)
	wheels.buckle_mob(player)

/datum/deathmatch_modifier/any_loadout
	name = "Any Loadout"
	description = "Watch players pick Instagib everytime."

/datum/deathmatch_modifier/any_loadout/selectable(datum/deathmatch_lobby/lobby)
	. = ..()
	if(!.)
		return
	return !lobby.map.allowed_loadouts

/datum/deathmatch_modifier/any_loadout/on_select(datum/deathmatch_lobby/lobby)
	lobby.loadouts = GLOB.deathmatch_game.loadouts

/datum/deathmatch_modifier/any_loadout/unselect(datum/deathmatch_lobby/lobby)
	lobby.loadouts = lobby.map.allowed_loadouts

/datum/deathmatch_modifier/any_loadout/on_map_changed(datum/deathmatch_lobby/lobby)
	if(lobby.loadouts == GLOB.deathmatch_game.loadouts) //This arena already allows any loadout for some reason.
		lobby.modifiers -= type
	else
		lobby.loadouts = GLOB.deathmatch_game.loadouts
