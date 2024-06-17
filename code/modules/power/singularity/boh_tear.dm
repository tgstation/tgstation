/obj/boh_tear
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

/obj/boh_tear/proc/start_disaster()
	apply_wibbly_filters(src)
	playsound(loc, 'sound/effects/clockcult_gateway_disrupted.ogg', vary = 200, extrarange = 3, falloff_exponent = 1, frequency = 0.33, pressure_affected = FALSE, ignore_walls = TRUE, falloff_distance = 7)
	AddComponent(
		/datum/component/singularity, \
		consume_range = 1, \
		grav_pull = 21, \
		roaming = FALSE, \
		singularity_size = STAGE_SIX, \
	)
	addtimer(CALLBACK(src, PROC_REF(bagulo_time)), 9 SECONDS, TIMER_DELETE_ME)
	animate(src, time = 7.5 SECONDS, transform = transform.Scale(2), flags = ANIMATION_PARALLEL)
	animate(time = 2 SECONDS, transform = transform.Scale(0.25), easing = ELASTIC_EASING)
	animate(time = 0.5 SECONDS, alpha = 0)

/obj/boh_tear/proc/bagulo_time()
	playsound(loc, 'sound/effects/supermatter.ogg', 200, vary = TRUE, extrarange = 3, falloff_exponent = 1, frequency = 0.5, pressure_affected = FALSE, ignore_walls = TRUE, falloff_distance = 7)
	var/obj/singularity/bagulo = new(loc)
	bagulo.expand(STAGE_TWO)
	bagulo.energy = 400
	qdel(src)

/obj/boh_tear/attack_tk(mob/user)
	if(!isliving(user))
		return
	var/mob/living/jedi = user
	to_chat(jedi, span_userdanger("You don't feel like you are real anymore."))
	jedi.dust_animation()
	jedi.spawn_dust()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, attack_hand), jedi), 0.5 SECONDS)
	return COMPONENT_CANCEL_ATTACK_CHAIN
