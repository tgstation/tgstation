/obj/item/biopsy_tool
	name = "biopsy tool"
	desc = "Don't worry, it won't sting."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"

/obj/item/biopsy_tool/Initialize()
	. = ..()
	AddComponent(/datum/component/swabbing, TRUE, TRUE, TRUE)



