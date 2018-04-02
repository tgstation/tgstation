//adding things to vending machines with out editing vending machine files
/obj/machinery/vending/clothing/New()
	if(type == /obj/machinery/vending/clothing)
		products += list(/obj/item/clothing/under/tracksuit = 1,/obj/item/clothing/suit/hooded/filthypink = 1)
	. = ..()

/obj/machinery/vending/autodrobe/New()
	if(type == /obj/machinery/vending/autodrobe)
		products += list(/obj/item/clothing/mask/balaclava/skull = 1)
	. = ..()

/obj/item/vending_refill/autodrobe/New()
	..()
	charges = list(34, 2, 3)
	init_charges = list(34, 2, 3)

//volodyah's pink suit

/obj/item/clothing/suit/hooded/filthypink
	name = "filthy pink suit"
	desc = "Makes you want to record a 'Harlem Shake' video."
	icon = 'icons/oldschool/clothing/suititem.dmi'
	icon_state = "filthypink"
	item_state = "p_suit"
	alternate_worn_icon = 'icons/oldschool/clothing/suitmob.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0, fire = 0, acid = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/filthypink

/obj/item/clothing/head/hooded/filthypink
	name = "filthy pink hood"
	desc = null
	icon = 'icons/oldschool/clothing/headitem.dmi'
	icon_state = "filthypink"
	alternate_worn_icon = 'icons/oldschool/clothing/headmob.dmi'
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

//Yolodyahs skull mask

/obj/item/clothing/mask/balaclava/skull
	name = "skull balaclava"
	desc = "LOADSASCARY"
	icon = 'icons/oldschool/clothing/maskitem.dmi'
	icon_state = "skullbalaclava"
	item_state = "bgloves"
	alternate_worn_icon = 'icons/oldschool/clothing/maskmob.dmi'

//track suit
/obj/item/clothing/under/tracksuit
	name = "track suit"
	desc = null
	icon = 'icons/oldschool/clothing/uniformitem.dmi'
	icon_state = "slav_track_suit"
	item_state = "bl_suit"
	alternate_worn_icon = 'icons/oldschool/clothing/uniformmob.dmi'

/obj/item/clothing/under/tracksuit/spawn_with_vodka/New()
	. = ..()
	if(loc)
		var/obj/item/reagent_containers/food/drinks/bottle/vodka/V = new(loc)
		V.layer = layer-0.1