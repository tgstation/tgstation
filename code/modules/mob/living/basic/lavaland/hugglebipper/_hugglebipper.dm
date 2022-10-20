/mob/living/basic/mining/hugglebipper
	name = "hugglebipper"
	desc = "Elusive creatures, little known about them. They seem friendly, but only get in the way of day to day operations."
	icon = 'icons/mob/simple/lavaland/hugglebipper.dmi'
	icon_state = "hugglebipper"
	icon_living = "hugglebipper"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	basic_mob_flags = DEL_ON_DEATH
	//we should not give players this power normally, they can teleport on attack
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 60
	health = 60
	verb_say = "bips"
	verb_ask = "buggles"
	verb_exclaim = "blips"
	verb_yell = "bugglebips"
	death_message = "lets out a pathetic screech as it dies..."
	pixel_x = -16
	base_pixel_x = -16

	buckle_lying = 90
	speed = 0.5

	ai_controller = /datum/ai_controller/basic_controller/hugglebipper

/mob/living/basic/mining/hugglebipper/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/waddling)
	var/drop_immediately = TRUE //clarifying this boolean
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/hugglebipper_eye, 100, drop_immediately)

/mob/living/basic/mining/hugglebipper/melee_attack(atom/target)
	if(!isliving(target))
		return ..()

	if(has_buckled_mobs())
		balloon_alert(src, "setting down")
		unbuckle_all_mobs()
		//just reset (goes back to stalking)
		ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
		return

	face_atom(target)

	var/result = buckle_mob(target, TRUE)

	//find where to run off to, regardless of whether we successfully grabbed our target
	var/turf/planned_dropoff
	var/list/turf/rim_turfs = shuffle(RIM_TURFS(10, 11, target))
	for(var/turf/open/possible_dropoff in rim_turfs)
		if(isgroundlessturf(possible_dropoff))
			continue
		get_path_to()

		//barebones solution
		var/invalid = FALSE
		for(var/turf/surrounding_dropoff_turf in range(5, possible_dropoff))
			if(locate(/mob/living/basic/mining) in surrounding_dropoff_turf)
				invalid = TRUE
				break
			if(locate(/mob/living/simple_animal/hostile) in surrounding_dropoff_turf)
				invalid = TRUE
				break
		if(invalid)
			continue
		/// there needs to be a check here to see if we can reach this turf before trying to go there
		planned_dropoff = possible_dropoff
		break
	if(planned_dropoff)
		ai_controller?.blackboard[BB_HUGGLEBIPPER_DROPOFF] = WEAKREF(planned_dropoff)

	//we no longer care who we are targetting so we really just want to go to dropoff
	//if we haven't picked anyone up? we're STILL going to dropoff
	ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
	balloon_alert(src, "[result ? "grabbed" : "can't grab!"]")
