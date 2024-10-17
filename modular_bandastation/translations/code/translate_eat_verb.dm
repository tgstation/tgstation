/proc/ru_eat_verb(eat_verb)
	var/static/list/eat_list = list(
		"bite" = "кусает",
		"chew" = "жуёт",
		"nibble" = "покусывает",
		"gnaw" = "грызёт",
		"gobble" = "пожирает",
		"chomp" = "лопает,")
	return eat_list[eat_verb] || eat_verb
