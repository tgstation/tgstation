// MBTODO: Destroying these by players (?) should leave them in place, requiring repair, rather than destroying them to machinery.
// Or make them invincible until singulo releases.

// MBTODO: It must be coiled to the computer.
// You still need to go outside and interface with them, but it has to be attached to the computer to function.
/obj/machinery/field/generator/singularity
	name = "specialized field generator"
	desc = "A field generator specialized in containing the extremely dangerous emissions of the singularity. Due to the sheer force of these particles, contact will weaken the field temporarily."

	anchored = TRUE
	state = 2 // FG_WELDED...:-(

	// In the future this should use power better.
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	generator_distance = 12

/obj/machinery/field/generator/singularity/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)

/obj/machinery/field/generator/singularity/calc_power(set_power_draw)
	return TRUE

/obj/machinery/field/generator/singularity/draw_power(draw, failsafe, obj/machinery/field/generator/other_generator, obj/machinery/field/generator/last)
	return TRUE
