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
	/// should we be applying the cursed status effect?
	var/status_effect_on_roll = TRUE
	/// Length of the cooldown between the machine being used and being able to spin the machine again. Don't trim this down too hard or the status effect story will fall flat
	var/cooldown_length = 15 SECONDS
	/// Cooldown between pulls of the cursed slot machine.
	COOLDOWN_DECLARE(spin_cooldown)

/obj/structure/cursed_slot_machine/Initialize(mapload)
	. = ..()
	update_appearance()
	set_light(brightness_on)

/obj/structure/cursed_slot_machine/interact(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user

	if(obj_flags & IN_USE || !COOLDOWN_FINISHED(src, spin_cooldown))
		to_chat(human_user, span_danger("The machine doesn't engage. You get the compulsion to try again in a few seconds."))
		return
	obj_flags |= IN_USE

	var/signal_value = SEND_SIGNAL(human_user, COMSIG_CURSED_SLOT_MACHINE_USE)

	if(signal_value & SLOT_MACHINE_USE_CANCEL)
		to_chat(human_user, span_userdanger("Why couldn't I get one more try?!"))
		human_user.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		human_user.gib()
		return

	user.visible_message(
		span_warning("[human_user] pulls [src]'s lever with a glint in [user.p_their()] eyes!"),
		span_warning("You feel a draining as you pull the lever, but you know it'll be worth it."),
	)

	if(status_effect_on_roll && isnull(human_user.has_status_effect(/datum/status_effect/grouped/cursed)))
		human_user.apply_status_effect(/datum/status_effect/grouped/cursed)

	icon_screen = "slots_screen_working"
	update_appearance()
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), human_user), 5 SECONDS)

/obj/structure/cursed_slot_machine/update_overlays()
	. = ..()
	var/overlay_state = icon_screen
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state, src)

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/user)
	icon_screen = initial(icon_screen)
	update_appearance()
	obj_flags &= ~IN_USE
	COOLDOWN_START(src, spin_cooldown, cooldown_length)
	if(!prob(win_prob))
		SEND_SIGNAL(user, COMSIG_CURSED_SLOT_MACHINE_LOST)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		balloon_alert_to_viewers("you lost!")
		return

	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, FALSE)
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
