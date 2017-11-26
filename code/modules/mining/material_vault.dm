/*
TODO:
Wires to cycle/turn off target storages on ORM/Control
Power usage/ off effects
Buildable ? 
Colorize material names
*/
GLOBAL_VAR_INIT(material_data,initialize_material_data())

/proc/initialize_material_data()
	var/material_data = list()
	for(var/mat_type in subtypesof(/datum/material))
		var/datum/material/MT = mat_type
		if(!initial(MT.sheet_type)) //Would need some more complicated integration if you want it to use biomass
			continue
		var/mat = list()
		mat["material_id"] = initial(MT.id)
		mat["material_name"] = initial(MT.name)
		material_data += list(mat)
	return material_data

/obj/machinery/material_storage
	icon = 'icons/obj/objects.dmi'
	icon_state ="mineral"
	name = "material network node"
	desc = "Storage using bluespace technology to transport materials"
	anchored = TRUE
	var/id = 1
	var/map_id	//for designating vaults during maptime
	var/static/gid = 1
	var/department = "Generic"
	var/list/requested_materials = list()

/obj/machinery/material_storage/vault
	map_id = "vault"

/obj/machinery/material_storage/engineering
	department = "Engineering"

/obj/machinery/material_storage/science
	department = "Science"

/obj/machinery/material_storage/security
	department = "Security"

/obj/machinery/material_storage/medbay
	department = "Medbay"

/obj/machinery/material_storage/Initialize(mapload)
	. = ..()
	id = gid++
	var/datum/component/material_container/M = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE),INFINITY)
	M.precise_insertion = TRUE

/obj/machinery/material_storage/proc/transfer_to(obj/machinery/material_storage/target,amount,material_id)
	if(!target || !material_id || isnull(amount) || amount <= 0)
		return

	GET_COMPONENT(our_materials, /datum/component/material_container)
	GET_COMPONENT_FROM(target_materials, /datum/component/material_container,target)

	our_materials.transfer_to(amount*MINERAL_MATERIAL_AMOUNT,material_id,target_materials)


/obj/machinery/material_storage/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "material_storage", name, 400, 600, master_ui, state)
		ui.open()

/obj/machinery/material_storage/ui_data()
	. = control_data()
	.["materials"] = GLOB.material_data

/obj/machinery/material_storage/ui_act(act, params)
	if(..())
		return
	GET_COMPONENT(materials, /datum/component/material_container)
	switch(act)
		if("release")
			if(allowed(usr)) //Dunno if they should actually have any req_accesses
				var/mat_id = params["material_id"]
				if(!materials.materials[mat_id])
					return
				var/datum/material/mat = materials.materials[mat_id]
				var/stored_amount = mat.amount / MINERAL_MATERIAL_AMOUNT

				if(!stored_amount)
					return

				var/desired = 0
				if (params["sheets"])
					desired = text2num(params["sheets"])
				else
					desired = input("How many sheets?", "How many sheets would you like to eject?", 1) as null|num

				var/sheets_to_remove = round(min(desired,50,stored_amount))
				materials.retrieve_sheets(sheets_to_remove, mat_id, drop_location())
			else
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
			return TRUE
		if("request")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
				return
			var/mat_id = params["id"]
			if(!materials.materials[mat_id])
				return
			if(!(mat_id in requested_materials))
				requested_materials |= mat_id
			else
				requested_materials -= mat_id
			return TRUE

/obj/machinery/material_storage/proc/control_data()
	. = list()
	.["storage_name"] = department
	.["storage_id"] = id
	var/mat_list = list()
	GET_COMPONENT(materials, /datum/component/material_container)
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		var/mineral_amount = M.amount / MINERAL_MATERIAL_AMOUNT
		mat_list[mat_id] = mineral_amount
	.["storage_amount"] = mat_list
	.["requested_materials"] = requested_materials


/obj/machinery/computer/material_control
	name = "material network controller"
	desc = "Console used to distributed materials"
	var/vault_map_id = "vault" //will set the storage with this id as the vault
	var/obj/machinery/material_storage/vault

/obj/machinery/computer/material_control/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/material_control/LateInitialize()
	if(vault_map_id)
		for(var/obj/machinery/material_storage/V in GLOB.machines)
			if(V.map_id == vault_map_id)
				vault = V
				break

/obj/machinery/computer/material_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "material_control", "Material Network Controller", 900, 400, master_ui, state)
		ui.open()

/obj/machinery/computer/material_control/Initialize(mapload)
	. = ..()

/obj/machinery/computer/material_control/ui_data()
	. = list()
	.["storages"] = list()
	if(vault)
		.["vault"] = vault.control_data()
	for(var/obj/machinery/material_storage/M in GLOB.machines)
		if(M != vault && M.z == z)
			.["storages"] += list(M.control_data())
	.["materials"] = GLOB.material_data

/obj/machinery/computer/material_control/proc/get_material_storage(id)
	for(var/obj/machinery/material_storage/M in GLOB.machines)
		if(M.id == id)
			return M

/obj/machinery/computer/material_control/ui_act(act,params)
	if(..())
		return

	var/mob/user = usr
	
	switch(act)
		if("send")
			if(!vault)
				return
			var/material_id = params["material_id"]
			var/target_id = text2num(params["storage_id"])
			transfer_helper(vault.id,target_id,user,material_id)
			return TRUE
		if("take")
			if(!vault)
				return
			var/material_id = params["material_id"]
			var/storage_id = text2num(params["storage_id"])
			transfer_helper(storage_id,vault.id,user,material_id)
			return TRUE
		if("setvault")
			if(vault)
				return
			var/obj/machinery/material_storage/target = get_material_storage(text2num(params["storage_id"]))
			if(!target)
				return
			vault = target
			return TRUE

/obj/machinery/computer/material_control/proc/transfer_helper(source_id,target_id,mob/user,material_id)
	if(!source_id || !target_id || !user || !material_id)
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Required access not found.</span>")
		return
	var/obj/machinery/material_storage/source = get_material_storage(source_id)
	var/obj/machinery/material_storage/target = get_material_storage(target_id)
	if(!source || !target)
		return
	if(source.stat || target.stat)
		to_chat(user,"<span class='warning>Target storage unresponsive.</span>")
		return
	var/requested_amount = input(user, "How much do you want to transfer?", "Transfer to [target.department]") as num|null
	if(isnull(requested_amount) || (requested_amount <= 0))
		return
	if(!user.canUseTopic(src,be_close=TRUE))
		return TRUE
	source.transfer_to(target,requested_amount,material_id)
	