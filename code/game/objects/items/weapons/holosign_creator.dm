/obj/item/weapon/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "electronic"
	force = 0
	w_class = 2
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "programming=3"
	flags = NOBLUDGEON
	var/list/signs = list()
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/effect/overlay/holograph/wetsign
	var/holocreator_busy = 0 //to prevent placing multiple holo barriers at once

/obj/item/weapon/holosign_creator/afterattack(atom/target, mob/user, flag)
	if(flag)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/effect/overlay/holograph/H = locate(holosign_type) in T
		if(H)
			user << "<span class='notice'>You use [src] to deactivate [H].</span>"
			signs.Remove(H)
			qdel(H)
		else
			if(!is_blocked_turf(T)) //can't put holograms on a tile that has dense stuff
				if(holocreator_busy)
					user << "<span class='notice'>[src] is busy creating a hologram.</span>"
					return
				if(signs.len < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
					if(creation_time)
						holocreator_busy = 1
						if(!do_after(user, creation_time, target = target))
							holocreator_busy = 0
							return
						holocreator_busy = 0
						if(signs.len >= max_signs)
							return
						if(is_blocked_turf(T)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target))
					signs += H
					user << "<span class='notice'>You create \a [H] with [src].</span>"
				else
					user << "<span class='notice'>[src] is projecting at max capacity!</span>"

/obj/item/weapon/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/weapon/holosign_creator/attack_self(mob/user)
	if(signs.len)
		var/list/L = signs.Copy()
		for(var/sign in L)
			qdel(sign)
			signs -= sign
		user << "<span class='notice'>You clear all active holograms.</span>"


/obj/item/weapon/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/effect/overlay/holograph/barrier
	creation_time = 30
	max_signs = 6

/obj/item/weapon/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	holosign_type = /obj/effect/overlay/holograph/barrier/engineering
	creation_time = 30
	max_signs = 6


/obj/effect/overlay/holograph
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	var/holo_integrity = 1

/obj/effect/overlay/holograph/attackby(obj/item/weapon/W, mob/user, params)
	if(!W.force || (W.flags & (ABSTRACT|NOBLUDGEON)))
		return
	if(W.force >= 10)
		take_damage(3, user)
	else
		take_damage(1, user)

/obj/effect/overlay/holograph/blob_act()
	qdel(src)

/obj/effect/overlay/holograph/attack_animal(mob/living/simple_animal/M)
	take_damage(5, M)

/obj/effect/overlay/holograph/attack_alien(mob/living/carbon/alien/A)
	take_damage(5, A)

/obj/effect/overlay/holograph/attack_hand(mob/living/user)
	take_damage(1, user)

/obj/effect/overlay/holograph/mech_melee_attack(obj/mecha/M)
	playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	qdel(src)

/obj/effect/overlay/holograph/attack_slime(mob/living/simple_animal/slime/S)
	if(S.is_adult)
		take_damage(5, S)
	else
		take_damage(2, S)

/obj/effect/overlay/holograph/proc/take_damage(amount, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
	user.visible_message("<span class='danger'>[user] hits [src].</span>", \
						 "<span class='danger'>You hit [src].</span>" )
	holo_integrity -= amount
	if(holo_integrity <= 0)
		qdel(src)

/obj/effect/overlay/holograph/hitby(atom/movable/AM)
	..()
	var/tforce = 1
	if(ismob(AM))
		tforce = 5
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = max(1, I.throwforce * 0.2)
	playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
	holo_integrity -= tforce
	if(holo_integrity <= 0)
		qdel(src)

/obj/effect/overlay/holograph/bullet_act(obj/item/projectile/P)
	if((P.damage_type == BRUTE || P.damage_type == BURN))
		holo_integrity -= P.damage * 0.5
		if(holo_integrity <= 0)
			qdel(src)

/obj/effect/overlay/holograph/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon_state = "holosign"

/obj/effect/overlay/holograph/barrier
	name = "holo barrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	pass_flags = LETPASSTHROW
	density = 1
	holo_integrity = 4

/obj/effect/overlay/holograph/barrier/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!density)
		return 1
	if(air_group || (height==0))
		return 1
	if(mover.pass_flags & (PASSGLASS|PASSTABLE|PASSGRILLE))
		return 1
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.m_intent == "walk")
			return 1

/obj/effect/overlay/holograph/barrier/engineering
	icon_state = "holosign_engi"
