
//These still need to be broken down into other files or such
/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	item_state = "brown"
	permeability_coefficient = 0.05
	flags = NOSLIP
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/shoes/syndigaloshes/all

/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	color = "black"
	desc = "A pair of black shoes."

	redcoat
		color = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	color = "brown"

	captain
		color = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.
	hop
		color = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.
	ce
		color = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.
	rd
		color = "director"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		color = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.
	cmo
		color = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	color = "blue"

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	color = "green"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	color = "yellow"

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	color = "mime"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	color = "purple"

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	icon_state = "brown"
	color = "brown"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	var/chained = 0
	color = "orange"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	color = "red"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	color = "rainbow"

/obj/item/clothing/shoes/swat
	name = "\improper SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags = NOSLIP

/obj/item/clothing/shoes/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags = NOSLIP

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	protective_temperature = 700
	permeability_coefficient = 0.01
	flags = NOSLIP
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.25
	color = "white"

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots"
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	color = "clown"

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	color = "hosred"

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	color = "cult"