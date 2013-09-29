/obj/item/weapon/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = 2.0

	m_amt = 50
	g_amt = 50
	origin_tech = "engineering=1"

	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT

	var/obj/item/device/toner/ink = null

	New()
		ink = new /obj/item/device/toner(src)

	proc/use(mob/user as mob)
		if(!ink)
			user << "<span class='notice'>There is no toner cardridge installed installed in \the [name]!</span>"
			return 0
		else if(ink.charges < 1)
			user << "<span class='notice'>\the [name] is out of ink!.</span>"
			return 0
		else
			ink.charges--
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1)
			return 1

	examine()
		..()
		if(!ink)
			usr << "<span class='notice'>It doesn't have a toner cardridge installed.</span>"
			return
		var/ink_level = "high"
		if(ink.charges < 1)
			ink_level = "empty"
		else if((ink.charges/ink.max_charges) <= 0.25) //25%
			ink_level = "low"
		else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
			ink_level = "dangerously high"
		usr << "<span class='notice'>Its ink levels look [ink_level].</span>"

	attackby(obj/item/weapon/W, mob/user)
		..()
		if(istype(W, /obj/item/device/toner))
			if(ink)
				user << "<span class='notice'>\the [name] already contains \a [ink].</span>"
				return
			user.drop_item()
			W.loc = src
			user << "<span class='notice'>You install \the [W] into \the [name].</span>"
			ink = W
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)


	attack_self(mob/user)
		if(ink)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			ink.loc = user.loc
			user.put_in_hands(ink)
			user << "<span class='notice'>You remove \the [ink] from \the [name].</span>"
			ink = null
