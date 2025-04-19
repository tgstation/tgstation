GLOBAL_DATUM_INIT(animate_panel, /datum/animate_panel, new)

/datum/animate_panel
	var/static/list/datum/animate_flag/flags
	var/static/list/datum/animate_easing/easings
	var/static/list/datum/animate_easing_flag/easing_flags
	var/static/list/datum/animate_argument/arguments

	var/list/cached_targets
	var/list/datum/animate_chain/animate_chains_by_user

/datum/animate_panel/New()
	..()

	if(isnull(flags))
		flags = list()
		for(var/datum/animate_flag/flag as anything in subtypesof(/datum/animate_flag))
			flags[flag::name] = new flag
		easings = list()
		for(var/datum/animate_easing/easing as anything in subtypesof(/datum/animate_easing))
			easings[easing::name] = new easing
		easing_flags = list()
		for(var/datum/animate_easing_flag/easing_flag as anything in subtypesof(/datum/animate_easing_flag))
			easing_flags[easing_flag::name] = new easing_flag
		arguments = list()
		for(var/datum/animate_argument/argument as anything in subtypesof(/datum/animate_argument))
			arguments[argument::name] = new argument

	cached_targets = list()
	animate_chains_by_user = list()

/datum/animate_panel/proc/get_chain_by_index(mob/user, index)
	RETURN_TYPE(/datum/animate_chain)

	if(!isnum(index))
		return null

	var/datum/animate_chain/chain = animate_chains_by_user[ref(user)]
	if(!chain)
		return null

	while(!isnull(chain) && chain.chain_index != index)
		chain = chain.next
	if(chain.chain_index == index)
		return chain

	return null
