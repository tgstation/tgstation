/// Logs the contents of the gasmix to the game log, prefixed by text
/proc/log_atmos(text, datum/gas_mixture/mix)
	var/message = text + " "
	message += print_gas_mixture(mix)
	log_game(message)
