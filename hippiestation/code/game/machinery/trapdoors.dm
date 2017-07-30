#define TIME_AUTO_CLOSE_MOB 100
#define TIME_AUTO_CLOSE 1200

/obj/machinery/disposal/trapdoor
	name = "trapdoor"
	desc = "Almost like a door, but on floor."
	density = FALSE
	icon = 'hippiestation/icons/obj/trapdoors.dmi'
	icon_state = "closed"
	layer = 2.01
	var/id = 1
	var/open = FALSE

/obj/machinery/disposal/trapdoor/proc/open()
	if(flushing)
		return
	if(open)
		return
	open = TRUE
	flick("opening", src)
	playsound(loc, 'hippiestation/sound/misc/blast_door.ogg', 100, 1)
	icon_state = "open"
	spawn(5)
		for(var/mob/living/M in loc)
			if(!M.floating)
				M.forceMove(src)
				trap_flush()
				addtimer(CALLBACK(src, .proc/close), TIME_AUTO_CLOSE_MOB)
		for(var/obj/item/O in loc)
			if(!O.throwing || !O.anchored)
				O.forceMove(src)
				trap_flush()
	addtimer(CALLBACK(src, .proc/close), TIME_AUTO_CLOSE)
	return 1

/obj/machinery/disposal/trapdoor/proc/close()
	if(open)
		flick("closing", src)
		icon_state = "closed"
		playsound(loc, 'hippiestation/sound/misc/blast_door.ogg', 100, 1)
		open = FALSE
		return TRUE

/obj/machinery/disposal/trapdoor/Initialize(loc,var/obj/structure/disposalconstruct/make_from)
	. = ..()
	stored.ptype = DISP_END_CHUTE
	trunk = locate() in loc
	if(trunk)
		trunk.linked = src

/obj/machinery/disposal/trapdoor/Crossed(AM as mob|obj)
	if(open)
		if(istype(AM, /mob/living))
			var/mob/living/M = AM
			if(M.floating)
				return
			M.forceMove(src)
			trap_flush()
			addtimer(CALLBACK(src, .proc/close), TIME_AUTO_CLOSE_MOB)
			return
		if(istype(AM, /obj/item))
			var/obj/item/O = AM
			spawn(5)
				if(O.throwing || O.anchored)
					return
				else if(O.loc == src.loc)
					O.forceMove(src)
					trap_flush()

/obj/machinery/disposal/trapdoor/MouseDrop_T(mob/living/target, mob/living/user)
	if (!open)
		return
	if(istype(target))
		push_mob_in(target, user)
		return 1

/obj/machinery/disposal/trapdoor/proc/push_mob_in(mob/living/target, mob/living/carbon/human/user)
	if(target.buckled)
		return
	add_fingerprint(user)
	if(user == target)
		if(target.floating)
			user.visible_message("[user] is attempting to dive into [name].", \
				"<span class='notice'>You start diving into [name]...</span>")
			if(!do_mob(target, user, 10))
				return
			target.forceMove(src)
			user.visible_message("[user] dives into [name].", \
				"<span class='notice'>You dive into [name].</span>")
			sleep(5)
			trap_flush()
			addtimer(CALLBACK(src, .proc/close), TIME_AUTO_CLOSE_MOB)
		else
			user.visible_message("[user] is attempting to step on the edge of [name].", \
				"<span class='notice'>You start attempting to step on the edge of [name]...</span>")
			if(!do_mob(target, user, 30))
				return
			var/chance = 25 // normal chance, 25% to fall inside
			var/turf/open/floor/T = get_turf(src)
			var/M = "fall inside"
			var/U = "falls inside"
			if(user.disabilities & CLUMSY)
				chance = 80
				M = "accidentally do a backward flip, falling inside"
				U = "accidentally does a backward flip, falling inside"
			else if(user.getBrainLoss() >= 50)
				chance = 70
				M = "close your eyes and boldly step forward"
				U = "closes his eyes and boldly steps forward"
			else if(istype(T) && T.wet && isobj(user.shoes) && user.shoes.flags&NOSLIP)
				chance = 60
				M = "slip and fall inside"
				U = "slips and falls inside"
			if(prob(chance))
				user.visible_message("[U] \the [name]!", "You [M] \the [name]!")
				user.forceMove(src)
				trap_flush()
				user.Stun(10)
				addtimer(CALLBACK(src, .proc/close), TIME_AUTO_CLOSE_MOB)
			else
				target.forceMove(src.loc)
				user.visible_message("[user] steps on the edge of [name].", \
					"<span class='notice'>You step on the edge of [name].</span>")

	if(user != target)
		target.visible_message("<span class='danger'>[user] starts pushing [target] into [name].</span>", \
			"<span class='userdanger'>[user] starts pushing you into [name]!</span>")
		user.visible_message("<span class='notice'>You start pushing [target] into [name]...</span>")
		if(do_mob(target, user, 10))
			if (!loc)
				return
			target.forceMove(src)
			target.visible_message("<span class='danger'>[user] has pushed [target] in \the [name].</span>", \
				"<span class='userdanger'>[user] has pushedd [target] in \the [name].</span>")
			add_logs(user, target, "pushed", addition="into [name]")
			sleep(5)
			trap_flush()

/obj/machinery/disposal/trapdoor/proc/trap_flush()
	if(flushing)
		return

	flushing = TRUE
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5)
	if(gc_destroyed)
		return
	var/obj/structure/disposalholder/H = new()
	newHolderDestination(H)
	H.init(src)
	air_contents = new()
	H.start(src)
	flushing = FALSE
	sleep(5)

#undef TIME_AUTO_CLOSE_MOB
#undef TIME_AUTO_CLOSE
