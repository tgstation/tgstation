/datum/species/lizard
	payday_modifier = 1

/datum/species/lizard/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender ==MALE)
		return pick(
		'sound/voice/lizard/lizard_scream_1.ogg',
		'sound/voice/lizard/lizard_scream_2.ogg',
		'sound/voice/lizard/lizard_scream_3.ogg',
		'monkestation/sound/voice/screams/lizard/lizard_scream_4.ogg',
		)

	return pick(
		'sound/voice/lizard/lizard_scream_1.ogg',
		'sound/voice/lizard/lizard_scream_2.ogg',
		'sound/voice/lizard/lizard_scream_3.ogg',
		'monkestation/sound/voice/screams/lizard/lizard_scream_5.ogg',
	)

/datum/species/lizard/get_laugh_sound(mob/living/carbon/human/human)
	if(prob(1))
		return 'monkestation/sound/voice/weh.ogg'
	return 'monkestation/sound/voice/laugh/lizard/lizard_laugh.ogg'

/datum/species/lizard/get_custom_worn_config_fallback(item_slot, obj/item/item)

	return item.greyscale_config_worn_lizard_fallback

/datum/species/lizard/generate_custom_worn_icon(item_slot, obj/item/item)
	. = ..()
	if(.)
		return

	// Use the fancy fallback sprites.
	. = generate_custom_worn_icon_fallback(item_slot, item)
	if(.)
		return
