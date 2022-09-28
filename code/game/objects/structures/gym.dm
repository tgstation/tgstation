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

/obj/structure/weightmachine
	desc = "Just looking at this thing makes you feel tired."
	density = TRUE
	anchored = TRUE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	icon = 'icons/obj/gym_equipment.dmi'

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
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(obj_flags & IN_USE)
		to_chat(user, span_warning("It's already in use - wait a bit!"))
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

/obj/structure/weightmachine/stacklifter
	name = "chest press machine"
	icon_state = "stacklifter"
	base_icon_state = "stacklifter"

/obj/structure/weightmachine/stacklifter/AnimateMachine(mob/living/user)
	var/lifts = 0
	while (lifts++ < 6)
		if (user.loc != src.loc)
			break
		sleep(3)
		animate(user, pixel_y = -2, time = 3)
		sleep(3)
		animate(user, pixel_y = -4, time = 3)
		sleep(2)
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
			sleep(4)
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)
		playsound(user, 'sound/machines/creak.ogg', 60, TRUE)
	sleep(3)
	animate(user, pixel_y = 2, time = 3)
	sleep(3)
