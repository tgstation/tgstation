/obj/item/clothing/mask/joy
	name = "emotion mask"
	desc = "Express your happiness or hide your sorrows with this cultured cutout."
	icon_state = "joy"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDESNOUT
	actions_types = list(/datum/action/item_action/adjust)
	unique_reskin = list("Joy" = "joy",
						"Flushed" = "flushed",
						"Pensive" = "pensive",
						"Angry" = "angry",
						)

/obj/item/clothing/mask/joy/ui_action_click(mob/user)
	reskin_obj(user)

/obj/item/clothing/mask/joy/reskin_obj(mob/user)
	..()
	user.update_inv_wear_mask()
	for(var/X in actions)
		var/datum/action/actionbutton = X
		actionbutton.UpdateButtons()
	current_skin = null//so we can infinitely reskin

/obj/item/clothing/mask/mummy
	name = "mummy mask"
	desc = "Ancient bandages."
	icon_state = "mummy_mask"
	inhand_icon_state = "mummy_mask"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/scarecrow
	name = "sack mask"
	desc = "A burlap sack with eyeholes."
	icon_state = "scarecrow_sack"
	inhand_icon_state = "scarecrow_sack"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
