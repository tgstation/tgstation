/obj/item/organ/internal/tongue
	name = "tongue"
	desc = "A fleshy muscle mostly used for lying."
	icon_state = "tongue"
	visual = FALSE
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	attack_verb_continuous = list("licks", "slobbers", "slaps", "frenches", "tongues")
	attack_verb_simple = list("lick", "slobber", "slap", "french", "tongue")
	var/list/languages_possible
	var/list/languages_native //human mobs can speak with this languages without the accent (letters replaces)
	var/say_mod = null

	/// Whether the owner of this tongue can taste anything. Being set to FALSE will mean no taste feedback will be provided.
	var/sense_of_taste = TRUE

	var/taste_sensitivity = 15 // lower is more sensitive.
	var/modifies_speech = FALSE
	var/static/list/languages_possible_base = typecacheof(list(
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
		/datum/language/nekomimetic
	))

/obj/item/organ/internal/tongue/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base

/obj/item/organ/internal/tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(speech_args[SPEECH_LANGUAGE] in languages_native)
		return FALSE //no changes
	modify_speech(source, speech_args)

/obj/item/organ/internal/tongue/proc/modify_speech(datum/source, list/speech_args)
	return speech_args[SPEECH_MESSAGE]

/obj/item/organ/internal/tongue/Insert(mob/living/carbon/tongue_owner, special = FALSE, drop_if_replaced = TRUE)
	..()
	if(say_mod && tongue_owner.dna && tongue_owner.dna.species)
		tongue_owner.dna.species.say_mod = say_mod
	if (modifies_speech)
		RegisterSignal(tongue_owner, COMSIG_MOB_SAY, .proc/handle_speech)
	tongue_owner.UnregisterSignal(tongue_owner, COMSIG_MOB_SAY)

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
	if(say_mod && tongue_owner.dna && tongue_owner.dna.species)
		tongue_owner.dna.species.say_mod = initial(tongue_owner.dna.species.say_mod)
	UnregisterSignal(tongue_owner, COMSIG_MOB_SAY)
	tongue_owner.RegisterSignal(tongue_owner, COMSIG_MOB_SAY, /mob/living/carbon/.proc/handle_tongueless_speech)
	REMOVE_TRAIT(tongue_owner, TRAIT_AGEUSIA, ORGAN_TRAIT)
	// Carbons by default start with NO_TONGUE_TRAIT caused TRAIT_AGEUSIA
	ADD_TRAIT(tongue_owner, TRAIT_AGEUSIA, NO_TONGUE_TRAIT)

/obj/item/organ/internal/tongue/could_speak_language(language)
	return is_type_in_typecache(language, languages_possible)

/obj/item/organ/internal/tongue/get_availability(datum/species/owner_species)
	return !(NO_TONGUE in owner_species.species_traits)

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
	RegisterSignal(statue, COMSIG_PARENT_QDELETING, .proc/statue_destroyed)

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
		RegisterSignal(becoming_statue, COMSIG_MOVABLE_MOVED, .proc/human_left_statue)

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

/obj/item/organ/internal/tongue/fly
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon = 'icons/obj/medical/organs/fly_organs.dmi'
	say_mod = "buzzes"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	modifies_speech = TRUE
	languages_native = list(/datum/language/buzzwords)
	var/static/list/languages_possible_fly = typecacheof(list(
		/datum/language/common,
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
		/datum/language/buzzwords
	))

/obj/item/organ/internal/tongue/fly/modify_speech(datum/source, list/speech_args)
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
		message = replacetext(message, "s", "z")
		message = replacetext(message, "S", "Z")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/fly/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_fly

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
	var/static/list/languages_possible_alien = typecacheof(list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/draconic,
		/datum/language/monkey))

/obj/item/organ/internal/tongue/alien/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_alien

/obj/item/organ/internal/tongue/alien/modify_speech(datum/source, list/speech_args)
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
	var/static/list/languages_possible_skeleton = typecacheof(list(
		/datum/language/common,
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
		/datum/language/calcic
	))

/obj/item/organ/internal/tongue/bone/Initialize(mapload)
	. = ..()
	phomeme_type = pick(phomeme_types)
	languages_possible = languages_possible_skeleton

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
	var/static/list/languages_possible_ethereal = typecacheof(list(
		/datum/language/common,
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
		/datum/language/voltaic
	))

/obj/item/organ/internal/tongue/ethereal/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_ethereal

/// Defines used to determine whether a sign language user can sign or not, and if not, why they cannot.
#define SIGN_OKAY 0
#define SIGN_ONE_HAND 1
#define SIGN_HANDS_FULL 2
#define SIGN_ARMLESS 3
#define SIGN_ARMS_DISABLED 4
#define SIGN_TRAIT_BLOCKED 5
#define SIGN_CUFFED 6

#define HANDS_PER_HANDCUFF 2

//Sign Language Tongue - yep, that's how you speak sign language.
/obj/item/organ/internal/tongue/tied
	name = "tied tongue"
	desc = "If only one had a sword so we may finally untie this knot."
	say_mod = "signs"
	icon_state = "tonguetied"
	modifies_speech = TRUE
	// The tonal indicator shown when we finish sending a message. If it's empty, none appears.
	var/tonal_indicator = null
	// The timerid for our tonal indicator
	var/tonal_timerid

/obj/item/organ/internal/tongue/tied/Insert(mob/living/carbon/signer, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	signer.verb_ask = "signs"
	signer.verb_exclaim = "signs"
	signer.verb_whisper = "subtly signs"
	signer.verb_sing = "rythmically signs"
	signer.verb_yell = "emphatically signs"
	signer.bubble_icon = "signlang"
	ADD_TRAIT(signer, TRAIT_SIGN_LANG, ORGAN_TRAIT)
	RegisterSignal(signer, COMSIG_LIVING_TRY_SPEECH, .proc/on_speech_check)
	RegisterSignal(signer, COMSIG_LIVING_TREAT_MESSAGE, .proc/on_treat_message)
	RegisterSignal(signer, COMSIG_MOVABLE_USING_RADIO, .proc/on_use_radio)

/obj/item/organ/internal/tongue/tied/Remove(mob/living/carbon/speaker, special = FALSE)
	. = ..()
	speaker.verb_ask = initial(speaker.verb_ask)
	speaker.verb_exclaim = initial(speaker.verb_exclaim)
	speaker.verb_whisper = initial(speaker.verb_whisper)
	speaker.verb_sing = initial(speaker.verb_sing)
	speaker.verb_yell = initial(speaker.verb_yell)
	speaker.bubble_icon = initial(speaker.bubble_icon)
	REMOVE_TRAIT(speaker, TRAIT_SIGN_LANG, ORGAN_TRAIT)
	UnregisterSignal(speaker, list(COMSIG_LIVING_TRY_SPEECH, COMSIG_LIVING_TREAT_MESSAGE, COMSIG_MOVABLE_USING_RADIO))

/// Signal proc for [COMSIG_LIVING_TRY_SPEECH]
/// Sign languagers can always speak regardless of they're mute (as long as they're not mimes)
/obj/item/organ/internal/tongue/tied/proc/on_speech_check(mob/living/source, message, ignore_spam, forced)
	SIGNAL_HANDLER

	if(source.mind?.miming)
		to_chat(source, span_green("You stop yourself from signing in favor of the artform of mimery!"))
		return COMPONENT_CANNOT_SPEAK

	switch(check_signables_state())
		if(SIGN_HANDS_FULL) // Full hands
			source.visible_message("tries to sign, but can't with [source.p_their()] hands full!", visible_message_flags = EMOTE_MESSAGE)
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_CUFFED) // Restrained
			source.visible_message("tries to sign, but can't with [source.p_their()] hands bound!", visible_message_flags = EMOTE_MESSAGE)
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_ARMLESS) // No arms
			to_chat(source, span_warning("You can't sign with no hands!"))
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_ARMS_DISABLED) // Arms but they're disabled
			to_chat(source, span_warning("Your can't sign with your hands right now!"))
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_TRAIT_BLOCKED) // Hands blocked or emote mute
			to_chat(source, span_warning("You can't sign at the moment!"))
			return COMPONENT_CANNOT_SPEAK

	// Assuming none of the above fail, sign language users can speak
	// regardless of being muzzled or mute toxin'd or whatever.
	return COMPONENT_CAN_ALWAYS_SPEAK

/// Signal proc for [COMSIG_LIVING_TREAT_MESSAGE] that stars out our message if we only have 1 hand free
/obj/item/organ/internal/tongue/tied/proc/on_treat_message(mob/living/source, list/message_args)
	SIGNAL_HANDLER

	if(check_signables_state() == SIGN_ONE_HAND)
		message_args[TREAT_MESSAGE_MESSAGE] = stars(message_args[TREAT_MESSAGE_MESSAGE])

/// Signal proc for [COMSIG_MOVABLE_USING_RADIO] that disallows us from speaking on comms if we don't have the special trait
/// Being unable to sign, or having our message be starred out, is handled by the above two signal procs.
/obj/item/organ/internal/tongue/tied/proc/on_use_radio(atom/movable/source, obj/item/radio/radio)
	SIGNAL_HANDLER

	return HAS_TRAIT(source, TRAIT_CAN_SIGN_ON_COMMS) ? NONE : COMPONENT_CANNOT_USE_RADIO

/// Checks to see what state this person is in and if they are able to sign or not.
/obj/item/organ/internal/tongue/tied/proc/check_signables_state()
	if(!owner)
		CRASH("[type] called check_signables_state without an owner.")

	// See how many hands we can actually use (this counts disabled / missing limbs for us)
	var/total_hands = owner.usable_hands
	// Look ma, no hands!
	if(total_hands <= 0)
		// Either our hands are still attached (just disabled) or they're gone entirely
		return owner.num_hands > 0 ? SIGN_ARMS_DISABLED : SIGN_ARMLESS

	// Now let's see how many of our hands is holding something
	var/busy_hands = 0
	// Yes held_items can contain null values, which represents empty hands,
	// I'm just saving myself a variable cast by using as anything
	for(var/obj/item/held_item as anything in owner.held_items)
		// items like slappers/zombie claws/etc. should be ignored
		if(isnull(held_item) || held_item.item_flags & HAND_ITEM)
			continue

		busy_hands++

	// Handcuffed or otherwise restrained - can't talk
	if(HAS_TRAIT(owner, TRAIT_RESTRAINED))
		return SIGN_CUFFED
	// Some other trait preventing us from using our hands now
	else if(HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(owner, TRAIT_EMOTEMUTE))
		return SIGN_TRAIT_BLOCKED

	// Okay let's compare the total hands to the number of busy hands
	// to see how many we have left to use for signing right now
	var/actually_usable_hands = total_hands - busy_hands
	if(actually_usable_hands <= 0)
		return SIGN_HANDS_FULL
	if(actually_usable_hands == 1)
		return SIGN_ONE_HAND

	return SIGN_OKAY

//Thank you Jwapplephobia for helping me with the literal hellcode below //Shoutout to Jwapplephobia
/obj/item/organ/internal/tongue/tied/modify_speech(datum/source, list/speech_args)
	// The message we send instead of our normal one
	var/new_message
	// The original message
	var/message = speech_args[SPEECH_MESSAGE]
	// Is there a !
	var/exclamation_found = findtext(message, "!")
	// Is there a ?
	var/question_found = findtext(message, "?")
	new_message = message
	if(exclamation_found)
		new_message = replacetext(new_message, "!", ".")
	if(question_found)
		new_message = replacetext(new_message, "?", ".")
	speech_args[SPEECH_MESSAGE] = new_message

	// Cut our last overlay before we replace it
	if(timeleft(tonal_timerid) > 0)
		remove_tonal_indicator()
		deltimer(tonal_timerid)
	// Prioritize questions
	if(question_found)
		tonal_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "signlang1", TYPING_LAYER)
		owner.visible_message(span_notice("[owner] lowers [owner.p_their()] eyebrows."))
	else if(exclamation_found)
		tonal_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "signlang2", TYPING_LAYER)
		owner.visible_message(span_notice("[owner] raises [owner.p_their()] eyebrows."))
	// If either an exclamation or question are found
	if(!isnull(tonal_indicator) && owner.client?.typing_indicators)
		owner.add_overlay(tonal_indicator)
		tonal_timerid = addtimer(CALLBACK(src, .proc/remove_tonal_indicator), 2.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE | TIMER_DELETE_ME)
	else // If we're not gonna use it, just be sure we get rid of it
		tonal_indicator = null

/obj/item/organ/internal/tongue/tied/proc/remove_tonal_indicator()
	if(isnull(tonal_indicator))
		return
	owner.cut_overlay(tonal_indicator)
	tonal_indicator = null

#undef SIGN_OKAY
#undef SIGN_ONE_HAND
#undef SIGN_HANDS_FULL
#undef SIGN_ARMLESS
#undef SIGN_TRAIT_BLOCKED
#undef SIGN_CUFFED

#undef HANDS_PER_HANDCUFF
