/*
transformative extracts:
	When fed three monkey cubes, produces between
	1 and 4 normal slime extracts of the same colour.
*/
/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It pulses with a strange hunger."
	icon_state = "transformative"
	effect = "transformative"
	effect_desc = ""

/obj/item/slimecross/transformative/attackby(obj/item/O, mob/user)



/obj/item/slimecross/transformative/grey
	extract_type = /obj/item/slime_extract/grey
	colour = "grey"

/obj/item/slimecross/transformative/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"

/obj/item/slimecross/transformative/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"

/obj/item/slimecross/transformative/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"

/obj/item/slimecross/transformative/metal //add 1.5x max health as well
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"

/obj/item/slimecross/transformative/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"

/obj/item/slimecross/transformative/darkpurple //set cores to 5
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"

/obj/item/slimecross/transformative/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"

/obj/item/slimecross/transformative/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"

/obj/item/slimecross/transformative/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"

/obj/item/slimecross/transformative/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"

/obj/item/slimecross/transformative/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"

/obj/item/slimecross/transformative/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"

/obj/item/slimecross/transformative/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"

/obj/item/slimecross/transformative/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"

/obj/item/slimecross/transformative/pink //owner.grant_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"

/obj/item/slimecross/transformative/gold //turn off the xenobio.dm in cargo when done
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"

/obj/item/slimecross/transformative/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"

/obj/item/slimecross/transformative/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"

/obj/item/slimecross/transformative/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"

/obj/item/slimecross/transformative/adamantine //REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"

/obj/item/slimecross/transformative/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
