/datum/round_event_control/florida_man
	name = "Florida Man"
	typepath = /datum/round_event/ghost_role/florida_man
	weight = 14
	max_occurrences = 3
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event/ghost_role/florida_man
	minimum_required = 1
	role_name = "Florida Man"
	fakeable = FALSE

/datum/round_event/ghost_role/florida_man/proc/equip_floridan(mob/living/carbon/human/H)

	var/i = rand(1,4)
	switch(i)
		if(1)
			return H.equipOutfit(/datum/outfit/florida_man_one)
		if(2)
			return H.equipOutfit(/datum/outfit/florida_man_two)
		if(3)
			return H.equipOutfit(/datum/outfit/florida_man_three)
		if(4)
			return H.equipOutfit(/datum/outfit/florida_man_four)

/datum/round_event/ghost_role/florida_man/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as Florida Man?",
		role = ROLE_FLORIDA_MAN,
		poll_time = 20 SECONDS,
		alert_pic = /datum/antagonist/florida_man,
		role_name_text = "florida man"
	)
	var/turf/spawn_loc = find_safe_turf()//Used for the Drop Pod type of spawn

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)
	var/mob/living/carbon/human/floridan = new(spawn_loc) //This is to catch errors by just giving them a location in general.

	equip_floridan(floridan)

	floridan.dna.update_dna_identity()
	var/datum/mind/Mind = new /datum/mind(selected.key)
	Mind.special_role = "Florida Man"
	Mind.active = 1
	Mind.transfer_to(floridan)
	Mind.add_antag_datum(/datum/antagonist/florida_man)


	var/i = rand(1,4)
	switch(i)
		if(1)
			var/obj/structure/closet/supplypod/car_pod/pod = new()
			pod.stay_after_drop = TRUE
			new /obj/effect/pod_landingzone(spawn_loc, pod)
			floridan.forceMove(pod)
			//Drop Pod Car
		if(2)
			var/obj/structure/closet/supplypod/washer_pod/pod = new()
			pod.stay_after_drop = TRUE
			new /obj/effect/pod_landingzone(spawn_loc, pod)
			floridan.forceMove(pod)
			//Drop Pod Washing Machine
		if(3)
			floridan.forceMove(get_unlocked_closed_locker()) //I KNEW THIS PROC WOULD HAVE MORE USES!
			//Locker/crate spawn
		if(4)
			floridan.Paralyze(10, TRUE, TRUE)
			new /obj/effect/holy(spawn_loc)
			//God has thrown you out of heaven, you know what you did. Don't try to deny your sins against humanity, Florida Man.

	message_admins("[ADMIN_LOOKUPFLW(floridan)] has been made into Florida Man.")
	log_game("[key_name(floridan)] was spawned as Florida Man by an event.")
	spawned_mobs += floridan
	return SUCCESSFUL_SPAWN

/obj/effect/holy
	name = "holy"
	icon = 'monkestation/icons/obj/effects/96x96.dmi'
	icon_state = "beamin"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = 0

/obj/effect/holy/Initialize()
	playsound(src,'monkestation/sound/misc/adminspawn.ogg',50,1)
	QDEL_IN(src, 20)
	. = ..()
	return INITIALIZE_HINT_NORMAL
