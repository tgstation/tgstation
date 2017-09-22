#define INFINITE -1

/obj/item/device/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/uses = INFINITE
	var/starting_organ

/obj/item/device/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/device/autosurgeon/proc/insert_organ(var/obj/item/I)
	storedorgan = I
	I.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/device/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, "<span class='warning'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return
	else if(!storedorgan)
		to_chat(user, "<span class='notice'>[src] currently has no implant stored.</span>")
		return
	storedorgan.Insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/device/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/device/autosurgeon/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] already has an implant stored.</span>")
			return
		else if(!uses)
			to_chat(user, "<span class='notice'>[src] has already been used up.</span>")
			return
		if(!user.drop_item())
			return
		I.forceMove(src)
		storedorgan = I
		to_chat(user, "<span class='notice'>You insert the [I] into [src].</span>")
	else if(istype(I, /obj/item/screwdriver))
		if(!storedorgan)
			to_chat(user, "<span class='notice'>There's no implant in [src] for you to remove.</span>")
		else
			var/turf/open/floorloc = get_turf(user)
			floorloc.contents += contents
			to_chat(user, "<span class='notice'>You remove the [storedorgan] from [src].</span>")
			playsound(get_turf(user), I.usesound, 50, 1)
			storedorgan = null
			if(uses != INFINITE)
				uses--
			if(!uses)
				desc = "[initial(desc)] Looks like it's been used up."

/obj/item/device/autosurgeon/cmo
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/medical


/obj/item/device/autosurgeon/thermal_eyes
	starting_organ = /obj/item/organ/eyes/robotic/thermals

/obj/item/device/autosurgeon/xray_eyes
	starting_organ = /obj/item/organ/eyes/robotic/xray

/obj/item/device/autosurgeon/anti_stun
	starting_organ = /obj/item/organ/cyberimp/brain/anti_stun

/obj/item/device/autosurgeon/reviver
	starting_organ = /obj/item/organ/cyberimp/chest/reviver
