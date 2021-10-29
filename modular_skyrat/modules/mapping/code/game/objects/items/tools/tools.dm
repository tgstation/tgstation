//WRENCHES//
/obj/item/wrench/advanced
	name = "advanced wrench"
	desc = "A wrench that uses the same magnetic technology that abductor tools use, but slightly more ineffeciently. It looks cobbled together."
	icon = 'modular_skyrat/modules/mapping/icons/obj/items/advancedtools.dmi'
	icon_state = "wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.2

//WIRECUTTERS//
/obj/item/wirecutters/advanced
	name = "advanced wirecutters"
	desc = "A set of reproduction alien wirecutters, they have a silver handle with an exceedingly sharp blade. There's a sticker attached declaring that it needs updating from 'the latest samples'."
	icon = 'modular_skyrat/modules/mapping/icons/obj/items/advancedtools.dmi'
	icon_state = "cutters"
	toolspeed = 0.2
	random_color = FALSE

//WELDING TOOLS//
/obj/item/weldingtool/advanced
	name = "advanced welding tool"
	desc = "A modern, experimental welding tool combined with an alien welding tool's generation methods, it never runs out of fuel and works almost as fast."
	icon = 'modular_skyrat/modules/mapping/icons/obj/items/advancedtools.dmi'
	icon_state = "welder"
	toolspeed = 0.2
	light_system = NO_LIGHT_SUPPORT
	light_range = 0
	change_icons = 0

/obj/item/weldingtool/advanced/process()
	if(get_fuel() <= max_fuel)
		reagents.add_reagent(/datum/reagent/fuel, 1)
	..()

//SCREWDRIVERS//
/obj/item/screwdriver/advanced
	name = "advanced screwdriver"
	desc = "A classy silver screwdriver with an alien alloy tip, it works almost as well as the real thing. There's a sticker attached declaring that it needs updating from 'the latest samples'."
	icon = 'modular_skyrat/modules/mapping/icons/obj/items/advancedtools.dmi'
	icon_state = "screwdriver_a"
	inhand_icon_state = "screwdriver_nuke"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.2
	random_color = FALSE
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null

//CROWBAR//
/obj/item/crowbar/advanced
	name = "advanced crowbar"
	desc = "A scientist's almost successful reproduction of an abductor's crowbar, it uses the same technology combined with a handle that can't quite hold it."
	icon = 'modular_skyrat/modules/mapping/icons/obj/items/advancedtools.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.2

//MULTITOOLS//
/obj/item/multitool/advanced
	name = "advanced multitool"
	desc = "The reproduction of an abductor's multitool, this multitool is a classy silver. There's a sticker attached declaring that it needs updating from 'the latest samples'."
	icon = 'modular_skyrat/modules/mapping/icons/obj/items/advancedtools.dmi'
	icon_state = "multitool"
	toolspeed = 0.2
