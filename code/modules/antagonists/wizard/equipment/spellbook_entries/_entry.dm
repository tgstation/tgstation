/**
 * ## Spellbook entries
 *
 * Wizard spellbooks are automatically populated with
 * a list of every spellbook entry subtype when they're made.
 *
 * Wizards can then buy entries from the book to learn magic,
 * invoke rituals, or summon items.
 */
/datum/spellbook_entry
	/// The name of the entry
	var/name
	/// The description of the entry
	var/desc
	/// The type of spell that the entry grants (typepath)
	var/datum/action/cooldown/spell/spell_type
	/// What category the entry falls in
	var/category
	/// How many book charges does the spell take
	var/cost = 2
	/// How many times has the spell been purchased. Compared against limit.
	var/times = 0
	/// The limit on number of purchases from this entry in a given spellbook. If null, infinite are allowed.
	var/limit
	/// Is this refundable?
	var/refundable = TRUE
	/// Flavor. Verb used in saying how the spell is aquired. Ex "[Learn] Fireball" or "[Summon] Ghosts"
	var/buy_word = "Learn"
	/// The cooldown of the spell
	var/cooldown
	/// Whether the spell requires wizard garb or not
	var/requires_wizard_garb = FALSE
	/// Used so you can't have specific spells together
	var/list/no_coexistance_typecache

/datum/spellbook_entry/New()
	no_coexistance_typecache = typecacheof(no_coexistance_typecache)

	if(ispath(spell_type))
		if(isnull(limit))
			limit = initial(spell_type.spell_max_level)
		if(initial(spell_type.spell_requirements) & SPELL_REQUIRES_WIZARD_GARB)
			requires_wizard_garb = TRUE

/**
 * Determines if this entry can be purchased from a spellbook
 * Used for configs / round related restrictions.
 *
 * Return FALSE to prevent the entry from being added to wizard spellbooks, TRUE otherwise
 */
/datum/spellbook_entry/proc/can_be_purchased()
	if(!name || !desc || !category) // Erroneously set or abstract
		return FALSE
	return TRUE

/**
 * Checks if the user, with the supplied spellbook, can purchase the given entry.
 *
 * Arguments
 * * user - the mob who's buying the spell
 * * book - what book they're buying the spell from
 *
 * Return TRUE if it can be bought, FALSE otherwise
 */
/datum/spellbook_entry/proc/can_buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(book.uses < cost)
		return FALSE
	if(!isnull(limit) && times >= limit)
		return FALSE
	for(var/spell in user.actions)
		if(is_type_in_typecache(spell, no_coexistance_typecache))
			return FALSE
	var/datum/antagonist/wizard/wizard_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(!wizard_datum)
		return TRUE
	for(var/perks in wizard_datum.perks)
		if(is_type_in_typecache(perks, no_coexistance_typecache))
			return FALSE
	if(is_type_in_list(src, wizard_datum.perks))
		to_chat(user, span_warning("This perk already learned!"))
		return FALSE
	return TRUE

/**
 * Actually buy the entry for the user
 *
 * Arguments
 * * user - the mob who's bought the spell
 * * book - what book they've bought the spell from
 *
 * Return truthy if the purchase was successful, FALSE otherwise
 */
/datum/spellbook_entry/proc/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy = TRUE)
	var/datum/action/cooldown/spell/existing = locate(spell_type) in user.actions
	if(existing)
		var/before_name = existing.name
		if(!existing.level_spell())
			to_chat(user, span_warning("This spell cannot be improved further!"))
			return FALSE

		to_chat(user, span_notice("You have improved [before_name] into [existing.name]."))
		name = existing.name

		//we'll need to update the cooldowns for the spellbook
		set_spell_info()

		if(log_buy)
			log_spellbook("[key_name(user)] improved their knowledge of [initial(existing.name)] to level [existing.spell_level] for [cost] points")
			SSblackbox.record_feedback("nested tally", "wizard_spell_improved", 1, list("[name]", "[existing.spell_level]"))
			log_purchase(user.key)
		return existing

	//No same spell found - just learn it
	var/datum/action/cooldown/spell/new_spell = new spell_type(user.mind || user)
	new_spell.Grant(user)
	to_chat(user, span_notice("You have learned [new_spell.name]."))

	if(log_buy)
		log_spellbook("[key_name(user)] learned [new_spell] for [cost] points")
		SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
		log_purchase(user.key)
	return new_spell

/datum/spellbook_entry/proc/log_purchase(key)
	if(!islist(GLOB.wizard_spellbook_purchases_by_key[key]))
		GLOB.wizard_spellbook_purchases_by_key[key] = list()

	for(var/list/log as anything in GLOB.wizard_spellbook_purchases_by_key[key])
		if(log[LOG_SPELL_TYPE] == type)
			log[LOG_SPELL_AMOUNT]++
			return

	var/list/to_log = list(
		LOG_SPELL_TYPE = type,
		LOG_SPELL_AMOUNT = 1,
	)
	GLOB.wizard_spellbook_purchases_by_key[key] += list(to_log)

/**
 * Checks if the user, with the supplied spellbook, can refund the entry
 *
 * Arguments
 * * user - the mob who's refunding the spell
 * * book - what book they're refunding the spell from
 *
 * Return TRUE if it can refunded, FALSE otherwise
 */
/datum/spellbook_entry/proc/can_refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(HAS_TRAIT(user, TRAIT_SPELLS_LOTTERY))
		to_chat(user, span_notice("No refund."))
		return FALSE
	if(!refundable)
		return FALSE
	if(!book.refunds_allowed)
		return FALSE

	for(var/datum/action/cooldown/spell/other_spell in user.actions)
		if(initial(spell_type.name) == initial(other_spell.name))
			return TRUE

	return FALSE

/**
 * Actually refund the entry for the user
 *
 * Arguments
 * * user - the mob who's refunded the spell
 * * book - what book they're refunding the spell from
 *
 * Return -1 on failure, or return the point value of the refund on success
 */
/datum/spellbook_entry/proc/refund_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/area/centcom/wizard_station/wizard_home = GLOB.areas_by_type[/area/centcom/wizard_station]
	if(get_area(user) != wizard_home)
		to_chat(user, span_warning("You can only refund spells at the wizard lair!"))
		return -1

	for(var/datum/action/cooldown/spell/to_refund in user.actions)
		if(initial(spell_type.name) != initial(to_refund.name))
			continue

		var/amount_to_refund = to_refund.spell_level * cost
		if(amount_to_refund <= 0)
			return -1

		qdel(to_refund)
		name = initial(name)
		log_spellbook("[key_name(user)] refunded [src] for [amount_to_refund] points")
		return amount_to_refund

	return -1

/**
 * Set any of the spell info saved on our entry
 * after something has occured
 *
 * For example, updating the cooldown after upgrading it
 */
/datum/spellbook_entry/proc/set_spell_info()
	if(!spell_type)
		return

	cooldown = (initial(spell_type.cooldown_time) / 10)

/// Item summons, they give you an item.
/datum/spellbook_entry/item
	refundable = FALSE
	buy_word = "Summon"
	/// Typepath of what item we create when purchased
	var/obj/item/item_path

/datum/spellbook_entry/item/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy = TRUE)
	var/atom/spawned_path = new item_path(user.loc)
	if(log_buy)
		log_spellbook("[key_name(user)] bought [src] for [cost] points")
		SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
		log_purchase(user.key)

	ADD_TRAIT(spawned_path, TRAIT_CONTRABAND, INNATE_TRAIT)
	for(var/obj/contained as anything in spawned_path.contents)
		ADD_TRAIT(contained, TRAIT_CONTRABAND, INNATE_TRAIT)

	try_equip_item(user, spawned_path)
	return spawned_path

/// Attempts to give the item to the buyer on purchase.
/datum/spellbook_entry/item/proc/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_put_in_hands = user.put_in_hands(to_equip)
	to_chat(user, span_notice("\A [to_equip.name] has been summoned [was_put_in_hands ? "in your hands" : "at your feet"]."))

/// Ritual, these cause station wide effects and are (pretty much) a blank slate to implement stuff in
/datum/spellbook_entry/summon
	category = "Rituals"
	limit = 1
	refundable = FALSE
	buy_word = "Cast"

/datum/spellbook_entry/summon/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy = TRUE)
	if(log_buy)
		log_spellbook("[key_name(user)] cast [src] for [cost] points")
		SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
		log_purchase(user.key)
	book.update_static_data(user) // updates "times" var
	return TRUE

/// Non-purchasable flavor spells to populate the spell book with, for style.
/datum/spellbook_entry/challenge
	name = "Take the Challenge"
	category = "Challenges"
	refundable = FALSE
	buy_word = "Accept"

// See, non-purchasable.
/datum/spellbook_entry/challenge/can_buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	return FALSE
