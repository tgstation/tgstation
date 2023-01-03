// MBTODO: It must be coiled to the computer
/obj/machinery/singularity_turret
	name = "experimental void emitter"
	desc = "A robust, dramatic emitter that is uniquely capable of powering the singularity. Its blasts are so powerful that ear protection is a necessity if you plan to be around them for any period of time, oddly enough, even in space."
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

	var/icon_state_on = "protoemitter_+a"
	var/sparks_left = 2
	var/datum/effect_system/spark_spread/sparks

/obj/machinery/singularity_turret/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/machinery/singularity_turret/process()
	if (sparks_left > 0)
		sparks_left -= 1

		if (isnull(sparks))
			sparks = new
			sparks.set_up(number = 2, location = src)

		sparks.start()
		return

	fire_beam()

/obj/machinery/singularity_turret/singularity_pull(singularity, current_size)
	if (istype(singularity, /obj/contained_singularity))
		return

	return ..()

/obj/machinery/singularity_turret/proc/prepare_fire()
	SHOULD_NOT_SLEEP(TRUE)
	begin_processing()

// MBTODO: Make you deaf for a bit if you're near it when it fires.
/obj/machinery/singularity_turret/proc/fire_beam()
	playsound(src, 'sound/magic/lightningshock.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE, ignore_walls = FALSE)

	sparks.start()

	var/obj/projectile/projectile = new /obj/projectile/beam/singularity_turret(get_turf(src))
	projectile.fired_from = src
	projectile.fire(dir2angle(dir))

/obj/projectile/beam/singularity_turret
	name = "void emitter beam"
	icon_state = "u_laser"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN
	wound_bonus = -40
	bare_wound_bonus = 70
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/singularity_turret/singularity_pull()
	return
