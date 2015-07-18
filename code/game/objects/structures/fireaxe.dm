/obj/structure/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/weapon/twohanded/fireaxe/fireaxe = new/obj/item/weapon/twohanded/fireaxe
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe"
	anchored = 1
	density = 0
	var/locked = 1
	var/open = 0
	var/glass_hp = 60

/obj/structure/fireaxecabinet/New()
	..()
	update_icon()

/obj/structure/fireaxecabinet/attackby(obj/item/I, mob/user, params)
	if(isrobot(user) || istype(I,/obj/item/device/multitool))
		toggle_lock(user)
		return
	if(open || glass_hp <= 0)
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
		else if(glass_hp > 0)
			toggle_open()

	else if(istype(I, /obj/item/weapon))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/W = I
		user.do_attack_animation(src)
		playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
		if(W.force >= 10)
			glass_hp -= W.force
			if(glass_hp <= 0)
				playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)
			update_icon()
		else
			user << "<span class='warning'>The [name]'s protective glass glances off the hit.</span>"

/obj/structure/fireaxecabinet/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50) && fireaxe)
				fireaxe.loc = src.loc
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/fireaxecabinet/bullet_act(obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(Proj.damage)
			glass_hp -= Proj.damage
			if(glass_hp <= 0)
				playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)
		update_icon()

/obj/structure/fireaxecabinet/blob_act()
	if(prob(75) && fireaxe)
		fireaxe.loc = src.loc
		qdel(src)

/obj/structure/fireaxecabinet/attack_hand(mob/user)
	if(open || glass_hp <= 0)
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

/obj/structure/fireaxecabinet/attack_paw(mob/user)
	if(ismonkey(user)) //no fire-axe wielding aliens allowed
		attack_hand(user)
	return

/obj/structure/fireaxecabinet/attack_ai(mob/user)
	toggle_lock(user)
	return

/obj/structure/fireaxecabinet/update_icon()
	overlays.Cut()
	if(fireaxe)
		overlays += "axe"
	if(!open)
		switch(glass_hp)
			if(-INFINITY to 0)
				overlays += "glass4"
			if(1 to 20)
				overlays += "glass3"
			if(21 to 40)
				overlays += "glass2"
			if(41 to 59)
				overlays += "glass1"
			if(60)
				overlays += "glass"
		if(locked)
			overlays += "locked"
		else
			overlays += "unlocked"
	else
		overlays += "glass_raised"

/obj/structure/fireaxecabinet/proc/toggle_lock(mob/user)
	user << "<span class = 'caution'> Resetting circuitry...</span>"
	playsound(src, 'sound/machines/locktoggle.ogg', 50, 1)
	if(do_after(user, 20, target = src))
		user << "<span class='caution'>You [locked ? "disable" : "re-enable"] the locking modules.</span>"
		locked = !locked
		update_icon()

/obj/structure/fireaxecabinet/verb/toggle_open() //nice name, huh? HUH?! -Erro //YEAH -Agouri
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