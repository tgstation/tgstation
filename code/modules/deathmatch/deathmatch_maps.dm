/datum/lazy_template/deathmatch
	map_dir = "_maps/deathmatch"
	place_on_top = TRUE
	turf_reservation_type = /datum/turf_reservation/turf_not_baseturf
	/// Map UI Name
	var/name
	/// Map Description
	var/desc = ""
	/// Minimum players for this map
	var/min_players = 2
	/// Maximum players for this map
	var/max_players = 2 // TODO: make this automatic.
	/// The map will end in this time
	var/automatic_gameend_time = 8 MINUTES
	/// List of allowed loadouts for this map, otherwise defaults to all loadouts
	var/list/allowed_loadouts = list()
	/// whether we are currently being loaded by a lobby
	var/template_in_use = FALSE

/datum/lazy_template/deathmatch/ragecage
	name = "Ragecage"
	desc = "Fun for the whole family, the classic ragecage."
	max_players = 4
	automatic_gameend_time = 4 MINUTES // its a 10x10 cage what are you guys doing in there
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	map_name = "ragecage"
	key = "ragecage"

/datum/lazy_template/deathmatch/maintenance
	name = "Maint Mania"
	desc = "Dark maintenance tunnels, floor pills, improvised weaponry and a bloody beatdown. Welcome to assistant utopia."
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	map_name = "maint_mania"
	key = "maint_mania"

/datum/lazy_template/deathmatch/osha_violator
	name = "OSHA Violator"
	desc = "What would Engineering be without an overly complicated engine, with conveyor belts, emitters and shield generators sprinkled about? That's right, not Engineering."
	max_players = 10
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	map_name = "OSHA_violator"
	key = "OSHA_violator"

/datum/lazy_template/deathmatch/the_brig
	name = "The Brig"
	desc = "A recreation of MetaStation Brig."
	max_players = 12
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant)
	map_name = "meta_brig"
	key = "meta_brig"

/datum/lazy_template/deathmatch/shooting_range
	name = "Shooting Range"
	desc = "A simple room with a bunch of wooden barricades."
	max_players = 6
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative/ranged,
		/datum/outfit/deathmatch_loadout/operative/melee,
	)
	map_name = "shooting_range"
	key = "shooting_range"

/datum/lazy_template/deathmatch/securing
	name = "SecuRing"
	desc = "Presenting the Security Ring, ever wanted to shoot people with disablers? Well now you can."
	max_players = 4
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/securing_sec)
	map_name = "secu_ring"
	key = "secu_ring"

/datum/lazy_template/deathmatch/instagib
	name = "Instagib"
	desc = "EVERYONE GETS AN INSTAKILL RIFLE!"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/assistant/instagib)
	map_name = "instagib"
	key = "instagib"

/datum/lazy_template/deathmatch/mech_madness
	name = "Mech Madness"
	desc = "Do you hate mechs? Yeah? Dont care! Go fight eachother!"
	max_players = 4
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/operative)
	map_name = "mech_madness"
	key = "mech_madness"

/datum/lazy_template/deathmatch/sniper_elite
	name = "Sniper Elite"
	desc = "Sound of gunfire and screaming people make my day"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/operative/sniper)
	map_name = "sniper_elite"
	key = "sniper_elite"

/datum/lazy_template/deathmatch/meatower
	name = "Meat Tower"
	desc = "There can only be one chef in this kitchen"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/chef)
	map_name = "meat_tower"
	key = "meat_tower"

/datum/lazy_template/deathmatch/sunrise
	name = "Sunrise"
	desc = "DEHUMANIZE YOURSELF AND FACE TO BLOODSHED DEHUMANIZE YOURSELF AND FACE TO BLOODSHED DEHUMANIZE YOURSELF AND FACE TO BLOODSHED DEHUMANIZE YOURSELF AND FACE TO BLOODSHED"
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/samurai)
	map_name = "sunrise"
	key = "sunrise"

/datum/lazy_template/deathmatch/starwars
	name = "Arena Station"
	desc = "Choose your battler!"
	max_players = 10
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/battler/soldier, // First because its a good and easy loadout and is picked by default
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
		/datum/outfit/deathmatch_loadout/battler/surgeon,
		/datum/outfit/deathmatch_loadout/battler/tgcoder,
		/datum/outfit/deathmatch_loadout/naked,
	)
	map_name = "arena_station"
	key = "arena_station"

/datum/lazy_template/deathmatch/underground_thunderdome
	name = "Underground Thunderdome"
	desc = "An illegal underground thunderdome, for larger amounts of murder."
	max_players = 15
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/operative,
		/datum/outfit/deathmatch_loadout/naked,
	)
	map_name = "underground_arena"
	key = "underground_arena"

/datum/lazy_template/deathmatch/backalley
	name = "Backalley"
	desc = "You are not built for these streets."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/assistant,
		/datum/outfit/deathmatch_loadout/naked,
	)
	map_name = "backalley"
	key = "backalley"

/datum/lazy_template/deathmatch/raginmages
	name = "Ragin' Mages"
	desc = "Greetings! We're the wizards of the wizard federation!"
	max_players = 8
	automatic_gameend_time = 4 MINUTES // ill be surprised if this lasts more than two minutes
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/wizard,
		/datum/outfit/deathmatch_loadout/wizard/pyro,
		/datum/outfit/deathmatch_loadout/wizard/electro,
		/datum/outfit/deathmatch_loadout/wizard/necromancer,
		/datum/outfit/deathmatch_loadout/wizard/larp,
		/datum/outfit/deathmatch_loadout/wizard/chuuni,
		/datum/outfit/deathmatch_loadout/wizard/battle,
		/datum/outfit/deathmatch_loadout/wizard/apprentice,
		/datum/outfit/deathmatch_loadout/wizard/gunmancer,
		/datum/outfit/deathmatch_loadout/wizard/monkey,
		/datum/outfit/deathmatch_loadout/wizard/chaos,
		/datum/outfit/deathmatch_loadout/wizard/clown,
	)
	map_name = "ragin_mages"
	key = "ragin_mages"

/datum/lazy_template/deathmatch/train
	name = "Trainship Hijack"
	desc = "Trouble stirs in Tizira..."
	max_players = 8
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/battler/cowboy)
	map_name = "train"
	key = "train"
	turf_reservation_type = /datum/turf_reservation/indestructible_plating

/datum/lazy_template/deathmatch/finaldestination
	name = "Final Destination"
	desc = "1v1v1v1, 1 Stock, Final Destination."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/captain,
		/datum/outfit/deathmatch_loadout/head_of_security,
		/datum/outfit/deathmatch_loadout/traitor,
		/datum/outfit/deathmatch_loadout/nukie,
		/datum/outfit/deathmatch_loadout/tider,
		/datum/outfit/deathmatch_loadout/abductor,
		/datum/outfit/deathmatch_loadout/chef/upgraded,
		/datum/outfit/deathmatch_loadout/battler/clown/upgraded,
		/datum/outfit/deathmatch_loadout/mime,
		/datum/outfit/deathmatch_loadout/pete,
	)
	map_name = "finaldestination"
	key = "finaldestination"

/datum/lazy_template/deathmatch/species_warfare
	name = "Species Warfare"
	desc = "Choose your favorite species and prove its superiority against all the other, lamer species. And also anyone else of your own."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/humanity,
		/datum/outfit/deathmatch_loadout/lizardkind,
		/datum/outfit/deathmatch_loadout/mothman,
		/datum/outfit/deathmatch_loadout/ethereal,
		/datum/outfit/deathmatch_loadout/plasmamen,
		/datum/outfit/deathmatch_loadout/felinid,
	)
	map_name = "species_warfare"
	key = "species_warfare"

/datum/lazy_template/deathmatch/lattice_battles
	name = "Lattice Battles"
	desc = "Tired of fisticuffs all the time? Just snip the catwalk underneath instead!"
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/lattice_battles,
	)
	map_name = "lattice_battles"
	key = "lattice_battles"

/datum/lazy_template/deathmatch/ragnarok
	name = "Ragnarok"
	desc = "Cultists, heretics, and chaplains all duking it out in the jungle to retrieve the McGuffin."
	max_players = 8
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/cultish/invoker,
		/datum/outfit/deathmatch_loadout/cultish/artificer,
		/datum/outfit/deathmatch_loadout/heresy/warrior,
		/datum/outfit/deathmatch_loadout/heresy/scribe,
		/datum/outfit/deathmatch_loadout/holy_crusader,
		/datum/outfit/deathmatch_loadout/clock_cult,
	)
	map_name = "ragnarok"
	key = "ragnarok"

/datum/turf_reservation/indestructible_plating
	turf_type = /turf/open/indestructible/plating //a little hacky but i guess it has to be done
