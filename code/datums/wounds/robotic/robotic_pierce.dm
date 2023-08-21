#define ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY 3 SECONDS
#define ELECTRICAL_DAMAGE_REPLACE_METALS_BASE_DELAY 4 SECONDS

/datum/wound/electrical_damage/pierce
	wound_type = WOUND_PIERCE
	wound_series = WOUND_SERIES_WIRE_PIERCE_ELECTRICAL_DAMAGE

	limb_unimportant_damage_mult = 0.5
	var/disable_at_intensity_mult

	var/heat_thresh_to_heal = (BODYTEMP_NORMAL + 20)
	var/heat_differential_healing_mult = 3 // 3x the differential

    // number
    var/metal_set = 0
    var/max_metal_set = 10

    var/resolder_repair_percent
    var/set_metal_repair_percent = 0.1

    var/resolder_flat_bonus_per_set_metal = 1

/datum/wound/electrical_damage/pierce/item_can_treat(obj/item/potential_treater, mob/user)
    if (potential_treater.tool_behaviour == TOOL_CAUTERY)
        return TRUE

	if ((potential_treater.tool_behaviour == TOOL_WELDER))
        if (limb.brute_dam <= 5)
            return TRUE
        if (user && user.pulling == victim)
            if (user.grab_state < GRAB_AGGRESSIVE)
                to_chat(user, span_warning("You must have [victim] in an aggressive grab to use the [potential_treater]!"))
            else
                return TRUE

    if (istype(potential_treater, /obj/item/stack/rods) || istype(potential_treater, /obj/item/stack/sheet/iron))
        return TRUE

    return ..()

/datum/wound/electrical_damage/pierce/treat(obj/item/treating_item, mob/user)
    if (treating_item.tool_behaviour == TOOL_CAUTERY || treating_item.tool_behaviour == TOOL_WELDER)
        return cauterize(treating_item, user)

    if (istype(treating_item, /obj/item/stack/rods) || istype(treating_item, /obj/item/stack/sheet/iron))
        return set_metal(treating_item, user)

    return ..()

/datum/wound/electrical_damage/pierce/proc/set_metal(obj/item/stack/metallic_stack, mob/user)
    if (metal_set >= max_metal_set)
        to_chat(user, span_warning("The [name] already has as much metal as you can put in!"))
        return TRUE

	if (!metallic_stack.tool_start_check())
        return TRUE
	
    var/is_rods = (istype(metallic_stack, /obj/item/stack/rods))
    var/metal_to_add = (is_rods ? 1 : 2)

    var/change = (processing_full_shock_threshold * set_metal_repair_percent)
    var/delay_mult = 1

	if (user == victim)
		delay_mult *= 3
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= 0.75
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.75

    var/their_or_other = (user == victim ? "their" : "[user]'s")
	while (metallic_stack.tool_start_check())
		user?.visible_message(span_notice("[user] begins setting some metal on the [name] of [their_or_other] [limb.plaintext_zone]..."), ignored_mobs = list(user))
		if (!metallic_stack.use_tool(target = victim, user = user, delay = ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
			return TRUE

		if (user != victim && user.combat_mode)
			user?.visible_message(span_danger("[user] tears the set metal off [name] of [their_or_other] [limb.plaintext_zone]!"))
			adjust_intensity(metal_set * 20)
            limb.receive_damage(brute = 10, source = user, wound_bonus = CANT_WOUND)
            metal_set = 0
		else
            user?.visible_message(span_notice("[user] sets some metal near the [name] of [their_or_other] [limb.plaintext_zone]."))
			adjust_intensity(-change)
            adjust_metal(metal_to_add)

            metallic_stack.use(1)

		if (remove_if_fixed())
			return TRUE
	return TRUE

/datum/wound/electrical_damage/pierce/proc/adjust_metal(metal_to_add)
    metal_set = clamp((metal_set + metal_to_add), 0, max_metal_set)
	
/datum/wound/electrical_damage/pierce/proc/cauterize(obj/item/cauterizing_item, mob/user)
	if (!cauterizing_item.tool_start_check())
        return (cauterizing_item.tool_behavior == TOOL_WELDER)
	
    var/is_cautery = (cauterizing_item.tool_behavior == TOOL_CAUTERY)

    var/change = (processing_full_shock_threshold * resolder_repair_percent)
    var/delay_mult = 1

	if (user == victim)
		delay_mult *= 3
	if (is_cautery) //
		delay_mult *= 1.2
		change *= 0.9
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= 0.75
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.75

    if (!metal_set)
        change *= 0.2
    else 
        var/metal_bonus = ((metal_set * resolder_flat_bonus_per_set_metal) / 100) * processing_full_shock_threshold
        change += metal_bonus

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	while (cauterizing_item.tool_start_check())
        if (!metal_set)
            to_chat(user, span_warning("The [name] has no replacement metal for you to weld! Repairs will be less effective until you put some in!"))
		user?.visible_message(span_notice("[user] begins repairing the [name] of [their_or_other] [limb.plaintext_zone]..."), ignored_mobs = list(user))
		if (!cauterizing_item.use_tool(target = victim, user = user, delay = ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
			return TRUE

		if (user != victim && user.combat_mode)
			user?.visible_message(span_danger("[user] damages the [name] of [their_or_other] [limb.plaintext_zone]!"))
			adjust_intensity(change)
            metal_set = 0
		else
            if (!metal_set)
                user?.visible_message(span_notice("[user] tries their best to repair the [name] of [their_or_other] [limb.plaintext_zone] without replacement metal!"))
            else
			    user?.visible_message(span_notice("[user] repairs some damage on the [name] of [their_or_other] [limb.plaintext_zone]!"))
                adjust_set_metal(-1)
			adjust_intensity(-change)

            cauterizing_item.use(1)

		if (remove_if_fixed())
			return TRUE
	return TRUE


/datum/wound_pregen_data/electrical_damage/pierce
	abstract = TRUE
	
/datum/wound/electrical_damage/pierce/wound_injury(datum/wound/electrical_damage/old_wound, attack_direction)
	RegisterSignals(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))

	return ..()

/datum/wound/electrical_damage/pierce/set_limb(obj/item/bodypart/new_limb)
	if (limb)
		UnregisterSignal(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED))
	if (new_limb)
		RegisterSignals(new_limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))
	
	. = ..()

	if (limb)
		update_inefficiencies()

/datum/wound/electrical_damage/pierce/modify_seconds_for_intensity_after_mult(seconds_for_intensity)
	if (!victim)
		return seconds_for_intensity

	var/healing_amount = max((victim.bodytemperature - heat_thresh_to_heal), 0) * heat_differential_healing_mult
	if (healing_amount != 0 && prob(heat_heal_message_chance))
		to_chat(victim, span_notice("You feel the solder within your [limb.plaintext_zone] reform and repair your [name]..."))

	return seconds_for_intensity - healing_amount

/datum/wound/electrical_damage/pierce/moderate
	name = "Punctured Capacitor"
	desc = "A major capacitor has been broken open, causing slow and intensifying electrical damage, as well as limb dysfunction."
	occur_text = "shoots out a short stream of sparks"
	examine_text = "is shuddering gently, movements a little weak"
	treat_text = "Replacing of damaged wiring, though repairs via wirecutting instruments or sutures may suffice, albiet at limited efficiency. In case of emergency, \
                subject may be subjected to high temperatures to allow solder to reset."

	sound_effect = 'sound/effects/wounds/robotic_slash_T1.ogg'

	severity = WOUND_SEVERITY_MODERATE

	sound_volume = 30

	threshold_minimum = 40
	threshold_penalty = 30

	intensity = 1 MINUTES
	processing_full_shock_threshold = 8 MINUTES

	processing_shock_power_per_second_max = 0.4
	processing_shock_power_per_second_min = 0.3

	processing_shock_stun_chance = 0
	processing_shock_spark_chance = 35

	process_shock_spark_count_max = 1
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.13 //13% per wirecut
	wire_repair_percent = 0.07 //7% per suture

    resolder_repair_percent = 0.07 //8% with 1 set metal or so

    metal_set = 1
    max_metal_set = 3

	interaction_efficiency_penalty = 2
	limp_slowdown = 4
	limp_chance = 40

	wiring_reset = TRUE

	initial_sparks_amount = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

/datum/wound_pregen_data/electrical_damage/pierce/moderate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/moderate

/datum/wound/electrical_damage/pierce/severe
	name = "Penetrated Transformer"
	desc = "A major transformer has been pierced, causing rapid electrical damage and progressive limb dysfunction."
	occur_text = "sputters and goes limp for a moment as it ejects a stream of sparks"
	examine_text = "is shuddering significantly, servos briefly giving way in a rythmic pattern"
	treat_text = "Containment of damaged wiring via gauze, securing of wires via a wirecutter/hemostat, then application of fresh wiring or sutures."

	sound_effect = 'sound/effects/wounds/robotic_slash_T2.ogg'

	severity = WOUND_SEVERITY_SEVERE

	sound_volume = 15

	threshold_minimum = 80
	threshold_penalty = 60

	intensity = 1.2 MINUTES
	processing_full_shock_threshold = 4 MINUTES

	processing_shock_power_per_second_max = 0.6
	processing_shock_power_per_second_min = 0.4

	processing_shock_stun_chance = 0
	processing_shock_spark_chance = 60

	process_shock_spark_count_max = 2
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.07 //7% per wirecut
	wire_repair_percent = 0.05 //5% per suture

    resolder_repair_percent = 0.05 //6% with 1 set metal or so

    max_metal_set = 5

	interaction_efficiency_penalty = 3
	limp_slowdown = 6
	limp_chance = 60

	initial_sparks_amount = 3

	disable_at_intensity_mult = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

/datum/wound_pregen_data/electrical_damage/pierce/severe
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/severe

/datum/wound/electrical_damage/pierce/critical
	name = "Ruptured PSU"
	desc = "Target's local PSU has suffered a core rupture, causing massive power loss that will cause intense electrical damage and limb dysfunction."
	occur_text = "flashes with radiant blue, emitting a noise not unlike a jacobs ladder"
	examine_desc = "'s PSU is visible, with a sizable hole in the center"
	treat_text = "Immediate securing via gauze, followed by emergency cable replacement and securing. If the fault has become uncontrollable, extreme heat therapy is \
                    reccomended."

	severity = WOUND_SEVERITY_CRITICAL
	wound_flags = (ACCEPTS_GAUZE|MANGLES_FLESH)

	sound_effect = 'sound/effects/wounds/robotic_slash_T3.ogg'

	sound_volume = 30

	threshold_minimum = 120
	threshold_penalty = 70

	intensity = 1.4 MINUTES
	processing_full_shock_threshold = 7 MINUTES

	processing_shock_power_per_second_max = 1.1
	processing_shock_power_per_second_min = 0.9

	processing_shock_stun_chance = 1
	processing_shock_spark_chance = 90

	process_shock_spark_count_max = 3
	process_shock_spark_count_min = 2

	wirecut_repair_percent = 0.05 //5% per wirecut
	wire_repair_percent = 0.03 //3% per suture

    resolder_repair_percent = 0.02 //3% with 1 set metal or so

    max_metal_set = 10

	interaction_efficiency_penalty = 4
	limp_slowdown = 8
	limp_chance = 80

	initial_sparks_amount = 8

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

/datum/wound_pregen_data/electrical_damage/pierce/critical
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/critical

/datum/wound/electrical_damage/pierce/proc/update_inefficiencies()
	SIGNAL_HANDLER

	var/intensity_mult = get_intensity_mult()

	var/obj/items/stack/gauze = limb.current_gauze
	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(gauze?.splint_factor)
			limp_slowdown = (initial(limp_slowdown) * gauze.splint_factor) * intensity_mult
			limp_chance = (initial(limp_chance) * gauze.splint_factor) * intensity_mult
		else
			limp_slowdown = initial(limp_slowdown) * intensity_mult
			limp_chance = initial(limp_chance) * intensity_mult
		victim.apply_status_effect(/datum/status_effect/limp)
	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(gauze?.splint_factor)
			interaction_efficiency_penalty = *1 + ((interaction_efficiency_penalty - 1) * gauze.splint_factor) * intensity_mult)
		else
			interaction_efficiency_penalty = (initial(interaction_efficiency_penalty) * intensity_mult)

	if(disable_at_intensity_mult && intensity_mult >= disable_at_intensity_mult)
		set_disabling(gauze)

	limb.update_wounds()

/datum/wound/electrical_damage/pierce/adjust_intensity()
	. = ..()
	update_inefficiencies()
