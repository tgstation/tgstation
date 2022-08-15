/// Logs the contents of the gasmix to the game log, prefixed by text
/proc/log_atmos(text, datum/gas_mixture/mix)
	var/message = text
	message += "TEMP=[mix.temperature],MOL=[mix.total_moles()],VOL=[mix.volume]"
	for(var/key in mix.gases)
		var/list/gaslist = mix.gases[key]
		message += "[gaslist[GAS_META][META_GAS_ID]]=[gaslist[MOLES]];"
	log_game(message)
