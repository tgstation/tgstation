/obj/item/skillchip
	name = "skillchip"
	desc = "This biochip integrates with user's brain to enable mastery of specific skill. Consult certified Nanotrasen neurosurgeon before use."

	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "skillchip"
	custom_price = PAYCHECK_CREW * 3
	w_class = WEIGHT_CLASS_SMALL

	/// Traits automatically granted by this chip, optional. Lazylist.
	var/list/auto_traits
	/// Skill name shown on UI
	var/skill_name
	/// Skill description shown on UI
	var/skill_description
	/// Category string. Used alongside SKILLCHIP_RESTRICTED_CATEGORIES flag to make a chip incompatible with chips from another category.
	var/chip_category = SKILLCHIP_CATEGORY_GENERAL
	/// List of any incompatible categories.
	var/list/incompatibility_list
	/// Fontawesome icon show on UI, list of possible icons https://fontawesome.com/icons?d=gallery&m=free
	var/skill_icon = "brain"
	/// Message shown when activating the chip
	var/activate_message
	/// Message shown when deactivating the chip
	var/deactivate_message
	//If set to FALSE, trying to extract the chip will destroy it instead
	var/removable
	/// How complex the skillchip is. Brains can only handle so much complexity at once and skillchips will start to deactivate when the brain's complexity limit is exceeded.
	var/complexity = 1
	/// How many slots taken up in the brain by this chip. Max brain slots are hard set and should not be changed at all.
	var/slot_use = 1
	/// Variable for flags. DANGEROUS - Child types overwrite flags instead of adding to them. If you change this, make sure all child types have the appropriate flags set too.
	var/skillchip_flags = NONE
	/// Cooldown before the skillchip can be extracted after it has been implanted.
	var/cooldown = 5 MINUTES
	/// Cooldown for chip actions.
	COOLDOWN_DECLARE(chip_cooldown)
	/// Used to determine if this is an abstract type or not.
	/// If this is meant to be an abstract type, set it to the type's path.
	/// Will be overridden by subsequent abstract parents.
	var/abstract_parent_type = /obj/item/skillchip
	/// Set to TRUE when the skill chip's effects are applied. Set to FALSE when they're not.
	var/active = FALSE
	/// Brain that holds this skillchip.
	var/obj/item/organ/internal/brain/holding_brain

/obj/item/skillchip/Initialize(mapload, is_removable = TRUE)
	. = ..()
	removable = is_removable

/**
 * Activates the skillchip, if possible.
 *
 * Returns a message containing the reason if activation is not possible.
 * Arguments:
 * * silent - Boolean. Whether or not an activation message should be shown to the user.
 * * force - Boolean. Whether or not to just force de-activation if it would be prevented for any reason.
 */
/obj/item/skillchip/proc/try_activate_skillchip(silent = FALSE, force = FALSE)
	// Should not happen. Holding brain is destroyed and the chip hasn't had its state set appropriately.
	if(QDELETED(holding_brain))
		stack_trace("Skillchip's owner is null or qdeleted brain.")
		return "Skillchip cannot detect viable brain."

	// Also should not happen. We're somehow activating skillchips in a bodyless brain.
	if(QDELETED(holding_brain.owner))
		stack_trace("Skillchip's brain has no owner, owner is null or owner qdeleted.")
		return "Skillchip cannot detect viable body."

	// We have a holding brain, the holding brain has an owner. If we're forcing this, do it hard and fast.
	if(force)
		on_activate(holding_brain.owner, silent)
		return

	// Is the chip still experiencing a cooldown period?
	if(!COOLDOWN_FINISHED(src, chip_cooldown))
		return "Skillchip is still recharging for [COOLDOWN_TIMELEFT(src, chip_cooldown) * 0.1]s"

	// So, we have a brain and that brain has a body. Let's start checking for incompatibility.
	var/activate_msg = has_activate_incompatibility(holding_brain)

	// If there's an activate_msg it means we can't activate for some reason. Return the feedback message.
	if(activate_msg)
		return activate_msg

	// Either there's no incompatibility or we're forcing the activation. We're good to go!
	on_activate(holding_brain.owner, silent)

/**
 * Deactivates the skillchip, if possible.
 *
 * Returns a message containing the reason if deactivation is not possible.
 * Arguments:
 * * silent - Boolean. Whether or not an activation message should be shown to the user.
 * * force - Boolean. Whether or not to just force de-activation if it would be prevented for any reason.
 */
/obj/item/skillchip/proc/try_deactivate_skillchip(silent = FALSE, force = FALSE)
	if(!active)
		return "Skillchip is not active."

	// Should not happen. Holding brain is destroyed and the chip hasn't had its state set appropriately.
	if(!holding_brain)
		stack_trace("Skillchip's owner is null or qdeleted brain.")
		return "Skillchip cannot detect viable brain."

	// Also should not happen. We're somehow deactivating skillchips in a bodyless brain.
	if(QDELETED(holding_brain.owner))
		active = FALSE
		stack_trace("Skillchip's brain has no owner, owner is null or owner qdeleted.")
		return "Skillchip cannot detect viable body."

	// We have a holding brain, the holding brain has an owner. If we're forcing this, do it hard and fast.
	if(force)
		on_deactivate(holding_brain.owner, silent)
		return

	// Is the chip still experiencing a cooldown period?
	if(!COOLDOWN_FINISHED(src, chip_cooldown))
		return "Skillchip is still recharging for [COOLDOWN_TIMELEFT(src, chip_cooldown) * 0.1]s"

	// We're good to go. Deactive this chip.
	on_deactivate(holding_brain.owner, silent)

/**
 * Called when a skillchip is inserted in a user's brain.
 *
 * Arguments:
 * * owner_brain - The brain that this skillchip was implanted in to.
 */
/obj/item/skillchip/proc/on_implant(obj/item/organ/internal/brain/owner_brain)
	if(holding_brain)
		CRASH("Skillchip is trying to be implanted into [owner_brain], but it's already implanted in [holding_brain]")

	holding_brain = owner_brain

/**
 * Called when a skillchip is activated.
 *
 * Arguments:
 * * user - The user to apply skillchip effects to.
 * * silent - Boolean. Whether or not an activation message should be shown to the user.
 */
/obj/item/skillchip/proc/on_activate(mob/living/carbon/user, silent=FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!silent && activate_message)
		to_chat(user, activate_message)

	if(length(auto_traits))
		user.add_traits(auto_traits, SKILLCHIP_TRAIT)

	active = TRUE

	COOLDOWN_START(src, chip_cooldown, cooldown)

/**
 * Called when a skillchip is removed from the user's brain.
 *
 * Always deactivates the skillchip.
 * Arguments:
 * * user - The user to remove skillchip effects from.
 * * silent - Boolean. Whether or not a deactivation message should be shown to the user.
 */
/obj/item/skillchip/proc/on_removal(silent=FALSE)
	if(active)
		try_deactivate_skillchip(silent, TRUE)

	COOLDOWN_RESET(src, chip_cooldown)

	holding_brain = null

/**
 * Called when a skillchip is deactivated.
 *
 * Arguments:
 * * user - The user to remove skillchip effects from.
 * * silent - Boolean. Whether or not a deactivation message should be shown to the user.
 */
/obj/item/skillchip/proc/on_deactivate(mob/living/carbon/user, silent=FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!silent && deactivate_message)
		to_chat(user, deactivate_message)

	if(length(auto_traits))
		user.remove_traits(auto_traits, SKILLCHIP_TRAIT)

	active = FALSE

	COOLDOWN_START(src, chip_cooldown, cooldown)

/**
 * Checks whether a given skillchip has an incompatibility with a brain that should render it impossible
 * to activate.
 *
 * Returns a string with an explanation if the chip is not activatable. FALSE otherwise.
 * Arguments:
 * * skillchip - The skillchip you're intending to activate. Does not activate the chip.
 */
/obj/item/skillchip/proc/has_activate_incompatibility(obj/item/organ/internal/brain/brain)
	if(QDELETED(brain))
		return "No brain detected."

	// Check if there's enough complexity usage left to activate the skillchip.
	var/max_complexity = brain.get_max_skillchip_complexity()
	var/new_complexity = brain.get_used_skillchip_complexity() + get_complexity()
	if(new_complexity > max_complexity)
		return "Skillchip is too complex to activate: [new_complexity] total out of [max_complexity] max complexity."

	return FALSE


/**
 * Checks for skillchip incompatibility with another chip.
 *
 * Does *this* skillchip have incompatibility with the skillchip in the args?
 * Override this with any snowflake chip-vs-chip incompatibility checks.
 * Returns a string with an incompatibility explanation if the chip is not compatible, returns FALSE
 * if it is compatible.
 * Arguments:
 * * skillchip - The skillchip to test for incompatability.
 */
/obj/item/skillchip/proc/has_skillchip_incompatibility(obj/item/skillchip/skillchip)
	// Only allow multiple copies of a type if SKILLCHIP_ALLOWS_MULTIPLE flag is set
	if(!(skillchip_flags & SKILLCHIP_ALLOWS_MULTIPLE) && (skillchip.type == type))
		return "Duplicate chip detected: [skillchip.name]"

	// Prevent implanting multiple chips of the same category.
	if((skillchip_flags & SKILLCHIP_RESTRICTED_CATEGORIES) && (skillchip.chip_category in incompatibility_list))
		return "Incompatible with implanted [skillchip.chip_category] chip [skillchip.name]."

	return FALSE

/**
 * Performs a full sweep of checks that dictate if this chip can be implanted in a given target.
 *
 * Override this with any snowflake chip checks. An example of which would be checking if a target is
 * mindshielded if you've got a special security skillchip.
 * Returns a string with an incompatibility explanation if the chip is not compatible, returns FALSE
 * if it is compatible.
 * Arguments:
 * * target - The mob to check for implantability with.
 */
/obj/item/skillchip/proc/has_mob_incompatibility(mob/living/carbon/target)
	// No carbon/carbon of incorrect type
	if(!istype(target))
		return "Incompatible lifeform detected."

	// No brain
	var/obj/item/organ/internal/brain/brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return "No brain detected."

	// Check brain incompatibility. This also performs skillchip-to-skillchip incompatibility checks.
	var/brain_message = has_brain_incompatibility(brain)
	if(brain_message)
		return brain_message

	return FALSE

/**
 * Performs a full sweep of checks that dictate if this chip can be implanted in a given brain.
 *
 * Override this with any snowflake chip checks.
 * Returns TRUE if the chip is fully compatible, FALSE otherwise.
 * Arguments:
 * * brain - The brain to check for implantability with.
 */
/obj/item/skillchip/proc/has_brain_incompatibility(obj/item/organ/internal/brain/brain)
	if(!istype(brain))
		stack_trace("Attempted to check incompatibility with invalid brain object [brain].")
		return "Incompatible brain."

	var/chip_message

	// Slot capacity check!
	var/max_slots = brain.get_max_skillchip_slots()
	var/used_slots = brain.get_used_skillchip_slots()

	if(used_slots + slot_use > max_slots)
		return "Not enough free slots. You have [max_slots - used_slots] free and need [slot_use]."

	// Check if this chip is incompatible with any other chips in the brain.
	for(var/skillchip in brain.skillchips)
		chip_message = has_skillchip_incompatibility(skillchip)
		if(chip_message)
			return chip_message

	return FALSE

/**
 * Returns whether the chip is on cooldown. Chips ordinarily go on cooldown when activated.
 *
 * This does not mean the chip should be impossible to do anything with.
 * It's up to each individual piece of code to decide what it does with the result of this proc.
 *
 * Returns TRUE if the chip's extraction cooldown hasn't yet passed.
 */
/obj/item/skillchip/proc/is_on_cooldown()
	return !COOLDOWN_FINISHED(src, chip_cooldown)

/**
 * Returns whether the chip is active.
 *
 * Intended to be overriden.
 * Returns TRUE if the chip is active.
 */
/obj/item/skillchip/proc/is_active()
	return active

/**
 * Returns the chip's complexity.
 *
 * Intended to be overriden.
 */
/obj/item/skillchip/proc/get_complexity()
	return complexity

/**
 * Returns a list of basic chip info. Used by the skill station.
 */
/obj/item/skillchip/proc/get_chip_data()
	return list(
		"name" = skill_name,
		"icon" = skill_icon,
		"desc" = skill_description,
		"complexity" = get_complexity(),
		"slot_use" = slot_use,
		"removable" = removable,
		"ref" = REF(src),
		"active" = is_active(),
		"active_error" = has_activate_incompatibility(holding_brain),
		"cooldown" = COOLDOWN_TIMELEFT(src, chip_cooldown),
		"actionable" = is_on_cooldown())

/**
 * Gets key metadata from this skillchip in an assoc list.
 *
 * If you override this proc, don't forget to also override set_metadata, which takes the output of
 * this proc and uses it to set the metadata.
 * Does not copy over any owner or brain status. Handle that externally.
 */
/obj/item/skillchip/proc/get_metadata()
	var/list/metadata = list()
	metadata["type"] = type
	metadata["chip_cooldown"] = chip_cooldown
	metadata["active"] = active
	metadata["removable"] = removable

	return metadata

/**
 * Sets key metadata for this skillchip from an assoc list.
 *
 * Best used with the output from get_metadata() of another chip.
 * If you override this proc, don't forget to also override get_metadata, which is where you should
 * usually get the assoc list that feeds into this proc.
 * Does not set any owner or brain status. Handle that externally.
 * Arguments:
 * metadata - Ideally the output of another chip's get_metadata proc. Assoc list of metadata.
 */
/obj/item/skillchip/proc/set_metadata(list/metadata)
	var/active_msg
	// Start by trying to activate.
	active = metadata["active"]
	if(active)
		active_msg = try_activate_skillchip(FALSE, TRUE)

	// Whether it worked or not, set the rest of the metadata and then return any activate message.
	chip_cooldown = metadata["chip_cooldown"]
	removable = metadata["removable"]

	return active_msg

/obj/item/skillchip/basketweaving
	name = "Basketsoft 3000 skillchip"
	desc = "Underwater edition."
	auto_traits = list(TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE)
	skill_name = "Underwater Basketweaving"
	skill_description = "Master intricate art of using twine to create perfect baskets while submerged."
	skill_icon = "shopping-basket"
	activate_message = "<span class='notice'>You're one with the twine and the sea.</span>"
	deactivate_message = "<span class='notice'>Higher mysteries of underwater basketweaving leave your mind.</span>"

/obj/item/skillchip/wine_taster
	name = "WINE skillchip"
	desc = "Wine.Is.Not.Equal version 5."
	auto_traits = list(TRAIT_WINE_TASTER)
	skill_name = "Wine Tasting"
	skill_description = "Recognize wine vintage from taste alone. Never again lack an opinion when presented with an unknown drink."
	skill_icon = "wine-bottle"
	activate_message = "<span class='notice'>You recall wine taste.</span>"
	deactivate_message = "<span class='notice'>Your memories of wine evaporate.</span>"

/obj/item/skillchip/bonsai
	name = "Hedge 3 skillchip"
	auto_traits = list(TRAIT_BONSAI)
	skill_name = "Hedgetrimming"
	skill_description = "Trim hedges and potted plants into marvelous new shapes with any old knife. Not applicable to plastic plants."
	skill_icon = "spa"
	activate_message = "<span class='notice'>Your mind is filled with plant arrangments.</span>"
	deactivate_message = "<span class='notice'>You can't remember what a hedge looks like anymore.</span>"

/obj/item/skillchip/useless_adapter
	name = "Skillchip adapter"
	skill_name = "Useless adapter"
	skill_description = "Allows you to insert another skillchip into this adapter after it has been inserted into your brain..."
	skill_icon = "plug"
	activate_message = "<span class='notice'>You can now activate another chip through this adapter, but you're not sure why you did this...</span>"
	deactivate_message = "<span class='notice'>You no longer have the useless skillchip adapter.</span>"
	skillchip_flags = SKILLCHIP_ALLOWS_MULTIPLE
	// Literally does nothing.
	complexity = 0
	slot_use = 0

/obj/item/skillchip/light_remover
	name = "N16H7M4R3 skillchip"
	auto_traits = list(TRAIT_LIGHTBULB_REMOVER)
	skill_name = "Lightbulb Removing"
	skill_description = "Stop failing taking out lightbulbs today, no gloves needed!"
	skill_icon = "lightbulb"
	activate_message = "<span class='notice'>Your feel like your pain receptors are less sensitive to hot objects.</span>"
	deactivate_message = "<span class='notice'>You feel like hot objects could stop you again...</span>"

/obj/item/skillchip/disk_verifier
	name = "K33P-TH4T-D15K skillchip"
	auto_traits = list(TRAIT_DISK_VERIFIER)
	skill_name = "Nuclear Disk Verification"
	skill_description = "Nuclear authentication disks have an extremely long serial number for verification. This skillchip stores that number, which allows the user to automatically spot forgeries."
	skill_icon = "save"
	activate_message = "<span class='notice'>You feel your mind automatically verifying long serial numbers on disk shaped objects.</span>"
	deactivate_message = "<span class='notice'>The innate recognition of absurdly long disk-related serial numbers fades from your mind.</span>"

/obj/item/skillchip/entrails_reader
	name = "3NTR41LS skillchip"
	auto_traits = list(TRAIT_ENTRAILS_READER)
	skill_name = "Entrails Reader"
	skill_description = "Be able to learn about a person's life, by looking at their internal organs. Not to be confused with looking into the future."
	skill_icon = "lungs"
	activate_message = "<span class='notice'>You feel that you know a lot about interpreting organs.</span>"
	deactivate_message = "<span class='notice'>Knowledge of liver damage, heart strain and lung scars fades from your mind.</span>"

/obj/item/skillchip/appraiser
	name = "GENUINE ID Appraisal Now! skillchip"
	auto_traits = list(TRAIT_ID_APPRAISER)
	skill_name = "ID Appraisal"
	skill_description = "Appraise an ID and see if it's issued from centcom, or just a cruddy station-printed one."
	skill_icon = "magnifying-glass"
	activate_message = span_notice("You feel that you can recognize special, minute details on ID cards.")
	deactivate_message = span_notice("Was there something special about certain IDs?")

/obj/item/skillchip/sabrage
	name = "Le S48R4G3 skillchip"
	auto_traits = list(TRAIT_SABRAGE_PRO)
	skill_name = "Sabrage Proficiency"
	skill_description = "Grants the user knowledge of the intricate structure of a champagne bottle's structural weakness at the neck, \
	improving their proficiency at being a show-off at officer parties."
	skill_icon = "bottle-droplet"
	activate_message = span_notice("You feel a new understanding of champagne bottles and methods on how to remove their corks.")
	deactivate_message = span_notice("The knowledge of the subtle physics residing inside champagne bottles fades from your mind.")

/obj/item/skillchip/brainwashing
	name = "suspicious skillchip"
	auto_traits = list(TRAIT_BRAINWASHING)
	skill_name = "Brainwashing"
	skill_description = "WARNING: The integrity of this chip is compromised. Please discard this skillchip."
	skill_icon = "soap"
	activate_message = span_notice("...But all at once it comes to you... something involving putting a brain in a washing machine?")
	deactivate_message = span_warning("All knowledge of the secret brainwashing technique is GONE.")

/obj/item/skillchip/brainwashing/examine(mob/user)
	. = ..()
	. += span_warning("It seems to have been corroded over time, putting this in your head may not be the best idea...")

/obj/item/skillchip/brainwashing/on_activate(mob/living/carbon/user, silent = FALSE)
	to_chat(user, span_danger("You get a pounding headache as the chip sends corrupt memories into your head!"))
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
	. = ..()

/obj/item/skillchip/chefs_kiss
	name = "K1SS skillchip"
	auto_traits = list(TRAIT_CHEF_KISS)
	skill_name = "Chef's Kiss"
	skill_description = "Allows you to kiss food you've created to make them with love."
	skill_icon = "cookie"
	activate_message = span_notice("You recall learning from your grandmother how they baked their cookies with love.")
	deactivate_message = span_notice("You forget all memories imparted upon you by your grandmother. Were they even your real grandma?")

/obj/item/skillchip/master_angler
	name = "Mast-Angl-Er skillchip"
	auto_traits = list(TRAIT_REVEAL_FISH, TRAIT_EXAMINE_FISHING_SPOT, TRAIT_EXAMINE_FISH, TRAIT_EXAMINE_DEEPER_FISH)
	skill_name = "Fisherman's Discernment"
	skill_description = "Lists fishes when examining a fishing spot, gives a hint of whatever thing's biting the hook and more."
	skill_icon = "fish"
	activate_message = span_notice("You feel the knowledge and passion of several sunbaked, seasoned fishermen burn within you.")
	deactivate_message = span_notice("You no longer feel like casting a fishing rod by the sunny riverside.")

/obj/item/skillchip/intj
	name = "Integrated Intuitive Thinking and Judging skillchip"
	auto_traits = list(TRAIT_REMOTE_TASTING)
	skill_name = "Mental Flavour Calculus"
	skill_description = "When examining food, you can experience the flavours just as well as if you were eating it."
	skill_icon = FA_ICON_DRUMSTICK_BITE
	activate_message = span_notice("You think of your favourite food and realise that you can rotate its flavour in your mind.")
	deactivate_message = span_notice("You feel your food-based mind palace crumbling...")

/obj/item/skillchip/drunken_brawler
	name = "F0RC3 4DD1CT10N skillchip"
	auto_traits = list(TRAIT_DRUNKEN_BRAWLER)
	skill_name = "Drunken Unarmed Proficiency"
	skill_description = "When intoxicated, you gain increased unarmed effectiveness."
	skill_icon = "wine-bottle"
	activate_message = span_notice("You honestly could do with a drink. Never know when someone might try and jump you around here.")
	deactivate_message = span_notice("You suddenly feel a lot safer going around the station sober... ")

/obj/item/skillchip/musical
	name = "\improper Old Copy of \"Space Station 13: The Musical\""
	desc = "An old copy of \"Space Station 13: The Musical\", \
		ran on the station's 100th anniversary...Or maybe it was the 200th?"
	skill_name = "Memory of a Musical"
	skill_description = "Allows you to hit that high note, like those that came a century before us."
	skill_icon = FA_ICON_MUSIC
	activate_message = span_notice("You feel like you could \u2669 sing a soooong! \u266B")
	deactivate_message = span_notice("The musical fades from your mind, leaving you with a sense of nostalgia.")
	custom_premium_price = PAYCHECK_CREW * 4

/obj/item/skillchip/musical/Initialize(mapload, is_removable)
	. = ..()
	name = replacetext(name, "Old", round(CURRENT_STATION_YEAR - pick(50, 100, 150, 200, 250), 5))

/obj/item/skillchip/musical/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(make_music))

/obj/item/skillchip/musical/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_SAY)

/obj/item/skillchip/musical/proc/make_music(mob/living/carbon/source, list/say_args)
	SIGNAL_HANDLER

	var/raw_message = say_args[SPEECH_MESSAGE]
	var/list/words = splittext(raw_message, " ")
	if(length(words) <= 1)
		say_args[SPEECH_MODS][MODE_SING] = TRUE
		return
	var/last_word = words[length(words)]
	var/num_chars = length_char(last_word)
	var/last_vowel = ""
	// find the last vowel present in the word
	for(var/i in 1 to num_chars)
		var/char = copytext_char(last_word, i, i + 1)
		if(char in VOWELS)
			last_vowel = char

	// now we'll reshape the final word to make it sound like they're singing it
	var/final_word = ""
	var/has_ellipsis = copytext(last_word, -3) == "..."
	for(var/i in 1 to num_chars)
		var/char = copytext_char(last_word, i, i + 1)
		// replacing any final periods with exclamation marks (so long as it's not an ellipsis)
		if(char == "." && i == num_chars && !has_ellipsis)
			final_word += "!"
		// or if it's the vowel we found, we're gonna repeat it a few times (holding the note)
		else if(char == last_vowel)
			for(var/j in 1 to 4)
				final_word += char
			// if we dragged out the last character of the word, just period it
			if(i == num_chars)
				final_word += "."
		// no special handing otherwise
		else
			final_word += char

	if(!has_ellipsis)
		// adding an extra exclamation mark at the end if there's no period
		var/last_char = copytext_char(final_word, -1)
		if(last_char != ".")
			final_word += "!"

	words[length(words)] = final_word
	// now we siiiiiiing
	say_args[SPEECH_MESSAGE] = jointext(words, " ")
	say_args[SPEECH_MODS][MODE_SING] = TRUE

/obj/item/skillchip/musical/examine(mob/user)
	. = ..()
	. += span_tinynoticeital("Huh, looks like it'd fit in a skillchip adapter.")

/obj/item/skillchip/musical/examine_more(mob/user)
	. = ..()
	var/list/songs = list()
	songs += "&bull; \"The Ballad of Space Station 13\""
	songs += "&bull; \"The Captain's Call\""
	songs += "&bull; \"A Mime's Lament\""
	songs += "&bull; \"Banned from Cargo\""
	songs += "&bull; \"Botany Blues\""
	songs += "&bull; \"Clown Song\""
	songs += "&bull; \"Elegy to an Engineer\""
	songs += "&bull; \"Medical Malpractitioner\""
	songs += "&bull; \"Security Strike\""
	songs += "&bull; \"Send for the Shuttle\""
	songs += "&bull;  And one song scratched out..."

	. += span_notice("<i>On the back of the chip, you see a list of songs:</i>")
	. += span_smallnotice("<i>[jointext(songs, "<br>")]</i>")

/obj/item/skillchip/acrobatics
	name = "old F058UR7 skillchip"
	desc = "A formerly cutting-edge skillchip that granted the user an advanced, Olympian-level degree of kinesthesics for flipping, spinning, and absolutely nothing else. \
		It was pulled off the markets shortly after release due to users damaging the chip's integrity from excessive acrobatics, causing deadly malfunctions. It really puts the 'flop' in 'Fosbury Flop'!"
	skill_name = "Spinesthetics"
	skill_description = "Allows you to flip and spin at an illegal and dangerous rate."
	skill_icon = FA_ICON_WHEELCHAIR_ALT
	activate_message = span_notice("You suddenly have an extremely advanced and complex sense of how to spin and flip with grace.")
	deactivate_message = span_notice("Your divine grasp of Spinesthesics disappears entirely.")
	custom_premium_price = PAYCHECK_CREW * 4
	// set integrity to 1 when mapping for !!FUN!!
	max_integrity = 100
	// more fun
	var/list/affected_emotes = list("spin", "flip")
	var/datum/effect_system/spark_spread/sparks
	// you can use this without lowering integrity! let's be honest. nobody's doing that
	var/allowed_usage = 3
	var/reload_charge = 10 SECONDS

/obj/item/skillchip/acrobatics/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_EMOTE_COOLDOWN_CHECK, PROC_REF(whowee))

/obj/item/skillchip/acrobatics/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_EMOTE_COOLDOWN_CHECK)

/obj/item/skillchip/acrobatics/proc/whowee(mob/living/carbon/bozo, emote_key, emote_intentional)
	SIGNAL_HANDLER

	if(!(emote_key in affected_emotes))
		return

	var/integrity_loss = 1
	if(emote_key == "flip") // twice as obtrusive
		integrity_loss = 2

	if(allowed_usage)
		allowed_usage--
		addtimer(CALLBACK(src, PROC_REF(charge)), reload_charge)
	else
		take_damage(integrity_loss, sound_effect = FALSE)

	if(!sparks)
		sparks = new(src)

	var/cancel_flip = FALSE
	// minimum roll is by default capped at 50, with the min value lowering as integrity is reduced.
	var/mintegrity = clamp(50 - (100 - get_integrity()), 1, 100)
	switch(rand(mintegrity, get_integrity())) // 1 to 100 but gets worse every time
		// CRIT FAIL
		if(1)
			bozo.visible_message(span_userdanger("[bozo]'s head suddenly explodes outwards!"))

			explosion(bozo, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
			// WITNESS THE GORE
			for(var/mob/living/splashed in view(2, bozo))
				if(bozo.has_status_effect(/datum/status_effect/grouped/blindness))
					to_chat(splashed, span_userdanger("You're covered in blood!"))
				else
					to_chat(splashed, span_userdanger("You are blinded by a shower of blood!"))
				splashed.Stun(2 SECONDS)
				splashed.set_eye_blur_if_lower(40 SECONDS)
				splashed.adjust_confusion(3 SECONDS)

			// GORE
			var/obj/item/bodypart/bozopart = bozo.bodyparts[/obj/item/bodypart/head]
			if(bozopart)
				var/datum/wound/cranial_fissure/crit_wound = new()
				crit_wound.apply_wound(bozopart)
				var/obj/item/thing_to_drop = pick(bozopart.contents)
				// assign to bodypart, change to organ inside
				if(thing_to_drop)
					thing_to_drop = pick(thing_to_drop.contents)
					thing_to_drop.forceMove(bozo.drop_location())
			// does not always kill you directly. instead it causes cranial fissure + something to drop from your head. could be eyes, tongue, ears, brain, even implants
			new /obj/effect/gibspawner/generic/smol(get_turf(src))
			cancel_flip = TRUE

			sparks.set_up(15, cardinals_only = FALSE, location = get_turf(src))
			sparks.start()

			qdel(src)
		// last chance to stop
		if(7 to 9)
			bozo.visible_message(
				span_danger("[bozo] seems to short circuit!"),
				span_userdanger("Your brain short circuits!"),
			)
			// if they're susceptible to electrocution, confuse them
			if(bozo.electrocute_act(15, bozo, 1, SHOCK_NOGLOVES|SHOCK_NOSTUN))
				bozo.adjust_confusion(15 SECONDS)
			// but the rest of the effects will happen either way
			bozo.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20 - get_integrity())

			sparks.set_up(5, cardinals_only = FALSE, location = get_turf(src))
			sparks.start()

		// brain Smoking. you should probably stop now
		if(13 to 15)
			// if already hot, light 'em up
			if(bozo.has_status_effect(/datum/status_effect/temperature_over_time/chip_overheat))
				bozo.adjust_fire_stacks(11 - get_integrity())
				bozo.ignite_mob()
				bozo.visible_message(
					span_danger("[bozo]'s head lights up!"),
					span_userdanger("Your head hurts so much, it feels like it's on fire!"),
				)
				INVOKE_ASYNC(bozo, TYPE_PROC_REF(/mob/living, emote), "scream")
				bozo.emote("scream")
			else
				bozo.visible_message(
					span_danger("[bozo]'s head starts smoking!"),
					span_userdanger("You get a massive headache! This can't be good..."),
				)


			var/particles/smoke/steam/mild/particle_effect = new(bozo)
			bozo.apply_status_effect(/datum/status_effect/temperature_over_time/chip_overheat)
			QDEL_IN(particle_effect, 15 SECONDS)

			sparks.set_up(10, cardinals_only = FALSE, location = get_turf(src))
			sparks.start()
		// hey, something isn't right...
		if(16 to 50)
			bozo.visible_message(
				span_warning("[bozo]'s head sparks."),
				span_danger("[name] sparks a little."),
			)

			sparks.set_up(rand(1,2), cardinals_only = TRUE, location = get_turf(src))
			sparks.start()

	// no spin :(
	if(cancel_flip)
		return

	return COMPONENT_EMOTE_COOLDOWN_BYPASS

/obj/item/skillchip/acrobatics/proc/charge()
	allowed_usage++

/obj/item/skillchip/acrobatics/kiss
	name = "prototype N. 807 - K1SS skillchip"
	desc = "An idle experiment when developing skillchips led to this catastrophe. Everyone involved swore to keep it a secret until death, but it looks like someone has let loose this mistake into the world."
	skill_name = "ERROERERROROROEROEORROER"
	skill_description = "NULL DESCRIPTION NOT FOUND"
	skill_icon = FA_ICON_KISS_BEAM
	activate_message = span_userdanger("This was a mistake.")
	deactivate_message = span_userdanger("The mistake is over.")
	custom_premium_price = PAYCHECK_CREW * 500
	max_integrity = 25
	affected_emotes = list("kiss")
	allowed_usage = 1
	reload_charge = 30 SECONDS
