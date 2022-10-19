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
	pixel_x = -16
	base_pixel_x = -16

	speed = 2

	death_message = "lets out a pathetic screech as it dies..."

	ai_controller = /datum/ai_controller/basic_controller/hugglebipper

/mob/living/basic/mining/hugglebipper/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/waddling)
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/hugglebipper_eye, 100)

/mob/living/basic/mining/hugglebipper/melee_attack(atom/target)
	if(!isliving(target))
		return ..()
	var/mob/living/living_target = target
	src.face_atom(living_target)
	var/list/turf/turf_list = RIM_TURFS(10, 11, living_target)
	var/teleported = FALSE
	for(var/turf/turf as anything in turf_list)
		if(isopenturf(turf) && !isgroundlessturf(turf))
			living_target.forceMove(turf)
			teleported = TRUE
			break
	if(!teleported)
		living_target.forceMove(pick(turf_list))
	if(ai_controller)
		ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
	return TRUE
