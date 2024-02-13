/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "filingcabinet"
	base_icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	///Boolean on whether the cabinet has been populated yet, set on first touch as to include as many latejoins as possible.
	var/paperwork_populated = FALSE

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"
	base_icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/filingcabinet //not changing the path to avoid unnecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"
	base_icon_state = "tallcabinet"

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	for(var/obj/item/items_mapped_in in loc)
		if(items_mapped_in.w_class < WEIGHT_CLASS_NORMAL) //there probably shouldn't be anything placed ontop of filing cabinets in a map that isn't meant to go in them
			items_mapped_in.forceMove(src)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NO_DECONSTRUCTION))
		new /obj/item/stack/sheet/iron(loc, 2)
		for(var/obj/item/paperwork in contents)
			paperwork.forceMove(drop_location())
	qdel(src)

/obj/structure/filingcabinet/attack_hand(mob/living/user, list/modifiers)
	if(!paperwork_populated)
		populate()
	. = ..()
	ui_interact(user)

/obj/structure/filingcabinet/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 2 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/structure/filingcabinet/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.w_class >= WEIGHT_CLASS_NORMAL)
		balloon_alert(user, "doesn't fit!")
		return ..()
	if(!user.transferItemToLoc(attacking_item, src))
		return ..()
	icon_state = "[base_icon_state]-open"
	addtimer(VARSET_CALLBACK(src, icon_state, base_icon_state), 0.5 SECONDS)

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(!paperwork_populated)
		populate()
	if(anchored)
		return attack_self_tk(user)
	return ..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(!contents.len)
		balloon_alert(user, "nothing inside!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!prob(40 + contents.len * 5))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	var/obj/item/random_item = pick(contents)
	random_item.forceMove(loc)
	if(prob(25))
		step_rand(random_item)
	balloon_alert(user, "pulled [random_item]!")
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/filingcabinet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FilingCabinet")
		ui.open()

/obj/structure/filingcabinet/ui_data(mob/user)
	var/list/data = list()

	data["cabinet_name"] = "[name]"
	data["contents"] = list()
	data["contents_ref"] = list()
	for(var/obj/item/content in contents)
		data["contents"] += "[content]"
		data["contents_ref"] += "[REF(content)]"

	return data

/obj/structure/filingcabinet/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		// Take the object out
		if("remove_object")
			var/obj/item/content = locate(params["ref"]) in src
			if(istype(content) && in_range(src, usr))
				usr.put_in_hands(content)
				icon_state = "[base_icon_state]-open"
				addtimer(VARSET_CALLBACK(src, icon_state, base_icon_state), 0.5 SECONDS)
				return TRUE

///Base proc in populating filing cabinets, setting the paperwork populated var to TRUE.
/obj/structure/filingcabinet/proc/populate()
	paperwork_populated = TRUE

/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security/populate()
	if(paperwork_populated || !length(GLOB.manifest.general))
		return
	for(var/datum/record/crew/target as anything in GLOB.manifest.general)
		var/obj/item/paper/rapsheet = target.get_rapsheet()
		rapsheet.forceMove(src)
	return ..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical/populate()
	if(paperwork_populated || !length(GLOB.manifest.general))
		return
	for(var/datum/record/crew/record in GLOB.manifest.general)
		var/obj/item/paper/med_record_paper = new /obj/item/paper(src)
		var/med_record_text = "<CENTER><B>Medical Record</B></CENTER><BR>"
		med_record_text += "Name: [record.name] Rank: [record.rank]<BR>\nGender: [record.gender]<BR>\nAge: [record.age]<BR>"
		med_record_text += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [record.blood_type]<BR>\nDNA: [record.dna_string]<BR>\n<BR>\nPhysical Status: [record.physical_status]<BR>\nMental Status: [record.mental_status]<BR>\nMinor Disabilities: [record.minor_disabilities]<BR>\nDetails: [record.minor_disabilities_desc]<BR>\n<BR>\nMajor Disabilities: [record.major_disabilities]<BR>\nDetails: [record.major_disabilities_desc]<BR>\n<BR>\nImportant Notes:<BR>\n\t[record.medical_notes]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
		med_record_text += "</TT>"
		med_record_paper.add_raw_text(med_record_text)
		med_record_paper.name = "paper - '[record.name]'"
		med_record_paper.update_appearance()
	return ..()

/*
 * Employment contract Cabinets
 */
GLOBAL_LIST_EMPTY(employment_cabinets)

/obj/structure/filingcabinet/employment
	icon_state = "employmentcabinet"
	base_icon_state = "employmentcabinet"

/obj/structure/filingcabinet/employment/Initialize(mapload)
	. = ..()
	GLOB.employment_cabinets += src

/obj/structure/filingcabinet/employment/Destroy()
	GLOB.employment_cabinets -= src
	return ..()

///Fills the filing cabinet with the records of all currently-existing crewmembers.
/obj/structure/filingcabinet/employment/populate()
	if(paperwork_populated || !length(GLOB.manifest.locked))
		return
	for(var/datum/record/locked/target as anything in GLOB.manifest.locked)
		var/datum/mind/filed_mind = target.mind_ref.resolve()
		if(filed_mind)
			add_employee_file(filed_mind.current)

	return ..()

///Adds an individual employment contract to the filing cabinet.
/obj/structure/filingcabinet/employment/proc/add_employee_file(mob/living/employee)
	new /obj/item/paper/employment_contract(src, employee.mind.name)
