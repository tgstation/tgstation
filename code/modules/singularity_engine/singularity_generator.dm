// MBTODO: Destroying these by players (?) should leave them in place, requiring repair, rather than destroying them to machinery.
// Or make them invincible until singulo releases.

// MBTODO: Spawning the singularity should summon a huge flash of light
/obj/machinery/singularity_generator
	name = "singularity generator"
	desc = "A deceptively small machine that, when fired with void emitters, produces enough compressed energy to create a singularity in space. It's worth more in scrap parts than the combined net worth of the entire station."
	icon = 'icons/obj/engine/singularity.dmi'
	icon_state = "generator"

	anchored = TRUE
	density = TRUE

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	var/starting = FALSE

/obj/machinery/singularity_generator/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)

/obj/machinery/singularity_generator/bullet_act(obj/projectile/projectile)
	if (!istype(projectile, /obj/projectile/beam/singularity_turret))
		return ..()

	if (starting)
		return

	INVOKE_ASYNC(src, PROC_REF(start))

	return BULLET_ACT_HIT

/obj/machinery/singularity_generator/proc/start()
	starting = TRUE

	playsound(src, 'sound/magic/lightning_chargeup.ogg', vol = 80, extrarange = 4, falloff_exponent = 2, vary = FALSE, pressure_affected = FALSE, ignore_walls = TRUE)
	stoplag(9 SECONDS)

	for (var/mob/living/carbon/viewer in viewers(10, src))
		viewer.flash_act(intensity = FLASH_PROTECTION_WELDER + 1, visual = TRUE)

	qdel(src)
