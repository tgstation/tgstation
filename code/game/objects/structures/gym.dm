/obj/structure/punching_bag
	name = "punching bag"
	desc = "A punching bag. Can you get to speed level 4???"
	icon = 'icons/obj/gym_equipment.dmi'
	icon_state = "punchingbag"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	plane = GAME_PLANE_UPPER
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

/obj/structure/punching_bag/Initialize(mapload)
	. = ..()

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		lmb_text = "Punch", \
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

/obj/structure/punching_bag/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	flick("[icon_state]-punch", src)
	playsound(loc, pick(hit_sounds), 25, TRUE, -1)
	if(isliving(user))
		var/mob/living/L = user
		L.add_mood_event("exercise", /datum/mood_event/exercise)
		L.apply_status_effect(/datum/status_effect/exercised)

/obj/structure/punching_bag/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	if(anchored)
		balloon_alert(user, "unsecured")
		anchored = FALSE
	else
		balloon_alert(user, "secured")
		anchored = TRUE
	return TRUE

/obj/structure/punching_bag/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "unsecure first!")
		return FALSE
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if (!do_after(user, 10 SECONDS, target = src))
		return FALSE
	new /obj/item/stack/sheet/iron(get_turf(src))
	new /obj/item/stack/sheet/iron(get_turf(src))
	new /obj/item/stack/rods(get_turf(src))
	new /obj/item/pillow(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/weightmachine
	desc = "Just looking at this thing makes you feel tired."
	density = TRUE
	anchored = TRUE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	icon = 'icons/obj/gym_equipment.dmi'

/obj/structure/weightmachine/Initialize(mapload)
	. = ..()

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

/obj/structure/weightmachine/proc/AnimateMachine(mob/living/user)
	return

/obj/structure/weightmachine/update_icon_state()
	. = ..()
	icon_state = (obj_flags & IN_USE) ? "[base_icon_state]-u" : base_icon_state

/obj/structure/weightmachine/update_overlays()
	. = ..()

	if(obj_flags & IN_USE)
		. += mutable_appearance(icon, "[base_icon_state]-o", offset_spokesman = src, plane = GAME_PLANE_UPPER, layer = ABOVE_MOB_LAYER, alpha = src.alpha)

/obj/structure/weightmachine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if(obj_flags & IN_USE)
		balloon_alert(user, "wait your turn!")
		return
	else
		obj_flags |= IN_USE
		update_appearance()
		user.setDir(SOUTH)
		user.Stun(80)
		user.forceMove(src.loc)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		AnimateMachine(user)

		playsound(user, 'sound/machines/click.ogg', 60, TRUE)
		obj_flags &= ~IN_USE
		update_appearance()
		user.pixel_y = user.base_pixel_y
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		user.add_mood_event("exercise", /datum/mood_event/exercise)
		to_chat(user, finishmessage)
		user.apply_status_effect(/datum/status_effect/exercised)

/obj/structure/weightmachine/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	if(anchored)
		balloon_alert(user, "unsecured")
		anchored = FALSE
	else
		balloon_alert(user, "secured")
		anchored = TRUE
	return TRUE

/obj/structure/weightmachine/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "unsecure first!")
		return FALSE
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if (!do_after(user, 10 SECONDS, target = src))
		return FALSE
	new /obj/item/stack/sheet/iron/five(get_turf(src))
	new /obj/item/stack/rods(get_turf(src))
	new /obj/item/stack/rods(get_turf(src))
	new /obj/item/chair(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/weightmachine/stacklifter
	name = "chest press machine"
	icon_state = "stacklifter"
	base_icon_state = "stacklifter"

/obj/structure/weightmachine/stacklifter/AnimateMachine(mob/living/user)
	var/lifts = 0
	while (lifts++ < 6)
		if (user.loc != src.loc)
			break
		sleep(0.3 SECONDS)
		animate(user, pixel_y = -2, time = 3)
		sleep(0.3 SECONDS)
		animate(user, pixel_y = -4, time = 3)
		sleep(0.2 SECONDS)
		playsound(user, 'sound/machines/creak.ogg', 60, TRUE)

/obj/structure/weightmachine/weightlifter
	name = "inline bench press"
	icon_state = "benchpress"
	base_icon_state = "benchpress"

/obj/structure/weightmachine/weightlifter/AnimateMachine(mob/living/user)
	var/reps = 0
	user.pixel_y = 5
	while (reps++ < 6)
		if (user.loc != src.loc)
			break
		for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
			sleep(0.4 SECONDS)
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)
		playsound(user, 'sound/machines/creak.ogg', 60, TRUE)
	sleep(0.3 SECONDS)
	animate(user, pixel_y = 2, time = 3)
	sleep(0.3 SECONDS)
