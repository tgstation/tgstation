/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	colour="yellow"

/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05

	colour="yellow"

	New()
		siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	colour="brown"

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT


	hos
		colour = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

	ce
		colour = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	colour="orange"

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	colour = "red"

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	colour = "rainbow"

	clown
		colour = "clown"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	colour="blue"

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	colour="purple"

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	colour="green"

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	colour="grey"

	rd
		colour = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

	hop
		colour = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	colour="light brown"

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	colour="brown"

	cargo
		colour = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.