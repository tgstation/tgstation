#define HITS_TO_CRIT(damage) round(100 / damage, 0.1)
/**
 *
 * The purpose of this element is to widely provide the ability to examine an object and determine its stats, with the ability to add
 * additional notes or information based on type or other factors
 *
 */
/datum/element/weapon_description
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	// Additional proc to be run for specific object types
	var/attached_proc

	// Flavor text crimes used in build_weapon_text()
	var/list/crimes = list("Assaults", "Third Degree Murders", "Robberies", "Terrorist Attacks", "Different Felonies", "Felinies", "Counts of Tax Evasion", "Mutinies")
	var/list/victims = list("a human", "a moth", "a felinid", "a lizard", "a particularly resilient slime", "a syndicate agent", "a clown", "a mime", "a mortal foe", "an innocent bystander")

/datum/element/weapon_description/Attach(datum/target, attached_proc)
	. = ..()
	if(!isitem(target)) // Do not attach this to anything that isn't an item
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(warning_label))
	RegisterSignal(target, COMSIG_TOPIC, PROC_REF(topic_handler))
	// Don't perform the assignment if there is nothing to assign, or if we already have something for this bespoke element
	if(attached_proc && !src.attached_proc)
		src.attached_proc = attached_proc

/datum/element/weapon_description/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_PARENT_EXAMINE, COMSIG_TOPIC))

/**
 *
 * This proc is called when the user examines an object with the associated element. This produces a hyperlinked
 * text line provided that the given item meets the weapon-determining criteria (Sufficient force or notes)
 *
 * Arguments:
 * 	* source - Object being examined, cast into an item variable
 *  * user - Unused
 *  * examine_texts - The output text list of the original examine function
 */
/datum/element/weapon_description/proc/warning_label(obj/item/item, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	if(item.force >= 5 || item.throwforce >= 5 || item.override_notes || item.offensive_notes || attached_proc) /// Only show this tag for items that could feasibly be weapons, shields, or those that have special notes
		examine_texts += span_notice("It appears to have an ever-updating bluespace <a href='?src=[REF(item)];examine=1'>warning label.</a>")

/**
 *
 * Details the stats of the examined weapon
 *
 * This function is called when the user clicks the hyperlink provided by
 * warning_label(). It calls build_label_text() and outputs its return value to the user
 *
 * Arguments:
 *  * source - Object being examined, sent to build_label_text()
 *  * href-list - List provided by the href of input values, used to know what hyperlinked action is being attempted
 */

/datum/element/weapon_description/proc/topic_handler(atom/source, user, href_list)
	SIGNAL_HANDLER

	if(href_list["examine"])
		to_chat(user, span_notice(examine_block("[build_label_text(source)]")))

/**
 *
 * Compiles a warning label detailing various statistics of the examined weapon
 *
 * This function is called by the "examine" function of Topic(), and compiles a number of relevant
 * weapon stats into a message that is then shown to the user
 * Arguments:
 *  * source - The object whose stats are being examined
 */
/datum/element/weapon_description/proc/build_label_text(obj/item/source)
	var/list/readout = list("") // Readout is used to store the text block output to the user so it all can be sent in one message

	// Meaningless flavor text. The number of crimes is constantly changing because of the complex Nanotrasen legal system and the esoteric nature of time itself!
	readout += "[span_warning("WARNING:")] This item has been marked as dangerous by the NT legal team because of its use in [span_warning("[rand(2,99)] [crimes[rand(1, crimes.len)]]")] in the past hour.\n"

	// Doesn't show the base notes for items that have the override notes variable set to true
	if(!source.override_notes)
		// Make sure not to divide by 0 on accident
		if(source.force > 0)
			readout += "Our extensive research has shown that it takes a mere [span_warning("[HITS_TO_CRIT(source.force)] hit\s")] to beat down [victims[rand(1, victims.len)]] with no armor."
		else
			readout += "Our extensive research found that you couldn't beat anyone to death with this if you tried."

		if(source.throwforce > 0)
			readout += "If you decide to throw this object instead, one will take [span_warning("[HITS_TO_CRIT(source.throwforce)] hit\s")] before collapsing."
		else
			readout += "If you decide to throw this object instead, then you will have trouble damaging anything."
		if(source.armour_penetration > 0 || source.block_chance > 0)
			readout += "This item has proven itself [span_warning("[weapon_tag_convert(source.armour_penetration)]")] of piercing armor and [span_warning("[weapon_tag_convert(source.block_chance)]")] of blocking attacks."
	// Custom manual notes
	if(source.offensive_notes)
		readout += source.offensive_notes

	// Check if we have an additional proc, if so, add it to the readout
	if(attached_proc)
		readout += call(source, attached_proc)()

	// Finally bringing the fields together
	return readout.Join("\n")

/**
 *
 * Converts percentile based stats to an adjective appropriate for the
 * examined warning label
 *
 * Arguments:
 *  * tag_val: The value of the item to be added to the tag
 */
/datum/element/weapon_description/proc/weapon_tag_convert(tag_val)
	switch(tag_val)
		if(0)
			return "INCAPABLE"
		if(1 to 25)
			return "BARELY CAPABLE"
		if(26 to 50)
			return "CAPABLE"
		if(51 to 75)
			return "VERY CAPABLE"
		if(76 to INFINITY)
			return "EXTREMELY CAPABLE"
		else
			return "STRANGELY CAPABLE"
