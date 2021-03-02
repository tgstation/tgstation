///Footstep component. Plays footsteps at parents location when it is appropriate.
/datum/component/footstep
	///How many steps the parent has taken since the last time a footstep was played.
	var/steps = 0
	///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
	var/volume
	///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't a base value.
	var/e_range
	///footstep_type is a define which determines what kind of sounds should get chosen.
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds
	///Whether or not to add variation to the sounds played
	var/sound_vary = FALSE

/datum/component/footstep/Initialize(footstep_type_ = FOOTSTEP_MOB_BAREFOOT, volume_ = 0.5, e_range_ = -8, vary)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	footstep_type = footstep_type_
	sound_vary = vary
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(parent))
				return COMPONENT_INCOMPATIBLE
			RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_humanstep)
			return
		if(FOOTSTEP_MOB_CLAW)
			footstep_sounds = GLOB.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = GLOB.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			footstep_sounds = GLOB.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = GLOB.footstep
		if(FOOTSTEP_MOB_SLIME)
			footstep_sounds = 'sound/effects/footstep/slime1.ogg'
		if(FOOTSTEP_OBJ_MACHINE)
			footstep_sounds = 'sound/effects/bang.ogg'
			RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_simplestep_machine) //Note that this doesn't get called for humans.
			return
		if(FOOTSTEP_OBJ_ROBOT)
			footstep_sounds = 'sound/effects/tank_treads.ogg'
			RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_simplestep_machine) //Note that this doesn't get called for humans.
			return
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_simplestep) //Note that this doesn't get called for humans.

///Prepares a footstep. Determines if it should get played. Returns the turf it should get played on. Note that it is always a /turf/open
/datum/component/footstep/proc/prepare_step()
	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return

	var/mob/living/LM = parent

	if(!T.footstep || LM.buckled || LM.throwing || LM.movement_type & (VENTCRAWLING | FLYING) || HAS_TRAIT(LM, TRAIT_IMMOBILIZED))
		return

	if(LM.body_position == LYING_DOWN) //play crawling sound if we're lying
		playsound(T, 'sound/effects/footstep/crawl1.ogg', 15 * volume, falloff_distance = 1, vary = sound_vary)
		return

	if(iscarbon(LM))
		var/mob/living/carbon/C = LM
		if(!C.get_bodypart(BODY_ZONE_L_LEG) && !C.get_bodypart(BODY_ZONE_R_LEG))
			return
		if(C.m_intent == MOVE_INTENT_WALK)
			return// stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return

	if(steps != 0 && !LM.has_gravity(T)) // don't need to step as often when you hop around
		return
	return T

/datum/component/footstep/proc/play_simplestep()
	SIGNAL_HANDLER

	var/turf/open/T = prepare_step()
	if(!T)
		return
	if(isfile(footstep_sounds) || istext(footstep_sounds))
		playsound(T, footstep_sounds, volume, falloff_distance = 1, vary = sound_vary)
		return
	var/turf_footstep
	switch(footstep_type)
		if(FOOTSTEP_MOB_CLAW)
			turf_footstep = T.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			turf_footstep = T.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			turf_footstep = T.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			turf_footstep = T.footstep
	if(!turf_footstep)
		return
	playsound(T, pick(footstep_sounds[turf_footstep][1]), footstep_sounds[turf_footstep][2] * volume, TRUE, footstep_sounds[turf_footstep][3] + e_range, falloff_distance = 1, vary = sound_vary)

/datum/component/footstep/proc/play_humanstep()
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS))
		return
	var/turf/open/T = prepare_step()
	if(!T)
		return
	var/mob/living/carbon/human/H = parent

	if ((H.wear_suit?.body_parts_covered | H.w_uniform?.body_parts_covered | H.shoes?.body_parts_covered) & FEET)
		// we are wearing shoes
		playsound(T, pick(GLOB.footstep[T.footstep][1]),
			GLOB.footstep[T.footstep][2] * volume,
			TRUE,
			GLOB.footstep[T.footstep][3] + e_range, falloff_distance = 1, vary = sound_vary)
	else
		if(H.dna.species.special_step_sounds)
			playsound(T, pick(H.dna.species.special_step_sounds), 50, TRUE, falloff_distance = 1, vary = sound_vary)
		else
			playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
				GLOB.barefootstep[T.barefootstep][2] * volume,
				TRUE,
				GLOB.barefootstep[T.barefootstep][3] + e_range, falloff_distance = 1, vary = sound_vary)


///Prepares a footstep for machine walking
/datum/component/footstep/proc/play_simplestep_machine()
	SIGNAL_HANDLER

	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return
	playsound(T, footstep_sounds, 50, falloff_distance = 1, vary = sound_vary)
