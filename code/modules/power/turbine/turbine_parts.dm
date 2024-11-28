/obj/item/turbine_parts
	name = "turbine parts"
	desc = "you really should call an admin"
	icon = 'icons/obj/machines/engine/turbine.dmi'
	icon_state = "inlet_compressor"

	///Efficiency of the part to the turbine machine
	var/part_efficiency = 0
	///Efficiency increase amount for each tier
	var/part_efficiency_increase_amount = 0
	///Current part tier
	var/current_tier = TURBINE_PART_TIER_ONE
	///Max rpm reachable by the part
	var/max_rpm = 35000
	///Max temperature achievable by the part before the turbine starts to take damage
	var/max_temperature = 50000

/obj/item/turbine_parts/examine(mob/user)
	. = ..()
	. += span_notice("This is a tier [current_tier] turbine part, rated for [max_rpm] rpm and [max_temperature] K.")

	var/list/required_parts = get_tier_upgrades()
	if(length(required_parts))
		var/obj/item/stack/material = required_parts["part"]
		. += span_notice("Can be upgraded with [required_parts["amount"]] [initial(material.name)] sheets.")
	else
		. += span_notice("Is already at max tier.")

///Returns a list containing the typepath & amount of it required to upgrade to the next tier
/obj/item/turbine_parts/proc/get_tier_upgrades()
	PROTECTED_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)
	RETURN_TYPE(/list)

	switch(current_tier)
		if(TURBINE_PART_TIER_ONE)
			return list("part" = /obj/item/stack/sheet/plasteel, "amount" = 10)
		if(TURBINE_PART_TIER_TWO)
			return list("part" = /obj/item/stack/sheet/mineral/titanium, "amount" = 10)
		if(TURBINE_PART_TIER_THREE)
			return list("part" = /obj/item/stack/sheet/mineral/metal_hydrogen, "amount" = 5)

/obj/item/turbine_parts/item_interaction(mob/living/user, obj/item/attacking_item, list/modifiers)
	. = NONE

	var/list/required_parts = get_tier_upgrades()
	if(!length(required_parts))
		return ITEM_INTERACT_FAILURE

	var/obj/item/stack/sheet/material = attacking_item
	if(!istype(material, required_parts["part"]) || material.amount <= required_parts["amount"])
		return ITEM_INTERACT_FAILURE

	if(do_after(user, current_tier SECONDS, src) && material.use(required_parts["amount"]))
		current_tier += 1
		part_efficiency += part_efficiency_increase_amount
		max_rpm *= 2.5
		max_temperature = max_temperature ** 1.2
		return ITEM_INTERACT_SUCCESS

/obj/item/turbine_parts/compressor
	name = "compressor part"
	desc = "Install in a turbine engine compressor to increase its performance"
	icon_state = "compressor_part"
	part_efficiency = 0.25
	part_efficiency_increase_amount = 0.2

/obj/item/turbine_parts/rotor
	name = "rotor part"
	desc = "Install in a turbine engine rotor to increase its performance"
	icon_state = "rotor_part"
	part_efficiency = 0.25
	part_efficiency_increase_amount = 0.2

/obj/item/turbine_parts/stator
	name = "stator part"
	desc = "Install in a turbine engine turbine to increase its performance"
	icon_state = "stator_part"
	part_efficiency = 0.85
	part_efficiency_increase_amount = 0.015

/obj/item/turbine_parts/stator/get_tier_upgrades()
	switch(current_tier)
		if(TURBINE_PART_TIER_ONE)
			return list("part" = /obj/item/stack/sheet/mineral/titanium, "amount" = 15)
		if(TURBINE_PART_TIER_TWO)
			return list("part" = /obj/item/stack/sheet/mineral/metal_hydrogen, "amount" = 15)
		if(TURBINE_PART_TIER_THREE)
			return list("part" = /obj/item/stack/sheet/mineral/zaukerite, "amount" = 10)
