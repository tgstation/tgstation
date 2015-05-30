//BAIT: Stops a mining creature from following you, distracting it if it hits
/obj/item/weapon/miningBait
	name = "ball of raw meat"
	desc ="A chunk of raw meat used to distract hostile creatures to allow for an escape."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_strawberry" //Yeah, I improvised >.>
	w_class = 2
	throw_range = 9
	throw_speed = 2

/obj/item/weapon/miningBait/throw_impact(atom/hitAtom)
	..()
	src.visible_message("<span class='warning'>[src] breaks apart upon impact!</span>")
	if(ismob(hitAtom))
		var/mob/living/simple_animal/hostile/M = hitAtom
		if(!istype(M) || !M)
			return
		else
			M.visible_message("<span class='warning'>[M] stops and begins chomping at the remains of [src].</span>", \
					  "<span class='notice'>Free food? Truth be told, you're pretty hungry. Can't let this go to waste...</span>")
			M.LoseAggro()
			M.notransform = 1
			qdel(src)
			sleep(100) //10 seconds
			M.visible_message("<span class='warning'>[M] finishes eating the meat scraps.</span>", \
					  		  "<span class='notice'>That wasn't very filling. Now what were you doing again?</span>")
			M.notransform = 0
	if(src)
		qdel(src)
