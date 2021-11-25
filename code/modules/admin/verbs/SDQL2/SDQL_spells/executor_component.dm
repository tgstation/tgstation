/datum/component/sdql_executor
	var/query = "CALL visible_message(\"<span class='warning'>The spell fizzles!</span>\") ON * IN TARGETS"
	var/giver //The ckey of the user that gave this spell
	var/suppress_message_admins
	var/list/scratchpad = list() //Use this to store vars in between queries and casts.
	var/list/saved_overrides = list()

/datum/component/sdql_executor/Initialize(giver)
	src.giver = giver

//Returns the address of x without the square brackets around it.
#define RAW_ADDRESS(x) copytext("\ref[x]",2,-1)

/datum/component/sdql_executor/proc/execute(list/targets, mob/user)
	if(!CONFIG_GET(flag/sdql_spells))
		return
	if(!length(query))
		return
	var/query_text = query
	var/message_query = query
	var/list/targets_and_user_list = list(user)
	if(targets)
		targets_and_user_list += targets
	var/targets_and_user_string = ref_list(targets_and_user_list)
	var/targets_string = ref_list(targets)
	query_text = replacetextEx_char(query_text, "TARGETS_AND_USER", "[targets_and_user_string]")
	message_query = replacetext_char(message_query, "TARGETS_AND_USER", (targets_and_user_list.len > 3) ? "\[<i>[targets_and_user_list.len] items</i>]" : targets_and_user_string)
	query_text = replacetextEx_char(query_text, "USER", "{[RAW_ADDRESS(user)]}")
	message_query = replacetextEx_char(message_query, "USER", "{[RAW_ADDRESS(user)]}")
	query_text = replacetextEx_char(query_text, "TARGETS", "[targets_string]")
	message_query = replacetextEx_char(message_query, "TARGETS", (targets?.len > 3) ? "\[<i>[targets.len] items</i>]" : targets_string)
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

/datum/component/sdql_executor/proc/ref_list(list/L)
	if(isnull(L) || !L.len)
		return "\[]"
	var/ret = "\["
	for(var/i in 1 to L.len-1)
		ret += "{[RAW_ADDRESS(L[i])]},"
	ret += "{[RAW_ADDRESS(L[L.len])]}]"
	return ret

#undef RAW_ADDRESS
