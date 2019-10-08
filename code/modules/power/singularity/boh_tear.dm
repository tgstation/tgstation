/// BoH tear
/// The BoH tear is a stationary singularity with a really high gravitational pull, which collapses briefly after being created
/// The BoH isn't deleted for 10 minutes (only moved to nullspace) so that admins may retrieve the things back in case of a grief
/obj/singularity/boh_tear
	name = "tear in the fabric of reality"
	desc = "Your own comprehension of reality starts bending as you stare this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	pixel_x = -32
	pixel_y = -32
	dissipate = 0
	move_self = 0
	consume_range = 1
	grav_pull = 25
	current_size = STAGE_SIX
	allowed_size = STAGE_SIX
	var/ghosts = list()
	var/old_loc

/obj/singularity/boh_tear/Initialize()
	. = ..()
	old_loc = loc
	addtimer(CALLBACK(src, /atom/movable.proc/moveToNullspace), 5 SECONDS) // vanishes after 5 seconds
	QDEL_IN(src, 10 MINUTES)

/// Retrieve all the items consumed
/obj/singularity/boh_tear/proc/retrieve_consumed_items()
	for(var/atom/movable/content in contents)
		content.forceMove(old_loc)
		if(ismob(content))
			var/mob/M = content
			if(!M.mind)
				continue
			for(var/mob/dead/observer/ghost in ghosts)
				if(ghost.mind == M.mind)
					ghosts -= ghost
					ghost.can_reenter_corpse = TRUE
					ghost.reenter_corpse()
					break
	qdel(src)

/obj/singularity/boh_tear/process()
	eat()

/obj/singularity/boh_tear/consume(atom/A)
	if(isturf(A))
		A.singularity_act()
		return
	var/atom/movable/AM = A
	if(!istype(AM))
		return
	if(isliving(AM))
		var/mob/living/M = AM
		var/turf/T = get_turf(src)
		investigate_log("([key_name(A)]) has been consumed by the BoH tear at [AREACOORD(T)].", INVESTIGATE_SINGULO)
		M.ghostize(FALSE)
	else if(!isobj(AM))
		return
	AM.forceMove(src)

/obj/singularity/boh_tear/admin_investigate_setup()
	var/turf/T = get_turf(src)
	message_admins("A BoH tear has been created at [ADMIN_VERBOSEJMP(T)]. [ADMIN_RETRIEVE_BOH_ITEMS(src)]")
	investigate_log("was created at [AREACOORD(T)].", INVESTIGATE_SINGULO)

/obj/singularity/boh_tear/attack_tk(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='userdanger'>You don't feel like you are real anymore.</span>")
	user.dust_animation()
	user.spawn_dust()
	addtimer(CALLBACK(src, .proc/consume, user), 5)
