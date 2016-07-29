/obj/structure/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is a small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/weapon/twohanded/fireaxe/fireaxe = new/obj/item/weapon/twohanded/fireaxe
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe"
	anchored = 1
	density = 0
	var/locked = 1
	var/open = 0
	var/health = 60

/obj/structure/fireaxecabinet/New()
	..()
	update_icon()

/obj/structure/fireaxecabinet/attackby(obj/item/I, mob/user, params)
	if(isrobot(user) || istype(I,/obj/item/device/multitool))
		toggle_lock(user)
		return
	if(open || health <= 0)
		if(istype(I, /obj/item/weapon/twohanded/fireaxe) && !fireaxe)
			var/obj/item/weapon/twohanded/fireaxe/F = I
			if(F.wielded)
				user << "<span class='warning'>Unwield the [F.name] first.</span>"
				return
			if(!user.drop_item())
				return
			fireaxe = F
			src.contents += F
			user << "<span class='caution'>You place the [F.name] back in the [name].</span>"
			update_icon()
			return
		else if(health > 0)
			toggle_open()
	else
		return ..()

/obj/structure/fireaxecabinet/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force, I.damtype)

/obj/structure/fireaxecabinet/proc/take_damage(damage, damage_type, sound_effect = 1)
	if(open)
		return
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(health <= 0)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
				else
					playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	if(damage < 10)
		return
	if(health > 0)
		health -= damage
		update_icon()
		if(health <= 0)
			playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)


/obj/structure/fireaxecabinet/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50) && fireaxe)
				fireaxe.loc = src.loc
				qdel(src)
			else
				take_damage(rand(30,70), BRUTE, 0)
		if(3)
			take_damage(rand(10,30), BRUTE, 0)

/obj/structure/fireaxecabinet/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)


/obj/structure/fireaxecabinet/blob_act(obj/effect/blob/B)
	if(fireaxe)
		fireaxe.loc = src.loc
	qdel(src)

/obj/structure/fireaxecabinet/attack_hand(mob/user)
	if(open || health <= 0)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			fireaxe = null
			user << "<span class='caution'>You take the fire axe from the [name].</span>"
			src.add_fingerprint(user)
			update_icon()
			return
	if(locked)
		user <<"<span class='warning'> The [name] won't budge!</span>"
		return
	else
		open = !open
		update_icon()
		return

/obj/structure/fireaxecabinet/attack_paw(mob/living/user)
	attack_hand(user)

/obj/structure/fireaxecabinet/attack_alien(mob/living/user)
	user.visible_message("<span class='warning'>[user] slashes [src].</span>")
	take_damage(20)

/obj/structure/fireaxecabinet/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper)
		return
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='danger'>You smash against [src].</span>")
	take_damage(M.melee_damage_upper, M.melee_damage_type)

/obj/structure/fireaxecabinet/attack_ai(mob/user)
	toggle_lock(user)
	return

/obj/structure/fireaxecabinet/update_icon()
	cut_overlays()
	if(fireaxe)
		add_overlay("axe")
	if(!open)
		switch(health)
			if(-INFINITY to 0)
				add_overlay("glass4")
			if(1 to 20)
				add_overlay("glass3")
			if(21 to 40)
				add_overlay("glass2")
			if(41 to 59)
				add_overlay("glass1")
			if(60)
				add_overlay("glass")
		if(locked)
			add_overlay("locked")
		else
			add_overlay("unlocked")
	else
		add_overlay("glass_raised")

/obj/structure/fireaxecabinet/proc/toggle_lock(mob/user)
	user << "<span class = 'caution'> Resetting circuitry...</span>"
	playsound(src, 'sound/machines/locktoggle.ogg', 50, 1)
	if(do_after(user, 20, target = src))
		user << "<span class='caution'>You [locked ? "disable" : "re-enable"] the locking modules.</span>"
		locked = !locked
		update_icon()

/obj/structure/fireaxecabinet/verb/toggle_open()
	set name = "Open/Close"
	set category = "Object"
	set src in oview(1)

	if(locked)
		usr <<"<span class='warning'> The [name] won't budge!</span>"
		return
	else
		open = !open
		update_icon()
		return
