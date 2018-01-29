#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

/obj/item/device/electronic_assembly
	name = "electronic assembly"
	desc = "It's a case, for building small electronics with."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small"
	flags_1 = NOBLUDGEON_1
	materials = list()		// To be filled later
	var/list/assembly_components = list()
	var/max_components = IC_MAX_SIZE_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = FALSE
	var/obj/item/stock_parts/cell/battery // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/stock_parts/cell
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/charge_sections = 4
	var/charge_tick = FALSE
	var/charge_delay = 4
	var/use_cyborg_cell = TRUE
	max_integrity = 50
	armor = list(melee = 50, bullet = 70, laser = 70, energy = 100, bomb = 10, bio = 100, rad = 100, fire = 0, acid = 0)

/obj/item/device/electronic_assembly/proc/check_interactivity(mob/user)
	return user.canUseTopic(src,be_close = TRUE)


/obj/item/device/electronic_assembly/Initialize()
	.=..()
	START_PROCESSING(SScircuit, src)
	materials[MAT_METAL] = round((max_complexity + max_components) / 4) * SScircuit.cost_multiplier

/obj/item/device/electronic_assembly/Destroy()
	STOP_PROCESSING(SScircuit, src)
	return ..()

/obj/item/device/electronic_assembly/process()
	handle_idle_power()
	check_pulling()

/obj/item/device/electronic_assembly/proc/handle_idle_power()
	if(assembly_components && assembly_components.len)
		for(var/i in 1 to assembly_components.len)
			var/obj/item/integrated_circuit/IC = assembly_components[i]
			if(istype(IC, /obj/item/integrated_circuit/passive/power))
				var/obj/item/integrated_circuit/passive/power/P = IC
				P.make_energy()
			if(IC.power_draw_idle)
				if(!draw_power(IC.power_draw_idle))
					IC.power_fail()
			CHECK_TICK


/obj/item/device/electronic_assembly/interact(mob/user)
	if(!check_interactivity(user))
		return

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/HTML = ""

	HTML += "<html><head><title>[name]</title></head><body>"

	HTML += "<a href='?src=[REF(src)]'>\[Refresh\]</a>  |  <a href='?src=[REF(src)];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_part_size]/[max_components] ([round((total_part_size / max_components) * 100, 0.1)]%) space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] ([round((total_complexity / max_complexity) * 100, 0.1)]%) maximum complexity.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='?src=[REF(src)];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += "<span class='danger'>No power cell detected!</span>"
	HTML += "<br><br>"



	HTML += "Components:"

	var/builtin_components = ""

	if(assembly_components && assembly_components.len)
		for(var/i in 1 to assembly_components.len)
			var/obj/item/integrated_circuit/circuit = assembly_components[i]
			if(!circuit.removable)
				builtin_components += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a> | "
				builtin_components += "<a href='?src=[REF(circuit)];rename=1;return=1'>\[Rename\]</a> | "
				builtin_components += "<a href='?src=[REF(circuit)];scan=1'>\[Scan with Debugger\]</a>"
				builtin_components += "<br>"
			CHECK_TICK

	// Put removable circuits (if any) in separate categories from non-removable
	if(builtin_components)
		HTML += "<hr>"
		HTML += "Built in:<br>"
		HTML += builtin_components
		HTML += "<hr>"
		HTML += "Removable:"

	HTML += "<br>"
	if(assembly_components && assembly_components.len)
		for(var/i in 1 to assembly_components.len)
			var/obj/item/integrated_circuit/circuit = assembly_components[i]
			if(circuit.removable)
				HTML += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a> | "
				HTML += "<a href='?src=[REF(circuit)];rename=1;return=1'>\[Rename\]</a> | "
				HTML += "<a href='?src=[REF(circuit)];scan=1'>\[Scan with Debugger\]</a> | "
				HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];remove=1'>\[Remove\]</a> | "
				HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];up=1' style='text-decoration:none;'>&#8593;</a> "
				HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];down=1' style='text-decoration:none;'>&#8595;</a>  "
				HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];top=1' style='text-decoration:none;'>&#10514;</a> "
				HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];bottom=1' style='text-decoration:none;'>&#10515;</a>"
				HTML += "<br>"
			CHECK_TICK

	HTML += "</body></html>"
	user << browse(HTML, "window=assembly-[REF(src)];size=600x350;border=1;can_resize=1;can_close=1;can_minimize=1")

/obj/item/device/electronic_assembly/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["rename"])
		rename(usr)

	if(href_list["remove_cell"])
		if(!battery)
			to_chat(usr, "<span class='warning'>There's no power cell to remove from \the [src].</span>")
		else
			battery.forceMove(drop_location())
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>You pull \the [battery] out of \the [src]'s power supplier.</span>")
			battery = null

	if(href_list["component"])
		var/obj/item/integrated_circuit/component = locate(href_list["component"]) in assembly_components
		if(component)
			// Builtin components are not supposed to be removed or rearranged
			if(!component.removable)
				return

			var/current_pos = assembly_components.Find(component)

			// Find the position of a first removable component
			var/first_removable_pos
			for(var/i in 1 to assembly_components.len)
				var/obj/item/integrated_circuit/temp_component = assembly_components[i]
				if(temp_component.removable)
					first_removable_pos = i
					break

			if(href_list["remove"])
				try_remove_component(component, usr)

			else
				// Adjust the position
				if(href_list["up"])
					current_pos--
				else if(href_list["down"])
					current_pos++
				else if(href_list["top"])
					current_pos = first_removable_pos
				else if(href_list["bottom"])
					current_pos = assembly_components.len

				// Wrap around nicely
				if(current_pos < first_removable_pos)
					current_pos = assembly_components.len
				else if(current_pos > assembly_components.len)
					current_pos = first_removable_pos

				assembly_components.Remove(component)
				assembly_components.Insert(current_pos, component)

	interact(usr) // To refresh the UI.

/obj/item/device/electronic_assembly/proc/rename()
	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(input("What do you want to name this?", "Rename", src.name) as null|text, TRUE)
	if(!check_interactivity(M))
		return
	if(src && input)
		to_chat(M, "<span class='notice'>The machine now has a label reading '[input]'.</span>")
		name = input

/obj/item/device/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/device/electronic_assembly/update_icon()
	if(opened)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)

/obj/item/device/electronic_assembly/examine(mob/user)
	..()
	if(assembly_components && assembly_components.len)
		for(var/i in 1 to assembly_components.len)
			var/obj/item/integrated_circuit/IC = assembly_components[i]
			IC.external_examine(user)
			CHECK_TICK
	if(opened)
		interact(user)

/obj/item/device/electronic_assembly/proc/return_total_complexity()
	. = 0
	if(assembly_components && assembly_components.len)
		var/obj/item/integrated_circuit/part
		for(var/i in 1 to assembly_components.len)
			part = = assembly_components[i]
			. += part.complexity
			CHECK_TICK

/obj/item/device/electronic_assembly/proc/return_total_size()
	. = 0
	if(assembly_components && assembly_components.len)
		var/obj/item/integrated_circuit/part
		for(var/i in 1 to assembly_components.len)
			part = = assembly_components[i]
			. += part.size
			CHECK_TICK

// Returns true if the circuit made it inside.
/obj/item/device/electronic_assembly/proc/try_add_component(obj/item/integrated_circuit/IC, mob/user)
	if(!opened)
		to_chat(user, "<span class='warning'>\The [src]'s hatch is closed, you can't put anything inside.</span>")
		return FALSE

	if(IC.w_class > w_class)
		to_chat(user, "<span class='warning'>\The [IC] is way too big to fit into \the [src].</span>")
		return FALSE

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()

	if((total_part_size + IC.size) > max_components)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', as there's insufficient space.</span>")
		return FALSE
	if((total_complexity + IC.complexity) > max_complexity)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since this setup's too complicated for the case.</span>")
		return FALSE

	if(!user.transferItemToLoc(IC, src))
		return FALSE

	to_chat(user, "<span class='notice'>You slide [IC] inside [src].</span>")
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)

	add_component(IC)
	return TRUE


// Actually puts the circuit inside, doesn't perform any checks.
/obj/item/device/electronic_assembly/proc/add_component(obj/item/integrated_circuit/component)
	component.forceMove(get_object())
	component.assembly = src
	assembly_components |= component


/obj/item/device/electronic_assembly/proc/try_remove_component(obj/item/integrated_circuit/IC, mob/user)
	if(!opened)
		to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
		return FALSE

	if(!IC.removable)
		to_chat(user, "<span class='warning'>[src] is permanently attached to the case.</span>")
		return FALSE

	to_chat(user, "<span class='notice'>You pop \the [src] out of the case, and slide it out.</span>")
	playsound(src, 'sound/items/Crowbar.ogg', 50, 1)

	remove_component(IC)
	return TRUE

// Actually removes the component, doesn't perform any checks.
/obj/item/device/electronic_assembly/proc/remove_component(obj/item/integrated_circuit/component)
	component.disconnect_all()
	component.forceMove(drop_location())
	component.assembly = null
	assembly_components.Remove(component)


/obj/item/device/electronic_assembly/afterattack(atom/target, mob/user, proximity)
	if(assembly_components && assembly_components.len)
		var/obj/item/integrated_circuit/part
		for(var/i in 1 to assembly_components.len)
			part = assembly_components[i]
			if(istype(part, /obj/item/integrated_circuit/input))
				var/obj/item/integrated_circuit/input/S = part
				if(S.sense(target,user,proximity))
					visible_message("<span class='notice'> [user] waves [src] around [target].</span>")
			CHECK_TICK


/obj/item/device/electronic_assembly/screwdriver_act(mob/living/user, obj/item/S)
	playsound(src, S.usesound, 50, 1)
	opened = !opened
	to_chat(user, "<span class='notice'>You [opened ? "open" : "close"] the maintenance hatch of [src].</span>")
	update_icon()
	return TRUE

/obj/item/device/electronic_assembly/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/integrated_circuit))
		if(!user.canUnEquip(I))
			return FALSE
		if(try_add_component(I, user))
			interact(user)
			return TRUE
	else if(istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/integrated_electronics/wirer) || istype(I, /obj/item/device/integrated_electronics/debugger))
		if(opened)
			interact(user)
		else
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
	else if(istype(I, /obj/item/stock_parts/cell))
		if(!opened)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't put anything inside.</span>")
			return FALSE
		if(battery)
			to_chat(user, "<span class='warning'>[src] already has \a [battery] installed. Remove it first if you want to replace it.</span>")
			return FALSE
		var/obj/item/stock_parts/cell = I
		user.transferItemToLoc(I, loc)
		cell.forceMove(src)
		battery = cell
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You slot \the [cell] inside \the [src]'s power supplier.</span>")
		interact(user)
		return TRUE
	else
		if(assembly_components && assembly_components.len)
			var/obj/item/integrated_circuit/part
			for(var/i in 1 to assembly_components.len)
				part = assembly_components[i]
				if(istype(part, /obj/item/integrated_circuit/input))
					var/obj/item/integrated_circuit/input/S = part
					S.attackby_react(I,user,user.a_intent)
				CHECK_TICK
		return ..()


/obj/item/device/electronic_assembly/attack_self(mob/user)
	if(!check_interactivity(user))
		return
	if(opened)
		interact(user)

	var/list/input_selection = list()
	var/list/available_inputs = list()
	for(var/obj/item/integrated_circuit/input/input in assembly_components)
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

/obj/item/device/electronic_assembly/emp_act(severity)
	..()
	for(var/i in 1 to contents.len)
		var/atom/movable/AM = contents[i]
		AM.emp_act(severity)

// Returns true if power was successfully drawn.
/obj/item/device/electronic_assembly/proc/draw_power(amount)
	if(battery && battery.use(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
/obj/item/device/electronic_assembly/proc/give_power(amount)
	if(battery && battery.give(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

/obj/item/device/electronic_assembly/Moved(oldLoc, dir)
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.ext_moved(oldLoc, dir)

/obj/item/device/electronic_assembly/stop_pulling()
	..()
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.stop_pulling()


// Returns the object that is supposed to be used in attack messages, location checks, etc.
// Override in children for special behavior.
/obj/item/device/electronic_assembly/proc/get_object()
	return src

// Returns the location to be used for dropping items.
// Same as the regular drop_location(), but with checks being run on acting_object if necessary.
/obj/item/integrated_circuit/drop_location()
	var/atom/movable/acting_object = get_object()

	// plz no infinite loops
	if(acting_object == src)
		return ..()

	return acting_object.drop_location()

/obj/item/device/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/device/electronic_assembly/calc
	name = "type-b electronic assembly"
	icon_state = "setup_small_calc"
	desc = "It's a case, for building small electronics with. This one resembles a pocket calculator."

/obj/item/device/electronic_assembly/clam
	name = "type-c electronic assembly"
	icon_state = "setup_small_clam"
	desc = "It's a case, for building small electronics with. This one has a clamshell design."

/obj/item/device/electronic_assembly/simple
	name = "type-d electronic assembly"
	icon_state = "setup_small_simple"
	desc = "It's a case, for building small electronics with. This one has a simple design."

/obj/item/device/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = WEIGHT_CLASS_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

/obj/item/device/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/device/electronic_assembly/medium/box
	name = "type-b electronic mechanism"
	icon_state = "setup_medium_box"
	desc = "It's a case, for building medium-sized electronics with. This one has a boxy design."

/obj/item/device/electronic_assembly/medium/clam
	name = "type-c electronic mechanism"
	icon_state = "setup_medium_clam"
	desc = "It's a case, for building medium-sized electronics with. This one has a clamshell design."

/obj/item/device/electronic_assembly/medium/medical
	name = "type-d electronic mechanism"
	icon_state = "setup_medium_med"
	desc = "It's a case, for building medium-sized electronics with. This one resembles some type of medical apparatus."

/obj/item/device/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4
	anchored = FALSE

/obj/item/device/electronic_assembly/large/attackby(obj/item/O, mob/user)
	if(default_unfasten_wrench(user, O, 20))
		return
	..()

/obj/item/device/electronic_assembly/large/attack_tk(mob/user)
	if(anchored)
		return
	..()

/obj/item/device/electronic_assembly/large/attack_hand(mob/user)
	if(anchored)
		attack_self(user)
		return
	..()

/obj/item/device/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/device/electronic_assembly/large/scope
	name = "type-b electronic machine"
	icon_state = "setup_large_scope"
	desc = "It's a case, for building large electronics with. This one resembles an oscilloscope."

/obj/item/device/electronic_assembly/large/terminal
	name = "type-c electronic machine"
	icon_state = "setup_large_terminal"
	desc = "It's a case, for building large electronics with. This one resembles a computer terminal."

/obj/item/device/electronic_assembly/large/arm
	name = "type-d electronic machine"
	icon_state = "setup_large_arm"
	desc = "It's a case, for building large electronics with. This one resembles a robotic arm."

/obj/item/device/electronic_assembly/drone
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case, for building mobile electronics with."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_MAX_SIZE_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3

/obj/item/device/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/device/electronic_assembly/drone/default
	name = "type-a electronic drone"

/obj/item/device/electronic_assembly/drone/arms
	name = "type-b electronic drone"
	icon_state = "setup_drone_arms"
	desc = "It's a case, for building mobile electronics with. This one is armed and dangerous."
