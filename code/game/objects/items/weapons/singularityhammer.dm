/obj/item/weapon/twohanded/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	var/charged = 5
	origin_tech = "combat=4;bluespace=4;plasmatech=7"
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 0, bomb = 50, bio = 0, rad = 0, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/weapon/twohanded/singularityhammer/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/twohanded/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/twohanded/singularityhammer/process()
	if(charged < 5)
		charged++
	return

/obj/item/weapon/twohanded/singularityhammer/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[wielded]"
	return

/obj/item/weapon/twohanded/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/X in orange(5,pull))
		if(istype(X, /atom/movable))
			var/atom/movable/A = X
			if(A == wielder)
				continue
			if(A && !A.anchored && !ishuman(X))
				step_towards(A,pull)
				step_towards(A,pull)
				step_towards(A,pull)
			else if(ishuman(X))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						continue
				H.apply_effect(1, WEAKEN, 0)
				step_towards(H,pull)
				step_towards(H,pull)
				step_towards(H,pull)
	return

/obj/item/weapon/twohanded/singularityhammer/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	if(!proximity) return
	if(wielded)
		if(charged == 5)
			charged = 0
			if(istype(A, /mob/living/))
				var/mob/living/Z = A
				Z.take_bodypart_damage(20,0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target,user)

/obj/item/weapon/twohanded/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	//var/charged = 5
	origin_tech = "combat=4;powerstorage=7"

/obj/item/weapon/twohanded/mjollnir/proc/shock(mob/living/target)
	var/datum/effect_system/lightning_spread/s = new /datum/effect_system/lightning_spread
	s.set_up(5, 1, target.loc)
	s.start()
	target.visible_message("<span class='danger'>[target.name] was shocked by the [src.name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock course through your body sending you flying!</span>", \
		"<span class='italics'>You hear a heavy electrical crack!</span>")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)
	return

/obj/item/weapon/twohanded/mjollnir/attack(mob/living/M, mob/user)
	..()
	if(wielded)
		//if(charged == 5)
		//charged = 0
		playsound(src.loc, "sparks", 50, 1)
		M.Stun(3)
		shock(M)

/obj/item/weapon/twohanded/mjollnir/throw_impact(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.Stun(3)
		shock(L)

/obj/item/weapon/twohanded/mjollnir/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[wielded]"
	return
