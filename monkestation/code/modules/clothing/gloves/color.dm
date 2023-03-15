/obj/item/clothing/gloves/color/yellow/catgloves
	desc = "A pair of heavy rubber cosplay gloves, doing basically anything in these would probably be obscenely difficult, including taking them off. At least they might help against shocks, but is it ultimately worth how much people are going to make fun of you?"
	name = "cat gloves"
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/gloves.dmi'
	icon_state = "catgloves"
	item_state = "catgloves"
	greyscale_colors =  "#ffffff#FFC0CB"
	greyscale_config_worn = /datum/greyscale_config/catgloves_worn
	greyscale_config = /datum/greyscale_config/catgloves
	worn_icon_state = "catgloves"

/obj/item/clothing/gloves/color/yellow/catgloves/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		ADD_TRAIT(H,TRAIT_NOGUNS,CLOTHING_TRAIT)
		ENABLE_BITFIELD(clothing_flags, NOTDROPPABLE)

/obj/item/clothing/gloves/color/yellow/catgloves/dropped(mob/user, slot)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		REMOVE_TRAIT(H,TRAIT_NOGUNS,CLOTHING_TRAIT)

