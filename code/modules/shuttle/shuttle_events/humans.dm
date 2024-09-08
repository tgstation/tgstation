/datum/shuttle_event/simple_spawner/player_controlled/human
	var/datum/outfit/outfit = /datum/outfit/job/assistant

/datum/shuttle_event/simple_spawner/player_controlled/human/post_spawn(atom/movable/spawnee)
	..()

	if(ishuman(spawnee))
		prepare_human(spawnee)

/datum/shuttle_event/simple_spawner/player_controlled/human/prepare_human(mob/living/carbon/human/human)
	human.equipOutfit(new outfit ())

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide
	name = "Greytide!"
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

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide/interns
	name = "Intern Wave"
	event_probability = 0
	outfit = /datum/outfit/centcom/centcom_intern/unarmed

	spawn_anyway_if_no_player = TRUE
	ghost_alert_string = "Would you like to be a centcom intern shot at the shuttle?"

/datum/shuttle_event/simple_spawner/player_controlled/human/greytide/interns/activate()
	..()

	minor_announce("We're sending you our bravest interns, please let them in when they arrive.",
		title = "Emergency Shuttle", alert = TRUE)


/datum/outfit/job/assistant/breath_mask
	name = "Assistant - Breathmask"
	mask = /obj/item/clothing/mask/breath
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/shuttle_event/simple_spawner/player_controlled/human/hitchhiker
	name = "Hitchhiker!"
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
