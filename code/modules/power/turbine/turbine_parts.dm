/obj/item/turbine_parts
	name = "turbine parts"
	desc = "you really should call an admin"
	icon = 'icons/obj/turbine/turbine.dmi'
	icon_state = "inlet_compressor"

	var/part_efficiency = 0
	var/part_efficiency_increase_amount = 0

	var/current_tier = 1
	var/max_tier = 4

	var/second_tier_material = /obj/item/stack/sheet/plasteel
	var/second_tier_material_amount = 10

	var/third_tier_material = /obj/item/stack/sheet/mineral/titanium
	var/third_tier_material_amount = 10

	var/fourth_tier_material = /obj/item/stack/sheet/mineral/metal_hydrogen
	var/fourth_tier_material_amount = 5

/obj/item/turbine_parts/attackby(obj/item/attacking_item, mob/user, params)
	if(current_tier >= max_tier)
		return FALSE
	switch(current_tier)
		if(1)
			if(istype(attacking_item, second_tier_material))
				var/obj/item/stack/sheet/second_tier = attacking_item
				if(second_tier.use(second_tier_material_amount) && do_after(user, 1 SECONDS, src))
					current_tier = 2
					part_efficiency += part_efficiency_increase_amount
				return TRUE
		if(2)
			if(istype(attacking_item, third_tier_material))
				var/obj/item/stack/sheet/third_tier = attacking_item
				if(third_tier.use(third_tier_material_amount) && do_after(user, 2 SECONDS, src))
					current_tier = 3
					part_efficiency += part_efficiency_increase_amount
				return TRUE
		if(3)
			if(istype(attacking_item, fourth_tier_material))
				var/obj/item/stack/sheet/fourth_tier = attacking_item
				if(fourth_tier.use(fourth_tier_material_amount) && do_after(user, 3 SECONDS, src))
					current_tier = 4
					part_efficiency += part_efficiency_increase_amount
				return TRUE

	return FALSE

/obj/item/turbine_parts/rotor
	name = "rotor part"
	desc = "Install in a turbine engine rotor to increase it's performances"
	part_efficiency = 0.25
	part_efficiency_increase_amount = 0.2

/obj/item/turbine_parts/compressor
	name = "compressor part"
	desc = "Install in a turbine engine compressor to increase it's performances"
	part_efficiency = 0.25
	part_efficiency_increase_amount = 0.2

/obj/item/turbine_parts/stator
	name = "stator part"
	desc = "Install in a turbine engine turbine to increase it's performances"
	part_efficiency = 0.85
	part_efficiency_increase_amount = 0.015
	second_tier_material = /obj/item/stack/sheet/mineral/titanium
	third_tier_material = /obj/item/stack/sheet/mineral/plastitanium
	fourth_tier_material = /obj/item/stack/sheet/mineral/metal_hydrogen
	second_tier_material_amount = 15
	third_tier_material_amount = 15
	fourth_tier_material_amount = 10
