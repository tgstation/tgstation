/obj/machinery/field/generator/singularity
	name = "specialized field generator"
	desc = "A field generator specialized in containing the extremely dangerous emissions of the singularity. Due to the sheer force of these particles, contact will weaken the field temporarily."

	anchored = TRUE
	state = FG_WELDED

	// Prototype only
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	// In the future this should use power better.
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	generator_distance = 12

	containment_field_type = /obj/machinery/field/containment/singularity

	/// How much energy did we trap from singularity particles
	var/trapped_energy = 0
	/// How much to transfer to the powernet per tick
	var/transfer_per_tick = 0

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

/obj/machinery/field/generator/singularity/proc/trap_energy(amount)
	if(amount <= 0)
		return

	trapped_energy += amount
	transfer_per_tick = min(trapped_energy, max(transfer_per_tick, amount / 2))

/obj/machinery/field/generator/singularity/process(seconds_per_tick)
	. = ..()
	if(trapped_energy <= 0)
		return

	if(active == FG_ONLINE)
		var/obj/structure/cable/gen_cable = locate() in loc
		gen_cable?.add_avail(min(transfer_per_tick, trapped_energy))
	// power is used even without a cable - say it discharges or something
	trapped_energy = max(0, trapped_energy - transfer_per_tick)
	transfer_per_tick = min(transfer_per_tick, trapped_energy)

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
		return BULLET_ACT_BLOCK

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

	var/captured_energy = SSpower_bars.get_surplus_power()
	if(captured_energy > 0)
		astype(field_gen_1, /obj/machinery/field/generator/singularity)?.trap_energy(captured_energy / 2)
		astype(field_gen_2, /obj/machinery/field/generator/singularity)?.trap_energy(captured_energy / 2)

/obj/machinery/field/containment/singularity/proc/reset_cooldown()
	var/delay = SSsingularity_turrets.wait * 0.75
	COOLDOWN_START(src, reset_cooldown, delay)

	animate(src, time = 0, alpha = 40, flags = ANIMATION_END_NOW)
	animate(time = delay * 1.05, alpha = 255, easing = SINE_EASING)
