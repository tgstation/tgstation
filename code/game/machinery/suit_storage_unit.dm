// SUIT STORAGE UNIT /////////////////
/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial unit made to hold space suits. It comes with a built-in UV cauterization mechanism. A small warning label advises that organic matter should not be placed into the unit."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "close"
	anchored = TRUE
	density = TRUE
	max_integrity = 250

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
	suit_type = /obj/item/clothing/suit/space/hardsuit/captain
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/jetpack/oxygen/captain

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
	storage_type = /obj/item/tank/internals/oxygen

/obj/machinery/suit_storage_unit/atmos
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	mask_type = /obj/item/clothing/mask/gas
	storage_type = /obj/item/watertank/atmos

/obj/machinery/suit_storage_unit/mining
	suit_type = /obj/item/clothing/suit/hooded/explorer
	mask_type = /obj/item/clothing/mask/gas/explorer

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
	storage_type = /obj/item/tank/jetpack/oxygen/harness

/obj/machinery/suit_storage_unit/ert/command
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/security
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/sec
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/engineer
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/engi
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/medical
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/med
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/Initialize()
	. = ..()
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

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(suit)
	QDEL_NULL(helmet)
	QDEL_NULL(mask)
	QDEL_NULL(storage)
	return ..()

/obj/machinery/suit_storage_unit/update_icon()
	cut_overlays()

	if(uv)
		if(uv_super)
			add_overlay("super")
		else if(occupant)
			add_overlay("uvhuman")
		else
			add_overlay("uv")
	else if(state_open)
		if(stat & BROKEN)
			add_overlay("broken")
		else
			add_overlay("open")
			if(suit)
				add_overlay("suit")
			if(helmet)
				add_overlay("helm")
			if(storage)
				add_overlay("storage")
	else if(occupant)
		add_overlay("human")

/obj/machinery/suit_storage_unit/power_change()
	..()
	if(!is_operational() && state_open)
		open_machine()
		dump_contents()
	update_icon()

/obj/machinery/suit_storage_unit/proc/dump_contents()
	dropContents()
	helmet = null
	suit = null
	mask = null
	storage = null
	occupant = null

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		open_machine()
		dump_contents()
		new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/A, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, "<span class='warning'>The unit's doors are shut!</span>")
		return
	if(!is_operational())
		to_chat(user, "<span class='warning'>The unit is not operational!</span>")
		return
	if(occupant || helmet || suit || storage)
		to_chat(user, "<span class='warning'>It's too cluttered inside to fit in!</span>")
		return

	if(target == user)
		user.visible_message("<span class='warning'>[user] starts squeezing into [src]!</span>", "<span class='notice'>You start working your way into [src]...</span>")
	else
		target.visible_message("<span class='warning'>[user] starts shoving [target] into [src]!</span>", "<span class='userdanger'>[user] starts shoving you into [src]!</span>")

	if(do_mob(user, target, 30))
		if(occupant || helmet || suit || storage)
			return
		if(target == user)
			user.visible_message("<span class='warning'>[user] slips into [src] and closes the door behind them!</span>", "<span class=notice'>You slip into [src]'s cramped space and shut its door.</span>")
		else
			target.visible_message("<span class='warning'>[user] pushes [target] into [src] and shuts its door!<span>", "<span class='userdanger'>[user] shoves you into [src] and shuts the door!</span>")
		close_machine(target)
		add_fingerprint(user)

/obj/machinery/suit_storage_unit/proc/cook()
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		locked = TRUE
		update_icon()
		if(occupant)
			var/mob/living/mob_occupant = occupant
			if(uv_super)
				mob_occupant.adjustFireLoss(rand(20, 36))
			else
				mob_occupant.adjustFireLoss(rand(10, 16))
			mob_occupant.emote("scream")
		addtimer(CALLBACK(src, .proc/cook), 50)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_super)
			visible_message("<span class='warning'>[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber.</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
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
			if(!occupant)
				visible_message("<span class='notice'>[src]'s door slides open. The glowing yellow lights dim to a gentle green.</span>")
			else
				visible_message("<span class='warning'>[src]'s door slides open, barraging you with the nauseating smell of charred flesh.</span>")
			playsound(src, 'sound/machines/airlockclose.ogg', 25, 1)
			for(var/obj/item/I in src) //Scorches away blood and forensic evidence, although the SSU itself is unaffected
				I.forensics.clean_blood()
				I.forensics.clean_prints()
		open_machine(FALSE)
		if(occupant)
			dump_contents()

/obj/machinery/suit_storage_unit/proc/shock(mob/user, prb)
	if(!prob(prb))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		if(electrocute_mob(user, src, src, 1, TRUE))
			return 1

/obj/machinery/suit_storage_unit/relaymove(mob/user)
	container_resist(user)

/obj/machinery/suit_storage_unit/container_resist(mob/living/user)
	add_fingerprint(user)
	if(locked)
		visible_message("<span class='notice'>You see [user] kicking against the doors of [src]!</span>", "<span class='notice'>You start kicking against the doors...</span>")
		addtimer(CALLBACK(src, .proc/resist_open, user), 300)
	else
		open_machine()
		dump_contents()

/obj/machinery/suit_storage_unit/proc/resist_open(mob/user)
	if(!state_open && occupant && (user in src) && user.stat == 0) // Check they're still here.
		visible_message("<span class='notice'>You see [user] bursts out of [src]!</span>", "<span class='notice'>You escape the cramped confines of [src]!</span>")
		open_machine()

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(state_open && is_operational())
		if(istype(I, /obj/item/clothing/suit/space))
			if(suit)
				to_chat(user, "<span class='warning'>The unit already contains a suit!.</span>")
				return
			if(!user.drop_item())
				return
			suit = I
		else if(istype(I, /obj/item/clothing/head/helmet))
			if(helmet)
				to_chat(user, "<span class='warning'>The unit already contains a helmet!</span>")
				return
			if(!user.drop_item())
				return
			helmet = I
		else if(istype(I, /obj/item/clothing/mask))
			if(mask)
				to_chat(user, "<span class='warning'>The unit already contains a mask!</span>")
				return
			if(!user.drop_item())
				return
			mask = I
		else
			if(storage)
				to_chat(user, "<span class='warning'>The auxiliary storage compartment is full!</span>")
				return
			if(!user.drop_item())
				return
			storage = I

		I.loc = src
		visible_message("<span class='notice'>[user] inserts [I] into [src]</span>", "<span class='notice'>You load [I] into [src].</span>")
		update_icon()
		return

	if(panel_open && is_wire_tool(I))
		wires.interact(user)
	if(!state_open)
		if(default_deconstruction_screwdriver(user, "panel", "close", I))
			return
	if(default_pry_open(I))
		dump_contents()
		return

	return ..()

/obj/machinery/suit_storage_unit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)
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
				open_machine(0)
				if(occupant)
					dump_contents() // Dump out contents if someone is in there.
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
				if(occupant)
					var/mob/living/mob_occupant = occupant
					to_chat(mob_occupant, "<span class='userdanger'>[src]'s confines grow warm, then hot, then scorching. You're being burned [!mob_occupant.stat ? "alive" : "away"]!</span>")
				cook()
				. = TRUE
		if("dispense")
			if(!state_open)
				return

			var/static/list/valid_items = list("helmet", "suit", "mask", "storage")
			var/item_name = params["item"]
			if(item_name in valid_items)
				var/obj/item/I = vars[item_name]
				vars[item_name] = null
				if(I)
					I.forceMove(loc)
			. = TRUE
	update_icon()
