/obj/item/clothing/suit/toggle/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat"
	icon = 'icons/obj/clothing/suits/labcoat.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat.dmi'
	inhand_icon_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	armor_type = /datum/armor/toggle_labcoat
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/cmo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -2) //FISH DOCTOR?!

/datum/armor/toggle_labcoat
	bio = 50
	fire = 50
	acid = 50

/obj/item/clothing/suit/toggle/labcoat/paramedic
	name = "paramedic's jacket"
	desc = "A dark blue jacket for paramedics with reflective stripes."
	icon_state = "labcoat_paramedic"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/paramedic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -2) //FISH DOCTOR?!

/obj/item/clothing/suit/toggle/labcoat/mad
	name = "\proper The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#4A77A1#4A77A1#7095C2"

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#F17420#F17420#EB6F2C"

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a green stripe on the shoulder."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#198019#198019#40992E"

/obj/item/clothing/suit/toggle/labcoat/coroner
	name = "coroner labcoat"
	desc = "A suit that protects against minor chemical spills. Has a black stripe on the shoulder."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#2D2D33#2D2D33#39393F"

/obj/item/clothing/suit/toggle/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#7E1980#7E1980#B347A1"

/obj/item/clothing/suit/toggle/labcoat/roboticist
	name = "roboticist labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#88242D#88242D#39393F"

/obj/item/clothing/suit/toggle/labcoat/interdyne
	name = "interdyne labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#88242D#88242D#39393F"

// Research Director

/obj/item/clothing/suit/toggle/labcoat/research_director
	name = "research director's coat"
	desc = "A mix between a labcoat and just a regular coat. It's made out of a special anti-bacterial, anti-acidic, and anti-biohazardous synthetic fabric."
	icon_state = "labcoat_rd"
	armor_type = /datum/armor/jacket_research_director
	body_parts_covered = CHEST|GROIN|ARMS

/datum/armor/jacket_research_director
	bio = 75
	fire = 75
	acid = 75
