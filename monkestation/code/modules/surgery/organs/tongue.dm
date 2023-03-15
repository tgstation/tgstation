/obj/item/organ/tongue/monkey
	name = "monkey tongue"
	desc = "While similar size to a human's, this flat muscle makes it difficult to produce most sounds!"
	say_mod = "chimpers"
	modifies_speech = TRUE
	var/static/list/languages_possible_monkey = typecacheof(list(/datum/language/monkey)) //only capable of speaking chimp, must use translator to speak anything else

/obj/item/organ/tongue/monkey/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_monkey


