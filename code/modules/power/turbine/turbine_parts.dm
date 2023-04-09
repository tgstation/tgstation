/obj/item/turbine_parts
	name = "turbine parts"
	desc = "you really should call an admin"
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "inlet_compressor"

	///Efficiency of the part to the turbine machine
	var/part_efficiency = 0
	///Efficiency increase amount for each tier
	var/part_efficiency_increase_amount = 0

	///Current part tier
	var/current_tier = TURBINE_PART_TIER_ONE
	///Max part tier
	var/max_tier = TURBINE_PART_TIER_FOUR

	///Stores the path of the material for the second tier upgrade
	var/obj/item/stack/sheet/second_tier_material = /obj/item/stack/sheet/plasteel
	///Amount of second tier material for the upgrade
	var/second_tier_material_amount = 10

	///Stores the path of the material for the third tier upgrade
	var/obj/item/stack/sheet/third_tier_material = /obj/item/stack/sheet/mineral/titanium
	///Amount of third tier material for the upgrade
	var/third_tier_material_amount = 10

	///Stores the path of the material for the fourth tier upgrade
	var/obj/item/stack/sheet/fourth_tier_material = /obj/item/stack/sheet/mineral/metal_hydrogen
	///Amount of fourth tier material for the upgrade
	var/fourth_tier_material_amount = 5

	///Max rpm reachable by the part
	var/max_rpm = 35000
	///Multiplier to increase the max rpm per tier, max should be around 500000 rpm
	var/max_rpm_tier_multiplier = 2.5

	///Max temperature achievable by the part before the turbine starts to take damage
	var/max_temperature = 50000
	///Max temperature exponential value per tier
	var/max_temperature_tier_exponential = 1.2

/obj/item/turbine_parts/examine(mob/user)
	. = ..()
	. += "This is a tier [current_tier] turbine part, rated for [max_rpm] rpm and [max_temperature] K."
	var/upgrade_material_name_amount
	switch(current_tier)
		if(TURBINE_PART_TIER_ONE)
			upgrade_material_name_amount = "[second_tier_material_amount] [initial(second_tier_material.name)] sheets"
		if(TURBINE_PART_TIER_TWO)
			upgrade_material_name_amount = "[third_tier_material_amount] [initial(third_tier_material.name)] sheets"
		if(TURBINE_PART_TIER_THREE)
			upgrade_material_name_amount = "[fourth_tier_material_amount] [initial(fourth_tier_material.name)] sheets"

	if(upgrade_material_name_amount)
		. += "Can be upgraded with [upgrade_material_name_amount]."
	else
		. += "Is already at max tier."

/obj/item/turbine_parts/attackby(obj/item/attacking_item, mob/user, params)
	if(current_tier >= max_tier)
		return FALSE
	switch(current_tier)
		if(TURBINE_PART_TIER_ONE)
			if(!istype(attacking_item, second_tier_material))
				return
			var/obj/item/stack/sheet/second_tier = attacking_item
			if(second_tier.use(second_tier_material_amount) && do_after(user, 1 SECONDS, src))
				current_tier = 2
				part_efficiency += part_efficiency_increase_amount
				max_rpm *= max_rpm_tier_multiplier
				max_temperature = max_temperature ** max_temperature_tier_exponential
			return TRUE
		if(TURBINE_PART_TIER_TWO)
			if(!istype(attacking_item, third_tier_material))
				return
			var/obj/item/stack/sheet/third_tier = attacking_item
			if(third_tier.use(third_tier_material_amount) && do_after(user, 2 SECONDS, src))
				current_tier = 3
				part_efficiency += part_efficiency_increase_amount
				max_rpm *= max_rpm_tier_multiplier
				max_temperature = max_temperature ** max_temperature_tier_exponential
			return TRUE
		if(TURBINE_PART_TIER_THREE)
			if(!istype(attacking_item, fourth_tier_material))
				return
			var/obj/item/stack/sheet/fourth_tier = attacking_item
			if(fourth_tier.use(fourth_tier_material_amount) && do_after(user, 3 SECONDS, src))
				current_tier = 4
				part_efficiency += part_efficiency_increase_amount
				max_rpm *= max_rpm_tier_multiplier
				max_temperature = max_temperature ** max_temperature_tier_exponential
			return TRUE

	return ..()

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
	second_tier_material = /obj/item/stack/sheet/mineral/titanium
	third_tier_material = /obj/item/stack/sheet/mineral/metal_hydrogen
	fourth_tier_material = /obj/item/stack/sheet/mineral/zaukerite
	second_tier_material_amount = 15
	third_tier_material_amount = 15
	fourth_tier_material_amount = 10
