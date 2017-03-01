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
	QDEL_IN(src, 30)

/obj/item/weapon/dark_bead/Destroy(force)
	if(isliving(loc) && !eating && !force)
		loc << "<span class='warning'>You were too slow! [src] faded away...</span>"
	if(!eating || force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/weapon/dark_bead/attack(mob/living/carbon/L, mob/living/user)
	if(!is_umbrage(user.mind) || eating || L == user) //no eating urself ;)))))))
		return
	var/datum/umbrage/U = linked_ability.linked_umbrage
	if(!L.health || L.stat)
		user << "<span class='warning'>[L] is too weak to drain.</span>"
		return
	if(linked_ability.victims[L.real_name])
		user << "<span class='warning'>[L] must be given time to recover from their last draining.</span>"
		return
	if(!L.mind || is_umbrage_or_veil(L.mind))
		user << "<span class='warning'>You cannot drain allies or the mindless.</span>"
		return
	eating = 1
	user.visible_message("<span class='warning'>[user] grabs [L] and leans in close...</span>", "<span class='velvet bold'>cera qo...</span><br>\
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
	user.visible_message("<span class='warning'>[user] gently lowers [L] to the ground...</span>", "<span class='velvet bold'>...aranupdejc</span><br>\
	<span class='boldnotice'>You devour [L]'s will. Your psi has been fully restored.\n\
	Additionally, you have gained one lucidity. Use it to purchase and upgrade abilities.</span><br>\
	<span class='warning'>[L] is now severely weakened and will take some time to recover.</span>")
	playsound(L, 'sound/magic/devour_will_victim.ogg', 50, 0)
	U.psi = U.max_psi
	U.lucidity++
	U.lucidity_drained++
	LAZYADD(U.drained_minds, L.mind)
	linked_ability.victims[L.real_name] = L
	L << "<span class='userdanger'>You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber...</span>"
	L << sound('sound/magic/devour_will_end.ogg', volume = 75)
	L.Paralyse(30)
	L.stuttering += 40
	L.confused += 40
	L.reagents.add_reagent("zombiepowder", 2) //Brief window of vulnerability to veiling
	addtimer(CALLBACK(linked_ability, .proc/make_mob_eligible, L), 50)
	qdel(src, force = TRUE)
	#warn Change this dark bead recovery timer - 2 minutes, maybe?
	return TRUE

/obj/item/weapon/dark_bead/proc/make_mob_eligible(mob/living/L)
	linked_ability.make_mob_eligible(L)


//Umbral tendrils: Formed by the Pass ability. See umbrage_abilities.dm for more details.
/obj/item/weapon/umbral_tendrils
	name = "umbral tendrils"
	desc = "A mass of purple, glowing tentacles."
	icon_state = "dark_bead"
	flags = NODROP
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE | INDESTRUCTIBLE
	var/psi_cost //How much psi we're using right now
	var/datum/umbrage/linked_umbrage

/obj/item/weapon/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity)
	var/used = FALSE
	switch(user.a_intent)
		if("help") //Mobility and movement
		if("disarm") //Object and item interaction
		if("grab") //Grabbing things from a distance
		if("harm") //Disabling and hurting oter people
			if(isliving(target))
				used = disable_victim(user, target)
	if(used)
		linked_umbrage.use_psi(psi_cost)
		qdel(src)

/obj/item/weapon/umbral_tendrils/proc/disable_victim(mob/living/user, mob/living/target)
	if(!linked_umbrage.has_psi(40))
		user << "<span class='warning'>You need at least 40 psi to disable someone!</span>"
		return
	user.visible_message("<span class='warning'>[user] swings \his [src] in an arc towards [target]!</span>", "<span class='notice'>You swing your tendrils towards [target]!</span>")
	playsound(user, 'sound/magic/Tail_swing.ogg', 50, 1)
	sleep(0.5)
	if(!target in view(7, user))
		user.visible_message("<span class='warning'>[user]'s [src] bounce harmlessly off of the floor!</span>", "<span class='warning'>[target] left your line of sight!</span>")
		playsound(user, 'sound/weapons/Genhit.ogg', 50, 1)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.visible_message("<span class='warning'>[user]'s [src] slam into [C]'s stomach, knocking them over!</span>", "<span class='userdanger'>You feel something heavy slam into your gut, and the wind goes out of you!</span>")
		playsound(C, "swing_hit", 50, 1)
		C.Weaken(4)
		C.silent += 8
	else if(issilicon(target))
		var/mob/living/silicon/S = target
		S.visible_message("<span class='warning'>[user]'s [src] slam into [S]'s chassis, leaving a sizable dent!</span>", "<span class='userdanger'>Heavy percussive maintenance detected. Motor circuits rebooting.</span>")
		playsound(S, 'sound/effects/bang.ogg', 75, 1)
		S.adjustBruteLoss(10)
		S.Stun(3)
	psi_cost = 40
	return 1


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
	luminosity = 1
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


//Simulacrum: Created from Simulacrum. Runs in a straight line until destroyed.
/obj/effect/simulacrum
	name = "an illusion!"
	desc = "What are you hiding?!"
	icon_state = "static"
	density = 0

/obj/effect/simulacrum/New()
	..()
	START_PROCESSING(SSfastprocess, src)
	QDEL_IN(src, 100)

/obj/effect/simulacrum/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/simulacrum/process()
	var/turf/T = get_step(src, dir)
	Move(T)

/obj/effect/simulacrum/proc/mimic(mob/living/L)
	if(!L)
		return
	name = L.name
	desc = "A lifelike illusion of [L]."
	icon = L.icon
	icon_state = L.icon_state
	overlays = L.overlays
	setDir(L.dir)
