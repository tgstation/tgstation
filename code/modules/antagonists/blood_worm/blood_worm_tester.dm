/obj/item/blood_worm_tester
	name = "hemoparasite testing tool"
	desc = "A proprietary device patented by the DeForest Medical Corporation that is tailor-made for detecting hemoparasites, such as the infamous space-faring blood worm. The testing process is allegedly very painful."

	icon = 'icons/obj/antags/blood_worm.dmi'
	icon_state = "tester"

	inhand_icon_state = "blood_worm_tester"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

	w_class = WEIGHT_CLASS_SMALL

	var/spent = FALSE

/obj/item/blood_worm_tester/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	update_appearance(UPDATE_ICON_STATE | UPDATE_DESC)

/obj/item/blood_worm_tester/update_icon_state()
	icon_state = spent ? "tester_spent" : "tester"
	inhand_icon_state = spent ? "blood_worm_tester_spent" : "blood_worm_tester"
	return ..()

/obj/item/blood_worm_tester/update_desc(updates)
	desc = "[initial(desc)] [spent ? "This one is spent." : "It's loaded for a single use."]"
	return ..()

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
	if (!target_mob.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return

	if (target_mob != user)
		user.visible_message(
			message = span_danger("\The [user] jab[user.p_s()] \the [target_mob] with \the [src]!"),
			self_message = span_danger("You jab \the [target_mob] with \the [src]!"),
			ignored_mobs = target_mob,
		)

		target_mob.show_message(
			msg = span_userdanger("\The [user] jab[user.p_s()] you with \the [src]!"),
			type = MSG_VISUAL,
		)
	else
		user.visible_message(
			message = span_notice("\The [user] jab[user.p_s()] [user.p_themselves()] with \the [src]."),
			self_message = span_notice("You jab yourself with \the [src]."),
		)

	log_combat(user, target_mob, "tested", src)

	target_mob.painful_scream()
	target_mob.apply_damage(rand(10, 15), BRUTE, def_zone = check_zone(user.zone_selected), wound_bonus = CANT_WOUND, attack_direction = get_dir(user, target_mob), attacking_item = src)
	target_mob.add_mood_event("tester", /datum/mood_event/jabbed_with_tester)

	playsound(src, 'sound/items/hypospray.ogg', vol = 50, vary = TRUE)

	say("Scanning...")

	// Handling it as a timer instead of a do_after prevents abusing the do_after to do antag checks.
	// Otherwise, if the target runs away from the testing do_after, then that means they're likely a host.
	// So, contrary to intuition, having this on a timer is way better for the blood worms than a do_after.
	addtimer(CALLBACK(src, PROC_REF(report_results), HAS_TRAIT(target_mob, TRAIT_BLOOD_WORM_HOST)), 3 SECONDS)

	spent = TRUE
	update_appearance(UPDATE_ICON_STATE | UPDATE_DESC)

/obj/item/blood_worm_tester/proc/can_inject(mob/living/target_mob, mob/living/user, target_zone)
	return target_mob.try_inject(user, target_zone, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE)

/obj/item/blood_worm_tester/proc/report_results(is_worm)
	if (is_worm)
		say("Active hemoparasite presence detected!")
		playsound(src, 'sound/machines/beep/twobeep.ogg', vol = 50, vary = TRUE)
	else
		say("No anomalous readings found.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', vol = 40, vary = TRUE)
