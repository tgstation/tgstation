/obj/item/organ/internal/tongue
	name = "tongue"
	desc = "A fleshy muscle mostly used for lying."
	icon_state = "tongue"
	visual = FALSE
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	attack_verb_continuous = list("licks", "slobbers", "slaps", "frenches", "tongues")
	attack_verb_simple = list("lick", "slobber", "slap", "french", "tongue")
	/**
	 * A cached list of paths of all the languages this tongue is capable of speaking
	 *
	 * Relates to a mob's ability to speak a language - a mob must be able to speak the language
	 * and have a tongue able to speak the language (or omnitongue) in order to actually speak said language
	 *
	 * To modify this list for subtypes, see [/obj/item/organ/internal/tongue/proc/get_possible_languages]. Do not modify directly.
	 */
	VAR_PRIVATE/list/languages_possible
	/**
	 * A list of languages which are native to this tongue
	 *
	 * When these languages are spoken with this tongue, and modifies speech is true, no modifications will be made
	 * (such as no accent, hissing, or whatever)
	 */
	var/list/languages_native
	///changes the verbage of how you speak. (Permille -> says <-, "I just used a verb!")
	///i hate to say it, but because of sign language, this may have to be a component. and we may have to do some insane shit like putting a component on a component
	var/say_mod = "says"
	///for temporary overrides of the above variable.
	var/temp_say_mod = ""

	/// Whether the owner of this tongue can taste anything. Being set to FALSE will mean no taste feedback will be provided.
	var/sense_of_taste = TRUE
	/// Determines how "sensitive" this tongue is to tasting things, lower is more sensitive.
	/// See [/mob/living/proc/get_taste_sensitivity].
	var/taste_sensitivity = 15
	/// Whether this tongue modifies speech via signal
	var/modifies_speech = FALSE

/obj/item/organ/internal/tongue/Initialize(mapload)
	. = ..()
	// Setup the possible languages list
	// - get_possible_languages gives us a list of language paths
	// - then we cache it via string list
	// this results in tongues with identical possible languages sharing a cached list instance
	languages_possible = string_list(get_possible_languages())

/**
 * Used in setting up the "languages possible" list.
 *
 * Override to have your tongue be only capable of speaking certain languages
 * Extend to hvae a tongue capable of speaking additional languages to the base tongue
 *
 * While a user may be theoretically capable of speaking a language, they cannot physically speak it
 * UNLESS they have a tongue with that language possible, UNLESS UNLESS they have omnitongue enabled.
 */
/obj/item/organ/internal/tongue/proc/get_possible_languages()
	RETURN_TYPE(/list)
	// This is the default list of languages most humans should be capable of speaking
	return list(
		/datum/language/common,
		/datum/language/uncommon,
		/datum/language/draconic,
		/datum/language/codespeak,
		/datum/language/monkey,
		/datum/language/narsie,
		/datum/language/beachbum,
		/datum/language/aphasia,
		/datum/language/piratespeak,
		/datum/language/moffic,
		/datum/language/sylvan,
		/datum/language/shadowtongue,
		/datum/language/terrum,
		/datum/language/nekomimetic,
	)

/obj/item/organ/internal/tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(speech_args[SPEECH_LANGUAGE] in languages_native)
		return FALSE //no changes
	modify_speech(source, speech_args)

/obj/item/organ/internal/tongue/proc/modify_speech(datum/source, list/speech_args)
	return speech_args[SPEECH_MESSAGE]

/obj/item/organ/internal/tongue/Insert(mob/living/carbon/tongue_owner, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	ADD_TRAIT(tongue_owner, TRAIT_SPEAKS_CLEARLY, SPEAKING_FROM_TONGUE)
	if (modifies_speech)
		RegisterSignal(tongue_owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

	/* This could be slightly simpler, by making the removal of the
	* NO_TONGUE_TRAIT conditional on the tongue's `sense_of_taste`, but
	* then you can distinguish between ageusia from no tongue, and
	* ageusia from having a non-tasting tongue.
	*/
	REMOVE_TRAIT(tongue_owner, TRAIT_AGEUSIA, NO_TONGUE_TRAIT)
	if(!sense_of_taste)
		ADD_TRAIT(tongue_owner, TRAIT_AGEUSIA, ORGAN_TRAIT)

/obj/item/organ/internal/tongue/Remove(mob/living/carbon/tongue_owner, special = FALSE)
	. = ..()
	REMOVE_TRAIT(tongue_owner, TRAIT_SPEAKS_CLEARLY, SPEAKING_FROM_TONGUE)
	temp_say_mod = ""
	UnregisterSignal(tongue_owner, COMSIG_MOB_SAY)
	REMOVE_TRAIT(tongue_owner, TRAIT_AGEUSIA, ORGAN_TRAIT)
	// Carbons by default start with NO_TONGUE_TRAIT caused TRAIT_AGEUSIA
	ADD_TRAIT(tongue_owner, TRAIT_AGEUSIA, NO_TONGUE_TRAIT)

/obj/item/organ/internal/tongue/could_speak_language(datum/language/language_path)
	return (language_path in languages_possible)

/obj/item/organ/internal/tongue/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutanttongue

/obj/item/organ/internal/tongue/lizard
	name = "forked tongue"
	desc = "A thin and long muscle typically found in reptilian races, apparently moonlights as a nose."
	icon_state = "tonguelizard"
	say_mod = "hisses"
	taste_sensitivity = 10 // combined nose + tongue, extra sensitive
	modifies_speech = TRUE
	languages_native = list(/datum/language/draconic)

/obj/item/organ/internal/tongue/lizard/modify_speech(datum/source, list/speech_args)
	var/static/regex/lizard_hiss = new("s+", "g")
	var/static/regex/lizard_hiSS = new("S+", "g")
	var/static/regex/lizard_kss = new(@"(\w)x", "g")
	var/static/regex/lizard_kSS = new(@"(\w)X", "g")
	var/static/regex/lizard_ecks = new(@"\bx([\-|r|R]|\b)", "g")
	var/static/regex/lizard_eckS = new(@"\bX([\-|r|R]|\b)", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
		message = lizard_kss.Replace(message, "$1kss")
		message = lizard_kSS.Replace(message, "$1KSS")
		message = lizard_ecks.Replace(message, "ecks$1")
		message = lizard_eckS.Replace(message, "ECKS$1")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/lizard/silver
	name = "silver tongue"
	desc = "A genetic branch of the high society Silver Scales that gives them their silverizing properties. To them, it is everything, and society traitors have their tongue forcibly revoked. Oddly enough, it itself is just blue."
	icon_state = "silvertongue"
	actions_types = list(/datum/action/item_action/organ_action/statue)

/datum/action/item_action/organ_action/statue
	name = "Become Statue"
	desc = "Become an elegant silver statue. Its durability and yours are directly tied together, so make sure you're careful."
	COOLDOWN_DECLARE(ability_cooldown)

	var/obj/structure/statue/custom/statue

/datum/action/item_action/organ_action/statue/New(Target)
	. = ..()
	statue = new
	RegisterSignal(statue, COMSIG_PARENT_QDELETING, PROC_REF(statue_destroyed))

/datum/action/item_action/organ_action/statue/Destroy()
	UnregisterSignal(statue, COMSIG_PARENT_QDELETING)
	QDEL_NULL(statue)
	. = ..()

/datum/action/item_action/organ_action/statue/Trigger(trigger_flags)
	. = ..()
	if(!iscarbon(owner))
		to_chat(owner, span_warning("Your body rejects the powers of the tongue!"))
		return
	var/mob/living/carbon/becoming_statue = owner
	if(becoming_statue.health < 1)
		to_chat(becoming_statue, span_danger("You are too weak to become a statue!"))
		return
	if(!COOLDOWN_FINISHED(src, ability_cooldown))
		to_chat(becoming_statue, span_warning("You just used the ability, wait a little bit!"))
		return
	var/is_statue = becoming_statue.loc == statue
	to_chat(becoming_statue, span_notice("You begin to [is_statue ? "break free from the statue" : "make a glorious pose as you become a statue"]!"))
	if(!do_after(becoming_statue, (is_statue ? 5 : 30), target = get_turf(becoming_statue)))
		to_chat(becoming_statue, span_warning("Your transformation is interrupted!"))
		COOLDOWN_START(src, ability_cooldown, 3 SECONDS)
		return
	COOLDOWN_START(src, ability_cooldown, 10 SECONDS)

	if(statue.name == initial(statue.name)) //statue has not been set up
		statue.name = "statue of [becoming_statue.real_name]"
		statue.desc = "statue depicting [becoming_statue.real_name]"
		statue.set_custom_materials(list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT*5))

	if(is_statue)
		statue.visible_message(span_danger("[statue] becomes animated!"))
		becoming_statue.forceMove(get_turf(statue))
		statue.moveToNullspace()
		UnregisterSignal(becoming_statue, COMSIG_MOVABLE_MOVED)
	else
		becoming_statue.visible_message(span_notice("[becoming_statue] hardens into a silver statue."), span_notice("You have become a silver statue!"))
		statue.set_visuals(becoming_statue.appearance)
		statue.forceMove(get_turf(becoming_statue))
		becoming_statue.forceMove(statue)
		statue.update_integrity(becoming_statue.health)
		RegisterSignal(becoming_statue, COMSIG_MOVABLE_MOVED, PROC_REF(human_left_statue))

	//somehow they used an exploit/teleportation to leave statue, lets clean up
/datum/action/item_action/organ_action/statue/proc/human_left_statue(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER

	statue.moveToNullspace()
	UnregisterSignal(mover, COMSIG_MOVABLE_MOVED)

/datum/action/item_action/organ_action/statue/proc/statue_destroyed(datum/source)
	SIGNAL_HANDLER

	to_chat(owner, span_userdanger("Your existence as a living creature snaps as your statue form crumbles!"))
	if(iscarbon(owner))
		//drop everything, just in case
		var/mob/living/carbon/dying_carbon = owner
		for(var/obj/item/dropped in dying_carbon)
			if(!dying_carbon.dropItemToGround(dropped))
				qdel(dropped)
	qdel(owner)

/obj/item/organ/internal/tongue/abductor
	name = "superlingual matrix"
	desc = "A mysterious structure that allows for instant communication between users. Pretty impressive until you need to eat something."
	icon_state = "tongueayylmao"
	say_mod = "gibbers"
	sense_of_taste = FALSE
	modifies_speech = TRUE
	var/mothership

/obj/item/organ/internal/tongue/abductor/attack_self(mob/living/carbon/human/tongue_holder)
	if(!istype(tongue_holder))
		return

	var/obj/item/organ/internal/tongue/abductor/tongue = tongue_holder.getorganslot(ORGAN_SLOT_TONGUE)
	if(!istype(tongue))
		return

	if(tongue.mothership == mothership)
		to_chat(tongue_holder, span_notice("[src] is already attuned to the same channel as your own."))

	tongue_holder.visible_message(span_notice("[tongue_holder] holds [src] in their hands, and concentrates for a moment."), span_notice("You attempt to modify the attenuation of [src]."))
	if(do_after(tongue_holder, delay=15, target=src))
		to_chat(tongue_holder, span_notice("You attune [src] to your own channel."))
		mothership = tongue.mothership

/obj/item/organ/internal/tongue/abductor/examine(mob/examining_mob)
	. = ..()
	if(HAS_TRAIT(examining_mob, TRAIT_ABDUCTOR_TRAINING) || (examining_mob.mind && HAS_TRAIT(examining_mob.mind, TRAIT_ABDUCTOR_TRAINING)) || isobserver(examining_mob))
		. += span_notice("It can be attuned to a different channel by using it inhand.")
		if(!mothership)
			. += span_notice("It is not attuned to a specific mothership.")
		else
			. += span_notice("It is attuned to [mothership].")

/obj/item/organ/internal/tongue/abductor/modify_speech(datum/source, list/speech_args)
	//Hacks
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_abductor("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=SPECIES_ABDUCTOR)
	for(var/mob/living/carbon/human/living_mob in GLOB.alive_mob_list)
		var/obj/item/organ/internal/tongue/abductor/tongue = living_mob.getorganslot(ORGAN_SLOT_TONGUE)
		if(!istype(tongue))
			continue
		if(mothership == tongue.mothership)
			to_chat(living_mob, rendered)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/internal/tongue/zombie
	name = "rotting tongue"
	desc = "Between the decay and the fact that it's just lying there you doubt a tongue has ever seemed less sexy."
	icon_state = "tonguezombie"
	say_mod = "moans"
	modifies_speech = TRUE
	taste_sensitivity = 32

// List of english words that translate to zombie phrases
GLOBAL_LIST_INIT(english_to_zombie, list())

/obj/item/organ/internal/tongue/zombie/proc/add_word_to_translations(english_word, zombie_word)
	GLOB.english_to_zombie[english_word] = zombie_word
	// zombies don't care about grammar (any tense or form is all translated to the same word)
	GLOB.english_to_zombie[english_word + plural_s(english_word)] = zombie_word
	GLOB.english_to_zombie[english_word + "ing"] = zombie_word
	GLOB.english_to_zombie[english_word + "ed"] = zombie_word

/obj/item/organ/internal/tongue/zombie/proc/load_zombie_translations()
	var/list/zombie_translation = strings("zombie_replacement.json", "zombie")
	for(var/zombie_word in zombie_translation)
		// since zombie words are a reverse list, we gotta do this backwards
		var/list/data = islist(zombie_translation[zombie_word]) ? zombie_translation[zombie_word] : list(zombie_translation[zombie_word])
		for(var/english_word in data)
			add_word_to_translations(english_word, zombie_word)
	GLOB.english_to_zombie = sort_list(GLOB.english_to_zombie) // Alphabetizes the list (for debugging)

/obj/item/organ/internal/tongue/zombie/modify_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		// setup the global list for translation if it hasn't already been done
		if(!length(GLOB.english_to_zombie))
			load_zombie_translations()

		// make a list of all words that can be translated
		var/list/message_word_list = splittext(message, " ")
		var/list/translated_word_list = list()
		for(var/word in message_word_list)
			word = GLOB.english_to_zombie[lowertext(word)]
			translated_word_list += word ? word : FALSE

		// all occurrences of characters "eiou" (case-insensitive) are replaced with "r"
		message = replacetext(message, regex(@"[eiou]", "ig"), "r")
		// all characters other than "zhrgbmna .!?-" (case-insensitive) are stripped
		message = replacetext(message, regex(@"[^zhrgbmna.!?-\s]", "ig"), "")
		// multiple spaces are replaced with a single (whitespace is trimmed)
		message = replacetext(message, regex(@"(\s+)", "g"), " ")

		var/list/old_words = splittext(message, " ")
		var/list/new_words = list()
		for(var/word in old_words)
			// lower-case "r" at the end of words replaced with "rh"
			word = replacetext(word, regex(@"\lr\b"), "rh")
			// an "a" or "A" by itself will be replaced with "hra"
			word = replacetext(word, regex(@"\b[Aa]\b"), "hra")
			new_words += word

		// if words were not translated, then we apply our zombie speech patterns
		for(var/i in 1 to length(new_words))
			new_words[i] = translated_word_list[i] ? translated_word_list[i] : new_words[i]

		message = new_words.Join(" ")
		message = capitalize(message)
		speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/alien
	name = "alien tongue"
	desc = "According to leading xenobiologists the evolutionary benefit of having a second mouth in your mouth is \"that it looks badass\"."
	icon_state = "tonguexeno"
	say_mod = "hisses"
	taste_sensitivity = 10 // LIZARDS ARE ALIENS CONFIRMED
	modifies_speech = TRUE // not really, they just hiss

// Aliens can only speak alien and a few other languages.
/obj/item/organ/internal/tongue/alien/get_possible_languages()
	return list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/uncommon,
		/datum/language/draconic, // Both hiss?
		/datum/language/monkey,
	)

/obj/item/organ/internal/tongue/alien/modify_speech(datum/source, list/speech_args)
	var/datum/saymode/xeno/hivemind = speech_args[SPEECH_SAYMODE]
	if(hivemind)
		return

	playsound(owner, SFX_HISS, 25, TRUE, TRUE)

/obj/item/organ/internal/tongue/bone
	name = "bone \"tongue\""
	desc = "Apparently skeletons alter the sounds they produce through oscillation of their teeth, hence their characteristic rattling."
	icon_state = "tonguebone"
	say_mod = "rattles"
	attack_verb_continuous = list("bites", "chatters", "chomps", "enamelles", "bones")
	attack_verb_simple = list("bite", "chatter", "chomp", "enamel", "bone")
	sense_of_taste = FALSE
	modifies_speech = TRUE
	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/internal/tongue/bone/Initialize(mapload)
	. = ..()
	phomeme_type = pick(phomeme_types)

// Bone tongues can speak all default + calcic
/obj/item/organ/internal/tongue/bone/get_possible_languages()
	return ..() + /datum/language/calcic

/obj/item/organ/internal/tongue/bone/modify_speech(datum/source, list/speech_args)
	if (chattering)
		chatter(speech_args[SPEECH_MESSAGE], phomeme_type, source)
	switch(phomeme_type)
		if("sans")
			speech_args[SPEECH_SPANS] |= SPAN_SANS
		if("papyrus")
			speech_args[SPEECH_SPANS] |= SPAN_PAPYRUS

/obj/item/organ/internal/tongue/bone/plasmaman
	name = "plasma bone \"tongue\""
	desc = "Like animated skeletons, Plasmamen vibrate their teeth in order to produce speech."
	icon_state = "tongueplasma"
	modifies_speech = FALSE

/obj/item/organ/internal/tongue/robot
	name = "robotic voicebox"
	desc = "A voice synthesizer that can interface with organic lifeforms."
	status = ORGAN_ROBOTIC
	organ_flags = NONE
	icon_state = "tonguerobot"
	say_mod = "states"
	attack_verb_continuous = list("beeps", "boops")
	attack_verb_simple = list("beep", "boop")
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue

/obj/item/organ/internal/tongue/robot/can_speak_language(language)
	return TRUE // THE MAGIC OF ELECTRONICS

/obj/item/organ/internal/tongue/robot/modify_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/obj/item/organ/internal/tongue/snail
	name = "radula"
	color = "#96DB00" // TODO proper sprite, rather than recoloured pink tongue
	desc = "A minutely toothed, chitious ribbon, which as a side effect, makes all snails talk IINNCCRREEDDIIBBLLYY SSLLOOWWLLYY."
	modifies_speech = TRUE

/obj/item/organ/internal/tongue/snail/modify_speech(datum/source, list/speech_args)
	var/new_message
	var/message = speech_args[SPEECH_MESSAGE]
	for(var/i in 1 to length(message))
		if(findtext("ABCDEFGHIJKLMNOPWRSTUVWXYZabcdefghijklmnopqrstuvwxyz", message[i])) //Im open to suggestions
			new_message += message[i] + message[i] + message[i] //aaalllsssooo ooopppeeennn tttooo sssuuuggggggeeessstttiiiooonsss
		else
			new_message += message[i]
	speech_args[SPEECH_MESSAGE] = new_message

/obj/item/organ/internal/tongue/ethereal
	name = "electric discharger"
	desc = "A sophisticated ethereal organ, capable of synthesising speech via electrical discharge."
	icon_state = "electrotongue"
	say_mod = "crackles"
	taste_sensitivity = 10 // ethereal tongues function (very loosely) like a gas spectrometer: vaporising a small amount of the food and allowing it to pass to the nose, resulting in more sensitive taste
	attack_verb_continuous = list("shocks", "jolts", "zaps")
	attack_verb_simple = list("shock", "jolt", "zap")

// Ethereal tongues can speak all default + voltaic
/obj/item/organ/internal/tongue/ethereal/get_possible_languages()
	return ..() + /datum/language/voltaic

/obj/item/organ/internal/tongue/cat
	name = "felinid tongue"
	desc = "A fleshy muscle mostly used for meowing."
	say_mod = "meows"

/obj/item/organ/internal/tongue/bananium
	name = "bananium tongue"
	desc = "A bananium geode mostly used for honking."
	say_mod = "honks"

	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	icon_state = "gold_horn"

/obj/item/organ/internal/tongue/jelly
	name = "jelly tongue"
	desc = "Ah... That's not the sound I expected it to make. Sounds like a Space Autumn Bird."
	say_mod = "chirps"

/obj/item/organ/internal/tongue/monkey
	name = "primitive tongue"
	desc = "For aggressively chimpering. And consuming bananas."
	say_mod = "chimpers"

/obj/item/organ/internal/tongue/moth
	name = "moth tongue"
	desc = "Moths don't have tongues. Someone get god on the phone, tell them I'm not happy."
	say_mod = "flutters"

/obj/item/organ/internal/tongue/zombie
	name = "rotting tongue"
	desc = "Makes you speak like you're at the dentist and you just absolutely refuse to spit because you forgot to mention you were allergic to space shellfish."
	say_mod = "moans"

/obj/item/organ/internal/tongue/mush
	name = "mush-tongue-room"
	desc = "You poof with this. Got it?"
	say_mod = "poofs"

	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "mycelium-angel"
