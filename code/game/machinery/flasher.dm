// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/obj/item/device/flash/bulb = null
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1-p"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1

/obj/machinery/flasher/New()
	bulb = new /obj/item/device/flash(src)

/obj/machinery/flasher/power_change()
	if (powered() && anchored && bulb)
		stat &= ~NOPOWER
		if(bulb.broken)
			icon_state = "[base_state]1-p"
		else
			icon_state = "[base_state]1"
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wirecutters))
		if (bulb)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] has disconnected [src]'s flashbulb!</span>", "<span class='notice'>You disconnect [src]'s flashbulb!</span>")
			bulb.loc = src.loc
			bulb = null
			power_change()

	else if (istype(W, /obj/item/device/flash))
		if (!bulb)
			user.visible_message("<span class='notice'>[user] installs [W] into [src].</span>", "<span class='notice'>You install [W] into [src].</span>")
			user.drop_item()
			W.loc = src
			bulb = W
			power_change()
		else
			user << "<span class='notice'>A flashbulb is already installed in [src].</span>"
	add_fingerprint(user)

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (anchored)
		return flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!powered() || !bulb)
		return

	if (bulb.broken || (last_flash && world.time < src.last_flash + 150))
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	last_flash = world.time
	use_power(1000)

	for (var/mob/O in viewers(src, null))
		if (get_dist(src, O) > src.range)
			continue

		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			if(!H.eyecheck() <= 0)
				continue

		if (istype(O, /mob/living/carbon/alien))//So aliens don't get flashed (they have no external eyes)/N
			continue

		O.Weaken(strength)
		if ((O.eye_stat > 15 && prob(O.eye_stat + 50)))
			flick("e_flash", O:flash)
			O.eye_stat += rand(1, 2)
		else
			if(!O.blinded)
				flick("flash", O:flash)
				O.eye_stat += rand(0, 2)
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

/obj/machinery/flasher/portable/flash()
	if(!..())
		return
	if(prob(4))	//Small chance to burn out on use
		bulb.burn_out()
		power_change()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)

		if (!anchored && !isinspace())
			user << "<span class='notice'>[src] is now secured.</span>"
			overlays += "[base_state]-s"
			anchored = 1
			power_change()
		else
			user << "<span class='notice'>[src] can now be moved.</span>"
			overlays.Cut()
			anchored = 0
			power_change()

	else
		..()

/obj/machinery/flasher_button/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/flasher_button/attackby(obj/item/weapon/W, mob/user)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in world)
		if(M.id == id)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return