/obj/item/clothing/mask/joy
	name = "emotion mask"
	desc = "Express your happiness or hide your sorrows with this cultured cutout."
	icon_state = "joy"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDESNOUT
	unique_reskin = list(
			"Joy" = "joy",
			"Flushed" = "flushed",
			"Pensive" = "pensive",
			"Angry" = "angry",
			"Pleading" = "pleading"
	)

/obj/item/clothing/mask/joy/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/clothing/mask/joy/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Change Emotion"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/mask/joy/reskin_obj(mob/user)
	. = ..()
	user.update_worn_mask()
	current_skin = null//so we can infinitely reskin

/obj/item/clothing/mask/mummy
	name = "mummy mask"
	desc = "Ancient bandages."
	icon_state = "mummy_mask"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/scarecrow
	name = "sack mask"
	desc = "A burlap sack with eyeholes."
	icon_state = "scarecrow_sack"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
