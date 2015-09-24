
//Allows the ninja to kidnap people
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet(mob/living/carbon/C in oview())//Only living carbon mobs.
	set name = "Energy Net (20E)"
	set desc = "Captures a fallen opponent in a net of energy. Will teleport them to a holding facility after 30 seconds."
	set category = null
	set src = usr.contents

	if(!ninjacost(200,N_STEALTH_CANCEL) && iscarbon(C))
		var/mob/living/carbon/human/H = affecting
		if(C.client)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
			if(!locate(/obj/effect/energy_net) in C.loc)//Check if they are already being affected by an energy net.
				for(var/turf/T in getline(H.loc, C.loc))
					if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
						H << "<span class='warning'>You may not use an energy net through solid obstacles!</span>"
						return
				spawn(0)
					H.Beam(C,"n_beam",,15)
				H.say("Get over here!")
				var/obj/effect/energy_net/E = new /obj/effect/energy_net(C.loc)
				E.layer = C.layer+1//To have it appear one layer above the mob.
				H.visible_message("<span class='danger'>[H] caught [C] with an energy net!</span>","<span class='notice'>You caught [C] with an energy net!</span>")
				E.affecting = C
				E.master = H
				spawn(0)//Parallel processing.
					E.process(C)
			else
				H << "<span class='warning'>They are already trapped inside an energy net!</span>"
		else
			H << "<span class='warning'>They will bring no honor to your Clan!</span>"
	return