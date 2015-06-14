//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/weapon/twohanded/fireaxe/fireaxe = new/obj/item/weapon/twohanded/fireaxe
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe1000"
	anchored = 1
	density = 0
	wall_mounted = 1
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	locked = 1
	var/smashed = 0

/obj/structure/closet/fireaxecabinet/attackby(var/obj/item/O as obj, var/mob/living/user as mob, params)  //Marker -Agouri
	//..() //That's very useful, Erro

	var/hasaxe = 0       //gonna come in handy later~
	if(fireaxe)
		hasaxe = 1

	if (isrobot(user) || src.locked)
		if(istype(O, /obj/item/device/multitool))
			user << "<span class = 'caution'> Resetting circuitry...</span>"
			playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
			if(do_after(user, 20))
				src.locked = 0
				user << "<span class = 'caution'> You disable the locking modules.</span>"
				update_icon()
			return
		else if(istype(O, /obj/item/weapon))
			user.changeNext_move(CLICK_CD_MELEE)
			var/obj/item/weapon/W = O
			if(src.smashed || src.localopened)
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]closing"
					spawn(10) update_icon()
				return
			else
				user.do_attack_animation(src)
				playsound(user, 'sound/effects/Glasshit.ogg', 100, 1) //We don't want this playing every time
			if(W.force < 15)
				user << "<span class = 'warning'> The cabinet's protective glass glances off the hit.</span>"
			else
				src.hitstaken++
				if(src.hitstaken == 4)
					playsound(user, 'sound/effects/Glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
					src.smashed = 1
					src.locked = 0
					src.localopened = 1
			update_icon()
		return
	if (istype(O, /obj/item/weapon/twohanded/fireaxe) && src.localopened)
		if(!fireaxe)
			if(O:wielded)
				user << "<span class = 'warning'> Unwield the axe first.</span>"
				return
			if(!user.drop_item())
				return
			fireaxe = O
			src.contents += O
			user << "<span class = 'caution'> You place the fire axe back in the [src.name].</span>"
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]opening"
					spawn(10) update_icon()
				else
					icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]closing"
					spawn(10) update_icon()
	else
		if(src.smashed)
			return
		if(istype(O, /obj/item/device/multitool))
			if(localopened)
				localopened = 0
				icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]closing"
				spawn(10) update_icon()
				return
			else
				user << "<span class = 'caution'> Resetting circuitry...</span>"
				playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
				if(do_after(user, 20))
					src.locked = 1
					user << "<span class = 'caution'> You re-enable the locking modules.</span>"
				return
		else
			localopened = !localopened
			if(localopened)
				icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]opening"
				spawn(10) update_icon()
			else
				icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]closing"
				spawn(10) update_icon()


/obj/structure/closet/fireaxecabinet/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				if(fireaxe)
					fireaxe.loc = src.loc
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/closet/fireaxecabinet/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		if(Proj.damage >= 15 && !smashed && !localopened)
			hitstaken++
		if(health <= 0)
			if(fireaxe)
				fireaxe.loc = src.loc
			qdel(src)
			return
		if(hitstaken >= 4)
			playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)
			smashed = 1
			locked = 0
			localopened = 1
		update_icon()

/obj/structure/closet/fireaxecabinet/blob_act()
	if(prob(75))
		if(fireaxe)
			fireaxe.loc = src.loc
			qdel(src)


/obj/structure/closet/fireaxecabinet/attack_hand(mob/user as mob)
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1

	if(src.locked)
		user <<"<span class = 'warning'> The cabinet won't budge!</span>"
		return
	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			fireaxe = null
			user << "<span class = 'caution'> You take the fire axe from the [name].</span>"
			src.add_fingerprint(user)
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					src.icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]opening"
					spawn(10) update_icon()
				else
					src.icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]closing"
					spawn(10) update_icon()

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			src.icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]opening"
			spawn(10) update_icon()
		else
			src.icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]closing"
			spawn(10) update_icon()

/obj/structure/closet/fireaxecabinet/attack_tk(mob/user as mob)
	if(localopened && fireaxe)
		fireaxe.loc = loc
		user << "<span class = 'caution'> You telekinetically remove the fire axe.</span>"
		fireaxe = null
		update_icon()
		return
	attack_hand(user)

/obj/structure/closet/fireaxecabinet/verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
	set name = "Open/Close"
	set category = "Object"

	if (isrobot(usr) || src.locked || src.smashed)
		if(src.locked)
			usr << "<span class='danger'>The cabinet won't budge!</span>"
		else if(src.smashed)
			usr << "<span class='notice'>The protective glass is broken!</span>"
		return

	localopened = !localopened
	update_icon()

/obj/structure/closet/fireaxecabinet/verb/remove_fire_axe()
	set name = "Remove Fire Axe"
	set category = "Object"

	if (isrobot(usr))
		return

	if (localopened)
		if(fireaxe)
			usr.put_in_hands(fireaxe)
			fireaxe = null
			usr << "<span class='notice'>You take the Fire axe from the [name].</span>"
		else
			usr << "<span class='notice'>The [src.name] is empty.</span>"
	else
		usr << "<span class='notice'>The [src.name] is closed.</span>"
	update_icon()

/obj/structure/closet/fireaxecabinet/attack_paw(mob/user as mob)
	attack_hand(user)
	return

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(src.smashed)
		user << "<span class = 'warning'> The security of the cabinet is compromised.</span>"
		return
	else
		locked = !locked
		if(locked)
			user << "<span class = 'caution'> Cabinet locked.</span>"
		else
			user << "<span class = 'caution'> Cabinet unlocked.</span>"
		return

/obj/structure/closet/fireaxecabinet/update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1
	icon_state = "fireaxe[hasaxe][src.localopened][src.hitstaken][src.smashed]"

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return
