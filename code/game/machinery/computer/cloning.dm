#define MAIN_MENU 1
#define STORAGE_MENU 2

/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to operate cloning pods."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning
	var/menu = MAIN_MENU ///Which menu screen to display
	var/obj/item/disk/cloning/disk = null ///Cloning data disk
	var/list/pods = list() ///Linked cloning pods
	var/list/datum/dna/dna_bank = list() ///List of saved DNAs
	var/selected_dna = null ///Index of the currently selected DNA in dna_bank
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/Destroy()
	eject_disk()
	for(var/P in pods)
		unlink_pod(P)
	pods = null
	for(var/D in dna_bank)
		qdel(D)
	dna_bank = null
	return ..()

/obj/machinery/computer/cloning/proc/link_pod(obj/machinery/cloning_pod/pod)
	pod.linked_consoles |= src
	pods |= pod

/obj/machinery/computer/cloning/proc/unlink_pod(obj/machinery/cloning_pod/pod)
	pods -= pod
	pod.linked_consoles -= src

/obj/machinery/computer/cloning/proc/start_clone(datum/dna/dna_to_clone, pod_index)
	if(!(dna_to_clone.species.inherent_biotypes | (MOB_ORGANIC|MOB_MINERAL)))
		return
	var/obj/machinery/cloning_pod/cloner = pods[pod_index]
	if(QDELETED(cloner))
		return
	cloner.grow_clone(dna_to_clone)

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/cloning))
		if(!user.transferItemToLoc(W, src))
			return
		if(disk)
			eject_disk(user)
		disk = W
		to_chat(user, "<span class='notice'>You insert [W].</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/P = W

		if(istype(P.buffer, /obj/machinery/cloning_pod))
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
			var/obj/machinery/cloning_pod/pod = P.buffer
			link_pod(pod)
		else
			P.buffer = src
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(P.buffer)] [P.buffer.name] in buffer %-</font color>")
		return
	else
		return ..()

/obj/machinery/computer/cloning/proc/eject_disk(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

/obj/machinery/computer/cloning/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cloning", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()
	var/list/cloning_pods = list()
	var/list/dna_list = list()
	data["menu"] = menu
	data["has_disk"] = !isnull(disk)
	data["has_disk_dna"] = !isnull(disk) && disk.stored_dna
	if(data["has_disk_dna"])
		var/list/disk_dna = list()
		disk_dna["name"] = disk.stored_dna.real_name
		disk_dna["species"] = disk.stored_dna.species.name
		disk_dna["sequence"] = disk.stored_dna.uni_identity
		data["disk"] = disk_dna
	var/i = 1
	for(var/X in pods)
		var/obj/machinery/cloning_pod/CP = X
		var/area/pod_area = get_area(CP)
		var/list/cloning_pod = list()
		cloning_pod["area"] = pod_area.name
		cloning_pod["operational"] = CP.is_operational() && !CP.panel_open
		cloning_pod["cloning"] = CP.cloning
		if(cloning_pod["cloning"])
			cloning_pod["progress"] = round((CP.growth_progress / CP.growth_required) * 100)
			var/list/cloning_dna = list()
			cloning_dna["name"] = CP.growing_dna.real_name
			cloning_dna["species"] = CP.growing_dna.species.name
			cloning_dna["sequence"] = CP.growing_dna.uni_identity
			cloning_pod["cloning_dna"] = cloning_dna
		cloning_pod["index"] = i
		cloning_pods += list(cloning_pod)
		i++
	data["cloning_pods"] = cloning_pods

	i = 1
	for(var/X in dna_bank)
		var/datum/dna/dna_datum = X
		var/list/this_dna = list()
		this_dna["name"] = dna_datum.real_name
		this_dna["species"] = dna_datum.species.name
		this_dna["sequence"] = dna_datum.uni_identity
		this_dna["index"] = i
		dna_list += list(this_dna)
		i++
	data["dna_list"] = dna_list

	data["has_selected_dna"] = !isnull(selected_dna)
	if(data["has_selected_dna"])
		var/list/active_dna = list()
		active_dna["name"] = dna_bank[selected_dna].real_name
		active_dna["species"] = dna_bank[selected_dna].species.name
		active_dna["sequence"] = dna_bank[selected_dna].uni_identity
		active_dna["index"] = selected_dna
		data["selected_dna"] = active_dna
	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject_disk(usr)
			. = TRUE
		if("toggle_menu")
			if(menu == MAIN_MENU)
				menu = STORAGE_MENU
			else
				menu = MAIN_MENU
			. = TRUE
		if("select_dna")
			var/new_selection = text2num(params["select"])
			selected_dna = new_selection
			. = TRUE
		if("deselect_dna")
			selected_dna = null
			. = TRUE
		if("save_dna")
			if(!disk)
				return TRUE
			var/datum/dna/new_dna = new
			disk.stored_dna.copy_dna(new_dna)
			dna_bank += new_dna
			. = TRUE
		if("delete_dna")
			var/dna_index = text2num(params["index"])
			if(length(dna_bank) < dna_index)
				return TRUE
			var/dna_to_remove = dna_bank[dna_index]
			dna_bank -= dna_to_remove
			qdel(dna_to_remove)
			if(!isnull(selected_dna))
				if(selected_dna == dna_index)
					selected_dna = null
				else if(selected_dna > dna_index)
					selected_dna-- //readjust index
			. = TRUE
		if("clone_selected")
			var/pod_index = text2num(params["index"])
			if(length(pods) < pod_index)
				return TRUE
			start_clone(dna_bank[selected_dna], pod_index)
			. = TRUE
		if("clone_disk")
			var/pod_index = text2num(params["index"])
			if(length(pods) < pod_index)
				return TRUE
			if(!disk || !disk.stored_dna)
				return TRUE
			start_clone(disk.stored_dna, pod_index)
			. = TRUE
		if("cancel_clone")
			var/pod_index = text2num(params["index"])
			if(length(pods) < pod_index)
				return TRUE
			var/obj/machinery/cloning_pod/cloner = pods[pod_index]
			cloner.reset()
			cloner.update_icon()
			. = TRUE
		if("unlink_pod")
			var/pod_index = text2num(params["index"])
			if(length(pods) < pod_index)
				return TRUE
			unlink_pod(pods[pod_index])
			. = TRUE
	. = TRUE

/obj/item/disk/cloning
	name = "DNA cloning scan-disk"
	desc = "A disk with an inbuilt DNA scanner. It can be placed onto an organism to store its genetic sequence, and then used to clone said organism."
	icon_state = "clonedisk"
	var/datum/dna/stored_dna = null

/obj/item/disk/cloning/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return FALSE
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!C.has_dna())
			to_chat(user, "<span class='warning'>Subject does not have a valid DNA sequence to analyze.</span>")
			return FALSE
		if(HAS_TRAIT(C, TRAIT_BADDNA))
			to_chat(user, "<span class='warning'>Subject's DNA is too damaged to analyze.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>DNA scan successful.</span>")
		store_dna(C.dna)
		return FALSE

/obj/item/disk/cloning/proc/store_dna(datum/dna/dna)
	if(!stored_dna)
		stored_dna = new
	dna.copy_dna(stored_dna)

#undef MAIN_MENU
#undef STORAGE_MENU
