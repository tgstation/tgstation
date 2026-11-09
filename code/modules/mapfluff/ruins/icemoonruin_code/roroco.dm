/obj/machinery/door/puzzle/keycard/roro
	name = "Fabric Processing"
	desc = "A dusty, scratched door with a thick lock attached."
	puzzle_id = "roroco"

/obj/item/keycard/roro
	name = "Fabric Processing keycard"
	desc = ""
	color = "#b1634c"
	puzzle_id = "roroco"

/area/ruin/roroco
	name = "\improper RoroCo Primary Hallway"

/area/ruin/roroco/management
	name = "\improper RoroCo Management Office"

/area/ruin/roroco/packing
	name = "\improper RoroCo Packing Room"

/area/ruin/roroco/extraction
	name = "\improper RoroCo Product Extraction"

/area/ruin/roroco/harvesting
	name = "\improper RoroCo Harvesting Room"

/area/ruin/roroco/maintenance
	name = "\improper RoroCo Maintenance Hallway"

/area/ruin/roroco/janitor
	name = "\improper RoroCo Janitor's Closet"

/obj/item/card/id/away/roroco
	name = "\improper RoroCo ID Card"
	desc = "A plastic card that identifies its bearer as an employee of RoroCo. There are electronic chips embedded to communicate with airlocks and other machines. It does not have a name attached."
	icon_state = "card_roro"
	trim = /datum/id_trim/away/roroco

/obj/item/card/id/away/roroco/boss
	desc = "A plastic card that identifies its bearer as a senior employee of RoroCo with enhanced access to secure areas. There are electronic chips embedded to communicate with airlocks and other machines. It does not have a name attached."
	icon_state = "card_roroboss"
	trim = /datum/id_trim/away/roroco/boss

/obj/structure/closet/cardboard/roroco
	icon_state = "cardboard_roroco"

/obj/item/clothing/suit/toggle/labcoat/roroco
	name = "\improper RoroCo labcoat"
	desc = "A suit that protects against minor chemical spills, though the deep red colour makes them hard to see. Great for hiding blood stains, though..."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/roroco"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#88242D#39393F#39393F#39393F"

/obj/item/clothing/under/costume/buttondown/slacks/roroco
	icon_state = "/obj/item/clothing/under/costume/buttondown/slacks/roroco"
	greyscale_colors = "#FFCCCC#17171B#17171B#88242D"

/datum/outfit/roroco
	name = "RoroCo Glove Packer"
	gloves = /obj/item/clothing/gloves/cargo_gauntlet
	shoes = /obj/item/clothing/shoes/workboots
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/roroco
	suit = /obj/item/clothing/suit/hazardvest

/datum/outfit/roroco/processing
	name = "Roroco Fabric Technician"
	glasses = /obj/item/clothing/glasses/science
	gloves = /obj/item/clothing/gloves/latex/nitrile
	suit = /obj/item/clothing/suit/toggle/labcoat/roroco
	id = /obj/item/card/id/away/roroco/boss

/obj/effect/mob_spawn/corpse/human/roroco_packing
	name = "Dead RoroCo Glove Packer"
	mob_name = "Nameless Glove Packer"
	outfit = /datum/outfit/roroco

/obj/effect/mob_spawn/corpse/human/roroco_processing
	name = "Dead Roroco Fabric Technician"
	mob_name = "Nameless Fabric Technician"
	outfit = /datum/outfit/roroco/processing
