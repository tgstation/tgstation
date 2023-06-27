/obj/item/weldingtool
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/obj/item/crowbar
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	belt_icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_onbelt.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/obj/item/crowbar/red
	greyscale_config = /datum/greyscale_config/crowbar
	greyscale_config_belt = /datum/greyscale_config/crowbar_belt_overlay
	greyscale_config_inhand_left = /datum/greyscale_config/crowbar_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/crowbar_inhand_right
	var/static/list/crowbar_colors = list("#AAFF00", "#FF6600", "#6600FF", "#0066FF", "#FFFF00", "#FF0000")

/obj/item/crowbar/red/Initialize(mapload)
	. = ..()
	set_greyscale(colors = list(pick(crowbar_colors)))

/obj/item/crowbar/power/syndicate	//Because we have a clearly different color JOL than upstream, this needs to be specifically different now
	inhand_icon_state = "jaws_syndie"

/obj/item/crowbar/large/heavy
	icon = 'icons/obj/tools.dmi'

/obj/item/crowbar/large/old
	icon = 'icons/obj/tools.dmi'

/obj/item/wrench
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	belt_icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_onbelt.dmi'

/obj/item/wrench/caravan
	icon = 'icons/obj/tools.dmi'

/obj/item/screwdriver/power
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'
	belt_icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_onbelt.dmi'

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

/obj/item/construction/rtd
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

/obj/item/fireaxe
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'

/*
 * Bespoke Cinder-Swimmer fireaxe, a hidden goodie.
 */
/obj/item/fireaxe/cinderaxe
	icon_state = "cinderaxe0"
	base_icon_state = "cinderaxe"
	name = "rugged fireaxe"
	desc = "An old Terran fireaxe, worn but well maintained, with a faint smell of copper and ozone about it.  It feels strangely reassuring in your hands, as if it could solve any problem you faced."
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	usesound = 'sound/items/crowbar.ogg'



/datum/greyscale_config/screwdriver
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'

/datum/greyscale_config/wirecutters
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'



/datum/greyscale_config/crowbar
	name = "Crowbar"
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools.dmi'
	json_config = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/greyscale/crowbar.json'

/datum/greyscale_config/crowbar_belt_overlay
	name = "Crowbar Belt Worn Icon"
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_onbelt.dmi'
	json_config = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/greyscale/crowbar.json'

/datum/greyscale_config/crowbar_inhand_left
	name = "Held Crowbar, Left"
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_lefthand.dmi'
	json_config = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/greyscale/crowbar_worn.json'

/datum/greyscale_config/crowbar_inhand_right
	name = "Held Crowbar, Right"
	icon_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/tools_righthand.dmi'
	json_config = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/tools/greyscale/crowbar_worn.json'
