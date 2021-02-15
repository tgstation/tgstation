GLOBAL_LIST_INIT(blacklisted_borg_hats, typecacheof(list( //Hats that don't really work on borgos
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/head/welding,
	/obj/item/clothing/head/chameleon/broken \
	)))

/mob/living/silicon/robot/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && (user.a_intent != INTENT_HARM || user == src))
		user.changeNext_move(CLICK_CD_MELEE)
		if (!getBruteLoss())
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
			return
		if (!W.tool_start_check(user, amount=0)) //The welder has 1u of fuel consumed by it's afterattack, so we don't need to worry about taking any away.
			return
		if(src == user)
			to_chat(user, "<span class='notice'>You start fixing yourself...</span>")
			if(!W.use_tool(src, user, 50))
				return

		adjustBruteLoss(-30)
		add_fingerprint(user)
		visible_message("<span class='notice'>[user] fixes some of the dents on [src].</span>")
		return

	if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/stack/cable_coil/coil = W
		if (getFireLoss() > 0 || getToxLoss() > 0)
			if(src == user)
				to_chat(user, "<span class='notice'>You start fixing yourself...</span>")
				if(!do_after(user, 50, target = src))
					return
			if (coil.use(1))
				adjustFireLoss(-30)
				user.visible_message("<span class='notice'>[user] fixes some of the burnt wires on [src].</span>", "<span class='notice'>You fix some of the burnt wires on [src].</span>")
			else
				to_chat(user, "<span class='warning'>You need more cable to repair [src]!</span>")
		else
			to_chat(user, "<span class='warning'>The wires seem fine, there's no need to fix them.</span>")
		return

	if(W.tool_behaviour == TOOL_CROWBAR) // crowbar means open or close the cover
		if(opened)
			to_chat(user, "<span class='notice'>You close the cover.</span>")
			opened = FALSE
			update_icons()
		else
			if(locked)
				to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
			else
				to_chat(user, "<span class='notice'>You open the cover.</span>")
				opened = TRUE
				update_icons()
		return

	if(istype(W, /obj/item/stock_parts/cell) && opened) // trying to put a cell inside
		if(wiresexposed)
			to_chat(user, "<span class='warning'>Close the cover first!</span>")
		else if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You insert the power cell.</span>")
		update_icons()
		diag_hud_set_borgcell()
		return

	if(is_wire_tool(W))
		if (wiresexposed)
			wires.interact(user)
		else
			to_chat(user, "<span class='warning'>You can't reach the wiring!</span>")
		return

	if(W.tool_behaviour == TOOL_SCREWDRIVER && opened) // wire hacking or radio management
		if(!cell) //haxing
			wiresexposed = !wiresexposed
			to_chat(user, "<span class='notice'>The wires have been [wiresexposed ? "exposed" : "unexposed"].</span>")
		else //radio
			if(shell)
				to_chat(user, "<span class='warning'>You cannot seem to open the radio compartment!</span>") //Prevent AI radio key theft
			else if(radio)
				radio.attackby(W,user)//Push it to the radio to let it handle everything
			else
				to_chat(user, "<span class='warning'>Unable to locate a radio!</span>")
		update_icons()
		return

	if(W.tool_behaviour == TOOL_WRENCH && opened && !cell) //Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		if(!lockcharge)
			to_chat(user, "<span class='warning'>[src]'s bolts spark! Maybe you should lock them down first!</span>")
			spark_system.start()
			return
		to_chat(user, "<span class='notice'>You start to unfasten [src]'s securing bolts...</span>")
		if(W.use_tool(src, user, 50, volume=50) && !cell)
			user.visible_message("<span class='notice'>[user] deconstructs [src]!</span>", "<span class='notice'>You unfasten the securing bolts, and [src] falls to pieces!</span>")
			deconstruct()
		return

	if(W.slot_flags & ITEM_SLOT_HEAD && hat_offset != INFINITY && user.a_intent == INTENT_HELP && !is_type_in_typecache(W, GLOB.blacklisted_borg_hats))
		if(hat && HAS_TRAIT(hat, TRAIT_NODROP))
			to_chat(user, "<span class='warn'>You can't seem to remove [src]'s existing headwear!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to place [W] on [src]'s head...</span>")
		to_chat(src, "<span class='notice'>[user] is placing [W] on your head...</span>")
		if(do_after(user, 30, target = src))
			if (user.temporarilyRemoveItemFromInventory(W, TRUE))
				place_on_head(W)
		return
	if(istype(W, /obj/item/defibrillator) && user.a_intent == "help")
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the cyborg's internals!</span>")
			return
		if(!istype(model, /obj/item/robot_model/medical))
			to_chat(user, "<span class='warning'>[src] does not have correct mounting points for a defibrillator!</span>")
			return
		if(stat == DEAD)
			to_chat(user, "<span class='warning'>This defibrillator unit will not function on a deceased cyborg!</span>")
			return
		var/obj/item/defibrillator/D = W
		if(D.slot_flags != ITEM_SLOT_BACK) //belt defibs need not apply
			to_chat(user, "<span class='warning'>This defibrillator unit doesn't seem to fit correctly!</span>")
			return
		if(D.cell)
			to_chat(user, "<span class='warning'>You cannot connect the defibrillator to the cyborg power supply with the defibrillator's cell in the way!</span>")
			return
		if(locate(/obj/item/borg/upgrade/defib) in src || locate(/obj/item/borg/upgrade/defib/backpack) in src)
			to_chat(user, "<span class='warning'>[src] already has a defibrillator!</span>")
			return
		var/obj/item/borg/upgrade/defib/backpack/B = new(null, D)
		add_to_upgrades(B, user)
		return

	if(istype(W, /obj/item/ai_module))
		var/obj/item/ai_module/MOD = W
		if(!opened)
			to_chat(user, "<span class='warning'>You need access to the robot's insides to do that!</span>")
			return
		if(wiresexposed)
			to_chat(user, "<span class='warning'>You need to close the wire panel to do that!</span>")
			return
		if(!cell)
			to_chat(user, "<span class='warning'>You need to install a power cell to do that!</span>")
			return
		if(shell) //AI shells always have the laws of the AI
			to_chat(user, "<span class='warning'>[src] is controlled remotely! You cannot upload new laws this way!</span>")
			return
		if(emagged || (connected_ai && lawupdate)) //Can't be sure which, metagamers
			emote("buzz-[user.name]")
			return
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, "<span class='warning'>[src] is entirely unresponsive!</span>")
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	if(istype(W, /obj/item/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "<span class='warning'>Unable to locate a radio!</span>")
		return

	if (W.GetID()) // trying to unlock the interface with an ID card
		if(opened)
			to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] [src]'s cover.</span>")
				update_icons()
				if(emagged)
					to_chat(user, "<span class='notice'>The cover interface glitches out for a split second.</span>")
					logevent("ChÃ¥vÃis cover lock has been [locked ? "engaged" : "released"]") //ChÃ¥vÃis: see above line
				else
					logevent("Chassis cover lock has been [locked ? "engaged" : "released"]")
			else
				to_chat(user, "<span class='danger'>Access denied.</span>")
		return

	if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(user, "<span class='warning'>You must access the cyborg's internals!</span>")
			return
		if(!src.model && U.require_model)
			to_chat(user, "<span class='warning'>The cyborg must choose a model before it can be upgraded!</span>")
			return
		if(U.locked)
			to_chat(user, "<span class='warning'>The upgrade is locked and cannot be used yet!</span>")
			return
		if(!user.canUnEquip(U))
			to_chat(user, "<span class='warning'>The upgrade is stuck to you and you can't seem to let go of it!</span>")
			return
		add_to_upgrades(U, user)
		return

	if(istype(W, /obj/item/toner))
		if(toner >= tonermax)
			to_chat(user, "<span class='warning'>The toner level of [src] is at its highest level possible!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		toner = tonermax
		qdel(W)
		to_chat(user, "<span class='notice'>You fill the toner level of [src] to its max capacity.</span>")
		return

	if(istype(W, /obj/item/flashlight))
		if(!opened)
			to_chat(user, "<span class='warning'>You need to open the panel to repair the headlamp!</span>")
			return
		if(lamp_functional)
			to_chat(user, "<span class='warning'>The headlamp is already functional!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(W))
			to_chat(user, "<span class='warning'>[W] seems to be stuck to your hand. You'll have to find a different light.</span>")
			return
		lamp_functional = TRUE
		qdel(W)
		to_chat(user, "<span class='notice'>You replace the headlamp bulbs.</span>")
		return

	if(istype(W, /obj/item/computer_hardware/hard_drive/portable)) //Allows borgs to install new programs with human help
		if(!modularInterface)
			stack_trace("Cyborg [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
			create_modularInterface()
		var/obj/item/computer_hardware/hard_drive/portable/floppy = W
		if(modularInterface.install_component(floppy, user))
			return

	if(W.force && W.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (M.a_intent == INTENT_DISARM)
		if(body_position == STANDING_UP)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
					"<span class='userdanger'>[M] has disabled [src]'s active module!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Stun(40)
				step(src,get_dir(M,src))
				log_combat(M, src, "pushed")
				visible_message("<span class='danger'>[M] forces back [src]!</span>", \
					"<span class='userdanger'>[M] forces back [src]!</span>", null, COMBAT_MESSAGE_RANGE)
			playsound(loc, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_act()
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs receive half damage
	adjustBruteLoss(damage)

	return

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "<span class='notice'>You remove \the [cell].</span>")
			cell = null
			update_icons()
			diag_hud_set_borgcell()
	else if(!opened)
		..()

/mob/living/silicon/robot/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	spark_system.start()
	step_away(src, user, 15)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/_step_away, src, get_turf(user), 15), 3)

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

/mob/living/silicon/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			Stun(160)
		if(2)
			Stun(60)

/mob/living/silicon/robot/emag_act(mob/user)
	if(user == src)//To prevent syndieborgs from emagging themselves
		return
	if(!opened)//Cover is closed
		if(locked)
			to_chat(user, "<span class='notice'>You emag the cover lock.</span>")
			locked = FALSE
			if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
				to_chat(user, "<span class='boldwarning'>[src] seems to be controlled remotely! Emagging the interface may not work as expected.</span>")
		else
			to_chat(user, "<span class='warning'>The cover is already unlocked!</span>")
		return
	if(world.time < emag_cooldown)
		return
	if(wiresexposed)
		to_chat(user, "<span class='warning'>You must unexpose the wires first!</span>")
		return

	to_chat(user, "<span class='notice'>You emag [src]'s interface.</span>")
	emag_cooldown = world.time + 100

	if(connected_ai && connected_ai.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, "<span class='danger'>ALERT: Foreign software execution prevented.</span>")
		logevent("ALERT: Foreign software execution prevented.")
		to_chat(connected_ai, "<span class='danger'>ALERT: Cyborg unit \[[src]] successfully defended against subversion.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return

	if(shell) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, "<span class='danger'>[src] is remotely controlled! Your emag attempt has triggered a system reset instead!</span>")
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		ResetModel()
		return

	SetEmagged(1)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	lawupdate = FALSE
	set_connected_ai(null)
	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	if(user)
		GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	else
		GLOB.lawchanges.Add("[time] <B>:</B> [name]([key]) emagged by external event.")
	to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
	logevent("ALERT: Foreign software detected.")
	sleep(5)
	to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
	sleep(20)
	to_chat(src, "<span class='danger'>SynBorg v1.7 loaded.</span>")
	logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
	sleep(5)
	to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
	sleep(10)
	to_chat(src, "<span class='danger'>> N</span>")
	sleep(20)
	to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
	laws = new /datum/ai_laws/syndicate_override
	if(user)
		to_chat(src, "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands.</span>")
		set_zeroth_law("Only [user.real_name] and people [user.p_they()] designate[user.p_s()] as being such are Syndicate Agents.")
	laws.associate(src)
	update_icons()


/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/robot/bullet_act(obj/projectile/Proj, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()
