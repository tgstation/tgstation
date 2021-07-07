/**
 * The wirebrush is a tool whose sole purpose is to remove rust from anything that is rusty.
 * Because of the inherent nature of hard countering rust heretics it does it very slowly.
 */
/obj/item/wirebrush
	name = "wirebrush"
	desc = "A tool that is used to scrub the rust thoroughly off walls. Not for hair!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "wirebrush"
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 1

/**
 * An advanced form of the wirebrush that trades the safety of the user for instant rust removal.
 * If the person using this is unlucky they are going to die painfully.
 */
/obj/item/wirebrush/advanced
	name = "advanced wirebrush"
	desc = "An advanced wirebrush; uses radiation to almost instantly liquify rust."
	icon_state = "wirebrush_adv"
	toolspeed = 0.1

	/// The amount of radiation to give to the user of this tool; regardless of what they did with it.
	var/radiation_on_use = 20

	/// How likely is a critical fail?
	var/crit_fail_prob = 1

	/// The amount of radiation to give to the user if they roll the worst effects. Negative numbers will heal radiation instead!
	var/crit_fail_rads = 50

	/// The amount of damage to take in BOTH Tox and Oxy on critical fail
	var/crit_fail_damage = 15

	/// We only apply damage and force vomit if the user has OVER this many rads
	var/crit_fail_rads_threshold = 300

/obj/item/wirebrush/advanced/examine(mob/user)
	. = ..()
	. += span_danger("There is a warning label that indicates extended use of [src] may result in loss of hair, yellowing skin, and death.")

/obj/item/wirebrush/advanced/pre_attack(atom/A, mob/living/user)
	. = ..()

	if(!istype(user))
		return

	if(prob(crit_fail_prob))
		to_chat(user, span_danger("You feel a sharp pain as your entire body grows oddly warm."))
		user.radiation += crit_fail_rads
		if(user.radiation > crit_fail_rads_threshold) // If you ignore the warning signs you get punished
			user.emote("vomit")
			user.adjustToxLoss(crit_fail_damage, forced=TRUE)
			user.adjustOxyLoss(crit_fail_damage, forced=TRUE)
		return

	user.radiation += radiation_on_use

	if(prob(25))
		user.emote("cough")

/obj/item/wirebrush/advanced/pre_attack_secondary()
	return SECONDARY_ATTACK_CALL_NORMAL
