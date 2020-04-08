/obj/machinery/medical/dialysis
	name = "Direct Blood Filtration Unit"
	desc = "Automatically filtrates your blood from all chemicals."
	icon_state = "dialysis"
	///Amount of purged chems per process
	var/purge_amount = 3

/obj/machinery/medical/dialysis/RefreshParts()
	var/change = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		change += C.rating
	purge_amount = initial(purge_amount) * change
	return

/obj/machinery/medical/dialysis/process()
	. = ..()
	if(attached)
		for(var/R in attached.reagents.reagent_list)
			var/datum/reagent/r1 = R
			attached.reagents.remove_reagent(r1.type, purge_amount)
	return

/obj/machinery/medical/plasmic_stabilizer
	name = "Automated Inorganic Lifeform Stabilizer"
	desc = "Stabilizes free plasma particles in inorganic bodies, causing them to not burn. Uses massive amounts of electricity."
	icon_state = "plasmic_stabilizer"
	active_power_usage = 1500

/obj/machinery/medical/plasmic_stabilizer/RefreshParts()
	var/change = 0
	for(var/obj/item/stock_parts/micro_laser/ML in component_parts)
		change + ML.rating
	active_power_usage = initial(active_power_usage) / change
	return

/obj/machinery/medical/plasmic_stabilizer/clear_status()
	. = ..()
	REMOVE_TRAIT(attached,TRAIT_STABLEPLASMA,"plasmic_stabilizer")
	return

/obj/machinery/medical/plasmic_stabilizer/process()
	. = ..()

	if(!isplasmaman(attached) || !attached)
		attached = null
		return

	ADD_TRAIT(attached,TRAIT_STABLEPLASMA,"plasmic_stabilizer")
	return

/obj/machinery/medical/plasmic_stabilizer/defunct
	name = "Old Inorganic Lifeform Stabilizer"
	desc = "Stabilizes free plasma particles in inorganic bodies, causing them to not burn. Uses massive amounts of electricity.This model seems to be very old."
	icon_state = "plasmic_stabilizer_defunct"
	active_power_usage = 2000 //very old inefficient model

/obj/machinery/medical/plasmic_stabilizer/defunct/process()
	if(prob(5)) //doesn't work sometimes
		clear_status()
		return
	. = ..()

/obj/machinery/medical/thermal
	name = "Thermal Stabilizer"
	desc = "Stabilizes free plasma particles in inorganic bodies, causing them to not burn. Uses massive amounts of electricity.This model seems to be very old."
	icon_state = "thermal_stabilizer"
	var/stabilization_rate = 10

/obj/machinery/medical/thermal/RefreshParts()
	var/change = 0
	for(var/obj/item/stock_parts/micro_laser/ML in component_parts)
		change += ML.rating
	stabilization_rate = initial(stabilization_rate) * change
	return

/obj/machinery/medical/thermal/process()
	. = ..()
	if(attached)
		var/tempdiff = attached.get_body_temp_normal() - attached.bodytemperature
		switch(tempdiff)
			if(stabilization_rate to INFINITY)
				attached.adjust_bodytemperature(stabilization_rate)
			if(1 to stabilization_rate)
				attached.adjust_bodytemperature(tempdiff)
			if(-1 to -stabilization_rate)
				attached.adjust_bodytemperature(-tempdiff)
			if(-INFINITY to -stabilization_rate)
				attached.adjust_bodytemperature(-stabilization_rate)
	return
