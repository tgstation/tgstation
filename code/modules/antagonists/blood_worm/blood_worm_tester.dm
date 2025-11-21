/obj/item/blood_worm_tester
	name = "\improper blood worm testing tool"
	desc = "A DeForest-patented tool for testing whether someone is the host of a blood worm. Testing is allegedly very painful."

	icon = 'icons/obj/antags/blood_worm.dmi'
	icon_state = "tester"

	var/spent = FALSE

/obj/item/blood_worm_tester/update_icon_state()
	. = ..()
	icon_state = spent ? "tester_spent" : "tester"

/obj/item/blood_worm_tester/update_desc(updates)
	. = ..()
	desc = "[initial(desc)] [spent ? "It's spent." : "It's loaded for a single use."]"

/obj/item/blood_worm_tester/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if (spent)
		target_mob.balloon_alert(user, "already spent!")
		return
	if (!ISADVANCEDTOOLUSER(user))
		target_mob.balloon_alert(user, "needs dexterity!")
		return
	if (!ishuman(target_mob))
		target_mob.balloon_alert(user, "target a human!")
		return

	var/target_zone = user.zone_selected

	if (!can_inject(target_mob, user, target_zone))
		return

	user.visible_message(
		message = span_danger("\The [user] start[user.p_s()] trying to jab \the [target_mob] with \the [src]!"),
		self_message = span_danger("You start trying to jab \the [target_mob] with \the [src]."),
		ignored_mobs = target_mob,
	)

	target_mob.show_message(
		msg = span_userdanger("\The [user] start[user.p_s()] trying to jab you with \the [src]!"),
		type = MSG_VISUAL,
	)

	log_combat(user, target_mob, "attempted to test", src)

	if (!do_after(user, 5 SECONDS, target_mob, extra_checks = CALLBACK(src, PROC_REF(can_inject), target_mob, user, target_zone)))
		return

	user.visible_message(
		message = span_danger("\The [user] jab[user.p_s()] \the [target_mob] with \the [src]!"),
		self_message = span_danger("You jab \the [target_mob] with \the [src]!"),
		ignored_mobs = target_mob,
	)

	target_mob.show_message(
		msg = span_userdanger("\The [user] jab[user.p_s()] you with \the [src]!"),
		type = MSG_VISUAL,
	)

	log_combat(user, target_mob, "tested", src)

	playsound(src, 'sound/items/hypospray.ogg', vol = 50, vary = TRUE)

	say("Scanning...")

	target_mob.painful_scream()
	target_mob.apply_damage(rand(20, 30), BRUTE, target_zone, wound_bonus = CANT_WOUND, attack_direction = get_dir(user, target_mob), attacking_item = src)
	target_mob.add_mood_event("tester", /datum/mood_event/jabbed_with_tester)

	addtimer(CALLBACK(src, PROC_REF(report_results), HAS_TRAIT(target_mob, TRAIT_BLOOD_WORM_HOST)), 1 SECONDS)

	spent = TRUE
	update_appearance()

/obj/item/blood_worm_tester/proc/can_inject(mob/living/target_mob, mob/living/user, target_zone)
	return target_mob.try_inject(user, target_zone, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE)

/obj/item/blood_worm_tester/proc/report_results(is_worm)
	if (is_worm)
		say("Blood worm detected!")
		playsound(src, 'sound/machines/beep/twobeep.ogg', vol = 50, vary = TRUE)
	else
		say("No blood worm detected.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', vol = 50, vary = TRUE)
