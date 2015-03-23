//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fireaxe cabinet"
	desc = "A small label reads 'For Emergency use only', accompanied with pictograms detailing safe usages for the included fireaxe. As if."
	var/obj/item/weapon/fireaxe/fireaxe = new/obj/item/weapon/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	density = 0
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	var/smashed = 0
	locked = 1

/obj/structure/closet/fireaxecabinet/examine(mob/user)

	..()
	if(smashed)
		user << "The protective glass shield has been damaged beyond repair"
	else if(hitstaken)
		user << "You count [hitstaken] impacts on the protective glass shield"
	else
		user << "The protective glass shield appears intact"
	if(!fireaxe)
		user << "The fireaxe is gone from the cabinet"
	else
		user << "The fireaxe is still in the cabinet [localopened ? "and up for grabs" : "behind the protective glass"]"

	user << "A small [locked ? "red" : "green"] light indicates the cabinet is [locked ? "" : "un"]locked"

/obj/structure/closet/fireaxecabinet/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri

	user.delayNextAttack(10) //Whatever we do here, no clicking around for the user for at least one second

	var/hasaxe = 0       //gonna come in handy later~
	if(fireaxe)
		hasaxe = 1

	if(isrobot(usr) || src.locked)
		if(istype(O, /obj/item/device/multitool))
			visible_message("<span class='notice'>[user] starts fiddling with \the [src]'s locking module</span>", \
			"<span class='notice'>You start disabling \the [src]'s locking module</span>")
			playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
			if(do_after(user, 50))
				locked = 0
				visible_message("<span class='notice'>[user] disables \the [src]'s locking module.</span>", "<span class='notice'>You disable \the [src]'s locking module.</span>")
				update_icon()
		if(istype(O, /obj/item/weapon))
			var/obj/item/weapon/W = O
			if(smashed || localopened) //We're putting the axe back in
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
				return
			else //We are hitting the closet
				if(W.force < 15)
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
					visible_message("<span class='notice'>\The [src]'s protective glass glances off [user]'s hit with \the [O].")
				else
					hitstaken++
					if(hitstaken == 4) //Slam
						playsound(user, 'sound/effects/Glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
						visible_message("<span class='warning'>\The [src]'s protective glass shatters, exposing its content.")
						smashed = 1
						locked = 0
						localopened = 1
					else //We have yet to break the closet, so glass hiting sound and damage message
						visible_message("<span class='warning'>[user] damages \the [src]'s protective glass with \the [O].")
						playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
				update_icon()
		return
	if(istype(O, /obj/item/weapon/fireaxe) && src.localopened)
		if(!fireaxe)
			var/obj/item/weapon/fireaxe/F = O
			if(F.wielded)
				user << "<span class='warning'>Unwield [F] first!</span>"
				return
			fireaxe = O
			user.drop_item(src)
			visible_message("<span class='notice'>[user] places [F] back into [src].</span>", \
			"<span class='notice'>You place [F] back into [src].</span>")
			update_icon()
		else
			if(smashed)
				user << "<span class='warning'>[src]'s protective glass is broken. Cutting hazard right there!</span>"
				return
			if(istype(O, /obj/item/device/multitool))
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
					return
				else
					visible_message("<span class='notice'>[user] starts to fiddle with [src]'s locking module</span>", \
					"<span class='notice'>You start to re-enable [src]'s locking module</span>")
					if(do_after(user, 50))
						locked = 1
						visible_message("<span class='notice'>[user] re-enables [src]'s locking module.</span>", \
						"<span class='notice'>You re-enable [src]'s locking module.</span>")
						playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
						update_icon()
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
						update_icon()
				else
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
	else
		if(smashed)
			return
		else
			localopened = !localopened
			if(localopened)
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
				spawn(10)
					update_icon()
			else
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
				spawn(10)
					update_icon()

/obj/structure/closet/fireaxecabinet/attack_hand(mob/user as mob)

	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1

	if(locked)
		user <<"<span class='warning'>[src] is locked tight!</span>"
		return
	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			visible_message("<span class='notice'>[user] takes [fireaxe] from [src].</span>", \
			"<span class='notice'>You take [fireaxe] from [src].</span>")
			fireaxe = null
			add_fingerprint(user)
			update_icon()
		else
			if(smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
						update_icon()
				else
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
			spawn(10)
				update_icon()
		else
			icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
			spawn(10)
				update_icon()

/obj/structure/closet/fireaxecabinet/verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
	set name = "Open/Close"
	set category = "Object"

	if(isrobot(usr) || locked || smashed)
		if(locked)
			usr << "<span class='warning'>\The [src] is locked tight!</span>"
		else if(smashed)
			usr << "<span class='notice'>\The [src]'s protective glass is broken!</span>"
		return

	localopened = !localopened
	update_icon()

/obj/structure/closet/fireaxecabinet/verb/remove_fire_axe()
	set name = "Remove Fire Axe"
	set category = "Object"

	if(isrobot(usr))
		return

	if(localopened)
		if(fireaxe)
			usr.put_in_hands(fireaxe)
			visible_message("<span class='notice'>[usr] takes [fireaxe] from \the [src].</span>", \
			"<span class='notice'>You take [fireaxe] from \the [src].</span>")
			fireaxe = null
		else
			usr << "<span class='notice'>\The [src] is empty.</span>"
	else
		usr << "<span class='notice'>\The [src] is closed.</span>"
	update_icon()

/obj/structure/closet/fireaxecabinet/attack_paw(mob/user as mob)
	attack_hand(user)
	return

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(isobserver(user))
		return //NO. FUCK OFF.
	if(smashed)
		user << "<span class='warning'>\The [src]'s security protocols have locked down its electronic systems. Might have to do with the smashed glass.</span>"
		return
	else
		locked = !locked
		if(locked)
			visible_message("<span class='notice'>[user] locks \the [src]</span>", \
			"<span class='notice'>You lock [src]</span>")
		else
			visible_message("<span class='notice'>[user] unlocks \the [src]</span>", \
			"<span class='notice'>You unlock [src]</span>")
		return

/obj/structure/closet/fireaxecabinet/update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1
	icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]"

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return

/obj/structure/closet/fireaxecabinet/Destroy()
	if(fireaxe)
		visible_message("<span class='notice'>The fireaxe noisily ricochets off the ground as it slides out of \the [src].</span>")
		fireaxe.loc = get_turf(src) //Save the axe from destruction
	..()
