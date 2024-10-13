/// A subtype of blunt wounds that has a "secure internals" step
/datum/wound/blunt/robotic/secures_internals
	/// Our current counter for gel + gauze regeneration
	var/regen_time_elapsed = 0 SECONDS
	/// Time needed for gel to secure internals.
	var/regen_time_needed = 30 SECONDS

	/// If we have used bone gel to secure internals.
	var/gelled = FALSE
	/// Total brute damage taken over the span of [regen_time_needed] deciseconds when we gel our limb.
	var/gel_damage = 10 // brute in total

	/// If we are ready to begin screwdrivering or gelling our limb.
	var/ready_to_secure_internals = FALSE
	/// If our external plating has been torn open and we can access our internals without a tool
	var/crowbarred_open = FALSE
	/// If internals are secured, and we are ready to weld our limb closed and end the wound
	var/ready_to_resolder = TRUE

/datum/wound/blunt/robotic/secures_internals/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	if (gelled)
		regen_time_elapsed += ((seconds_per_tick SECONDS) / 2)
		if(victim.body_position == LYING_DOWN)
			if(SPT_PROB(30, seconds_per_tick))
				regen_time_elapsed += 1 SECONDS
			if(victim.IsSleeping() && SPT_PROB(30, seconds_per_tick))
				regen_time_elapsed += 1 SECONDS

		var/effective_damage = ((gel_damage / (regen_time_needed / 10)) * seconds_per_tick)
		var/obj/item/stack/gauze = limb.current_gauze
		if (gauze)
			effective_damage *= gauze.splint_factor
		limb.receive_damage(effective_damage, wound_bonus = CANT_WOUND, damage_source = src)
		if(effective_damage && prob(33))
			var/gauze_text = (gauze?.splint_factor ? ", although the [gauze] helps to prevent some of the leakage" : "")
			to_chat(victim, span_danger("Your [limb.plaintext_zone] sizzles as some gel leaks and warps the exterior metal[gauze_text]..."))

		if(regen_time_elapsed > regen_time_needed)
			if(!victim || !limb)
				qdel(src)
				return
			to_chat(victim, span_green("The gel within your [limb.plaintext_zone] has fully hardened, allowing you to re-solder it!"))
			gelled = FALSE
			ready_to_resolder = TRUE
			ready_to_secure_internals = FALSE
			set_disabling(FALSE)

/datum/wound/blunt/robotic/secures_internals/modify_desc_before_span(desc)
	. = ..()

	var/use_exclamation = FALSE

	if (!limb.current_gauze) // gauze covers it up
		if (crowbarred_open)
			. += ", [span_notice("and is violently torn open, internals visible to the outside")]"
			use_exclamation = TRUE
		if (gelled)
			. += ", [span_notice("with fizzling blue surgical gel leaking out of the cracks")]"
			use_exclamation = TRUE
		if (use_exclamation)
			. += "!"

/datum/wound/blunt/robotic/secures_internals/get_scanner_description(mob/user)
	. = ..()

	var/to_add = get_wound_status()
	if (!isnull(to_add))
		. += "\nWound status: [to_add]"

/datum/wound/blunt/robotic/secures_internals/get_simple_scanner_description(mob/user)
	. = ..()

	var/to_add = get_wound_status()
	if (!isnull(to_add))
		. += "\nWound status: [to_add]"

/// Returns info specific to the dynamic state of the wound.
/datum/wound/blunt/robotic/secures_internals/proc/get_wound_status(mob/user)
	if (crowbarred_open)
		. += "The limb has been torn open, allowing ease of access to internal components, but also disabling it. "
	if (gelled)
		. += "Bone gel has been applied, causing progressive corrosion of the metal, but eventually securing the internals. "

/datum/wound/blunt/robotic/secures_internals/item_can_treat(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_WELDER || potential_treater.tool_behaviour == TOOL_CAUTERY)
		if (ready_to_resolder)
			return TRUE

	if (ready_to_secure_internals)
		if (item_can_secure_internals(potential_treater))
			return TRUE

	return ..()

/datum/wound/blunt/robotic/secures_internals/treat(obj/item/potential_treater, mob/user)
	if (ready_to_secure_internals)
		if (istype(potential_treater, /obj/item/stack/medical/bone_gel))
			return apply_gel(potential_treater, user)
		else if (!crowbarred_open && potential_treater.tool_behaviour == TOOL_CROWBAR)
			return crowbar_open(potential_treater, user)
		else if (item_can_secure_internals(potential_treater))
			return secure_internals_normally(potential_treater, user)
	else if (ready_to_resolder && (potential_treater.tool_behaviour == TOOL_WELDER) || (potential_treater.tool_behaviour == TOOL_CAUTERY))
		return resolder(potential_treater, user)

	return ..()

/// Returns TRUE if the item can be used in our 1st step (2nd if T3) of repairs.
/datum/wound/blunt/robotic/secures_internals/proc/item_can_secure_internals(obj/item/potential_treater)
	return (potential_treater.tool_behaviour == TOOL_SCREWDRIVER || potential_treater.tool_behaviour == TOOL_WRENCH || istype(potential_treater, /obj/item/stack/medical/bone_gel))

#define CROWBAR_OPEN_SELF_TEND_DELAY_MULT 2
#define CROWBAR_OPEN_KNOWS_ROBO_WIRES_DELAY_MULT 0.5
#define CROWBAR_OPEN_KNOWS_ENGI_WIRES_DELAY_MULT 0.5
#define CROWBAR_OPEN_HAS_DIAG_HUD_DELAY_MULT 0.5
#define CROWBAR_OPEN_WOUND_SCANNED_DELAY_MULT 0.5
/// If our limb is essential, damage dealt to it by tearing it open will be multiplied against this.
#define CROWBAR_OPEN_ESSENTIAL_LIMB_DAMAGE_MULT 1.5

/// The "power" put into electrocute_act whenever someone gets shocked when they crowbar open our limb
#define CROWBAR_OPEN_SHOCK_POWER 20
/// The brute damage done to this limb (doubled on essential limbs) when it is crowbarred open
#define CROWBAR_OPEN_BRUTE_DAMAGE 20

/**
 * Available during the "secure internals" step of T2 and T3. Requires a crowbar. Low-quality ghetto option.
 *
 * Tears open the limb, exposing internals. This massively increases the chance of secure internals succeeding, and removes the self-tend malice.
 *
 * Deals significant damage to the limb, and shocks the user (causing failure) if victim is alive, this limb is wired, and user is not insulated.
 */
/datum/wound/blunt/robotic/secures_internals/proc/crowbar_open(obj/item/crowbarring_item, mob/living/user)
	if (!crowbarring_item.tool_start_check())
		return TRUE

	var/delay_mult = 1
	if (user == victim)
		delay_mult *= CROWBAR_OPEN_SELF_TEND_DELAY_MULT

	var/knows_wires = FALSE
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= CROWBAR_OPEN_KNOWS_ROBO_WIRES_DELAY_MULT
		knows_wires = TRUE
	else if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= CROWBAR_OPEN_KNOWS_ENGI_WIRES_DELAY_MULT
		knows_wires = TRUE
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		if (knows_wires)
			delay_mult *= (CROWBAR_OPEN_HAS_DIAG_HUD_DELAY_MULT * 1.5)
		else
			delay_mult *= CROWBAR_OPEN_HAS_DIAG_HUD_DELAY_MULT
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= CROWBAR_OPEN_WOUND_SCANNED_DELAY_MULT

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

	playsound(get_turf(crowbarring_item), 'sound/machines/airlock/airlock_alien_prying.ogg', 30, TRUE)
	if (!crowbarring_item.use_tool(target = victim, user = user, delay = (7 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	var/limb_can_shock = (victim.stat != DEAD && limb.biological_state & BIO_WIRED) // re-define the previous shock variable because we slept
	var/stunned = FALSE

	var/message

	if (user && limb_can_shock)
		var/electrocute_flags = (SHOCK_KNOCKDOWN|SHOCK_NO_HUMAN_ANIM|SHOCK_SUPPRESS_MESSAGE)
		var/stun_chance = 100

		if (HAS_TRAIT(user, TRAIT_SHOCKIMMUNE))
			stun_chance = 0

		else if (iscarbon(user)) // doesn't matter if we're shock immune, it's set to 0 anyway
			var/mob/living/carbon/carbon_user = user
			if (carbon_user.gloves)
				stun_chance *= carbon_user.gloves.siemens_coefficient

			if (ishuman(user))
				var/mob/living/carbon/human/human_user = user
				stun_chance *= human_user.physiology.siemens_coeff
			stun_chance *= carbon_user.dna.species.siemens_coeff

		if (stun_chance && prob(stun_chance))
			electrocute_flags &= ~SHOCK_KNOCKDOWN
			electrocute_flags &= ~SHOCK_NO_HUMAN_ANIM
			stunned = TRUE

			message = span_boldwarning("[user] is shocked by [their_or_other] [limb.plaintext_zone], [user.p_their()] crowbar slipping as [user.p_they()] briefly convulse!")
			self_message = span_userdanger("You are shocked by [your_or_other] [limb.plaintext_zone], causing your crowbar to slip out!")
			if (user != victim)
				victim_message = span_userdanger("[user] is shocked by your [limb.plaintext_zone] in [user.p_their()] efforts to tear it open!")

		var/shock_damage = CROWBAR_OPEN_SHOCK_POWER
		if (limb.current_gauze)
			shock_damage *= limb.current_gauze.splint_factor // always good to let gauze do something
		user.electrocute_act(shock_damage, limb, flags = electrocute_flags)

	if (!stunned)
		var/other_shock_text = ""
		var/self_shock_text = ""
		if (!limb_can_shock)
			other_shock_text = ", and is striken by golden bolts of electricity"
			self_shock_text = ", but are immediately shocked by the electricity contained within"
		message = span_boldwarning("[user] tears open [their_or_other] [limb.plaintext_zone] with [user.p_their()] crowbar[other_shock_text]!")
		self_message = span_warning("You tear open [your_or_other] [limb.plaintext_zone] with your crowbar[self_shock_text]!")
		if (user != victim)
			victim_message = span_userdanger("Your [limb.plaintext_zone] fragments and splinters as [user] tears it open with [user.p_their()] crowbar!")

		playsound(get_turf(crowbarring_item), 'sound/effects/bang.ogg', 35, TRUE) // we did it!
		to_chat(user, span_green("You've torn [your_or_other] [limb.plaintext_zone] open, heavily damaging it but making it a lot easier to screwdriver the internals!"))
		var/damage = CROWBAR_OPEN_BRUTE_DAMAGE
		if (limb_essential()) // can't be disabled
			damage *= CROWBAR_OPEN_ESSENTIAL_LIMB_DAMAGE_MULT
		limb.receive_damage(brute = CROWBAR_OPEN_BRUTE_DAMAGE, wound_bonus = CANT_WOUND, damage_source = crowbarring_item)
		set_torn_open(TRUE)

	if (user == victim)
		victim_message = self_message

	user.visible_message(message, self_message, ignored_mobs = list(victim))
	to_chat(victim, victim_message)
	return TRUE

#undef CROWBAR_OPEN_SELF_TEND_DELAY_MULT
#undef CROWBAR_OPEN_KNOWS_ROBO_WIRES_DELAY_MULT
#undef CROWBAR_OPEN_KNOWS_ENGI_WIRES_DELAY_MULT
#undef CROWBAR_OPEN_HAS_DIAG_HUD_DELAY_MULT
#undef CROWBAR_OPEN_WOUND_SCANNED_DELAY_MULT
#undef CROWBAR_OPEN_ESSENTIAL_LIMB_DAMAGE_MULT

#undef CROWBAR_OPEN_BRUTE_DAMAGE
#undef CROWBAR_OPEN_SHOCK_POWER

/// Sets [crowbarred_open] to the new value. If we werent originally disabling, or if we arent currently and we're torn open, we set disabling to true.
/datum/wound/blunt/robotic/secures_internals/proc/set_torn_open(torn_open_state)
	// if we aren't disabling but we were torn open, OR if we aren't disabling by default
	var/should_update_disabling = ((!disabling && torn_open_state) || !initial(disabling))

	crowbarred_open = torn_open_state
	if(should_update_disabling)
		set_disabling(torn_open_state)

/// If, on a secure internals attempt, we have less than this chance to succeed, we warn the user.
#define SECURE_INTERNALS_CONFUSED_CHANCE_THRESHOLD 25
#define SECURE_INTERNALS_FAILURE_BRUTE_DAMAGE 5

/**
 * The primary way of performing the secure internals step for T2/T3. Uses a screwdriver/wrench. Very hard to do by yourself, or without a diag hud/wire knowledge.
 * Roboticists/engineers have a very high chance of succeeding.
 * Deals some brute damage on failure, but moves to the final step of treatment (re-soldering) on success.
 *
 * If [crowbarred_open], made far more likely and remove the self-tend malice.
 */
/datum/wound/blunt/robotic/secures_internals/proc/secure_internals_normally(obj/item/securing_item, mob/user)
	if (!securing_item.tool_start_check())
		return TRUE

	var/chance = 10
	var/delay_mult = 1

	if (user == victim)
		if (!crowbarred_open)
			chance *= 0.2
		delay_mult *= 2

	var/knows_wires = FALSE
	if (crowbarred_open)
		chance *= 4 // even self-tends get a high chance of success if torn open!
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		chance *= 8 // almost guaranteed if it's not self surgery - guaranteed with diag hud
		delay_mult *= 0.75
		knows_wires = TRUE
	else if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 5.5
		delay_mult *= 0.85
		knows_wires = TRUE
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		if (knows_wires)
			chance *= 1.25 // ((10 * 8) * 1.25) = 100%
		else
			chance *= 4
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 1.5 // youre not intended to fix this by yourself this way
		delay_mult *= 0.8

	var/confused = (chance < SECURE_INTERNALS_CONFUSED_CHANCE_THRESHOLD) // generate chance beforehand, so we can use this var

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	user?.visible_message(span_notice("[user] begins the delicate operation of securing the internals of [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin the delicate operation of securing the internals of [your_or_other] [limb.plaintext_zone]..."))
	if (confused)
		to_chat(user, span_warning("You are confused by the layout of [your_or_other] [limb.plaintext_zone]! A diagnostic hud would help, as would knowing robo/engi wires! You could also tear the limb open with a crowbar, or get someone else to help."))

	if (!securing_item.use_tool(target = victim, user = user, delay = (10 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if (prob(chance))
		user?.visible_message(span_green("[user] finishes securing the internals of [their_or_other] [limb.plaintext_zone]!"), \
			span_green("You finish securing the internals of [your_or_other] [limb.plaintext_zone]!"))
		to_chat(user, span_green("[capitalize(your_or_other)] [limb.plaintext_zone]'s internals are now secure! Your next step is to weld/cauterize it."))
		ready_to_secure_internals = FALSE
		ready_to_resolder = TRUE
	else
		user?.visible_message(span_danger("[user] screws up and accidentally damages [their_or_other] [limb.plaintext_zone]!"))
		limb.receive_damage(brute = SECURE_INTERNALS_FAILURE_BRUTE_DAMAGE, damage_source = securing_item, wound_bonus = CANT_WOUND)

	return TRUE

#undef SECURE_INTERNALS_CONFUSED_CHANCE_THRESHOLD
#undef SECURE_INTERNALS_FAILURE_BRUTE_DAMAGE

/**
 * "Premium" ghetto option of the secure internals step for T2/T3. Requires bone gel. Guaranteed to work.
 * Deals damage over time and disables the limb, but finishes the step afterwards.
 */
/datum/wound/blunt/robotic/secures_internals/proc/apply_gel(obj/item/stack/medical/bone_gel/gel, mob/user)
	if (gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already filled with bone gel!"))
		return TRUE

	var/delay_mult = 1
	if (victim == user)
		delay_mult *= 1.5

	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	user.visible_message(span_danger("[user] begins hastily applying [gel] to [victim]'s [limb.plaintext_zone]..."), span_warning("You begin hastily applying [gel] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone], disregarding the acidic effect it seems to have on the metal..."))

	if (!do_after(user, (6 SECONDS * delay_mult), target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	gel.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [gel] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [gel] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [gel] to your [limb.plaintext_zone], and you can hear the sizzling of the metal..."))
	else
		victim.visible_message(span_notice("[victim] finishes applying [gel] to [victim.p_their()] [limb.plaintext_zone], emitting a funny fizzing sound!"), span_notice("You finish applying [gel] to your [limb.plaintext_zone], and you can hear the sizzling of the metal..."))

	gelled = TRUE
	set_disabling(TRUE)
	processes = TRUE
	return TRUE

/**
 * The final step of T2/T3, requires a welder/cautery. Guaranteed to work. Cautery is slower.
 * Once complete, removes the wound entirely.
 */
/datum/wound/blunt/robotic/secures_internals/proc/resolder(obj/item/welding_item, mob/user)
	if (!welding_item.tool_start_check())
		return TRUE

	var/their_or_other = (user == victim ? "[user.p_their()]" : "[victim]'s")
	var/your_or_other = (user == victim ? "your" : "[victim]'s")
	victim.visible_message(span_notice("[user] begins re-soldering [their_or_other] [limb.plaintext_zone]..."), \
		span_notice("You begin re-soldering [your_or_other] [limb.plaintext_zone]..."))

	var/delay_mult = 1
	if (welding_item.tool_behaviour == TOOL_CAUTERY)
		delay_mult *= 3 // less efficient
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	if (!welding_item.use_tool(target = victim, user = user, delay = 7 SECONDS * delay_mult, volume = 50,  extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	victim.visible_message(span_green("[user] finishes re-soldering [their_or_other] [limb.plaintext_zone]!"), \
		span_notice("You finish re-soldering [your_or_other] [limb.plaintext_zone]!"))
	remove_wound()
	return TRUE

/// Returns a string with our current treatment step for use in health analyzers.
/datum/wound/blunt/robotic/secures_internals/proc/get_wound_step_info()
	var/string

	if (ready_to_resolder)
		string = "Apply a welder/cautery to the limb to finalize repairs."
	else if (ready_to_secure_internals)
		string = "Use a screwdriver/wrench to secure the internals of the limb. This step is best performed by a qualified technician. \
		In absence of one, bone gel or a crowbar may be used."

	return string

/datum/wound/blunt/robotic/secures_internals/get_scanner_description(mob/user)
	. = ..()

	var/wound_step = get_wound_step_info()
	if (wound_step)
		. += "\n\n<b>Current step</b>: [span_notice(wound_step)]"

/datum/wound/blunt/robotic/secures_internals/get_simple_scanner_description(mob/user)
	. = ..()

	var/wound_step = get_wound_step_info()
	if (wound_step)
		. += "\n\n<b>Current step</b>: [span_notice(wound_step)]"
