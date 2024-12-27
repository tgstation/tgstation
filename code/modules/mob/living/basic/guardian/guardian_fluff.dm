/**
 * Defines a theme used by guardian mobs for visuals and some text output
 * The default is used for ones created by wizards
 */
/datum/guardian_fluff
	/// What name do we apply before one has been selected?
	var/name = "Guardian Spirit"
	/// Mob description to apply
	var/desc = "A mysterious being that stands by its charge, ever vigilant."
	/// Are we magical or technological? Mostly just used to pick a surname
	var/fluff_type = GUARDIAN_MAGIC
	/// What speech bubble do we use?
	var/bubble_icon = "guardian"
	/// What is our base icon state?
	var/icon_state = "magicbase"
	/// What is the icon state for our coloured overlay?
	var/overlay_state = "magic"
	/// Emote used for speaking
	var/list/speak_emote = list("hisses")
	/// Verb shown to viewers when attacking
	var/attack_verb_continuous = "punches"
	/// Verb shown to attacker when attacking
	var/attack_verb_simple = "punch"
	/// Sound played when we attack
	var/attack_sound = 'sound/items/weapons/punch1.ogg'
	/// Visible effect when we attack
	var/attack_vis_effect = ATTACK_EFFECT_PUNCH
	/// An associative list of type of guardian to some kind of descriptive text to show on appearance.
	var/guardian_fluff = list(
		GUARDIAN_ASSASSIN = "...And draw the Space Ninja, a lethal and invisible assassin.",
		GUARDIAN_CHARGER = "...And draw the Hunter, alien master of rapid assault.",
		GUARDIAN_DEXTROUS = "...And draw the Monkey, ascendant beast who has learned to use tools.",
		GUARDIAN_EXPLOSIVE = "...And draw the Scientist, herald of explosive death.",
		GUARDIAN_GASEOUS = "...And draw the Atmospheric Technician, veiled in a purple haze.",
		GUARDIAN_GRAVITOKINETIC = "...And draw the Singularity, a terrible, irresistible force..",
		GUARDIAN_LIGHTNING = "...And draw the Supermatter, a shockingly lethal font of power.",
		GUARDIAN_PROTECTOR = "...And draw the Corgi, a stalwart protector that never leaves the side of its charge.",
		GUARDIAN_RANGED = "...And draw the Watcher, impaling its prey from afar.",
		GUARDIAN_STANDARD = "...And draw the Assistant, faceless but never to be underestimated.",
		GUARDIAN_SUPPORT = "...And draw the Paramedic, arbiter of life and death.",
	)

/// Applies relevant visual properties to our guardian
/datum/guardian_fluff/proc/apply(mob/living/basic/guardian/guardian)
	guardian.name = name
	guardian.real_name = name
	guardian.bubble_icon = bubble_icon
	guardian.icon_living = icon_state
	guardian.icon_state = icon_state

	guardian.speak_emote = speak_emote
	guardian.attack_verb_continuous = attack_verb_continuous
	guardian.attack_verb_simple = attack_verb_simple
	guardian.attack_sound = attack_sound
	guardian.attack_vis_effect = attack_vis_effect

	guardian.overlay = mutable_appearance(guardian.icon, overlay_state)

/// Output an appropriate fluff string for our guardian when it is created
/datum/guardian_fluff/proc/get_fluff_string(guardian_type)
	return span_holoparasite(guardian_fluff[guardian_type] || "You bring forth a glitching abomination, something which should not be! Please contact a coder about it.")

/// Used by holoparasites in the Traitor uplink
/datum/guardian_fluff/tech
	name = "Holoparasite"
	fluff_type = GUARDIAN_TECH
	bubble_icon = "holo"
	icon_state = "techbase"
	overlay_state = "tech"
	guardian_fluff = list(
		GUARDIAN_ASSASSIN = "Boot sequence complete. Stealth modules loaded. Holoparasite swarm online.",
		GUARDIAN_CHARGER = "Boot sequence complete. Overclocking motive engines. Holoparasite swarm online.",
		GUARDIAN_DEXTROUS = "Boot sequence complete. Armed combat routines loaded. Holoparasite swarm online.",
		GUARDIAN_EXPLOSIVE = "Boot sequence complete. Payload generator online. Holoparasite swarm online.",
		GUARDIAN_GASEOUS = "Boot sequence complete. Atmospheric projectors operational. Holoparasite swarm online.",
		GUARDIAN_GRAVITOKINETIC = "Boot sequence complete. Gravitic engine spinning up. Holoparasite swarm online.",
		GUARDIAN_LIGHTNING = "Boot sequence complete. Tesla projectors charged. Holoparasite swarm online.",
		GUARDIAN_PROTECTOR = "Boot sequence complete. Bodyguard routines loaded. Holoparasite swarm online.",
		GUARDIAN_RANGED = "Boot sequence complete. Flechette launchers operational. Holoparasite swarm online.",
		GUARDIAN_STANDARD = "Boot sequence complete. CQC suite engaged. Holoparasite swarm online.",
		GUARDIAN_SUPPORT = "Boot sequence complete. Medical suite active. Holoparasite swarm online.",
	)

/// Used by powerminers found in necropolis chests
/datum/guardian_fluff/miner
	name = "Power Miner"
	icon_state = "minerbase"
	overlay_state = "miner"
	guardian_fluff = list(
		GUARDIAN_ASSASSIN = "The shard reveals... Glass, a sharp but fragile ambusher.",
		GUARDIAN_CHARGER = "The shard reveals... Titanium, a lightweight, agile fighter.",
		GUARDIAN_DEXTROUS = "The shard reveals... Gold, a malleable hoarder of treasure.",
		GUARDIAN_EXPLOSIVE = "The shard reveals... Gibtonite, volatile and surprising.",
		GUARDIAN_GASEOUS = "The shard reveals... Plasma, the bringer of flame.",
		GUARDIAN_GRAVITOKINETIC = "The shard reveals... Bananium, a manipulator of motive forces.",
		GUARDIAN_LIGHTNING = "The shard reveals... Iron, a conductive font of lightning.",
		GUARDIAN_PROTECTOR = "The shard reveals... Uranium, dense and resistant.",
		GUARDIAN_RANGED = "The shard reveals... Diamond, projecting a million sharp edges.",
		GUARDIAN_STANDARD = "The shard reveals... Plastitanium, a powerful fighter.",
		GUARDIAN_SUPPORT = "The shard reveals... Bluespace, master of relocation.",
	)

/// Used by holocarp spawned by admins
/datum/guardian_fluff/carp
	name = "Holocarp"
	fluff_type = GUARDIAN_TECH
	desc = "A mysterious fish that swims by its charge, ever fingilant."
	icon_state = null // Handled entirely by the overlay
	bubble_icon = "holo"
	overlay_state = "carp"
	speak_emote = list("gnashes")
	guardian_fluff = list(
		GUARDIAN_ASSASSIN = "CARP CARP CARP! Caught one! It's an assassin carp! Just when you thought it was safe to go back to the water... which is unhelpful, because we're in space.",
		GUARDIAN_CHARGER = "CARP CARP CARP! Caught one! It's a charger carp which likes running at people. But it doesn't have any legs...",
		GUARDIAN_DEXTROUS = "CARP CARP CARP! You caught one! It's a dextrous carp ready to slap people with a fish, once it picks one up.",
		GUARDIAN_EXPLOSIVE = "CARP CARP CARP! Caught one! It's an explosive carp! You two are going to have a blast.",
		GUARDIAN_GASEOUS = "CARP CARP CARP! You caught one! It's a gaseous carp, but don't worry it actually smells pretty good!",
		GUARDIAN_GRAVITOKINETIC = "CARP CARP CARP! Caught one! It's a gravitokinetic carp! Now do you understand the gravity of the situation?",
		GUARDIAN_LIGHTNING = "CARP CARP CARP! Caught one! It's a lightning carp! What a shocking result!",
		GUARDIAN_PROTECTOR = "CARP CARP CARP! You caught one! Wait, no... it caught you! The fisher has become the fishy...",
		GUARDIAN_RANGED = "CARP CARP CARP! You caught one! It's a ranged carp! It has been collecting glass shards in preparation for this moment.",
		GUARDIAN_STANDARD = "CARP CARP CARP! You caught one! This one is a little generic and disappointing... Better punch through some walls to ease the tension.",
		GUARDIAN_SUPPORT = "CARP CARP CARP! You caught a support carp! Now it's here, now you're over there!",
	)
