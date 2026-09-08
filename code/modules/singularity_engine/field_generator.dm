/obj/machinery/field/generator/singularity
	name = "specialized field generator"
	desc = "A field generator specialized in containing the extremely dangerous emissions of the singularity. Due to the sheer force of these particles, contact will weaken the field temporarily."

	anchored = TRUE
	state = 2 // FG_WELDED...:-(

	// Prototype only
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	// In the future this should use power better.
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	generator_distance = 12

	containment_field_type = /obj/machinery/field/containment/singularity

/obj/machinery/field/generator/singularity/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)

/obj/machinery/field/generator/singularity/calc_power(set_power_draw)
	return TRUE

/obj/machinery/field/generator/singularity/draw_power(draw, failsafe, obj/machinery/field/generator/other_generator, obj/machinery/field/generator/last)
	return TRUE

/obj/machinery/field/generator/singularity/block_singularity_if_active(singularity)
	if (istype(singularity, /obj/contained_singularity))
		return ..()

	return NONE

/obj/machinery/field/generator/singularity/singularity_pull(S, current_size)
	. = ..()
	resistance_flags = NONE

/obj/machinery/field/containment/singularity
	name = "singularity containment field"
	density = TRUE

	var/datum/effect_system/basic/spark_spread/quantum/sparks
	COOLDOWN_DECLARE(reset_cooldown)

/obj/machinery/field/containment/singularity/Initialize(mapload)
	. = ..()

	var/icon/new_icon = icon(icon, icon_state)
	new_icon.ColorTone(COLOR_GREEN)
	icon = new_icon
	icon_state = ""

/obj/machinery/field/containment/singularity/Destroy()
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/field/containment/singularity/bullet_act(obj/projectile/projectile)
	if (istype(projectile, /obj/projectile/singularity_particle))
		if (!COOLDOWN_FINISHED(src, reset_cooldown))
			return BULLET_ACT_FORCE_PIERCE

		capture_particle(projectile)
		return

	return ..()

/obj/machinery/field/containment/singularity/proc/capture_particle(obj/projectile/singularity_particle/particle)
	playsound(particle, 'sound/effects/singulo_particle_captured.ogg', vol = 50, pressure_affected = FALSE)
	qdel(particle)

	if (isnull(sparks))
		sparks = new()
		sparks.attach(src)

	sparks.start()

	for (var/obj/machinery/field/containment/singularity/field as anything in field_gen_1.fields | field_gen_2.fields)
		if (field.dir != dir)
			continue

		field.reset_cooldown()

	var/obj/structure/cable/gen_one_cable = locate() in field_gen_1.loc
	var/obj/structure/cable/gen_two_cable = locate() in field_gen_2.loc

	var/fake_power = power_to_energy(SSpower_bars.get_surplus_power())
	gen_one_cable?.add_avail(fake_power / 2)
	gen_two_cable?.add_avail(fake_power / 2)

/obj/machinery/field/containment/singularity/proc/reset_cooldown()
	var/delay = SSsingularity_turrets.wait * 0.75
	COOLDOWN_START(src, reset_cooldown, delay)

	animate(src, time = 0, alpha = 40, flags = ANIMATION_END_NOW)
	animate(time = delay * 1.05, alpha = 255, easing = SINE_EASING)
