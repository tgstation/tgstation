/obj/item/clothing/mask/joy
	name = "emotion mask"
	desc = "Express your happiness or hide your sorrows with this cultured cutout."
	icon_state = "joy"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDESNOUT
	actions_types = list(/datum/action/item_action/adjust)
	var/static/list/joymask_designs = list()


/obj/item/clothing/mask/joy/Initialize(mapload)
	. = ..()
	joymask_designs = list(
		"Joy" = image(icon = src.icon, icon_state = "joy"),
		"Flushed" = image(icon = src.icon, icon_state = "flushed"),
		"Pensive" = image(icon = src.icon, icon_state = "pensive"),
		"Angry" = image(icon = src.icon, icon_state = "angry"),
		)

/obj/item/clothing/mask/joy/proc/emojichange(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/static/list/options = list("Joy" = "joy", "Flushed" = "flushed", "Pensive" = "pensive","Angry" ="angry")

	var/choice = show_radial_menu(user, src, joymask_designs, custom_check = FALSE, radius = 36, require_near = TRUE)

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtons()
		to_chat(user, "<span class='notice'>You switch the emotion on your mask to [choice].</span>")
		return TRUE

/obj/item/clothing/mask/joy/ui_action_click(mob/user)
	emojichange(user)

/obj/item/clothing/mask/joy/attack_self(mob/user)
	emojichange(user)

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
