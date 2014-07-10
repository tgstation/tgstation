/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	_color="yellow"
	species_fit = list("Vox")

	power
		var/next_shock = 0

/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05
	species_fit = list("Vox")

	_color="yellow"

/obj/item/clothing/gloves/fyellow/New()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	_color="brown"
	species_fit = list("Vox")

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECITON_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECITON_TEMPERATURE


	hos
		_color = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

	ce
		_color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

	thief
		pickpocket = 1



/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	_color="orange"
	species_fit = list("Vox")

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	_color = "red"
	species_fit = list("Vox")

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	_color = "rainbow"
	species_fit = list("Vox")

	clown
		_color = "clown"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	_color="blue"
	species_fit = list("Vox")

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	_color="purple"
	species_fit = list("Vox")

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	_color="green"
	species_fit = list("Vox")

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	_color="grey"
	species_fit = list("Vox")

	rd
		_color = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

	hop
		_color = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	_color="light brown"
	species_fit = list("Vox")

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	_color="brown"
	species_fit = list("Vox")

	cargo
		_color = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.