/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'Initialize()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Destroy' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         NO_POWER_USE -- no auto power use
         IDLE_POWER_USE -- machine is using power at its idle power level
         ACTIVE_POWER_USE -- machine is using power at its active power level

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
         BROKEN -- Machine is broken
         NOPOWER -- No power is being supplied to machine.
         MAINT -- machine is currently under going maintenance.
         EMPED -- temporary broken by EMP pulse

Class Procs:
   Initialize()                     'game/machinery/machine.dm'

   Destroy()                   'game/machinery/machine.dm'

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
      Called by the 'machinery subsystem' once per machinery tick for each machine that is listed in its 'machines' list.

   process_atmos()
      Called by the 'air subsystem' once per atmos tick for each machine that is listed in its 'atmos_machines' list.

   is_operational()
		Returns 0 if the machine is unpowered, broken or undergoing maintenance, something else if not

	Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	verb_say = "beeps"
	verb_yell = "blares"
	pressure_resistance = 15
	max_integrity = 200

	var/stat = 0
	var/emagged = FALSE
	var/use_power = IDLE_POWER_USE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/global/gl_uid = 1
	var/panel_open = FALSE
	var/state_open = FALSE
	var/critical_machine = FALSE //If this machine is critical to station operation and should have the area be excempted from power failures.
	var/list/occupant_typecache = list(/mob/living) // turned into typecache in Initialize
	var/atom/movable/occupant = null
	var/unsecuring_tool = /obj/item/wrench
	var/interact_open = FALSE // Can the machine be interacted with when in maint/when the panel is open.
	var/interact_offline = 0 // Can the machine be interacted with while de-powered.
	var/speed_process = 0 // Process as fast as possible?
	var/obj/item/circuitboard/circuit // Circuit to be created and inserted when the machinery is created

/obj/machinery/Initialize()
	if(!armor)
		armor = list(melee = 25, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
	. = ..()
	GLOB.machines += src

	if(ispath(circuit, /obj/item/circuitboard))
		circuit = new circuit
		circuit.apply_default_parts(src)

	if(!speed_process)
		START_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSfastprocess, src)
	power_change()

	occupant_typecache = typecacheof(occupant_typecache)

/obj/machinery/Destroy()
	GLOB.machines.Remove(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	dropContents()
	return ..()

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()//If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && !stat)
		use_power(7500/severity)
		new /obj/effect/temp_visual/emp(loc)
	..()

/obj/machinery/proc/open_machine(drop = 1)
	state_open = TRUE
	density = FALSE
	if(drop)
		dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/proc/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
		if(isliving(A))
			var/mob/living/L = A
			L.update_canmove()
	occupant = null

/obj/machinery/proc/close_machine(atom/movable/target = null)
	state_open = FALSE
	density = TRUE
	if(!target)
		for(var/am in loc)
			if(!is_type_in_typecache(am, occupant_typecache))
				continue
			var/atom/movable/AM = am
			if(AM.has_buckled_mobs())
				continue
			if(isliving(AM))
				var/mob/living/L = am
				if(L.buckled)
					continue
			target = am

	var/mob/living/mobtarget = target
	if(target && !target.has_buckled_mobs() && (!isliving(target) || !mobtarget.buckled))
		occupant = target
		target.forceMove(src)
	updateUsrDialog()
	update_icon()

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(use_power == 1)
		use_power(idle_power_usage,power_channel)
	else if(use_power >= 2)
		use_power(active_power_usage,power_channel)
	return 1

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/proc/is_interactable()
	if((stat & (NOPOWER|BROKEN)) && !interact_offline)
		return FALSE
	if(panel_open && !interact_open)
		return FALSE
	return TRUE


////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/interact(mob/user, special_state)
	add_fingerprint(user)
	if(special_state)
		ui_interact(user, state = special_state)
	else
		ui_interact(user)

/obj/machinery/ui_status(mob/user)
	if(is_interactable())
		return ..()
	return UI_CLOSE

/obj/machinery/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/machinery/Topic(href, href_list)
	..()
	if(!is_interactable())
		return 1
	if(!usr.canUseTopic(src))
		return 1
	add_fingerprint(usr)
	return 0


////////////////////////////////////////////////////////////////////////////////////////////



/obj/machinery/attack_paw(mob/living/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		user.visible_message("<span class='danger'>[user.name] smashes against \the [src.name] with its paws.</span>", null, null, COMBAT_MESSAGE_RANGE)
		take_damage(4, BRUTE, "melee", 1)


/obj/machinery/attack_ai(mob/user)
	if(iscyborg(user))// For some reason attack_robot doesn't work
		var/mob/living/silicon/robot/R = user
		if(R.client && R.client.eye == R && !R.low_power_mode)// This is to stop robots from using cameras to remotely control machines; and from using machines when the borg has no power.
			return attack_hand(user)
	else
		return attack_hand(user)


//set_machine must be 0 if clicking the machinery doesn't bring up a dialog
/obj/machinery/attack_hand(mob/user, check_power = 1, set_machine = 1)
	if(..())// unbuckling etc
		return 1
	if((user.lying || user.stat) && !IsAdminGhost(user))
		return 1
	if(!user.IsAdvancedToolUser() && !IsAdminGhost(user))
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	if(!is_interactable())
		return 1
	if(set_machine)
		user.set_machine(src)
	interact(user)
	add_fingerprint(user)
	return 0

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/default_pry_open(obj/item/crowbar/C)
	. = !(state_open || panel_open || is_operational() || (flags_1 & NODECONSTRUCT_1)) && istype(C)
	if(.)
		playsound(loc, C.usesound, 50, 1)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()
		return 1

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/crowbar/C, ignore_panel = 0)
	. = istype(C) && (panel_open || ignore_panel) &&  !(flags_1 & NODECONSTRUCT_1)
	if(.)
		playsound(loc, C.usesound, 50, 1)
		deconstruct(TRUE)

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		if(component_parts && component_parts.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
	qdel(src)

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/structure/frame/machine/M = new /obj/structure/frame/machine(loc)
	. = M
	M.anchored = anchored
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

/obj/machinery/obj_break(damage_flag)
	if(!(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN

/obj/machinery/contents_explosion(severity, target)
	if(occupant)
		occupant.ex_act(severity, target)

/obj/machinery/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		update_icon()
		updateUsrDialog()

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver/S)
	if(istype(S) &&  !(flags_1 & NODECONSTRUCT_1))
		playsound(loc, S.usesound, 50, 1)
		if(!panel_open)
			panel_open = TRUE
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			panel_open = FALSE
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	if(panel_open && istype(W))
		playsound(loc, W.usesound, 50, 1)
		setDir(turn(dir,-90))
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		return 1
	return 0

/obj/proc/can_be_unfasten_wrench(mob/user, silent) //if we can unwrench this object; returns SUCCESSFUL_UNFASTEN and FAILED_UNFASTEN, which are both TRUE, or CANT_UNFASTEN, which isn't.
	if(!isfloorturf(loc) && !anchored)
		to_chat(user, "<span class='warning'>[src] needs to be on the floor to be secured!</span>")
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/proc/default_unfasten_wrench(mob/user, obj/item/wrench/W, time = 20) //try to unwrench an object in a WONDERFUL DYNAMIC WAY
	if(istype(W) && !(flags_1 & NODECONSTRUCT_1))
		var/can_be_unfasten = can_be_unfasten_wrench(user)
		if(!can_be_unfasten || can_be_unfasten == FAILED_UNFASTEN)
			return can_be_unfasten
		if(time)
			to_chat(user, "<span class='notice'>You begin [anchored ? "un" : ""]securing [src]...</span>")
		playsound(loc, W.usesound, 50, 1)
		var/prev_anchored = anchored
		//as long as we're the same anchored state and we're either on a floor or are anchored, toggle our anchored state
		if(!time || do_after(user, time*W.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/unfasten_wrench_check, prev_anchored, user)))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [src].</span>")
			anchored = !anchored
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			return SUCCESSFUL_UNFASTEN
		return FAILED_UNFASTEN
	return CANT_UNFASTEN

/obj/proc/unfasten_wrench_check(prev_anchored, mob/user) //for the do_after, this checks if unfastening conditions are still valid
	if(anchored != prev_anchored)
		return FALSE
	if(can_be_unfasten_wrench(user, TRUE) != SUCCESSFUL_UNFASTEN) //if we aren't explicitly successful, cancel the fuck out
		return FALSE
	return TRUE

/obj/machinery/proc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return
	if((flags_1 & NODECONSTRUCT_1) && !W.works_from_distance)
		return
	var/shouldplaysound = 0
	if(component_parts)
		if(panel_open || W.works_from_distance)
			var/obj/item/circuitboard/machine/CB = locate(/obj/item/circuitboard/machine) in component_parts
			var/P
			if(W.works_from_distance)
				display_parts(user)
			for(var/obj/item/stock_parts/A in component_parts)
				for(var/D in CB.req_components)
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/stock_parts/B in W.contents)
					if(istype(B, P) && istype(A, P))
						if(B.rating > A.rating)
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
							shouldplaysound = 1 //Only play the sound when parts are actually replaced!
							break
			RefreshParts()
		else
			display_parts(user)
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	return 0

/obj/machinery/proc/display_parts(mob/user)
	to_chat(user, "<span class='notice'>Following parts detected in the machine:</span>")
	for(var/obj/item/C in component_parts)
		to_chat(user, "<span class='notice'>[icon2html(C, user)] [C.name]</span>")

/obj/machinery/examine(mob/user)
	..()
	if(stat & BROKEN)
		to_chat(user, "<span class='notice'>It looks broken and non functional.</span>")
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			to_chat(user, "<span class='warning'>It's on fire!</span>")
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				to_chat(user,  "It looks slightly damaged.")
			if(25 to 50)
				to_chat(user,  "It appears heavily damaged.")
			if(0 to 25)
				to_chat(user,  "<span class='warning'>It's falling apart!</span>")
	if(user.research_scanner && component_parts)
		display_parts(user)

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

//called on deconstruction before the final deletion
/obj/machinery/proc/on_deconstruction()
	return

// Hook for html_interface module to prevent updates to clients who don't have this as their active machine.
/obj/machinery/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	if (hclient.client.mob && (hclient.client.mob.stat == 0 || IsAdminGhost(hclient.client.mob)))
		if (isAI(hclient.client.mob) || IsAdminGhost(hclient.client.mob)) return TRUE
		else                          return hclient.client.mob.machine == src && Adjacent(hclient.client.mob)
	else
		return FALSE

// Hook for html_interface module to unset the active machine when the window is closed by the player.
/obj/machinery/proc/hiOnHide(datum/html_interface_client/hclient)
	if (hclient.client.mob && hclient.client.mob.machine == src) hclient.client.mob.unset_machine()

/obj/machinery/proc/can_be_overridden()
	. = 1


/obj/machinery/tesla_act(power, explosive = FALSE)
	..()
	if(prob(85) && explosive)
		explosion(src.loc,1,2,4,flame_range = 2, adminlog = 0, smoke = 0)
	else if(prob(50))
		emp_act(EMP_LIGHT)
	else
		ex_act(EXPLODE_HEAVY)

/obj/machinery/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if (AM == occupant)
		occupant = null
