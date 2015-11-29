/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = 4.0
	canhear_range = 2
	var/number = 0
	var/anyai = 1
	var/circuitry_installed=1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck
	var/buildstage = 0

/obj/item/device/radio/intercom/universe/New()
	tag = "UNIVERSE"
	return ..()

/obj/item/device/radio/intercom/New(turf/loc, var/ndir = 0, var/building = 3)
	..()
	buildstage = building
	if(buildstage)
		processing_objects.Add(src)
	else
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 : -28)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 : -28) : 0
		dir=ndir
		b_stat=1
		on = 0
	update_icon()

/obj/item/device/radio/intercom/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on || b_stat || isWireCut(WIRE_RECEIVE))
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq == SYND_FREQ)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && !src.anyai && !(speech.speaker in src.ai))
		return
	..()

/obj/item/device/radio/intercom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	switch(buildstage)
		if(3)
			if(iswirecutter(W) && b_stat && wires.IsAllCut())
				to_chat(user, "<span class='notice'>You cut out the intercoms wiring and disconnect its electronics.</span>")
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				if(do_after(user, src, 10))
					new /obj/item/stack/cable_coil(get_turf(src),5)
					on = 0
					b_stat = 1
					buildstage = 1
					update_icon()
					processing_objects.Remove(src)
				return 1
			else return ..()
		if(2)
			if(isscrewdriver(W))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src, 10))
					update_icon()
					on = 1
					b_stat = 0
					buildstage = 3
					to_chat(user, "<span class='notice'>You secure the electronics!</span>")
					update_icon()
					processing_objects.Add(src)
					for(var/i, i<= 5, i++)
						wires.UpdateCut(i,1)
				return 1
		if(1)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 5)
					to_chat(user, "<span class='warning'>You need more cable for this!</span>")
					return
				if(do_after(user, src, 10))
					coil.use(5)
					to_chat(user, "<span class='notice'>You wire \the [src]!</span>")
					buildstage = 2
				return 1
			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You begin removing the electronics...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 10))
					new /obj/item/weapon/intercom_electronics(get_turf(src))
					to_chat(user, "<span class='notice'>The circuitboard pops out!</span>")
					buildstage = 0
				return 1
		if(0)
			if(istype(W,/obj/item/weapon/intercom_electronics))
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 10))
					qdel(W)
					to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]!</span>")
					buildstage = 1
				return 1
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT=W
				playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
				if(!WT.remove_fuel(3, user))
					to_chat(user, "<span class='warning'>You're out of welding fuel.</span>")
					return 1
				if(do_after(user, src, 10))
					to_chat(user, "<span class='notice'>You cut the intercom frame from the wall!</span>")
					new /obj/item/mounted/frame/intercom(get_turf(src))
					qdel(src)
					return 1

/obj/item/device/radio/intercom/update_icon()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday
		if(!areaMaster)
			on = 0
			update_icon()
			return
		on = areaMaster.powered(EQUIP) // set "on" to the power status
		update_icon()

/obj/item/weapon/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = 2.0
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
