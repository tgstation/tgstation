/*!
The swapper implant comes in two parts, the activator pen, and the swapper implant itself. The activator stores the object reference to the implant, and uses that to swap the locations of the mobs holding the objects.area
*/

/obj/item/pen/swap_activator
	///Stores the implant object ref.
	var/obj/item/implant/swapper/receiver

/obj/item/pen/swap_activator/proc/activate(var/obj/item/implant/swapper/R = receiver, var/obj/A = src)
	///Grab the recievers mob
	var/mob/living/RL = R.loc
	///Grab the activators mob
	var/mob/living/AL = A.loc
	
	if(R.implanted && R && A)
		///Grab the recievers turf
		var/turf/RT = get_turf(RL.loc)
		///Grab the activators turf
		var/turf/AT = get_turf(A.loc)
		
		playsound(RL, 'sound/effects/sparks4.ogg')
		playsound(AL, 'sound/effects/sparks4.ogg')

		RL.visible_message("[RL] suddenly vanishes, leaving [AL] in their place!")
		AL.visible_message("[AL] suddenly vanishes, leaving [RL] in their place!")
		to_chat(RL, "<span class=notice>You suddenly find yourself in a new location.</span>")
		to_chat(AL, "<span class=notice>You press the button on the pen, and suddenly find yourself in a new location.</span>")

		///Move the receiver to the activator
		do_teleport(RL, AT, channel = TELEPORT_CHANNEL_QUANTUM, forceMove = TRUE)
		///Move the activator to the receiver
		do_teleport(AL, RT, channel = TELEPORT_CHANNEL_QUANTUM, forceMove = TRUE)

		///Cleans up the objects after use.
		QDEL_NULL(R)
		QDEL_NULL(A)
		to_chat(AL, "<span class=notice>The pen falls apart in your hands.</span>")
	else
		to_chat(AL, "<span class=warning>You press the button on the pen, but you have not yet implanted anybody!</span>")

/obj/item/pen/swap_activator/attack_self()
	///Click the pen and you are gone.
	activate()

/obj/item/implant/swapper
	///Ensures that the thing was actually implanted.
	var/implanted = FALSE

/obj/item/implant/swapper/implant(silent = TRUE, force = TRUE)
	. = ..()
	if(.)
		///If 1, it worked and the implant is implanted.
		implanted = TRUE

/obj/item/implanter/swapper
	imp_type = /obj/item/implant/swapper

/obj/item/implanter/swapper/attack(mob/living/M, mob/user)
	if(!istype(M))
		return
	if(user && imp)
		var/turf/T = get_turf(M)
		if(T && (M == user || do_mob(user, M, 0)))
			if(src && imp)
				if(imp.implant(M, user))
					if (M == user)
						to_chat(user, "<span class='notice'>You implant yourself.</span>")
					else
						to_chat(user, "<span class='notice>You implant [M]</span>'")
					imp = null
					update_icon()
				else
					to_chat(user, "<span class='warning'>[src] fails to implant [M].</span>")

