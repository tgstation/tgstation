///We pump liquids from activated(plungerated) geysers to a plumbing outlet. We need to be wired.
/obj/structure/chemical_input/liquid_pump
	name = "geyser pump"
	desc = "Pump up those sweet liquids from under the surface. Uses thermal energy from geysers to power itself." //better than placing 200 cables, because it wasn't fun
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	base_icon_state = "pump"
	reagent_flags = TRANSPARENT | DRAINABLE
	component_name = "Geyser Input"

	///units we pump per second
	var/pump_power = 1
	///set to true if the loop couldnt find a geyser in process, so it remembers and stops checking every loop until moved. more accurate name would be absolutely_no_geyser_under_me_so_dont_try
	var/geyserless = FALSE
	///The geyser object
	var/obj/structure/geyser/geyser

/obj/structure/chemical_input/liquid_pump/Initialize(mapload, bolt, layer)
	. = ..()
	START_PROCESSING(SSmachines, src)

/obj/structure/chemical_input/liquid_pump/Destroy()
	. = ..()
	STOP_PROCESSING(SSmachines, src)

/obj/structure/chemical_input/liquid_pump/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.tool_behaviour == TOOL_WRENCH)
		if(attacking_item.use_tool(src, user, 40, volume=75))
			to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
			set_anchored(!anchored)
			geyser = null
			return
	. = ..()

/obj/structure/chemical_input/liquid_pump/process(seconds_per_tick)
	if(!anchored || geyserless)
		return

	if(!geyser)
		for(var/obj/structure/geyser/G in loc.contents)
			geyser = G
			update_appearance()
		if(!geyser) //we didnt find one, abort
			geyserless = TRUE
			visible_message(span_warning("The [name] makes a sad beep!"))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			return

	pump(seconds_per_tick)

///pump up that sweet geyser nectar
/obj/structure/chemical_input/liquid_pump/proc/pump(seconds_per_tick)
	if(!geyser || !geyser.reagents)
		return
	geyser.reagents.trans_to(src, pump_power * seconds_per_tick)

/obj/structure/chemical_input/liquid_pump/update_icon_state()
	if(geyser)
		icon_state = "[base_icon_state]-on"
		return ..()
	icon_state = "[base_icon_state]"
	return ..()
