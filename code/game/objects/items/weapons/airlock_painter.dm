/obj/item/weapon/airlock_painter
	name = "airlock painter"
	desc = "This device can change the paintjob of an airlock assembly."
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

	proc/use()
		if(!ink || ink.charges < 1)
			return 0
		else
			ink.charges--
			return 1

	examine()
		set src in usr
		var/ink_level = "high"
		if(!ink || ink.charges < 1)
			ink_level = "empty"
		else if((ink.charges/ink.max_charges) <= 0.25) //25%
			ink_level = "low"
		else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
			ink_level = "dangerously high"
		usr << "\icon[src] [src.name] is a small but effective airlock painting tool. Its ink levels look [ink_level]."
		return

