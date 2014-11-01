/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

   manual (num)
      Currently unused.

Class Procs:
   New()                     'game/machinery/machine.dm'

   Destroy()                     'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

   process()                  'game/machinery/machine.dm'
      Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.


	Compiled by Aygar
*/

//The machine flags can be found in setup.dm

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	var/icon_state_open = ""

	w_type = NOT_RECYCLABLE

	var/stat = 0
	var/emagged = 0
	var/use_power = 1
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP // EQUIP, ENVIRON or LIGHT.
	var/list/component_parts // List of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/global/gl_uid = 1
	var/custom_aghost_alerts=0
	var/panel_open = 0

	/**
	 * Machine construction/destruction/emag flags.
	 */
	var/machine_flags = 0

	/**
	 * Emag energy cost (in MJ).
	 */
	var/emag_cost = 1

	var/inMachineList = 1 // For debugging.

/obj/machinery/cultify()
	var/list/random_structure = list(
		/obj/structure/cult/talisman,
		/obj/structure/cult/forge,
		/obj/structure/cult/tome
		)
	var/I = pick(random_structure)
	new I(loc)
	..()

/obj/machinery/New()
	machines += src
	return ..()

/obj/machinery/examine(mob/user)
	..()
	if(panel_open)
		user << "Its maintenance panel is open."

/obj/machinery/Destroy()
	if(src in machines)
		machines -= src

	if(component_parts)
		for(var/atom/movable/AM in component_parts)
			AM.loc = loc
			component_parts -= AM

		component_parts = null

	..()

/obj/machinery/process() // If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && stat == 0)
		use_power(7500/severity)

		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			qdel(pulse2)
	..()

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return
		else
	return

/obj/machinery/blob_act()
	if(prob(50))
		del(src)

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0

	switch (use_power)
		if (1)
			use_power(idle_power_usage, power_channel)
		if (2)
			use_power(active_power_usage, power_channel)

	return 1

/obj/machinery/proc/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	if("set_id" in href_list)
		if(!("id_tag" in vars))
			warning("set_id: [type] has no id_tag var.")
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			src:id_tag = newid
			return MT_UPDATE|MT_REINIT
	if("set_freq" in href_list)
		if(!("frequency" in vars))
			warning("set_freq: [type] has no frequency var.")
			return 0
		var/newfreq=src:frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, src:frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				src:frequency = newfreq
				return MT_UPDATE|MT_REINIT
	return 0

/obj/machinery/proc/handle_multitool_topic(var/href, var/list/href_list, var/mob/user)
	var/obj/item/device/multitool/P = get_multitool(usr)
	if(P && istype(P))
		var/update_mt_menu=0
		var/re_init=0
		if("set_tag" in href_list)
			if(!(href_list["set_tag"] in vars))
				usr << "\red Something went wrong: Unable to find [href_list["set_tag"]] in vars!"
				return 1
			var/current_tag = src.vars[href_list["set_tag"]]
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				vars[href_list["set_tag"]] = newid
				re_init=1

		if("unlink" in href_list)
			var/idx = text2num(href_list["unlink"])
			if (!idx)
				return 1

			var/obj/O = getLink(idx)
			if(!O)
				return 1
			if(!canLink(O))
				usr << "\red You can't link with that device."
				return 1

			if(unlinkFrom(usr, O))
				usr << "\blue A green light flashes on \the [P], confirming the link was removed."
			else
				usr << "\red A red light flashes on \the [P].  It appears something went wrong when unlinking the two devices."
			update_mt_menu=1

		if("link" in href_list)
			var/obj/O = P.buffer
			if(!O)
				return 1
			if(!canLink(O,href_list))
				usr << "\red You can't link with that device."
				return 1
			if (isLinkedWith(O))
				usr << "\red A red light flashes on \the [P]. The two devices are already linked."
				return 1

			if(linkWith(usr, O, href_list))
				usr << "\blue A green light flashes on \the [P], confirming the link was removed."
			else
				usr << "\red A red light flashes on \the [P].  It appears something went wrong when linking the two devices."
			update_mt_menu=1

		if("buffer" in href_list)
			P.buffer = src
			usr << "\blue A green light flashes, and the device appears in the multitool buffer."
			update_mt_menu=1

		if("flush" in href_list)
			usr << "\blue A green light flashes, and the device disappears from the multitool buffer."
			P.buffer = null
			update_mt_menu=1

		var/ret = multitool_topic(usr,href_list,P.buffer)
		if(ret == MT_ERROR)
			return 1
		if(ret & MT_UPDATE)
			update_mt_menu=1
		if(ret & MT_REINIT)
			re_init=1

		if(re_init)
			initialize()
		if(update_mt_menu)
			//usr.set_machine(src)
			update_multitool_menu(usr)
			return 1

/obj/machinery/Topic(href, href_list)
	..()
	if(stat & (NOPOWER|BROKEN))
		return 1
	var/ghost_flags=0
	if(ghost_write)
		ghost_flags |= PERMIT_ALL
	if(!canGhostWrite(usr,src,"fucked with",ghost_flags))
		if(usr.restrained() || usr.lying || usr.stat)
			return 1
		if ( ! (istype(usr, /mob/living/carbon/human) || \
				istype(usr, /mob/living/silicon) || \
				istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
			usr << "\red You don't have the dexterity to do this!"
			return 1

		var/norange = 0
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(istype(H.l_hand, /obj/item/tk_grab))
				norange = 1
			else if(istype(H.r_hand, /obj/item/tk_grab))
				norange = 1

		if(!norange)
			if ((!in_range(src, usr) || !istype(src.loc, /turf)) && !istype(usr, /mob/living/silicon))
				return 1
	else if(!custom_aghost_alerts)
		log_adminghost("[key_name(usr)] screwed with [src] ([href])!")

	src.add_fingerprint(usr)

	handle_multitool_topic(href,href_list,usr)
	return 0

/obj/machinery/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return src.attack_hand(user)
	else
		return src.attack_hand(user)

/obj/machinery/attack_ghost(mob/user as mob)
	src.add_hiddenprint(user)
	var/ghost_flags=0
	if(ghost_read)
		ghost_flags |= PERMIT_ALL
	if(canGhostRead(usr,src,ghost_flags))
		return src.attack_ai(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN|MAINT))
		return 1

	if(user.lying || (user.stat && !canGhostRead(user))) // Ghost read-only
		return 1

	if(istype(usr,/mob/dead/observer))
		return 0

	if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon) || \
			istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		usr << "\red You don't have the dexterity to do this!"
		return 1
/*
	//distance checks are made by atom/proc/DblClick
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return 1
*/
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("\red [H] stares cluelessly at [src] and drools.")
			return 1
		else if(prob(H.getBrainLoss()))
			user << "\red You momentarily forget how to use [src]."
			return 1

	src.add_fingerprint(user)
	return 0

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return
	return 0

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/crowbarDestroy(mob/user)
	user.visible_message(	"[user] begins to pry out the circuitboard from \the [src].",
							"You begin to pry out the circuitboard from \the [src]...")
	if(do_after(user, 40))
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/I in component_parts)
			if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker) && src:reagents && src:reagents.total_volume)
				reagents.trans_to(I, reagents.total_volume)
			if(I.reliability != 100 && crit_fail)
				I.crit_fail = 1
			I.loc = src.loc
		for(var/obj/I in src) //remove any stuff loaded, like for fridges
			if(machine_flags &EJECTNOTDEL)
				I.loc = src.loc
			else
				qdel(I)
		user.visible_message(	"<span class='notice'>[user] successfully pries out the circuitboard from \the [src]!</span>",
								"<span class='notice'>\icon[src] You successfully pry out the circuitboard from \the [src]!</span>")
		return 1
	return -1

/obj/machinery/proc/togglePanelOpen(var/obj/toggleitem, var/mob/user)
	panel_open = !panel_open
	if(!icon_state_open)
		icon_state_open = icon_state
	if(panel_open)
		icon_state = icon_state_open
	else
		icon_state = initial(icon_state)
	user << "<span class='notice'>\icon[src] You [panel_open ? "open" : "close"] the maintenance hatch of \the [src].</span>"
	if(istype(toggleitem, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	return 1

/obj/machinery/proc/wrenchAnchor(var/mob/user)
	user.visible_message(	"[user] begins to [anchored ? "undo" : "wrench"] \the [src]'s securing bolts.",
							"You begin to [anchored ? "undo" : "wrench"] \the [src]'s securing bolts...")
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(user, 30))
		anchored = !anchored
		user.visible_message(	"<span class='notice'>[user] [anchored ? "wrench" : "unwrench"]es \the [src] [anchored ? "in place" : "from its fixture"]</span>",
								"<span class='notice'>\icon[src] You [anchored ? "wrench" : "unwrench"] \the [src] [anchored ? "in place" : "from its fixture"].</span>",
								"<span class='notice'>You hear a ratchet.</span>")
		return 1
	return -1

/**
 * Handle emags.
 * @param user /mob The mob that used the emag.
 */
/obj/machinery/proc/emag(mob/user as mob)
	// Disable emaggability.
	machine_flags &= ~EMAGGABLE

/**
 * Returns the cost of emagging this machine (emag_cost by default)
 * @param user /mob The mob that used the emag.
 * @param emag /obj/item/weapon/card/emag The emag used on this device.
 * @return number Cost to emag.
 */
/obj/machinery/proc/getEmagCost(var/mob/user, var/obj/item/weapon/card/emag/emag)
	return emag_cost

/obj/machinery/attackby(var/obj/O, var/mob/user)
	if(istype(O, /obj/item/weapon/card/emag) && machine_flags & EMAGGABLE)
		var/obj/item/weapon/card/emag/E = O
		if(E.canUse(user,src))
			emag(user)
			return

	if(istype(O, /obj/item/weapon/wrench) && machine_flags & WRENCHMOVE) //make sure this is BEFORE the fixed2work check
		if(!panel_open)
			return wrenchAnchor(user)
		else
			user <<"<span class='warning'>\The [src]'s maintenance panel must be closed first!</span>"
			return -1 //we return -1 rather than 0 for the if(..()) checks

	if(istype(O, /obj/item/weapon/screwdriver) && machine_flags & SCREWTOGGLE)
		return togglePanelOpen(O, user)

	if(istype(O, /obj/item/weapon/crowbar) && machine_flags & CROWDESTROY)
		if(panel_open)
			if(crowbarDestroy(user) == 1)
				qdel(src)
				return 1
			else
				return -1

	if(!anchored && machine_flags & FIXED2WORK)
		return user << "<span class='warning'>\The [src] must be anchored first!</span>"

/obj/machinery/proc/shock(mob/user, prb, var/siemenspassed = -1)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(siemenspassed == -1) //this means it hasn't been set by proc arguments, so we can set it ourselves safely
		siemenspassed = 0.7
	if (electrocute_mob(user, get_area(src), src, siemenspassed))
		return 1
	else
		return -1
