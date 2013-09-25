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
	//var/active = 0

	New()
		ink = new /obj/item/device/toner(src)

	proc/use()
		if(/*!active ||*/ !ink || ink.charges < 1)
			return 0
		else
			ink.charges--
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1)
			return 1

	examine()
		var/ink_level = "high"
		if(!ink || ink.charges < 1)
			ink_level = "empty"
		else if((ink.charges/ink.max_charges) <= 0.25) //25%
			ink_level = "low"
		else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
			ink_level = "dangerously high"
		..()
		//set src in usr
		usr << "<span class='notice'>Its ink levels look [ink_level].</span>"
		return

	attackby(obj/item/weapon/W, mob/user)
		..()
		if(istype(W, /obj/item/device/toner))
			if(ink)
				user << "<span class='notice'>The airlock painter already contains a toner cardridge.</span>"
				return
			user.drop_item()
			W.loc = src
			ink = W
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user << "<span class='notice'>You install the toner cardridge into the airlock painter.</span>"


	attack_self(mob/user)
		//Change the mode
		if(ink)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			var/turf/T = loc
			if(ismob(T))
				T = T.loc
			ink.loc = T
			ink = null
			user << "<span class='notice'>You remove the toner cardridge from the airlock painter.</span>"
