/obj/item/clothing/gloves/color/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	mob_overlay_state="yellow"
	resistance_flags = NONE

/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap knockoffs of the coveted ones - no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in Initialize()
	permeability_coefficient = 0.05
	mob_overlay_state = "yellow"
	resistance_flags = NONE

/obj/item/clothing/gloves/color/fyellow/Initialize()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/Initialize()
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/color/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "blackgloves"
	mob_overlay_state="black"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	var/can_be_cut = 1

/obj/item/clothing/gloves/color/black/hos
	mob_overlay_state = "hosred"	//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/ce
	mob_overlay_state = "chief"		//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(can_be_cut && icon_state == initial(icon_state))//only if not dyed
			to_chat(user, "<span class='notice'>You snip the fingertips off of [src].</span>")
			I.play_tool_sound(src)
			new /obj/item/clothing/gloves/fingerless(drop_location())
			qdel(src)
	..()

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	mob_overlay_state="orange"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	mob_overlay_state = "red"


/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves will protect the wearer from electric shock."
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	mob_overlay_state = "rainbow"

/obj/item/clothing/gloves/color/rainbow/clown
	mob_overlay_state = "clown"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	mob_overlay_state="blue"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	mob_overlay_state="purple"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	mob_overlay_state="green"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	mob_overlay_state="grey"

/obj/item/clothing/gloves/color/grey/rd
	mob_overlay_state = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/grey/hop
	mob_overlay_state = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	mob_overlay_state="light brown"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	mob_overlay_state="brown"

/obj/item/clothing/gloves/color/brown/cargo
	mob_overlay_state = "cargo"					//Exists for washing machines. Is not different from brown gloves in any way.

/obj/item/clothing/gloves/color/captain
	desc = "Regal blue gloves, with a nice gold trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	mob_overlay_state = "captain"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 50)

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.3
	permeability_coefficient = 0.01
	mob_overlay_state="mime"
	transfer_prints = TRUE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are stronger than latex."
	icon_state = "nitrile"
	item_state = "nitrilegloves"
	mob_overlay_state = "cmo"
	transfer_prints = FALSE

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "wgloves"
	mob_overlay_state="white"

/obj/item/clothing/gloves/color/white/redcoat
	mob_overlay_state = "redcoat"		//Exists for washing machines. Is not different from white gloves in any way.

/obj/effect/spawner/lootdrop/gloves
	name = "random gloves"
	desc = "These gloves are supposed to be a random color..."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "random_gloves"
	loot = list(
		/obj/item/clothing/gloves/color/orange = 1,
		/obj/item/clothing/gloves/color/red = 1,
		/obj/item/clothing/gloves/color/blue = 1,
		/obj/item/clothing/gloves/color/purple = 1,
		/obj/item/clothing/gloves/color/green = 1,
		/obj/item/clothing/gloves/color/grey = 1,
		/obj/item/clothing/gloves/color/light_brown = 1,
		/obj/item/clothing/gloves/color/brown = 1,
		/obj/item/clothing/gloves/color/white = 1,
		/obj/item/clothing/gloves/color/rainbow = 1)
