//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/janitor.dmi'
	desc = "This is rubbish."
	w_class = 1.0

	raisins
		name = "4no raisins"
		icon_state= "4no_raisins"
	candy
		name = "candy"
		icon_state= "candy"
	cheesie
		name = "cheesie honkers"
		icon_state = "cheesie_honkers"
	chips
		name = "chips"
		icon_state = "chips"
	popcorn
		name = "popcorn"
		icon_state = "popcorn"
	sosjerky
		name = "\improper Scaredy's Private Reserve Beef Jerky"
		icon_state = "sosjerky"
	syndi_cakes
		name = "syndi-cakes"
		icon_state = "syndi_cakes"
	waffles
		name = "waffles"
		icon_state = "waffles"
	plate
		name = "plate"
		icon_state = "plate"
	snack_bowl
		name = "snack bowl"
		icon_state	= "snack_bowl"
	pistachios
		name = "pistachios pack"
		icon_state = "pistachios_pack"
	semki
		name = "semki pack"
		icon_state = "semki_pack"
	tray
		name = "tray"
		icon_state = "tray"
	candle
		name = "candle"
		icon = 'icons/obj/candle.dmi'
		icon_state = "candle4"

/obj/item/trash/attack(mob/M, mob/living/user)
	return