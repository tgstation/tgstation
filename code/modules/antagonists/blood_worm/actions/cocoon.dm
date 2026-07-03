/datum/action/cooldown/mob_cooldown/blood_worm/cocoon
	cooldown_time = 30 SECONDS
	shared_cooldown = NONE

	click_to_activate = FALSE

	var/cocoon_type = null
	var/obj/structure/blood_worm_cocoon/cocoon = null

	var/new_worm_type = null

	var/total_blood_required = 0

	var/timer_id = null

	var/cocoon_time = 30 SECONDS

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/Grant(mob/granted_to)
	. = ..()
	if (!owner)
		return

	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_worm_stat_changed), override = TRUE)
	RegisterSignal(owner, COMSIG_BLOOD_WORM_CONSUMED_BLOOD, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/Remove(mob/removed_from)
	if (!QDELETED(cocoon))
		cancel()
	UnregisterSignal(owner, COMSIG_BLOOD_WORM_CONSUMED_BLOOD)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/IsAvailable(feedback)
	if (!istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	if (!ispath(cocoon_type, /obj/structure/blood_worm_cocoon))
		return FALSE
	if (!ispath(new_worm_type, /mob/living/basic/blood_worm))
		return FALSE
	if (HAS_TRAIT(owner, TRAIT_SHAPESHIFTED))
		if (feedback)
			owner.balloon_alert(owner, "не во время превращения!")
		return FALSE
	if (!isturf(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "встаньте на землю!")
		return FALSE
	if (!check_consumed_blood(feedback))
		return FALSE
	if (!QDELETED(cocoon))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/Activate(atom/target)
	owner.visible_message(
		message = span_danger("[owner.declent_ru(NOMINATIVE)] начинает выращивать кокон!"),
		self_message = span_notice("Вы начинаете выращивать кокон."),
		blind_message = span_hear("До вас доносится звук срастающейся плоти.")
	)

	if (!do_after(owner, 5 SECONDS, extra_checks = CALLBACK(src, PROC_REF(check_consumed_blood))))
		return FALSE

	owner.visible_message(
		message = span_danger("[owner.declent_ru(NOMINATIVE)] вошел в кокон!"),
		self_message = span_green("Вы входите в свежесотканный кокон!"),
		blind_message = span_hear("Вы больше не слышите звук срастающейся плоти!")
	)

	cocoon = new cocoon_type(get_turf(owner))

	playsound(cocoon, 'sound/effects/blob/blobattack.ogg', vol = 60, vary = TRUE, ignore_walls = FALSE)

	owner.forceMove(cocoon)

	owner.add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_EMOTEMUTE), REF(src))

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_worm_moved))
	RegisterSignal(cocoon, COMSIG_QDELETING, PROC_REF(on_cocoon_qdel))

	INVOKE_ASYNC(src, PROC_REF(handle_timer))

	return TRUE

/// Override this if you want special timer behaviors like polling ghosts for hatchling candidates.
/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/handle_timer()
	timer_id = addtimer(CALLBACK(src, PROC_REF(finalize)), cocoon_time, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_DELETE_ME)

/// Called upon successfully finishing the incubation process.
/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/finalize()
	var/mob/living/basic/blood_worm/new_worm = new new_worm_type(get_turf(cocoon))

	transfer(owner, new_worm)

	for (var/mob/living/unfortunate_observer in view(3, cocoon))
		if (new_worm.faction_check_atom(unfortunate_observer))
			continue // Don't harm our siblings.
		if (unfortunate_observer.stat == DEAD)
			continue // Harms potential hosts.

		unfortunate_observer.visible_message(
			message = span_danger("[unfortunate_observer.declent_ru(NOMINATIVE)] окатывается волной едкой крови!"),
			self_message = span_userdanger("Вас окатывает волной едкой крови! АУЧ!"),
			blind_message = span_hear("Вы слышите шипение!")
		)

		unfortunate_observer.Knockdown(3 SECONDS)
		unfortunate_observer.adjust_fire_loss(rand(30, 50))

		var/range = 4 - get_dist(cocoon, unfortunate_observer)
		unfortunate_observer.throw_at(get_ranged_target_turf_direct(cocoon, unfortunate_observer, range), range = range, speed = 2)

	for (var/turf/turf in view(3, cocoon))
		if (prob(100 - get_dist(cocoon, turf) * 20))
			new /obj/effect/decal/cleanable/blood(turf)

	playsound(cocoon, 'sound/effects/splat.ogg', vol = 100, vary = TRUE, ignore_walls = FALSE)

	shared_unregister_cocoon()

	qdel(owner)

/// Transfers the owning blood worm from one worm mob to another.
/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/transfer(mob/living/basic/blood_worm/old_worm, mob/living/basic/blood_worm/new_worm)
	old_worm.mind?.transfer_to(new_worm)

	new_worm.id_number = old_worm.id_number
	new_worm.update_name()

	// Safety check: If someone gets turned into a blood worm, they need to keep their old mind name.
	if (new_worm.mind.name == old_worm.real_name)
		new_worm.mind.name = new_worm.real_name

	new_worm.consumed_normal_blood = old_worm.consumed_normal_blood
	new_worm.consumed_synth_blood = old_worm.consumed_synth_blood

	new_worm.spit_action?.set_key(old_worm.spit_action?.full_key)
	new_worm.leech_action?.set_key(old_worm.leech_action?.full_key)
	new_worm.invade_action?.set_key(old_worm.invade_action?.full_key)
	new_worm.cocoon_action?.set_key(old_worm.cocoon_action?.full_key)

	new_worm.transfuse_action?.set_key(old_worm.transfuse_action?.full_key)
	new_worm.eject_action?.set_key(old_worm.eject_action?.full_key)
	new_worm.revive_action?.set_key(old_worm.revive_action?.full_key)

	new_worm.cocoon_action?.StartCooldown()

/// Cancels the incubation process, destroying the cocoon early.
/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/cancel()
	cocoon.visible_message(
		message = span_danger("[cocoon.declent_ru(NOMINATIVE)] разваливается на куски, избавляясь от [owner.declent_ru(ACCUSATIVE)]."),
		blind_message = span_danger("Вы слышите противный хлюпающий звук!"),
		ignored_mobs = owner
	)

	if (!QDELETED(owner) && owner.stat != DEAD)
		to_chat(owner, span_userdanger("Ваш кокон разваливается на части!"))

	playsound(cocoon, 'sound/effects/splat.ogg', vol = 60, vary = TRUE, ignore_walls = FALSE)

	// A little less punishing since you need a do_after to set it up again after anyway, and because this can occur due to adults canceling Reproduce for meta reasons outside of their control.
	StartCooldown(10 SECONDS)

	shared_unregister_cocoon()

/// Unregisters the cocoon. Used by both [proc/cancel] and [proc/finalize].
/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/shared_unregister_cocoon()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(cocoon, COMSIG_QDELETING)

	owner.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_EMOTEMUTE), REF(src))

	if (!QDELETED(owner))
		owner.forceMove(cocoon.drop_location())

	if (!QDELETED(cocoon))
		qdel(cocoon)

	cocoon = null

	if (timer_id)
		deltimer(timer_id)
		timer_id = null

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/on_worm_stat_changed(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if (cocoon && old_stat != DEAD && new_stat == DEAD) // Alive -> Dead
		cancel()
	update_status_on_signal(source, new_stat, old_stat)

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/on_worm_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	cancel()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/on_cocoon_qdel(datum/source)
	SIGNAL_HANDLER
	cancel()

/// Checks if the blood worm has consumed enough blood to use this action.
/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/proc/check_consumed_blood(feedback = FALSE)
	var/mob/living/basic/blood_worm/worm = owner
	var/total_consumed_blood = worm.get_consumed_blood()

	if (total_consumed_blood < total_blood_required)
		if (feedback)
			worm.balloon_alert(worm, "вы насытились только на [FLOOR(total_consumed_blood / total_blood_required * 100, 1)]% от необходимого для дальнейшего роста!")
		return FALSE
	return TRUE

/obj/structure/blood_worm_cocoon
	icon = 'icons/mob/nonhuman-player/blood_worm_32x32.dmi'

	faction = list(FACTION_BLOOD_WORM)

	density = TRUE
	anchored = TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/hatchling
	name = "Взросление"
	desc = "Проводит инкубацию в коконе, превращая вас в молодого кровяного червя."

	button_icon_state = "mature_hatchling"

	cocoon_type = /obj/structure/blood_worm_cocoon/hatchling
	new_worm_type = /mob/living/basic/blood_worm/juvenile

	total_blood_required = 500

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/hatchling/Activate(atom/target)
	if (tgui_alert(owner, "Вы уверены? После [cocoon_time / 10] секунд, вы станете юной особью, получив увеличение характеристик, а также навык «Плевок токсичной кровью», однако, вы потеряете возможность перемещатьсья по вентиляции.", "Взросление", list("Да", "Нет"), 30 SECONDS) != "Да")
		return
	if (!IsAvailable(feedback = TRUE))
		return

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/hatchling/transfer(mob/living/basic/blood_worm/old_worm, mob/living/basic/blood_worm/new_worm)
	. = ..()

	log_blood_worm("[key_name(new_worm)] finished maturing into a juvenile blood worm")

/obj/structure/blood_worm_cocoon/hatchling
	name = "small blood cocoon"
	desc = "Инкубационный кокон личинки кровяного червя. Его поверхность медленно изменяется."

	icon_state = "cocoon-small"

	max_integrity = 100
	damage_deflection = 10

/obj/structure/blood_worm_cocoon/hatchling/examine(mob/user)
	return ..() + span_warning("Кокон можно сломать, чтобы предотвратить созревание кровяного червя.")

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/juvenile
	name = "Взросление"
	desc = "Проводит инкубацию в коконе, превращая вас во взрослого кровяного червя."

	button_icon_state = "mature_juvenile"

	cocoon_type = /obj/structure/blood_worm_cocoon/juvenile
	new_worm_type = /mob/living/basic/blood_worm/adult

	total_blood_required = 1500

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/juvenile/Activate(atom/target)
	if (tgui_alert(owner, "Вы уверены? После [cocoon_time / 10] секунд вы станете взрослым кровавым червем, увеличив свои характеристики, а также получив навык «Плевок сгустком токсичной крови», активировать который можно нажав ПКМ при использовании «Плевок токсичной кровью» вне носителя.", "Взросление", list("Да", "Нет"), 30 SECONDS) != "Да")
		return
	if (!IsAvailable(feedback = TRUE))
		return

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/juvenile/transfer(mob/living/basic/blood_worm/old_worm, mob/living/basic/blood_worm/new_worm)
	. = ..()

	log_blood_worm("[key_name(new_worm)] finished maturing into an adult blood worm")

/obj/structure/blood_worm_cocoon/juvenile
	name = "medium blood cocoon"
	desc = "Инкубационный кокон молодого кровяного червя. Его поверхность медленно изменяется."

	icon_state = "cocoon-medium"

	max_integrity = 150
	damage_deflection = 15

/obj/structure/blood_worm_cocoon/juvenile/examine(mob/user)
	return ..() + span_warning("Его можно сломать, чтобы предотвратить созревание кровяного червя, хотя выглядит он довольно крепким.")

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult
	name = "Размножение"
	desc = "Погрузиться в инкубацию внутри кокона и породить 4 новые личинки, одной из которых будете вы."

	button_icon_state = "reproduce"

	cocoon_type = /obj/structure/blood_worm_cocoon/adult
	new_worm_type = /mob/living/basic/blood_worm/hatchling

	total_blood_required = 0

	var/num_hatchlings = 3 // in addition to the original

	var/list/candidates = null

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/Grant(mob/granted_to)
	. = ..()
	if (!owner)
		return

	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/Remove(mob/removed_from)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(update_status_on_signal))

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/Activate(atom/target)
	if (tgui_alert(owner, "Вы уверены? После [cocoon_time / 10] секунд, вы создадите [num_hatchlings + 1] новые личинки, включая себя самого.", "Размножение", list("Да", "Нет"), 30 SECONDS) != "Да")
		return
	if (!IsAvailable(feedback = TRUE))
		return

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/handle_timer()
	cocoon.balloon_alert(owner, "polling ghosts")

	candidates = SSpolling.poll_ghost_candidates(
		question = "Хотели бы вы стать только что вылупившимся кровяным червем? (x[num_hatchlings])",
		role = ROLE_BLOOD_WORM_INFESTATION,
		check_jobban = ROLE_BLOOD_WORM,
		poll_time = cocoon_time,
		ignore_category = POLL_IGNORE_BLOOD_WORM,
		alert_pic = cocoon_type, // The hatchling icon is too small, and a well-cropped juvenile icon is already used for the main spawn event.
		jump_target = cocoon,
		role_name_text = "blood worm",
		amount_to_pick = num_hatchlings
	)

	// poll_ghost_candidates returns a single mob instead of a list when exactly 1 candidate signs up, even with amount_to_pick > 1.
	if (!islist(candidates) && candidates)
		candidates = list(candidates)

	var/num_candidates = length(candidates)

	if (QDELETED(cocoon))
		send_apology_to_candidates() // If this is reached, then [proc/cancel], which normally handles apologizing to the candidates, has already been called before the poll was finished.
		return
	if (num_candidates <= 0)
		cancel()
		owner.balloon_alert(owner, "нет кандидатов!") // We can't host this balloon alert on a deleted cocoon.
		return
	if (num_candidates < num_hatchlings && tgui_alert(owner, "Сейчас только [num_candidates]/[num_hatchlings] кандидатов для личинок, всё равно хотите продолжить?", "Ghost Shortage", list("Да", "Нет"), 10 SECONDS) != "Да")
		cancel()
		return

	finalize() // The poll is the timer.

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/finalize()
	for (var/mob/candidate as anything in candidates)
		if (isnull(candidate) || isnull(candidate.key) || isnull(candidate.client))
			continue

		// The crew now has 3 new problems to deal with.
		var/mob/living/basic/blood_worm/hatchling/new_hatchling = new(cocoon.drop_location())
		var/datum/mind/fresh_mind = new(candidate.key)

		fresh_mind.transfer_to(new_hatchling, force_key_move = TRUE)
		fresh_mind.add_antag_datum(/datum/antagonist/blood_worm/infestation)

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/transfer(mob/living/basic/blood_worm/old_worm, mob/living/basic/blood_worm/new_worm)
	. = ..()

	new_worm.reset_consumed_blood()

	SEND_SIGNAL(new_worm, COMSIG_BLOOD_WORM_REPRODUCED)

	log_blood_worm("[key_name(new_worm)] finished reproducing, resetting their growth back into a hatchling blood worm")

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/cancel()
	send_apology_to_candidates()

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/shared_unregister_cocoon()
	candidates = null

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/adult/proc/send_apology_to_candidates()
	for (var/mob/candidate as anything in candidates)
		if (isnull(candidate) || isnull(candidate.key) || isnull(candidate.client))
			continue

		// Sucks, but that's just how it is sometimes.
		to_chat(candidate, span_warning("Кокон кровяного червя, которого вы выбрали был отменен. Увы."))

/obj/structure/blood_worm_cocoon/adult
	name = "large blood cocoon"
	desc = "Инкубационный кокон взрослого кровяного червя. Вы можете видеть множество едва различимых очертаний внутри."

	icon_state = "cocoon-large"

	max_integrity = 200
	damage_deflection = 20

/obj/structure/blood_worm_cocoon/adult/examine(mob/user)
	return ..() + span_warning("Его можно сломать, чтобы предотвратить размножение кровяного червя, но на вид он чрезвычайно прочный.")

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/hatchling/polymorph
	new_worm_type = /mob/living/basic/blood_worm/juvenile/polymorph

/datum/action/cooldown/mob_cooldown/blood_worm/cocoon/juvenile/polymorph
	new_worm_type = /mob/living/basic/blood_worm/adult/polymorph
