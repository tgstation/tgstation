#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

/obj/item/electronic_assembly
	name = "electronic assembly"
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	desc = "It's a case, for building small electronics with."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small"
	item_flags = NOBLUDGEON
	materials = list()		// To be filled later
	datum_flags = DF_USE_TAG
	var/list/assembly_components = list()
	var/list/ckeys_allowed_to_scan = list() // Players who built the circuit can scan it as a ghost.
	var/max_components = IC_MAX_SIZE_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = TRUE
	var/obj/item/stock_parts/cell/battery // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/stock_parts/cell
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/can_fire_equipped = FALSE //Can it fire/throw weapons when the assembly is being held?
	var/charge_sections = 4
	var/charge_tick = FALSE
	var/charge_delay = 4
	var/use_cyborg_cell = TRUE
	var/ext_next_use = 0
	var/atom/collw
	var/obj/item/card/id/access_card
	var/allowed_circuit_action_flags = IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE //which circuit flags are allowed
	var/combat_circuits = 0 //number of combat cicuits in the assembly, used for diagnostic hud
	var/long_range_circuits = 0 //number of long range cicuits in the assembly, used for diagnostic hud
	var/prefered_hud_icon = "hudstat"		// Used by the AR circuit to change the hud icon.
	var/creator // circuit creator if any
	var/static/next_assembly_id = 0
	var/sealed = FALSE
	var/datum/weakref/idlock = null

	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD, DIAG_CIRCUIT_HUD) //diagnostic hud overlays
	max_integrity = 50
	pass_flags = 0
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	anchored = FALSE
	var/can_anchor = TRUE
	var/detail_color = COLOR_ASSEMBLY_BLACK

/obj/item/electronic_assembly/New()
	..()
	src.max_components = round(max_components)
	src.max_complexity = round(max_complexity)

/obj/item/electronic_assembly/GenerateTag()
    tag = "assembly_[next_assembly_id++]"

/obj/item/electronic_assembly/examine(mob/user)
	. = ..()
	if(can_anchor)
		to_chat(user, "<span class='notice'>The anchoring bolts [anchored ? "are" : "can be"] <b>wrenched</b> in place and the maintenance panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")
	else
		to_chat(user, "<span class='notice'>The maintenance panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")

	if((isobserver(user) && ckeys_allowed_to_scan[user.ckey]) || IsAdminGhost(user))
		to_chat(user, "You can <a href='?src=[REF(src)];ghostscan=1'>scan</a> this circuit.")

	for(var/obj/item/integrated_circuit/I in assembly_components)
		I.external_examine(user)
	if(opened)
		interact(user)

/obj/item/electronic_assembly/proc/check_interactivity(mob/user)
	if(!istype(user, /mob))
		return
	return user.canUseTopic(src, BE_CLOSE)

/obj/item/electronic_assembly/Bump(atom/AM)
	collw = AM
	.=..()
	if((istype(collw, /obj/machinery/door/airlock) ||  istype(collw, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = collw
		if(D.check_access(access_card))
			D.open()

/obj/item/electronic_assembly/Initialize()
	.=..()
	START_PROCESSING(SScircuit, src)
	materials[MAT_METAL] = round((max_complexity + max_components) / 4) * SScircuit.cost_multiplier

	//sets up diagnostic hud view
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_circuithealth()
	diag_hud_set_circuitcell()
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()

	access_card = new /obj/item/card/id(src)

/obj/item/electronic_assembly/Destroy()
	STOP_PROCESSING(SScircuit, src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	QDEL_NULL(access_card)
	return ..()

/obj/item/electronic_assembly/process()
	handle_idle_power()
	check_pulling()

	//updates diagnostic hud
	diag_hud_set_circuithealth()
	diag_hud_set_circuitcell()

/obj/item/electronic_assembly/proc/handle_idle_power()

	// First we generate power.
	for(var/obj/item/integrated_circuit/passive/power/P in assembly_components)
		P.make_energy()

	// Now spend it.
	for(var/obj/item/integrated_circuit/I in assembly_components)
		if(I.power_draw_idle)
			if(!draw_power(I.power_draw_idle))
				I.power_fail()

/obj/item/electronic_assembly/interact(mob/user, circuit)
	ui_interact(user, circuit)

/obj/item/electronic_assembly/ui_interact(mob/user, obj/item/integrated_circuit/circuit_pins)
	. = ..()
	if(!check_interactivity(user))
		return

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/datum/browser/popup = new(user, "scannernew", name, 800, 630) // Set up the popup browser window
	popup.add_stylesheet("scannernew", 'html/browser/assembly_ui.css')

	var/HTML = "<html><head><title>[name]</title></head>\
		<body><table><thead><tr> \
		<a href='?src=[REF(src)]'>Refresh</a>  |  <a href='?src=[REF(src)];rename=1'>Rename</a><br> \
		[total_part_size]/[max_components] ([round((total_part_size / max_components) * 100, 0.1)]%) space taken up in the assembly.<br> \
		[total_complexity]/[max_complexity] ([round((total_complexity / max_complexity) * 100, 0.1)]%) maximum complexity.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='?src=[REF(src)];remove_cell=1'>Remove</a>"
	else
		HTML += "<span class='danger'>No power cell detected!</span>"
	HTML += "</tr></thead>"


	//Getting the newest viewed circuit to compare with new circuit list
	if(!circuit_pins || !istype(circuit_pins,/obj/item/integrated_circuit) || !(circuit_pins in assembly_components))
		if(assembly_components.len > 0)
			circuit_pins = assembly_components[1]


	HTML += "<tr><td width=200px><div class=scrollleft>Components:<br><nobr>"

	var/builtin_components = ""
	var/removables = ""
	var/remove_num = 1

	for(var/obj/item/integrated_circuit/circuit in assembly_components)
		if(!circuit.removable)
			if(circuit == circuit_pins)
				builtin_components += "[circuit.displayed_name]<br>"
			else
				builtin_components += "<a href='?src=[REF(src)]'>[circuit.displayed_name]</a><br>"

		// Non-inbuilt circuits come after inbuilt circuits
		else
			removables += "<a href='?src=[REF(src)];component=[REF(circuit)];change_pos=1' style='text-decoration:none;'>[remove_num].</a> | "
			if(circuit == circuit_pins)
				removables += "[circuit.displayed_name]<br>"
			else
				removables += "<a href='?src=[REF(src)];component=[REF(circuit)]'>[circuit.displayed_name]</a><br>"
			remove_num++

	// Put removable circuits (if any) in separate categories from non-removable
	if(builtin_components)
		HTML += "<hr> Built in:<br> [builtin_components] <hr> Removable: <br>"

	HTML += removables

	HTML += "</nobr></div></td><td valign='top'><div class=scrollright>"


	//Getting the newest circuit's pin
	if(!circuit_pins || !istype(circuit_pins,/obj/item/integrated_circuit))
		if(assembly_components.len > 0)
			circuit_pins = assembly_components[1]

	if(circuit_pins)
		HTML += "<div valign='middle'>[circuit_pins.displayed_name]<br>"

		HTML += "<a href='?src=[REF(src)];component=[REF(circuit_pins)]'>Refresh</a> | \
		<a href='?src=[REF(src)];component=[REF(circuit_pins)];rename_component=1'>Rename</a> | \
		<a href='?src=[REF(src)];component=[REF(circuit_pins)];scan=1'>Copy Ref</a> | \
		<a href='?src=[REF(src)];component=[REF(circuit_pins)];interact=1'>Interact</a>"
		if(circuit_pins.removable)
			HTML += " | <a href='?src=[REF(src)];component=[REF(circuit_pins)];remove=1'>Remove</a>"
		HTML += "</div><br>"

		var/table_edge_width = "30%"
		var/table_middle_width = "40%"

		HTML += "<table border='1' style='undefined;table-layout: fixed; position: absolute; left: 210; right: 2;'><colgroup>\
			<col style='width: [table_edge_width]'>\
			<col style='width: [table_middle_width]'>\
			<col style='width: [table_edge_width]'>\
			</colgroup>"

		var/column_width = 3
		var/row_height = max(circuit_pins.inputs.len, circuit_pins.outputs.len, 1)

		for(var/i = 1 to row_height)
			HTML += "<tr>"
			for(var/j = 1 to column_width)
				var/datum/integrated_io/io = null
				var/words = ""
				var/height = 1
				switch(j)
					if(1)
						io = circuit_pins.get_pin_ref(IC_INPUT, i)
						if(io)
							words += "<b><a href='?src=[REF(circuit_pins)];act=wire;pin=[REF(io)]'>[io.display_pin_type()] [io.name]</a> \
							<a href='?src=[REF(circuit_pins)];act=data;pin=[REF(io)]'>[io.display_data(io.data)]</a></b><br>"
							if(io.linked.len)
								words += "<ul>"
								for(var/k in io.linked)
									var/datum/integrated_io/linked = k
									words += "<li><a href='?src=[REF(circuit_pins)];act=unwire;pin=[REF(io)];link=[REF(linked)]'>[linked]</a> \
									@ <a href='?src=[REF(linked.holder)]'>[linked.holder.displayed_name]</a></li>"
								words += "</ul>"

							if(circuit_pins.outputs.len > circuit_pins.inputs.len)
								height = 1
					if(2)
						if(i == 1)
							words += "[circuit_pins.displayed_name]<br>[circuit_pins.name != circuit_pins.displayed_name ? "([circuit_pins.name])":""]<hr>[circuit_pins.desc]"
							height = row_height
						else
							continue
					if(3)
						io = circuit_pins.get_pin_ref(IC_OUTPUT, i)
						if(io)
							words += "<b><a href='?src=[REF(circuit_pins)];act=wire;pin=[REF(io)]'>[io.display_pin_type()] [io.name]</a> \
							<a href='?src=[REF(circuit_pins)];act=data;pin=[REF(io)]'>[io.display_data(io.data)]</a></b><br>"
							if(io.linked.len)
								words += "<ul>"
								for(var/k in io.linked)
									var/datum/integrated_io/linked = k
									words += "<li><a href='?src=[REF(circuit_pins)];act=unwire;pin=[REF(io)];link=[REF(linked)]'>[linked]</a> \
									@ <a href='?src=[REF(linked.holder)]'>[linked.holder.displayed_name]</a></li>"
								words += "</ul>"

							if(circuit_pins.inputs.len > circuit_pins.outputs.len)
								height = 1
				HTML += "<td align='center' rowspan='[height]'>[words]</td>"
			HTML += "</tr>"

		for(var/activator in circuit_pins.activators)
			var/datum/integrated_io/io = activator
			var/words = ""

			words += "<b><a href='?src=[REF(circuit_pins)];act=wire;pin=[REF(io)]'>[io]</a> \
				<a href='?src=[REF(circuit_pins)];act=data;pin=[REF(io)]'>[io.data?"\<PULSE OUT\>":"\<PULSE IN\>"]</a></b><br>"
			if(io.linked.len)
				words += "<ul>"
				for(var/k in io.linked)
					var/datum/integrated_io/linked = k
					words += "<li><a href='?src=[REF(circuit_pins)];act=unwire;pin=[REF(io)];link=[REF(linked)]'>[linked]</a> \
					@ <a href='?src=[REF(linked.holder)]'>[linked.holder.displayed_name]</a></li>"
				words += "</ul>"

			HTML += "<tr><td colspan='3' align='center'>[words]</td></tr>"

		HTML += "<tr>\
			<br><font color='FFFFFF' class=lowtext>Complexity: [circuit_pins.complexity]\
			<br>Cooldown per use: [circuit_pins.cooldown_per_use/10] sec"
		if(circuit_pins.ext_cooldown)
			HTML += "<br>External manipulation cooldown: [circuit_pins.ext_cooldown/10] sec"
		if(circuit_pins.power_draw_idle)
			HTML += "<br>Power Draw: [circuit_pins.power_draw_idle] W (Idle)"
		if(circuit_pins.power_draw_per_use)
			HTML += "<br>Power Draw: [circuit_pins.power_draw_per_use] W (Active)" // Borgcode says that powercells' checked_use() takes joules as input.
		HTML += "<br>[circuit_pins.extended_desc]</font></tr></table></div>"


	HTML += "</div></td></tr></table></body></html>"

	popup.set_content(HTML)
	popup.open()

/obj/item/electronic_assembly/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["ghostscan"])
		if((isobserver(usr) && ckeys_allowed_to_scan[usr.ckey]) || IsAdminGhost(usr))
			if(assembly_components.len)
				var/saved = "On circuit printers with cloning enabled, you may use the code below to clone the circuit:<br><br><code>[SScircuit.save_electronic_assembly(src)]</code>"
				usr << browse(saved, "window=circuit_scan;size=500x600;border=1;can_resize=1;can_close=1;can_minimize=1")
			else
				to_chat(usr, "<span class='warning'>The circuit is empty!</span>")
		return

	if(!check_interactivity(usr))
		return

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
			diag_hud_set_circuitstat() //update diagnostic hud

	var/obj/item/integrated_circuit/component

	if(href_list["component"])
		component = locate(href_list["component"]) in assembly_components

		if(!component)
			return


		if(href_list["scan"])
			var/obj/held_item = usr.get_active_held_item()
			if(istype(held_item, /obj/item/integrated_electronics/debugger))
				var/obj/item/integrated_electronics/debugger/D = held_item
				if(D.accepting_refs)
					D.afterattack(component, usr, TRUE)
				else
					to_chat(usr, "<span class='warning'>The debugger's 'ref scanner' needs to be on.</span>")
			else
				to_chat(usr, "<span class='warning'>You need a debugger set to 'ref' mode to do that.</span>")

		// Builtin components are not supposed to be removed or rearranged
		if(!component.removable)
			return

		add_allowed_scanner(usr.ckey)

		// Find the position of a first removable component
		var/first_removable_pos = 0
		for(var/i in assembly_components)
			first_removable_pos++
			var/obj/item/integrated_circuit/temp_component = i
			if(temp_component.removable)
				break

		if(href_list["remove"])
			if(try_remove_component(component, usr))
				component = null

		if(href_list["rename_component"])
			component.rename_component(usr)
			if(component.assembly)
				component.assembly.add_allowed_scanner(usr.ckey)
		
		if(href_list["interact"])
			var/obj/item/I = usr.get_active_held_item()
			if(istype(I))
				I.melee_attack_chain(usr, component)
			else
				component.attack_hand(usr)

		// Adjust the position
		if(href_list["change_pos"])
			var/new_pos = max(input(usr,"Write the new number","New position") as num,1)

			if(new_pos > assembly_components.len)
				new_pos = assembly_components.len

			if(new_pos < first_removable_pos)
				new_pos = first_removable_pos

			assembly_components.Remove(component)
			assembly_components.Insert(new_pos, component)

	interact(usr, component) // To refresh the UI.

/obj/item/electronic_assembly/pickup(mob/living/user)
	. = ..()
	//update diagnostic hud when picked up, true is used to force the hud to be hidden
	diag_hud_set_circuithealth(TRUE)
	diag_hud_set_circuitcell(TRUE)
	diag_hud_set_circuitstat(TRUE)
	diag_hud_set_circuittracking(TRUE)

/obj/item/electronic_assembly/dropped(mob/user)
	. = ..()
	//update diagnostic hud when dropped
	diag_hud_set_circuithealth()
	diag_hud_set_circuitcell()
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()

/obj/item/electronic_assembly/proc/rename()
	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(input("What do you want to name this?", "Rename", src.name) as null|text, TRUE)
	if(!check_interactivity(M))
		return
	if(src && input)
		to_chat(M, "<span class='notice'>The machine now has a label reading '[input]'.</span>")
		name = input

/obj/item/electronic_assembly/proc/add_allowed_scanner(ckey)
	ckeys_allowed_to_scan[ckey] = TRUE

/obj/item/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/electronic_assembly/update_icon()
	if(opened)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)
	cut_overlays()
	if(detail_color == COLOR_ASSEMBLY_BLACK) //Black colored overlay looks almost but not exactly like the base sprite, so just cut the overlay and avoid it looking kinda off.
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/assemblies/electronic_setups.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	add_overlay(detail_overlay)

/obj/item/electronic_assembly/proc/return_total_complexity()
	var/returnvalue = 0
	for(var/obj/item/integrated_circuit/part in assembly_components)
		returnvalue += part.complexity
	return(returnvalue)

/obj/item/electronic_assembly/proc/return_total_size()
	var/returnvalue = 0
	for(var/obj/item/integrated_circuit/part in assembly_components)
		returnvalue += part.size
	return(returnvalue)

// Returns true if the circuit made it inside.
/obj/item/electronic_assembly/proc/try_add_component(obj/item/integrated_circuit/IC, mob/user)
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
	if((allowed_circuit_action_flags & IC.action_flags) != IC.action_flags)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since the case doesn't support the circuit type.</span>")
		return FALSE

	if(!user.transferItemToLoc(IC, src))
		return FALSE

	to_chat(user, "<span class='notice'>You slide [IC] inside [src].</span>")
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	add_allowed_scanner(user.ckey)
	investigate_log("had [IC]([IC.type]) inserted by [key_name(user)].", INVESTIGATE_CIRCUIT)

	add_component(IC)
	return TRUE


// Actually puts the circuit inside, doesn't perform any checks.
/obj/item/electronic_assembly/proc/add_component(obj/item/integrated_circuit/component)
	component.forceMove(get_object())
	component.assembly = src
	assembly_components |= component

	//increment numbers for diagnostic hud
	if(component.action_flags & IC_ACTION_COMBAT)
		combat_circuits += 1;
	if(component.action_flags & IC_ACTION_LONG_RANGE)
		long_range_circuits += 1;

	//diagnostic hud update
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()


/obj/item/electronic_assembly/proc/try_remove_component(obj/item/integrated_circuit/IC, mob/user, silent)
	if(!opened)
		if(!silent)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
		return FALSE

	if(!IC.removable)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is permanently attached to the case.</span>")
		return FALSE

	remove_component(IC)
	if(!silent)
		to_chat(user, "<span class='notice'>You pop \the [IC] out of the case, and slide it out.</span>")
		playsound(src, 'sound/items/crowbar.ogg', 50, 1)
		user.put_in_hands(IC)
	add_allowed_scanner(user.ckey)
	investigate_log("had [IC]([IC.type]) removed by [key_name(user)].", INVESTIGATE_CIRCUIT)

	return TRUE

// Actually removes the component, doesn't perform any checks.
/obj/item/electronic_assembly/proc/remove_component(obj/item/integrated_circuit/component)
	component.disconnect_all()
	component.forceMove(drop_location())
	component.assembly = null

	assembly_components -= component

	//decrement numbers for diagnostic hud
	if(component.action_flags & IC_ACTION_COMBAT)
		combat_circuits -= 1;
	if(component.action_flags & IC_ACTION_LONG_RANGE)
		long_range_circuits -= 1;

	//diagnostic hud update
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()


/obj/item/electronic_assembly/afterattack(atom/target, mob/user, proximity)
	. = ..()
	for(var/obj/item/integrated_circuit/input/S in assembly_components)
		if(S.sense(target,user,proximity))
			visible_message("<span class='notice'> [user] waves [src] around [target].</span>")


/obj/item/electronic_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(sealed)
		to_chat(user,"<span class='notice'>The assembly is sealed. Any attempt to force it open would break it.</span>")
		return FALSE
	if(..())
		return TRUE
	I.play_tool_sound(src)
	opened = !opened
	to_chat(user, "<span class='notice'>You [opened ? "open" : "close"] the maintenance hatch of [src].</span>")
	update_icon()
	return TRUE

/obj/item/electronic_assembly/welder_act(mob/living/user, obj/item/I)
	var/type_to_use

	if(!sealed)
		type_to_use = input("What would you like to do?","[src] type setting") as null|anything in list("repair", "seal")
	else
		type_to_use = input("What would you like to do?","[src] type setting") as null|anything in list("repair", "unseal")

	switch(type_to_use)
		if("repair")
			to_chat(world,"Integrity: [obj_integrity] / [max_integrity]")
			if(obj_integrity < max_integrity)
				obj_integrity = min(obj_integrity + 20,max_integrity)
				to_chat(world,"Integrity: [obj_integrity] / [max_integrity]")
				to_chat(user,"<span class='notice'>You fix the dents and scratches of the assembly.</span>")
				to_chat(world,user)
				return TRUE

			else
				to_chat(user,"<span class='notice'>The assembly is already in impeccable condition.</span>")
				return FALSE

		if("seal")
			if(!opened)
				sealed = TRUE
				if(I.use_tool(src, user, 50, volume=100, amount=3))
					to_chat(user,"<span class='notice'>You seal the assembly, making it impossible to be opened.</span>")
					return TRUE

			else
				to_chat(user,"<span class='notice'>You need to close the assembly first before sealing it indefinitely!</span>")
				return FALSE

		if("unseal")
			to_chat(user,"<span class='notice'>You start unsealing the assembly carefully...</span>")
			if(I.use_tool(src, user, 50, volume=250, amount=3))
				for(var/obj/item/integrated_circuit/IC in assembly_components)
					if(prob(50))
						IC.disconnect_all()

				to_chat(user,"<span class='notice'>You unsealed the assembly.</span>")
				sealed = FALSE
				return TRUE

/obj/item/electronic_assembly/attackby(obj/item/I, mob/living/user)
	if(can_anchor && default_unfasten_wrench(user, I, 20))
		return

	// ID-Lock part: check if we have an id-lock and only lock if we're not trying to get values from it, to prevent accidents
	if(istype(I, /obj/item/integrated_electronics/debugger))
		var/obj/item/integrated_electronics/debugger/debugger = I
		if(debugger.idlock)
			// check if unlocked to lock
			if(!idlock)
				idlock = debugger.idlock
				to_chat(user,"<span class='notice'>You lock \the [src].</span>")

			//if locked, unlock if ids match
			else
				if(idlock.resolve() == debugger.idlock.resolve())
					idlock = null
					to_chat(user,"<span class='notice'>You unlock \the [src].</span>")

				else
					to_chat(user,"<span class='notice'>The scanned ID doesn't match with \the [src]'s lock.</span>")

			debugger.idlock = null
			return

	if(istype(I, /obj/item/integrated_circuit))
		if(!user.canUnEquip(I))
			return FALSE
		if(try_add_component(I, user))
			return TRUE
		else
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()

	else if(I.tool_behaviour == TOOL_MULTITOOL || istype(I, /obj/item/integrated_electronics/wirer) || istype(I, /obj/item/integrated_electronics/debugger))
		if(opened)
			interact(user)
			return TRUE
		else
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()

	else if(istype(I, /obj/item/stock_parts/cell))
		if(!opened)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't access \the [src]'s power supplier.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()
		if(battery)
			to_chat(user, "<span class='warning'>[src] already has \a [battery] installed. Remove it first if you want to replace it.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()
		I.forceMove(src)
		battery = I
		diag_hud_set_circuitstat() //update diagnostic hud
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You slot the [I] inside \the [src]'s power supplier.</span>")
		return TRUE

	else if(istype(I, /obj/item/integrated_electronics/detailer))
		var/obj/item/integrated_electronics/detailer/D = I
		detail_color = D.detail_color
		update_icon()

	else
		if(user.a_intent != INTENT_HELP)
			return ..()
		var/list/input_selection = list()
		//Check all the components asking for an input
		for(var/obj/item/integrated_circuit/input in assembly_components)
			if((input.demands_object_input && opened) || (input.demands_object_input && input.can_input_object_when_closed))
				var/i = 0
				//Check if there is another component with the same name and append a number for identification
				for(var/s in input_selection)
					var/obj/item/integrated_circuit/s_circuit = input_selection[s] //The for-loop iterates the keys of the associative list.
					if(s_circuit.name == input.name && s_circuit.displayed_name == input.displayed_name && s_circuit != input)
						i++
				var/disp_name= "[input.displayed_name] \[[input]\]"
				if(i)
					disp_name += " ([i+1])"
				//Associative lists prevent me from needing another list and using a Find proc
				input_selection[disp_name] = input

		var/obj/item/integrated_circuit/choice
		if(input_selection)
			if(input_selection.len == 1)
				choice = input_selection[input_selection[1]]
			else
				var/selection = input(user, "Where do you want to insert that item?", "Interaction") as null|anything in input_selection
				if(!check_interactivity(user))
					return ..()
				if(selection)
					choice = input_selection[selection]
			if(choice)
				choice.additem(I, user)
		for(var/obj/item/integrated_circuit/input/S in assembly_components)
			S.attackby_react(I,user,user.a_intent)
		return ..()


/obj/item/electronic_assembly/attack_self(mob/user)
	if(!check_interactivity(user))
		return
	if(opened)
		interact(user)

	var/list/input_selection = list()
	//Check all the components asking for an input
	for(var/obj/item/integrated_circuit/input/input in assembly_components)
		if(input.can_be_asked_input)
			var/i = 0
			//Check if there is another component with the same name and append a number for identification
			for(var/s in input_selection)
				var/obj/item/integrated_circuit/s_circuit = input_selection[s] //The for-loop iterates the keys of an associative list.
				if(s_circuit.name == input.name && s_circuit.displayed_name == input.displayed_name && s_circuit != input)
					i++
			var/disp_name= "[input.displayed_name] \[[input]\]"
			if(i)
				disp_name += " ([i+1])"
			//Associative lists prevent me from needing another list and using a Find proc
			input_selection[disp_name] = input

	var/obj/item/integrated_circuit/input/choice


	if(input_selection)
		if(input_selection.len ==1)
			choice = input_selection[input_selection[1]]
		else
			var/selection = input(user, "What do you want to interact with?", "Interaction") as null|anything in input_selection
			if(!check_interactivity(user))
				return
			if(selection)
				choice = input_selection[selection]

	if(choice)
		choice.ask_for_input(user)

/obj/item/electronic_assembly/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/I in src)
		var/atom/movable/AM = I
		AM.emp_act(severity)

// Returns true if power was successfully drawn.
/obj/item/electronic_assembly/proc/draw_power(amount)
	if(battery && battery.use(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
/obj/item/electronic_assembly/proc/give_power(amount)
	if(battery && battery.give(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

/obj/item/electronic_assembly/Moved(oldLoc, dir)
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.ext_moved(oldLoc, dir)
	if(light) //Update lighting objects (From light circuits).
		update_light()

/obj/item/electronic_assembly/stop_pulling()
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.stop_pulling()
	..()


// Returns the object that is supposed to be used in attack messages, location checks, etc.
// Override in children for special behavior.
/obj/item/electronic_assembly/proc/get_object()
	return src

// Returns the location to be used for dropping items.
// Same as the regular drop_location(), but with checks being run on acting_object if necessary.
/obj/item/integrated_circuit/drop_location()
	var/atom/movable/acting_object = get_object()

	// plz no infinite loops
	if(acting_object == src)
		return ..()

	return acting_object.drop_location()

/obj/item/electronic_assembly/attack_tk(mob/user)
	if(anchored)
		return
	..()

/obj/item/electronic_assembly/attack_hand(mob/user)
	if(anchored)
		attack_self(user)
		return
	..()

/obj/item/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/electronic_assembly/calc
	name = "type-b electronic assembly"
	icon_state = "setup_small_calc"
	desc = "It's a case, for building small electronics with. This one resembles a pocket calculator."

/obj/item/electronic_assembly/clam
	name = "type-c electronic assembly"
	icon_state = "setup_small_clam"
	desc = "It's a case, for building small electronics with. This one has a clamshell design."

/obj/item/electronic_assembly/simple
	name = "type-d electronic assembly"
	icon_state = "setup_small_simple"
	desc = "It's a case, for building small electronics with. This one has a simple design."

/obj/item/electronic_assembly/hook
	name = "type-e electronic assembly"
	icon_state = "setup_small_hook"
	desc = "It's a case, for building small electronics with. This one looks like it has a belt clip, but it's purely decorative."

/obj/item/electronic_assembly/pda
	name = "type-f electronic assembly"
	icon_state = "setup_small_pda"
	desc = "It's a case, for building small electronics with. This one resembles a PDA."

/obj/item/electronic_assembly/small
	name = "electronic device"
	icon_state = "setup_device"
	desc = "It's a case, for building tiny-sized electronics with."
	w_class = WEIGHT_CLASS_TINY
	max_components = IC_MAX_SIZE_BASE / 2
	max_complexity = IC_COMPLEXITY_BASE / 2

/obj/item/electronic_assembly/small/default
	name = "type-a electronic device"

/obj/item/electronic_assembly/small/cylinder
	name = "type-b electronic device"
	icon_state = "setup_device_cylinder"
	desc = "It's a case, for building tiny-sized electronics with. This one has a cylindrical design."

/obj/item/electronic_assembly/small/scanner
	name = "type-c electronic device"
	icon_state = "setup_device_scanner"
	desc = "It's a case, for building tiny-sized electronics with. This one has a scanner-like design."

/obj/item/electronic_assembly/small/hook
	name = "type-d electronic device"
	icon_state = "setup_device_hook"
	desc = "It's a case, for building tiny-sized electronics with. This one looks like it has a belt clip, but it's purely decorative."

/obj/item/electronic_assembly/small/box
	name = "type-e electronic device"
	icon_state = "setup_device_box"
	desc = "It's a case, for building tiny-sized electronics with. This one has a boxy design."

/obj/item/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = WEIGHT_CLASS_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

/obj/item/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/electronic_assembly/medium/box
	name = "type-b electronic mechanism"
	icon_state = "setup_medium_box"
	desc = "It's a case, for building medium-sized electronics with. This one has a boxy design."

/obj/item/electronic_assembly/medium/clam
	name = "type-c electronic mechanism"
	icon_state = "setup_medium_clam"
	desc = "It's a case, for building medium-sized electronics with. This one has a clamshell design."

/obj/item/electronic_assembly/medium/medical
	name = "type-d electronic mechanism"
	icon_state = "setup_medium_med"
	desc = "It's a case, for building medium-sized electronics with. This one resembles some type of medical apparatus."

/obj/item/electronic_assembly/medium/gun
	name = "type-e electronic mechanism"
	icon_state = "setup_medium_gun"
	item_state = "circuitgun"
	desc = "It's a case, for building medium-sized electronics with. This one resembles a gun, or some type of tool, if you're feeling optimistic. It can fire guns and throw items while the user is holding it."
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	can_fire_equipped = TRUE

/obj/item/electronic_assembly/medium/radio
	name = "type-f electronic mechanism"
	icon_state = "setup_medium_radio"
	desc = "It's a case, for building medium-sized electronics with. This one resembles an old radio."

/obj/item/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4

/obj/item/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/electronic_assembly/large/scope
	name = "type-b electronic machine"
	icon_state = "setup_large_scope"
	desc = "It's a case, for building large electronics with. This one resembles an oscilloscope."

/obj/item/electronic_assembly/large/terminal
	name = "type-c electronic machine"
	icon_state = "setup_large_terminal"
	desc = "It's a case, for building large electronics with. This one resembles a computer terminal."

/obj/item/electronic_assembly/large/arm
	name = "type-d electronic machine"
	icon_state = "setup_large_arm"
	desc = "It's a case, for building large electronics with. This one resembles a robotic arm."

/obj/item/electronic_assembly/large/tall
	name = "type-e electronic machine"
	icon_state = "setup_large_tall"
	desc = "It's a case, for building large electronics with. This one has a tall design."

/obj/item/electronic_assembly/large/industrial
	name = "type-f electronic machine"
	icon_state = "setup_large_industrial"
	desc = "It's a case, for building large electronics with. This one resembles some kind of industrial machinery."

/obj/item/electronic_assembly/drone
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case, for building mobile electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3
	allowed_circuit_action_flags = IC_ACTION_MOVEMENT | IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE
	can_anchor = FALSE

/obj/item/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/electronic_assembly/drone/default
	name = "type-a electronic drone"

/obj/item/electronic_assembly/drone/arms
	name = "type-b electronic drone"
	icon_state = "setup_drone_arms"
	desc = "It's a case, for building mobile electronics with. This one is armed and dangerous."

/obj/item/electronic_assembly/drone/secbot
	name = "type-c electronic drone"
	icon_state = "setup_drone_secbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Securitron."

/obj/item/electronic_assembly/drone/medbot
	name = "type-d electronic drone"
	icon_state = "setup_drone_medbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Medibot."

/obj/item/electronic_assembly/drone/genbot
	name = "type-e electronic drone"
	icon_state = "setup_drone_genbot"
	desc = "It's a case, for building mobile electronics with. This one has a generic bot design."

/obj/item/electronic_assembly/drone/android
	name = "type-f electronic drone"
	icon_state = "setup_drone_android"
	desc = "It's a case, for building mobile electronics with. This one has a hominoid design."

/obj/item/electronic_assembly/wallmount
	name = "wall-mounted electronic assembly"
	icon_state = "setup_wallmount_medium"
	desc = "It's a case, for building medium-sized electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

/obj/item/electronic_assembly/wallmount/heavy
	name = "heavy wall-mounted electronic assembly"
	icon_state = "setup_wallmount_large"
	desc = "It's a case, for building large electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4

/obj/item/electronic_assembly/wallmount/light
	name = "light wall-mounted electronic assembly"
	icon_state = "setup_wallmount_small"
	desc = "It's a case, for building small electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_MAX_SIZE_BASE
	max_complexity = IC_COMPLEXITY_BASE

/obj/item/electronic_assembly/wallmount/tiny
	name = "tiny wall-mounted electronic assembly"
	icon_state = "setup_wallmount_tiny"
	desc = "It's a case, for building tiny electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_TINY
	max_components = IC_MAX_SIZE_BASE / 2
	max_complexity = IC_COMPLEXITY_BASE / 2

/obj/item/electronic_assembly/wallmount/proc/mount_assembly(turf/on_wall, mob/user) //Yeah, this is admittedly just an abridged and kitbashed version of the wallframe attach procs.
	if(get_dist(on_wall,user)>1)
		return
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinals))
		return
	var/turf/T = get_turf(user)
	if(!isfloorturf(T))
		to_chat(user, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return
	if(gotwallitem(T, ndir))
		to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
		return
	playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
	user.visible_message("[user.name] attaches [src] to the wall.",
		"<span class='notice'>You attach [src] to the wall.</span>",
		"<span class='italics'>You hear clicking.</span>")
	user.dropItemToGround(src)
	switch(ndir)
		if(NORTH)
			pixel_y = -31
		if(SOUTH)
			pixel_y = 31
		if(EAST)
			pixel_x = -31
		if(WEST)
			pixel_x = 31
