//Dark bead: Formed by the Devour Will ability. See umbrage_abilities.dm for more details.
/obj/item/weapon/dark_bead
	name = "dark bead"
	desc = "A glowing black orb. It's fading fast."
	icon_state = "dark_bead"
	item_state = "ratvars_flame"
	flags = NODROP
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE | INDESTRUCTIBLE
	w_class = 5
	var/eating = 0 //If we're devouring someone's will
	var/datum/action/innate/umbrage/devour_will/linked_ability //The ability that keeps data for us

/obj/item/weapon/dark_bead/New()
	..()
	animate(src, alpha = 30, time = 30)
	spawn(30)
		if(!eating)
			loc << "<span class='warning'>You were too slow! [src] faded away.</span>"
			qdel(src)

/obj/item/weapon/dark_bead/attack(mob/living/carbon/L, mob/living/user)
	if(!is_umbrage(user.mind) || eating || L == user) //no eating urself ;)))))))
		return
	var/datum/umbrage/U = linked_ability.get_umbrage()
	if(!L.health)
		user << "<span class='warning'>[L] is too weak to drain.</span>"
		return
	for(var/V in linked_ability.victims)
		var/mob/living/M = V
		if(M == L)
			user << "<span class='warning'>[L] must be given time to recover from their last draining.</span>"
			return
	eating = 1
	user.visible_message("<span class='warning'>[user] grasps [L] and leans in close...</span>", "<span class='velvet_bold'>cera qo...</span><br>\
	<span class='danger'>You begin siphoning [L]'s mental energy...</span>")
	L << "<span class='userdanger'><i>AAAAAAAAAAAAAA-</i></span>"
	L.Stun(3)
	playsound(L, 'sound/magic/devour_will.ogg', 100, 0) //T A S T Y   S O U L S
	if(!do_mob(user, L, 30))
		user.Weaken(3)
		L << "<span class='boldwarning'>All right. You're all right.</span>"
		L.Weaken(3)
		qdel(src)
		return
	user.visible_message("<span class='warning'>[user] rips something out of [L]'s face!</span>", "<span class='velvet_bold'>...aranupdejc</span><br>\
	<span class='boldnotice'>You devour [L]'s will. Your psi has been fully restored.\n\
	Additionally, you have gained one lucidity. Use it to purchase and upgrade abilities.</span><br>\
	<span class='warning'>[L] is now severely weakened and will take some time to recover.</span>")
	playsound(L, 'sound/magic/devour_will_victim.ogg', 50, 0)
	U.psi = U.max_psi
	playsound(L, "bodyfall", 50, 1)
	L << "<span class='userdanger'>You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber...</span>"
	L << sound('sound/magic/devour_will_end.ogg', volume = 75)
	linked_ability.victims += L
	L.Paralyse(30)
	L.silent += 40
	L.stuttering += 40
	L.confused += 40
	L.reagents.add_reagent("zombiepowder", 2) //Brief window of vulnerability to veiling
	qdel(src)
	#warn Change this dark bead recovery timer - 2 minutes, maybe?
	spawn(10)
		if(linked_ability && L)
			linked_ability.victims -= L
			user << "<span class='notice'>[L] has recovered from their draining and is vulnerable to Devour Will again.</span>"
	return 1



//Umbral tendrils: Formed by the Pass ability. See umbrage_abilities.dm for more details.
/obj/item/weapon/umbral_tendrils
	name = "umbral tendrils"
	desc = "A mass of purple, glowing tentacles."
	icon_state = "dark_bead"
	flags = NODROP
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE | INDESTRUCTIBLE
	var/datum/umbrage/linked_umbrage


//Psionic barrier: Created during Divulge. Has a regenerating health pool and protects the umbrage from harm.
/obj/structure/psionic_barrier
	name = "psionic barrier"
	desc = "A violet tint to the air. It doesn't seem to have a physical presence."
	obj_integrity = 200
	max_integrity = 200
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	anchored = 1
	opacity = 0
	density = 1
	mouse_opacity = 2

/obj/structure/psionic_barrier/New()
	..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, 500)

/obj/structure/psionic_barrier/Destroy()
	if(!obj_integrity)
		visible_message("<span class='warning'>[src] vanishes in a burst of violet energy!</span>")
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
		PoolOrNew(/obj/effect/overlay/temp/revenant/cracks, get_turf(src))
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/psionic_barrier/process()
	obj_integrity = max(0, min(max_integrity, obj_integrity + 5))


//Psionic vortex: Created during Divulge. Used for flavor.
/obj/structure/fluff/psionic_vortex
	name = "psionic vortex"
	desc = "A swirling void streaked with violet energy. It seems harmless."
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	deconstructible = FALSE

/obj/structure/fluff/psionic_vortex/New()
	..()
	QDEL_IN(src, 520)
