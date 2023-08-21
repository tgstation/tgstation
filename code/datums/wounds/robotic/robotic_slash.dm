#define ELECTRICAL_DAMAGE_ON_STASIS_MULT 0.1
#define ELECTRICAL_DAMAGE_GRASPED_MULT 0.5
#define ELECTRICAL_DAMAGE_LYING_DOWN_MULT 0.5

#define ELECTRICAL_DAMAGE_WIRECUTTER_BASE_DELAY 4 SECONDS
#define ELECTRICAL_DAMAGE_SUTURE_WIRE_BASE_DELAY 1 SECONDS

/datum/wound/electrical_damage
	name = "Electrical (Wires) Wound"

	wound_flags = (ACCEPTS_GAUZE)

	treatable_tool = TOOL_WIRECUTTER
	treatable_by = list(/obj/item/stack/medical/suture)
	treatable_by_grabbed = list(/obj/item/stack/cable_coil)

	var/wiring_reset = FALSE

	var/initial_sparks_amount

	var/shock_immunity_self_damage_reduction = 75

	var/time_processed = 0
	var/processing_full_shock_threshold

	var/processing_shock_power_per_second_min
	var/processing_shock_power_per_second_max

	/// In the case we get below 1 power, we add the power to this buffer and use it next tick
	var/processing_shock_power_this_tick
	var/processing_shock_stun_chance
	var/processing_shock_spark_chance
	var/process_shock_message_chance = 80

	var/process_shock_spark_count_min
	var/process_shock_spark_count_max

	var/wirecut_repair_percent
	var/wire_repair_percent

	processes = TRUE

/datum/wound_pregen_data/electrical_damage
	abstract = TRUE

	required_limb_biostate = (BIO_WIRED)

/datum/wound/electrical_damage/handle_process(seconds_per_tick, times_fired)
	. = ..()

	/*if (!(limb.body_zone == BODY_ZONE_CHEST || limb.body_zone == BODY_ZONE_HEAD))
		return*/

	var/base_mult = 1
	if (IS_IN_STASIS(victim))
		base_mult *= ELECTRICAL_DAMAGE_ON_STASIS_MULT
	if (limb.grasped_by)
		base_mult *= ELECTRICAL_DAMAGE_GRASPED_MULT
	if (victim.body_position == LYING_DOWN)
		base_mult *= ELECTRICAL_DAMAGE_LYING_DOWN_MULT

	var/seconds_per_tick_for_intensity = (seconds_per_tick * base_mult)
	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		seconds_per_tick_for_intensity *= limb.current_gauze.splint_factor

	adjust_processed(seconds_per_tick_for_intensity SECONDS)

	if (victim.stat == DEAD)
		return

	var/damage_mult = base_mult * get_base_zap_damage_mult(victim)
	var/intensity = get_intensity()

	damage_mult *= seconds_per_tick
	damage_mult *= intensity

	var/picked_damage = LERP(processing_shock_power_per_second_min, processing_shock_power_per_second_max, rand())
	processing_shock_power_this_tick += (picked_damage * damage_mult)
	if (processing_shock_power_this_tick > 1)
		var/stun_chance = (processing_shock_stun_chance * intensity) * base_mult
		var/spark_chance = (processing_shock_spark_chance * intensity) * base_mult

		//var/jitter_time = seconds_per_tick
		//var/stutter_time = 0

		var/should_stun = SPT_PROB(stun_chance, seconds_per_tick)
		var/should_message = SPT_PROB(process_shock_message_chance, seconds_per_tick)

		zap(victim,
			processing_shock_power_this_tick,
			stun = should_stun,
			spark = SPT_PROB(spark_chance, seconds_per_tick),
			animation = should_stun, message = FALSE,
			message = should_stun,
			tell_victim_if_no_message = should_message,
			ignore_immunity = TRUE,
			jitter_time = seconds_per_tick,
			stutter_time = 0,
			delay_stun = TRUE,
			knockdown = TRUE,
			ignore_gloves = TRUE
		)
		processing_shock_power_this_tick = 0

/datum/wound/electrical_damage/proc/adjust_processed(to_adjust)
	time_processed = clamp((time_processed + to_adjust), 0, processing_full_shock_threshold)

/datum/wound/electrical_damage/wound_injury(datum/wound/electrical_damage/old_wound, attack_direction)
	. = ..()

	if (old_wound)
		time_processed = old_wound.time_processed
		processing_shock_power_this_tick = old_wound.processing_shock_power_this_tick

	do_sparks(initial_sparks_amount, FALSE, victim)

/datum/wound/electrical_damage/modify_desc_before_span(desc, mob/user)
	. = ..()

	if (limb.current_gauze)
		return

	var/intensity = get_intensity()
	if (intensity < 0.2 || (victim.stat == DEAD))
		return

	. += ", and "

	var/extra
	switch (intensity)
		if (0.2 to 0.4)
			extra += "[span_deadsay("is letting out some sparks")]"
		if (0.4 to 0.6)
			extra += "[span_deadsay("is sparking quite a bit")]"
		if (0.6 to 0.8)
			extra += "[span_deadsay("is practically hemorrhaging sparks")]"
		if (0.8 to 1)
			extra += "[span_deadsay("has golden bolts of electricity constantly striking the surface")]"

	. += extra

/datum/wound/electrical_damage/get_scanner_description(mob/user)
	. = ..()

	. += " Fault intensity is currently at [span_bold("[get_intensity() * 100]")]%."

/datum/wound/electrical_damage/item_can_treat(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_HEMOSTAT)
		return TRUE

	if (istype(potential_treater, /obj/item/stack/cable_coil) && (limb.burn_dam <= 5))
		return TRUE

	return ..()

/datum/wound/electrical_damage/treat(obj/item/treating_item, mob/user)
	if (treating_item.tool_behaviour == TOOL_WIRECUTTER || treating_item.tool_behaviour == TOOL_HEMOSTAT)
		return wirecut(treating_item, user)

	if (istype(treating_item, /obj/item/stack/medical/suture) || istype(treating_item, /obj/item/stack/cable_coil))
		return suture_wires(treating_item, user)

	return ..()

/datum/wound/electrical_damage/proc/suture_wires(obj/item/stack/suturing_item, mob/living/carbon/human/user)
	if (!suturing_item.tool_start_check())
		return TRUE

	var/is_suture = (istype(suturing_item, /obj/item/stack/medical/suture))

	var/change = (processing_full_shock_threshold * wire_repair_percent)
	var/delay_mult = 1
	if (user == victim)
		delay_mult *= 4.5
	if (is_suture)
		delay_mult *= 3
		change *= 0.6
		var/obj/item/stack/medical/suture/suture_item = suturing_item
		var/obj/item/stack/medical/suture/base_suture = /obj/item/stack/medical/suture
		change += (suture_item.heal_brute - initial(base_suture.heal_brute))
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= 0.75
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.75

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	var/your_or_other = (user == victim ? "your" : "[user]'s")
	var/replacing_or_suturing = (is_suture ? "repairing some" : "replacing")
	if (!wiring_reset)
		to_chat(user, span_warning("You notice the wiring within [your_or_other] [limb.plaintext_zone] is still loose... you might shock yourself!"))
		delay_mult *= 9

	while (suturing_item.tool_start_check())
		user?.visible_message(span_warning("[user] begins [replacing_or_suturing] wiring within [their_or_other] [limb.plaintext_zone] with [suturing_item]..."), ignored_mobs = list(user))
		if (!suturing_item.use_tool(target = victim, user = user, delay = ELECTRICAL_DAMAGE_SUTURE_WIRE_BASE_DELAY * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
			return TRUE

		if (user != victim && user.combat_mode)
			user?.visible_message(span_danger("[user] mangles some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_processed(change)
			set_wiring_status(FALSE, user)
		else
			var/repairs_or_replaces = (is_suture ? "repairs" : "replaces")
			user?.visible_message(span_green("[user] [repairs_or_replaces] some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_processed(-change)

			if (!wiring_reset)
				user?.electrocute_act(max(process_shock_spark_count_max * get_intensity(), 1), limb)
				set_wiring_status(TRUE, user)

			suturing_item.use(1)

		if (remove_if_fixed())
			return TRUE
	return TRUE

/datum/wound/electrical_damage/proc/wirecut(obj/item/wirecutting_tool, mob/living/carbon/human/user)
	if (!wirecutting_tool.tool_start_check())
		return TRUE

	var/is_hemostat = (wirecutting_tool.tool_behaviour == TOOL_HEMOSTAT)

	var/change = (processing_full_shock_threshold * wirecut_repair_percent)
	var/delay_mult = 1
	if (user == victim)
		delay_mult *= 3
	if (is_hemostat)
		delay_mult *= 2
		change *= 0.8
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= 0.75
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.75

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	while (wirecutting_tool.tool_start_check())
		user?.visible_message(span_warning("[user] begins resetting misplaced wiring within [their_or_other] [limb.plaintext_zone]..."), ignored_mobs = list(user))
		if (!wirecutting_tool.use_tool(target = victim, user = user, delay = ELECTRICAL_DAMAGE_WIRECUTTER_BASE_DELAY * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
			return TRUE

		if (user != victim && user.combat_mode)
			user?.visible_message(span_danger("[user] mangles some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_processed(change)
			set_wiring_status(FALSE, user)
		else
			user?.visible_message(span_green("[user] resets some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_processed(-change)
			set_wiring_status(TRUE, user)

		if (remove_if_fixed())
			return TRUE
	return TRUE

/datum/wound/electrical_damage/proc/set_wiring_status(reset, mob/user)
	if (!wiring_reset && reset)
		if (user)
			var/your_or_other = (user == victim ? "your" : "[user]'s")
			to_chat(user, span_green("The wires in [your_or_other]'s [limb.plaintext_zone] are set! You can now safely use wires/sutures."))
	wiring_reset = reset

/datum/wound/electrical_damage/proc/remove_if_fixed()
	if (time_processed <= 0)
		to_chat(victim, span_green("Your [limb.plaintext_zone] has recovered from its [name]!"))
		remove_wound()
		return TRUE
	return FALSE

/datum/wound/electrical_damage/proc/get_intensity()
	return (min((time_processed / processing_full_shock_threshold), 1))

/datum/wound/electrical_damage/proc/zap(
		mob/living/target,
		damage,
		coeff = 1,
		stun,
		spark = TRUE,
		animation = TRUE,
		message = TRUE,
		ignore_immunity = FALSE,
		delay_stun = FALSE,
		knockdown = FALSE,
		ignore_gloves = FALSE,
		tell_victim_if_no_message = TRUE,
		jitter_time = 20 SECONDS,
		stutter_time = 4 SECONDS)

	var/flags = NONE
	if (!stun)
		flags |= SHOCK_NOSTUN
	if (!animation)
		flags |= SHOCK_NOHUMANANIM
	if (!message)
		flags |= SHOCK_SUPPRESS_MESSAGE
		if (tell_victim_if_no_message && target == victim)
			to_chat(target, span_warning("Your [limb.plaintext_zone] short-circuits and zaps you!"))
	if (ignore_immunity)
		flags |= SHOCK_IGNORE_IMMUNITY
	if (delay_stun)
		flags |= SHOCK_DELAY_STUN
	if (knockdown)
		flags |= SHOCK_KNOCKDOWN
	if (ignore_gloves)
		flags |= SHOCK_NOGLOVES

	target.electrocute_act(damage, limb, coeff, flags, jitter_time, stutter_time)
	if (spark)
		do_sparks(rand(process_shock_spark_count_min, process_shock_spark_count_max), FALSE, victim)

/datum/wound/electrical_damage/proc/can_zap(atom/target = victim, atom/connecting_item, uses_victim_hands, uses_target_hands)
	if (!isliving(target))
		return FALSE
	if (target != victim)
		if (!isnull(connecting_item))
			return FALSE
		if (HAS_TRAIT(target, TRAIT_SHOCKIMMUNE))
			return FALSE
		if (uses_victim_hands && victim.wearing_shock_proof_gloves())
			return FALSE
		if (uses_target_hands && iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			if (carbon_target.wearing_shock_proof_gloves())
				return FALSE

	return TRUE

/datum/wound/electrical_damage/proc/get_base_zap_damage_mult(atom/target)
	SHOULD_BE_PURE(TRUE)

	var/mult = 1

	if (HAS_TRAIT(target, TRAIT_SHOCKIMMUNE))
		if (target == victim)
			mult *= shock_immunity_self_damage_reduction
		else
			return 0

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		mult *= gauze.splint_factor

	/*if (isobj(connecting_item))
		var/obj/connecting_obj = connecting_item
		var/total = connecting_obj.get_custom_material_amount()
		var/conductive_ratio = 0
		for (var/datum/material/iterated_material as anything in connecting_obj.custom_materials)
			if (!iterated_material.categories[MAT_CATEGORY_CONDUCTIVE])
				continue
			var/amount = connecting_obj.custom_materials[iterated_material]
			if (!amount)
				continue
			conductive_ratio += (total / connecting_obj.custom_materials[iterated_material])
		mult *= conductive_ratio*/

	return mult

/datum/wound/electrical_damage/slash
	wound_type = WOUND_SLASH
	wound_series = WOUND_SERIES_WIRE_SLASH_ELECTRICAL_DAMAGE

/datum/wound/electrical_damage/slash/moderate
	name = "Frayed Wiring"
	desc = "Internal wiring has suffered a slight abrasion, causing a very slow electrical fault that will intensify over time."
	occur_text = "lets out a few sparks, as a few frayed wires stick out"
	examine_desc = "has a few frayed wires sticking out"
	treat_text = "Replacing of damaged wiring, though repairs via wirecutting instruments or sutures may suffice, albiet at limited efficiency."

	sound_effect = 'sound/effects/wounds/blood1.ogg'

	severity = WOUND_SEVERITY_MODERATE

	threshold_minimum = 30
	threshold_penalty = 20

	processing_full_shock_threshold = 8 MINUTES

	processing_shock_power_per_second_min = 0.3
	processing_shock_power_per_second_max = 0.4

	processing_shock_stun_chance = 0
	processing_shock_spark_chance = 30

	process_shock_spark_count_min = 1
	process_shock_spark_count_max = 1

	wirecut_repair_percent = 0.15 //15% per wirecut
	wire_repair_percent = 0.08 //8% per suture

	wiring_reset = TRUE

	initial_sparks_amount = 1

	a_or_from = "from"

/datum/wound_pregen_data/electrical_damage/slash/moderate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/slash/moderate
/datum/wound/electrical_damage/slash/severe
	name = "Severed Conduits"
	desc = "A number of wires have been completely cut, resulting in electrical faults that will intensify at a worrying rate."
	occur_text = "sends some electrical fiber in the direction of the blow, beginning to profusely spark"
	examine_desc = "has multiple severed wires visible to the outside"
	treat_text = "Containment of damaged wiring via gauze, securing of wires via a wirecutter/hemostat, then application of fresh wiring or sutures."

	sound_effect = 'sound/effects/wounds/blood2.ogg'

	severity = WOUND_SEVERITY_SEVERE

	threshold_minimum = 70
	threshold_penalty = 50

	processing_full_shock_threshold = 6 MINUTES

	processing_shock_power_per_second_min = 0.4
	processing_shock_power_per_second_max = 0.6

	processing_shock_stun_chance = 0
	processing_shock_spark_chance = 60

	process_shock_spark_count_min = 1
	process_shock_spark_count_max = 2

	wirecut_repair_percent = 0.08 //8% per wirecut
	wire_repair_percent = 0.06 //6% per suture

	initial_sparks_amount = 3

	a_or_from = "from"

/datum/wound_pregen_data/electrical_damage/slash/severe
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/slash/severe
/datum/wound/electrical_damage/slash/critical
	name = "Systemic Fault"
	desc = "A significant portion of the power distribution network has been cut open, resulting in massive power loss and runaway electrocution."
	occur_text = "lets out a violent \"zhwarp\" sound as angry electric arcs attack the surrounding air"
	examine_desc = "has multipled wires sticking out, mauled, hemorraging power"
	treat_text = "Immediate securing via gauze, followed by emergency cable replacement and securing."

	severity = WOUND_SEVERITY_CRITICAL
	wound_flags = (ACCEPTS_GAUZE|MANGLES_FLESH)
	sound_effect = 'sound/effects/wounds/blood3.ogg'

	threshold_minimum = 110
	threshold_penalty = 60

	processing_full_shock_threshold = 3 MINUTES

	processing_shock_power_per_second_min = 1.8
	processing_shock_power_per_second_max = 2

	processing_shock_stun_chance = 5
	processing_shock_spark_chance = 90

	process_shock_spark_count_min = 2
	process_shock_spark_count_max = 3

	wirecut_repair_percent = 0.06 //6% per wirecut
	wire_repair_percent = 0.05 //5% per suture

	initial_sparks_amount = 8

	a_or_from = "a"

/datum/wound/electrical_damage/pierce
	wound_type = WOUND_PIERCE
	wound_series = WOUND_SERIES_WIRE_PIERCE_ELECTRICAL_DAMAGE

/datum/wound_pregen_data/electrical_damage/slash/critical
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/slash/critical

