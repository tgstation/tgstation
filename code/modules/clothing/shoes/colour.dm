/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	colour = "black"
	desc = "A pair of black shoes."

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

	redcoat
		colour = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	colour = "brown"

	captain
		colour = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.
	hop
		colour = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.
	ce
		colour = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.
	rd
		colour = "director"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		colour = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		colour = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	colour = "blue"

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	colour = "green"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	colour = "yellow"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	colour = "purple"

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	icon_state = "brown"
	colour = "brown"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	colour = "red"

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	colour = "white"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	colour = "rainbow"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	colour = "orange"

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