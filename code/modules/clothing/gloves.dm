// NO GLOVES NO LOVES

/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2.0
	icon = 'gloves.dmi'
	protective_temperature = 400
	heat_transfer_coefficient = 0.25
	siemens_coefficient = 0.50
	var/siemens_coefficient_archived = 0
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES


/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "latex"
	item_state = "lgloves"
	color="mime"

	redcoat
		color = "redcoat"		//Exists for washing machines. Is not different from white gloves in any way.

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	color="brown"
	protective_temperature = 1500
	heat_transfer_coefficient = 0.01

	hos
		color = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

	ce
		color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/detective
	desc = "Made of well worn leather. These gloves are comfortable, useful, and stylish!"
	name = "detective's gloves"
	icon_state = "black"
	item_state = "bgloves"
	color="brown"
	siemens_coefficient = 0.30
	protective_temperature = 1100

/obj/item/clothing/gloves/hos
	desc = "These gloves belong to the man in charge of the guns."
	name = "head of security's gloves"
	icon_state = "black"
	item_state = "bgloves"
	color="brown"
	siemens_coefficient = 0.30
	protective_temperature = 1100

/obj/item/clothing/gloves/cyborg
	desc = "Beep. Boop. Beep."
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1.0

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	protective_temperature = 310
	heat_transfer_coefficient = 0.90
	color="white"

	cmo
		color = "medical"		//Exists for washing machines. Is not different from latex gloves in any way.

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	protective_temperature = 1100
	heat_transfer_coefficient = 0.01

/obj/item/clothing/gloves/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	protective_temperature = 1100
	heat_transfer_coefficient = 0.01

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	protective_temperature = 1100
	heat_transfer_coefficient = 0.05
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400

//BEEP BEEP IT'S THE COMMENT BRIGADE -Pete (gloves overhaul)
/*
/obj/item/clothing/gloves/stungloves/
	name = "Stungloves"
	desc = "These gloves are electrically charged."
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0.30
	elecgen = 1
	uses = 10
*/

/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	protective_temperature = 1000
	heat_transfer_coefficient = 0.01
	color="yellow"

/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "fake insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05
	protective_temperature = 800
	heat_transfer_coefficient = null
	color="yellow"

	New()
		siemens_coefficient = pick(0,0,0.25,0.25,0.5,0.5,1)
		heat_transfer_coefficient = pick(0.01,0.1,0.25,0.25,0.5)

/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	color = "captain"

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9

/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	color="orange"

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	color = "red"
	siemens_coefficient = 0.30
	protective_temperature = 1100

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	color = "rainbow"

	clown
		color = "clown"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	color="blue"

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	color="purple"

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	color="green"

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	color="grey"

	rd
		color = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

	hop
		color = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	color="light brown"

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	color="brown"

	cargo
		color = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.

//Fingerless gloves

/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "A pair of gloves. They don't seem to have fingers."
	icon_state = "fingerless_black"
	item_state = "fingerless_black"

/obj/item/clothing/gloves/fingerless/black
	name = "black fingerless gloves"
	desc = "A pair of black gloves. They don't seem to have fingers."
	icon_state = "fingerless_black"
	item_state = "fingerless_black"
	color="black"