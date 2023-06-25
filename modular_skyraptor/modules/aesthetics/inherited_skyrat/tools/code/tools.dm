/obj/item/weldingtool
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/obj/item/crowbar
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/obj/item/crowbar/power
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/crowbar/power/syndicate	//Because we have a clearly different color JOL than upstream, this needs to be specifically different now
	inhand_icon_state = "jaws_syndie"

/obj/item/crowbar/large/heavy
	icon = 'icons/obj/tools.dmi'

/obj/item/crowbar/large/old
	icon = 'icons/obj/tools.dmi'

/obj/item/wrench
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/obj/item/wrench/caravan
	icon = 'icons/obj/tools.dmi'

/obj/item/screwdriver/power
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/construction/plumbing //This icon override NEEDS to be here for the subtypes
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/obj/item/construction/rcd/arcd
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/obj/item/inducer
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/pipe_dispenser
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/construction/rcd
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/construction/rld
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/screwdriver
	var/static/list/screwdriver_colors_rapt = list("#AAFF00", "#FF6600", "#6600FF", "#0066FF", "#FFFF00", "#FF0000")

/obj/item/screwdriver/Initialize(mapload)
	. = ..()
	if(random_color)
		set_greyscale(colors = list(pick(screwdriver_colors_rapt)))

/obj/item/wirecutters
	var/static/list/wirecutter_colors_rapt = list("#AAFF00", "#FF6600", "#6600FF", "#0066FF", "#FFFF00", "#FF0000")

/obj/item/wirecutters/Initialize(mapload)
	. = ..()
	if(random_color)
		set_greyscale(colors = list(pick(wirecutter_colors_rapt)))



/datum/greyscale_config/screwdriver
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/datum/greyscale_config/wirecutters
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
