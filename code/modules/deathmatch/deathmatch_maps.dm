/datum/deathmatch_map
	var/name = "If you see this someone is did a mistake and is going to die."
	var/desc = ""
	var/min_players = 2
	var/max_players = 2 // TODO: make this automatic.
	var/datum/species/forced_species
	var/list/allowed_loadouts = list()
	var/map_path = ""
	var/datum/map_template/template

/datum/deathmatch_map/New()
	. = ..()
	if (!map_path)
		return qdel(src) && stack_trace("MISSING MAP PATH!")
	template = new(path = map_path)

/datum/deathmatch_map/proc/map_equip(mob/living/carbon/human/player)
	SHOULD_CALL_PARENT(TRUE)
	if (forced_species)
		player.set_species(forced_species)

/datum/deathmatch_map/ragecage
	name = "Ragecage"
	desc = "Fun for the whole family, the classic ragecage."
	allowed_loadouts = list(/datum/deathmatch_loadout/assistant)
	map_path = "_maps/map_files/DM/ragecage.dmm"

/datum/deathmatch_map/maintenance
	name = "Maint Mania"
	desc = "Dark maintenance tunnels, floor pills, improvised weaponry and a bloody beatdown. Welcome to assistant utopia."
	min_players = 2
	max_players = 8
	allowed_loadouts = list(/datum/deathmatch_loadout/assistant)
	map_path = "_maps/map_files/DM/Maint_Mania.dmm"

/datum/deathmatch_map/osha_violator
	name = "OSHA Violator"
	desc = "What would Engineering be without an overly complicated engine, with conveyor belts, emitters and shield generators sprinkled about? That's right, not Engineering."
	min_players = 2
	max_players = 8
	allowed_loadouts = list(/datum/deathmatch_loadout/assistant)
	map_path = "_maps/map_files/DM/OSHA_Violator.dmm"

/datum/deathmatch_map/the_brig
	name = "The Brig"
	desc = "A recreation of MetaStation Brig."
	min_players = 2
	max_players = 12
	allowed_loadouts = list(/datum/deathmatch_loadout/assistant)
	map_path = "_maps/map_files/DM/The_Brig.dmm"

/datum/deathmatch_map/shooting_range
	name = "Shooting Range"
	desc = "A simple room with a bunch of wooden barricades."
	min_players = 2
	max_players = 5
	allowed_loadouts = list(
		/datum/deathmatch_loadout/gunperative,
		/datum/deathmatch_loadout/meleeperative
	)
	map_path = "_maps/map_files/DM/shooting_range.dmm"

/datum/deathmatch_map/securing
	name = "SecuRing"
	desc = "Presenting the Security Ring, ever wanted to shoot people with disablers? Well now you can."
	min_players = 2
	max_players = 4
	allowed_loadouts = list(/datum/deathmatch_loadout/securing_sec)
	map_path = "_maps/map_files/DM/SecuRing.dmm"

/datum/deathmatch_map/instagib
	name = "Instagib"
	desc = "EVERYONE GETS AN INSTAKILL RIFLE!"
	min_players = 2
	max_players = 8
	allowed_loadouts = list(/datum/deathmatch_loadout/instagib)
	map_path = "_maps/map_files/DM/instagib.dmm"
