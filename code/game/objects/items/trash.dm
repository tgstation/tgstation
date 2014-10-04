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
	bustanuts
		name = "Busta-Nuts"
		icon_state = "busta_nut"
	raisins
		name = "4no raisins"
		icon_state= "4no_raisins"
	candy
		name = "Candy"
		icon_state= "candy"
	cheesie
		name = "Cheesie honkers"
		icon_state = "cheesie_honkers"
	chips
		name = "Chips"
		icon_state = "chips"
	popcorn
		name = "Popcorn"
		icon_state = "popcorn"
	sosjerky
		name = "Scaredy's Private Reserve Beef Jerky"
		icon_state = "sosjerky"
	syndi_cakes
		name = "Syndi cakes"
		icon_state = "syndi_cakes"
	discountchocolate
		name = "Discount Dan's Chocolate Bar"
		icon_state = "danbar"
	danitos
		name = "Danitos"
		icon_state = "danitos"
	waffles
		name = "Waffles"
		icon_state = "waffles"
	plate
		name = "Plate"
		icon_state = "plate"
	snack_bowl
		name = "Snack bowl"
		icon_state	= "snack_bowl"
	pistachios
		name = "Pistachios pack"
		icon_state = "pistachios_pack"
	semki
		name = "Semki pack"
		icon_state = "semki_pack"
	tray
		name = "Tray"
		icon_state = "tray"
	candle
		name = "candle"
		icon = 'icons/obj/candle.dmi'
		icon_state = "candle4"
	liquidfood
		name = "\improper \"LiquidFood\" ration"
		icon_state = "liquidfood"

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return
