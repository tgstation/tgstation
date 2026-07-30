/datum/wound/blunt/robotic/moderate
	name = "Loosened Screws"
	desc = "Various semi-external fastening instruments have loosened, causing components to jostle, inhibiting limb control."
	treat_text = "Recommend topical re-fastening of instruments with a screwdriver, though percussive maintenance via low-force bludgeoning may suffice - \
	albeit at risk of worsening the injury."
	examine_desc = "appears to be loosely secured"
	occur_text = "jostles awkwardly and seems to slightly unfasten"
	severity = WOUND_SEVERITY_MODERATE
	simple_treat_text = "<b>Splinting</b> the wound will reduce the impact until it's <b>screws are secured."
	homemade_treat_text = "In a pinch, <b>percussive maintenance</b> can reset the screws - the chance of which is increased if done by <b>someone else</b> or \
	with a <b>diagnostic HUD</b>!"
	status_effect_type = /datum/status_effect/wound/blunt/robotic/moderate
	treat_text_short = "Apply screwdriver or percussive maintenance"
	treatable_tools = list(TOOL_SCREWDRIVER)
	interaction_efficiency_penalty = 1.2
	limp_slowdown = 2.5
	limp_chance = 30
	series_threshold_penalty = 15
	a_or_from = "from"
	/// % chance for hitting our limb to fix something.
	var/percussive_repair_chance = 12
	/// Damage must be over this to proc percussive maintenance.
	var/percussive_damage_min = 0

/datum/wound_pregen_data/blunt_metal/loose_screws
	abstract = FALSE
	wound_path_to_generate = /datum/wound/blunt/robotic/moderate
	threshold_minimum = 35

/datum/wound/blunt/robotic/moderate/treat(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_SCREWDRIVER)
		fasten_screws(potential_treater, user)
		return TRUE

	return ..()

/datum/wound/blunt/robotic/moderate/victim_attacked(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	. = ..()
	if(damage < percussive_damage_min || damagetype != BRUTE || sharpness)
		return
	if (prob(percussive_repair_chance))
		victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] rattles from the impact, but looks a lot more secure!"), span_green("Your [limb.plaintext_zone] rattles into place!"))
		remove_wound()
	else
		to_chat(victim, span_warning("Your [limb.plaintext_zone] rattles around."))

/// The main treatment for T1 blunt. Uses a screwdriver, guaranteed to always work, better with a diag hud. Removes the wound.
/datum/wound/blunt/robotic/moderate/proc/fasten_screws(obj/item/screwdriver_tool, mob/user)
	if (!screwdriver_tool.tool_start_check())
		return

	var/delay_mult = 1

	if (user == victim)
		delay_mult *= 2

	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.5

	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.5

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	victim.visible_message(span_notice("[user] begins fastening the screws of [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin fastening the screws of [your_or_other] [limb.plaintext_zone]..."))

	if (!screwdriver_tool.use_tool(target = victim, user = user, delay = (6 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	victim.visible_message(span_green("[user] finishes fastening [their_or_other] [limb.plaintext_zone]!"), \
		span_green("You finish fastening [your_or_other] [limb.plaintext_zone]!"))

	remove_wound()
