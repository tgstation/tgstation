//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = 1.0
	desc = "This is rubbish."
	w_type=NOT_RECYCLABLE
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1

/obj/item/trash/bustanuts
	name = "Busta-Nuts"
	icon_state = "busta_nut"

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "Candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "Cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "Chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "Popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "Syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/discountchocolate
	name = "Discount Dan's Chocolate Bar"
	icon_state = "danbar"

/obj/item/trash/danitos
	name = "Danitos"
	icon_state = "danitos"

/obj/item/trash/waffles
	name = "Waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "Plate"
	icon_state = "plate"

/obj/item/trash/snack_bowl
	name = "Snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/pistachios
	name = "Pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "Semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "Tray"
	icon_state = "tray"

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/chicken_bucket
	name = "Chicken bucket"
	icon_state = "kfc_bucket"

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return
