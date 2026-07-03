/datum/preferences/vv_edit_var(var_name, var_value)
	if(var_name == "discord_id")
		return FALSE
	return ..()

/client/proc/verify_in_discord_central()
	if(!SScentral.can_run())
		to_chat(src, span_warning("Привязка Discord сейчас недоступна."))
		return

	if(SScentral.is_player_discord_linked(ckey))
		to_chat(src, span_warning("Вы уже привязали свою учетную запись Discord."))
		return

	to_chat(src, span_notice("Пытаемся получить токен для входа в Discord..."))
	SScentral.verify_in_discord(src)

/datum/controller/subsystem/central/proc/verify_in_discord(client/player)
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/oauth/token?ckey=[player.ckey]"
	var/list/headers = list(
		"Authorization" = "Bearer [CONFIG_GET(string/ss_central_token)]"
	)
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, endpoint, "", headers, CALLBACK(SScentral, PROC_REF(verify_in_discord_callback), player))

/datum/controller/subsystem/central/proc/verify_in_discord_callback(client/player, datum/http_response/response)
	if(response.errored || response.status_code != 201)
		stack_trace("Failed to get discord verification token: HTTP status code [response.status_code] - [response.error]")
		return

	var/list/data = json_decode(response.body)
	var/login_endpoint = "[CONFIG_GET(string/ss_central_url)]/oauth/login?token=[data]"

	to_chat(player, boxed_message("<a href='[login_endpoint]'>Привязать дискорд</a>"))
	player << browse(
		"<!DOCTYPE html><html><head><meta charset=UTF-8'><script>location.href='[login_endpoint]'</script></head><body'></body></html>",
		"window=authwindow;parent=mapwindow.map;titlebar=0;can_resize=0;size=0x0;pos=0,0;background-color=black;"
	)
	SStitle.title_output(player, login_endpoint, "updateAuthBrowser")

/datum/config_entry/flag/force_discord_verification
	default = FALSE
