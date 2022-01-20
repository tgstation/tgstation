/obj/item/skillchip
	name = "skillchip"
	desc = "This biochip integrates with user's brain to enable mastery of specific skill. Consult certified Nanotrasen neurosurgeon before use."

	icon = 'icons/obj/card.dmi'
	icon_state = "data_3"
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
	/// Used to determine if this is an abstract type or not. If this is meant to be an abstract type, set it to the type's path. Will be overridden by subsequent abstract parents. See /datum/action/item_action/chameleon/change/skillchip/initialize_disguises()
	var/abstract_parent_type = /obj/item/skillchip
	/// Set to TRUE when the skill chip's effects are applied. Set to FALSE when they're not.
	var/active = FALSE
	/// Brain that holds this skillchip.
	var/obj/item/organ/brain/holding_brain

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
	if(QDELETED(holding_brain))
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
/obj/item/skillchip/proc/on_implant(obj/item/organ/brain/owner_brain)
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
	if(!silent && activate_message)
		to_chat(user, activate_message)

	for(var/trait in auto_traits)
		ADD_TRAIT(user, trait, SKILLCHIP_TRAIT)

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
	if(!silent && deactivate_message)
		to_chat(user, deactivate_message)

	for(var/trait in auto_traits)
		REMOVE_TRAIT(user, trait, SKILLCHIP_TRAIT)

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
/obj/item/skillchip/proc/has_activate_incompatibility(obj/item/organ/brain/brain)
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
	var/obj/item/organ/brain/brain = target.getorganslot(ORGAN_SLOT_BRAIN)
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
/obj/item/skillchip/proc/has_brain_incompatibility(obj/item/organ/brain/brain)
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
