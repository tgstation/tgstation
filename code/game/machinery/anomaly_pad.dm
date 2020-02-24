/obj/machinery/anomaly_pad
	name = "anomaly pad"
	desc = "If an anomaly core is applied, this machine will keep it stable and suspended. Looks beautiful and cannot possibly go wrong."

	icon = 'icons/obj/machines/anomaly_pad.dmi'
	icon_state = "pad"

	circuit = /obj/item/circuitboard/machine/anomaly_pad
	density = TRUE

	use_power = IDLE_POWER_USE
	power_channel = EQUIP

	///this is the big beautiful anomaly floating ontop of us
	var/obj/effect/anomaly/anomaly
	var/base_power = 500

/obj/machinery/anomaly_pad/RefreshParts()
	..()

	var/obj/item/stock_parts/micro_laser/L = locate(/obj/item/stock_parts/micro_laser) in contents

	if(L)
		active_power_usage = base_power / L.rating
		idle_power_usage = active_power_usage * 0.1

/obj/machinery/anomaly_pad/attackby(obj/item/I, mob/living/user, params)

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon_state()
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(!anomaly && istype(I, /obj/item/assembly/signaler/anomaly) && user.dropItemToGround(I) && IsAnomalyApplicable(I, user))
		CaptureAnomaly(I)
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE)
		return

	. = ..()

/obj/machinery/anomaly_pad/process()
	if(anomaly && (!is_operational() || get_turf(src) != get_turf(anomaly)))
		ReleaseAnomaly()
		return FALSE //uuhhh dont know if its ok but im using this to see if the check passed on the subtype

	return TRUE

///Spawn an anomaly from an anomaly core and suspend it ''''''''''safely''''''''''' on us
/obj/machinery/anomaly_pad/proc/CaptureAnomaly(obj/item/assembly/signaler/anomaly/S)
	anomaly = S.ReviveAnomaly(get_turf(src))
	anomaly.Suspend()
	use_power = ACTIVE_POWER_USE

///let them loose into the world to reign havoc once more
/obj/machinery/anomaly_pad/proc/ReleaseAnomaly()
	anomaly.Unsuspend()
	anomaly = null
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	use_power = IDLE_POWER_USE

///Check if an anomaly is applicable. Example is the chemical pad only accepting fluescent anomalies
/obj/machinery/anomaly_pad/proc/IsAnomalyApplicable(obj/item/assembly/signaler/anomaly/S, mob/living/user)
	return TRUE

/obj/machinery/anomaly_pad/Destroy()
	if(anomaly)
		ReleaseAnomaly()
	return ..()

/obj/machinery/anomaly_pad/update_icon()
	. = ..()

	icon_state = initial(icon_state) + (!powered(EQUIP) ? "-off" : "")

/obj/machinery/anomaly_pad/update_overlays()
	. = ..()
	if(panel_open)
		. += initial(icon_state) + "-panel"

/obj/machinery/anomaly_pad/power_change()
	. = ..()

	update_icon_state()

/obj/machinery/anomaly_pad/liquid
	name = "chemical anomaly pad"
	desc = "Drains a fluescent anomolies imprinted reagent with extreme efficiency."

	icon_state = "pad" //unique icon

	circuit = /obj/item/circuitboard/machine/anomaly_pad_liquid

	var/volume = 1000
	var/speed = 100
	var/reagent_type //alright, it'd be gross to make another anomaly var for the fluescent anom, so just track the reagent_type here

/obj/machinery/anomaly_pad/liquid/Initialize()
	. = ..()
	create_reagents(volume)
	AddComponent(/datum/component/plumbing/simple_supply, anchored)

/obj/machinery/anomaly_pad/liquid/process()
	. = ..()
	if(!.)
		return

	reagents.add_reagent(reagent_type, speed)

/obj/machinery/anomaly_pad/liquid/CaptureAnomaly(obj/item/assembly/signaler/anomaly/fluid/S)
	..(S)
	reagent_type = S.reagent_type

/obj/machinery/anomaly_pad/liquid/IsAnomalyApplicable(obj/item/assembly/signaler/anomaly/S, mob/living/user)
	if(!istype(S, /obj/item/assembly/signaler/anomaly/fluid))
		to_chat(user, "<span class'warning'>This is not a fluescent anomaly!")
		return FALSE
	return TRUE
