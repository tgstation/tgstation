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

	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES

	threshold_penalty = 5
	series_threshold_penalty = 30

	base_movement_stagger_score = 40

	chest_attacked_stagger_chance_ratio = 5
	chest_attacked_stagger_mult = 3

	chest_movement_stagger_chance = 2

	stagger_aftershock_knockdown_ratio = 0.3
	stagger_aftershock_knockdown_movement_ratio = 0.2

	a_or_from = "from"

	/// If our external plating has been torn open and we can access our internals without a tool
	var/crowbarred_open = FALSE
	/// If internals are secured, and we are ready to restart electronics in the limb and end the wound
	var/ready_to_restart = FALSE

/datum/wound_pregen_data/blunt_metal/fastenings
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/robotic/severe

	threshold_minimum = 65

/datum/wound/blunt/robotic/severe/modify_desc_before_span(desc)
	. = ..()

	if (!LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)) // gauze covers it up
		if (crowbarred_open)
			. += ", [span_notice("and is torn open, internals visible to the outside!")]"

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
		. += "The limb has been partially secured, allowing the electronics within to be restarted by a multitool."

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

/**
 * Available during the "secure internals" step of T2 and T3. Requires a crowbar. Low-quality ghetto option.
 *
 * Tears open the limb, exposing internals. This massively increases the chance of secure internals succeeding, and removes the self-tend malice.
 *
 * Deals significant damage to the limb, and shocks the user (causing failure) if victim is alive, this limb is wired, and user is not insulated.
 */
/datum/wound/blunt/robotic/severe/proc/crowbar_open(obj/item/crowbarring_item, mob/living/user)
	if (!crowbarring_item.tool_start_check())
		return TRUE


	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")

	var/limb_can_shock_pre_sleep = (victim.stat != DEAD && limb.biological_state & BIO_WIRED)
	var/shock_or_not = (limb_can_shock_pre_sleep ? ", risking electrocution" : "")
	var/self_message = span_warning("You start prying open [your_or_other] [limb.plaintext_zone] with [crowbarring_item][shock_or_not]...")

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
	var/limb_can_shock = (victim.stat != DEAD && limb.biological_state & BIO_WIRED) // re-define the previous shock variable because we slept

	var/shock_damage = 20
	var/obj/item/stack/medical/wrap/gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if (gauze)
		shock_damage *= gauze.splint_factor // yay gauze
	var/successful_shock = user.electrocute_act(shock_damage, limb, flags = SHOCK_KNOCKDOWN)

	if (successful_shock && user && limb_can_shock)
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
	return TRUE

/datum/wound/blunt/robotic/severe/proc/secure_internals_normally(obj/item/securing_item, mob/user)
	if (!securing_item.tool_start_check())
		return TRUE

	var/chance = 50
	var/delay_mult = 1.5

	if (user == victim)
		chance /= 2
		delay_mult *= 1.5
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 2
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 2
		delay_mult *= 0.5

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	user?.visible_message(span_notice("[user] begins the delicate operation of securing the internals of [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin the delicate operation of securing the internals of [your_or_other] [limb.plaintext_zone]..."))

	if (!securing_item.use_tool(target = victim, user = user, delay = (3 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if (prob(chance) || crowbarred_open)
		user?.visible_message(span_green("[user] finishes securing the internals of [their_or_other] [limb.plaintext_zone]!"), \
			span_green("You finish securing the internals of [your_or_other] [limb.plaintext_zone]!"))
		to_chat(user, span_green("[capitalize(your_or_other)] [limb.plaintext_zone]'s internals are now secure, but still need to be welded into place."))
		ready_to_restart = TRUE
	else
		user?.visible_message(span_danger("[user] screws up and accidentally damages [their_or_other] [limb.plaintext_zone]!"))
		limb.receive_damage(brute = 5, damage_source = securing_item, wound_bonus = CANT_WOUND)

	return TRUE

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
	ready_to_restart = TRUE

/**
 * The final step of T2/T3, requires a welder. Guaranteed to work. Cautery is slower.
 * Once complete, removes the wound entirely.
 */
/datum/wound/blunt/robotic/severe/proc/restart(obj/item/multitool, mob/user)
	if (!multitool.tool_start_check())
		return TRUE

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	victim.visible_message(span_notice("[user] begins re-soldering [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin restarting the electronics in [your_or_other] [limb.plaintext_zone]..."))

	var/delay = 6 SECONDS / (HAS_TRAIT(src, TRAIT_WOUND_SCANNED) ? 1 : 2)

	if (!multitool.use_tool(target = victim, user = user, delay = delay, volume = 50,  extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	victim.visible_message(span_green("[user] finishes re-soldering [their_or_other] [limb.plaintext_zone]!"), \
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
