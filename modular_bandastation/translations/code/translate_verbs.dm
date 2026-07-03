// MARK: Attack
GLOBAL_LIST_INIT(ru_attack_verbs_unarmed, list(
	// unarmed_attack_verbs
	"slash" = "режет",
	"bump" = "ударяет",
	"bite" = "кусает",
	"chomp" = "грызет",
	"punch" = "бьет",
	"kick" = "пинает",
	"burn" = "жгет",
	"sear" = "обжигает",
	"scratch" = "царапает",
	"claw" = "скребет",
	"slap" = "шлепает",
	"lash" = "стегает",
	// grappled_attack_verb
	"pummel" = "колотит",
	"lacerate" = "раздирает",
	"scorch" = "выжигает",
))

/proc/ru_attack_verb(attack_verb, list/override)
	var/list/list_to_use = override || GLOB.ru_attack_verbs
	return list_to_use[attack_verb] || attack_verb

// MARK: Eat
/proc/ru_eat_verb(eat_verb)
	return GLOB.ru_eat_verbs[eat_verb] || eat_verb

// MARK: Say
/proc/ru_say_verb(say_verb)
	return GLOB.ru_say_verbs[say_verb] || say_verb

/atom/movable/say_mod(input, list/message_mods)
	. = ..()
	return ru_say_verb(.)

/mob/living/say_mod(input, list/message_mods)
	. = ..()
	return ru_say_verb(.)

/obj/machinery/requests_console/say_mod(input, list/message_mods)
	. = ..()
	return ru_say_verb(.)
