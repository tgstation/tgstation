/obj/machinery/power/liquid_pump
	name = "liquid pump"
	desc = "Pump up those sweet liquids from under the surface."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/pump
	idle_power_usage = 10
	active_power_usage = 1000

	var/powered = FALSE
	var/pump_power = 2 //units we pump per process (2 seconds)

	var/obj/structure/geyser/geyser
	var/volume = 200

/obj/machinery/power/liquid_pump/Initialize()
	create_reagents(volume)
	return ..()

/obj/machinery/power/liquid_pump/ComponentInitialize()
	AddComponent(/datum/component/plumbing/simple_supply, TRUE)

/obj/machinery/power/liquid_pump/attackby(obj/item/W, mob/user, params)
	if(!powered)
		if(!anchored)
			if(default_deconstruction_screwdriver(user, "[initial(icon_state)]_open", "[initial(icon_state)]",W))
				return
		if(default_deconstruction_crowbar(W))
			return
	return ..()

/obj/machinery/power/liquid_pump/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/power/liquid_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		toggle_active()

/obj/machinery/power/liquid_pump/proc/toggle_active(mob/user, obj/item/I) //we split this in a seperate proc so we can also deactivate if we got no geyser under us
	geyser = null
	if(user)
		user.visible_message("<span class='notice'>[user.name] [anchored ? "fasten" : "unfasten"] [src]</span>", \
		"<span class='notice'>You [anchored ? "fasten" : "unfasten"] [src]</span>")
	var/datum/component/plumbing/P = GetComponent(/datum/component/plumbing)
	if(anchored)
		P.start()
		connect_to_network()
	else
		P.disable()
		disconnect_from_network()
	update_icon()

/obj/machinery/power/liquid_pump/process()
	if(!anchored || panel_open)
		return
	if(!geyser)
		for(var/obj/structure/geyser/G in loc.contents)
			geyser = G
		if(!geyser) //we didnt find one, abort
			anchored = FALSE
			toggle_active()
			visible_message("<span class='warning'>The [name] makes a sad beep!</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			return

	if(avail(active_power_usage))
		if(!powered) //we werent powered before this tick so update our sprite
			powered = TRUE
			update_icon()
		add_load(active_power_usage)
		pump()
	else if(powered) //we were powered, but now we arent
		powered = FALSE
		update_icon()

/obj/machinery/power/liquid_pump/proc/pump()
	if(!geyser || !geyser.reagents)
		return
	geyser.reagents.trans_to(src, pump_power)

/obj/machinery/power/liquid_pump/update_icon()
	if(powered)
		icon_state = initial(icon_state) + "-on"
	else if(panel_open)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)