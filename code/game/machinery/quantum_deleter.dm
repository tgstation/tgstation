/obj/machinery/quantumpad/deleter
	name = "quantum deleter"
	desc = "A quantum deleter (qdel for short) able to obliterate any object or entity standing above it when activated by only performing the first half of a quantum teleportation."
	circuit = /obj/item/circuitboard/machine/quantumpad/deleter

/obj/machinery/quantumpad/deleter/interact(mob/user, obj/machinery/quantumpad/target_pad = linked_pad)
	if(world.time < last_teleport + teleport_cooldown)
		to_chat(user, "<span class='warning'>[src] is recharging power. Please wait [DisplayTimeText(last_teleport + teleport_cooldown - world.time)].</span>")
		return

	if(teleporting)
		to_chat(user, "<span class='warning'>[src] is charging up. Please wait.</span>")
		return

	add_fingerprint(user)
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
	teleporting = TRUE
	addtimer(CALLBACK(src, .proc/dodelete, user, target_pad), teleport_speed)

/obj/machinery/quantumpad/deleter/proc/dodelete(mob/user, obj/machinery/quantumpad/target_pad = linked_pad)
	if(!src || QDELETED(src))
		teleporting = FALSE
		return
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] is unpowered!</span>")
		teleporting = FALSE
		return

	teleporting = FALSE
	last_teleport = world.time

	// use a lot of power
	use_power(10000 / power_efficiency)
	sparks()
	flick("qpad-beam", src)
	playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
	if(target_pad && !QDELETED(target_pad) && !(target_pad.stat & NOPOWER))
		target_pad.sparks()
		flick("qpad-beam", target_pad)
		playsound(get_turf(target_pad), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
	for(var/atom/movable/ROI in get_turf(src))
		if(QDELETED(ROI))
			continue //sleeps in CHECK_TICK
		   
		// if is anchored, don't let through
		if(ROI.anchored)
			if(isliving(ROI))
				var/mob/living/L = ROI
				//only TP living mobs buckled to non anchored items
				if(!L.buckled || L.buckled.anchored)
					continue
			//Don't delete ghosts
			else if(!isobserver(ROI))
				continue
		if(isliving(ROI))
			to_chat(ROI, "<span class='userdanger'>You don't feel so good...</span>")
			if(target_pad && !QDELETED(target_pad) && !(target_pad.stat & NOPOWER) && prob(10))
				new /obj/item/reagent_containers/food/snacks/store/bread/plain(get_turf(target_pad))
		qdel(ROI) //uh oh
		CHECK_TICK