/datum/action/cooldown/spell/pointed/blood_siphon
	name = "Отток крови"
	desc = "Заклинание с выбором цели, которое исцеляет ваши раны, нанося урон врагу. \
		Имеет шанс передать раны между вами и врагом."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "FL'MS O' 'T'RN'TY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6

/datum/action/cooldown/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/blood_siphon/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'sound/effects/magic/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		owner.balloon_alert(owner, "spell blocked!")
		cast_on.visible_message(
			span_danger("Заклинание отскакивает от [cast_on.declent_ru(GENITIVE)]!"),
			span_danger("Заклинание отскакивает от вас!"),
		)
		return FALSE

	cast_on.visible_message(
		span_danger("[capitalize(cast_on.declent_ru(NOMINATIVE))] бледнеет, когда [cast_on.ru_p_them()] охватывает красное сияние!"),
		span_danger("Вы бледнеете, когда вас охватывает красное сияние!"),
	)

	var/mob/living/living_owner = owner
	cast_on.adjust_brute_loss(20)
	living_owner.adjust_brute_loss(-20)

	cast_on.transfer_blood_to(living_owner, 20, ignore_low_blood = TRUE, ignore_incompatibility = TRUE, transfer_viruses = FALSE)

	if(!iscarbon(cast_on) || !iscarbon(owner))
		return TRUE

	var/mob/living/carbon/carbon_target = cast_on
	var/mob/living/carbon/carbon_user = owner
	for(var/obj/item/bodypart/bodypart as anything in carbon_user.get_bodyparts())
		for(var/datum/wound/iter_wound as anything in bodypart.wounds)
			if(prob(50))
				continue
			var/obj/item/bodypart/target_bodypart = carbon_target.get_bodypart(bodypart.body_zone)
			if(!target_bodypart)
				continue
			iter_wound.remove_wound()
			iter_wound.apply_wound(target_bodypart)

	return TRUE
