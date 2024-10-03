///bonus of the observing gondola: you can ignore environmental hazards
/datum/status_effect/organ_set_bonus/fish
	id = "organ_set_bonus_fish"
	tick_interval = 1 SECONDS
	organs_needed = 3
	bonus_activate_text = span_notice("Fish DNA is deeply infused with you! While wet, you crawl faster, are slippery, and cannot slip, and it takes longer to dry out. \
		You're also more resistant to high pressure,better at fishing, but somewhat weaker when dry, especially against burns.")
	bonus_deactivate_text = span_notice("You no longer feel as fishy. The moisture around your body begins to dissipate faster...")
	bonus_traits = list(
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_EXPERT_FISHER,
		TRAIT_EXAMINE_FISH,
		TRAIT_EXAMINE_DEEPER_FISH,
		TRAIT_REVEAL_FISH,
		TRAIT_EXAMINE_FISHING_SPOT,
		TRAIT_WET_FOR_LONGER,
		TRAIT_SLIPPERY_WHEN_WET,
		TRAIT_EXPANDED_FOV, //fish vision
		)

/datum/status_effect/organ_set_bonus/fish/enable_bonus()
	. = ..()
	if(!.)
		return
	RegisterSignals(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN), PROC_REF(check_tail))
	RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_IS_WET), SIGNAL_REMOVETRAIT(TRAIT_IS_WET)), PROC_REF(update_wetness))

	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.physiology.damage_resistance += 5 //base 5% damage resistance, much wow.
		if(!HAS_TRAIT(owner, TRAIT_IS_WET))
			apply_debuff()
	if(HAS_TRAIT(owner, TRAIT_IS_WET) && istype(owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/external/tail/fish))
		add_speed_buff()
	owner.mind?.adjust_experience(/datum/skill/fishing, SKILL_EXP_JOURNEYMAN, silent = TRUE)

/datum/status_effect/organ_set_bonus/fish/disable_bonus()
	. = ..()
	UnregisterSignal(owner, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		SIGNAL_ADDTRAIT(TRAIT_IS_WET),
		SIGNAL_REMOVETRAIT(TRAIT_IS_WET),
		COMSIG_LIVING_TREAT_MESSAGE,
	))
	if(ishuman(owner))
		if(!HAS_TRAIT(owner, TRAIT_IS_WET))
			remove_debuff()
		var/mob/living/carbon/human/human = owner
		human.physiology.damage_resistance -= 5
	if(HAS_TRAIT(owner, TRAIT_IS_WET) && istype(owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/external/tail/fish))
		remove_speed_buff()
	owner.mind?.adjust_experience(/datum/skill/fishing, -SKILL_EXP_JOURNEYMAN, silent = TRUE)

/datum/status_effect/organ_set_bonus/fish/tick(seconds_between_ticks)
	. = ..()
	if(!bonus_active || !HAS_TRAIT(owner, TRAIT_IS_WET))
		return
	owner.adjust_bodytemperature(-2 * seconds_between_ticks, min_temp = owner.get_body_temp_normal())
	owner.adjustStaminaLoss(-1.5 * seconds_between_ticks)

/datum/status_effect/organ_set_bonus/fish/proc/update_wetness(datum/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT(owner, TRAIT_IS_WET)) //remove the debuffs from being dry
		remove_debuff()
		if(istype(owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/external/tail/fish))
			add_speed_buff()
		return
	apply_debuff()
	if(istype(owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/external/tail/fish))
		remove_speed_buff()

/datum/status_effect/organ_set_bonus/fish/proc/apply_debuff()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human = owner
	human.physiology.burn_mod *= 1.5
	human.physiology.heat_mod *= 1.2
	human.physiology.brute_mod *= 1.1
	human.physiology.stun_mod *= 1.1
	human.physiology.knockdown_mod *= 1.1
	human.physiology.stamina_mod *= 1.1
	human.physiology.damage_resistance -= 10 //from +5% to -5%

/datum/status_effect/organ_set_bonus/fish/proc/remove_debuff()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human = owner
	human.physiology.burn_mod *= 1/1.5
	human.physiology.heat_mod *= 1/1.2
	human.physiology.brute_mod *= 1/1.1
	human.physiology.brute_mod *= 1/1.1
	human.physiology.stun_mod *= 1/1.1
	human.physiology.knockdown_mod *= 1/1.1
	human.physiology.stamina_mod *= 1/1.1
	human.physiology.damage_resistance += 10 //from -5% to +5%

/datum/status_effect/organ_set_bonus/fish/proc/check_tail(mob/living/carbon/source, obj/item/organ/organ, special)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(owner, TRAIT_IS_WET) || !istype(organ, /obj/item/organ/external/tail/fish))
		return
	var/obj/item/organ/tail = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail != organ)
		remove_speed_buff()
		return
	add_speed_buff()

/datum/status_effect/organ_set_bonus/fish/proc/add_speed_buff(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(check_body_position))
	check_body_position()

/datum/status_effect/organ_set_bonus/fish/proc/remove_speed_buff(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/fish_flopping)

/datum/status_effect/organ_set_bonus/fish/proc/check_body_position(datum/source)
	SIGNAL_HANDLER
	if(owner.body_position == LYING_DOWN)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/fish_flopping)
	else
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/fish_flopping)


///Tail for fish DNA-infused spacemen. It provides a speed buff while in water. It's also needed for the crawl speed bonus once the threshold is reached.
/obj/item/organ/external/tail/fish
	name = "fish tail"
	desc = "A severed tail from some sort of marine creature... or a fish-infused spaceman. It's smooth, faintly wet and definitely not flopping."

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish

	wag_flags = WAG_ABLE
	organ_traits = list(TRAIT_FLOPPING)

/obj/item/organ/external/tail/fish/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fish)
	var/datum/bodypart_overlay/mutant/overlay = bodypart_overlay
	overlay.randomize_sprite()

/obj/item/organ/external/tail/fish/on_mob_insert(mob/living/carbon/owner)
	. = ..()
	owner.AddElementTrait(TRAIT_WADDLING, type, /datum/element/waddling)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_location))
	check_location(owner, owner.loc)

/obj/item/organ/external/tail/fish/on_mob_remove(mob/living/carbon/owner)
	. = ..()
	owner.remove_traits(list(TRAIT_WADDLING, TRAIT_NO_STAGGER), type)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/fish_on_water)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/fish_on_water)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/obj/item/organ/external/tail/fish/proc/check_location(mob/living/carbon/source, atom/movable/old_loc, dir, forced)
	var/was_water = istype(old_loc, /turf/open/water)
	var/is_water = istype(source.loc, /turf/open/water) && !HAS_TRAIT(source.loc, TRAIT_TURF_IGNORE_SLOWDOWN)
	if(was_water && !is_water)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/fish_on_water)
		source.remove_actionspeed_modifier(/datum/actionspeed_modifier/fish_on_water)
		ADD_TRAIT(source, TRAIT_NO_STAGGER, type)
	else if(!was_water && is_water)
		source.add_movespeed_modifier(/datum/movespeed_modifier/fish_on_water)
		source.add_actionspeed_modifier(/datum/actionspeed_modifier/fish_on_water)
		REMOVE_TRAIT(source, TRAIT_NO_STAGGER, type)

/datum/bodypart_overlay/mutant/tail/fish
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/tail/fish/get_global_feature_list()
	return SSaccessories.tails_list_fish


///Lungs that replace the need of oxygen with water vapor or being wet
/obj/item/organ/internal/lungs/fish
	name = "mutated gills"
	desc = "Fish DNA infused on what once was a normal pair of lungs that now require spacemen to breathe water vapor, or keep themselves covered in water."
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "gills"

	safe_oxygen_min = 0 //We don't breathe this
	///The required partial pressure of water_vapor for not drowing
	var/safe_water_level = 29
	///The special bubble icon that we give to mobs with this organ. It's a indie rpg reference btw
	var/datum/component/bubble_icon_override/bubble_icon

/obj/item/organ/internal/lungs/fish/Initialize(mapload)
	//This takes precedence over oygen for the amphibious subtype
	add_gas_reaction(/datum/gas/water_vapor, always = PROC_REF(breathe_water))
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fish)
/obj/item/organ/internal/lungs/fish/on_mob_insert(mob/living/carbon/owner)
	. = ..()
	bubble_icon = owner.AddComponent(/datum/component/bubble_icon_override, "fish", BUBBLE_ICON_PRIORITY_ORGAN_SET_BONUS)

/obj/item/organ/internal/lungs/fish/on_mob_remove(mob/living/carbon/owner)
	. = ..()
	QDEL_NULL(bubble_icon)

/// Requires the spaceman to have either water vapor or be wet.
/obj/item/organ/internal/lungs/fish/proc/breathe_water(mob/living/carbon/breather, datum/gas_mixture/breath, water_pp, old_water_pp)
	var/need_to_breathe = !HAS_TRAIT(src, TRAIT_SPACEBREATHING) && !HAS_TRAIT(breather, TRAIT_IS_WET)
	if(water_pp < safe_water_level && need_to_breathe)
		on_low_water(breather, breath, water_pp)
		return FALSE

	if(old_water_pp < safe_water_level)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_WATER)

	if(need_to_breathe)
		breathe_gas_volume(breath, /datum/gas/water_vapor, /datum/gas/carbon_dioxide)
	// Heal mob if not in crit.
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjustOxyLoss(-5)
	return TRUE

/// Called when there isn't enough water to breath
/obj/item/organ/internal/lungs/fish/proc/on_low_water(mob/living/carbon/breather, datum/gas_mixture/breath, water_pp)
	breather.throw_alert(ALERT_NOT_ENOUGH_WATER, /atom/movable/screen/alert/not_enough_water)
	var/gas_breathed = handle_suffocation(breather, water_pp, safe_water_level, breath.gases[/datum/gas/water_vapor][MOLES])
	if(water_pp)
		breathe_gas_volume(breath, /datum/gas/water_vapor, /datum/gas/carbon_dioxide, volume = gas_breathed)
	return

/// Subtype of gills that allow the mob to optionally breathe water.
/obj/item/organ/internal/lungs/fish/amphibious
	name = "mutated semi-aquatic lungs"
	desc = "DNA from an amphibious or semi-aquatic creature infused on a pair lungs. Enjoy breathing underwater without drowning outside water."
	safe_oxygen_min = /obj/item/organ/internal/lungs::safe_oxygen_min
	safe_water_level = 19
	///If true, we don't have to breathe air since we've water vapor (or are wet)
	var/breathed_water = FALSE

/obj/item/organ/internal/lungs/fish/amphibious/breathe_water(mob/living/carbon/breather, datum/gas_mixture/breath, water_pp, old_water_pp)
	breathed_water = ..()
	if(breathed_water && breather.failed_last_breath) //in case we had neither oxygen nor water last tick.
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

/obj/item/organ/internal/lungs/fish/amphibious/on_low_water(mob/living/carbon/breather, datum/gas_mixture/breath, water_pp)
	return //do nothing, fall back on breathing oxygen instead.

/obj/item/organ/internal/lungs/fish/amphibious/breathe_oxygen(mob/living/carbon/breather, datum/gas_mixture/breath, o2_pp, old_o2_pp)
	if(breathed_water)
		return
	return ..()

///Fish infuser organ, allows mobs to safely eat raw fish.
/obj/item/organ/internal/stomach/fish
	name = "mutated fish-stomach"
	desc = "Fish DNA infused into a stomach now parmated by the faint smell of salt and slightly putrified fish."
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "stomach"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = "#a25690" //dark moderate magenta

	organ_traits = list(TRAIT_STRONG_STOMACH, TRAIT_FISH_EATER)
	disgust_metabolism = 2.5

/obj/item/organ/internal/stomach/fish/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fish)


///Organ from fish with the ink production trait. Doesn't count toward the organ set bonus but is buffed once it's active.
/obj/item/organ/internal/tongue/inky
	name = "ink-secreting tongue"
	desc = "A black tongue linked to two swollen black sacs underneath the palate."
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "inky_tongue"
	actions_types = list(/datum/action/cooldown/ink_spit)

///Organ from fish with the toxic trait. Allows the user to use tetrodotoxin as a healing chem instead of a toxin.
/obj/item/organ/internal/liver/fish
	name = "mutated fish-liver"
	desc = "Fish DNA infused into a stomach that now uses tetrodotoxin as regenerative materia."
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "liver"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = "#a25690" //dark moderate magenta

	organ_traits = list(TRAIT_TETRODOTOXIN_HEALING)
	liver_resistance = parent_type::liver_resistance * 1.5
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5, /datum/reagent/toxin/tetrodotoxin = 5)
	grind_results = list(/datum/reagent/consumable/nutriment/peptides = 5, /datum/reagent/toxin/tetrodotoxin = 5)

/obj/item/organ/internal/liver/fish/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fish)
