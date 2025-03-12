/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	density = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	armor_type = /datum/armor/machinery_computer
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_LITERACY
	/// How bright we are when turned on.
	var/brightness_on = 1
	/// Icon_state of the keyboard overlay.
	var/icon_keyboard = "generic_key"
	/// Should we render an unique icon for the keyboard when off?
	var/keyboard_change_icon = TRUE
	/// Icon_state of the emissive screen overlay.
	var/icon_screen = "generic"
	/// Time it takes to deconstruct with a screwdriver.
	var/time_to_unscrew = 2 SECONDS
	/// Are we authenticated to use this? Used by things like comms console, security and medical data, and apc controller.
	var/authenticated = FALSE
	/// Will projectiles be able to pass over this computer?
	var/projectiles_pass_chance = 65

/datum/armor/machinery_computer
	fire = 40
	acid = 20

/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	power_change()

/obj/machinery/computer/mouse_drop_receive(mob/living/dropping, mob/user, params)
	. = ..()
	// We add the component only once here & not in Initialize() because there are tons of computers & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/machinery/computer/CanAllowThrough(atom/movable/mover, border_dir) // allows projectiles to fly over the computer
	. = ..()
	if(.)
		return
	if(!projectiles_pass_chance)
		return FALSE
	if(!isprojectile(mover))
		return FALSE
	var/obj/projectile/proj = mover
	if(!anchored)
		return TRUE
	if(proj.firer && Adjacent(proj.firer))
		return TRUE
	if(prob(projectiles_pass_chance))
		return TRUE
	return FALSE

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	return TRUE

/obj/machinery/computer/update_overlays()
	. = ..()
	if(icon_keyboard)
		if(keyboard_change_icon && (machine_stat & NOPOWER))
			. += "[icon_keyboard]_off"
		else
			. += icon_keyboard

	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return // If we don't do this broken computers glow in the dark.

	if(machine_stat & NOPOWER) // Your screen can't be on if you've got no damn charge
		return

	// This lets screens ignore lighting and be visible even in the darkest room
	if(icon_screen)
		. += mutable_appearance(icon, icon_screen)
		. += emissive_appearance(icon, icon_screen, src)

/obj/machinery/computer/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
	else
		set_light(brightness_on)

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit)
		balloon_alert(user, "disconnecting monitor...")
		if(I.use_tool(src, user, time_to_unscrew, volume=50))
			deconstruct(TRUE)
	return TRUE

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/machinery/computer/atom_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
		set_light(0)

/obj/machinery/computer/proc/imprint_gps(gps_tag) // Currently used by the upload computers and communications console
	if(!length(gps_tag)) // Don't give a null GPS signal if there is none
		CRASH("[src] called imprint_gps without setting gps_tag")
	var/set_tracker = FALSE
	for(var/obj/item/circuitboard/computer/board in contents)
		if(board.GetComponent(/datum/component/gps))
			return
		board.AddComponent(/datum/component/gps, "[gps_tag]")
		set_tracker = TRUE
	if (set_tracker)
		balloon_alert_to_viewers("board tracker enabled", vision_distance = 1)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					atom_break(ENERGY)
			if(2)
				if(prob(10))
					atom_break(ENERGY)

/obj/machinery/computer/spawn_frame(disassembled)
	if(QDELETED(circuit)) //no circuit, no computer frame
		return

	var/obj/structure/frame/computer/new_frame = new(loc)
	new_frame.setDir(dir)
	new_frame.set_anchored(TRUE)
	new_frame.circuit = circuit
	// Circuit removal code is handled in /obj/machinery/Exited()
	component_parts -= circuit
	circuit.forceMove(new_frame)

	if((machine_stat & BROKEN) || !disassembled)
		var/atom/drop_loc = drop_location()
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		new /obj/item/shard(drop_loc)
		new /obj/item/shard(drop_loc)
		new_frame.state = FRAME_COMPUTER_STATE_WIRED
	else
		new_frame.state = FRAME_COMPUTER_STATE_GLASSED
	new_frame.update_appearance(UPDATE_ICON_STATE)

/obj/machinery/computer/ui_interact(mob/user, datum/tgui/ui)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	update_use_power(ACTIVE_POWER_USE)

/obj/machinery/computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(!issilicon(ui.user))
		playsound(src, SFX_KEYBOARD_CLICKS, 10, TRUE, FALSE)

/obj/machinery/computer/ui_close(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	update_use_power(IDLE_POWER_USE)
