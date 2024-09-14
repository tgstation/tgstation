///Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through
/datum/shuttle_event/simple_spawner/black_hole
	name = "Black Hole (Oh no!)"
	event_probability = 0 // only admin spawnable
	spawn_probability_per_process = 10
	activation_fraction = 0.35
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	spawning_list = list(/obj/singularity/shuttle_event = 1)
	// only spawn it once
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

///Kobayashi Maru version
/datum/shuttle_event/simple_spawner/black_hole/adminbus
	name = "Black Holes (OH GOD!)"
	event_probability = 0
	spawn_probability_per_process = 50
	activation_fraction = 0.2
	spawning_list = list(/obj/singularity/shuttle_event = 10)
	remove_from_list_when_spawned = TRUE

/// Spawns some player controlled fire sharks
/datum/shuttle_event/simple_spawner/player_controlled/fire_shark
	name = "Three player controlled fire sharks! (Dangerous!)"
	spawning_list = list(/mob/living/basic/heretic_summon/fire_shark = 3)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE

	event_probability = 0
	activation_fraction = 0.2
	spawn_probability_per_process = 100
	spawns_per_spawn = 3

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be a fire shark attacking the shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_SENTIENCE

///CARPTIDE! CARPTIDE! CARPTIDE! Magical carp will attack the shuttle!
/datum/shuttle_event/simple_spawner/carp/magic
	name = "Magical Carp Nest! (Very Dangerous!)"
	spawning_list = list(/mob/living/basic/carp/magic = 12, /mob/living/basic/carp/magic/chaos = 3)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_MISS_SHUTTLE

	event_probability = 0
	activation_fraction = 0.2
	spawn_probability_per_process = 20

	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

/datum/shuttle_event/simple_spawner/meteor/dust/meaty
	name = "Meaty Meteors! (Mostly Safe)"
	spawning_list = list(/obj/effect/meteor/meaty = 1)
	spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE

	event_probability = 0.1
	activation_fraction = 0.1
	spawn_probability_per_process = 100
	spawns_per_spawn = 3

	hit_the_shuttle_chance = 4

/datum/shuttle_event/simple_spawner/player_controlled/human/nukie
	name = "Nuclear Operative (Dangerous as heck)!"
	spawning_list = list(/mob/living/carbon/human = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	outfit = /datum/outfit/deathmatch_loadout/nukie

	event_probability = 0
	spawn_probability_per_process = 100

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be a nuclear operative to assault the shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_NUCLEAR_OPERATIVE

/datum/outfit/shuttle_nukie
	name = "Shuttle Nuclear Operative"

	uniform = /obj/item/clothing/under/syndicate/tacticool
	back = /obj/item/mod/control/pre_equipped/nuclear
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	belt = /obj/item/gun/ballistic/automatic/pistol/clandestine
	r_pocket = /obj/item/reagent_containers/hypospray/medipen/stimulants
	l_pocket = /obj/item/grenade/syndieminibomb
	implants = list(/obj/item/implant/explosive)
	suit_store = /obj/item/tank/internals/emergency_oxygen

	internals_slot = ITEM_SLOT_SUITSTORE

	backpack_contents = list(
		/obj/item/ammo_box/c10mm,
		/obj/item/ammo_box/magazine/m12g = 2,
		/obj/item/pen/edagger,
		/obj/item/reagent_containers/hypospray/medipen/atropine,
	)

/datum/shuttle_event/simple_spawner/projectile/fireball //bap bap bapaba bap
	name = "Fireball Burst (Very bad!)"
	activation_fraction = 0.5 // this doesn't matter for hijack events but just in case its forced

	spawning_list = list(/obj/projectile/magic/fireball = 10)
	angle_spread = 10
	spawns_per_spawn = 10
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	spawn_probability_per_process = 100

	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE
