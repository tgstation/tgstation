SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of access flags. Keys are accesses. Values are their associated bitflags.
	var/list/flags_by_access = list()
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

/datum/controller/subsystem/id_access/Initialize(timeofday)
	// We use this because creating the trim singletons requires the config to be loaded.
	SSmapping.HACK_LoadMapConfig()
	setup_access_flags()
	setup_trim_singletons()
	setup_wildcard_dict()
	setup_access_descriptions()
	setup_tgui_lists()
	return ..()

/datum/controller/subsystem/id_access/proc/setup_access_flags()
	for(var/access in COMMON_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_COMMON)
	for(var/access in COMMAND_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_COMMAND)
	for(var/access in PRIVATE_COMMAND_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_PRV_COMMAND)
	for(var/access in CAPTAIN_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_CAPTAIN)
	for(var/access in CENTCOM_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_CENTCOM)
	for(var/access in SYNDICATE_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_SYNDICATE)
	for(var/access in AWAY_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_AWAY)
	for(var/access in CULT_ACCESS)
		flags_by_access |= list("[access]" = ACCESS_FLAG_SPECIAL)

	access_flag_string_by_flag["[ACCESS_FLAG_COMMON]"] = ACCESS_FLAG_COMMON_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_COMMAND]"] = ACCESS_FLAG_COMMAND_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_PRV_COMMAND]"] = ACCESS_FLAG_PRV_COMMAND_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_CAPTAIN]"] = ACCESS_FLAG_CAPTAIN_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_CENTCOM]"] = ACCESS_FLAG_CENTCOM_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_SYNDICATE]"] = ACCESS_FLAG_SYNDICATE_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_AWAY]"] = ACCESS_FLAG_AWAY_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_SPECIAL]"] = ACCESS_FLAG_SPECIAL_NAME

/datum/controller/subsystem/id_access/proc/setup_trim_singletons()
	for(var/trim in typesof(/datum/id_trim))
		trim_singletons_by_path[trim] = new trim()

/// Creates various data structures that get fed to tgui interfaces.
/datum/controller/subsystem/id_access/proc/setup_tgui_lists()
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

/datum/controller/subsystem/id_access/proc/setup_access_descriptions()
	desc_by_access["[ACCESS_CARGO]"] = "Cargo Bay"
	desc_by_access["[ACCESS_SECURITY]"] = "Security"
	desc_by_access["[ACCESS_BRIG]"] = "Holding Cells"
	desc_by_access["[ACCESS_COURT]"] = "Courtroom"
	desc_by_access["[ACCESS_FORENSICS_LOCKERS]"] = "Forensics"
	desc_by_access["[ACCESS_MEDICAL]"] = "Medical"
	desc_by_access["[ACCESS_GENETICS]"] = "Genetics Lab"
	desc_by_access["[ACCESS_MORGUE]"] = "Morgue"
	desc_by_access["[ACCESS_RND]"] = "R&D Lab"
	desc_by_access["[ACCESS_TOXINS]"] = "Toxins Lab"
	desc_by_access["[ACCESS_TOXINS_STORAGE]"] = "Toxins Storage"
	desc_by_access["[ACCESS_CHEMISTRY]"] = "Chemistry Lab"
	desc_by_access["[ACCESS_RD]"] = "RD Office"
	desc_by_access["[ACCESS_BAR]"] = "Bar"
	desc_by_access["[ACCESS_JANITOR]"] = "Custodial Closet"
	desc_by_access["[ACCESS_ENGINE]"] = "Engineering"
	desc_by_access["[ACCESS_ENGINE_EQUIP]"] = "Power and Engineering Equipment"
	desc_by_access["[ACCESS_MAINT_TUNNELS]"] = "Maintenance"
	desc_by_access["[ACCESS_EXTERNAL_AIRLOCKS]"] = "External Airlocks"
	desc_by_access["[ACCESS_CHANGE_IDS]"] = "ID Console"
	desc_by_access["[ACCESS_AI_UPLOAD]"] = "AI Chambers"
	desc_by_access["[ACCESS_TELEPORTER]"] = "Teleporter"
	desc_by_access["[ACCESS_EVA]"] = "EVA"
	desc_by_access["[ACCESS_HEADS]"] = "Bridge"
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
	desc_by_access["[ACCESS_QM]"] = "Quartermaster"
	desc_by_access["[ACCESS_SURGERY]"] = "Surgery"
	desc_by_access["[ACCESS_THEATRE]"] = "Theatre"
	desc_by_access["[ACCESS_RESEARCH]"] = "Science"
	desc_by_access["[ACCESS_MINING]"] = "Mining"
	desc_by_access["[ACCESS_MAILSORTING]"] = "Cargo Office"
	desc_by_access["[ACCESS_VAULT]"] = "Main Vault"
	desc_by_access["[ACCESS_MINING_STATION]"] = "Mining EVA"
	desc_by_access["[ACCESS_XENOBIOLOGY]"] = "Xenobiology Lab"
	desc_by_access["[ACCESS_HOP]"] = "HoP Office"
	desc_by_access["[ACCESS_HOS]"] = "HoS Office"
	desc_by_access["[ACCESS_CE]"] = "CE Office"
	desc_by_access["[ACCESS_PHARMACY]"] = "Pharmacy"
	desc_by_access["[ACCESS_RC_ANNOUNCE]"] = "RC Announcements"
	desc_by_access["[ACCESS_KEYCARD_AUTH]"] = "Keycode Auth."
	desc_by_access["[ACCESS_TCOMSAT]"] = "Telecommunications"
	desc_by_access["[ACCESS_GATEWAY]"] = "Gateway"
	desc_by_access["[ACCESS_SEC_DOORS]"] = "Brig"
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
	desc_by_access["[ACCESS_CENT_GENERAL]"] = "Code Grey"
	desc_by_access["[ACCESS_CENT_THUNDER]"] = "Code Yellow"
	desc_by_access["[ACCESS_CENT_STORAGE]"] = "Code Orange"
	desc_by_access["[ACCESS_CENT_LIVING]"] = "Code Green"
	desc_by_access["[ACCESS_CENT_MEDICAL]"] = "Code White"
	desc_by_access["[ACCESS_CENT_TELEPORTER]"] = "Code Blue"
	desc_by_access["[ACCESS_CENT_SPECOPS]"] = "Code Black"
	desc_by_access["[ACCESS_CENT_CAPTAIN]"] = "Code Gold"
	desc_by_access["[ACCESS_CENT_BAR]"] = "Code Scotch"

/datum/controller/subsystem/id_access/proc/get_access_flag(access)
	return flags_by_access["[access]"]

/datum/controller/subsystem/id_access/proc/get_trim(trim)
	return trim_singletons_by_path[trim]

/datum/controller/subsystem/id_access/proc/get_wildcard_flags(name)
	return wildcard_flags_by_wildcard[name]

/datum/controller/subsystem/id_access/proc/get_access_desc(access)
	return desc_by_access["[access]"]

/datum/controller/subsystem/id_access/proc/apply_trim_to_card(obj/item/card/id/id_card, trim_path)
	var/datum/id_trim/trim = get_trim(trim_path)

	if(!id_card.can_add_wildcards(trim.wildcard_access))
		return FALSE

	id_card.timberpoes_trim = trim
	id_card.timberpoes_access = trim.access.Copy()
	id_card.add_wildcards(trim.wildcard_access)

	if(trim.assignment)
		id_card.assignment = trim.assignment

	id_card.update_label()

/datum/controller/subsystem/id_access/proc/remove_trim_from_card(obj/item/card/id/id_card)
	id_card.timberpoes_trim = null
	id_card.clear_access()
	id_card.update_label()

/datum/controller/subsystem/id_access/proc/apply_trim_to_chameleon_card(obj/item/card/id/advanced/chameleon/id_card, trim_path, check_forged = TRUE)
	var/datum/id_trim/trim = get_trim(trim_path)
	id_card.trim_icon_override = trim.trim_icon
	id_card.trim_state_override = trim.trim_state

	if(!check_forged || !id_card.forged)
		id_card.assignment = trim.assignment

	// We'll let the chameleon action update the card's label as necessary instead of doing it here.

/datum/controller/subsystem/id_access/proc/remove_trim_from_chameleon_card(obj/item/card/id/advanced/chameleon/id_card)
	id_card.trim_icon_override = null
	id_card.trim_state_override = null
