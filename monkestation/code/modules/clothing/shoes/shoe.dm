/obj/item/clothing/shoes/phantom
	name = "phantom shoes"
	desc = "Excellent for when you need to do cool flashy flips."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "phantom_shoes"

/obj/item/clothing/shoes/saints
	name = "saints sneakers"
	desc = "Officially branded Saints sneakers. Incredibly valuable!"
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "saints_shoes"

/obj/item/clothing/shoes/morningstar
	name = "morningstar boots"
	desc = "The most expensive boots on this station. Wearing them dropped the value by about 50%."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "morningstar_shoes"

/obj/item/clothing/shoes/driscoll
	name = "driscoll boots"
	desc = "A special pair of leather boots, for those who dont need spurs"
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "driscoll_boots"

/obj/item/clothing/shoes/cowboyboots
	name = "cowboy boots"
	desc = "A standard pair of brown cowboy boots."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "cowboyboots"

/obj/item/clothing/shoes/cowboyboots/black
	name = "black cowboy boots"
	desc = "A pair of black cowboy boots, pretty easy to scuff up."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "cowboyboots_black"

//START HEELS

/obj/item/clothing/shoes/heels
	name = "heels"
	desc = "A both professional and stylish pair of footwear that are difficult to walk in."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "heels"
	can_be_tied = FALSE
	greyscale_colors = "#39393f"
	greyscale_config = /datum/greyscale_config/heels
	greyscale_config_worn = /datum/greyscale_config/heels_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/heels/syndicate
	name = "heels"
	desc = "A both professional and stylish pair of footwear that are shockingly comfortable to walk in. They have have been sharpened to allow them to be used as a rudimentary weapon."
	icon_state = "heels_syndi"
	hitsound = 'sound/weapons/bladeslice.ogg'
	strip_delay = 2 SECONDS
	force = 10
	throwforce = 15
	sharpness = SHARP_POINTY
	attack_verb_continuous = list("attacks", "slices", "slashes", "cuts")
	attack_verb_simple = list("attack", "slice", "slash", "cut")
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/heels/magician
	name = "magical heels"
	desc = "A pair of heels that seem to magically solve all the problems with walking in heels."
	icon_state = "heels_wiz"
	strip_delay = 2 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/heels/centcom
	name = "green heels"
	desc = "A stylish piece of corporate footwear, its ergonomic design makes it easier to both run and work in than the average pair of heels."
	icon_state = "heels_centcom"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/heels/red
	name = "red heels"
	icon_state = "heels_red"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/heels/blue
	name = "blue heels"
	icon_state = "heels_blue"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
//END HEELS
