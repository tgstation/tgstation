///We pump liquids from activated(plungerated) geysers to a plumbing outlet. We need to be wired.
/obj/machinery/plumbing/liquid_pump
	name = "liquid pump"
	desc = "Pump up those sweet liquids from under the surface. Uses thermal energy from geysers to power itself." //better than placing 200 cables, because it wasnt fun
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	density = TRUE
	idle_power_usage = 10
	active_power_usage = 1000

	rcd_cost = 30
	rcd_delay = 40

	///units we pump per process (2 seconds)
	var/pump_power = 2
	///set to true if the loop couldnt find a geyser in process, so it remembers and stops checking every loop until moved. more accurate name would be absolutely_no_geyser_under_me_so_dont_try
	var/geyserless = FALSE
	///The geyser object
	var/obj/structure/geyser/geyser
	///volume of our internal buffer
	var/volume = 200

/obj/machinery/plumbing/liquid_pump/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)

///please note that the component has a hook in the parent call, wich handles activating and deactivating
/obj/machinery/plumbing/liquid_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		geyser = null
		update_icon()
		geyserless = FALSE //we switched state, so lets just set this back aswell

/obj/machinery/plumbing/liquid_pump/process()
	if(!anchored || panel_open || geyserless)
		return

	if(!geyser)
		for(var/obj/structure/geyser/G in loc.contents)
			geyser = G
			update_icon()
		if(!geyser) //we didnt find one, abort
			geyserless = TRUE
			visible_message("<span class='warning'>The [name] makes a sad beep!</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			return

	pump()

///pump up that sweet geyser nectar
/obj/machinery/plumbing/liquid_pump/proc/pump()
	if(!geyser || !geyser.reagents)
		return
	geyser.reagents.trans_to(src, pump_power)

/obj/machinery/plumbing/liquid_pump/update_icon_state()
	if(geyser)
		icon_state = initial(icon_state) + "-on"
	else if(panel_open)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)
