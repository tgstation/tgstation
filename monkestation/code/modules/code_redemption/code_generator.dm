#define CODE_STORAGE_PATH "data/generated_codes.json"

GLOBAL_LIST_INIT(stored_codes, list())


/proc/generate_redemption_code()
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose a code type", "Code generation", list("Coins", "Loadout Items", "Antag Tokens"))

	if(!choice)
		return

	if(choice == "Coins")
		generate_coin_code()
	else if(choice == "Loadout Items")
		generate_loadout_code()
	else
		generate_antag_token_code()

/proc/generate_coin_code(no_logs = FALSE)
	if(!check_rights(R_FUN))
		return
	var/amount = tgui_input_number(usr, "Please enter an amount of coins to give", "Coin Amount", 0, 10000, 0)
	if(!amount)
		return
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = amount

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)
	reload_global_stored_codes()
	if(!no_logs)
		log_game("[usr] generated a new redemption code worth [amount] of coins.")
		message_admins("[usr] generated a new redemption code worth [amount] of coins.")
		to_chat(usr, span_big("Your generated code is: [string]"))
	return string

/proc/generate_loadout_code(no_logs = FALSE)
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose a loadout item to award", "Loadout Choice", subtypesof(/datum/store_item) - typesof(/datum/store_item/roundstart))
	if(!choice)
		return
	reload_global_stored_codes()
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = "[choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)
	reload_global_stored_codes()
	if(!no_logs)
		log_game("[usr] generated a new redemption code giving a [choice].")
		message_admins("[usr] generated a new redemption code giving a [choice].")
		to_chat(usr, span_big("Your generated code is: [string]"))
	return string

/proc/generate_code_string()
	var/list/sections = list()
	for(var/num in 1 to 5)
		sections += random_string(5, GLOB.hex_characters)

	var/string = sections.Join("-")
	return string

/proc/reload_global_stored_codes()
	GLOB.stored_codes = list()
	var/json_file = file(CODE_STORAGE_PATH)

	if(!fexists(json_file))
		return
	GLOB.stored_codes = json_decode(file2text(json_file))


/proc/generate_antag_token_code(no_logs = FALSE)
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose an antag token level to award", "Token Choice", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!choice)
		return
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = "[choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)
	reload_global_stored_codes()

	if(!no_logs)
		log_game("[usr] generated a new redemption code giving a [choice] Antag Token.")
		message_admins("[usr] generated a new redemption code giving a [choice] Antag Token.")
		to_chat(usr, span_big("Your generated code is: [string]"))
	return string


/proc/generate_bulk_redemption_code()
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose a code type", "Code generation", list("Coins", "Loadout Items", "Antag Tokens"))

	if(!choice)
		return
	var/amount = tgui_input_number(usr, "Choose a number", "Number", 1, 20, 0)
	if(!amount)
		return

	reload_global_stored_codes()
	var/list/generated_codes = list()
	for(var/num in 1 to amount)
		if(choice == "Coins")
			generated_codes += generate_coin_code(TRUE)
		else if(choice == "Loadout Items")
			generated_codes += generate_loadout_code(TRUE)
		else
			generated_codes += generate_antag_token_code(TRUE)

	log_game("[usr] generated [amount] new redemption codes.")
	message_admins("[usr] generated a new redemption codes.")
	var/connected_keys = generated_codes.Join(" ,")
	to_chat(usr, span_big("Your generated codes are: [connected_keys]"))
