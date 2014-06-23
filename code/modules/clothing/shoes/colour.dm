/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	_color = "black"
	desc = "A pair of black shoes."
	species_fit = list("Vox")

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECITON_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECITON_TEMPERATURE

	redcoat
		_color = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	_color = "brown"
	species_fit = list("Vox")

	captain
		_color = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.
	hop
		_color = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.
	ce
		_color = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.
	rd
		_color = "director"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		_color = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		_color = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	_color = "blue"

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	_color = "green"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	_color = "yellow"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	_color = "purple"

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	icon_state = "brown"
	_color = "brown"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	_color = "red"

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	_color = "white"
	species_fit = list("Vox")

/obj/item/clothing/shoes/leather
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"
	_color = "leather"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	_color = "rainbow"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	_color = "orange"
	species_fit = list("Vox")

/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new chaintype( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/orange/attackby(var/obj/O, loc)
	..()
	if ((istype(O, /obj/item/weapon/handcuffs) && !( src.chained )))
		var/obj/item/weapon/handcuffs/H=O
		//H = null
		if (src.icon_state != "orange") return
		src.chained = 1
		src.chaintype = H.type
		src.slowdown = 15
		src.icon_state = "orange1"
		del(H)
	return