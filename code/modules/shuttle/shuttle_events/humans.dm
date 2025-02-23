/// Human spawning events, with the ability to give them outfits!
/datum/shuttle_event/simple_spawner/player_controlled/human
	/// Outfits equipped to human mobs we send to the shuttle
	var/datum/outfit/outfit = /datum/outfit/job/assistant

/datum/shuttle_event/simple_spawner/player_controlled/human/post_spawn(atom/movable/spawnee)
	..()

	if(ishuman(spawnee))
		prepare_human(spawnee)

/datum/shuttle_event/simple_spawner/player_controlled/human/proc/prepare_human(mob/living/carbon/human/human)
	human.equipOutfit(new outfit ())

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide
	name = "Greytide! (10 assistants)"
	spawning_list = list(/mob/living/carbon/human = 10)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	outfit = /datum/outfit/job/assistant/breath_mask

	event_probability = 0.1
	spawn_probability_per_process = 5
	activation_fraction = 0.05
	spawns_per_spawn = 10

	spawn_anyway_if_no_player = TRUE
	ghost_alert_string = "Would you like to be an assistant shot at the shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_HERMIT

/datum/outfit/job/assistant/breath_mask
	name = "Assistant - Breathmask"
	mask = /obj/item/clothing/mask/breath
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = ITEM_SLOT_LPOCKET

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide/interns
	name = "Intern Wave (Unarmed, 10 interns)"
	event_probability = 0
	outfit = /datum/outfit/centcom/centcom_intern/unarmed

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be a centcom intern shot at the shuttle?"

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide/interns/activate()
	..()

	minor_announce("We're sending you our bravest interns, please let them in when they arrive.",
		title = "Emergency Shuttle", alert = TRUE)

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide/interns/armed
	name = "Intern Wave (Armed, 10 interns)"
	event_probability = 0
	outfit = /datum/outfit/centcom/centcom_intern

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be a centcom intern shot at the shuttle?"

/datum/shuttle_event/simple_spawner/player_controlled/human/hitchhiker
	name = "Hitchhiker! (Harmless, single ghost spawn)"
	spawning_list = list(/mob/living/carbon/human = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	outfit = /datum/outfit/job/assistant/hitchhiker

	event_probability = 1
	spawn_probability_per_process = 5
	activation_fraction = 0.2

	spawn_anyway_if_no_player = TRUE
	ghost_alert_string = "Would you like to be an assistant shot at the shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_HERMIT

/datum/outfit/job/assistant/hitchhiker
	name = "Assistant - Hitchhiker"
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/eva
	head = /obj/item/clothing/head/helmet/space/eva
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_hand = /obj/item/storage/briefcase/hitchiker
	internals_slot = ITEM_SLOT_LPOCKET

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
