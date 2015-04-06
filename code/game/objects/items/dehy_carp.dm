/*
 *	Dehydrated Carp
 *	Instant carp, just add water
 */

/obj/item/dehy_carp
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	w_class = 2.0
	attack_verb = list("bit", "ate", "fin slapped")
	var/bitesound = 'sound/weapons/bite.ogg'

// Attack mob
/obj/item/dehy_carp/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, bitesound, 20, 1)	// Play bite sound in local area
	return ..()

// Attack self
/obj/item/dehy_carp/attack_self(mob/user as mob)
	playsound(src.loc, bitesound, 20, 1)
	return ..()

/obj/item/dehy_carp/afterattack(obj/O, mob/user,proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink))
		user << "<span class='notice'>You place [src] under a stream of water...</span>"
		user.drop_item()
		loc = get_turf(O)
		return Swell()
	..()

/obj/item/dehy_carp/proc/Swell()
	icon = 'icons/mob/animal.dmi'
	icon_state = "carp_swell"
	desc = "it's growing!"
	visible_message("<span class='notice'>[src] swells up!</span>")
	sleep(6)	// Sleep until animation's end frame
	new /mob/living/simple_animal/hostile/carp(get_turf(src))	// Make space carp
	qdel(src)