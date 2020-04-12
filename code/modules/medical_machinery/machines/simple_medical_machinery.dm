/obj/machinery/medical/simple
	name = "Simple Medical Unit"
	desc = "If you see this something went horrbily, horrbily wrong."
	///What trait do we add while this is on
	var/status
	///What organ do we protect while this is on
	var/organ_slot
	///We remember how much heart support we actually provide
	var/current_boost = 0
	///We remember how much heart support we maximally provide
	var/max_boost = 10
	///Tracked damage of the organ
	var/organ_damage

/obj/machinery/medical/simple/clear_status()
	. = ..()
	REMOVE_TRAIT(attached,status,"mechanical")

	if(!organ_slot)
		return

	attached.adjustOrganLoss(organ_slot,max_boost) //No spamming buckle unbuckle to heal instantly

	return

/obj/machinery/medical/simple/process()
	..()
	if(!attached)
		return
	ADD_TRAIT(attached,status,"mechanical")

	if(!organ_slot)
		return

	organ_damage = attached.getOrganLoss(organ_slot)

	//We calculate how much damage do we need to heal to rach 90 organ damage. Stops working below 90 organ damage.
	current_boost = -max(0,organ_damage + max_boost - STANDARD_ORGAN_THRESHOLD)

	attached.adjustOrganLoss(organ_slot,current_boost)
	return

/obj/machinery/medical/simple/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		active_power_usage /= C.rating

/obj/machinery/medical/simple/liver
	name = "Automated Liver Support System"
	desc = "Stabilizes the liver at the cost of a lot of electricity. Better parts lessen the strain on the power network."
	icon_state = "mechanical_liver"
	status = TRAIT_STABLELIVER
	organ_slot = ORGAN_SLOT_LIVER

/obj/machinery/medical/simple/lung
	name = "Automatic Breath Rejuvanator"
	desc = "Stabilizes the lungs at the cost of a lot of electricity. Better parts lessen the strain on the power network."
	icon_state = "mechanical_lungs"
	status = TRAIT_STABLELUNG
	organ_slot = ORGAN_SLOT_LUNGS

/obj/machinery/medical/simple/heart
	name = "Emergency Heart Stabilizer"
	desc = "Stabilizes the heart at the cost of a lot of electricity. Better parts lessen the strain on the power network."
	icon_state = "mechanical_heart"
	idle_power_usage = 150
	active_power_usage = 1200
	fair_market_price = 100
	status = TRAIT_STABLEHEART
	organ_slot = ORGAN_SLOT_HEART

/obj/machinery/medical/simple/rads
	name = "Lympathic Node Stabilizer"
	desc = "Stabilizes the lymphic nodes preventing damage from radiation poisoning at the cost of a lot of electricity. Better parts lessen the strain on the power network."
	icon_state = "rad_stabilizer"
	status = TRAIT_STABLERADS

