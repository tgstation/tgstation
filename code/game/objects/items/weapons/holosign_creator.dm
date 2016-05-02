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
					H = new holosign_type(get_turf(target), src)
					user << "<span class='notice'>You create \a [H] with [src].</span>"
				else
					user << "<span class='notice'>[src] is projecting at max capacity!</span>"

/obj/item/weapon/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/weapon/holosign_creator/attack_self(mob/user)
	if(signs.len)
		for(var/H in signs)
			qdel(H)
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
	var/obj/item/weapon/holosign_creator/projector

/obj/effect/overlay/holograph/New(loc, source_projector)
	if(source_projector)
		projector = source_projector
		projector.signs += src
	..()

/obj/effect/overlay/holograph/Destroy()
	if(projector)
		projector.signs -= src
		projector = null
	return ..()

/obj/effect/overlay/holograph/attacked_by(obj/item/I, mob/user)
	..()
	take_damage(I.force * 0.5, I.damtype)

/obj/effect/overlay/holograph/blob_act(obj/effect/blob/B)
	qdel(src)

/obj/effect/overlay/holograph/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper)
		return
	attack_generic(5, M)

/obj/effect/overlay/holograph/attack_alien(mob/living/carbon/alien/A)
	attack_generic(5, A)

/obj/effect/overlay/holograph/attack_hand(mob/living/user)
	attack_generic(1, user)

/obj/effect/overlay/holograph/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	qdel(src)

/obj/effect/overlay/holograph/attack_slime(mob/living/simple_animal/slime/S)
	if(S.is_adult)
		attack_generic(5, S)
	else
		attack_generic(2, S)

/obj/effect/overlay/holograph/proc/attack_generic(damage_amount, mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] hits [src].</span>", \
						 "<span class='danger'>You hit [src].</span>" )
	take_damage(damage_amount)

/obj/effect/overlay/holograph/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(damage && sound_effect)
				playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
		if(BURN)
			if(damage && sound_effect)
				playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
		else
			return
	holo_integrity -= damage
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
	take_damage(tforce)

/obj/effect/overlay/holograph/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage * 0.5, P.damage_type)

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
