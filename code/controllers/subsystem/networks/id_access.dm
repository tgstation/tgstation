/**
 * Non-processing subsystem that holds various procs and data structures to manage ID cards, trims and access.
 */
SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	flags = SS_NO_FIRE

	/// Dictionary of access flags. Keys are accesses. Values are their associated bitflags.
	var/list/flags_by_access = list()
	/// Dictionary of access lists. Keys are access flag names. Values are lists of all accesses as part of that access.
	var/list/accesses_by_flag = list()
	/// Dictionary of access flag string representations. Keys are bitflags. Values are their associated names.
	var/list/access_flag_string_by_flag = list()
	/// Dictionary of trim singletons. Keys are paths. Values are their associated singletons.
	var/list/trim_singletons_by_path = list()
	/// Dictionary of wildcard compatibility flags. Keys are strings for the wildcards. Values are their associated flags.
	var/list/wildcard_flags_by_wildcard = list()
	/// Dictionary of accesses based on station region. Keys are region strings. Values are lists of accesses.
	var/list/accesses_by_region = list()
	/// Specially formatted list for sending access levels to tgui interfaces.
	var/list/all_region_access_tgui = list()
	/// Dictionary of access names. Keys are access levels. Values are their associated names.
	var/list/desc_by_access = list()
	/// List of accesses for the Heads of each sub-department alongside the regions they control and their job name.
	var/list/sub_department_managers_tgui = list()
	/// Helper list containing all trim paths that can be used as job templates. Intended to be used alongside logic for ACCESS_CHANGE_IDS. Grab templates from sub_department_managers_tgui for Head of Staff restrictions.
	var/list/station_job_templates = list()
	/// Helper list containing all trim paths that can be used as Centcom templates.
	var/list/centcom_job_templates = list()
	/// Helper list containing all PDA paths that can be painted by station machines. Intended to be used alongside logic for ACCESS_CHANGE_IDS. Grab templates from sub_department_managers_tgui for Head of Staff restrictions.
	var/list/station_pda_templates = list()
	/// Helper list containing all station regions.
	var/list/station_regions = list()

	/// The roundstart generated code for the spare ID safe. This is given to the Captain on shift start. If there's no Captain, it's given to the HoP. If there's no HoP
	var/spare_id_safe_code = ""

/datum/controller/subsystem/id_access/Initialize()
	// We use this because creating the trim singletons requires the config to be loaded.
	setup_access_flags()
	setup_region_lists()
	setup_trim_singletons()
	setup_wildcard_dict()
	setup_access_descriptions()
	setup_tgui_lists()

	spare_id_safe_code = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"

	return SS_INIT_SUCCESS

/**
 * Called by [/datum/controller/subsystem/ticker/proc/setup]
 *
 * This runs through every /datum/id_trim/job singleton and ensures that its access is setup according to
 * appropriate config entries.
 */
/datum/controller/subsystem/id_access/proc/refresh_job_trim_singletons()
	for(var/trim in typesof(/datum/id_trim/job))
		var/datum/id_trim/job/job_trim = trim_singletons_by_path[trim]

		if(QDELETED(job_trim))
			stack_trace("Trim \[[trim]\] missing from trim singleton list. Reinitialising this trim.")
			trim_singletons_by_path[trim] = new trim()
			continue

		job_trim.refresh_trim_access()

/// Build access flag lists.
/datum/controller/subsystem/id_access/proc/setup_access_flags()
	accesses_by_flag["[ACCESS_FLAG_COMMON]"] = COMMON_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_COMMON]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_COMMON)

	accesses_by_flag["[ACCESS_FLAG_COMMAND]"] = COMMAND_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_COMMAND]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_COMMAND)

	accesses_by_flag["[ACCESS_FLAG_PRV_COMMAND]"] = PRIVATE_COMMAND_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_PRV_COMMAND]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_PRV_COMMAND)

	accesses_by_flag["[ACCESS_FLAG_CAPTAIN]"] = CAPTAIN_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_CAPTAIN]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_CAPTAIN)

	accesses_by_flag["[ACCESS_FLAG_CENTCOM]"] = CENTCOM_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_CENTCOM]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_CENTCOM)

	accesses_by_flag["[ACCESS_FLAG_SYNDICATE]"] = SYNDICATE_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_SYNDICATE]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_SYNDICATE)

	accesses_by_flag["[ACCESS_FLAG_AWAY]"] = AWAY_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_AWAY]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_AWAY)

	accesses_by_flag["[ACCESS_FLAG_SPECIAL]"] = CULT_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_SPECIAL]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_SPECIAL)

	access_flag_string_by_flag["[ACCESS_FLAG_COMMON]"] = ACCESS_FLAG_COMMON_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_COMMAND]"] = ACCESS_FLAG_COMMAND_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_PRV_COMMAND]"] = ACCESS_FLAG_PRV_COMMAND_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_CAPTAIN]"] = ACCESS_FLAG_CAPTAIN_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_CENTCOM]"] = ACCESS_FLAG_CENTCOM_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_SYNDICATE]"] = ACCESS_FLAG_SYNDICATE_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_AWAY]"] = ACCESS_FLAG_AWAY_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_SPECIAL]"] = ACCESS_FLAG_SPECIAL_NAME

/// Populates the region lists with data about which accesses correspond to which regions.
/datum/controller/subsystem/id_access/proc/setup_region_lists()
	accesses_by_region[REGION_ALL_STATION] = REGION_ACCESS_ALL_STATION
	accesses_by_region[REGION_ALL_GLOBAL] = REGION_ACCESS_ALL_GLOBAL
	accesses_by_region[REGION_GENERAL] = REGION_ACCESS_GENERAL
	accesses_by_region[REGION_SECURITY] = REGION_ACCESS_SECURITY
	accesses_by_region[REGION_MEDBAY] = REGION_ACCESS_MEDBAY
	accesses_by_region[REGION_RESEARCH] = REGION_ACCESS_RESEARCH
	accesses_by_region[REGION_ENGINEERING] = REGION_ACCESS_ENGINEERING
	accesses_by_region[REGION_SUPPLY] = REGION_ACCESS_SUPPLY
	accesses_by_region[REGION_COMMAND] = REGION_ACCESS_COMMAND
	accesses_by_region[REGION_CENTCOM] = REGION_ACCESS_CENTCOM

	station_regions = REGION_AREA_STATION

/// Instantiate trim singletons and add them to a list.
/datum/controller/subsystem/id_access/proc/setup_trim_singletons()
	for(var/trim in typesof(/datum/id_trim))
		trim_singletons_by_path[trim] = new trim()

/// Creates various data structures that primarily get fed to tgui interfaces, although these lists are used in other places.
/datum/controller/subsystem/id_access/proc/setup_tgui_lists()
	for(var/region in accesses_by_region)
		var/list/region_access = accesses_by_region[region]

		var/parsed_accesses = list()

		for(var/access in region_access)
			var/access_desc = get_access_desc(access)
			if(!access_desc)
				continue

			parsed_accesses += list(list(
				"desc" = replacetext(access_desc, "&nbsp", " "),
				"ref" = access,
			))

		all_region_access_tgui[region] = list(list(
			"name" = region,
			"accesses" = parsed_accesses,
		))

	sub_department_managers_tgui = list(
		"[ACCESS_CAPTAIN]" = list(
			"regions" = list(REGION_COMMAND),
			"head" = JOB_CAPTAIN,
			"templates" = list(),
			"pdas" = list(),
		),
		"[ACCESS_HOP]" = list(
			"regions" = list(REGION_GENERAL),
			"head" = JOB_HEAD_OF_PERSONNEL,
			"templates" = list(),
			"pdas" = list(),
		),
		"[ACCESS_HOS]" = list(
			"regions" = list(REGION_SECURITY),
			"head" = JOB_HEAD_OF_SECURITY,
			"templates" = list(),
			"pdas" = list(),
		),
		"[ACCESS_CMO]" = list(
			"regions" = list(REGION_MEDBAY),
			"head" = JOB_CHIEF_MEDICAL_OFFICER,
			"templates" = list(),
			"pdas" = list(),
		),
		"[ACCESS_RD]" = list(
			"regions" = list(REGION_RESEARCH),
			"head" = JOB_RESEARCH_DIRECTOR,
			"templates" = list(),
			"pdas" = list(),
		),
		"[ACCESS_CE]" = list(
			"regions" = list(REGION_ENGINEERING),
			"head" = JOB_CHIEF_ENGINEER,
			"templates" = list(),
			"pdas" = list(),
		),
		"[ACCESS_QM]" = list(
			"regions" = list(REGION_SUPPLY),
			"head" = JOB_QUARTERMASTER,
			"templates" = list(),
			"pdas" = list(),
		),
	)

	var/list/station_job_trims = subtypesof(/datum/id_trim/job)
	for(var/trim_path in station_job_trims)
		var/datum/id_trim/job/trim = trim_singletons_by_path[trim_path]
		if(!length(trim.template_access))
			continue

		station_job_templates[trim_path] = trim.assignment
		for(var/access in trim.template_access)
			var/list/manager = sub_department_managers_tgui["[access]"]
			if(!manager)
				if(access != ACCESS_CHANGE_IDS)
					WARNING("Invalid template access access \[[access]\] registered with [trim_path]. Template added to global list anyway.")
				continue
			var/list/templates = manager["templates"]
			templates[trim_path] = trim.assignment

	var/list/centcom_job_trims = typesof(/datum/id_trim/centcom) - typesof(/datum/id_trim/centcom/corpse)
	for(var/trim_path in centcom_job_trims)
		var/datum/id_trim/trim = trim_singletons_by_path[trim_path]
		centcom_job_templates[trim_path] = trim.assignment

	var/list/all_pda_paths = typesof(/obj/item/modular_computer/pda)
	var/list/pda_regions = PDA_PAINTING_REGIONS
	for(var/pda_path in all_pda_paths)
		if(!(pda_path in pda_regions))
			continue

		var/list/region_whitelist = pda_regions[pda_path]
		for(var/access_txt in sub_department_managers_tgui)
			var/list/manager_info = sub_department_managers_tgui[access_txt]
			var/list/manager_regions = manager_info["regions"]
			for(var/whitelisted_region in region_whitelist)
				if(!(whitelisted_region in manager_regions))
					continue
				var/list/manager_pdas = manager_info["pdas"]
				var/obj/item/modular_computer/pda/fake_pda = pda_path
				manager_pdas[pda_path] = initial(fake_pda.name)
				station_pda_templates[pda_path] = initial(fake_pda.name)

/// Set up dictionary to convert wildcard names to flags.
/datum/controller/subsystem/id_access/proc/setup_wildcard_dict()
	wildcard_flags_by_wildcard[WILDCARD_NAME_ALL] = WILDCARD_FLAG_ALL
	wildcard_flags_by_wildcard[WILDCARD_NAME_COMMON] = WILDCARD_FLAG_COMMON
	wildcard_flags_by_wildcard[WILDCARD_NAME_COMMAND] = WILDCARD_FLAG_COMMAND
	wildcard_flags_by_wildcard[WILDCARD_NAME_PRV_COMMAND] = WILDCARD_FLAG_PRV_COMMAND
	wildcard_flags_by_wildcard[WILDCARD_NAME_CAPTAIN] = WILDCARD_FLAG_CAPTAIN
	wildcard_flags_by_wildcard[WILDCARD_NAME_CENTCOM] = WILDCARD_FLAG_CENTCOM
	wildcard_flags_by_wildcard[WILDCARD_NAME_SYNDICATE] = WILDCARD_FLAG_SYNDICATE
	wildcard_flags_by_wildcard[WILDCARD_NAME_AWAY] = WILDCARD_FLAG_AWAY
	wildcard_flags_by_wildcard[WILDCARD_NAME_SPECIAL] = WILDCARD_FLAG_SPECIAL
	wildcard_flags_by_wildcard[WILDCARD_NAME_FORCED] = WILDCARD_FLAG_FORCED

/// Setup dictionary that converts access levels to text descriptions.
/datum/controller/subsystem/id_access/proc/setup_access_descriptions()
	desc_by_access["[ACCESS_CARGO]"] = "Cargo Bay"
	desc_by_access["[ACCESS_SECURITY]"] = "Security"
	desc_by_access["[ACCESS_BRIG]"] = "Holding Cells"
	desc_by_access["[ACCESS_COURT]"] = "Courtroom"
	desc_by_access["[ACCESS_DETECTIVE]"] = "Detective Office"
	desc_by_access["[ACCESS_MEDICAL]"] = "Medical"
	desc_by_access["[ACCESS_GENETICS]"] = "Genetics Lab"
	desc_by_access["[ACCESS_MORGUE]"] = "Morgue"
	desc_by_access["[ACCESS_MORGUE_SECURE]"] = "Coroner"
	desc_by_access["[ACCESS_SCIENCE]"] = "R&D Lab"
	desc_by_access["[ACCESS_ORDNANCE]"] = "Ordnance Lab"
	desc_by_access["[ACCESS_ORDNANCE_STORAGE]"] = "Ordnance Storage"
	desc_by_access["[ACCESS_PLUMBING]"] = "Chemistry Lab"
	desc_by_access["[ACCESS_RD]"] = "RD Office"
	desc_by_access["[ACCESS_BAR]"] = "Bar"
	desc_by_access["[ACCESS_JANITOR]"] = "Custodial Closet"
	desc_by_access["[ACCESS_ENGINEERING]"] = "Engineering"
	desc_by_access["[ACCESS_ENGINE_EQUIP]"] = "Power and Engineering Equipment"
	desc_by_access["[ACCESS_MAINT_TUNNELS]"] = "Maintenance"
	desc_by_access["[ACCESS_EXTERNAL_AIRLOCKS]"] = "External Airlocks"
	desc_by_access["[ACCESS_CHANGE_IDS]"] = "ID Console"
	desc_by_access["[ACCESS_AI_UPLOAD]"] = "AI Chambers"
	desc_by_access["[ACCESS_TELEPORTER]"] = "Teleporter"
	desc_by_access["[ACCESS_EVA]"] = "EVA"
	desc_by_access["[ACCESS_COMMAND]"] = "Command"
	desc_by_access["[ACCESS_CAPTAIN]"] = "Captain"
	desc_by_access["[ACCESS_ALL_PERSONAL_LOCKERS]"] = "Personal Lockers"
	desc_by_access["[ACCESS_CHAPEL_OFFICE]"] = "Chapel Office"
	desc_by_access["[ACCESS_TECH_STORAGE]"] = "Technical Storage"
	desc_by_access["[ACCESS_ATMOSPHERICS]"] = "Atmospherics"
	desc_by_access["[ACCESS_CREMATORIUM]"] = "Crematorium"
	desc_by_access["[ACCESS_ARMORY]"] = "Armory"
	desc_by_access["[ACCESS_CONSTRUCTION]"] = "Construction"
	desc_by_access["[ACCESS_KITCHEN]"] = "Kitchen"
	desc_by_access["[ACCESS_HYDROPONICS]"] = "Hydroponics"
	desc_by_access["[ACCESS_LIBRARY]"] = "Library"
	desc_by_access["[ACCESS_LAWYER]"] = "Law Office"
	desc_by_access["[ACCESS_ROBOTICS]"] = "Robotics"
	desc_by_access["[ACCESS_VIROLOGY]"] = "Virology"
	desc_by_access["[ACCESS_PSYCHOLOGY]"] = "Psychology"
	desc_by_access["[ACCESS_CMO]"] = "CMO Office"
	desc_by_access["[ACCESS_QM]"] = "QM Office"
	desc_by_access["[ACCESS_SURGERY]"] = "Surgery"
	desc_by_access["[ACCESS_THEATRE]"] = "Theatre"
	desc_by_access["[ACCESS_RESEARCH]"] = "Science"
	desc_by_access["[ACCESS_MINING]"] = "Mining Dock"
	desc_by_access["[ACCESS_SHIPPING]"] = "Cargo Shipping"
	desc_by_access["[ACCESS_VAULT]"] = "Main Vault"
	desc_by_access["[ACCESS_MINING_STATION]"] = "Mining Outpost"
	desc_by_access["[ACCESS_XENOBIOLOGY]"] = "Xenobiology Lab"
	desc_by_access["[ACCESS_HOP]"] = "HoP Office"
	desc_by_access["[ACCESS_HOS]"] = "HoS Office"
	desc_by_access["[ACCESS_CE]"] = "CE Office"
	desc_by_access["[ACCESS_PHARMACY]"] = "Pharmacy"
	desc_by_access["[ACCESS_RC_ANNOUNCE]"] = "RC Announcements"
	desc_by_access["[ACCESS_KEYCARD_AUTH]"] = "Keycode Auth."
	desc_by_access["[ACCESS_TCOMMS]"] = "Telecommunications"
	desc_by_access["[ACCESS_GATEWAY]"] = "Gateway"
	desc_by_access["[ACCESS_BRIG_ENTRANCE]"] = "Brig"
	desc_by_access["[ACCESS_MINERAL_STOREROOM]"] = "Mineral Storage"
	desc_by_access["[ACCESS_MINISAT]"] = "AI Satellite"
	desc_by_access["[ACCESS_WEAPONS]"] = "Weapon Permit"
	desc_by_access["[ACCESS_NETWORK]"] = "Network Access"
	desc_by_access["[ACCESS_MECH_MINING]"] = "Mining Mech Access"
	desc_by_access["[ACCESS_MECH_MEDICAL]"] = "Medical Mech Access"
	desc_by_access["[ACCESS_MECH_SECURITY]"] = "Security Mech Access"
	desc_by_access["[ACCESS_MECH_SCIENCE]"] = "Science Mech Access"
	desc_by_access["[ACCESS_MECH_ENGINE]"] = "Engineering Mech Access"
	desc_by_access["[ACCESS_AUX_BASE]"] = "Auxiliary Base"
	desc_by_access["[ACCESS_SERVICE]"] = "Service Hallway"
	desc_by_access["[ACCESS_CENT_GENERAL]"] = "Code Grey"
	desc_by_access["[ACCESS_CENT_THUNDER]"] = "Code Yellow"
	desc_by_access["[ACCESS_CENT_STORAGE]"] = "Code Orange"
	desc_by_access["[ACCESS_CENT_LIVING]"] = "Code Green"
	desc_by_access["[ACCESS_CENT_MEDICAL]"] = "Code White"
	desc_by_access["[ACCESS_CENT_TELEPORTER]"] = "Code Blue"
	desc_by_access["[ACCESS_CENT_SPECOPS]"] = "Code Black"
	desc_by_access["[ACCESS_CENT_CAPTAIN]"] = "Code Gold"
	desc_by_access["[ACCESS_CENT_BAR]"] = "Code Scotch"
	desc_by_access["[ACCESS_BIT_DEN]"] = "Bitrunner Den"

/**
 * Returns the access bitflags associated with any given access level.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/datum/controller/subsystem/id_access/proc/get_access_flag(access)
	var/flag = flags_by_access["[access]"]
	return flag

/**
 * Returns the access description associated with any given access level.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/datum/controller/subsystem/id_access/proc/get_access_desc(access)
	return desc_by_access["[access]"]

/**
 * Builds and returns a list of accesses from a list of regions.
 *
 * Arguments:
 * * regions - A list of region defines.
 */
/datum/controller/subsystem/id_access/proc/get_region_access_list(list/regions)
	if(!length(regions))
		return

	var/list/built_region_list = list()

	for(var/region in regions)
		built_region_list |= accesses_by_region[region]

	return built_region_list

/**
 * Returns the list of all accesses associated with any given access flag.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * flag - The flag to get access for as either a pure number of string representation of the flag.
 */
/datum/controller/subsystem/id_access/proc/get_flag_access_list(flag)
	return accesses_by_flag["[flag]"]

/**
 * Applies a trim singleton to a card.
 *
 * Returns FALSE if the trim could not be applied due to being incompatible with the card.
 * Incompatibility is defined as a card not being able to hold all the trim's required wildcards.
 * Returns TRUE otherwise.
 * Arguments:
 * * id_card - ID card to apply the trim_path to.
 * * trim_path - A trim path to apply to the card. Grabs the trim's associated singleton and applies it.
 * * copy_access - Boolean value. If true, the trim's access is also copied to the card.
 */
/datum/controller/subsystem/id_access/proc/apply_trim_to_card(obj/item/card/id/id_card, trim_path, copy_access = TRUE)
	var/datum/id_trim/trim = trim_singletons_by_path[trim_path]

	if(!id_card.can_add_wildcards(trim.wildcard_access))
		return FALSE

	id_card.clear_access()
	id_card.trim = trim
	id_card.big_pointer = trim.big_pointer
	id_card.pointer_color = trim.pointer_color

	if(copy_access)
		id_card.access = trim.access.Copy()
		id_card.add_wildcards(trim.wildcard_access)


	if(trim.assignment)
		id_card.assignment = trim.assignment

	var/datum/job/trim_job = trim.find_job()
	if (!isnull(id_card.registered_account))
		var/datum/job/old_job = id_card.registered_account.account_job
		id_card.registered_account.account_job = trim_job
		id_card.registered_account.update_account_job_lists(trim_job, old_job)

	id_card.update_label()
	id_card.update_icon()

	return TRUE

/**
 * Removes a trim from an ID card. Also removes all accesses from it too.
 *
 * Arguments:
 * * id_card - The ID card to remove the trim from.
 */
/datum/controller/subsystem/id_access/proc/remove_trim_from_card(obj/item/card/id/id_card)
	id_card.trim = null
	id_card.clear_access()
	id_card.update_label()
	id_card.update_icon()

/**
 * Applies a trim to a card. This is purely visual, utilising the card's override vars.
 *
 * Arguments:
 * * id_card - The card to apply the trim visuals to.
 * * trim_path - A trim path to apply to the card. Grabs the trim's associated singleton and applies it.
 * * check_forged - Boolean value. If TRUE, will not overwrite the card's assignment if the card has been forged.
 */
/datum/controller/subsystem/id_access/proc/apply_trim_override(obj/item/card/id/advanced/id_card, trim_path, check_forged = TRUE)
	var/datum/id_trim/trim = trim_singletons_by_path[trim_path]
	id_card.trim_icon_override = trim.trim_icon
	id_card.trim_state_override = trim.trim_state
	id_card.trim_assignment_override = trim.assignment
	id_card.sechud_icon_state_override = trim.sechud_icon_state
	id_card.department_color_override = trim.department_color
	id_card.department_state_override = trim.department_state
	id_card.subdepartment_color_override = trim.subdepartment_color
	id_card.big_pointer = trim.big_pointer
	id_card.pointer_color = trim.pointer_color

	var/obj/item/card/id/advanced/chameleon/cham_id = id_card
	if (istype(cham_id) && (!check_forged || !cham_id.forged))
		cham_id.assignment = trim.assignment

	if (ishuman(id_card.loc))
		var/mob/living/carbon/human/owner = id_card.loc
		owner.sec_hud_set_ID()

/**
 * Removes a trim from a ID card.
 *
 * Arguments:
 * * id_card - The ID card to remove the trim from.
 */
/datum/controller/subsystem/id_access/proc/remove_trim_override(obj/item/card/id/advanced/id_card)
	id_card.trim_icon_override = null
	id_card.trim_state_override = null
	id_card.trim_assignment_override = null
	id_card.sechud_icon_state_override = null
	id_card.department_color_override = null
	id_card.department_state_override = null
	id_card.subdepartment_color_override = null
	id_card.big_pointer = id_card.trim.big_pointer
	id_card.pointer_color = id_card.trim.pointer_color

	if (ishuman(id_card.loc))
		var/mob/living/carbon/human/owner = id_card.loc
		owner.sec_hud_set_ID()

/**
 * Adds the accesses associated with a trim to an ID card.
 *
 * Clears the card's existing access levels first.
 * Primarily intended for applying trim templates to cards. Will attempt to add as many ordinary access
 * levels as it can, without consuming any wildcards. Will then attempt to apply the trim-specific wildcards after.
 *
 * Arguments:
 * * id_card - The ID card to remove the trim from.
 */
/datum/controller/subsystem/id_access/proc/add_trim_access_to_card(obj/item/card/id/id_card, trim_path)
	var/datum/id_trim/trim = trim_singletons_by_path[trim_path]

	id_card.clear_access()

	id_card.add_access(trim.access, mode = TRY_ADD_ALL_NO_WILDCARD)
	id_card.add_wildcards(trim.wildcard_access, mode = TRY_ADD_ALL)
	if(istype(trim, /datum/id_trim/job))
		var/datum/id_trim/job/job_trim = trim // Here is where we update a player's paycheck department for the purposes of discounts/paychecks.
		id_card.registered_account.account_job.paycheck_department = job_trim.job.paycheck_department

/**
 * Tallies up all accesses the card has that have flags greater than or equal to the access_flag supplied.
 *
 * Returns the number of accesses that have flags matching access_flag or a higher tier access.
 * Arguments:
 * * id_card - The ID card to tally up access for.
 * * access_flag - The minimum access flag required for an access to be tallied up.
 */
/datum/controller/subsystem/id_access/proc/tally_access(obj/item/card/id/id_card, access_flag = NONE)
	var/tally = 0

	var/list/id_card_access = id_card.access
	for(var/access in id_card_access)
		if(flags_by_access["[access]"] >= access_flag)
			tally++

	return tally

/**
 * Helper proc for creating a copy of the in-character information you could render from scanning for an ID card.
 * Accounts for chameleon cards, silicons, and ID read failures.
 * Pertinently, it also returns relevant information for their bank account (if they have one).
 * To return bank account info for a chameleon card, bypass_chameleon must be set to TRUE. Otherwise it returns
 * a bogey record.
 * datum/source -
 */
/datum/controller/subsystem/id_access/proc/__in_character_record_id_information(
	atom/movable/target_of_record,
	bypass_chameleon = FALSE
	) as /alist

	var/alist/returned_record = alist(
		"name" = null,
		"age" = null,
		"assignment" = null,
		"account_id" = null,
		"account_holder" = null,
		"account_assignment" = null,
		"accesses" = null,
	)
	. = returned_record
	if(isnull(target_of_record))
		.["name"] = ID_READ_FAILURE
		.["age"] = ID_READ_FAILURE
		.["assignment"] = ID_READ_FAILURE
		.["account_id"] = ID_READ_FAILURE
		.["account_holder"] = ID_READ_FAILURE
		.["account_assignment"] = ID_READ_FAILURE
		.["accesses"] = ID_READ_FAILURE
		.[ID_READ_FAILURE] = ID_READ_FAILURE
		return .
	var/mob/living/target = astype(target_of_record, /mob/living)
	if(target)
		if(!issilicon(target) && !isdrone(target))
			. = __in_character_record_id_information(astype(target.get_idcard(), /obj/item/card/id/advanced))
			return .
		.["name"] = target.name
		.["age"] = 0
		.["assignment"] = "Silicon"
		.["account_id"] = null
		.["account_holder"] = null
		.["account_assignment"] = null
		.["accesses"] = null
		.[SILICON_OVERRIDE] = SILICON_OVERRIDE
		return .
	var/obj/item/card/id/advanced/id_card = astype(target_of_record, /obj/item/card/id/advanced)
	if(id_card)
		.["name"] = id_card.registered_name || "Unknown"
		.["age"] = id_card.registered_age || "Unknown"
		.["assignment"] = id_card.assignment || "Unassigned"
		.["accesses"] = id_card.access
		var/datum/bank_account/id_account = id_card.registered_account
		if(istype(id_card, /obj/item/card/id/advanced/chameleon) && !bypass_chameleon)
			// Generate a bogey record based only on the ID card
			// Generates a random bank account number every time as a 'spot the thread' for anyone who
			// went through records for this entry for whatever reason.
			.["account_id"] = rand(111111, 999999)
			.["account_holder"] = .["name"]
			.["account_assignment"] = .["assignment"]
			.[CHAMELEON_OVERRIDE] = CHAMELEON_OVERRIDE
			return .
		if(!id_account)
			.["account_id"] = 0
			.["account_holder"] = "NO ACCOUNT."
			.["account_assignment"] = "NO ACCOUNT."
			return .
		.["account_id"] = id_account.account_id
		.["account_holder"] = id_account.account_holder
		.["account_assignment"] = id_account.account_job?.title || "Unassigned"
		return .
	else
		. = ID_DATA(null)
