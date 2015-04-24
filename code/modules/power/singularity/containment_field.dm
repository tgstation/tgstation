//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/field/containment
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	unacidable = 1
	use_power = 0
	luminosity = 4
	layer = OBJ_LAYER + 0.1
	var/obj/machinery/field/generator/FG1 = null
	var/obj/machinery/field/generator/FG2 = null

/obj/machinery/field/containment/Destroy()
	if(FG1 && !FG1.clean_up)
		FG1.cleanup()
	if(FG2 && !FG2.clean_up)
		FG2.cleanup()
	..()

/obj/machinery/field/containment/attack_hand(mob/user as mob)
	if(get_dist(src, user) > 1)
		return 0
	else
		shock(user)
		return 1


/obj/machinery/field/containment/blob_act()
	return 0


/obj/machinery/field/containment/ex_act(severity, target)
	return 0


/obj/machinery/field/containment/Crossed(mob/mover as mob)
	if(isliving(mover))
		shock(mover)

/obj/machinery/field/containment/Crossed(obj/mover as obj)
	if(istype(mover, /obj/machinery) || istype(mover, /obj/structure) || istype(mover, /obj/mecha))
		bump(mover)

/obj/machinery/field/containment/proc/set_master(var/master1,var/master2)
	if(!master1 || !master2)
		return 0
	FG1 = master1
	FG2 = master2
	return 1

/obj/machinery/field/containment/shock(mob/living/user as mob)
	if(!FG1 || !FG2)
		qdel(src)
		return 0
	..()

/obj/machinery/field/containment/Move()
	qdel(src)

// Abstract Field Class
// Used for overriding certain procs

/obj/machinery/field
	var/hasShocked = 0 //Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.

/obj/machinery/field/CanPass(mob/mover as mob, turf/target, height=0)
	if(isliving(mover)) // Don't let mobs through
		shock(mover)
		return 0
	return ..()

/obj/machinery/field/CanPass(obj/mover as obj, turf/target, height=0)
	if((istype(mover, /obj/machinery) && !istype(mover, /obj/singularity)) || \
		istype(mover, /obj/structure) || \
		istype(mover, /obj/mecha))
		bump(mover)
		return 0
	return ..()

/obj/machinery/field/proc/shock(mob/living/user as mob)
	if(hasShocked)
		return 0
	if(isliving(user))
		hasShocked = 1
		var/shock_damage = min(rand(30,40),rand(30,40))

		if(iscarbon(user))
			var/stun = min(shock_damage, 15)
			user.Stun(stun)
			user.Weaken(10)
			user.burn_skin(shock_damage)
			user.visible_message("<span class='danger'>[user.name] was shocked by the [src.name]!</span>", \
			"<span class='userdanger'>You feel a powerful shock course through your body, sending you flying!</span>", \
			"<span class='italics'>You hear a heavy electrical crack.</span>")

		else if(issilicon(user))
			if(prob(20))
				user.Stun(2)
			user.take_overall_damage(0, shock_damage)
			user.visible_message("<span class='danger'>[user.name] was shocked by the [src.name]!</span>", \
			"<span class='userdanger'>Energy pulse detected, system damaged!</span>", \
			"<span class='italics'>You hear an electrical crack.</span>")

		user.updatehealth()
		bump(user)

		spawn(5)
			hasShocked = 0
	return

/obj/machinery/field/proc/bump(atom/movable/AM as mob|obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, AM.loc)
	s.start()
	var/atom/target = get_edge_target_turf(AM, get_dir(src, get_step_away(AM, src)))
	AM.throw_at(target, 200, 4)
