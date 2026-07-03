/* TODO
/mob/living/basic/pet/dog/corgi/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "It's a borgi."
	icon_state = "borgi"
	icon_living = "borgi"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/emagged = FALSE
	habitable_atmos = null
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot) // !!! TODO from PARACODE: d:\GitHub\Paradise-Remake-SS220\code\game\objects\effects\decals\Cleanable\robots.dm
	basic_mob_flags = DEL_ON_DEATH
	//deathmessage = "blows apart!"

	// holder
	held_state = "borgi"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_NORMAL
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'


/mob/living/basic/pet/dog/corgi/borgi/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		addtimer(CALLBACK(src, PROC_REF(explode)), 100 SECONDS)
		return TRUE

/mob/living/basic/pet/dog/corgi/borgi/proc/explode()
	visible_message("<span class='warning'>[src] makes an odd whining noise.</span>")
	explosion(get_turf(src), 0, 1, 4, 7)
	death()

/mob/living/basic/pet/dog/corgi/borgi/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()

/mob/living/basic/pet/dog/corgi/borgi/Life(seconds, times_fired)
	..()
	//spark for no reason
	if(prob(5))
		do_sparks(3, 1, src)

/mob/living/basic/pet/dog/corgi/borgi/handle_automated_action()
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10, src)
		if(target)
			shootAt(target)

/mob/living/basic/pet/dog/corgi/borgi/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

*/
