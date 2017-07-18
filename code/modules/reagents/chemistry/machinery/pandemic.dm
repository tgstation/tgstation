/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/weapon/circuitboard/computer/pandemic
	use_power = TRUE
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	var/wait
	var/obj/item/weapon/reagent_containers/beaker

/obj/machinery/computer/pandemic/Initialize()
	. = ..()
	update_icon()

/obj/machinery/computer/pandemic/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/computer/pandemic/proc/get_by_index(thing, index)
	if(!beaker || !beaker.reagents)
		return
	var/datum/reagent/blood/B = locate() in beaker.reagents.reagent_list
	if(B && B.data[thing])
		return B.data[thing][index]

/obj/machinery/computer/pandemic/proc/get_virus_id_by_index(index)
	var/datum/disease/D = get_by_index("viruses", index)
	if(D)
		return D.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/get_viruses_data(datum/reagent/blood/B)
	. = list()
	if(!islist(B.data["viruses"]))
		return
	var/list/V = B.data["viruses"]
	var/index = 1
	for(var/virus in V)
		var/datum/disease/D = virus
		if(!istype(D) || D.visibility_flags & HIDDEN_PANDEMIC)
			continue

		var/list/this = list()
		this["name"] = D.name
		if(istype(D, /datum/disease/advance))
			var/datum/disease/advance/A = SSdisease.archive_diseases[D.GetDiseaseID()]
			if(A.name == "Unknown")
				this["can_rename"] = TRUE
			this["name"] = A.name
			this["is_adv"] = TRUE
			this["resistance"] = A.totalResistance()
			this["stealth"] = A.totalStealth()
			this["stage_speed"] = A.totalStageSpeed()
			this["transmission"] = A.totalTransmittable()
			this["symptoms"] = list()
			for(var/symptom in A.symptoms)
				var/datum/symptom/S = symptom
				var/list/this_symptom = list()
				this_symptom["name"] = S.name
				this["symptoms"] += list(this_symptom)
		this["index"] = index++
		this["agent"] = D.agent
		this["description"] = D.desc || "none"
		this["spread"] = D.spread_text || "none"
		this["cure"] = D.cure_text || "none"

		. += list(this)

/obj/machinery/computer/pandemic/proc/get_resistance_data(datum/reagent/blood/B)
	. = list()
	if(!islist(B.data["resistances"]))
		return
	var/list/resistances = B.data["resistances"]
	for(var/id in resistances)
		var/list/this = list()
		var/datum/disease/D = SSdisease.archive_diseases[id]
		if(D)
			this["id"] = id
			this["name"] = D.name
		. += list(this)

/obj/machinery/computer/pandemic/proc/reset_replicator_cooldown()
	wait = FALSE
	update_icon()
	playsound(loc, 'sound/machines/ping.ogg', 30, 1)

/obj/machinery/computer/pandemic/update_icon()
	if(stat & BROKEN)
		icon_state = (beaker ? "mixer1_b" : "mixer0_b")
		return

	icon_state = "mixer[(beaker) ? "1" : "0"][powered() ? "" : "_nopower"]"
	if(wait)
		cut_overlays()
	else
		add_overlay("waitlight")

/obj/machinery/computer/pandemic/proc/eject_beaker()
	beaker.forceMove(get_turf(src))
	beaker = null
	update_icon()

/obj/machinery/computer/pandemic/ui_interact(mob/user, ui_key = "main", datum/tgui/ui, force_open = FALSE, datum/tgui/master_ui, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "pandemic", name, 700, 500, master_ui, state)
		ui.open()

/obj/machinery/computer/pandemic/ui_data(mob/user)
	var/list/data = list()
	data["is_ready"] = !wait
	if(beaker)
		data["has_beaker"] = TRUE
		if(!beaker.reagents.total_volume || !beaker.reagents.reagent_list)
			data["beaker_empty"] = TRUE
		var/datum/reagent/blood/B = locate() in beaker.reagents.reagent_list
		if(B)
			data["has_blood"] = TRUE
			data["blood"] = list()
			data["blood"]["dna"] = B.data["blood_DNA"] || "none"
			data["blood"]["type"] = B.data["blood_type"] || "none"
			data["viruses"] = get_viruses_data(B)
			data["resistances"] = get_resistance_data(B)

	return data

/obj/machinery/computer/pandemic/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject_beaker")
			eject_beaker()
			. = TRUE
		if("empty_beaker")
			beaker.reagents.clear_reagents()
			. = TRUE
		if("empty_eject_beaker")
			beaker.reagents.clear_reagents()
			eject_beaker()
			. = TRUE
		if("rename_disease")
			var/id = get_virus_id_by_index(text2num(params["index"]))
			var/datum/disease/advance/A = SSdisease.archive_diseases[id]
			if(A)
				var/new_name = stripped_input(usr, "Name the disease", "New name", "", MAX_NAME_LEN)
				if(!new_name || ..())
					return
				A.AssignName(new_name)
				for(var/datum/disease/advance/AD in SSdisease.active_diseases)
					AD.Refresh()
				. = TRUE
		if("create_culture_bottle")
			var/id = get_virus_id_by_index(text2num(params["index"]))
			var/datum/disease/advance/A = new(FALSE, SSdisease.archive_diseases[id])
			var/list/data = list("viruses" = list(A))
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new(get_turf(src))
			B.name = "[A.name] culture bottle"
			B.desc = "A small bottle. Contains [A.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood", 20, data)
			wait = TRUE
			update_icon()
			addtimer(CALLBACK(src, .proc/reset_replicator_cooldown), 50)
			. = TRUE
		if("create_vaccine_bottle")
			var/index = params["index"]
			var/datum/disease/D = SSdisease.archive_diseases[index]
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new(get_turf(src))
			B.name = "[D.name] vaccine bottle"
			B.reagents.add_reagent("vaccine", 15, list(index))
			wait = TRUE
			update_icon()
			addtimer(CALLBACK(src, .proc/reset_replicator_cooldown), 200)
			. = TRUE

/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers) && (I.container_type & OPENCONTAINER))
		. = TRUE //no afterattack
		if(stat & (NOPOWER|BROKEN))
			return
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine!</span>")
			return
		if(!user.drop_item())
			return

		beaker = I
		beaker.forceMove(src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine.</span>")
		update_icon()
	else
		return ..()

/obj/machinery/computer/pandemic/on_deconstruction()
	if(beaker)
		beaker.forceMove(get_turf(src))
		beaker = null
	. = ..()
