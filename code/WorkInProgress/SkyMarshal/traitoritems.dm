/obj/item/weapon/stamperaser
	name = "eraser"
	desc = "It looks like some kind of eraser."
	flags = FPRINT | TABLEPASS
	icon = 'items.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	w_class = 1.0
	m_amt = 80
/*
/obj/item/device/jammer
	name = "strange device"
	desc = "It blinks and has an antenna on it.  Weird."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT|TABLEPASS
	w_class = 1
	var
		list/obj/item/device/radio/Old = list()
		list/obj/item/device/radio/Curr = list()
		time_remaining = 5

/obj/item/device/jammer/New()
	..()
	time_remaining = rand(10,20) // ~2-4 BYOND seconds of use.
	return

/obj/item/device/jammer/attack_self(mob/user)

	if(time_remaining > 0)
		on = !on
		icon_state = "t-ray[on]"

		if(on)
			processing_objects.Add(src)
	else
		on = 0
		icon_state = "t-ray0"
		user << "It's fried itself from overuse!"
		if(Old)
			for(var/obj/item/device/radio/T in Old)
				T.scrambleoverride = 0
			Old = null
			Curr = null


/obj/item/device/jammer/process()
	if(!on)
		processing_objects.Remove(src)
		return null

	Old = Curr
	Curr = list()

	for(var/obj/item/device/radio/T in range(3, src.loc) )

		T.scrambleoverride = 1
		Curr |= T
		for(var/obj/item/device/radio/V in Old)
			if(V == T)
				Old -= V
				break

	for(var/obj/item/device/radio/T in Old)
		T.scrambleoverride = 0

	time_remaining--
	if(time_remaining <= 0)
		for(var/mob/O in viewers(src))
			O.show_message("\red You hear a loud pop, like circuits frying.", 1)
		on = 0
		icon_state = "t-ray0"

	sleep(2)
	*/