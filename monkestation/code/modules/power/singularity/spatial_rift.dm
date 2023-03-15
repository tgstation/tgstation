/// Spatial Rift
/// Basically a BoH Tear, but weaker because it spawns after nullifying a tesloose or singlo and those have done enough damage
/obj/spatial_rift
	name = "a small tear in the fabric of reality, a good place to stuff problems"
	desc = "Your own comprehension of reality starts bending as you stare at this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	pixel_x = -32
	pixel_y = -32
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

/obj/spatial_rift/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 5 SECONDS) // vanishes after 5 seconds
	AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, .proc/consume), \
		admin_investigate_callback = CALLBACK(src, .proc/admin_investigate_setup), \
		consume_range = 1, \
		grav_pull = 8, \
		roaming = FALSE, \
		singularity_size = STAGE_FIVE, \
	)

/obj/spatial_rift/process()
	consume()

/obj/spatial_rift/proc/consume(atom/A)
	if(isturf(A))
		A.singularity_act()
		return
	var/atom/movable/AM = A
	var/turf/T = get_turf(src)
	if(!istype(AM))
		return
	if(isliving(AM))
		var/mob/living/M = AM
		investigate_log("([key_name(A)]) has been consumed by the Spatial rift at [AREACOORD(T)].", INVESTIGATE_ENGINES)
		M.ghostize(FALSE)
	else if(istype(AM, /obj/anomaly/singularity))
		investigate_log("([key_name(A)]) has been consumed by the Spatial rift at [AREACOORD(T)].", INVESTIGATE_ENGINES)
		return
	AM.forceMove(src)

/obj/spatial_rift/proc/admin_investigate_setup()
	var/turf/T = get_turf(src)
	message_admins("A Spatial rift has been created at [ADMIN_VERBOSEJMP(T)].]")
	investigate_log("was created at [AREACOORD(T)].", INVESTIGATE_ENGINES)

/obj/spatial_rift/attack_tk(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='userdanger'>You don't feel like you are real anymore.</span>")
	user.dust_animation()
	user.spawn_dust()
	addtimer(CALLBACK(src, .proc/consume, user), 5)
