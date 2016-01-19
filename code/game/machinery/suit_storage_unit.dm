//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////

#define REPAIR_NEEDS_WIRECUTTERS 1
#define REPAIR_NEEDS_WIRES 2
#define REPAIR_NEEDS_CROWBAR 3
#define REPAIR_NEEDS_METAL 4

/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial unit made to hold space suits. It comes with a built-in UV cauterization mechanism. A small warning label advises that organic matter should not be placed into the unit."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "close"
	anchored = 1
	density = 1
	//Vars to hold internal items
	var/mob/living/OCCUPANT = null
	var/obj/item/clothing/suit/space/SUIT = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/obj/item/clothing/mask/MASK = null
	var/obj/item/STORAGE = null

	//Base types on creation
	var/SUIT_TYPE = null
	var/HELMET_TYPE = null
	var/MASK_TYPE = null
	var/STORAGE_TYPE = null

	//Machine related vars
	var/isopen = 0
	var/islocked = 0
	var/isUV = 0
	var/ispowered = 1
	var/isbroken = 0
	var/issuperUV = 0
	var/safetieson = 1
	var/cycletime_left = 0
	var/repair_stage = 0

/obj/machinery/suit_storage_unit/examine(mob/user)
	..()
	if(isbroken && isopen)
		if(!panel_open)
			user << "<span class='warning'>A small LED above the maintenance panel is flashing red.</span>"
			return
		switch(repair_stage)
			if(REPAIR_NEEDS_WIRECUTTERS)
				user << "<span class='warning'>The wires inside are charred and snapped.</span>"
			if(REPAIR_NEEDS_WIRES)
				user << "<span class='warning'>There are no wires inside.</span>"
			if(REPAIR_NEEDS_CROWBAR)
				user << "<span class='warning'>Some of the interior metal is burnt and broken.</span>"
			if(REPAIR_NEEDS_METAL)
				user << "<span class='warning'>It lacks interior plating.</span>"



/obj/machinery/suit_storage_unit/standard_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/eva
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/eva
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/captain
	SUIT_TYPE = /obj/item/clothing/suit/space/captain
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/captain
	MASK_TYPE = /obj/item/clothing/mask/gas
	STORAGE_TYPE = /obj/item/weapon/tank/jetpack/oxygen/captain

/obj/machinery/suit_storage_unit/engine
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/engine
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/ce
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/engine/elite
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE= /obj/item/clothing/shoes/magboots/advance

/obj/machinery/suit_storage_unit/security
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/security
	MASK_TYPE = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/hos
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/security/hos
	MASK_TYPE = /obj/item/clothing/mask/gas/sechailer

/obj/machinery/suit_storage_unit/atmos
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	MASK_TYPE = /obj/item/clothing/mask/gas
	STORAGE_TYPE = /obj/item/weapon/watertank/atmos

/obj/machinery/suit_storage_unit/mining
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/mining
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/cmo
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/medical
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/rd
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/rd
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/syndicate
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/syndi
	MASK_TYPE = /obj/item/clothing/mask/gas/syndicate
	STORAGE_TYPE = /obj/item/weapon/tank/jetpack/oxygen/harness

/obj/machinery/suit_storage_unit/ertCom
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ertSec
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert/sec
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ertEngi
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert/engi
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ertMed
	SUIT_TYPE = /obj/item/clothing/suit/space/hardsuit/ert/med
	MASK_TYPE = /obj/item/clothing/mask/breath
	STORAGE_TYPE = /obj/item/weapon/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/New()
	src.update_icon()
	if(SUIT_TYPE)
		SUIT = new SUIT_TYPE(src)
	if(HELMET_TYPE)
		HELMET = new HELMET_TYPE(src)
	if(MASK_TYPE)
		MASK = new MASK_TYPE(src)
	if(STORAGE_TYPE)
		STORAGE = new STORAGE_TYPE(src)

/obj/machinery/suit_storage_unit/update_icon() //overlays yaaaay - Jordie
	src.overlays = 0

	if(!isopen)
		overlays += "close"
	if(OCCUPANT)
		overlays += "human"
	if(OCCUPANT && isUV)
		overlays += "uvhuman"
	if(isUV)
		overlays += "uv"
	if(issuperUV && isUV)
		overlays += "super"
	if(isopen)
		overlays += "open"
		if(SUIT)
			overlays += "suit"
		if(HELMET)
			overlays += "helm"
		if(STORAGE)
			overlays += "storage"
		if(isbroken)
			overlays += "broken"
	return

/obj/machinery/suit_storage_unit/power_change()
	..()
	ispowered = !(stat & NOPOWER)
	if((stat & NOPOWER) && isopen)
		dump_everything()
	update_icon()

/obj/machinery/suit_storage_unit/ex_act(severity, target)
	switch(severity)
		if(1)
			if(prob(50))
				src.dump_everything() //So suits dont survive all the time
			qdel(src)
			return
		if(2)
			if(prob(50))
				src.dump_everything()
				qdel(src)
			return
		else
			return
	return

/obj/machinery/suit_storage_unit/get_ui_data()
	var/list/data = list()
	data["isBroken"] = isbroken
	data["isLocked"] = islocked
	data["isOpen"] = isopen
	data["isBaking"] = isUV
	data["uv"] = issuperUV
	data["safety"] = safetieson
	data["maintenance"] = panel_open
	if(HELMET)
		data["helmet"] = HELMET.name
	if(SUIT)
		data["suit"] = SUIT.name
	if(MASK)
		data["mask"] = MASK.name
	if(STORAGE)
		data["aux"] = STORAGE.name
	if(OCCUPANT)
		data["occupied"] = 1
	return data

/obj/machinery/suit_storage_unit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "suit_storage", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/suit_storage_unit/ui_act(action, params)
	switch(action)
		if ("uv")
			toggleUV(usr)
		if ("safety")
			togglesafeties(usr)
		if ("helmet")
			dispense_helmet(usr)
		if ("suit")
			dispense_suit(usr)
		if ("mask")
			dispense_mask(usr)
		if ("aux")
			eject_storage(usr)
		if ("toggle_open")
			toggle_open(usr)
		if ("toggle_lock")
			toggle_lock(usr)
		if ("uv_start")
			start_UV(usr)
		if ("mob")
			eject_occupant(usr)
	update_icon()
	return 1

/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	interact(user)

/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user)
	if(!src.panel_open)
		return
	else
		if(src.issuperUV)
			user << "<span class='notice'>You slide the dial back towards \"185nm\".</span>"
			src.issuperUV = 0
		else
			user << "<span class='notice'>You crank the dial all the way up to \"15nm\".</span>"
			src.issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user)
	if(!src.panel_open) //Needed check due to bugs
		return
	else
		user << "<span class='notice'>You push the button. The coloured LED next to it changes.</span>"
		src.safetieson = !src.safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet()
	eject(HELMET)
	HELMET = null

/obj/machinery/suit_storage_unit/proc/dispense_suit()
	eject(SUIT)
	SUIT = null

/obj/machinery/suit_storage_unit/proc/dispense_mask()
	eject(MASK)
	MASK = null

/obj/machinery/suit_storage_unit/proc/eject_storage()
	eject(STORAGE)
	STORAGE = null

/obj/machinery/suit_storage_unit/proc/eject(atom/movable/ITEM)
	//Check item still exists - if not, then usually someone has already ejected the item
	if(ITEM)
		ITEM.loc = src.loc

/obj/machinery/suit_storage_unit/proc/dump_everything()
	for(var/obj/item/ITEM in src)
		eject(ITEM)
	SUIT = null
	HELMET = null
	MASK = null
	STORAGE = null
	if(OCCUPANT)
		eject_occupant(OCCUPANT)
	return


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user)
	if(islocked || isUV)
		user << "<span class='warning'>You're unable to open unit!</span>"
		return 0
	if(OCCUPANT)
		eject_occupant(user)
		return 1  // eject_occupant opens the door, so we need to return
	isopen = !isopen
	return 1


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user)
	if(OCCUPANT && safetieson)
		user << "<span class='warning'>The unit's safety protocols disallow locking when a biological form is detected inside its compartments.</span>"
		return
	if(isopen)
		return
	islocked = !islocked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user)
	if(isUV || isopen) //I'm bored of all these sanity checks
		return
	if(OCCUPANT && safetieson)
		user << "<font color='red'><B>WARNING:</B> Biological entity detected in the confines of the unit's storage. Cannot initiate cycle.</font>"
		return
	if(!HELMET && !MASK && !SUIT && !STORAGE && !OCCUPANT )
		user << "<font color='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</font>"
		return
	user << "<span class='notice'>You start the unit's cauterisation cycle.</span>"
	cycletime_left = 20
	isUV = 1
	if(OCCUPANT && !islocked)
		islocked = 1 //Let's lock it for good measure
	update_icon()

	var/i
	spawn(0)
		for(i=0,i<4,++i)
			sleep(50)
			if(OCCUPANT)
				var/burndamage = rand(6,10)
				if(issuperUV)
					burndamage = rand(28,35)
				if(iscarbon(OCCUPANT))
					OCCUPANT.take_organ_damage(0,burndamage)
					OCCUPANT.emote("scream")
				else
					OCCUPANT.take_organ_damage(burndamage)
			if(i==3) //End of the cycle
				if(!issuperUV)
					for(var/obj/item/ITEM in src)
						ITEM.clean_blood()
					if(istype(STORAGE, /obj/item/weapon/reagent_containers/food))
						qdel(STORAGE)
				else //It was supercycling, destroy everything
					HELMET = null
					SUIT = null
					MASK = null
					qdel(STORAGE)
					visible_message("<span class='warning'>With a loud whining noise, [src]'s door grinds open. A foul cloud of smoke emanates from the chamber.</span>")
					isbroken = 1
					isopen = 1
					islocked = 0
					repair_stage = REPAIR_NEEDS_WIRECUTTERS
					eject_occupant(OCCUPANT)
				isUV = 0 //Cycle ends
		update_icon()
		return

/obj/machinery/suit_storage_unit/proc/cycletimeleft()
	if(cycletime_left >= 1)
		cycletime_left--
	return cycletime_left


/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user)
	if (islocked)
		return

	if (!OCCUPANT)
		return

	if (OCCUPANT.client)
		if(user != OCCUPANT)
			OCCUPANT << "<span class='warning'>The machine kicks you out!</span>"
		if(user.loc != loc)
			OCCUPANT << "<span class='warning'>You leave the not-so-cozy confines of [src].</span>"

		OCCUPANT.client.eye = OCCUPANT.client.mob
		OCCUPANT.client.perspective = MOB_PERSPECTIVE
	if(OCCUPANT.loc == src)
		OCCUPANT.loc = loc
	OCCUPANT = null
	if(!isopen)
		isopen = 1
	update_icon()
	return


/obj/machinery/suit_storage_unit/relaymove(mob/user)
	if(user.stat || !isturf(loc))
		return
	container_resist()


/obj/machinery/suit_storage_unit/container_resist()
	var/mob/living/user = usr
	if(islocked)
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/breakout_time = 2
		user << "<span class='notice'>You start kicking against the doors to escape... (This will take about [breakout_time] minutes.)</span>"
		visible_message("You see [user] kicking against the doors of \the [src]!")
		if(do_after(user,(breakout_time*60*10), target = src))
			if(!user || user.stat != CONSCIOUS || user.loc != src || isopen || !islocked)
				return
			else
				isopen = 1
				islocked = 0
				visible_message("<span class='warning'>[user] kicks their way out of [src]!</span>")

		else
			return
	eject_occupant(user)
	add_fingerprint(user)
	update_icon()
	return


/obj/machinery/suit_storage_unit/MouseDrop_T(mob/M, mob/user)
	store_mob(M, user)

/obj/machinery/suit_storage_unit/proc/store_mob(mob/living/M, mob/user)
	if(!istype(M))
		return
	if (user.stat != 0)
		return
	if (!isopen)
		user << "<span class='warning'>The unit's doors are shut!</span>"
		return
	if (!ispowered || isbroken)
		user << "<span class='warning'>The unit is not operational!</span>"
		return
	if ( (OCCUPANT) || (HELMET) || (SUIT) || (STORAGE))
		user << "<span class='warning'>It's too cluttered inside to fit in!</span>"
		return
	if(M == user)
		visible_message("<span class='warning'>[user] squeezes into [src]!</span>", "<span class='notice'>You squeeze into [src].</span>")
	else
		M.visible_message("<span class='warning'>[user] starts putting [M] into [src]!</span>", "<span class='userdanger'>[user] starts shoving you into [src]!</span>")
	if(do_mob(user, M, 10))
		user.stop_pulling()
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		OCCUPANT = M
		isopen = 0
		update_icon()

		add_fingerprint(user)
		return
	return

/obj/machinery/suit_storage_unit/proc/fix()
	audible_message("<span class='notice'>[src] beeps and comes back online!</span>")
	playsound(src, 'sound/machines/defib_ready.ogg', 50, 1)
	repair_stage = 0
	isbroken = 0
	update_icon()

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(!ispowered)
		if(istype(I, /obj/item/weapon/crowbar) && !isopen)
			if(toggle_open(user))
				dump_everything()
				user << text("<span class='notice'>You pry open [src]'s doors.</span>")
				update_icon()
		return
	if(istype(I, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		user << text("<span class='notice'>You [] the unit's maintenance panel.</span>",(src.panel_open ? "open up" : "close") )
		src.updateUsrDialog()
		return
	if(isbroken && panel_open)
		if(istype(I, /obj/item/weapon/wirecutters) && repair_stage == REPAIR_NEEDS_WIRECUTTERS)
			user.visible_message("<span class='notice'>[user] starts removing [src]'s damaged wires.</span>", \
								 "<span class='notice'>You begin removing the damaged wires from [src]...</span>")
			playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
			if(!do_after(user, 30/I.toolspeed, target = src))
				return
			user.visible_message("<span class='notice'>[user] removes the damaged wires from [src].</span>", \
								 "<spna class='notice'>You remove the damaged wiring from [src].</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			repair_stage = REPAIR_NEEDS_WIRES
			return
		if(istype(I, /obj/item/stack/cable_coil) && repair_stage == REPAIR_NEEDS_WIRES)
			var/obj/item/stack/cable_coil/C = I
			if(C.amount < 5)
				user << "<span class='warning'>You need at least five cables to rewire [src]!</span>"
				return
			user.visible_message("<span class='notice'>[user] begins replacing [src] wires.</span>", \
								 "<span class='notice'>You begin rewiring [src]...</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			if(!do_after(user, 30, target = src))
				return
			user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
								 "<span class='notice'>You rewire [src].</span>")
			C.amount -= 5
			if(C.amount <= 0)
				user.drop_item()
				qdel(C)
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			repair_stage = REPAIR_NEEDS_CROWBAR
			return
		if(istype(I, /obj/item/weapon/crowbar) && repair_stage == REPAIR_NEEDS_CROWBAR)
			user.visible_message("<span class='notice'>[user] starts removing [src]'s broken interior plating.</span>", \
								 "<span class='notice'>You begin removing the damaged interior plating from [src]...</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			if(!do_after(user, 30/I.toolspeed, target = src))
				return
			user.visible_message("<span class='notice'>[user] removes the damaged interior plating from [src].</span>", \
								 "<spna class='notice'>You remove the damaged interior plating from [src].</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			repair_stage = REPAIR_NEEDS_METAL
			return
		if(istype(I, /obj/item/stack/sheet/metal) && repair_stage == REPAIR_NEEDS_METAL)
			var/obj/item/stack/sheet/metal/M = I
			if(M.amount < 3)
				user << "<span class='warning'>You need at least three sheets of metal to repair [src]!</span>"
				return
			user.visible_message("<span class='notice'>[user] starts adding interior plating to [src].</span>", \
								 "<span class='notice'>You begin adding interior plating to [src]...</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			if(!do_after(user, 30, target = src))
				return
			user.visible_message("<span class='notice'>[user] adds interior plating to [src].</span>", \
								 "<spna class='notice'>You add interior plating to [src].</span>")
			fix()
			return
	if ( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		store_mob(G.affecting, user)
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/clothing/suit/space/S = I
		if(src.SUIT)
			user << "<span class='notice'>The unit already contains a suit.</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>[S] is stuck to your hand, you cannot put it in [src]!</span>"
			return
		user << "<span class='notice'>You load [S] into the suit storage compartment.</span>"
		S.loc = src
		SUIT = S
		update_icon()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(src.HELMET)
			user << "<span class='warning'>The unit already contains a helmet!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>[H] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load [H] into the helmet storage compartment.</span>"
		H.loc = src
		HELMET = H
		update_icon()
		return
	if( istype(I,/obj/item/clothing/mask) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/clothing/mask/M = I
		if(src.MASK)
			user << "<span class='warning'>The unit already contains a mask!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>[M] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load [M] into the mask storage compartment.</span>"
		M.loc = src
		MASK = M
		update_icon()
		return
	if( istype(I,/obj/item) )
		if(!src.isopen || src.isbroken)
			return
		var/obj/item/ITEM = I
		if(src.STORAGE)
			user << "<span class='warning'>The auxiliary storage compartment is full!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>[ITEM] is stuck to your hand, you cannot put it in the Suit Storage Unit!</span>"
			return
		user << "<span class='notice'>You load [ITEM] into the auxiliary storage compartment.</span>"
		ITEM.loc = src
		STORAGE = ITEM
	update_icon()
	return


/obj/machinery/suit_storage_unit/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/suit_storage_unit/attack_paw(mob/user)
	user << "<span class='warning'>You don't know how to work this!</span>"
	return

#undef REPAIR_NEEDS_WIRECUTTERS
#undef REPAIR_NEEDS_WIRES
#undef REPAIR_NEEDS_CROWBAR
#undef REPAIR_NEEDS_METAL
