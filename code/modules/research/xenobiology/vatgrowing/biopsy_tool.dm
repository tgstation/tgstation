///Tool capable of taking biological samples from mobs
/obj/item/biopsy_tool
	name = "biopsy tool"
	desc = "Don't worry, it won't sting."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"

///Adds the swabbing component to the biopsy tool
/obj/item/biopsy_tool/Initialize()
	. = ..()
	AddComponent(/datum/component/swabbing, TRUE, TRUE, TRUE)



