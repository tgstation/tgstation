/datum/wound_pregen_data/burnt_metal
	abstract = TRUE
	required_limb_biostate = BIO_METAL
	required_wounding_type = WOUND_BURN
	wound_series = WOUND_SERIES_METAL_BURN_OVERHEAT

/datum/wound/burn/robotic/overheat
	treat_text = "Introduction of a cold environment or lowering of body temperature."
	treat_text_short = "Cool the patient down or put them under a shower."
	simple_desc = "Metals are overheated, increasing damage taken and raising body temperature!"
	simple_treat_text = "Ideally <b>cryogenics</b>, but any source of <b>low body temperature</b> can work. <b>Spraying</b> with <b>spray bottles/extinguishers/showers</b> \
	will quickly cool the limb, but cause <b>structural damage</b>. \
	<b>Clothing</b> reduces the reagents that make it to the metal, and <b>gauze</b> or grasping it binds it and <b>reduces</b> the <b>damage</b> taken."
	homemade_treat_text = "You can also splash <b>any liquid</b> on it or dive into space to cool yourself."
	can_scar = FALSE
	wound_flags = (ACCEPTS_GAUZE|CAN_BE_GRASPED) // gauze binds the metal and makes it resistant to thermal shock

	processes = TRUE

	// It's like flesh_damage, but for robots
	var/chassis_temperature = 0
	// Bonus to chassis_temperature for the purpose of calculating how much we heat up each tick.
	var/overheat_bonus = 0
	// Thermal shock damage multiplier.
	var/thermal_shock_mult = 0
	// If we are sprayed with a extinguisher/shower with obscuring clothing on (think clothing that prevents surgery), the effect is multiplied against this.
	var/sprayed_with_reagent_clothed_mult = 0.4
	// The wound we demote to when we go below cooling threshold. If null, removes us.
	var/datum/wound/burn/robotic/demotes_to
	// The temperature we need to be under in order to begin passively cooling.
	var/temperature_limit = BODYTEMP_NORMAL + 200
	// Divisor for how much reagents cool the chassis. 100 means 100 units of water at 0K chassis_temperature by 1.
	var/reagent_volume_coeff = 30
	// The color of the light we will generate.
	var/light_color
	// The power of the light we will generate.
	var/light_power
	// The range of the light we will generate.
	var/light_range
	// The glow we have attached to our victim, to simulate our limb glowing.
	var/obj/effect/dummy/lighting_obj/moblight/mob_glow

/datum/wound/burn/robotic/overheat/set_victim(mob/living/new_victim)
	if (victim)
		QDEL_NULL(mob_glow)
		UnregisterSignal(victim, COMSIG_ATOM_EXPOSE_REAGENTS)
	if (new_victim)
		mob_glow = new_victim.mob_light(light_range, light_power, light_color)
		mob_glow.set_light_on(TRUE)
		RegisterSignal(new_victim, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(victim_exposed_to_reagents))
	return ..()

/datum/wound/burn/robotic/get_limb_examine_description()
	return span_warning("The metal on this limb is glowing with heat.")

/datum/wound/burn/robotic/overheat/proc/under_limit(query)
	if(query >= temperature_limit)
		return
	var/amount_under_limit = temperature_limit - query
	return amount_under_limit / temperature_limit

/datum/wound/burn/robotic/overheat/handle_process(seconds_per_tick)
	var/passive_cooling = under_limit(victim.bodytemperature)
	if(passive_cooling)
		chassis_temperature -= 0.2 * passive_cooling
	if(victim.stat != DEAD) // So we don't husk anyone with a burn
		victim.adjust_bodytemperature((chassis_temperature + overheat_bonus) * 0.4) // This is how burns actually hurt you, our (very simple) version of infection
	if (chassis_temperature <= 0)
		if (demotes_to)
			victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] turns a more pleasant thermal color as it cools down a little..."), span_green("Your [limb.plaintext_zone] seems to cool down a little!"))
			replace_wound(new demotes_to)
			return
		else
			victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] returns to its usual colors!"), span_green("Your [limb.plaintext_zone] returns to its usual colors!"))
			remove_wound()
			return

/datum/wound/burn/robotic/overheat/proc/victim_exposed_to_reagents(datum/signal_source, list/reagents, datum/reagents/source, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	if(methods != TOUCH)
		return
	var/temp_delta = under_limit(source.chem_temp)
	if(isnull(temp_delta))
		return

	if(!victim.is_location_accessible(limb.body_zone))
		if (ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			for (var/obj/item/clothing/iter_clothing as anything in human_victim.get_clothing_on_part(limb))
				if (iter_clothing.clothing_flags & THICKMATERIAL)
					return
		temp_delta *= sprayed_with_reagent_clothed_mult

	if (istype(source.my_atom, /obj/effect/particle_effect/water))
		temp_delta *= 3

	if (istype(source.my_atom, /obj/machinery/shower))
		temp_delta *= 2

/*  Here we try to calculate the amount of heat any volume of reagents can conduct away from the burn.
	However, every reagent in the game besides plasma and the one bespoke cooling reagent (as of coding this) has the exact same specific heat.
	Even "reagents" that aren't liquid like salt.
	So it's not a very in-depth mechanic. */

	var/effective_volume = 0
	for(var/datum/reagent/each_reagent as anything in reagents)
		effective_volume += reagents[each_reagent] * each_reagent.specific_heat / SPECIFIC_HEAT_DEFAULT
	temp_delta *= effective_volume / reagent_volume_coeff
	temp_delta = max(chassis_temperature, 0) // So we don't overheal and take extra thermal shock
	chassis_temperature -= temp_delta

	// Okay, now it's thermal shock time
	var/thermal_shock = temp_delta * thermal_shock_mult * (effective_volume / source.total_volume) // Highly conductive reagents (plasma, coolant) cause less shock
	thermal_shock *= limb.get_splint_factor()
	if(limb.grasped_by)
		thermal_shock *= 0.8 // Grab that burning hot metal! Fireproof gloves would be a bit of an unreasonable ask from medical so whatever.
	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	victim.visible_message(span_warning("[victim]'s [limb.plaintext_zone] strains from the thermal shock[(!victim.is_location_accessible(limb.body_zone) ? ", [victim.p_their()] clothing absorbing some of the liquid" : "")][(!isnull(current_gauze) ? ", but the [current_gauze.name] helps to keep it together" : "")]!"))
	playsound(victim, 'sound/items/tools/welder.ogg', 25)
	if(thermal_shock <= 30)
		INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")
		limb.receive_damage(brute = thermal_shock, wound_bonus = CANT_WOUND)

// this wound is unaffected by cryoxadone and pyroxadone
/datum/wound/burn/robotic/overheat/on_xadone(power)
	chassis_temperature -= 0.2
	return

/datum/wound/burn/robotic/overheat/moderate
	name = "Transient Overheating"
	desc = "External metals have exceeded lower-bound thermal limits and have lost some structural integrity, increasing damage taken as well as the chance to \
		sustain additional wounds."
	occur_text = "lets out a slight groan as it turns a dull shade of thermal red"
	examine_desc = "is glowing a dull thermal red and giving off heat"
	treat_text = "Reduction of body temperature to expedite the passive heat dissipation - or, if thermal shock is to be risked, application of a fire extinguisher/shower."
	treat_text_short = "Apply gauze or grasp limb before spraying the wound with coolant, lower body temperature, or just wait."
	severity = WOUND_SEVERITY_MODERATE
	a_or_from = "from"
	damage_multiplier_penalty = 1.1
	threshold_penalty = 15
	series_threshold_penalty = 35
	status_effect_type = /datum/status_effect/wound/burn/robotic/moderate
	sound_volume = 18

	chassis_temperature = 15
	thermal_shock_mult = 1.25
	light_color = COLOR_RED
	light_power = 0.1
	light_range = 0.5

/datum/wound_pregen_data/burnt_metal/transient_overheat
	abstract = FALSE
	wound_path_to_generate = /datum/wound/burn/robotic/overheat/moderate
	threshold_minimum = 30

/datum/wound/burn/robotic/overheat/severe
	name = "Thermal Overload"
	desc = "Exterior plating has surpassed critical thermal levels, causing significant failure in structural integrity and overheating of internal systems."
	occur_text = "sizzles, the externals turning a dull shade of orange"
	examine_desc = "appears discolored and polychromatic, parts of it glowing a dull orange"
	treat_text = "Isolation from physical hazards, and accommodation of passive heat dissipation - active cooling may be used, but temperature differentials significantly \
		raise the risk of thermal shock."
	treat_text_short = "Apply gauze and grasp limb before spraying the wound with cold liquid, or lower body temperature and wait."
	severity = WOUND_SEVERITY_SEVERE
	a_or_from = "from"
	damage_multiplier_penalty = 1.2
	threshold_penalty = 15
	series_threshold_penalty = 55
	status_effect_type = /datum/status_effect/wound/burn/robotic/severe
	sound_volume = 20

	chassis_temperature = 15
	thermal_shock_mult = 1.5
	overheat_bonus = 20
	demotes_to = /datum/wound/burn/robotic/overheat/moderate
	light_color = COLOR_BRIGHT_ORANGE
	light_power = 0.8
	light_range = 0.5

/datum/wound_pregen_data/burnt_metal/severe
	abstract = FALSE
	wound_path_to_generate = /datum/wound/burn/robotic/overheat/severe
	threshold_minimum = 80

/datum/wound/burn/robotic/overheat/critical
	name = "Runaway Exothermy"
	desc = "Carapace is beyond melting point, causing catastrophic structural integrity failure as well as massively heating up the subject."
	occur_text = "turns a bright shade of radiant white as it sizzles and melts"
	examine_desc = "is a blinding shade of white, almost melting from the heat"
	treat_text = "Immediate confinement to cryogenics, as rapid overheating and physical vulnerability may occur. Active cooling is not advised, \
		since the thermal shock may be lethal with such a temperature differential."
	treat_text_short = "Apply cryogenics or lower body temperature without direct exposure to cold liquid."
	severity = WOUND_SEVERITY_CRITICAL
	a_or_from = "from"
	sound_effect = 'sound/effects/wounds/sizzle2.ogg'
	damage_multiplier_penalty = 1.3
	threshold_penalty = 25
	status_effect_type = /datum/status_effect/wound/burn/robotic/critical
	sound_volume = 22
	wound_flags = (ACCEPTS_GAUZE|CAN_BE_GRASPED)

	chassis_temperature = 15
	thermal_shock_mult = 2
	overheat_bonus = 40
	demotes_to = /datum/wound/burn/robotic/overheat/severe
	light_color = COLOR_VERY_SOFT_YELLOW
	light_power = 1.3
	light_range = 1.5

/datum/wound_pregen_data/burnt_metal/critical
	abstract = FALSE
	wound_path_to_generate = /datum/wound/burn/robotic/overheat/critical
	threshold_minimum = 140
