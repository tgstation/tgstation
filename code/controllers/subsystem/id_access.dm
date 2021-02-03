SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of access flags. Keys are accesses. Values are their associated bitflags.
	var/list/flags_by_access = list()
	/// Dictionary of trim singletons. Keys are paths. Values are their associated singletons.
	var/list/trim_singletons_by_path = list()

/datum/controller/subsystem/id_access/Initialize(timeofday)
	// We use this because creating the trim singletons requires the config to be loaded.
	SSmapping.HACK_LoadMapConfig()
	setup_access_flags()
	setup_trim_singletons()
	return ..()

/datum/controller/subsystem/id_access/proc/setup_access_flags()
	for(var/access in COMMON_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_COMMON
	for(var/access in COMMAND_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_COMMAND
	for(var/access in PRIVATE_COMMAND_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_PRV_COMMAND
	for(var/access in CAPTAIN_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_CAPTAIN
	for(var/access in CENTCOM_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_CENTCOM
	for(var/access in SYNDICATE_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_SYNDICATE
	for(var/access in AWAY_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_AWAY
	for(var/access in CULT_ACCESS)
		flags_by_access[access] = ACCESS_FLAG_SPECIAL

/datum/controller/subsystem/id_access/proc/setup_trim_singletons()
	for(var/trim in typesof(/datum/id_trim))
		trim_singletons_by_path[trim] = new trim()

/datum/controller/subsystem/id_access/proc/get_access_flag(access)
	return flags_by_access[access] ? flags_by_access[access] : ACCESS_FLAG_SPECIAL

/datum/controller/subsystem/id_access/proc/get_trim(trim)
	return trim_singletons_by_path[trim]

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
