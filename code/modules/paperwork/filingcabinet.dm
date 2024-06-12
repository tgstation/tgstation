/* Filing cabinets!
 * Contains:
 * Filing Cabinets
 * Security Record Cabinets
 * Medical Record Cabinets
 * Employment Contract Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/filingcabinet //not changing the path to avoid unnecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc)
			if(I.w_class < WEIGHT_CLASS_NORMAL) //there probably shouldn't be anything placed ontop of filing cabinets in a map that isn't meant to go in them
				I.forceMove(src)

/obj/structure/filingcabinet/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc, 2)
	for(var/obj/item/obj in src)
		obj.forceMove(loc)

/obj/structure/filingcabinet/attackby(obj/item/P, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if(P.tool_behaviour == TOOL_WRENCH && LAZYACCESS(modifiers, RIGHT_CLICK))
		to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
		if(P.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
			set_anchored(!anchored)
	else if(P.w_class < WEIGHT_CLASS_NORMAL)
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, span_notice("You put [P] in [src]."))
		icon_state = "[initial(icon_state)]-open"
		sleep(0.5 SECONDS)
		icon_state = initial(icon_state)
	else if(!user.combat_mode)
		to_chat(user, span_warning("You can't put [P] in [src]!"))
	else
		return ..()

/obj/structure/filingcabinet/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	ui_interact(user)

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
	for(var/obj/item/content in src)
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
				icon_state = "[initial(icon_state)]-open"
				addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), 0.5 SECONDS)
				return TRUE

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		return attack_self_tk(user)
	return ..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	. = ITEM_INTERACT_BLOCKING
	if(contents.len)
		if(prob(40 + contents.len * 5))
			var/obj/item/I = pick(contents)
			I.forceMove(loc)
			if(prob(25))
				step_rand(I)
			to_chat(user, span_notice("You pull \a [I] out of [src] at random."))
			return
	to_chat(user, span_notice("You find nothing in [src]."))

/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/virgin = TRUE

/obj/structure/filingcabinet/security/proc/populate()
	if(!virgin)
		return
	for(var/datum/record/crew/target in GLOB.manifest.general)
		var/obj/item/paper/rapsheet = target.get_rapsheet()
		rapsheet.forceMove(src)
		virgin = FALSE //tabbing here is correct- it's possible for people to try and use it
					//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand(mob/user, list/modifiers)
	populate()
	return ..()

/obj/structure/filingcabinet/security/attack_tk()
	populate()
	return ..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	///This var is so that its filled on crew interaction to be as accurate (including latejoins) as possible, true until first interact
	var/virgin = TRUE

/obj/structure/filingcabinet/medical/proc/populate()
	if(!virgin)
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
		virgin = FALSE //tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/filingcabinet/medical/attack_hand(mob/user, list/modifiers)
	populate()
	return ..()

/obj/structure/filingcabinet/medical/attack_tk()
	populate()
	return ..()

/*
 * Employment contract Cabinets
 */

GLOBAL_LIST_EMPTY(employmentCabinets)

/obj/structure/filingcabinet/employment
	icon_state = "employmentcabinet"
	///This var is so that its filled on crew interaction to be as accurate (including latejoins) as possible, true until first interact
	var/virgin = TRUE

/obj/structure/filingcabinet/employment/Initialize(mapload)
	. = ..()
	GLOB.employmentCabinets += src

/obj/structure/filingcabinet/employment/Destroy()
	GLOB.employmentCabinets -= src
	return ..()

/obj/structure/filingcabinet/employment/proc/fillCurrent()
	//This proc fills the cabinet with the current crew.
	for(var/datum/record/locked/target in GLOB.manifest.locked)
		var/datum/mind/filed_mind = target.mind_ref.resolve()
		if(filed_mind && ishuman(filed_mind.current))
			addFile(filed_mind.current)

/obj/structure/filingcabinet/employment/proc/addFile(mob/living/carbon/human/employee)
	new /obj/item/paper/employment_contract(src, employee.mind.name)

/obj/structure/filingcabinet/employment/interact(mob/user)
	if(virgin)
		fillCurrent()
		virgin = FALSE
	return ..()
