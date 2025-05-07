/// The starter amount for the android's core
#define ENERGY_START_AMT 5 MEGA JOULES
/// The amount at which mob energy decreases
#define ENERGY_DRAIN_AMT 2.5 KILO JOULES

/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	preview_outfit = /datum/outfit/android_preview
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTLOWPRESSURE,
		/*TG traits we remove
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_PIERCEIMMUNE,
		TRAIT_OVERDOSEIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOFIRE,
		TRAIT_NOBLOOD,
		TRAIT_NO_UNDERWEAR,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,*/
		TRAIT_UNHUSKABLE,
		TRAIT_STABLEHEART,
		TRAIT_STABLELIVER,
	)
	reagent_flags = PROCESS_SYNTHETIC
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "None")
	mutantheart = /obj/item/organ/heart/cybernetic/tier2
	mutantstomach = /obj/item/organ/stomach/cybernetic/tier2
	mutantliver = /obj/item/organ/liver/cybernetic/tier2
	exotic_blood = /datum/reagent/synth_blood
	exotic_bloodtype = BLOOD_TYPE_SYNTHETIC

	bodytemp_heat_damage_limit = (BODYTEMP_NORMAL + 146) // 456 K / 183 C
	bodytemp_cold_damage_limit = (BODYTEMP_NORMAL - 80) // 230 K / -43 C
	/// Ability to recharge!
	var/datum/action/innate/power_cord/power_cord
	/// Hud element to display our energy level
	var/atom/movable/screen/android/energy/energy_tracker
	/// How much energy we start with
	var/core_energy = ENERGY_START_AMT

/datum/outfit/android_preview
	name = "Android (Species Preview)"
	// nude

/datum/species/android/on_species_gain(mob/living/carbon/target, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(ishuman(target))
		power_cord = new
		power_cord.Grant(target)

/datum/species/android/on_species_loss(mob/living/carbon/target, datum/species/new_species, pref_load)
	. = ..()
	if(power_cord)
		power_cord.Remove(target)
	if(target.hud_used)
		var/datum/hud/hud_used = target.hud_used
		hud_used.infodisplay -= energy_tracker
		QDEL_NULL(energy_tracker)

/datum/species/android/spec_revival(mob/living/carbon/human/target)
	if(core_energy < 0.5 MEGA JOULES)
		core_energy += 0.5 MEGA JOULES
	playsound(target.loc, 'sound/machines/chime.ogg', 50, TRUE)
	target.visible_message(span_notice("[target]'s LEDs flicker to life!"), span_notice("All systems nominal. You're back online!"))

/datum/species/android/spec_life(mob/living/carbon/human/target, seconds_per_tick, times_fired)
	. = ..()
	handle_hud(target)

	if(target.stat == SOFT_CRIT || target.stat == HARD_CRIT)
		target.adjustFireLoss(1 * seconds_per_tick) //Still deal some damage in case a cold environment would be preventing us from the sweet release to robot heaven
		target.adjust_bodytemperature(13 * seconds_per_tick) //We're overheating!!
		if(prob(10))
			to_chat(target, span_warning("Alert: Critical damage taken! Cooling systems failing!"))
			do_sparks(3, FALSE, target)

	if(target.stat == DEAD)
		return
	if(HAS_TRAIT(target, TRAIT_CHARGING))
		return
	if(core_energy > 0)
		core_energy -= ENERGY_DRAIN_AMT
		target.remove_movespeed_modifier(/datum/movespeed_modifier/android_nocharge)
	// Once out of power, you begin to move terribly slowly
	if(core_energy <= 0)
		target.add_movespeed_modifier(/datum/movespeed_modifier/android_nocharge)

/datum/species/android/proc/handle_hud(mob/living/carbon/human/target)
	// update it
	if(energy_tracker)
		energy_tracker.update_energy_hud(core_energy)
	// initialize it
	else if(target.hud_used)
		var/datum/hud/hud_used = target.hud_used
		energy_tracker = new(null, hud_used)
		hud_used.infodisplay += energy_tracker

		target.hud_used.show_hud(target.hud_used.hud_version)

/datum/species/android/prepare_human_for_preview(mob/living/carbon/human/robot_for_preview)
	robot_for_preview.dna.ear_type = CYBERNETIC
	robot_for_preview.dna.features["ears"] = "TV Antennae"
	robot_for_preview.dna.features["ears_color_1"] = "#333333"
	robot_for_preview.dna.features["frame_list"] = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot/android/sgm,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot/android/sgm,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/android/sgm,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/android/sgm,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/android/sgm,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/android/sgm)
	regenerate_organs(robot_for_preview)
	robot_for_preview.update_body(is_creating = TRUE)

/datum/species/android/get_physical_attributes()
	return "Androids are almost, but not quite, identical to fully augmented humans. \
	Unlike those, though, they're completely immune to toxin damage, don't have blood or organs (besides their head), don't get hungry, and can reattach their limbs! \
	That said, an EMP will devastate them and they cannot process any chemicals."

/datum/species/android/get_species_description()
	return "Androids are an entirely synthetic species."

/datum/species/android/get_species_lore()
	return list(
		"Androids are a synthetic species created by the Port Authority as an intermediary between humans and cyborgs."
	)

/datum/movespeed_modifier/android_nocharge
	multiplicative_slowdown = CRAWLING_ADD_SLOWDOWN
	flags = IGNORE_NOSLOW

#undef ENERGY_START_AMT
#undef ENERGY_DRAIN_AMT
