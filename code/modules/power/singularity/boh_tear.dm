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
	var/start_time = 0

/obj/singularity/boh_tear/Initialize()
	. = ..()
	old_loc = loc
	start_time = world.time
	QDEL_IN(src, 5 SECONDS) // vanishes after 5 seconds

/obj/singularity/boh_tear/process()
	//Backup to catch timerss errors
	if(start_time + (10 SECONDS) < world.time)
		stack_trace("The timer subsytem isn't firing properly, yell at your local coders posthaste")
		qdel(src)
	eat()

/obj/singularity/boh_tear/consume(atom/A)
	A.singularity_act(current_size, src)

/obj/singularity/boh_tear/admin_investigate_setup()
	var/turf/T = get_turf(src)
	message_admins("A BoH tear has been created at [ADMIN_VERBOSEJMP(T)].")
	investigate_log("was created at [AREACOORD(T)].", INVESTIGATE_SINGULO)


/obj/singularity/boh_tear/attack_tk(mob/user)
	if(!isliving(user))
		return
	var/mob/living/jedi = user
	to_chat(jedi, "<span class='userdanger'>You don't feel like you are real anymore.</span>")
	jedi.dust_animation()
	jedi.spawn_dust()
	addtimer(CALLBACK(src, .proc/consume, jedi), 0.5 SECONDS)
	return COMPONENT_CANCEL_ATTACK_CHAIN
