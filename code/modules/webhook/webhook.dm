/proc/webhook_send_roundstatus(var/status, var/extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_runtime(var/message) //when server logging gets fucked up, discord bot saves the day
	var/list/query = list("message" = message)
	webhook_send("runtimemessage", query)

/proc/webhook_send_asay(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("oocmessage", query)

/proc/webhook_send_me(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("memessage", query)

/proc/webhook_send_ahelp(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("ahelpmessage", query)

/proc/webhook_send_garbage(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("garbage", query)

/proc/webhook_send_token(var/ckey, var/token)
	var/list/query = list("ckey" = ckey, "token" = token)
	webhook_send("token", query)

/proc/webhook_send_status_update(var/event,var/data)
	var/list/query = list("event" = event, "data" = data)
	webhook_send("status_update", query)

/proc/webhook_send(var/method, var/data)
	if(!CONFIG_GET(string/webhook_address) || !CONFIG_GET(string/webhook_key))
		return
	var/query = "[CONFIG_GET(string/webhook_address)]?key=[CONFIG_GET(string/webhook_key)]&method=[method]&data=[url_encode(r_json_encode(data))]"
	spawn(-1)
		world.Export(query)