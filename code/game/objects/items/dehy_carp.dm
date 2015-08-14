/*
 *	Dehydrated Carp
 *	Instant carp, just add water
 */

// Child of carpplushie because this should do everything the toy does and more
/obj/item/toy/carpplushie/dehy_carp
	var/mob/owner = null	// Carp doesn't attack owner, set when using in hand
	var/owned = 1	// Boolean, no owner to begin with

// Attack self
/obj/item/toy/carpplushie/dehy_carp/attack_self(mob/user)
	src.add_fingerprint(user)	// Anyone can add their fingerprints to it with this
	if(owned)
		user << "<span class='notice'>[src] stares up at you with friendly eyes.</span>"
		owner = user
		owned = 0
	return ..()


/obj/item/toy/carpplushie/dehy_carp/afterattack(obj/O, mob/user,proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink))
		user << "<span class='notice'>You place [src] under a stream of water...</span>"
		user.drop_item()
		loc = get_turf(O)
		return Swell()
	..()

/obj/item/toy/carpplushie/dehy_carp/proc/Swell()
	desc = "It's growing!"
	visible_message("<span class='notice'>[src] swells up!</span>")

	// Animation
	icon = 'icons/mob/animal.dmi'
	flick("carp_swell", src)
	// Wait for animation to end
	sleep(6)
	// Make space carp
	var/mob/living/simple_animal/hostile/carp/C = new /mob/living/simple_animal/hostile/carp(get_turf(src))
	// Make carp non-hostile to user, and their allies
	if(owner)
		var/list/factions = owner.faction
		for(var/F in factions)
			if(F == "neutral")
				factions -= F
		C.faction = factions
	qdel(src)