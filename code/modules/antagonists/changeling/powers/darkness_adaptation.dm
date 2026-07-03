/datum/action/changeling/darkness_adaptation
	name = "Darkness Adaptation"
	desc = "Пигментация кожи и глаза быстро меняется в зависимости от темноты. \
		Для включения требуется 15 химикатов. Замедляет регенерацию химикатов на 15%."
	helptext = "Позволяет затемнить и изменить полупрозрачность пигментации, а также адаптировать глаза для видения в темных условиях. \
		Эффект полупрозрачности лучше всего работает в темном окружении и одежде. Можно включать и выключать."
	button_icon_state = "darkness_adaptation"
	category = "stealth"
	dna_cost = 2
	chemical_cost = 15
	/// How much we slow chemical regeneration while active, in chems per second
	var/recharge_slowdown = 0.15

/datum/action/changeling/darkness_adaptation/sting_action(mob/living/carbon/human/cling) //SHOULD always be human, because req_human = TRUE
	if(cling.has_status_effect(/datum/status_effect/darkness_adapted))
		disable_ability(cling)
		cling.changeNext_move(CLICK_CD_MELEE * 0.5)
		chemical_cost = initial(chemical_cost)
		return FALSE

	..()
	enable_ability(cling)
	chemical_cost = 0
	return TRUE

/datum/action/changeling/darkness_adaptation/Remove(mob/living/carbon/human/cling)
	disable_ability(cling)
	return ..()

/datum/action/changeling/darkness_adaptation/proc/enable_ability(mob/living/carbon/human/cling)
	if(!cling.apply_status_effect(/datum/status_effect/darkness_adapted))
		return

	cling.visible_message(
		span_warning("Кожа [cling.declent_ru(GENITIVE)] внезапно становится полупрозрачной!"),
		span_notice("Теперь мы стали гораздо более скрытными и лучше видим в темноте."),
	)
	var/datum/antagonist/changeling/changeling_data = cling.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling_data?.chem_recharge_slowdown -= recharge_slowdown //Slows down chem regeneration

/datum/action/changeling/darkness_adaptation/proc/disable_ability(mob/living/carbon/human/cling)
	if(!cling.remove_status_effect(/datum/status_effect/darkness_adapted))
		return

	cling.visible_message(
		span_warning("[capitalize(cling.declent_ru(NOMINATIVE))] появляется из воздуха!"),
		span_notice("Мы становимся внешне нормальными и теряем способность видеть в темноте."),
	)
	var/datum/antagonist/changeling/changeling_data = cling.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling_data?.chem_recharge_slowdown += recharge_slowdown

/// Makes the user harder to see in the dark (and makes the user see in the dark easier)
/datum/status_effect/darkness_adapted
	id = "darkness_adapted"
	tick_interval = 0.6 SECONDS
	alert_type = null
	/// Threshold before the dark color is applied
	var/dark_color_threshold = 70
	/// Tracks last eye strength to avoid unnecessary updates / eye nerfs
	VAR_FINAL/last_eye_strength = 0
	/// Tracks last alpha to avoid unnecessary updates
	VAR_FINAL/last_alpha = 255
	/// When we're moving around, skip any constant tick updates
	COOLDOWN_DECLARE(skip_tick_update)

/datum/status_effect/darkness_adapted/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))
	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(examine_mob))
	update_eye_status()
	update_invis()
	return TRUE

/datum/status_effect/darkness_adapted/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_EXAMINE,
	))
	if(last_eye_strength > 0)
		nerf_eyes(owner.get_organ_by_type(/obj/item/organ/eyes))
	if(last_alpha < 255)
		nerf_invis()

/datum/status_effect/darkness_adapted/proc/examine_mob(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(last_alpha > dark_color_threshold)
		examine_list += span_warning("[owner.p_Their()] skin is shimmering unnaturally in the light.")

/datum/status_effect/darkness_adapted/proc/get_darkness()
	var/turf/owner_turf = get_turf(owner)
	return istype(owner_turf) ? owner_turf.get_lumcount() : 1

/datum/status_effect/darkness_adapted/proc/get_alpha()
	return clamp(65 + ((get_darkness() - LIGHTING_TILE_IS_DARK) * 255), 65, 255)

/datum/status_effect/darkness_adapted/proc/get_eye_strength()
	return clamp(LIGHTING_CUTOFF_MEDIUM - ((get_darkness() - LIGHTING_TILE_IS_DARK) * LIGHTING_CUTOFF_MEDIUM + 5), LIGHTING_CUTOFF_REAL_LOW, LIGHTING_CUTOFF_MEDIUM + 5)

/datum/status_effect/darkness_adapted/proc/update_eye_status(obj/item/organ/eyes/eyes = owner.get_organ_by_type(/obj/item/organ/eyes))
	if(!istype(eyes))
		last_eye_strength = 0
		return
	var/new_eye_strength = get_eye_strength()
	if(last_eye_strength == new_eye_strength)
		return
	buff_eyes(eyes, new_eye_strength)
	last_eye_strength = new_eye_strength

/datum/status_effect/darkness_adapted/proc/buff_eyes(obj/item/organ/eyes/eyes, new_strength = get_eye_strength())
	eyes.lighting_cutoff = new_strength
	if(new_strength >= LIGHTING_CUTOFF_MEDIUM)
		eyes.flash_protect = max(eyes.flash_protect += 1, FLASH_PROTECTION_WELDER)
	else if(last_eye_strength >= LIGHTING_CUTOFF_MEDIUM)
		eyes.flash_protect = max(eyes.flash_protect -= 1, FLASH_PROTECTION_HYPER_SENSITIVE)
	owner.update_sight()

/datum/status_effect/darkness_adapted/proc/nerf_eyes(obj/item/organ/eyes/eyes)
	eyes.lighting_cutoff = initial(eyes.lighting_cutoff)
	if(last_eye_strength >= LIGHTING_CUTOFF_MEDIUM)
		eyes.flash_protect = max(eyes.flash_protect -= 1, FLASH_PROTECTION_HYPER_SENSITIVE)
	owner.update_sight()

/datum/status_effect/darkness_adapted/proc/update_invis()
	var/new_alpha = get_alpha()
	if(last_alpha == new_alpha)
		return
	animate(owner, alpha = new_alpha, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	if(new_alpha <= dark_color_threshold)
		owner.add_atom_colour(COLOR_DARK, TEMPORARY_COLOUR_PRIORITY)
	else
		owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK)
	last_alpha = new_alpha

/datum/status_effect/darkness_adapted/proc/nerf_invis()
	animate(owner, alpha = 255, time = 1 SECONDS)
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK)

/datum/status_effect/darkness_adapted/proc/on_move(...)
	SIGNAL_HANDLER

	update_invis()
	update_eye_status()
	COOLDOWN_START(src, skip_tick_update, 0.5 SECONDS)

/datum/status_effect/darkness_adapted/proc/eye_implanted(mob/living/source, obj/item/organ/gained, special)
	SIGNAL_HANDLER

	if(istype(gained, /obj/item/organ/eyes))
		update_eye_status(gained)

/datum/status_effect/darkness_adapted/proc/eye_removed(mob/living/source, obj/item/organ/removed, special)
	SIGNAL_HANDLER

	if(istype(removed, /obj/item/organ/eyes) && last_eye_strength > 0)
		nerf_eyes(removed)
		last_eye_strength = 0

/datum/status_effect/darkness_adapted/tick(seconds_between_ticks)
	if(!COOLDOWN_FINISHED(src, skip_tick_update))
		return
	update_eye_status()
	update_invis()
