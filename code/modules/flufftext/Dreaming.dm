/**
 * Begins the dreaming process on a sleeping carbon.
 *
 * Checks a 10% chance and whether or not the carbon this is called on is already dreaming. If
 * the prob() passes and there are no dream images left to display, a new dream is constructed.
 */

/mob/living/carbon/proc/handle_dreams()
	if(prob(10) && !dreaming)
		dream()

/**
 * Generates a dream sequence to be displayed to the sleeper.
 *
 * Generates the "dream" to display to the sleeper. A dream consists of a subject, a verb, and (most of the time) an object, displayed in sequence to the sleeper.
 * Dreams are generated as a list of strings stored inside dream_fragments, which is passed to and displayed in dream_sequence().
 * Bedsheets on the sleeper will provide a custom subject for the dream, pulled from the dream_messages on each bedsheet.
 */

/mob/living/carbon/proc/dream()
	set waitfor = FALSE
	var/list/dream_fragments = list()
	var/list/custom_dream_nouns = list()
	var/fragment = ""

	for(var/obj/item/bedsheet/sheet in loc)
		custom_dream_nouns += sheet.dream_messages

	dream_fragments += "you see"

	//Subject
	if(custom_dream_nouns.len && prob(90))
		fragment += pick(custom_dream_nouns)
	else
		fragment += pick(GLOB.dream_strings)

	if(prob(50)) //Replace the adjective space with an adjective, or just get rid of it
		fragment = replacetext(fragment, "%ADJECTIVE%", pick(GLOB.adjectives))
	else
		fragment = replacetext(fragment, "%ADJECTIVE% ", "")
	if(findtext(fragment, "%A% "))
		fragment = "\a [replacetext(fragment, "%A% ", "")]"
	dream_fragments += fragment

	//Verb
	fragment = ""
	if(prob(50))
		if(prob(35))
			fragment += "[pick(GLOB.adverbs)] "
		fragment += pick(GLOB.ing_verbs)
	else
		fragment += "will "
		fragment += pick(GLOB.verbs)
	dream_fragments += fragment

	if(prob(25))
		dream_sequence(dream_fragments)
		return

	//Object
	fragment = ""
	fragment += pick(GLOB.dream_strings)
	if(prob(50))
		fragment = replacetext(fragment, "%ADJECTIVE%", pick(GLOB.adjectives))
	else
		fragment = replacetext(fragment, "%ADJECTIVE% ", "")
	if(findtext(fragment, "%A% "))
		fragment = "\a [replacetext(fragment, "%A% ", "")]"
	dream_fragments += fragment

	dreaming = TRUE
	dream_sequence(dream_fragments)

/**
 * Displays the passed list of dream fragments to a sleeping carbon.
 *
 * Displays the first string of the passed dream fragments, then either ends the dream sequence
 * or performs a callback on itself depending on if there are any remaining dream fragments to display.
 *
 * Arguments:
 * * dream_fragments - A list of strings, in the order they will be displayed.
 */

/mob/living/carbon/proc/dream_sequence(list/dream_fragments)
	if(stat != UNCONSCIOUS || HAS_TRAIT(src, TRAIT_CRITICAL_CONDITION))
		dreaming = FALSE
		return
	var/next_message = dream_fragments[1]
	dream_fragments.Cut(1,2)
	to_chat(src, span_notice("<i>... [next_message] ...</i>"))
	if(LAZYLEN(dream_fragments))
		addtimer(CALLBACK(src, PROC_REF(dream_sequence), dream_fragments), rand(10,30))
	else
		dreaming = FALSE
