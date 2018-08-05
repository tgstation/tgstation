/datum/component/integrated_electronic
	var/list/assembly_circuits = list()
	var/max_circuits
	var/max_complexity
	datum_flags = DF_USE_TAG
	var/list/ckeys_allowed_to_scan = list() // Players who built the circuit can scan it as a ghost.
	var/opened = TRUE
	var/obj/item/stock_parts/cell/battery // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/stock_parts/cell
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/can_fire_equipped //Can it fire/throw weapons when the assembly is being held?
	var/charge_sections = 4
	var/charge_tick = FALSE
	var/charge_delay = 4
	var/use_cyborg_cell = TRUE
	var/ext_next_use = 0
	var/atom/collw
	var/obj/item/card/id/access_card
	var/allowed_circuit_action_flags//which circuit flags are allowed
	var/combat_circuits = 0 //number of combat cicuits in the assembly, used for diagnostic hud
	var/long_range_circuits = 0 //number of long range cicuits in the assembly, used for diagnostic hud
	var/prefered_hud_icon = "hudstat"		// Used by the AR circuit to change the hud icon.
	var/detail_color = COLOR_ASSEMBLY_BLACK
	var/creator // circuit creator if any
	var/static/next_assembly_id = 0
	var/atom/assembly_atom

/datum/component/integrated_electronic/Initialize(_max_circuits , _max_complexity, _allowed_circuit_action_flags = IC_ACTION_COMBAT|IC_ACTION_LONG_RANGE,_can_fire_equipped = FALSE)
	tag = "assembly_[next_assembly_id++]"//datums can't use GenerateTag() so we assign it here
	assembly_atom = parent
	if(!istype(assembly_atom))//So many parts of circuits use the parent as an atom that we define it as a var
		return COMPONENT_INCOMPATIBLE
	max_circuits = round(_max_circuits)
	max_complexity = round(_max_complexity)
	allowed_circuit_action_flags = _allowed_circuit_action_flags
	can_fire_equipped = _can_fire_equipped
	START_PROCESSING(SScircuit, src)
	var/obj/item/assembly_item = parent
	if(istype(assembly_item))
		assembly_item.materials[MAT_METAL] = IC_GET_COST(max_circuits, max_complexity)
	access_card = new /obj/item/card/id(src)
	update_icon()

	//sets up diagnostic hud view
	assembly_atom.prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(assembly_atom)
	update_hud()

	//when the parent calls these signals we in turn call these procs
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, .proc/ie_collide)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/ie_examine)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/ie_after_attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/ie_attackby)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/ie_attack_self)
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, .proc/ie_emp_act)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/ie_moved)
	RegisterSignal(parent, COMSIG_MOVABLE_STOP_PULLING, .proc/ie_stop_pulling)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/ie_attack_hand)
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/ie_pickup)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/ie_dropped)

/datum/component/integrated_electronic/proc/update_hud(hide = FALSE)
	var/mob/living/assembly_living = parent
	var/obj/assembly_obj = parent
	var/percentHealth = 100
	var/percentCell = -1
	if(istype(assembly_living))
		percentHealth = assembly_living.health/100
	else if(istype(assembly_obj))
		percentHealth = assembly_obj.obj_integrity/assembly_obj.max_integrity
	if(battery)
		percentCell = battery.charge/battery.maxcharge
	assembly_atom.diag_hud_set_circuithealth(percentHealth, hide)
	assembly_atom.diag_hud_set_circuitcell(percentCell, hide) //use -1 if we don't have a battery
	assembly_atom.diag_hud_set_circuitstat(percentCell, prefered_hud_icon, combat_circuits, hide)
	assembly_atom.diag_hud_set_circuittracking(long_range_circuits, hide)

/datum/component/integrated_electronic/proc/check_interactivity(mob/user)
	return user.canUseTopic(assembly_atom, BE_CLOSE)

/datum/component/integrated_electronic/proc/ie_collide(atom/AM)
	collw = AM
	.=..()
	if((istype(collw, /obj/machinery/door/airlock) ||  istype(collw, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = collw
		if(D.check_access(access_card))
			D.open()

/datum/component/integrated_electronic/Destroy()
	STOP_PROCESSING(SScircuit, src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(assembly_atom)
	QDEL_NULL(access_card)
	return ..()

/datum/component/integrated_electronic/process()
	handle_idle_power()
	var/atom/movable/assembly_movable = parent
	if(istype(assembly_movable))
		assembly_movable.check_pulling()

	//updates diagnostic hud
	update_hud()

/datum/component/integrated_electronic/proc/handle_idle_power()
	// First we generate power.
	for(var/obj/item/integrated_circuit/passive/power/P in assembly_circuits)
		P.make_energy()

	// Now spend it.
	for(var/I in assembly_circuits)
		var/obj/item/integrated_circuit/IC = I
		if(IC.power_draw_idle)
			if(!draw_power(IC.power_draw_idle))
				IC.power_fail()

/datum/component/integrated_electronic/proc/interact(mob/user)
	ui_interact(user)

/datum/component/integrated_electronic/ui_interact(mob/user)
	if(!check_interactivity(user))
		return

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/HTML = ""

	HTML += "<html><head><title>[parent]</title></head><body>"

	HTML += "<a href='?src=[REF(src)]'>\[Refresh\]</a>  |  <a href='?src=[REF(src)];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_part_size]/[max_circuits] ([round((total_part_size / max_circuits) * 100, 0.1)]%) space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] ([round((total_complexity / max_complexity) * 100, 0.1)]%) maximum complexity.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='?src=[REF(src)];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += "<span class='danger'>No power cell detected!</span>"
	HTML += "<br><br>"



	HTML += "Circuits:"

	var/builtin_circuits = ""

	for(var/c in assembly_circuits)
		var/obj/item/integrated_circuit/circuit = c
		if(!circuit.removable)
			builtin_circuits += "<a href='?src=[REF(circuit)];rename=1;return=1'>\[R\]</a> | "
			builtin_circuits += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a>"
			builtin_circuits += "<br>"

	// Put removable circuits (if any) in separate categories from non-removable
	if(builtin_circuits)
		HTML += "<hr>"
		HTML += "Built in:<br>"
		HTML += builtin_circuits
		HTML += "<hr>"
		HTML += "Removable:"

	HTML += "<br>"

	for(var/c in assembly_circuits)
		var/obj/item/integrated_circuit/circuit = c
		if(circuit.removable)
			HTML += "<a href='?src=[REF(src)];circuit=[REF(circuit)];up=1' style='text-decoration:none;'>&#8593;</a> "
			HTML += "<a href='?src=[REF(src)];circuit=[REF(circuit)];down=1' style='text-decoration:none;'>&#8595;</a>  "
			HTML += "<a href='?src=[REF(src)];circuit=[REF(circuit)];top=1' style='text-decoration:none;'>&#10514;</a> "
			HTML += "<a href='?src=[REF(src)];circuit=[REF(circuit)];bottom=1' style='text-decoration:none;'>&#10515;</a> | "
			HTML += "<a href='?src=[REF(circuit)];circuit=[REF(circuit)];rename=1;return=1'>\[R\]</a> | "
			HTML += "<a href='?src=[REF(src)];circuit=[REF(circuit)];remove=1'>\[-\]</a> | "
			HTML += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a>"
			HTML += "<br>"

	HTML += "</body></html>"
	user << browse(HTML, "window=assembly-[REF(src)];size=655x350;border=1;can_resize=1;can_close=1;can_minimize=1")

/datum/component/integrated_electronic/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["ghostscan"])
		if((isobserver(usr) && ckeys_allowed_to_scan[usr.ckey]) || IsAdminGhost(usr))
			if(assembly_circuits.len)
				var/saved = "On circuit printers with cloning enabled, you may use the code below to clone the circuit:<br><br><code>[SScircuit.save_electronic_assembly(src)]</code>"
				usr << browse(saved, "window=circuit_scan;size=500x600;border=1;can_resize=1;can_close=1;can_minimize=1")
			else
				to_chat(usr, "<span class='warning'>The circuit is empty!</span>")
		return

	if(!check_interactivity(usr))
		return

	if(href_list["rename"])
		rename()

	if(href_list["remove_cell"])
		if(!battery)
			to_chat(usr, "<span class='warning'>There's no power cell to remove from \the [parent].</span>")
		else
			battery.forceMove(assembly_atom.drop_location())
			playsound(parent, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>You pull \the [battery] out of \the [parent]'s power supplier.</span>")
			battery = null
			update_hud()

	if(href_list["circuit"])
		var/obj/item/integrated_circuit/circuit = locate(href_list["circuit"]) in assembly_circuits
		if(circuit)
			// Builtin circuits are not supposed to be removed or rearranged
			if(!circuit.removable)
				return

			add_allowed_scanner(usr.ckey)

			var/current_pos = assembly_circuits.Find(circuit)

			// Find the position of a first removable circuit
			var/first_removable_pos
			for(var/i in 1 to assembly_circuits.len)
				var/obj/item/integrated_circuit/temp_circuit = assembly_circuits[i]
				if(temp_circuit.removable)
					first_removable_pos = i
					break

			if(href_list["remove"])
				try_remove_circuit(circuit, usr)

			else
				// Adjust the position
				if(href_list["up"])
					current_pos--
				else if(href_list["down"])
					current_pos++
				else if(href_list["top"])
					current_pos = first_removable_pos
				else if(href_list["bottom"])
					current_pos = assembly_circuits.len

				// Wrap around nicely
				if(current_pos < first_removable_pos)
					current_pos = assembly_circuits.len
				else if(current_pos > assembly_circuits.len)
					current_pos = first_removable_pos

				assembly_circuits.Remove(circuit)
				assembly_circuits.Insert(current_pos, circuit)

	interact(usr) // To refresh the UI.

/datum/component/integrated_electronic/proc/ie_pickup(mob/living/user)
	//update diagnostic hud when picked up, true is used to force the hud to be hidden
	update_hud(TRUE)

/datum/component/integrated_electronic/proc/ie_dropped(mob/user)
	//update diagnostic hud when dropped
	update_hud()

/datum/component/integrated_electronic/proc/rename()
	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(input("What do you want to name this?", "Rename", assembly_atom.name) as null|text, TRUE)
	if(!check_interactivity(M))
		return
	if(src && input)
		to_chat(M, "<span class='notice'>The machine now has a label reading '[input]'.</span>")
		assembly_atom.name = input

/datum/component/integrated_electronic/proc/add_allowed_scanner(ckey)
	ckeys_allowed_to_scan[ckey] = TRUE

/datum/component/integrated_electronic/proc/update_icon()
	if(opened)
		assembly_atom.icon_state = initial(assembly_atom.icon_state) + "-open"
	else
		assembly_atom.icon_state = initial(assembly_atom.icon_state)
	assembly_atom.cut_overlays()
	if(detail_color == COLOR_ASSEMBLY_BLACK) //Black colored overlay looks almost but not exactly like the base sprite, so just cut the overlay and avoid it looking kinda off.
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/assemblies/electronic_setups.dmi', "[assembly_atom.icon_state]-color")
	detail_overlay.color = detail_color
	assembly_atom.add_overlay(detail_overlay)

/datum/component/integrated_electronic/proc/ie_examine(mob/user)
	to_chat(user, "<span class='notice'>The maintainence panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")
	for(var/I in assembly_circuits)
		var/obj/item/integrated_circuit/IC = I
		IC.external_examine(user)
	if(opened)
		interact(user)

	if((isobserver(user) && ckeys_allowed_to_scan[user.ckey]) || IsAdminGhost(user))
		to_chat(user, "You can <a href='?src=[REF(src)];ghostscan=1'>scan</a> this circuit.");

/datum/component/integrated_electronic/proc/return_total_complexity()
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_circuits)
		part = p
		. += part.complexity

/datum/component/integrated_electronic/proc/return_total_size()
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_circuits)
		part = p
		. += part.size

// Returns true if the circuit made it inside.
/datum/component/integrated_electronic/proc/try_add_circuit(obj/item/integrated_circuit/IC, mob/user)
	if(!opened)
		to_chat(user, "<span class='warning'>\The [parent]'s hatch is closed, you can't put anything inside.</span>")
		return FALSE

	var/obj/item/assembly_item = parent
	if(istype(assembly_item) && IC.w_class > assembly_item.w_class)
		to_chat(user, "<span class='warning'>\The [IC] is way too big to fit into \the [parent].</span>")
		return FALSE

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()

	if((total_part_size + IC.size) > max_circuits)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', as there's insufficient space.</span>")
		return FALSE
	if((total_complexity + IC.complexity) > max_complexity)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since this setup's too complicated for the case.</span>")
		return FALSE
	if((allowed_circuit_action_flags & IC.action_flags) != IC.action_flags)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since the case doesn't support the circuit type.</span>")
		return FALSE

	if(!user.transferItemToLoc(IC, parent))
		return FALSE

	to_chat(user, "<span class='notice'>You slide [IC] inside [parent].</span>")
	playsound(parent, 'sound/items/Deconstruct.ogg', 50, 1)
	add_allowed_scanner(user.ckey)
	assembly_atom.investigate_log("had [IC]([IC.type]) inserted by [key_name(user)].", INVESTIGATE_CIRCUIT)

	add_circuit(IC)
	return TRUE


// Actually puts the circuit inside, doesn't perform any checks.
/datum/component/integrated_electronic/proc/add_circuit(obj/item/integrated_circuit/circuit)
	circuit.forceMove(get_object())
	circuit.assembly = src
	assembly_circuits |= circuit

	//increment numbers for diagnostic hud
	if(circuit.action_flags & IC_ACTION_COMBAT)
		combat_circuits += 1;
	if(circuit.action_flags & IC_ACTION_LONG_RANGE)
		long_range_circuits += 1;

	//diagnostic hud update
	update_hud()


/datum/component/integrated_electronic/proc/try_remove_circuit(obj/item/integrated_circuit/IC, mob/user, silent)
	if(!opened)
		if(!silent)
			to_chat(user, "<span class='warning'>[parent]'s hatch is closed, so you can't fiddle with the internal circuits.</span>")
		return FALSE

	if(!IC.removable)
		if(!silent)
			to_chat(user, "<span class='warning'>[parent] is permanently attached to the case.</span>")
		return FALSE

	remove_circuit(IC)
	if(!silent)
		to_chat(user, "<span class='notice'>You pop \the [IC] out of the case, and slide it out.</span>")
		playsound(parent, 'sound/items/crowbar.ogg', 50, 1)
		user.put_in_hands(IC)
	add_allowed_scanner(user.ckey)
	assembly_atom.investigate_log("had [IC]([IC.type]) removed by [key_name(user)].", INVESTIGATE_CIRCUIT)

	return TRUE

// Actually removes the circuit, doesn't perform any checks.
/datum/component/integrated_electronic/proc/remove_circuit(obj/item/integrated_circuit/circuit)
	circuit.disconnect_all()
	circuit.forceMove(drop_location())
	circuit.assembly = null
	assembly_circuits.Remove(circuit)

	//decriment numbers for diagnostic hud
	if(circuit.action_flags & IC_ACTION_COMBAT)
		combat_circuits -= 1;
	if(circuit.action_flags & IC_ACTION_LONG_RANGE)
		long_range_circuits -= 1;

	//diagnostic hud update
	update_hud()


/datum/component/integrated_electronic/proc/ie_after_attack(atom/target, mob/living/user, params)
	for(var/obj/item/integrated_circuit/input/S in assembly_circuits)
		if(S.sense(target,user, user.CanReach(target, parent)))
			assembly_atom.visible_message("<span class='notice'> [user] waves [assembly_atom] around [target].</span>")


/datum/component/integrated_electronic/proc/ie_screwdriver_act(mob/living/user, obj/item/I)
	I.play_tool_sound(parent)
	opened = !opened
	to_chat(user, "<span class='notice'>You [opened ? "open" : "close"] the maintenance hatch of [parent].</span>")
	update_icon()
	return TRUE

/datum/component/integrated_electronic/proc/ie_attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/integrated_circuit))
		if(!user.canUnEquip(I))
			return FALSE
		if(try_add_circuit(I, user))
			interact(user)
			return TRUE
		else
			for(var/obj/item/integrated_circuit/input/S in assembly_circuits)
				S.attackby_react(I,user,user.a_intent)
			return ..()
	else if(istype(I, /obj/item/multitool) || istype(I, /obj/item/integrated_electronics/wirer) || istype(I, /obj/item/integrated_electronics/debugger))
		if(opened)
			interact(user)
			return TRUE
		else
			to_chat(user, "<span class='warning'>[parent]'s hatch is closed, so you can't fiddle with the internal circuits.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_circuits)
				S.attackby_react(I,user,user.a_intent)
			return ..()
	else if(istype(I, /obj/item/screwdriver))
		return ie_screwdriver_act(user, I)
	else if(istype(I, /obj/item/stock_parts/cell))
		if(!opened)
			to_chat(user, "<span class='warning'>[parent]'s hatch is closed, so you can't access \the [parent]'s power supplier.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_circuits)
				S.attackby_react(I,user,user.a_intent)
			return ..()
		if(battery)
			to_chat(user, "<span class='warning'>[parent] already has \a [battery] installed. Remove it first if you want to replace it.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_circuits)
				S.attackby_react(I,user,user.a_intent)
			return ..()
		var/obj/item/stock_parts/cell = I
		user.transferItemToLoc(I, assembly_atom.loc)
		cell.forceMove(assembly_atom)
		battery = cell
		update_hud() //update diagnostic hud
		playsound(get_turf(parent), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You slot \the [cell] inside \the [parent]'s power supplier.</span>")
		interact(user)
		return TRUE
	else if(istype(I, /obj/item/integrated_electronics/detailer))
		var/obj/item/integrated_electronics/detailer/D = I
		detail_color = D.detail_color
		var/obj/assembly_obj = parent
		if(istype(assembly_obj))
			assembly_obj.update_icon()
	else
		for(var/obj/item/integrated_circuit/input/S in assembly_circuits)
			S.attackby_react(I,user,user.a_intent)
		if(user.a_intent != INTENT_HELP)
			return ..()


/datum/component/integrated_electronic/proc/ie_attack_self(mob/user)
	if(!check_interactivity(user))
		return
	if(opened)
		interact(user)

	var/list/input_selection = list()
	var/list/available_inputs = list()
	for(var/obj/item/integrated_circuit/input/input in assembly_circuits)
		if(input.can_be_asked_input)
			available_inputs.Add(input)
			var/i = 0
			for(var/obj/item/integrated_circuit/s in available_inputs)
				if(s.name == input.name && s.displayed_name == input.displayed_name && s != input)
					i++
			var/disp_name= "[input.displayed_name] \[[input]\]"
			if(i)
				disp_name += " ([i+1])"
			input_selection.Add(disp_name)

	var/obj/item/integrated_circuit/input/choice
	if(available_inputs)
		if(available_inputs.len ==1)
			choice = available_inputs[1]
		else
			var/selection = input(user, "What do you want to interact with?", "Interaction") as null|anything in input_selection
			if(!check_interactivity(user))
				return
			if(selection)
				var/index = input_selection.Find(selection)
				choice = available_inputs[index]

	if(choice)
		choice.ask_for_input(user)

/datum/component/integrated_electronic/proc/ie_emp_act(severity)
	if(parent.GetComponent(/datum/component/empprotection).getEmpFlags(severity) | EMP_PROTECT_CONTENTS)
		return
	for(var/I in assembly_circuits)
		var/atom/movable/AM = I
		AM.emp_act(severity)

// Returns true if power was successfully drawn.
/datum/component/integrated_electronic/proc/draw_power(amount)
	if(battery && battery.use(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
/datum/component/integrated_electronic/proc/give_power(amount)
	if(battery && battery.give(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

/datum/component/integrated_electronic/proc/ie_moved(oldLoc, dir)
	for(var/I in assembly_circuits)
		var/obj/item/integrated_circuit/IC = I
		IC.ext_moved(oldLoc, dir)
	if(assembly_atom.light) //Update lighting objects (From light circuits).
		assembly_atom.update_light()

/datum/component/integrated_electronic/proc/ie_stop_pulling()
	for(var/I in assembly_circuits)
		var/obj/item/integrated_circuit/IC = I
		IC.stop_pulling()

// Returns the object that is supposed to be used in attack messages, location checks, etc.
// Override in children for special behavior.
/datum/component/integrated_electronic/proc/get_object()
	return parent

// Redirects to the drop_location() of the actual atom.
/datum/component/integrated_electronic/proc/drop_location()
	return assembly_atom.drop_location()

/datum/component/integrated_electronic/proc/ie_attack_hand(mob/user)
	if(!istype(parent, /obj/item))
		ie_attack_self(user)
		return