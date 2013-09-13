/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	col = "black"
	desc = "A pair of black shoes."

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

	redcoat
		col = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	col = "brown"

	captain
		col = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.
	hop
		col = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.
	ce
		col = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.
	rd
		col = "director"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		col = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		col = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	col = "blue"

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	col = "green"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	col = "yellow"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	col = "purple"

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	icon_state = "brown"
	col = "brown"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	col = "red"

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	col = "white"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	col = "rainbow"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	col = "orange"

/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/orange/attackby(H as obj, loc)
	..()
	if ((istype(H, /obj/item/weapon/handcuffs) && !( src.chained )))
		//H = null
		if (src.icon_state != "orange") return
		del(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return