
//Returns the address of x without the square brackets around it.
#define RAW_ADDRESS(x) copytext("\ref[x]",2,-1)

/**
 * SDQL spell exector
 *
 * Attached to spells, allow them to execute an SDQL query on cast
 */
/datum/component/sdql_spell_executor
	var/executor_signals
	/// The query ran on cast.
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	/// The ckey of the admin / user that created this spell.
	var/giver
	/// Whether every casted alerts admins or not.
	var/suppress_message_admins = FALSE
	/// Use this to store vars in between queries and casts.
	var/list/scratchpad = list()
	var/list/saved_overrides = list()

/datum/component/sdql_spell_executor/Initialize(giver, executor_signals)
	if(!istype(parent, /datum/action))
		return COMPONENT_INCOMPATIBLE

	if(!executor_signals)
		message_admins("An SDQL spell was created without executor signals, that means the spell won't execute on anything.")

	src.giver = giver
	src.executor_signals = executor_signals

/datum/component/sdql_spell_executor/RegisterWithParent()
	if(!executor_signals)
		return

	RegisterSignal(parent, executor_signals, .proc/on_spell_execute)

/datum/component/sdql_spell_executor/UnregisterFromParent()
	if(!executor_signals)
		return

	UnregisterSignal(parent, executor_signals)

/// On a successful execution, invoke the SDQL
/datum/component/sdql_spell_executor/proc/on_spell_execute(datum/source, cast_on)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/execute, cast_on)

/// The actual proc that exectues the SDQL queery
/datum/component/sdql_spell_executor/proc/execute(cast_on)
	if(!CONFIG_GET(flag/sdql_spells))
		return
	if(!length(query))
		return
	var/query_text = query
	var/message_query = query
	var/datum/action/parent_action = parent
	var/mob/user = parent_action?.owner
	if(!user)
		CRASH("An SDQL executed a query without an associated [parent_action ? "owner":"action"].")
	var/list/targets_and_user_list = list(user)
	if(cast_on)
		targets_and_user_list |= cast_on
	var/list/targets_list = islist(cast_on) ? cast_on : list(cast_on)

	var/targets_and_user_string = ref_list(targets_and_user_list)
	var/targets_string = ref_list(targets_list)

	query_text = replacetextEx_char(query_text, "TARGETS_AND_USER", "[targets_and_user_string]")
	message_query = replacetext_char(message_query, "TARGETS_AND_USER", (targets_and_user_list.len > 3) ? "\[<i>[targets_and_user_list.len] items</i>]" : targets_and_user_string)
	query_text = replacetextEx_char(query_text, "USER", "{[RAW_ADDRESS(user)]}")
	message_query = replacetextEx_char(message_query, "USER", "{[RAW_ADDRESS(user)]}")
	query_text = replacetextEx_char(query_text, "TARGETS", "[targets_string]")
	message_query = replacetextEx_char(message_query, "TARGETS", (length(targets_list) > 3) ? "\[<i>[length(targets_list)] items</i>]" : targets_string)
	query_text = replacetextEx_char(query_text, "SOURCE", "{[RAW_ADDRESS(parent)]}")
	message_query = replacetextEx_char(message_query, "SOURCE", "{[RAW_ADDRESS(parent)]}")
	query_text = replacetextEx_char(query_text, "SCRATCHPAD", "({[RAW_ADDRESS(src)]}.scratchpad)")
	message_query = replacetextEx_char(message_query, "SCRATCHPAD", "({[RAW_ADDRESS(src)]}.scratchpad)")
	if(!usr) //We need to set AdminProcCaller manually because it won't be set automatically by WrapAdminProcCall if usr is null
		GLOB.AdminProcCaller = "SDQL_SPELL_OF_[user.ckey]"
	GLOB.AdminProcCallCount++
	world.SDQL2_query(query_text, "[key_name(user, TRUE)] (via an SDQL spell given by [giver])", "[key_name(user)] (via an SDQL spell given by [giver])", silent = suppress_message_admins)
	GLOB.AdminProcCallCount--
	GLOB.AdminProcCaller = null

/datum/component/sdql_spell_executor/proc/ref_list(list/L)
	if(isnull(L) || !L.len)
		return "\[]"
	var/ret = "\["
	for(var/i in 1 to L.len-1)
		ret += "{[RAW_ADDRESS(L[i])]},"
	ret += "{[RAW_ADDRESS(L[L.len])]}]"
	return ret

#undef RAW_ADDRESS
