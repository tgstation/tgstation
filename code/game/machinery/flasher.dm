<<<<<<< HEAD
// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/obj/item/device/assembly/flash/handheld/bulb = null
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 5 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1-p"
	strength = 4
	anchored = 0
	base_state = "pflash"
	density = 1

/obj/machinery/flasher/New(loc, ndir = 0, built = 0)
	..() // ..() is EXTREMELY IMPORTANT, never forget to add it
	if(built)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -28 : 28)
		pixel_y = (dir & 3)? (dir ==1 ? -28 : 28) : 0
	else
		bulb = new /obj/item/device/assembly/flash/handheld(src)

/obj/machinery/flasher/Move()
	remove_from_proximity_list(src, range)
	..()

/obj/machinery/flasher/power_change()
	if (powered() && anchored && bulb)
		stat &= ~NOPOWER
		if(bulb.crit_fail)
			icon_state = "[base_state]1-p"
		else
			icon_state = "[base_state]1"
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/weapon/wirecutters))
		if (bulb)
			user.visible_message("[user] begins to disconnect [src]'s flashbulb.", "<span class='notice'>You begin to disconnect [src]'s flashbulb...</span>")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			if(do_after(user, 30/W.toolspeed, target = src) && bulb)
				user.visible_message("[user] has disconnected [src]'s flashbulb!", "<span class='notice'>You disconnect [src]'s flashbulb.</span>")
				bulb.loc = src.loc
				bulb = null
				power_change()

	else if (istype(W, /obj/item/device/assembly/flash/handheld))
		if (!bulb)
			if(!user.drop_item())
				return
			user.visible_message("[user] installs [W] into [src].", "<span class='notice'>You install [W] into [src].</span>")
			W.loc = src
			bulb = W
			power_change()
		else
			user << "<span class='warning'>A flashbulb is already installed in [src]!</span>"

	else if (istype(W, /obj/item/weapon/wrench))
		if(!bulb)
			user << "<span class='notice'>You start unsecuring the flasher frame...</span>"
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 40/W.toolspeed, target = src))
				user << "<span class='notice'>You unsecure the flasher frame.</span>"
				var/obj/item/wallframe/flasher/F = new(get_turf(src))
				transfer_fingerprints_to(F)
				F.id = id
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				qdel(src)
		else
			user << "<span class='warning'>Remove a flashbulb from [src] first!</span>"
	else
		return ..()

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (anchored)
		return flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!powered() || !bulb)
		return

	if (bulb.crit_fail || (last_flash && world.time < src.last_flash + 150))
		return

	if(!bulb.flash_recharge(30)) //Bulb can burn out if it's used too often too fast
		power_change()
		return
	bulb.times_used ++

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	last_flash = world.time
	use_power(1000)

	for (var/mob/living/L in viewers(src, null))
		if (get_dist(src, L) > range)
			continue

		if(L.flash_eyes(affect_silicon = 1))
			L.Weaken(strength)
			if(L.weakeyes)
				L.Weaken(strength * 1.5)
				L.visible_message("<span class='disarm'><b>[L]</b> gasps and shields their eyes!</span>")

	return 1


/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(bulb && prob(75/severity))
		flash()
		bulb.burn_out()
		power_change()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM)
	if (last_flash && world.time < last_flash + 150)
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.m_intent != "walk" && anchored)
			flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)

		if (!anchored && !isinspace())
			user << "<span class='notice'>[src] is now secured.</span>"
			add_overlay("[base_state]-s")
			anchored = 1
			power_change()
			add_to_proximity_list(src, range)
		else
			user << "<span class='notice'>[src] can now be moved.</span>"
			cut_overlays()
			anchored = 0
			power_change()
			remove_from_proximity_list(src, range)

	else
		return ..()


/obj/item/wallframe/flasher
	name = "mounted flash frame"
	desc = "Used for building wall-mounted flashers."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash_frame"
	result_path = /obj/machinery/flasher
	var/id = null

/obj/item/wallframe/flasher/examine(mob/user)
	..()
	user << "<span class='notice'>Its channel ID is '[id]'.</span>"

/obj/item/wallframe/flasher/after_attach(var/obj/O)
	..()
	var/obj/machinery/flasher/F = O
	F.id = id
=======
// It is a gizmo that flashes a small area
var/list/obj/machinery/flasher/flashers = list()

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id_tag = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1
	ghost_read=0
	ghost_write=0
	min_harm_label = 15 //Seems low, but this is going by the sprite. May need to be changed for balance.
	harm_label_examine = list("<span class='info'>A label is on the bulb, but doesn't cover it.</span>", "<span class='warning'>A label covers the bulb!</span>")

	flags = FPRINT | PROXMOVE

/obj/machinery/flasher/New()
	..()
	flashers += src

/obj/machinery/flasher/Destroy()
	..()
	flashers -= src

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1
	min_harm_label = 35 //A lot. Has to wrap around the bulb, after all.

/*
/obj/machinery/flasher/New()
	sleep(4)					//<--- What the fuck are you doing? D=
	src.sd_SetLuminosity(2)
*/
/obj/machinery/flasher/power_change()
	if ( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"
//		src.sd_SetLuminosity(0)

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswirecutter(W))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("<span class='warning'>[user] has disconnected the [src]'s flashbulb!</span>", "<span class='warning'>You disconnect the [src]'s flashbulb!</span>")
		if (!src.disable)
			user.visible_message("<span class='warning'>[user] has connected the [src]'s flashbulb!</span>", "<span class='warning'>You connect the [src]'s flashbulb!</span>")

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (src.anchored)
		return src.flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1)
	src.last_flash = world.time
	use_power(1000)
	if(harm_labeled >= min_harm_label)	return //Still "flashes," so power is used and the noise is made, etc., but it doesn't actually flash anyone.
	flick("[base_state]_flash", src)

	for (var/mob/O in viewers(src, null))
		if(isobserver(O)) continue
		if (get_dist(src, O) > src.range)
			continue

		if (istype(O, /mob/living/carbon/alien))//So aliens don't get flashed (they have no external eyes)/N
			continue
		if(istype(O, /mob/living))
			var/mob/living/L = O
			L.flash_eyes(affect_silicon = 1)
		if(istype(O, /mob/living/carbon))
			var/mob/living/carbon/C = O
			if(C.eyecheck() <= 0) // Identical to handheld flash safety check
				C.Weaken(strength)
		else
			O.Weaken(strength)


/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if ((M.m_intent != "walk") && (src.anchored))
			src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswrench(W))
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			user.show_message(text("<span class='warning'>[src] can now be moved.</span>"))
			src.overlays.len = 0

		else if (src.anchored)
			user.show_message(text("<span class='warning'>[src] is now secured.</span>"))
			src.overlays += image(icon = icon, icon_state = "[base_state]-s")

/obj/machinery/flasher_button/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/flasher_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/flasher_button/attackby(obj/item/weapon/W, mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in flashers)
		if(M.id_tag == src.id_tag)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
