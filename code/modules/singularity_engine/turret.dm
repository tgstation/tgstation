/obj/machinery/singularity_turret
	name = "experimental void emitter"
	desc = "A robust, dramatic emitter that is uniquely capable of powering the singularity. Firing into an active singularity will generate power."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "protoemitter"
	base_icon_state = "protoemitter"

	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/singularity_turrets

	anchored = TRUE
	density = TRUE

	// Handwaived
	use_power = NO_POWER_USE
	active_power_usage = 0

	var/pause_counter = 0
	var/sparks_left = 2

	VAR_PRIVATE
		icon_state_on = "protoemitter_+a"
		datum/effect_system/basic/spark_spread/sparks

/obj/machinery/singularity_turret/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/machinery/singularity_turret/process()
	if (!powered())
		return

	if (pause_counter > 0)
		return

	if (sparks_left > 0)
		sparks_left -= 1

		if (isnull(sparks))
			sparks = new(null, 2)
			sparks.attach(src)

		sparks.start()
		return

	fire_beam()

/obj/machinery/singularity_turret/singularity_pull(singularity, current_size)
	if (istype(singularity, /obj/contained_singularity))
		return

	return ..()

/obj/machinery/singularity_turret/proc/prepare_fire()
	SHOULD_NOT_SLEEP(TRUE)

	icon_state = icon_state_on
	begin_processing()

/obj/machinery/singularity_turret/proc/fire_beam(overclocked = FALSE)
	playsound(src, 'sound/effects/magic/lightningshock.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE, ignore_walls = FALSE)

	sparks.start()

	var/obj/projectile/beam/singularity_turret/projectile = new (get_turf(src))
	projectile.overclocked = overclocked
	projectile.fired_from = src
	projectile.fire(dir2angle(dir))

/obj/projectile/beam/singularity_turret
	name = "void emitter beam"
	icon_state = "u_laser"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN
	wound_bonus = -40
	exposed_wound_bonus = 70
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

	var/overclocked = FALSE

/obj/projectile/beam/singularity_turret/singularity_pull()
	return
