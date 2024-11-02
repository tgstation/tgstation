GLOBAL_LIST_EMPTY(ru_attack_verbs)
GLOBAL_LIST_EMPTY(ru_eat_verbs)
GLOBAL_LIST_EMPTY(ru_say_verbs)

/datum/modpack/translations
	name = "Переводы"
	desc = "Добавляет переводы"
	author = "Vallat, Larentoun, dj-34"

/datum/modpack/translations/post_initialize()
	var/toml_path = "[PATH_TO_TRANSLATE_DATA]/ru_verbs.toml"
	if(!fexists(file(toml_path)))
		return
	var/list/verbs_toml_list = rustg_read_toml_file(toml_path)

	var/list/attack_verbs = verbs_toml_list["attack_verbs"]
	for(var/attack_key in attack_verbs)
		GLOB.ru_attack_verbs += list("[attack_key]" = attack_verbs[attack_key])

	var/list/eat_verbs = verbs_toml_list["eat_verbs"]
	for(var/eat_key in eat_verbs)
		GLOB.ru_eat_verbs += list("[eat_key]" = eat_verbs[eat_key])

	var/list/say_verbs = verbs_toml_list["say_verbs"]
	for(var/say_key in say_verbs)
		GLOB.ru_say_verbs += list("[say_key]" = say_verbs[say_key])
