/obj/machinery/power/energy_accumulator/nuclear_accumulator
	name = "nuclear accumulator"
	desc = "A large, powerful nuclear accumulator. It is capable of storing a large amount of power."
	icon = 'icons/obj/engine/supermatter.dmi'
	icon_state = "nuclear_accumulator"
	circuit = /obj/item/circuitboard/machine/nuclear_accumulator
	set_dir_on_move = FALSE

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

/obj/machinery/power/nuclear_emitter
	name = "nuclear emitter"
	desc = "A large, powerful nuclear emitter. It is capable of storing a large amount of power."
	icon = 'icons/obj/engine/supermatter.dmi'
	icon_state = "nuclear_emitter"
	base_icon_state = "nuclear_emitter"
	circuit = /obj/item/circuitboard/machine/nuclear_emitter
	anchored = FALSE
	density = TRUE
	set_dir_on_move = FALSE
	///Amount of power stored inside
	var/internal_energy = 0
	///Amount required to fire a beam
	var/needed_energy_to_emit = 1000000
	///Is ready to fire?
	var/ready = FALSE
	///Is shooting a beam?
	var/shooting = FALSE

/obj/machinery/power/nuclear_emitter/examine(mob/user)
	. = ..()
	if(!ready)
		. += "It is not ready to shoot."
		. += "Current energy: [internal_energy] Watts, [needed_energy_to_emit] Watts needed to shoot."
	else
		. += "It is ready to shoot."

/obj/machinery/power/nuclear_emitter/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	if(anchored)
		connect_to_network()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/nuclear_emitter/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	default_change_direction_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/nuclear_emitter/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_crowbar(tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/nuclear_emitter/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/nuclear_emitter/should_have_node()
	return anchored

/obj/machinery/power/nuclear_emitter/process()
	if(!powernet || shooting)
		return

	if(!ready)
		use_power(20000)
		internal_energy += 20000

	if(internal_energy >= needed_energy_to_emit)
		ready = TRUE

/obj/machinery/power/nuclear_emitter/attack_hand(mob/living/user, list/modifiers)
	if(!ready || shooting)
		return

	shooting = TRUE
	ready = FALSE

	var/steps = 10
	var/turf/starting_point = get_turf(src)
	var/obj/machinery/power/supermatter_crystal/crystal
	for(var/_ in 1 to steps)
		var/turf/next_step = get_step(starting_point, dir)
		if(!next_step || isclosedturf(next_step))
			shooting = FALSE
			return
		for(var/atom/checked_atom in next_step.contents)
			if(!istype(checked_atom, /obj/machinery/power/supermatter_crystal))
				continue
			crystal = checked_atom
			break
		if(crystal)
			break
		starting_point = next_step

	if(!crystal) //If after the steps there is no crystal just return, we tried
		shooting = FALSE
		return

	internal_energy = max(internal_energy - needed_energy_to_emit, 0)

	Beam(crystal, DEFAULT_ZAP_ICON_STATE, time = 3 SECONDS, beam_color = color_matrix_rotate_hue(120))
	playsound(src, "sound/weapons/nuclear_emitter.ogg", 50, TRUE)
	addtimer(CALLBACK(src, .proc/activate_hypermatter, crystal), 3 SECONDS)

///Activate the SM crystal into an hypermatter state
/obj/machinery/power/nuclear_emitter/proc/activate_hypermatter(obj/machinery/power/supermatter_crystal/crystal)
	shooting = FALSE
	if(!crystal)
		return
	crystal.activate_hypermatter_state(2.5 MINUTES, 3000)
