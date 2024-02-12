/datum/map_template/deathmatch //largest map is 32x32, consider that when spacing map spawners
	/// Map Description
	var/desc = ""
	var/min_players = 2
	var/max_players = 2 // TODO: make this automatic.
	/// The map will end in this time
	var/automatic_gameend_time = 8 MINUTES
	/// List of allowed loadouts for this map, otherwise defaults to all loadouts
	var/list/allowed_loadouts = list()
	/// This is usually the folder
	var/prefix = "_maps/map_files/DM/"
	///The filename
	var/suffix

/datum/map_template/deathmatch/New()
	suffix = prefix + suffix
	..(path = suffix)

/datum/map_template/deathmatch/ragecage
	name = "Ragecage"
	desc = "Fun for the whole family, the classic ragecage."
	max_players = 4
	automatic_gameend_time = 4 MINUTES // its a 10x10 cage what are you guys doing in there
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	suffix = "ragecage.dmm"

/datum/map_template/deathmatch/maintenance
	name = "Maint Mania"
	desc = "Dark maintenance tunnels, floor pills, improvised weaponry and a bloody beatdown. Welcome to assistant utopia."
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	suffix = "Maint_Mania.dmm"

/datum/map_template/deathmatch/osha_violator
	name = "OSHA Violator"
	desc = "What would Engineering be without an overly complicated engine, with conveyor belts, emitters and shield generators sprinkled about? That's right, not Engineering."
	max_players = 10
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	suffix = "OSHA_Violator.dmm"

/datum/map_template/deathmatch/the_brig
	name = "The Brig"
	desc = "A recreation of MetaStation Brig."
	max_players = 12
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	suffix = "The_Brig.dmm"

/datum/map_template/deathmatch/shooting_range
	name = "Shooting Range"
	desc = "A simple room with a bunch of wooden barricades."
	max_players = 6
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative/ranged,
		/datum/outfit/deathmatch_loadout/operative/melee,
	)
	suffix = "shooting_range.dmm"

/datum/map_template/deathmatch/securing
	name = "SecuRing"
	desc = "Presenting the Security Ring, ever wanted to shoot people with disablers? Well now you can."
	max_players = 4
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/securing_sec)
	suffix = "SecuRing.dmm"

/datum/map_template/deathmatch/instagib
	name = "Instagib"
	desc = "EVERYONE GETS AN INSTAKILL RIFLE!"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant/instagib)
	suffix = "instagib.dmm"

/datum/map_template/deathmatch/mech_madness
	name = "Mech Madness"
	desc = "Do you hate mechs? Yeah? Dont care! Go fight eachother!"
	max_players = 4
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/operative)
	suffix = "mech_madness.dmm"

/datum/map_template/deathmatch/sniperelite
	name = "Sniper Elite"
	desc = "Sound of gunfire and screaming people make my day"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/operative/sniper)
	suffix = "Sniper_elite.dmm"

/datum/map_template/deathmatch/meatower
	name = "Meat Tower"
	desc = "There can only be one chef in this kitchen"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/chef)
	suffix = "meatower.dmm"

/datum/map_template/deathmatch/sunrise
	name = "Sunrise"
	desc = "DEHUMANIZE YOURSELF AND FACE TO BLOODSHED DEHUMANIZE YOURSELF AND FACE TO BLOODSHED DEHUMANIZE YOURSELF AND FACE TO BLOODSHED DEHUMANIZE YOURSELF AND FACE TO BLOODSHED"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/samurai)
	suffix = "chinatown.dmm"

/datum/map_template/deathmatch/starwars
	name = "Arena Station"
	desc = "Choose your battler!"
	max_players = 10
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/battler/bloodminer,
		/datum/outfit/deathmatch_loadout/battler/clown,
		/datum/outfit/deathmatch_loadout/battler/cowboy,
		/datum/outfit/deathmatch_loadout/battler/druid,
		/datum/outfit/deathmatch_loadout/battler/enginer,
		/datum/outfit/deathmatch_loadout/battler/janitor,
		/datum/outfit/deathmatch_loadout/battler/northstar,
		/datum/outfit/deathmatch_loadout/battler/raider,
		/datum/outfit/deathmatch_loadout/battler/ripper,
		/datum/outfit/deathmatch_loadout/battler/scientist,
		/datum/outfit/deathmatch_loadout/battler/soldier,
		/datum/outfit/deathmatch_loadout/battler/surgeon,
		/datum/outfit/deathmatch_loadout/battler/tgcoder,
		/datum/outfit/deathmatch_loadout/naked,
	)
	suffix = "starwars.dmm"

/datum/map_template/deathmatch/arenaplatform
	name = "Underground Thunderdome"
	desc = "An illegal underground thunderdome, for larger amounts of murder."
	max_players = 15
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative,
		/datum/outfit/deathmatch_loadout/naked,
	)
	suffix = "arena.dmm"
