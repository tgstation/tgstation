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
	var/strength = 100 //How knocked down targets are when flashed.
	var/base_state = "mflash"
	max_integrity = 250
	integrity_failure = 100
	anchored = TRUE

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1-p"
	strength = 80
	anchored = FALSE
	base_state = "pflash"
	density = TRUE

/obj/machinery/flasher/New(loc, ndir = 0, built = 0)
	..() // ..() is EXTREMELY IMPORTANT, never forget to add it
	if(built)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -28 : 28)
		pixel_y = (dir & 3)? (dir ==1 ? -28 : 28) : 0
	else
		bulb = new /obj/item/device/assembly/flash/handheld(src)

/obj/machinery/flasher/Destroy()
	if(bulb)
		qdel(bulb)
		bulb = null
	return ..()

/obj/machinery/flasher/power_change()
	if (powered() && anchored && bulb)
		stat &= ~NOPOWER
		if(bulb.crit_fail)
			icon_state = "[base_state]1-p"
		else
			icon_state = "[base_state]1"
	else
		stat |= NOPOWER
		icon_state = "[base_state]1-p"

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/weapon/wirecutters))
		if (bulb)
			user.visible_message("[user] begins to disconnect [src]'s flashbulb.", "<span class='notice'>You begin to disconnect [src]'s flashbulb...</span>")
			playsound(src.loc, W.usesound, 100, 1)
			if(do_after(user, 30*W.toolspeed, target = src) && bulb)
				user.visible_message("[user] has disconnected [src]'s flashbulb!", "<span class='notice'>You disconnect [src]'s flashbulb.</span>")
				bulb.forceMove(loc)
				bulb = null
				power_change()

	else if (istype(W, /obj/item/device/assembly/flash/handheld))
		if (!bulb)
			if(!user.drop_item())
				return
			user.visible_message("[user] installs [W] into [src].", "<span class='notice'>You install [W] into [src].</span>")
			W.forceMove(src)
			bulb = W
			power_change()
		else
			to_chat(user, "<span class='warning'>A flashbulb is already installed in [src]!</span>")

	else if (istype(W, /obj/item/weapon/wrench))
		if(!bulb)
			to_chat(user, "<span class='notice'>You start unsecuring the flasher frame...</span>")
			playsound(loc, W.usesound, 50, 1)
			if(do_after(user, 40*W.toolspeed, target = src))
				to_chat(user, "<span class='notice'>You unsecure the flasher frame.</span>")
				deconstruct(TRUE)
		else
			to_chat(user, "<span class='warning'>Remove a flashbulb from [src] first!</span>")
	else
		return ..()

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (anchored)
		return flash()

/obj/machinery/flasher/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 10) //any melee attack below 10 dmg does nothing
		return 0
	. = ..()

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

		if(L.flash_act(affect_silicon = 1))
			L.Knockdown(strength)

	return 1


/obj/machinery/flasher/emp_act(severity)
	if(!(stat & (BROKEN|NOPOWER)))
		if(bulb && prob(75/severity))
			flash()
			bulb.burn_out()
			power_change()
	..()

/obj/machinery/flasher/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			stat |= BROKEN
			if(bulb)
				bulb.burn_out()
				power_change()

/obj/machinery/flasher/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(bulb)
			bulb.forceMove(loc)
			bulb = null
		if(disassembled)
			var/obj/item/wallframe/flasher/F = new(get_turf(src))
			transfer_fingerprints_to(F)
			F.id = id
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
		else
			new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/machinery/flasher/portable/Initialize()
	. = ..()
	proximity_monitor = new(src, 0)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM)
	if (last_flash && world.time < last_flash + 150)
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.m_intent != MOVE_INTENT_WALK && anchored)
			flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, W.usesound, 100, 1)

		if (!anchored && !isinspace())
			to_chat(user, "<span class='notice'>[src] is now secured.</span>")
			add_overlay("[base_state]-s")
			anchored = TRUE
			power_change()
			proximity_monitor.SetRange(range)
		else
			to_chat(user, "<span class='notice'>[src] can now be moved.</span>")
			cut_overlays()
			anchored = FALSE
			power_change()
			proximity_monitor.SetRange(0)

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
	to_chat(user, "<span class='notice'>Its channel ID is '[id]'.</span>")

/obj/item/wallframe/flasher/after_attach(var/obj/O)
	..()
	var/obj/machinery/flasher/F = O
	F.id = id
