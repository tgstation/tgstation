// SUIT STORAGE UNIT /////////////////close_machine(
/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial unit made to hold space suits. It comes with a built-in UV cauterization mechanism. A small warning label advises that organic matter should not be placed into the unit."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "close"
	anchored = 1
	density = 1

	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/storage = null

	var/suit_type = null
	var/helmet_type = null
	var/mask_type = null
	var/storage_type = null

	state_open = FALSE
	var/locked = FALSE
	panel_open = FALSE
	var/safeties = TRUE

	var/uv = FALSE
	var/uv_super = FALSE
	var/uv_cycles = 6

/obj/machinery/suit_storage_unit/standard_unit
	suit_type = /obj/item/clothing/suit/space/eva
	helmet_type = /obj/item/clothing/head/helmet/space/eva
	mask_type = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/captain
	suit_type = /obj/item/clothing/suit/space/captain
	helmet_type = /obj/item/clothing/head/helmet/space/captain
	mask_type = /obj/item/clothing/mask/gas
	storage_type = /obj/item/weapon/tank/jetpack/oxygen/captain

/obj/machinery/suit_storage_unit/engine
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine
	mask_type = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/ce
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/elite
	mask_type = /obj/item/clothing/mask/breath
	storage_type= /obj/item/clothing/shoes/magboots/advance

/obj/machinery/suit_storage_unit/security
	suit_type = /obj/item/clothing/suit/space/hardsuit/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/hos
	suit_type = /obj/item/clothing/suit/space/hardsuit/security/hos
	mask_type = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/atmos
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	mask_type = /obj/item/clothing/mask/gas
	storage_type = /obj/item/weapon/watertank/atmos

/obj/machinery/suit_storage_unit/mining
	suit_type = /obj/item/clothing/suit/hooded/explorer
	mask_type = /obj/item/clothing/mask/gas

/obj/machinery/suit_storage_unit/mining/eva
	suit_type = /obj/item/clothing/suit/space/hardsuit/mining
	mask_type = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/cmo
	suit_type = /obj/item/clothing/suit/space/hardsuit/medical
	mask_type = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/rd
	suit_type = /obj/item/clothing/suit/space/hardsuit/rd
	mask_type = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/syndicate
	suit_type = /obj/item/clothing/suit/space/hardsuit/syndi
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/weapon/tank/jetpack/oxygen/harness

/obj/machinery/suit_storage_unit/ert/command
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/security
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/sec
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/engineer
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/engi
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/medical
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/med
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/New()
	..()
	wires = new /datum/wires/suit_storage_unit(src)
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_icon()

/obj/machinery/suit_storage_unit/update_icon()
	overlays.Cut()

	if(uv)
		if(uv_super)
			overlays += "super"
		else if(occupant)
			overlays += "uvhuman"
		else
			overlays += "uv"
	else if(state_open)
		if(stat & BROKEN)
			overlays += "broken"
		else
			overlays += "open"
			if(suit)
				overlays += "suit"
			if(helmet)
				overlays += "helm"
			if(storage)
				overlays += "storage"
	else if(occupant)
		overlays += "human"

/obj/machinery/suit_storage_unit/power_change()
	..()
	if(!is_operational() && state_open)
		open_machine(dump = TRUE)
	update_icon()

/obj/machinery/suit_storage_unit/open_machine(dump = FALSE)
	state_open = TRUE
	if(dump)
		dropContents()
		helmet = null
		suit = null
		mask = null
		storage = null
		occupant = null
	update_icon()

/obj/machinery/suit_storage_unit/ex_act(severity, target)
	switch(severity)
		if(1)
			if(prob(50))
				open_machine(dump = TRUE)
			qdel(src)
		if(2)
			if(prob(50))
				open_machine(dump = TRUE)
				qdel(src)

/obj/machinery/suit_storage_unit/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !Adjacent(target))
		return

	if(!state_open)
		user << "<span class='warning'>The unit's doors are shut!</span>"
		return
	if(!is_operational())
		user << "<span class='warning'>The unit is not operational!</span>"
		return
	if(occupant || helmet || suit || storage)
		user << "<span class='warning'>It's too cluttered inside to fit in!</span>"
		return

	if(target == user)
		visible_message("<span class='warning'>[user] squeezes into [src]!</span>", "<span class='notice'>You squeeze into [src].</span>")
	else
		visible_message("<span class='warning'>[user] starts putting [target] into [src]!</span>", "<span class='userdanger'>[user] starts shoving you into [src]!</span>")

	if(do_mob(user, target, 10))
		close_machine(target)
		add_fingerprint(user)

/obj/machinery/suit_storage_unit/proc/cook()
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		locked = TRUE
		update_icon()
		if(occupant)
			if(uv_super)
				occupant.adjustFireLoss(rand(20, 36))
			else
				occupant.adjustFireLoss(rand(10, 16))
			if(iscarbon(occupant))
				occupant.emote("scream")
		addtimer(src, "cook", 50, FALSE)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_super)
			visible_message("<span class='warning'>With a loud whining noise, [src]'s door grinds open. A foul cloud of smoke emanates from the chamber.</span>")
			helmet = null
			qdel(helmet)
			suit = null
			qdel(suit) // Delete everything but the occupant.
			mask = null
			qdel(mask)
			storage = null
			qdel(storage)
			// The wires get damaged too.
			wires.cut_all()
		else
			visible_message("<span class='warning'>With a loud whining noise, [src]'s door grinds open. A light cloud of steam escapes from the chamber.</span>")
			for(var/obj/item/I in src)
				I.clean_blood()
		open_machine(dump = !!occupant)

/obj/machinery/suit_storage_unit/proc/shock(mob/user, prb)
	if(!prob(prb))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		if(electrocute_mob(user, src, src))
			return 1

/obj/machinery/suit_storage_unit/relaymove(mob/user)
	container_resist()

/obj/machinery/suit_storage_unit/container_resist()
	var/mob/living/user = usr
	add_fingerprint(user)
	if(locked)
		visible_message("<span class='notice'>You see [user] kicking against the doors of [src]!</span>", "<span class='notice'>You start kicking against the doors...</span>")
		addtimer(src, "resist_open", 300, FALSE, user)
	else
		open_machine(dump = TRUE)

/obj/machinery/suit_storage_unit/proc/resist_open(mob/user)
	if(!state_open && occupant && (user in src) && user.stat == 0) // Check they're still here.
		visible_message("<span class='notice'>You see [user] bursts out of [src]!</span>", "<span class='notice'>You escape the cramped confines of [src]!</span>")
		open_machine()

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(state_open && is_operational())
		if(istype(I, /obj/item/clothing/suit/space))
			if(suit)
				user << "<span class='warning'>The unit already contains a suit!.</span>"
				return
			if(!user.drop_item())
				return
			suit = I
		else if(istype(I, /obj/item/clothing/head/helmet))
			if(helmet)
				user << "<span class='warning'>The unit already contains a helmet!</span>"
				return
			if(!user.drop_item())
				return
			helmet = I
		else if(istype(I, /obj/item/clothing/mask))
			if(mask)
				user << "<span class='warning'>The unit already contains a mask!</span>"
				return
			if(!user.drop_item())
				return
			mask = I
		else if(istype(I, /obj/item))
			if(storage)
				user << "<span class='warning'>The auxiliary storage compartment is full!</span>"
				return
			if(!user.drop_item())
				return
			storage = I

		I.loc = src
		visible_message("<span class='notice'>[user] inserts [I] into [src]</span>", "<span class='notice'>You load [I] into [src].</span>")

	if(panel_open && is_wire_tool(I))
		wires.interact(user)
	if(!state_open)
		if(default_deconstruction_screwdriver(user, "panel", "close", I))
			return
	if(default_pry_open(I))
		return

	update_icon()
	return

/obj/machinery/suit_storage_unit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = notcontained_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "suit_storage_unit", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/suit_storage_unit/ui_data()
	var/list/data = list()
	data["locked"] = locked
	data["open"] = state_open
	data["safeties"] = safeties
	data["uv_active"] = uv
	data["uv_super"] = uv_super
	if(helmet)
		data["helmet"] = helmet.name
	if(suit)
		data["suit"] = suit.name
	if(mask)
		data["mask"] = mask.name
	if(storage)
		data["storage"] = storage.name
	if(occupant)
		data["occupied"] = 1
	return data

/obj/machinery/suit_storage_unit/ui_act(action, params)
	if(..() || uv)
		return
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine(!!occupant) // Dump out contents if someone is in there.
			. = TRUE
		if("lock")
			locked = !locked
			. = TRUE
		if("uv")
			if(occupant && safeties)
				return
			else if(!helmet && !mask && !suit && !storage && !occupant)
				return
			else
				cook()
				. = TRUE
		if("dispense")
			if(!state_open)
				return
			switch(params["item"])
				if("helmet")
					helmet.loc = loc
					helmet = null
				if("suit")
					suit.loc = loc
					suit = null
				if("mask")
					mask.loc = loc
					mask = null
				if("storage")
					storage.loc = loc
					storage = null
			. = TRUE
	update_icon()