//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = W_CLASS_TINY
	desc = "This is rubbish."
	w_type=NOT_RECYCLABLE
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	//var/global/list/trash_items = list()

/obj/item/trash/New()
	..()
	trash_items += src

/obj/item/trash/bustanuts
	name = "\improper Busta-Nuts"
	icon_state = "busta_nut"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/oldempirebar
	name = "Old Empire Bar"
	icon_state = "old_empire_bar"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/candy
	name = "candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "\improper Cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"


/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/syndi_cakes
	name = "\improper Syndi cakes"
	icon_state = "syndi_cakes"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/discountchocolate
	name = "\improper Discount Dan's Chocolate Bar"
	icon_state = "danbar"

/obj/item/trash/danitos
	name = "\improper Danitos"
	icon_state = "danitos"

/obj/item/trash/waffles
	name = "waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "plate"
	icon_state = "plate"

/obj/item/trash/pietin
	name = "pie tin"
	icon_state = "pietin"
	autoignition_temperature = 0
	siemens_coefficient = 2 //Do not touch live wires
	melt_temperature = MELTPOINT_SILICON //Not as high as steel

/obj/item/trash/pietin/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/trash/pietin))
		var/obj/item/I = new /obj/item/clothing/head/tinfoil(get_turf(src))
		qdel(W)
		qdel(src)
		user.put_in_hands(I)

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "pemki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/chicken_bucket
	name = "chicken bucket"
	icon_state = "kfc_bucket"
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return

/obj/item/trash/Destroy()
	trash_items -= src
	..()
