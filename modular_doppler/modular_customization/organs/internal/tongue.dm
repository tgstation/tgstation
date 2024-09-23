/// Dog tongue
//
/obj/item/organ/internal/tongue/dog
	name = "dog tongue"
	desc = "A fleshy muscle mostly used for barking."
	say_mod = "barks"

/// Bird tongue
//
/obj/item/organ/internal/tongue/bird
	name = "bird tongue"
	desc = "A fleshy muscle mostly used for chirping."
	say_mod = "chirps"

/obj/item/organ/internal/tongue/bird/Insert(mob/living/carbon/speaker, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	speaker.verb_ask = "peeps"
	speaker.verb_exclaim = "squawks"
	speaker.verb_whisper = "murmurs"
	speaker.verb_yell = "shrieks"

/obj/item/organ/internal/tongue/bird/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)

/// Mouse tongue
//
/obj/item/organ/internal/tongue/mouse
	name = "mouse tongue"
	desc = "A fleshy muscle mostly used for squeaking."
	say_mod = "squeaks"

/// Fish tongue
//
/obj/item/organ/internal/tongue/fish
	name = "fish tongue"
	desc = "A fleshy muscle mostly used for gnashing."
	say_mod = "gnashes"

/// Monkey tongue
//
/obj/item/organ/internal/tongue/monkey
