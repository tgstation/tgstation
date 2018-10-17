/datum/component/footstep
	var/steps = 0
	var/volume
	var/e_range

/datum/component/footstep/Initialize(volume_ = 0.5, e_range_ = -1)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_footstep)

/datum/component/footstep/proc/play_footstep()
	var/turf/open/T = get_turf(parent)
	if(!istype(T))
		return
	
	var/mob/living/LM = parent
	var/v = volume
	var/e = e_range
	if(!T.footstep || LM.buckled || !CHECK_MULTIPLE_BITFIELDS(LM.mobility_flags, MOBILITY_STAND | MOBILITY_MOVE) || LM.throwing || LM.movement_type & (VENTCRAWLING | FLYING))
		return
	
	if(iscarbon(LM))
		var/mob/living/carbon/C = LM
		if(!C.get_bodypart(BODY_ZONE_L_LEG) && !C.get_bodypart(BODY_ZONE_R_LEG))
			return
		if(ishuman(C) && C.m_intent == MOVE_INTENT_WALK)
			v /= 2
			e -= 5
	steps++
	
	if(steps >= 6)
		steps = 0
	
	if(steps % 2)
		return
	
	if(!LM.has_gravity(T) && steps != 0) // don't need to step as often when you hop around
		return
	
	if(ishuman(LM))
		var/mob/living/carbon/human/H = LM
		var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))
		if(H.shoes || feetCover) //are we wearing shoes?
			playsound(T, pick(GLOB.footstep[T.footstep][1]),
				GLOB.footstep[T.footstep][2] * v,
				TRUE,
				GLOB.footstep[T.footstep][3] + e)
		
		if(!H.shoes && !feetCover) //are we NOT wearing shoes?
			playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
				GLOB.barefootstep[T.barefootstep][2] * v,
				TRUE,
				GLOB.barefootstep[T.barefootstep][3] + e)
