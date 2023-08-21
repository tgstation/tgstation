/// Greed's slot machine: Used in the Greed ruin. Deals damage on each use, with a successful use giving a d20 of fate.
/obj/structure/cursed_slot_machine
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "slots"
	anchored = TRUE
	density = TRUE
	/// Variable that tracks the screen we display.
	var/icon_screen = "slots_screen"
	/// Should we be emitting light?
	var/brightness_on = TRUE
	/// The probability the player has to win.
	var/win_prob = 5
	/// clone damaged dealt each roll
	var/damage_on_roll = 20
	/// machine's reward when you hit jackpot
	var/prize = /obj/structure/cursed_money

/obj/structure/cursed_slot_machine/Initialize(mapload)
	. = ..()
	update_appearance()
	set_light(brightness_on)

/obj/structure/cursed_slot_machine/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(obj_flags & IN_USE)
		return
	obj_flags |= IN_USE
	user.adjustCloneLoss(damage_on_roll)

	if(user.stat != CONSCIOUS)
		to_chat(user, span_userdanger("No... just one more try..."))
		user.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		user.gib()
		return

	user.visible_message(
		span_warning("[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!"),
		span_warning("You feel a draining as you pull the lever, but you know it'll be worth it."),
	)

	icon_screen = "slots_screen_working"
	update_appearance()
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 5 SECONDS)

/obj/structure/cursed_slot_machine/update_overlays()
	. = ..()
	var/overlay_state = icon_screen
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state, src)

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/user)
	icon_screen = initial(icon_screen)
	update_appearance()
	obj_flags &= ~IN_USE
	if(!prob(win_prob))
		if(user)
			to_chat(user, span_boldwarning("Fucking machine! Must be rigged. Still... one more try couldn't hurt, right?"))
		return

	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, FALSE)
	new prize(get_turf(src))
	if(user)
		to_chat(user, span_boldwarning("You've hit jackpot. Laughter echoes around you as your reward appears in the machine's place."))

	qdel(src)


/// Prize given out by the cursed slot machine that will give the user one Die of Fate and then delete itself.
/obj/structure/cursed_money
	name = "bag of money"
	desc = "RICH! YES! YOU KNEW IT WAS WORTH IT! YOU'RE RICH! RICH! RICH!"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "moneybag"
	anchored = FALSE
	density = TRUE

/obj/structure/cursed_money/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(collapse)), 1 MINUTES)

/obj/structure/cursed_money/proc/collapse()
	if(QDELETED(src))
		return
	visible_message(span_warning("[src] falls in on itself, with the canvas rotting away and contents vanishing."))
	qdel(src)

/obj/structure/cursed_money/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.visible_message(
		span_warning("[user] opens the bag and removes a die."),
		span_warning("[span_boldwarning("You open the bag...!")] But all you see is a bag full of dice. Confused, you take one..."),
	)
	var/turf/location = get_turf(user)
	var/obj/item/dice/d20/fate/one_use/critical_fail = new(location)
	user.put_in_hands(critical_fail)
	collapse()
