/obj/item/device/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	w_class = 2
	var/obj/item/organ/internal/cyberimp/storedorgan

/obj/item/device/autoimplanter/attack_self(mob/user)//when the object it used...
	if(!storedorgan)
		user << "<span class='notice'>[src] currently has no implant stored.</span>"
		return
	storedorgan.Insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	storedorgan = null

/obj/item/device/autoimplanter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/internal/cyberimp))
		if(storedorgan)
			user << "<span class='notice'>[src] already has an implant stored.</span>"
			return
		if(!user.drop_item())
			return
		I.loc = src
		storedorgan = I
		user << "<span class='notice'>You insert the [I] into [src].</span>"
	else if(istype(I, /obj/item/weapon/screwdriver))
		if(!storedorgan)
			user << "<span class='notice'>There's no implant in [src] for you to remove.</span>"
		else
			var/turf/floorloc = get_turf(user)
			floorloc.contents += contents
			user << "<span class='notice'>You remove the [storedorgan] from [src].</span>"
			storedorgan = null
