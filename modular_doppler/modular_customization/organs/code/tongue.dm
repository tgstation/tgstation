/// Bug tongue
//
/obj/item/organ/tongue/bug
	name = "bug tongue"
	desc = "A fleshy muscle mostly used for chittering."
	icon = 'icons/obj/medical/organs/fly_organs.dmi'
	say_mod = "chitters"

/// Cat tongue
//
/obj/item/organ/tongue/cat/Insert(mob/living/carbon/signer, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	signer.verb_ask = "mrrps"
	signer.verb_exclaim = "mrrowls"
	signer.verb_whisper = "purrs"
	signer.verb_yell = "yowls"

/obj/item/organ/tongue/cat/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)

/// Dog tongue
//
/obj/item/organ/tongue/dog
	name = "dog tongue"
	desc = "A fleshy muscle mostly used for barking."
	say_mod = "woofs"

/obj/item/organ/tongue/dog/Insert(mob/living/carbon/signer, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	signer.verb_ask = "arfs"
	signer.verb_exclaim = "wans"
	signer.verb_whisper = "whimpers"
	signer.verb_yell = "barks"
	if(!ishuman(signer))
		return // Only humans have DNA
	signer.dna.add_mutation(/datum/mutation/human/olfaction, MUT_NORMAL)
	signer.dna.activate_mutation(/datum/mutation/human/olfaction)
	for(var/datum/mutation/human/olfaction/sneef in signer.dna.mutations)
		sneef.mutadone_proof = TRUE

/obj/item/organ/tongue/dog/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)
	if(ishuman(speaker))
		speaker.dna.remove_mutation(/datum/mutation/human/olfaction)

/// Bird tongue
//
/obj/item/organ/tongue/bird
	name = "bird tongue"
	desc = "A fleshy muscle mostly used for chirping."
	say_mod = "chirps"

/obj/item/organ/tongue/bird/Insert(mob/living/carbon/speaker, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	speaker.verb_ask = "peeps"
	speaker.verb_exclaim = "squawks"
	speaker.verb_whisper = "murmurs"
	speaker.verb_yell = "shrieks"

/obj/item/organ/tongue/bird/Remove(mob/living/carbon/speaker, special = FALSE, movement_flags)
	. = ..()
	speaker.verb_ask = initial(verb_ask)
	speaker.verb_exclaim = initial(verb_exclaim)
	speaker.verb_whisper = initial(verb_whisper)
	speaker.verb_yell = initial(verb_yell)

/// Mouse tongue
//
/obj/item/organ/tongue/mouse
	name = "mouse tongue"
	desc = "A fleshy muscle mostly used for squeaking."
	say_mod = "squeaks"

/// Fish tongue
//
/obj/item/organ/tongue/fish
	name = "fish tongue"
	desc = "A fleshy muscle mostly used for gnashing."
	say_mod = "gnashes"

/// Frog tongue
//
/obj/item/organ/tongue/frog
	name = "frog tongue"
	desc = "A fleshy muscle mostly used for ribbiting."
	say_mod = "ribbits"
