/datum/component/footstep
	var/steps = 0
	var/volume
	var/e_range
	///This is only a callback because I'm too lazy to do this properly. Used to play the correct sounds for the correct typed.
	var/datum/callback/footstep_callback

/datum/component/footstep/Initialize(volume_ = 0.5, e_range_ = -1)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_footstep)
	var/sound_proc
	if(isbarefoot(parent))
		sound_proc = .proc/play_barefoot
	else if(isclawfoot(parent))
		if(isalienadult(parent))
			volume *= 0.5
			e_range -= 5
		sound_proc = .proc/play_clawfoot
	else if(isheavyfoot(parent))
		if(istype(parent, /mob/living/simple_animal/hostile/asteroid/goliath))
			volume *= 0.5
		sound_proc = .proc/play_heavyfoot
	else if(isslime(parent))
		sound_proc = .proc/play_slimefoot
	else if(isshoefoot(parent))
		sound_proc = .proc/play_shoefoot
	else if(ishuman(parent))
		sound_proc = .proc/play_humanfoot
	footstep_callback = CALLBACK(src, sound_proc)

/datum/component/footstep/Destroy()
	QDEL_NULL(footstep_callback)
	return ..()

/datum/component/footstep/proc/play_footstep()
	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return

	var/mob/living/LM = parent
	var/v = volume
	var/e = e_range
	if(!T.footstep || LM.buckled || LM.lying || !CHECK_MULTIPLE_BITFIELDS(LM.mobility_flags, MOBILITY_STAND | MOBILITY_MOVE) || LM.throwing || LM.movement_type & (VENTCRAWLING | FLYING))
		if (LM.lying && !LM.buckled && !(!T.footstep || LM.movement_type & (VENTCRAWLING | FLYING))) //play crawling sound if we're lying
			playsound(T, 'sound/effects/footstep/crawl1.ogg', 15 * v)
		return

	if(iscarbon(LM))
		var/mob/living/carbon/C = LM
		if(!C.get_bodypart(BODY_ZONE_L_LEG) && !C.get_bodypart(BODY_ZONE_R_LEG))
			return
		if(ishuman(C) && C.m_intent == MOVE_INTENT_WALK)
			return // stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return

	if(!LM.has_gravity(T) && steps != 0) // don't need to step as often when you hop around
		return

	footstep_callback.Invoke(T, v, e)

//begin playsound shenanigans//

///for barefooted non-clawed mobs like monkeys
/datum/component/footstep/proc/play_barefoot(turf/open/T, v, e)
	playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
		GLOB.barefootstep[T.barefootstep][2] * v,
		TRUE,
		GLOB.barefootstep[T.barefootstep][3] + e)

///for xenomorphs, dogs, and other clawed mobs
/datum/component/footstep/proc/play_clawfoot(turf/open/T, v, e)
	playsound(T, pick(GLOB.clawfootstep[T.clawfootstep][1]),
			GLOB.clawfootstep[T.clawfootstep][2] * v,
			TRUE,
			GLOB.clawfootstep[T.clawfootstep][3] + e)

///for stuff like megafauna
/datum/component/footstep/proc/play_heavyfoot(turf/open/T, v, e)
	playsound(T, pick(GLOB.heavyfootstep[T.heavyfootstep][1]),
			GLOB.heavyfootstep[T.heavyfootstep][2] * v,
			TRUE,
			GLOB.heavyfootstep[T.heavyfootstep][3] + e)

///for slimes
/datum/component/footstep/proc/play_slimefoot(turf/open/T, v, e)
	playsound(T, 'sound/effects/footstep/slime1.ogg', 15 * v)

///for (simple) humanoid mobs (clowns, russians, pirates, etc.)
/datum/component/footstep/proc/play_shoefoot(turf/open/T, v, e)
		playsound(T, pick(GLOB.footstep[T.footstep][1]),
			GLOB.footstep[T.footstep][2] * v,
			TRUE,
			GLOB.footstep[T.footstep][3] + e)

///for mob/living/carbon/human's
/datum/component/footstep/proc/play_humanfoot(turf/open/T, v, e)
	var/mob/living/carbon/human/H = parent
	var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

	if(H.shoes || feetCover) //are we wearing shoes
		playsound(T, pick(GLOB.footstep[T.footstep][1]),
			GLOB.footstep[T.footstep][2] * v,
			TRUE,
			GLOB.footstep[T.footstep][3] + e)

	if((!H.shoes && !feetCover)) //are we NOT wearing shoes
		if(H.dna.species.special_step_sounds)
			playsound(T, pick(H.dna.species.special_step_sounds), 50, TRUE)
		else
			playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
				GLOB.barefootstep[T.barefootstep][2] * v,
				TRUE,
				GLOB.barefootstep[T.barefootstep][3] + e)
