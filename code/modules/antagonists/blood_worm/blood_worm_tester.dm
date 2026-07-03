/obj/item/blood_worm_tester
	name = "hemoparasite testing tool"
	desc = "Специальное устройство, запатентованное медицинской корпорацией DeForest, разработанное для выявления паразитов в крови, в частности, печально известных, кровяных червей. Утверждается, что процесс тестирования очень болезненный."

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
	desc = "[initial(desc)] [spent ? "Анализатор израсходован." : "Анализатор заряжен для единоразового использования."]"
	return ..()

/obj/item/blood_worm_tester/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if (spent)
		target_mob.balloon_alert(user, "уже израсходован!")
		return
	if (!ISADVANCEDTOOLUSER(user))
		target_mob.balloon_alert(user, "не хватает ловкости!")
		return
	if (!ishuman(target_mob))
		target_mob.balloon_alert(user, "нацельтесь в человека!")
		return
	if (!target_mob.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return

	if (target_mob != user)
		user.visible_message(
			message = span_danger("[user.declent_ru(NOMINATIVE)] делает укол [target_mob.declent_ru(GENITIVE)] при помощи [src.declent_ru(GENITIVE)]!"),
			self_message = span_danger("Вы делаете укол [target_mob.declent_ru(DATIVE)] при помощи [src.declent_ru(GENITIVE)]!"),
			ignored_mobs = target_mob,
		)

		target_mob.show_message(
			msg = span_userdanger("[user.declent_ru(NOMINATIVE)] укалывает вас [src.declent_ru(INSTRUMENTAL)]!"),
			type = MSG_VISUAL,
		)
	else
		user.visible_message(
			message = span_notice("[user.declent_ru(NOMINATIVE)] укалывает [user.ru_p_themselves()] себя используя [src.declent_ru(ACCUSATIVE)]."),
			self_message = span_notice("Вы укололи себя с помощью [src.declent_ru(GENITIVE)]."),
		)

	log_combat(user, target_mob, "tested", src)

	target_mob.painful_scream()
	target_mob.apply_damage(rand(10, 15), BRUTE, def_zone = check_zone(user.zone_selected), wound_bonus = CANT_WOUND, attack_direction = get_dir(user, target_mob), attacking_item = src)
	target_mob.add_mood_event("tester", /datum/mood_event/jabbed_with_tester)

	playsound(src, 'sound/items/hypospray.ogg', vol = 50, vary = TRUE)

	say("Сканирование...")

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
		say("Зафиксировано присутствие гемопаразитов!")
		playsound(src, 'sound/machines/beep/twobeep.ogg', vol = 50, vary = TRUE)
	else
		say("Никаких аномальных показаний обнаружено не было.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', vol = 40, vary = TRUE)
