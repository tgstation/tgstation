/// Tear in the Fabric of Reality ///
// Typically spawned by placing two bags of holding into one another, collapsing into a wandering singularity after a brief period as a stationary singularity.

/obj/reality_tear
	name = "tear in the fabric of reality"
	desc = "As you gaze into the abyss, the only thing you can think is... \"Should I really be this close to it?\""
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	plane = MASSIVE_OBJ_PLANE
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1
	/// Range that our singularity component consumes objects
	var/singularity_consume_range = 1
	/// Ranges that the singularity pulls objects
	var/singularity_grav_pull = 21
	/// Time before we begin our bagulo spawn
	var/collapse_spawn_time = 9 SECONDS

/obj/reality_tear/proc/start_disaster()
	apply_wibbly_filters(src)
	playsound(loc, 'sound/effects/clockcult_gateway_disrupted.ogg', vary = 200, extrarange = 3, falloff_exponent = 1, frequency = 0.33, pressure_affected = FALSE, ignore_walls = TRUE, falloff_distance = 7)
	AddComponent(
		/datum/component/singularity, \
		consume_range = singularity_consume_range, \
		grav_pull = singularity_grav_pull, \
		roaming = FALSE, \
		singularity_size = STAGE_SIX, \
	)
	addtimer(CALLBACK(src, PROC_REF(reality_collapse)), collapse_spawn_time, TIMER_DELETE_ME)
	animate(src, time = 7.5 SECONDS, transform = transform.Scale(2), flags = ANIMATION_PARALLEL)
	animate(time = 2 SECONDS, transform = transform.Scale(0.25), easing = ELASTIC_EASING)
	animate(time = 0.5 SECONDS, alpha = 0)

/obj/reality_tear/proc/reality_collapse()
	playsound(loc, 'sound/effects/supermatter.ogg', 200, vary = TRUE, extrarange = 3, falloff_exponent = 1, frequency = 0.5, pressure_affected = FALSE, ignore_walls = TRUE, falloff_distance = 7)
	var/obj/singularity/bagulo = new(loc)
	bagulo.expand(STAGE_TWO)
	bagulo.energy = 400
	qdel(src)

/obj/reality_tear/attack_tk(mob/user)
	if(!isliving(user))
		return
	var/mob/living/jedi = user
	to_chat(jedi, span_userdanger("You don't feel like you are real anymore."))
	jedi.dust(just_ash = TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN

//The temporary tears in reality. Collapses into nothing, and has a significantly lower gravity pull range, but consumes more widely.

/obj/reality_tear/temporary
	name = "puncture in the fabric of reality"
	desc = "Count your lucky stars that this wasn't anywhere near you."
	singularity_consume_range = 2
	singularity_grav_pull = 3
	collapse_spawn_time = 2 SECONDS

/obj/reality_tear/temporary/reality_collapse()
	qdel(src)
