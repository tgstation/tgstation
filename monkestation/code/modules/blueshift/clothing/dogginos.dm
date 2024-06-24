/obj/item/clothing/suit/toggle/jacket/hoodie/pizza
	name = "dogginos hoodie"
	desc = "A hoodie often worn by the delivery boys of this intergalactically known brand of pizza."
	greyscale_colors = "#c40000"

/obj/item/clothing/suit/pizzaleader
	name = "dogginos manager coat"
	desc = "A long, cool, flowing coat in a tasteless red colour."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "forensics_red_long"

/obj/item/clothing/under/pizza
	name = "dogginos employee uniform"
	desc = "The standard issue for the famous dog-founded pizza brand, Dogginos."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/centcom.dmi' //Dogginos is not technically affiliated with CC, but it's not OPPOSING it, and its an "ERT"...
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/centcom.dmi'
	icon_state = "dominos"

/obj/item/radio/headset/headset_cent/impostorsr
	keyslot2 = null

/obj/item/radio/headset/chameleon/advanced
	special_desc = "A chameleon headset employed by the Syndicate in infiltration operations. \
	This particular model features flashbang protection, and the ability to amplify your volume."
	command = TRUE
	freerange = TRUE

/obj/item/radio/headset/chameleon/advanced/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/clothing/head/pizza
	name = "dogginos manager hat"
	desc = "Looks like something a Sol general would wear."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "dominosleader"
