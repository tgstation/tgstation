/datum/config_entry/flag/demos_enabled
	default = FALSE

SUBSYSTEM_DEF(demo)
	name = "Demo"
	wait = 1
	flags = SS_TICKER | SS_BACKGROUND
	init_order = INIT_ORDER_DEMO
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/last_size = 0
	var/last_embedded_size = 0
	var/demo_started = 0

	var/ckey = "@@demoobserver"
	var/mob/dead/observer/dummy_observer

	var/list/embed_list = list()
	var/list/embedded_list = list()
	var/list/chat_list = list()

/datum/controller/subsystem/demo/proc/write_chat(target, message)
	if(!demo_started && !chat_list || !CONFIG_GET(flag/demos_enabled))
		return
	var/list/target_list
	if(target == GLOB.clients || target == world)
		target_list = list(world)
	else if(istype(target, /datum/controller/subsystem/demo) || target == dummy_observer || target == "d")
		target_list = list("d")
	else if(islist(target))
		target_list = list()
		for(var/T in target)
			if(istype(T, /datum/controller/subsystem/demo) || T == dummy_observer || T == "d")
				target_list += "d"
			else
				var/client/C = CLIENT_FROM_VAR(target)
				if(C)
					target_list += C
	else
		var/client/C = CLIENT_FROM_VAR(target)
		if(C)
			target_list = list(C)
	if(!target_list || !target_list.len)
		return

	var/message_str = ""
	var/is_text = FALSE
	if(islist(message))
		if(message["text"])
			is_text = TRUE
			message_str = message["text"]
		else
			message_str = message["html"]
	else if(istext(message))
		message_str = message
	if(demo_started)
		for(var/I in 1 to target_list.len)
			if(!istext(target_list[I])) target_list[I] = "\ref[target_list[I]]"
		call(DEMO_WRITER, "demo_chat")(target_list.Join(","), "\ref[message_str]", "[is_text]")
	else if(chat_list)
		chat_list[++chat_list.len] = list(world.time, target_list, message_str, is_text)

/datum/controller/subsystem/demo/Initialize()
	if(!CONFIG_GET(flag/demos_enabled))
		return SS_INIT_NO_NEED
	dummy_observer = new
	dummy_observer.forceMove(null)
	dummy_observer.key = dummy_observer.ckey = ckey
	dummy_observer.name = dummy_observer.real_name = "SSdemo Dummy Observer"

	var/revdata_list = list()
	if(GLOB.revdata)
		revdata_list["commit"] = "[GLOB.revdata.commit || GLOB.revdata.originmastercommit]"
		if(GLOB.revdata.originmastercommit) revdata_list["originmastercommit"] = "[GLOB.revdata.originmastercommit]"
		revdata_list["repo"] = "Monkestation/Monkestation2.0"
	var/revdata_str = json_encode(revdata_list);
	var/result = RUSTG_CALL(DEMO_WRITER, "demo_start")(GLOB.demo_log, revdata_str)

	if(result == "SUCCESS")
		demo_started = 1
		for(var/L in embed_list)
			embed_resource(arglist(L))

		for(var/list/L in chat_list)
			call(DEMO_WRITER, "demo_set_time_override")(L[1])
			var/list/target_list = L[2]
			for(var/I in 1 to target_list.len)
				if(!istext(target_list[I])) target_list[I] = "\ref[target_list[I]]"
			call(DEMO_WRITER, "demo_chat")(target_list.Join(","), "\ref[L[3]]", "[L[4]]")
		call(DEMO_WRITER, "demo_set_time_override")("null")

		last_size = text2num(call(DEMO_WRITER, "demo_get_size")())
	else
		log_world("Failed to initialize demo system: [result]")

	embed_list = null
	chat_list = null

	return SS_INIT_SUCCESS

/datum/controller/subsystem/demo/fire()
	if(!CONFIG_GET(flag/demos_enabled))
		return
	if(demo_started)
		last_size = text2num(call(DEMO_WRITER, "demo_flush")())

/datum/controller/subsystem/demo/proc/flush()
	if(!CONFIG_GET(flag/demos_enabled))
		return
	if(demo_started)
		last_size = text2num(call(DEMO_WRITER, "demo_flush")())

/datum/controller/subsystem/demo/Shutdown()
	if(!CONFIG_GET(flag/demos_enabled))
		return
	call(DEMO_WRITER, "demo_end")()

/datum/controller/subsystem/demo/stat_entry(msg)
	msg += "ALL: [format_size(last_size)] | RSC: [format_size(last_embedded_size)]"
	return ..(msg)

/datum/controller/subsystem/demo/proc/format_size(size)
	if(size < 1000000)
		return "[round(size / 1000, 0.01)]kB"
	return "[round(size / 1000000, 0.01)]MB"

/datum/controller/subsystem/demo/proc/embed_resource(res, path)
	if(!CONFIG_GET(flag/demos_enabled))
		return
	res = fcopy_rsc(res)
	if(!demo_started)
		if(embed_list)
			embed_list += list(list(res, path))
		return res
	if(!res || embedded_list[res])
		return res
	var/do_del = FALSE
	if(!istext(path))
		path = "tmp/rsc_[ckey("\ref[res]")]_[rand(0, 100000)]"
		fcopy(res, path)
		//do_del = TRUE
	var/size = length(file(path))
	last_embedded_size += size
	log_world("Embedding \ref[res] [res] from [path] ([size] bytes)")
	if(call(DEMO_WRITER, "demo_embed_resource")("\ref[res]", path) != "SUCCESS")
		log_world("Failed to copy \ref[res] [res] from [path]!")
	embedded_list[res] = 1
	if(do_del)
		fdel(path)
	return res
