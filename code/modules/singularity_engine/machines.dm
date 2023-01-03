// MBTODO: Destroying these by players (?) should leave them in place, requiring repair, rather than destroying them to machinery.
// Or make them invincible until singulo releases.

// MBTODO: Spawning the singularity should summon a huge flash of light
/obj/machinery/singularity_generator
	name = "singularity generator"
	desc = "A deceptively small machine that, when fired with void emitters, produces enough compressed energy to create a singularity in space. It's worth more in scrap parts than the combined net worth of the entire station."
	icon = 'icons/obj/engine/singularity.dmi'
	icon_state = "generator"

	anchored = TRUE

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/singularity_generator/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)

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

// MBTODO: It must be coiled to the computer
// MBTODO: Make you deaf for a bit if you're near it when it fires.
/obj/machinery/singularity_turret
	name = "experimental void emitter"
	desc = "A robust, dramatic emitter that is uniquely capable of powering the singularity. Its blasts are so powerful that ear protection is a necessity if you plan to be around them for any period of time, oddly enough, even in space."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "protoemitter"
	base_icon_state = "protoemitter"
	var/icon_state_on = "protoemitter_+a"

	anchored = TRUE

	// Handwaived
	use_power = NO_POWER_USE
	active_power_usage = 0

/obj/machinery/singularity_turret/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)
