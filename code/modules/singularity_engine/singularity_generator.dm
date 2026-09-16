/obj/machinery/singularity_generator
	name = "singularity generator"
	desc = "A deceptively small machine that, when fired with void emitters, produces enough compressed energy to create a singularity in space. It's worth more in scrap parts than the combined net worth of the entire station."
	icon = 'icons/obj/machines/engine/singularity.dmi'
	icon_state = "generator"

	anchored = TRUE
	density = TRUE

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	// Prototype only
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	var/starting = FALSE

/obj/machinery/singularity_generator/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/connects_to_singularity_console)

/obj/machinery/singularity_generator/bullet_act(obj/projectile/projectile)
	if (!istype(projectile, /obj/projectile/beam/singularity_turret))
		return ..()

	if (!starting)
		INVOKE_ASYNC(src, PROC_REF(start))

	return BULLET_ACT_HIT

/obj/machinery/singularity_generator/proc/start()
	starting = TRUE

	playsound(src, 'sound/effects/magic/lightning_chargeup.ogg', vol = 80, extrarange = 4, falloff_exponent = 2, vary = FALSE, pressure_affected = FALSE, ignore_walls = TRUE)
	stoplag(9 SECONDS)

	for (var/mob/living/carbon/viewer in viewers(10, src))
		viewer.flash_act(intensity = FLASH_PROTECTION_WELDER_SENSITIVE, visual = TRUE)

	var/obj/contained_singularity/singularity = new(get_turf(src))
	SEND_SIGNAL(src, COMSIG_SINGULARITY_GENERATOR_CREATED_SINGULARITY, singularity)

	qdel(src)

/obj/machinery/singularity_generator/singularity_pull(S, current_size)
	. = ..()
	resistance_flags = NONE
