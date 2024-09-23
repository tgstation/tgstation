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
	/// The maximum amount of curses we will allow a player to have before disallowing them to use the machine.
	var/max_curse_amount = 5
	/// machine's reward when you hit jackpot
	var/prize = /obj/structure/cursed_money
	/// should we be applying the cursed status effect?
	var/status_effect_on_roll = TRUE
	/// Length of the cooldown between the machine being used and being able to spin the machine again.
	var/cooldown_length = 15 SECONDS
	/// Are we currently in use? Anti-spam prevention measure.
	var/in_use = FALSE
	/// Cooldown between pulls of the cursed slot machine.
	COOLDOWN_DECLARE(spin_cooldown)

/obj/structure/cursed_slot_machine/Initialize(mapload)
	. = ..()
	update_appearance()
	set_light(brightness_on)

/obj/structure/cursed_slot_machine/interact(mob/user)
	if(!ishuman(user))
		return

	if(!check_and_set_usage(user))
		return

	user.visible_message(
		span_warning("[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!"),
		span_warning("You feel a draining as you pull the lever, but you know it'll be worth it."),
	)

	icon_screen = "slots_screen_working"
	update_appearance()
	playsound(src, 'sound/machines/lavaland/cursed_slot_machine.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 5 SECONDS)

/obj/structure/cursed_slot_machine/update_overlays()
	. = ..()
	var/overlay_state = icon_screen
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state, src)

/// Validates that the user can use the cursed slot machine. User is the person using the slot machine. Returns TRUE if we can, FALSE otherwise.
/obj/structure/cursed_slot_machine/proc/check_and_set_usage(mob/living/carbon/human/user)
	if(in_use)
		balloon_alert_to_viewers("already spinning!")
		return FALSE

	var/signal_value = SEND_SIGNAL(user, COMSIG_CURSED_SLOT_MACHINE_USE, max_curse_amount)

	if(!COOLDOWN_FINISHED(src, spin_cooldown) || (signal_value & SLOT_MACHINE_USE_POSTPONE))
		to_chat(user, span_danger("The machine doesn't engage. You get the compulsion to try again in a few seconds."))
		return FALSE

	if(signal_value & SLOT_MACHINE_USE_CANCEL) // failsafe in case we don't want to let the machine be used for some reason (like if we're maxed out on curses but not getting gibbed)
		say("We're sorry, but we can no longer serve you at this establishment.")
		return FALSE

	in_use = TRUE
	return TRUE

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/carbon/human/user)
	icon_screen = initial(icon_screen)
	update_appearance()

	in_use = FALSE
	COOLDOWN_START(src, spin_cooldown, cooldown_length)

	if(!prob(win_prob))
		if(status_effect_on_roll && isnull(user.has_status_effect(/datum/status_effect/grouped/cursed)))
			user.apply_status_effect(/datum/status_effect/grouped/cursed)

		SEND_SIGNAL(user, COMSIG_CURSED_SLOT_MACHINE_LOST)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		balloon_alert_to_viewers("you lost!")
		return

	playsound(src, 'sound/machines/lavaland/cursed_slot_machine_jackpot.ogg', 50, FALSE)
	new prize(get_turf(src))
	if(user)
		to_chat(user, span_boldwarning("You've hit the jackpot!!! Laughter echoes around you as your reward appears in the machine's place."))

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CURSED_SLOT_MACHINE_WON)
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
