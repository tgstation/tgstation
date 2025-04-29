
/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = TRUE
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "pandemic0"
	icon_keyboard = null
	icon_screen = null
	base_icon_state = "pandemic"
	resistance_flags = ACID_PROOF
	circuit = /obj/item/circuitboard/computer/pandemic

	/// Whether the pandemic is ready to make another culture/vaccine
	var/wait = FALSE
	///The currently selected symptom
	var/datum/symptom/selected_symptom
	///The inserted beaker
	var/obj/item/reagent_containers/beaker

/obj/machinery/computer/pandemic/Initialize(mapload)
	. = ..()
	update_appearance()


	var/static/list/hovering_item_typechecks = list(
		/obj/item/reagent_containers/dropper = list(
			SCREENTIP_CONTEXT_LMB = "Use dropper",
		),

		/obj/item/reagent_containers/syringe = list(
			SCREENTIP_CONTEXT_LMB = "Inject sample",
			SCREENTIP_CONTEXT_RMB = "Draw sample"
		),
	)

	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		lmb_text = "Open interface", \
		rmb_text = "Remove beaker", \
	)


/obj/machinery/computer/pandemic/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/computer/pandemic/examine(mob/user)
	. = ..()
	if(beaker)
		var/is_close
		if(Adjacent(user)) //don't reveal exactly what's inside unless they're close enough to see the UI anyway.
			. += "It contains \a [beaker]."
			is_close = TRUE
		else
			. += "It has a beaker inside it."
		. += span_info("Alt-click to eject [is_close ? beaker : "the beaker"].")

/obj/machinery/computer/pandemic/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return
	eject_beaker()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/computer/pandemic/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/computer/pandemic/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/computer/pandemic/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
		update_appearance()
		SStgui.update_uis(src)

/obj/machinery/computer/pandemic/attackby(obj/item/held_item, mob/user, list/modifiers)
	//Advanced science! Precision instruments (eg droppers and syringes) are precise enough to modify the loaded sample!
	if(istype(held_item, /obj/item/reagent_containers/dropper) || istype(held_item, /obj/item/reagent_containers/syringe))
		if(!beaker)
			balloon_alert(user, "no beaker!")
			return ..()
		if(istype(held_item, /obj/item/reagent_containers/syringe) && LAZYACCESS(modifiers, RIGHT_CLICK))
			held_item.interact_with_atom_secondary(beaker, user)
		else
			held_item.interact_with_atom(beaker, user)
		SStgui.update_uis(src)
		return TRUE

	if(!is_reagent_container(held_item) || held_item.item_flags & ABSTRACT || !held_item.is_open_container())
		return ..()
	. = TRUE //no afterattack
	if(machine_stat & (NOPOWER|BROKEN))
		return ..()
	if(beaker)
		balloon_alert(user, "pandemic full!")
		return ..()
	if(!user.transferItemToLoc(held_item, src))
		return ..()
	beaker = held_item
	balloon_alert(user, "beaker loaded")
	update_appearance()
	SStgui.update_uis(src)

/obj/machinery/computer/pandemic/on_deconstruction(disassembled)
	eject_beaker()
	. = ..()

/obj/machinery/computer/pandemic/update_icon_state()
	icon_state = "[base_icon_state][beaker ? 1 : 0][(machine_stat & BROKEN) ? "_b" : (powered() ? null : "_nopower")]"
	return ..()

/obj/machinery/computer/pandemic/update_overlays()
	. = ..()
	if(wait)
		. += "waitlight"

/obj/machinery/computer/pandemic/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pandemic", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/pandemic/ui_data(mob/user)
	var/list/data = list()
	data["is_ready"] = !wait
	if(!beaker)
		data["has_beaker"] = FALSE
		data["has_blood"] = FALSE
		return data
	data["has_beaker"] = TRUE
	data["beaker"] = list(
		"volume" = round(beaker.reagents?.total_volume, 0.01) || 0,
		"capacity" = beaker.volume,
	)
	var/datum/reagent/blood/blood = locate() in beaker.reagents.reagent_list
	if(!blood)
		data["has_blood"] = FALSE
		return data
	data["has_blood"] = TRUE
	data["blood"] = list()
	data["blood"]["dna"] = blood.data["blood_DNA"] || "none"
	data["blood"]["type"] = blood.data["blood_type"] || "none"
	data["viruses"] = get_viruses_data(blood)
	data["resistances"] = get_resistance_data(blood)
	return data

/obj/machinery/computer/pandemic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject_beaker")
			eject_beaker()
			return TRUE
		if("empty_beaker")
			if(beaker)
				beaker.reagents.clear_reagents()
			return TRUE
		if("empty_eject_beaker")
			if(beaker)
				beaker.reagents.clear_reagents()
				eject_beaker()
			return TRUE
		if("rename_disease")
			rename_disease(params["index"], params["name"])
			return TRUE
		if("create_culture_bottle")
			if (wait)
				return FALSE
			create_culture_bottle(params["index"])
			return TRUE
		if("create_vaccine_bottle")
			if (wait)
				return FALSE
			create_vaccine_bottle(params["index"])
			return TRUE
	return FALSE


/**
 * Supporting proc to get the cures of a replicable virus. This may differ from the archived cures for that disease id.
 *
 * @param {number} disease_id - The id of the disease being replicated.
 *
 * @returns {list} - List of two elements - the cures list for the disease and the cure_text associated with it. Will be empty if anything fails.
 *
 */
/obj/machinery/computer/pandemic/proc/get_beaker_cures(disease_id)
	var/list/cures = list()
	if(!beaker)
		return cures

	var/datum/reagent/blood/blood = beaker.reagents.has_reagent(/datum/reagent/blood)
	if(!blood)
		return cures

	var/list/viruses = blood.get_diseases()
	if(!length(viruses))
		return cures

	// Only check for cure if there is a beaker AND the beaker contains blood AND the blood contains a virus.
	for(var/datum/disease/advance/disease in viruses)
		if(disease.GetDiseaseID() == disease_id)	// Double check the ids match.
			cures.Add(disease.cures)
			cures.Add(disease.cure_text)
			break

	return cures


/**
 * Creates a culture bottle (ie: replicates) of the the specified disease.
 *
 * @param {number} index - The index of the disease to replicate.
 *
 * @returns {boolean} - Success or failure.
 */
/obj/machinery/computer/pandemic/proc/create_culture_bottle(index)
	var/id = get_virus_id_by_index(text2num(index))
	var/datum/disease/advance/adv_disease = SSdisease.archive_diseases[id]


	if(!istype(adv_disease) || !adv_disease.mutable)
		to_chat(usr, span_warning("ERROR: Cannot replicate virus strain."))
		return FALSE
	use_energy(active_power_usage)
	adv_disease = adv_disease.Copy()
	var/list/cures = get_beaker_cures(id)
	if(cures.len)
		adv_disease.cures = cures[1]
		adv_disease.cure_text = cures[2]	// Same as generate_cure() in advance.dm
	var/list/data = list("viruses" = list(adv_disease))

	var/obj/item/reagent_containers/cup/tube/bottle = new(drop_location())
	bottle.name = "[adv_disease.name] culture tube"
	bottle.desc = "A small test tube containing [adv_disease.agent] culture in synthblood medium."
	bottle.reagents.add_reagent(/datum/reagent/blood, 20, data)
	wait = TRUE
	update_appearance()
	var/turf/source_turf = get_turf(src)
	log_virus("A culture tube was printed for the virus [adv_disease.admin_details()] at [loc_name(source_turf)] by [key_name(usr)]")
	addtimer(CALLBACK(src, PROC_REF(reset_replicator_cooldown)), 5 SECONDS)
	return TRUE

/**
 * Creates a vaccine bottle for the specified disease.
 *
 * @param {number} index - The index of the disease to replicate.
 *
 * @returns {boolean} - Success or failure.
 */
/obj/machinery/computer/pandemic/proc/create_vaccine_bottle(index)
	use_energy(active_power_usage)
	var/id = index
	var/datum/disease/disease = SSdisease.archive_diseases[id]
	var/obj/item/reagent_containers/cup/tube/bottle = new(drop_location())
	bottle.name = "[disease.name] vaccine tube"
	bottle.reagents.add_reagent(/datum/reagent/vaccine, 15, list(id))
	wait = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(reset_replicator_cooldown)), 20 SECONDS)
	return TRUE

/**
 * Supporting proc to eject a beaker from the machine.
 *
 * Places it in hand if possible.
 *
 * @returns {boolean} - Success or failure.
 */
/obj/machinery/computer/pandemic/proc/eject_beaker()
	if(!beaker)
		return FALSE
	try_put_in_hand(beaker, usr)
	beaker = null
	update_appearance()
	return TRUE

/**
 * Displays a thing if it exists within the contents of a beaker.
 *
 * @param {any} thing - The key to look for.
 *
 * @param {any} index - Nested objects within the thing.
 *
 * @returns {any | boolean} The thing found or FALSE if unsuccessful.
 */
/obj/machinery/computer/pandemic/proc/get_by_index(thing, index)
	if(!beaker || !beaker.reagents)
		return FALSE
	var/datum/reagent/blood/blood = locate() in beaker.reagents.reagent_list
	if(blood?.data[thing])
		return blood.data[thing][index]
	return FALSE

/**
 * Gets resistances of a given blood sample as a list
 *
 * @param {reagent/blood} blood - The sample.
 *
 * @returns {list} - The resistances.
 */
/obj/machinery/computer/pandemic/proc/get_resistance_data(datum/reagent/blood/blood)
	var/list/data = list()
	if(!islist(blood.data["resistances"]))
		return data
	var/list/resistances = blood.data["resistances"]
	for(var/id in resistances)
		var/list/resistance = list()
		var/datum/disease/disease = SSdisease.archive_diseases[id]
		if(disease)
			resistance["id"] = id
			resistance["name"] = disease.name
		data += list(resistance)
	return data

/**
 * A very hefty proc that I am not proud to see.
 *
 * Given a blood sample, this proc will return a list of viruses that are present in the sample.
 *
 * Contains traits, symptoms, thresholds etc.
 *
 * @param {reagent/blood} blood - The sample to analyze.
 *
 * @returns {list} - A list of virus info present in the sample.
 */
/obj/machinery/computer/pandemic/proc/get_viruses_data(datum/reagent/blood/blood)
	var/list/data = list()
	var/list/viruses = blood.get_diseases()
	var/index = 1
	for(var/datum/disease/disease as anything in viruses)
		if(!istype(disease) || disease.visibility_flags & HIDDEN_PANDEMIC)
			continue
		var/list/traits = list()
		traits["agent"] = disease.agent
		traits["cure"] = disease.cure_text || "none"
		traits["description"] = disease.desc || "none"
		traits["index"] = index++
		traits["name"] = disease.name
		traits["spread"] = disease.spread_text || "none"
		if(istype(disease, /datum/disease/advance)) // Advanced diseases get more info
			var/datum/disease/advance/adv_disease = disease
			var/disease_name = SSdisease.get_disease_name(adv_disease.GetDiseaseID())
			traits["can_rename"] = ((disease_name == "Unknown") && adv_disease.mutable)
			traits["is_adv"] = TRUE
			traits["name"] = disease_name
			traits["resistance"] = adv_disease.totalResistance()
			traits["stage_speed"] = adv_disease.totalStageSpeed()
			traits["stealth"] = adv_disease.totalStealth()
			traits["symptoms"] = list()
			for(var/datum/symptom/symptom as anything in adv_disease.symptoms)
				var/list/this_symptom = list()
				this_symptom = symptom.get_symptom_data()
				traits["symptoms"] += list(this_symptom)
			traits["transmission"] = adv_disease.totalTransmittable()
		data += list(traits)
	return data

/**
 * Gets the ID of the virus by its index in the list of viruses.
 *
 * @param {number} index - The index of the virus in the list of viruses.
 *
 * @returns {string | boolean} - The ID of the virus or FALSE if unable
 * to find the virus.
 */
/obj/machinery/computer/pandemic/proc/get_virus_id_by_index(index)
	var/datum/disease/disease = get_by_index("viruses", index)
	if(!disease)
		return FALSE
	return disease.GetDiseaseID()

/**
 * Renames an advanced disease after running it through sanitize_name().
 *
 * @param {string} id - The ID of the disease to rename.
 *
 * @param {string} name - The new name of the disease.
 *
 * @returns {boolean} - Success or failure.
 */
/obj/machinery/computer/pandemic/proc/rename_disease(index, name)
	var/id = get_virus_id_by_index(text2num(index))
	var/datum/disease/advance/adv_disease = SSdisease.archive_diseases[id]
	if(!adv_disease.mutable)
		return FALSE
	if(adv_disease)
		var/new_name = sanitize_name(name, allow_numbers = TRUE, cap_after_symbols = FALSE)
		if(!new_name)
			return FALSE
		adv_disease.AssignName(new_name)
		return TRUE
	return FALSE

/**
 * Allows a user to create another vaccine/culture bottle again.
 *
 * @returns {boolean} - Success or failure.
 */
/obj/machinery/computer/pandemic/proc/reset_replicator_cooldown()
	wait = FALSE
	SStgui.update_uis(src)
	update_appearance()
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	return TRUE
