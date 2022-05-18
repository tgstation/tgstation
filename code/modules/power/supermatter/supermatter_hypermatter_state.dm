/obj/machinery/power/supermatter_crystal/proc/handle_hypermatter_state()

	var/static/list/angles = list(0, 45, 90, 135, 180, 225, 270, 315, 360)

	if(power)
		power = max(power - 30, 0)

		for(var/_ in 1 to rand(2, 4))
			if(hypermatter_power_amount < 1000)
				break
			var/angle_to_shoot = pick(angles)
			fire_nuclear_particle(angle_to_shoot, 1.2, 1000)
			hypermatter_power_amount = max(hypermatter_power_amount - 100, 0)
	else
		hypermatter_power_amount = max(hypermatter_power_amount - 100, 0)


	if(prob(5))
		fire_nuclear_particle()

		supermatter_zap(
				zapstart = src,
				range = 3,
				zap_str = 5 * power,
				zap_flags = ZAP_SUPERMATTER_FLAGS,
				zap_cutoff = 300,
				power_level = power,
			)

	if(hypermatter_power_amount < 1000)
		hypermatter_cooldown -= 5 SECONDS

/obj/machinery/power/energy_accumulator/nuclear_accumulator
	name = "nuclear accumulator"
	desc = "A large, powerful nuclear accumulator. It is capable of storing a large amount of power."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "nuclear_accumulator"
	circuit = /obj/item/circuitboard/machine/tesla_coil

/obj/machinery/power/energy_accumulator/nuclear_accumulator/bullet_act(obj/projectile/projectile)
	if(!istype(projectile, /obj/projectile/energy/nuclear_particle) || projectile.dir != turn(dir, 180))
		return ..()

	var/obj/projectile/energy/nuclear_particle/particle = projectile
	stored_energy += joules_to_energy((particle.internal_power) * 400)

/obj/machinery/power/energy_accumulator/nuclear_accumulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/energy_accumulator/nuclear_accumulator/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	default_change_direction_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/energy_accumulator/nuclear_accumulator/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_crowbar(tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/energy_accumulator/nuclear_accumulator/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS
