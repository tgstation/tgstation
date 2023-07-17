/obj/structure/weightmachine
	name = "chest press machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fluff/gym_equipment.dmi'
	icon_state = "stacklifter"
	base_icon_state = "stacklifter"
	can_buckle = TRUE
	density = TRUE
	anchored = TRUE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	///How much we shift the user's pixel y when using the weight machine.
	var/pixel_shift_y = -3

	///The weight action we give to people that buckle themselves to us.
	var/datum/action/push_weights/weight_action

	///List of messages picked when using the machine.
	var/static/list/more_weight = list(
		"pushing it to the limit!",
		"going into overdrive!",
		"burning with determination!",
		"rising up to the challenge!",
		"getting strong now!",
		"getting ripped!",
	)
	///List of messages picked when finished using the machine.
	var/static/list/finished_message = list(
		"You feel stronger!",
		"You feel like you can take on the world!",
		"You feel robust!",
		"You feel indestructible!",
	)

/obj/structure/weightmachine/Initialize(mapload)
	. = ..()

	weight_action = new(src)
	weight_action.weightpress = src

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		lmb_text = "Work out", \
	)

	var/static/list/tool_behaviors = list(
		TOOL_CROWBAR = list(
			SCREENTIP_CONTEXT_RMB = "Deconstruct",
		),

		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_RMB = "Anchor",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/structure/weightmachine/Destroy()
	QDEL_NULL(weight_action)
	return ..()

/obj/structure/weightmachine/buckle_mob(mob/living/buckled, force, check_loc)
	. = ..()
	weight_action.Grant(buckled)

/obj/structure/weightmachine/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	. = ..()
	weight_action.Remove(buckled_mob)

/obj/structure/weightmachine/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	balloon_alert(user, anchored ? "unsecured" : "secured")
	anchored = !anchored
	return TRUE

/obj/structure/weightmachine/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "still secured!")
		return FALSE
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if (!do_after(user, 10 SECONDS, target = src))
		return FALSE
	new /obj/item/stack/sheet/iron(get_turf(src), 5)
	new /obj/item/stack/rods(get_turf(src), 2)
	new /obj/item/chair(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/weightmachine/proc/perform_workout(mob/living/user)
	user.balloon_alert_to_viewers("[pick(more_weight)]")
	START_PROCESSING(SSobj, src)
	if(do_after(user, 8 SECONDS, src) && user.has_gravity())
		user.Stun(2 SECONDS)
		user.balloon_alert(user, pick(finished_message))
		user.add_mood_event("exercise", /datum/mood_event/exercise)
		user.apply_status_effect(/datum/status_effect/exercised)
	end_workout()

/obj/structure/weightmachine/proc/end_workout()
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)
	STOP_PROCESSING(SSobj, src)
	icon_state = initial(icon_state)

/obj/structure/weightmachine/process(seconds_per_tick)
	if(!has_buckled_mobs())
		end_workout()
		return FALSE
	var/image/workout_icon = new(icon, src, "[base_icon_state]-o", ABOVE_MOB_LAYER)
	workout_icon.plane = GAME_PLANE_UPPER
	flick_overlay_view(workout_icon, 8)
	flick("[base_icon_state]-u", src)
	var/mob/living/user = buckled_mobs[1]
	animate(user, pixel_y = pixel_shift_y, time = 4)
	playsound(user, 'sound/machines/creak.ogg', 60, TRUE)
	animate(pixel_y = user.base_pixel_y, time = 4)
	return TRUE

/**
 * Weight lifter subtype
 */
/obj/structure/weightmachine/weightlifter
	name = "inline bench press"
	icon_state = "benchpress"
	base_icon_state = "benchpress"

	pixel_shift_y = 5

