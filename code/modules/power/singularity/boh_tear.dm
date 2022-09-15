/// BoH tear
/// The BoH tear is a stationary singularity with a really high gravitational pull, which collapses briefly after being created
/// The BoH isn't deleted for 10 minutes (only moved to nullspace) so that admins may retrieve the things back in case of a grief
#define BOH_TEAR_CONSUME_RANGE 1
#define BOH_TEAR_GRAV_PULL 25

/obj/boh_tear
	name = "tear in the fabric of reality"
	desc = "Your own comprehension of reality starts bending as you stare this."
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

/obj/boh_tear/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 5 SECONDS) // vanishes after 5 seconds

	AddComponent(
		/datum/component/singularity, \
		consume_range = BOH_TEAR_CONSUME_RANGE, \
		grav_pull = BOH_TEAR_GRAV_PULL, \
		roaming = FALSE, \
		singularity_size = STAGE_SIX, \
	)

/obj/boh_tear/attack_tk(mob/user)
	if(!isliving(user))
		return
	var/mob/living/jedi = user
	to_chat(jedi, span_userdanger("You don't feel like you are real anymore."))
	jedi.dust_animation()
	jedi.spawn_dust()
	addtimer(CALLBACK(src, /atom/proc/attack_hand, jedi), 0.5 SECONDS)
	return COMPONENT_CANCEL_ATTACK_CHAIN

#undef BOH_TEAR_CONSUME_RANGE
#undef BOH_TEAR_GRAV_PULL
