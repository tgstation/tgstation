SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of access flags. Keys are accesses. Values are their associated bitflags.
	var/list/flags_by_access = list()
	/// Dictionary of trim singletons. Keys are paths. Values are their associated singletons.
	var/list/trim_singletons_by_path = list()
	/// Dictionary of wildcard compatibility flags. Keys are strings for the wildcards. Values are their associated flags.
	var/list/wildcard_flags_by_wildcard = list()

/datum/controller/subsystem/id_access/Initialize(timeofday)
	// We use this because creating the trim singletons requires the config to be loaded.
	SSmapping.HACK_LoadMapConfig()
	setup_access_flags()
	setup_trim_singletons()
	setup_wildcard_dict()
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

/datum/controller/subsystem/id_access/proc/setup_trim_singletons()
	for(var/trim in typesof(/datum/id_trim))
		trim_singletons_by_path[trim] = new trim()

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

/datum/controller/subsystem/id_access/proc/get_access_flag(access)
	return flags_by_access["[access]"] ? text2num(flags_by_access["[access]"]) : ACCESS_FLAG_SPECIAL

/datum/controller/subsystem/id_access/proc/get_trim(trim)
	return trim_singletons_by_path[trim]

/datum/controller/subsystem/id_access/proc/get_wildcard_flags(name)
	return wildcard_flags_by_wildcard[name]

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

/datum/controller/subsystem/id_access/proc/apply_trim_to_chameleon_card(obj/item/card/id/advanced/chameleon/id_card, trim_path, check_forged = TRUE)
	var/datum/id_trim/trim = get_trim(trim_path)
	id_card.trim_icon_override = trim.trim_icon
	id_card.trim_state_override = trim.trim_state

	if(!check_forged || !id_card.forged)
		id_card.assignment = trim.assignment

	// We'll let the chameleon action update the card's label as necessary instead of doing it here.
