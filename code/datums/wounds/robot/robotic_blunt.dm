/datum/wound/blunt/robotic
	name = "Robotic Blunt (Screws and bolts) Wound"
	wound_flags = (ACCEPTS_GAUZE|CAN_BE_GRASPED)
	can_scar = FALSE

	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown
	/// The ratio damage taken to our chest will be multiplied against for determining our stagger and confusion duration.
	var/stagger_multiplier = 1

/datum/wound_pregen_data/blunt_metal
	abstract = TRUE
	required_limb_biostate = BIO_METAL
	wound_series = WOUND_SERIES_METAL_BLUNT_BASIC
	required_wounding_type = WOUND_BLUNT

/datum/wound/blunt/robotic/set_victim(new_victim)
	if(victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
	if(new_victim)
		RegisterSignal(new_victim, COMSIG_MOVABLE_MOVED, PROC_REF(victim_moved))
	return ..()

/datum/wound/blunt/robotic/get_limb_examine_description()
	return span_warning("This limb looks loosely held together.")

// this wound is unaffected by cryoxadone and pyroxadone
/datum/wound/blunt/robotic/on_xadone(power)
	return

/datum/wound/blunt/robotic/wound_injury(datum/wound/old_wound, attack_direction)
	. = ..()

	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	var/obj/item/held_item = victim.get_item_for_held_index(limb.held_index || 0)
	if(held_item && (disabling || prob(30 * severity)))

		if(istype(held_item, /obj/item/offhand))
			held_item = victim.get_inactive_held_item()

		if(held_item && victim.dropItemToGround(held_item))
			victim.visible_message(span_danger("[victim] drops [held_item] in shock!"), span_warning("<b>The force on your [limb.plaintext_zone] causes you to drop [held_item]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()
	return..()

/datum/wound/blunt/robotic/remove_wound(ignore_limb, replaced, destroying)
	. = ..()
	QDEL_NULL(active_trauma)

/datum/wound/blunt/robotic/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if(!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if (active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

/// Signal handler proc to when our victim has damage applied via apply_damage(), which is a external attack.
/datum/wound/blunt/robotic/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!victim || wounding_type = WOUND_BURN || wounding_dmg < WOUND_MINIMUM_DAMAGE)
		return

	var/obj/item/stack/medical/wrap/gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if(gauze)
		wounding_dmg *= gauze.splint_factor

	if(limb.body_zone == BODY_ZONE_CHEST && !victim.buckled)
		var/stagger_duration = wounding_dmg * stagger_multiplier
		var/confusion_duration = stagger_duration / 2
		victim.adjust_staggered_up_to(stagger_duration DECISECONDS, 20 SECONDS)
		victim.adjust_confusion_up_to(confusion_duration, 10 SECONDS)
		to_chat(victim, span_warning("The blow to your chest causes you to start shaking uncontrollably!"))

// Loosened Screws (Moderate Blunt)
/datum/wound/blunt/robotic/moderate
	name = "Loosened Screws"
	desc = "Various semi-external fastening instruments have loosened, causing components to jostle, inhibiting limb control."
	treat_text = "Recommend re-fastening of instruments with a screwdriver, though percussive maintenance via low-force bludgeoning may suffice - \
	albeit at risk of worsening the injury."
	examine_desc = "appears to be loosely secured"
	occur_text = "jostles awkwardly and seems to slightly unfasten"
	severity = WOUND_SEVERITY_MODERATE
	simple_treat_text = "<b>Splinting</b> the wound will reduce the impact until it's <b>screws are secured."
	homemade_treat_text = "In a pinch, <b>percussive maintenance</b> targeting the loose body part can reset the screws. However, effective percussive maintenance is difficult to perform on oneself."

	status_effect_type = /datum/status_effect/wound/blunt/robotic/moderate
	treat_text_short = "Apply screwdriver or percussive maintenance"
	treatable_tools = list(TOOL_SCREWDRIVER)
	interaction_efficiency_penalty = 1.2
	limp_slowdown = 2.5
	limp_chance = 30
	series_threshold_penalty = 15
	a_or_from = "from"
	stagger_multiplier = 1
	/// % chance for hitting our limb to fix something.
	var/percussive_repair_chance = 12
	/// Damage must be over this to proc percussive maintenance.
	var/percussive_damage_min = 3

/datum/wound_pregen_data/blunt_metal/loose_screws
	abstract = FALSE
	wound_path_to_generate = /datum/wound/blunt/robotic/moderate
	// logically you could have loose screws in a torso, but this is for parity and balance reasons
	required_limb_biostate = BIO_JOINTED
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

// Detatched Fastenings (Severe Blunt)
/datum/wound/blunt/robotic/severe
	name = "Detached Fastenings"
	desc = "Various fastening devices are extremely loose and wires within have been disconnected, causing significant jostling of internal components and \
	noticable limb dysfunction."
	treat_text = "Fastening of bolts and screws followed by rebooting the limb's electronics."
	examine_desc = "jostles with every move, wires visible through cracks in the metal"
	occur_text = "visibly cracks open, metal pieces flying everywhere"
	severity = WOUND_SEVERITY_SEVERE
	simple_treat_text = "<b>If on the <b>chest</b>, <b>walk</b>, <b>grasp it</b>, <b>splint</b>, <b>rest</b> or <b>buckle yourself</b> to something to reduce movement effects. \
	Afterwards, <b>screwdriver/wrench</b> it, and then <b>reboot</b> the electronics inside!"
	homemade_treat_text = "If <b>unable to screw/wrench</b>, <b>bone gel</b> can secure inner components. \
	Alternatively, <b>crowbar</b> the limb open to expose the internals - this will make it <b>easier</b> to re-secure them, but has a <b>high risk</b> of <b>shocking</b> you, \
	so use insulated gloves. This will also <b>cripple the limb</b>, so use it only as a last resort!"
	treat_text_short = "Use a screwdriver or wrench, and then a multitool."

	wound_flags = (ACCEPTS_GAUZE|MANGLES_INTERIOR|CAN_BE_GRASPED)
	treatable_by = list(/obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/severe
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 60
	series_threshold_penalty = 30
	a_or_from = "from"
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	threshold_penalty = 5
	stagger_multiplier = 1.5
	/// If our external plating has been torn open and we can access our internals without a tool
	var/crowbarred_open = FALSE
	/// If internals are secured, and we are ready to restart electronics in the limb and end the wound
	var/ready_to_restart = FALSE

/datum/wound_pregen_data/blunt_metal/fastenings
	abstract = FALSE
	wound_path_to_generate = /datum/wound/blunt/robotic/severe
	threshold_minimum = 65

/datum/wound/blunt/robotic/severe/get_scanner_description(mob/user)
	. = ..()
	var/to_add = get_wound_status()
	if (!isnull(to_add))
		. += "\nWound status: [to_add]"

/datum/wound/blunt/robotic/severe/get_simple_scanner_description(mob/user)
	. = ..()
	var/to_add = get_wound_status()
	if (!isnull(to_add))
		. += "\nWound status: [to_add]"

/// Returns info specific to the dynamic state of the wound.
/datum/wound/blunt/robotic/severe/proc/get_wound_status(mob/user)
	if (crowbarred_open)
		. += "The limb has been torn open, allowing ease of access to internal components, but also disabling it. "
	if (ready_to_restart)
		. += "The components within have been secured, allowing them to be restarted using a multitool."

/datum/wound/blunt/robotic/severe/item_can_treat(obj/item/potential_treater, mob/user)
	if (ready_to_restart)
		if(potential_treater.tool_behaviour == TOOL_MULTITOOL)
			return TRUE
		return FALSE
	if(potential_treater.tool_behaviour == TOOL_CROWBAR && !crowbarred_open)
		return TRUE
	if (potential_treater.tool_behaviour == TOOL_SCREWDRIVER || potential_treater.tool_behaviour == TOOL_WRENCH || istype(potential_treater, /obj/item/stack/medical/bone_gel))
		return TRUE

/datum/wound/blunt/robotic/severe/treat(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_MULTITOOL)
		return restart(potential_treater, user)
	if (istype(potential_treater, /obj/item/stack/medical/bone_gel))
		return apply_gel(potential_treater, user)
	if (potential_treater.tool_behaviour == TOOL_CROWBAR)
		return crowbar_open(potential_treater, user)
	if (potential_treater.tool_behaviour == TOOL_SCREWDRIVER || potential_treater.tool_behaviour == TOOL_WRENCH)
		return secure_internals_normally(potential_treater, user)
	return ..()

/*
	Available during the screwdriver step of T2 and T3. Requires a crowbar. Improvised option.
	Tears open the limb, exposing internals. This guarantees the next screwdriver step succeeding, and removes the self-tend time penalty.
	Deals minor damage to the limb, and shocks the user (causing failure) if victim is alive, this limb is wired, and the crowbarrer is not insulated.
 */
/datum/wound/blunt/robotic/severe/proc/crowbar_open(obj/item/crowbarring_item, mob/living/user)
	if (!crowbarring_item.tool_start_check())
		return TRUE

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	var/self_message = span_warning("You start prying open [your_or_other] [limb.plaintext_zone] with [crowbarring_item][can_shock() ? ", risking electrocution" : ""]...")
	user?.visible_message(span_bolddanger("[user] starts prying open [their_or_other] [limb.plaintext_zone] with [crowbarring_item]!"), self_message, ignored_mobs = list(victim))

	var/victim_message
	if (user != victim) // this exists so we can do a userdanger
		victim_message = span_userdanger("[user] starts prying open your [limb.plaintext_zone] with [crowbarring_item]!")
	else
		victim_message = self_message
	to_chat(victim, victim_message)

	var/delay = 4 SECONDS / (user == victim ? 1 : 2)
	playsound(get_turf(crowbarring_item), 'sound/machines/airlock/airlock_alien_prying.ogg', 30, TRUE)
	if (!crowbarring_item.use_tool(target = victim, user = user, delay = delay, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	var/message = ""

	var/shock_damage = 20
	var/obj/item/stack/medical/wrap/gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if (gauze)
		shock_damage *= gauze.splint_factor // yay gauze
	var/successful_shock = user.electrocute_act(shock_damage, limb, flags = SHOCK_KNOCKDOWN)

	if (successful_shock && user && can_shock())
		message = span_boldwarning("[user] is shocked by [their_or_other] [limb.plaintext_zone]!")
		self_message = span_userdanger("You are shocked by [your_or_other] [limb.plaintext_zone]!")
		if (user != victim)
			victim_message = span_userdanger("[user] is shocked by your [limb.plaintext_zone] while [user.p_they()] tear it open!")

	if (successful_shock)
		var/other_shock_text = ""
		var/self_shock_text = ""
		other_shock_text = ", and is striken by bolts of electricity"
		self_shock_text = ", but are immediately shocked by the electricity contained within"
		message = span_boldwarning("[user] tears open [their_or_other] [limb.plaintext_zone] with [user.p_their()] crowbar[other_shock_text]!")
		self_message = span_warning("You tear open [your_or_other] [limb.plaintext_zone] with your crowbar[self_shock_text]!")
		if(user != victim)
			victim_message = span_userdanger("Your [limb.plaintext_zone] fragments and splinters as [user] tears it open with [user.p_their()] crowbar!")
		else
			victim_message = self_message

		playsound(get_turf(crowbarring_item), 'sound/effects/bang.ogg', 35, TRUE) // we did it!
		to_chat(user, span_green("You've torn [your_or_other] [limb.plaintext_zone] open, heavily damaging it but making it a lot easier to screwdriver the internals!"))
	limb.receive_damage(brute = 15, wound_bonus = CANT_WOUND, damage_source = crowbarring_item)
	crowbarred_open = TRUE
	user.visible_message(message, self_message, ignored_mobs = list(victim))
	to_chat(victim, victim_message)
	examine_desc = replacetext(examine_desc, "cracks", "large gaps")
	set_disabling(TRUE)
	return TRUE

/datum/wound/blunt/robotic/severe/proc/can_shock()
	return (victim.stat != DEAD && limb.biological_state & BIO_WIRED)

/datum/wound/blunt/robotic/severe/proc/secure_internals_normally(obj/item/securing_item, mob/user)
	if (!securing_item.tool_start_check())
		return TRUE

	var/chance = 50
	var/delay = 3 SECONDS

	if (user == victim && !crowbarred_open)
		chance /= 2
		delay *= 1.5
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 2
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 2
		delay *= 0.5

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	user?.visible_message(span_notice("[user] begins the delicate operation of securing the internals of [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin the delicate operation of securing the internals of [your_or_other] [limb.plaintext_zone]..."))

	if (!securing_item.use_tool(target = victim, user = user, delay = delay, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if (prob(chance) || crowbarred_open)
		user?.visible_message(span_green("[user] finishes securing the internals of [their_or_other] [limb.plaintext_zone]!"), \
			span_green("You finish securing the internals of [your_or_other] [limb.plaintext_zone]!"))
		to_chat(user, span_green("[capitalize(your_or_other)] [limb.plaintext_zone]'s internals are now secure, but still need to be rebooted."))
		make_ready_to_restart()
	else
		user?.visible_message(span_danger("[user] screws up and accidentally damages [their_or_other] [limb.plaintext_zone]!"))
		limb.receive_damage(brute = 5, damage_source = securing_item, wound_bonus = CANT_WOUND)

	return TRUE

/datum/wound/blunt/robotic/severe/proc/make_ready_to_restart()
	ready_to_restart = TRUE
	examine_desc = "twitches and sparks erratically."

// Alternative to securing the wires. Requires bone gel. Guaranteed to work.
/datum/wound/blunt/robotic/severe/proc/apply_gel(obj/item/stack/medical/bone_gel/gel, mob/user)
	var/delay_mult = 1.5
	if (victim == user)
		delay_mult *= 1.5
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.5

	user.visible_message(span_notice("[user] begins applying [gel] to [victim]'s [limb.plaintext_zone]."), span_warning("You begin applying [gel] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]."))
	if (!do_after(user, (3 SECONDS * delay_mult), target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	gel.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [gel] to [victim]'s [limb.plaintext_zone]!"), span_notice("You finish applying [gel] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [gel] to your [limb.plaintext_zone]."))
	else
		victim.visible_message(span_notice("[victim] finishes applying [gel] to [victim.p_their()] [limb.plaintext_zone]!"), span_notice("You finish applying [gel] to your [limb.plaintext_zone]."))

	to_chat(victim, span_green("The gel within your [limb.plaintext_zone] is holding down its components, allowing you to restart it!"))
	make_ready_to_restart()

/*
	The second step of T2/T3, requires a multitool.
	Once complete, removes the wound entirely.
*/
/datum/wound/blunt/robotic/severe/proc/restart(obj/item/multitool, mob/user)
	if (!multitool.tool_start_check())
		return TRUE

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	victim.visible_message(span_notice("[user] begins rebooting [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin restarting the electronics in [your_or_other] [limb.plaintext_zone]..."))

	var/delay = 6 SECONDS / (HAS_TRAIT(src, TRAIT_WOUND_SCANNED) ? 1 : 2)

	if (!multitool.use_tool(target = victim, user = user, delay = delay, volume = 50,  extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	victim.visible_message(span_green("[user] finishes rebooting [their_or_other] [limb.plaintext_zone]!"), \
		span_notice("You succesfully restart the electronics in [your_or_other] [limb.plaintext_zone]!"))
	remove_wound()
	return TRUE

/// Returns a string with our current treatment step for use in health analyzers.
/datum/wound/blunt/robotic/severe/proc/get_wound_step_info()

	if(ready_to_restart)
		. = "Apply a multitool to the limb to finalize repairs."
	else
		. = "Use a screwdriver, wrench, or bone gel to secure the internals of the limb. A diagnostic hud or wound scanner will help. \
		In absence of those, a crowbar may be used."

/datum/wound/blunt/robotic/severe/get_scanner_description(mob/user)
	. = ..()

	var/wound_step = get_wound_step_info()
	if (wound_step)
		. += "\n\n<b>Current step</b>: [span_notice(wound_step)]"

/datum/wound/blunt/robotic/severe/get_simple_scanner_description(mob/user)
	. = ..()

	var/wound_step = get_wound_step_info()
	if (wound_step)
		. += "\n\n<b>Current step</b>: [span_notice(wound_step)]"
/datum/wound/blunt/robotic/critical
	name = "Collapsed Superstructure"
	desc = "The superstructure has totally collapsed in one or more locations, causing extreme internal oscillation with every move and massive limb dysfunction"
	treat_text = "Bind the affected limb with gauze or a splint. Repair surgically."
	occur_text = "caves in on itself, damaged solder and shrapnel flying out in a miniature explosion"
	examine_desc = "has caved in, with internal components visible through gaps in the metal"
	severity = WOUND_SEVERITY_CRITICAL
	treat_text_short = "Repair surgically."
	disabling = TRUE
	simple_treat_text = "If on the <b>chest</b>, <b>walk</b>, <b>grasp it</b>, <b>splint</b>, <b>rest</b> or <b>buckle yourself</b> to something to reduce movement effects. \
	Afterwards, repair with surgery."
	homemade_treat_text = "The metal can be made <b>malleable</b> by repeated harmful application of any heated instrument until it carries a <b>moderate burn</b>. Afterwards, a <b>crowbar</b> can reset the metal, \
	reducing the severity of the wound."

	interaction_efficiency_penalty = 2.5
	limp_slowdown = 7
	limp_chance = 70
	threshold_penalty = 15
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical
	sound_effect = 'sound/effects/wounds/crack2.ogg'
	wound_flags = (ACCEPTS_GAUZE|MANGLES_INTERIOR|CAN_BE_GRASPED)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical
	treatable_tools = list(TOOL_CROWBAR)
	a_or_from = "a"
	stagger_multiplier = 1.75

/datum/wound_pregen_data/blunt_metal/superstructure
	abstract = FALSE
	wound_path_to_generate = /datum/wound/blunt/robotic/critical
	threshold_minimum = 125

/datum/wound/blunt/robotic/critical/treat(obj/item/item, mob/treater)
	var/delay = 4 SECONDS / (HAS_TRAIT(src, TRAIT_WOUND_SCANNED) ? 2 : 1)
	if(!limb.get_wound_type(WOUND_SERIES_METAL_BURN_OVERHEAT) || victim?.bodytemperature < BODYTEMP_HEAT_WARNING_3)
		to_chat(treater, span_warning("The metal isn't hot enough to bend back into place!"))
		return
	if(item.use_tool(target = victim, user = treater, delay = delay, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		replace_wound(new /datum/wound/blunt/robotic/severe)
	return ..()
