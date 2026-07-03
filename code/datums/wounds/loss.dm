/datum/wound_pregen_data/loss
	abstract = FALSE

	wound_path_to_generate = /datum/wound/loss
	required_limb_biostate = NONE
	require_any_biostate = TRUE

	required_wounding_type = WOUND_ALL

	wound_series = WOUND_SERIES_LOSS_BASIC

	threshold_minimum = WOUND_DISMEMBER_OUTRIGHT_THRESH // not actually used since dismembering is handled differently, but may as well assign it since we got it

/datum/wound/loss
	name = "Рана от ампутации"
	desc = "Ай яй яй!!"

	sound_effect = 'sound/effects/dismember.ogg'
	severity = WOUND_SEVERITY_LOSS
	status_effect_type = null
	scar_keyword = "dismember"
	wound_flags = null
	already_scarred = TRUE // We manually assign scars for dismembers through endround missing limbs and aheals

	/// The wounding_type of the attack that caused us. Used to generate the description of our scar. Currently unused, but primarily exists in case non-biological wounds are added.
	var/loss_wounding_type

/// Our special proc for our special dismembering, the wounding type only matters for what text we have
/datum/wound/loss/proc/apply_dismember(obj/item/bodypart/dismembered_part, wounding_type = WOUND_SLASH, outright = FALSE, attack_direction)
	if(!istype(dismembered_part) || !dismembered_part.owner || !(dismembered_part.body_zone in get_viable_zones()) || isalien(dismembered_part.owner) || !dismembered_part.can_dismember())
		qdel(src)
		return

	set_victim(dismembered_part.owner)
	var/self_msg

	if(dismembered_part.body_zone == BODY_ZONE_CHEST)
		occur_text = "рассекается, вызывая выпадение [victim.ru_p_them()] внутренних органов!"
		self_msg = "рассекается, вызывая выпадение ваших внутренних органов!"
	else
		occur_text = dismembered_part.get_dismember_message(wounding_type, outright)

	var/msg = span_bolddanger("[capitalize(dismembered_part.ru_plaintext_zone[NOMINATIVE] || dismembered_part.plaintext_zone)] у [victim.declent_ru(GENITIVE)] [occur_text]")

	victim.visible_message(msg, span_userdanger("Ваша [dismembered_part.ru_plaintext_zone[NOMINATIVE] || dismembered_part.plaintext_zone] [self_msg ? self_msg : occur_text]"))

	loss_wounding_type = wounding_type

	set_limb(dismembered_part)
	second_wind()
	log_wound(victim, src)
	if(dismembered_part.can_bleed() && wounding_type != WOUND_BURN && victim.get_blood_volume())
		victim.spray_blood(attack_direction, severity)
	dismembered_part.dismember(wounding_type == WOUND_BURN ? BURN : BRUTE, wounding_type = wounding_type)
	qdel(src)
	return TRUE

/obj/item/bodypart/proc/get_dismember_message(wounding_type, outright)
	var/occur_text

	if(outright)
		switch(wounding_type)
			if(WOUND_BLUNT)
				occur_text = "разбивается в отвратительное месиво, отрываясь!"
			if(WOUND_SLASH)
				occur_text = "чисто срезается, полностью отсекаясь!"
			if(WOUND_PIERCE)
				occur_text = "разрывается, полностью отсекаясь!"
			if(WOUND_BURN)
				occur_text = "сгорает, превратившись в пыль!"
	else
		var/bone_text = get_internal_description()
		var/tissue_text = get_external_description()

		switch(wounding_type)
			if(WOUND_BLUNT)
				occur_text = "теряет от удара последнюю [bone_text], что удерживала конечность!"
			if(WOUND_SLASH)
				occur_text = "теряет от разреза последнюю [tissue_text], что удерживала конечность!"
			if(WOUND_PIERCE)
				occur_text = "теряет от прокалывания последнюю [tissue_text], что удерживала конечность!"
			if(WOUND_BURN)
				occur_text = "сгорает, превратившись в пыль!"

	return occur_text
