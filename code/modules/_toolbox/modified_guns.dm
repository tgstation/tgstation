/*/obj/item/gun/ballistic/automatic/pistol/APS/New()
	if(type == /obj/item/gun/ballistic/automatic/pistol/APS)
		icon = 'icons/oldschool/guns.dmi'
	. = ..()*/

/obj/item/gun/ballistic/automatic/wt550/New()
	if(type == /obj/item/gun/ballistic/automatic/wt550)
		icon = 'icons/oldschool/guns.dmi'
	. = ..()

/obj/item/gun/ballistic/automatic/mini_uzi/New()
	if(type == /obj/item/gun/ballistic/automatic/mini_uzi)
		icon = 'icons/oldschool/guns.dmi'
	. = ..()

/obj/item/gun/ballistic/automatic/pistol/New()
	if(type == /obj/item/gun/ballistic/automatic/pistol || type == /obj/item/gun/ballistic/automatic/pistol/suppressed)
		icon = 'icons/oldschool/guns.dmi'
	. = ..()

/obj/item/gun/ballistic/revolver/golden/New()
	if(type == /obj/item/gun/ballistic/revolver/golden)
		icon = 'icons/oldschool/guns.dmi'
	. = ..()

/obj/item/gun/ballistic/automatic/surplus/New()
	if(type == /obj/item/gun/ballistic/automatic/surplus)
		icon = 'icons/oldschool/guns.dmi'
		lefthand_file = 'icons/oldschool/inhand_left.dmi'
		righthand_file = 'icons/oldschool/inhand_right.dmi'
	. = ..()