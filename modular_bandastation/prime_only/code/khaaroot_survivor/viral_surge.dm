/datum/action/cooldown/spell/khaaroot_adrenaline_surge
	name = "Вирусный всплеск"
	desc = "Временно активирует остатки вируса Кхаарут в организме, давая взрывной прирост выносливости, ускорение и сопротивляемость урону. После завершения наступает короткий период истощения."
	button_icon = 'modular_bandastation/prime_only/icons/khaaroot.dmi'
	button_icon_state = "viral_surge"
	cooldown_time = 120 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/khaaroot_adrenaline_surge/cast(mob/living/cast_on)
	. = ..()

	if(cast_on.has_status_effect(/datum/status_effect/khaaroot_surge_active))
		to_chat(cast_on, span_warning("Вирусные остатки ещё не восстановились после предыдущего всплеска!"))
		return

	cast_on.apply_status_effect(/datum/status_effect/khaaroot_surge_active)
	cast_on.visible_message(
		span_danger("Глаза [cast_on.declent_ru(GENITIVE)] вспыхивают ярко-оранжевым! Вирусная аура на мгновение окутывает [cast_on.declent_ru(ACCUSATIVE)]."),
		span_userdanger("Остатки вируса Кхаарут вскипают в вашей крови! Вы чувствуете чудовищный прилив сил!")
	)

/datum/status_effect/khaaroot_surge_active
	id = "khaaroot_surge_active"
	duration = 12 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/khaaroot_surge_active
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY

	/// Stamina restored when the surge starts.
	var/initial_stamina_heal = -60
	/// Stamina restored per second while the surge is active.
	var/stamina_regen = -15
	/// Brute and burn damage multiplier while the surge is active.
	var/damage_multiplier = 0.6

	var/original_brute_mod
	var/original_burn_mod

/datum/status_effect/khaaroot_surge_active/on_apply()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H))
		return FALSE

	original_brute_mod = H.physiology.brute_mod
	original_burn_mod = H.physiology.burn_mod

	H.add_movespeed_modifier(/datum/movespeed_modifier/khaaroot_surge_speed, update = TRUE)
	H.physiology.brute_mod *= damage_multiplier
	H.physiology.burn_mod *= damage_multiplier
	playsound(H, 'sound/effects/singlebeat.ogg', 50, FALSE, -5)

	ADD_TRAIT(H, TRAIT_SLEEPIMMUNE, REF(src))
	ADD_TRAIT(H, TRAIT_BATON_RESISTANCE, REF(src))

	H.adjust_stamina_loss(initial_stamina_heal)

	return TRUE

/datum/status_effect/khaaroot_surge_active/tick(seconds_between_ticks)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return

	H.adjust_stamina_loss(stamina_regen * seconds_between_ticks, forced = TRUE)

/datum/status_effect/khaaroot_surge_active/on_remove()
	var/mob/living/carbon/human/H = owner
	if(!H)
		return

	H.remove_movespeed_modifier(/datum/movespeed_modifier/khaaroot_surge_speed, update = TRUE)
	H.physiology.brute_mod = original_brute_mod
	H.physiology.burn_mod = original_burn_mod

	REMOVE_TRAIT(H, TRAIT_SLEEPIMMUNE, REF(src))
	REMOVE_TRAIT(H, TRAIT_BATON_RESISTANCE, REF(src))

	H.visible_message(
		span_warning("Оранжевое свечение в глазах [H.declent_ru(GENITIVE)] гаснет, и [H.ru_p_they()] тяжело переводит дух."),
		span_danger("Вирусный всплеск отступает. Волна истощения накрывает вас.")
	)

	H.apply_status_effect(/datum/status_effect/khaaroot_surge_crash)

/datum/status_effect/khaaroot_surge_crash
	id = "khaaroot_surge_crash"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/khaaroot_surge_crash
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS

/datum/status_effect/khaaroot_surge_crash/on_apply()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H))
		return FALSE

	H.add_movespeed_modifier(/datum/movespeed_modifier/khaaroot_surge_crash, update = TRUE)
	to_chat(H, span_danger("Ваши мышцы дрожат от перенапряжения. Вы двигаетесь значительно медленнее."))

	return TRUE

/datum/status_effect/khaaroot_surge_crash/on_remove()
	var/mob/living/carbon/human/H = owner
	if(!H)
		return

	H.remove_movespeed_modifier(/datum/movespeed_modifier/khaaroot_surge_crash, update = TRUE)
	to_chat(H, span_notice("Вы восстанавливаете контроль над телом. Истощение отступает."))

/datum/movespeed_modifier/khaaroot_surge_speed
	multiplicative_slowdown = -0.12

/datum/movespeed_modifier/khaaroot_surge_crash
	multiplicative_slowdown = 0.3

/atom/movable/screen/alert/status_effect/khaaroot_surge_active
	name = "Вирусный всплеск Кхаарут"
	desc = "Остатки вируса Кхаарут активны! Вы движетесь быстрее, восстанавливаете силы и имеете повышенное сопротивление."
	icon_state = "high"

/atom/movable/screen/alert/status_effect/khaaroot_surge_crash
	name = "Истощение Кхаарут"
	desc = "Вирусные остатки исчерпаны. Вы истощены и двигаетесь значительно медленнее."
	icon_state = "stun"
