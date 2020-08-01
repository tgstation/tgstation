/obj/item/skillchip
	name = "skillchip"
	desc = "This biochip integrates with user's brain to enable mastery of specific skill. Consult certified Nanotrasen neurosurgeon before use."

	icon = 'icons/obj/card.dmi'
	icon_state = "data_3"
	custom_price = 500
	w_class = WEIGHT_CLASS_SMALL

	// Primarily used in the chameleon skillchip item_action code to specify an item that isn't really an item.
	item_flags = ABSTRACT

	/// Trait automatically granted by this chip, optional
	var/auto_trait
	/// Skill name shown on UI
	var/skill_name
	/// Skill description shown on UI
	var/skill_description
	/// Category string. Used alongside SKILLCHIP_RESTRICTED_CATEGORIES flag to make a chip incompatible with chips from another category.
	var/chip_category = "general"
	/// List of any incompatible categories.
	var/list/incompatibility_list
	/// Fontawesome icon show on UI, list of possible icons https://fontawesome.com/icons?d=gallery&m=free
	var/skill_icon = "brain"
	/// Message shown when implanting the chip
	var/implanting_message
	/// Message shown when extracting the chip
	var/removal_message
	//If set to TRUE, trying to extract the chip will destroy it instead
	var/removable
	/// How many skillslots this one takes
	var/slot_cost = 1
	/// Variable for flags. DANGEROUS - Child types overwrite flags instead of adding to them. If you change this, make sure all child types have the appropriate flags set too.
	var/skillchip_flags = NONE
	/// Cooldown before the skillchip can be extracted after it has been implanted.
	var/cooldown = 5 MINUTES
	/// The world.time when this skillchip should be extractable.
	COOLDOWN_DECLARE(extractable_at)

/obj/item/skillchip/Initialize(is_removable = TRUE)
	. = ..()
	removable = is_removable

/// Called after implantation and/or brain entering new body
/obj/item/skillchip/proc/on_apply(mob/living/carbon/user,silent=TRUE)
	if(!silent && implanting_message)
		to_chat(user,implanting_message)
	if(auto_trait)
		ADD_TRAIT(user,auto_trait,SKILLCHIP_TRAIT)
	user.used_skillchip_slots += slot_cost

	COOLDOWN_START(src, extractable_at, cooldown)

/// Called after removal and/or brain exiting the body
/obj/item/skillchip/proc/on_removal(mob/living/carbon/user,silent=TRUE)
	if(!silent && removal_message)
		to_chat(user,removal_message)
	if(auto_trait)
		REMOVE_TRAIT(user,auto_trait,SKILLCHIP_TRAIT)
	user.used_skillchip_slots -= slot_cost

	COOLDOWN_RESET(src, extractable_at)

/**
  * Checks for skillchip incompatibility with another chip.
  *
  * Override this with any snowflake chip-vs-chip incompatibility checks.
  * Returns a string with an incompatibility explanation if the chip is not compatible, returns FALSE
  * if it is compatible.
  * Arguments:
  * * skillchip - The skillchip to test for incompatability.
  */
/obj/item/skillchip/proc/has_skillchip_incompatibility(obj/item/skillchip/skillchip)
	// If this is a SKILLCHIP_UNIQUE_IN_CATEGORY it is incompatible with chips of the same category.
	if((skillchip_flags & SKILLCHIP_RESTRICTED_CATEGORIES) && (skillchip.chip_category in incompatibility_list))
		return "Incompatible with other [chip_category] chip: [skillchip.name]"

	// Only allow multiple copies of a type if SKILLCHIP_ALLOWS_MULTIPLE flag is set
	if(!(skillchip_flags & SKILLCHIP_ALLOWS_MULTIPLE) && (istype(skillchip, type)))
		return "Duplicate chip detected."

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

	// No skill slots left
	if(target.used_skillchip_slots + slot_cost > target.max_skillchip_slots)
		return "Complexity limit exceeded."

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

	// Check if this chip is incompatible with any other chips in the brain.
	for(var/obj/item/skillchip/skillchip in brain.skillchips)
		chip_message = skillchip.has_skillchip_incompatibility(skillchip)
		if(chip_message)
			return chip_message

	return FALSE

/**
  * Returns whether the chip is able to be removed safely.
  *
  * This does not mean the chip should be impossible to remove. It's up to each individual
  * piece of code to decide what it does with the result of this proc.
  *
  * Returns FALSE if the chip's extraction cooldown hasn't yet passed.
  */
/obj/item/skillchip/proc/can_remove_safely()
	if(!COOLDOWN_FINISHED(src, extractable_at))
		return FALSE

	return TRUE

/obj/item/skillchip/basketweaving
	name = "Basketsoft 3000 skillchip"
	desc = "Underwater edition."
	auto_trait = TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE
	skill_name = "Underwater Basketweaving"
	skill_description = "Master intricate art of using twine to create perfect baskets while submerged."
	skill_icon = "shopping-basket"
	implanting_message = "<span class='notice'>You're one with the twine and the sea.</span>"
	removal_message = "<span class='notice'>Higher mysteries of underwater basketweaving leave your mind.</span>"

/obj/item/skillchip/wine_taster
	name = "WINE skillchip"
	desc = "Wine.Is.Not.Equal version 5."
	auto_trait = TRAIT_WINE_TASTER
	skill_name = "Wine Tasting"
	skill_description = "Recognize wine vintage from taste alone. Never again lack an opinion when presented with an unknown drink."
	skill_icon = "wine-bottle"
	implanting_message = "<span class='notice'>You recall wine taste.</span>"
	removal_message = "<span class='notice'>Your memories of wine evaporate.</span>"

/obj/item/skillchip/bonsai
	name = "Hedge 3 skillchip"
	auto_trait = TRAIT_BONSAI
	skill_name = "Hedgetrimming"
	skill_description = "Trim hedges and potted plants into marvelous new shapes with any old knife. Not applicable to plastic plants."
	skill_icon = "spa"
	implanting_message = "<span class='notice'>Your mind is filled with plant arrangments.</span>"
	removal_message = "<span class='notice'>Your can't remember how a hedge looks like anymore.</span>"

/obj/item/skillchip/useless_adapter
	name = "Skillchip adapter"
	skill_name = "Useless adapter"
	skill_description = "Allows you to insert another identical skillchip into this adapter, but the adapter also takes a slot ..."
	skill_icon = "plug"
	implanting_message = "<span class='notice'>You can now implant another chip into this adapter, but the adapter also took up an existing slot ...</span>"
	removal_message = "<span class='notice'>You no longer have the useless skillchip adapter.</span>"
	skillchip_flags = SKILLCHIP_ALLOWS_MULTIPLE
	slot_cost = 0

/obj/item/skillchip/useless_adapter/on_apply(mob/living/carbon/user, silent)
	. = ..()
	user.max_skillchip_slots++
	user.used_skillchip_slots++

/obj/item/skillchip/useless_adapter/on_removal(mob/living/carbon/user, silent)
	user.max_skillchip_slots--
	user.used_skillchip_slots--
	return ..()
