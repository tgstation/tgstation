/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "oceanwater_motion"
	baseturfs = /turf/open/water
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	slowdown = 10
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/water/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)

turf/open/water/Enter(mob/A)
	if(istype(A,/mob/living))
		var/mob/living/L = A
		if(!L.buckled)
			if(istype(L, /mob/living/simple_animal) || istype(L, /mob/living/carbon/monkey))
				return
			else
				return ..()
		else
			return ..()
	else
		return ..()

/turf/open/water/Entered(atom/movable/A)
	. = ..()
	if(istype(A,/obj/effect/decal/cleanable))
		sleep(1)
		del(A) //wash the blood away.
	if(istype(A,/mob/living))
		var/mob/living/L = A
		if(!L.buckled)
			SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
			L.wash_cream()
			L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			if(iscarbon(L))
				var/mob/living/carbon/M = L
				. = TRUE

				for(var/obj/item/I in M.held_items)
					wash_obj(I)

				if(M.back && wash_obj(M.back))
					M.update_inv_back(0)

				var/list/obscured = M.check_obscured_slots()

				if(M.head && wash_obj(M.head))
					M.update_inv_head()

				if(M.glasses && !(SLOT_GLASSES in obscured) && wash_obj(M.glasses))
					M.update_inv_glasses()

				if(M.wear_mask && !(SLOT_WEAR_MASK in obscured) && wash_obj(M.wear_mask))
					M.update_inv_wear_mask()

				if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
					M.update_inv_ears()

				if(M.wear_neck && !(SLOT_NECK in obscured) && wash_obj(M.wear_neck))
					M.update_inv_neck()

				if(M.shoes && !(HIDESHOES in obscured) && wash_obj(M.shoes))
					M.update_inv_shoes()

				var/washgloves = FALSE
				if(M.gloves && !(HIDEGLOVES in obscured))
					washgloves = TRUE

				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.set_hygiene(HYGIENE_LEVEL_CLEAN)

					if(slowdown == 5)
						SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "swam", /datum/mood_event/swam)
					else
						SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "swam", /datum/mood_event/swam/deep)
						L.adjust_bodytemperature(-rand(16,20))

					if(H.wear_suit && wash_obj(H.wear_suit))
						H.update_inv_wear_suit()
					else if(H.w_uniform && wash_obj(H.w_uniform))
						H.update_inv_w_uniform()

					if(washgloves)
						SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

					if(!H.is_mouth_covered())
						H.lip_style = null
						H.update_body()

					if(H.belt && wash_obj(H.belt))
						H.update_inv_belt()
				else
					SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
					if(slowdown == 5)
						SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "swam", /datum/mood_event/swam)
					else
						SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "swam", /datum/mood_event/swam/deep)
						L.adjust_bodytemperature(-rand(16,20))
			else
				SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

				if(slowdown == 5)
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "swam", /datum/mood_event/swam)
				else
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "swam", /datum/mood_event/swam/deep)
					L.adjust_bodytemperature(-rand(16,20))

/turf/open/water/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/water/acid_act(acidpwr, acid_volume)
	return

/turf/open/water/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/water/singularity_act()
	return

/turf/open/water/singularity_pull(S, current_size)
	return

/turf/open/water/shallow
	slowdown = 5
	desc = "Shallow water."
	icon_state = "riverwater_motion"