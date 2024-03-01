/obj/item/clothing/neck/decapitator
	name = "collar bomb"
	desc = "A tight cumbersome collar of some sort, filled with just enough explosive to rip one's head off... at least that's what it reads on the front tag."
	icon_state = "decapitator"
	icon = 'icons/obj/clothing/neck.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	clothing_traits = list(TRAIT_NODROP)
	var/obj/item/decapitator_button/button
	var/active = FALSE

/obj/item/clothing/neck/decapitator/Initialize(mapload, obj/item/decapitator_button/button)
	. = ..()
	src.button = button
	button?.collar = src

/obj/item/clothing/neck/decapitator/Destroy()
	button.collar = null
	button = null
	return ..()

/obj/item/clothing/neck/decapitator/proc/explosive_countdown(ticks_left)
	playsound(src, 'sound/items/timer.ogg', 30, FALSE)
	if(ticks_left > 0)
		balloon_alert_to_viewers("[ticks_left]")
		ticks_left--
		addtimer(CALLBACK(src, PROC_REF(explosive_countdown), ticks_left), 1 SECONDS)
		return

	playsound(src, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	if(!ishuman(loc))
		balloon_alert_to_viewers("dud...")
		active = FALSE
		return
	var/mob/living/carbon/human/brian = loc
	if(brian.get_item_by_slot(ITEM_SLOT_NECK) != src)
		balloon_alert_to_viewers("dud...")
		active = FALSE
		return
	balloon_alert_to_viewers(UNLINT("BOOM!!"))
	visible_message(span_warning("[src] goes off, outright decapitating [brian]!"), span_hear("You hear a snappy yet fleshy boom!"))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	brian.apply_damage(200, BRUTE, BODY_ZONE_HEAD)
	var/obj/item/bodypart/head/myhead = brian.get_bodypart(BODY_ZONE_HEAD)
	myhead?.dismember()
	brian.investigate_log("has been decapitated by [src].", INVESTIGATE_DEATHS)
	flash_color(brian, flash_color = "#FF0000", flash_time = 1 SECONDS)
	qdel(src)

/obj/item/decapitator_button
	name = "big yellow button"
	desc = "It looks like a big red button, except it's yellow, and with a heavy trigger, also to avoid accidents."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "bigyellow"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/clothing/neck/decapitator/collar

/obj/item/decapitator_button/attack_self(mob/user)
	. = ..()
	balloon_alert_to_viewers("pushing the button...")
	if(!do_after(user, 3 SECONDS, target = src))
		return
	playsound(user, 'sound/machines/click.ogg', 25, TRUE)
	balloon_alert_to_viewers("button pushed")
	if(collar && !collar.active)
		collar.explosive_countdown(5)

/obj/item/decapitator_button/Destroy()
	collar = null
	collar.button = null
	return ..()
