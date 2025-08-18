/// List of roundstart races' their species_id's
GLOBAL_LIST_EMPTY(roundstart_races)
///List of all roundstart languages by path except common
GLOBAL_LIST_EMPTY(uncommon_roundstart_languages)

/// An assoc list of species types to their features (from get_features())
GLOBAL_LIST_EMPTY(features_by_species)

/**
 * # species datum
 *
 * Datum that handles different species in the game.
 *
 * This datum handles species in the game, such as lizardpeople, mothmen, zombies, skeletons, etc.
 * It is used in [carbon humans][mob/living/carbon/human] to determine various things about them, like their food preferences, if they have biological genders, their damage resistances, and more.
 *
 */
/datum/species
	///If the game needs to manually check your race to do something not included in a proc here, it will use this.
	var/id
	///This is used for children, it will determine their default limb ID for use of examine. See [/mob/living/carbon/human/proc/examine].
	var/examine_limb_id
	///This is the fluff name. They are displayed on health analyzers and in the character setup menu. Leave them generic for other servers to customize.
	var/name
	/**
	 * The formatting of the name of the species in plural context. Defaults to "[name]\s" if unset.
	 *  Ex "[Plasmamen] are weak", "[Mothmen] are strong", "[Lizardpeople] don't like", "[Golems] hate"
	 */
	var/plural_form

	///Whether or not the race has sexual characteristics (biological genders). At the moment this is only FALSE for skeletons and shadows
	var/sexes = TRUE

	///The maximum number of bodyparts this species can have.
	var/max_bodypart_count = 6
	/// This allows races to have specific hair colors.
	/// If null, it uses the mob's hair/facial hair colors.
	/// If USE_MUTANT_COLOR, it uses the mob's mutant_color.
	/// If USE_FIXED_MUTANT_COLOR, it uses fixedmutcolor
	var/hair_color_mode
	///The alpha used by the hair. 255 is completely solid, 0 is invisible.
	var/hair_alpha = 255
	///The alpha used by the facial hair. 255 is completely solid, 0 is invisible.
	var/facial_hair_alpha = 255

	///Never, Optional, or Forced digi legs?
	var/digitigrade_customization = DIGITIGRADE_NEVER
	///If your race uses a non standard bloodtype (A+, O-, AB-, etc). For example, lizards have L type blood.
	///Reagent that your species bleeds, and what chemical can be used to recover lost blood depend on this
	var/exotic_bloodtype
	///The rate at which blood is passively drained by having the blood deficiency quirk. Some races such as slimepeople can regen their blood at different rates so this is to account for that
	var/blood_deficiency_drain_rate = BLOOD_REGEN_FACTOR + BLOOD_DEFICIENCY_MODIFIER // slightly above the regen rate so it slowly drains instead of regenerates.
	///What the species drops when gibbed by a gibber machine.
	var/meat = /obj/item/food/meat/slab/human
	///What skin the species drops when gibbed by a gibber machine.
	var/skinned_type
	///flags for inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example.
	var/no_equip_flags
	/// What languages this species can understand and say.
	/// Use a [language holder datum][/datum/language_holder] typepath in this var.
	/// Should never be null.
	var/datum/language_holder/species_language_holder = /datum/language_holder/human_basic
	///The bodyparts this species uses. assoc of bodypart string - bodypart type. Make sure all the fucking entries are in or I'll skin you alive.
	var/list/bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	///Internal organs that are unique to this race, like a tail or other cosmetic organs. list(typepath of organ 1, typepath of organ 2 = "Round").
	var/list/mutant_organs = list()
	///Replaces default brain with a different organ
	var/obj/item/organ/brain/mutantbrain = /obj/item/organ/brain
	///Replaces default heart with a different organ
	var/obj/item/organ/heart/mutantheart = /obj/item/organ/heart
	///Replaces default lungs with a different organ
	var/obj/item/organ/lungs/mutantlungs = /obj/item/organ/lungs
	/// Smoker lungs for the quirk, overriden by certain species
	var/obj/item/organ/lungs/smoker_lungs = /obj/item/organ/lungs/smoker_lungs
	///Replaces default eyes with a different organ
	var/obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	///Replaces default ears with a different organ
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	///Replaces default tongue with a different organ
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	///Replaces default liver with a different organ
	var/obj/item/organ/liver/mutantliver = /obj/item/organ/liver
	///Replaces default stomach with a different organ
	var/obj/item/organ/stomach/mutantstomach = /obj/item/organ/stomach
	///Replaces default appendix with a different organ.
	var/obj/item/organ/appendix/mutantappendix = /obj/item/organ/appendix

	/// Store body marking defines. See mobs.dm for bitflags
	var/list/body_markings = list()

	/// Flat modifier on all damage taken via [apply_damage][/mob/living/proc/apply_damage] (so being punched, shot, etc.)
	/// IE: 10 = 10% less damage taken.
	var/damage_modifier = 0
	///multiplier for damage from cold temperature
	var/coldmod = 1
	///multiplier for damage from hot temperature
	var/heatmod = 1
	///multiplier for stun durations
	var/stunmod = 1
	///multiplier for money paid at payday
	var/payday_modifier = 1.0
	///Base electrocution coefficient.  Basically a multiplier for damage from electrocutions.
	var/siemens_coeff = 1
	///To use MUTCOLOR with a fixed color that's independent of the mcolor feature in DNA.
	var/fixed_mut_color = ""
	///Special mutation that can be found in the genepool exclusively in this species. Dont leave empty or changing species will be a headache
	var/inert_mutation = /datum/mutation/dwarfism
	///Used to set the mob's death_sound upon species change
	var/death_sound
	///Special sound for grabbing
	var/grab_sound
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life

	/// The natural temperature for a body
	var/bodytemp_normal = BODYTEMP_NORMAL
	/// Minimum amount of kelvin moved toward normal body temperature per tick.
	var/bodytemp_autorecovery_min = BODYTEMP_AUTORECOVERY_MINIMUM
	/// The body temperature limit the body can take before it starts taking damage from heat.
	var/bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT
	/// The body temperature limit the body can take before it starts taking damage from cold.
	var/bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT

	/// The icon_state of the fire overlay added when sufficently ablaze and standing. see onfire.dmi
	var/fire_overlay = "human"

	/// Generic traits tied to having the species.
	var/list/inherent_traits = list()
	/// List of biotypes the mob belongs to. Used by diseases.
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	/// The type of respiration the mob is capable of doing. Used by adjustOxyLoss.
	var/inherent_respiration_type = RESPIRATION_OXYGEN
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	///What gas does this species breathe? Used by suffocation screen alerts, most of actual gas breathing is handled by mutantlungs. See [life.dm][code/modules/mob/living/carbon/human/life.dm]
	var/breathid = GAS_O2

	///What anim to use for gibbing
	var/gib_anim = "gibbed-h"

	///Bitflag that controls what in game ways something can select this species as a spawnable source, such as magic mirrors. See [mob defines][code/__DEFINES/mobs.dm] for possible sources.
	var/changesource_flags = NONE

	///Unique cookie given by admins through prayers
	var/species_cookie = /obj/item/food/cookie

	/// List of family heirlooms this species can get with the family heirloom quirk. List of types.
	var/list/family_heirlooms

	///List of results you get from knife-butchering. null means you cant butcher it. Associated by resulting type - value of amount
	var/list/knife_butcher_results

	/// Should we preload this species's organs?
	var/preload = TRUE

	/// Do we try to prevent reset_perspective() from working? Useful for Dullahans to stop perspective changes when they're looking through their head.
	var/prevent_perspective_change = FALSE

	///Was the species changed from its original type at the start of the round?
	var/roundstart_changed = FALSE

	/// This supresses the "dosen't appear to be himself" examine text for if the mob is run by an AI controller. Should be used on any NPC human subtypes. Monkeys are the prime example.
	var/ai_controlled_species = FALSE

	/**
	 * Was on_species_gain ever actually called?
	 * Species code is really odd...
	 **/
	var/properly_gained = FALSE

	///A list containing outfits that will be overridden in the species_equip_outfit proc. [Key = Typepath passed in] [Value = Typepath of outfit you want to equip for this specific species instead].
	var/list/outfit_override_registry = list()

///////////
// PROCS //
///////////


/datum/species/New()
	if(!plural_form)
		plural_form = "[name]\s"
	if(!examine_limb_id)
		examine_limb_id = id

	return ..()

/// Gets a list of all species id's available to choose in roundstart.
/proc/get_selectable_species()
	RETURN_TYPE(/list)

	if (!GLOB.roundstart_races.len)
		GLOB.roundstart_races = generate_selectable_species_and_languages()

	return GLOB.roundstart_races

/**
 * Generates species available to choose in character setup at roundstart
 *
 * This proc generates which species are available to pick from in character setup.
 * If there are no available roundstart species, defaults to human.
 */
/proc/generate_selectable_species_and_languages()
	var/list/selectable_species = list()

	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = GLOB.species_prototypes[species_type]
		if(species.check_roundstart_eligible())
			selectable_species += species.id
			var/datum/language_holder/temp_holder = GLOB.prototype_language_holders[species.species_language_holder]
			for(var/datum/language/spoken_language as anything in temp_holder.understood_languages)
				GLOB.uncommon_roundstart_languages |= spoken_language

	GLOB.uncommon_roundstart_languages -= /datum/language/common
	if(!selectable_species.len)
		selectable_species += SPECIES_HUMAN

	return selectable_species

/**
 * Checks if a species is eligible to be picked at roundstart.
 *
 * Checks the config to see if this species is allowed to be picked in the character setup menu.
 * Used by [/proc/generate_selectable_species_and_languages].
 */
/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/**
 * Copies some vars and properties over that should be kept when creating a copy of this species.
 *
 * Used by slimepeople to copy themselves, and by the DNA datum to hardset DNA to a species
 * Arguments:
 * * old_species - The species that the carbon used to be before copying
 */
/datum/species/proc/copy_properties_from(datum/species/old_species, pref_load, regenerate_icons)
	return

/**
 * Gets the default mutant organ for the species based on the provided slot.
 */
/datum/species/proc/get_mutant_organ_type_for_slot(slot)
	switch(slot)
		if(ORGAN_SLOT_BRAIN)
			return mutantbrain
		if(ORGAN_SLOT_HEART)
			return mutantheart
		if(ORGAN_SLOT_LUNGS)
			return mutantlungs
		if(ORGAN_SLOT_APPENDIX)
			return mutantappendix
		if(ORGAN_SLOT_EYES)
			return mutanteyes
		if(ORGAN_SLOT_EARS)
			return mutantears
		if(ORGAN_SLOT_TONGUE)
			return mutanttongue
		if(ORGAN_SLOT_LIVER)
			return mutantliver
		if(ORGAN_SLOT_STOMACH)
			return mutantstomach
		else
			// Non-standard organs we might have
			for(var/obj/item/organ/extra_organ as anything in mutant_organs)
				if(initial(extra_organ.slot) == slot)
					return extra_organ

/**
 * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does.
 *
 * Takes all organ slots, removes organs a species should not have, adds organs a species should have.
 * can use replace_current to refresh all organs, creating an entirely new set.
 *
 * Arguments:
 * * organ_holder - carbon, the owner of the species datum AKA whoever we're regenerating organs in
 * * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
 * * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
 * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 * * visual_only - boolean, only load organs that change how the species looks. Do not use for normal gameplay stuff
 * * replace_missing - Whether or not to replace missing organs
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/organ_holder, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE, replace_missing = TRUE)
	for(var/slot in get_all_slots())
		var/obj/item/organ/existing_organ = organ_holder.get_organ_slot(slot)
		var/obj/item/organ/new_organ = get_mutant_organ_type_for_slot(slot)
		var/old_organ_type = old_species?.get_mutant_organ_type_for_slot(slot)

		// if we have an extra organ that before changing that the species didnt have, remove it
		if(!new_organ)
			if(existing_organ && (old_organ_type == existing_organ.type || replace_current))
				existing_organ.Remove(organ_holder)
				qdel(existing_organ)
			continue

		if(existing_organ)
			// we dont want to remove organs that were not from the old species (such as from freak surgery or prosthetics)
			if(existing_organ.type != old_organ_type && !replace_current)
				continue

			// we don't want to remove organs that are the same as the new one
			if(existing_organ.type == new_organ)
				continue

		if(visual_only && (!initial(new_organ.bodypart_overlay) && !initial(new_organ.visual)))
			continue

		var/used_neworgan = FALSE
		new_organ = SSwardrobe.provide_type(new_organ)
		var/should_have = new_organ.get_availability(src, organ_holder) && should_visual_organ_apply_to(new_organ, organ_holder)

		// Check for an existing organ, and if there is one check to see if we should remove it
		var/health_pct = 1
		var/remove_existing = !isnull(existing_organ) && !(existing_organ.zone in excluded_zones) && !(existing_organ.organ_flags & ORGAN_UNREMOVABLE)
		if(remove_existing)
			health_pct = (existing_organ.maxHealth - existing_organ.damage) / existing_organ.maxHealth
			if(slot == ORGAN_SLOT_BRAIN)
				var/obj/item/organ/brain/existing_brain = existing_organ
				existing_brain.before_organ_replacement(new_organ)
				existing_brain.Remove(organ_holder, special = TRUE, movement_flags = NO_ID_TRANSFER)
			else
				existing_organ.before_organ_replacement(new_organ)
				existing_organ.Remove(organ_holder, special = TRUE)

			QDEL_NULL(existing_organ)
		if(isnull(existing_organ) && should_have && !(new_organ.zone in excluded_zones) && organ_holder.get_bodypart(deprecise_zone(new_organ.zone)) && (replace_missing || remove_existing))
			used_neworgan = TRUE
			new_organ.set_organ_damage(new_organ.maxHealth * (1 - health_pct))
			new_organ.Insert(organ_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

		if(!used_neworgan)
			QDEL_NULL(new_organ)

/datum/species/proc/worn_items_fit_body_check(mob/living/carbon/wearer)
	for(var/obj/item/equipped_item in wearer.get_equipped_items(INCLUDE_POCKETS))
		var/equipped_item_slot = wearer.get_slot_by_item(equipped_item)
		if(!equipped_item.mob_can_equip(wearer, equipped_item_slot, bypass_equip_delay_self = TRUE, ignore_equipped = TRUE))
			wearer.dropItemToGround(equipped_item, force = TRUE)

/datum/species/proc/update_no_equip_flags(mob/living/carbon/wearer, new_flags)
	no_equip_flags = new_flags
	wearer.hud_used?.update_locked_slots()
	worn_items_fit_body_check(wearer)

/**
 * Normalizes blood in a human if it is excessive. If it is above BLOOD_VOLUME_NORMAL, this will clamp it to that value. It will not give the human more blodo than they have less than this value.
 */
/datum/species/proc/normalize_blood(mob/living/carbon/human/blood_possessing_human)
	var/normalized_blood_values = max(blood_possessing_human.blood_volume, 0, BLOOD_VOLUME_NORMAL)
	blood_possessing_human.blood_volume = normalized_blood_values

/**
 * Proc called when a carbon becomes this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_GAIN] signal.
 * Arguments:
 * * C - Carbon, this is whoever became the new species.
 * * old_species - The species that the carbon used to be before becoming this race, used for regenerating organs.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 * * regenerate_icons - Whether or not to update the bodies icons
 * * replace_missing - Whether or not to replace missing organs
 */
/datum/species/proc/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons = TRUE, replace_missing = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	human_who_gained_species.living_flags |= STOP_OVERLAY_UPDATE_BODY_PARTS //Don't call update_body_parts() for every single bodypart overlay added.

	// Drop the items the new species can't wear
	human_who_gained_species.mob_biotypes = inherent_biotypes
	human_who_gained_species.mob_respiration_type = inherent_respiration_type
	human_who_gained_species.butcher_results = knife_butcher_results?.Copy()

	//update body zones to match what they are supposed to have
	human_who_gained_species.hud_used?.healthdoll.update_body_zones()

	if(old_species.type != type)
		replace_body(human_who_gained_species, src)

	if(!human_who_gained_species.get_bloodtype()?.is_species_universal) // Clown blood is forever.
		//Assigns exotic blood type if the species has one
		if(exotic_bloodtype && human_who_gained_species.get_bloodtype()?.id != exotic_bloodtype)
			human_who_gained_species.set_blood_type(exotic_bloodtype)
		//Otherwise, check if the previous species had an exotic bloodtype and we do not have one and assign a random blood type
		else if(old_species.exotic_bloodtype && isnull(exotic_bloodtype))
			human_who_gained_species.set_blood_type(random_human_blood_type())

	regenerate_organs(human_who_gained_species, old_species, replace_current = FALSE, visual_only = human_who_gained_species.visual_only_organs, replace_missing = replace_missing)
	// Update locked slots AFTER all organ and body stuff is handled
	human_who_gained_species.hud_used?.update_locked_slots()
	// Drop the items the new species can't wear
	INVOKE_ASYNC(src, PROC_REF(worn_items_fit_body_check), human_who_gained_species, TRUE)

	//Resets blood if it is excessively high so they don't gib
	normalize_blood(human_who_gained_species)

	add_body_markings(human_who_gained_species)

	if(length(inherent_traits))
		human_who_gained_species.add_traits(inherent_traits, SPECIES_TRAIT)

	if(inherent_factions)
		for(var/i in inherent_factions)
			human_who_gained_species.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	// All languages associated with this language holder are added with source [LANGUAGE_SPECIES]
	// rather than source [LANGUAGE_ATOM], so we can track what to remove if our species changes again
	var/datum/language_holder/gaining_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in gaining_holder.understood_languages)
		human_who_gained_species.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.spoken_languages)
		human_who_gained_species.grant_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.blocked_speaking)
		human_who_gained_species.add_blocked_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.blocked_understanding)
		human_who_gained_species.add_blocked_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	if(regenerate_icons)
		human_who_gained_species.regenerate_icons()

	SEND_SIGNAL(human_who_gained_species, COMSIG_SPECIES_GAIN, src, old_species)

	properly_gained = TRUE

	human_who_gained_species.living_flags &= ~STOP_OVERLAY_UPDATE_BODY_PARTS

	//we don't allow it to update during species transition, so update it now
	human_who_gained_species.hud_used?.healthdoll.update_appearance()

/**
 * Proc called when a carbon is no longer this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_LOSS] signal.
 * Arguments:
 * * C - Carbon, this is whoever lost this species.
 * * new_species - The new species that the carbon became, used for genetics mutations.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)

	human.living_flags |= STOP_OVERLAY_UPDATE_BODY_PARTS //Don't call update_body_parts() for every single bodypart overlay removed.
	human.butcher_results = null
	for(var/trait in inherent_traits)
		REMOVE_TRAIT(human, trait, SPECIES_TRAIT)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(human.dna.mutation_index) && (inert_mutation in human.dna.mutation_index))
		human.dna.remove_mutation(inert_mutation, MUTATION_SOURCE_ACTIVATED)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = human.dna.mutation_index.Find(inert_mutation)
		human.dna.mutation_index[location] = new_species.inert_mutation
		human.dna.default_mutation_genes[location] = human.dna.mutation_index[location]
		human.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		human.dna.default_mutation_genes[new_species.inert_mutation] = human.dna.mutation_index[new_species.inert_mutation]

	if(inherent_factions)
		for(var/i in inherent_factions)
			human.faction -= i

	clear_tail_moodlets(human)

	remove_body_markings(human)

	// Removes all languages previously associated with [LANGUAGE_SPECIES], gaining our new species will add new ones back
	var/datum/language_holder/losing_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in losing_holder.understood_languages)
		human.remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.spoken_languages)
		human.remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.blocked_speaking)
		human.remove_blocked_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.blocked_understanding)
		human.remove_blocked_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)

	SEND_SIGNAL(human, COMSIG_SPECIES_LOSS, src)

	human.living_flags &= ~STOP_OVERLAY_UPDATE_BODY_PARTS

/**
 * Handles the body of a human
 *
 * Handles lipstick, having no eyes, eye color, undergarnments like underwear, undershirts, and socks, and body layers.
 * Arguments:
 * * species_human - Human, whoever we're handling the body for
 */
/datum/species/proc/handle_body(mob/living/carbon/human/species_human)
	species_human.remove_overlay(BODY_LAYER)
	species_human.remove_overlay(EYES_LAYER)

	if(HAS_TRAIT(species_human, TRAIT_INVISIBLE_MAN))
		return

	if(!HAS_TRAIT(species_human, TRAIT_HUSK))
		var/obj/item/bodypart/head/noggin = species_human.get_bodypart(BODY_ZONE_HEAD)
		if(noggin?.head_flags & HEAD_EYESPRITES)
			// eyes (missing eye sprites get handled by the head itself, but sadly we have to do this stupid shit here, for now)
			var/obj/item/organ/eyes/eye_organ = species_human.get_organ_slot(ORGAN_SLOT_EYES)
			if(eye_organ)
				eye_organ.refresh(call_update = FALSE)
				species_human.overlays_standing[EYES_LAYER] = eye_organ.generate_body_overlay(species_human)
				species_human.apply_overlay(EYES_LAYER)

	if(HAS_TRAIT(species_human, TRAIT_NO_UNDERWEAR))
		return

	// Underwear, Undershirts & Socks
	var/list/standing = list()
	if(species_human.underwear)
		var/datum/sprite_accessory/underwear/underwear = SSaccessories.underwear_list[species_human.underwear]
		var/mutable_appearance/underwear_overlay
		if(underwear)
			if(species_human.dna.species.sexes && species_human.physique == FEMALE && (underwear.gender == MALE))
				underwear_overlay = mutable_appearance(wear_female_version(underwear.icon_state, underwear.icon, FEMALE_UNIFORM_FULL), layer = -BODY_LAYER)
			else
				underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)
			if(!underwear.use_static)
				underwear_overlay.color = species_human.underwear_color
			standing += underwear_overlay

	if(species_human.undershirt)
		var/datum/sprite_accessory/undershirt/undershirt = SSaccessories.undershirt_list[species_human.undershirt]
		if(undershirt)
			var/mutable_appearance/working_shirt
			if(species_human.dna.species.sexes && species_human.physique == FEMALE)
				working_shirt = mutable_appearance(wear_female_version(undershirt.icon_state, undershirt.icon), layer = -BODY_LAYER)
			else
				working_shirt = mutable_appearance(undershirt.icon, undershirt.icon_state, layer = -BODY_LAYER)
			standing += working_shirt

	if(species_human.socks && species_human.num_legs >= 2 && !(species_human.bodyshape & BODYSHAPE_DIGITIGRADE))
		var/datum/sprite_accessory/socks/socks = SSaccessories.socks_list[species_human.socks]
		if(socks)
			standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)

	if(standing.len)
		species_human.overlays_standing[BODY_LAYER] = standing

	species_human.apply_overlay(BODY_LAYER)

/// Updates face (as of now, only eye) offsets
/datum/species/proc/update_face_offset(mob/living/carbon/human/species_human)
	var/list/eye_overlays = species_human.overlays_standing[EYES_LAYER]
	species_human.remove_overlay(EYES_LAYER)

	if(HAS_TRAIT(species_human, TRAIT_INVISIBLE_MAN) || HAS_TRAIT(species_human, TRAIT_HUSK) || !length(eye_overlays))
		return

	var/obj/item/bodypart/head/noggin = species_human.get_bodypart(BODY_ZONE_HEAD)
	for (var/mutable_appearance/overlay as anything in eye_overlays)
		overlay.pixel_w = 0
		overlay.pixel_z = 0
		noggin.worn_face_offset.apply_offset(overlay)

	species_human.overlays_standing[EYES_LAYER] = eye_overlays
	species_human.apply_overlay(EYES_LAYER)

// This exists so sprite accessories can still be per-layer without having to include that layer's
// number in their sprite name, which causes issues when those numbers change.
/datum/species/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"

///Proc that will randomise the hair, or primary appearance element (i.e. for moths wings) of a species' associated mob
/datum/species/proc/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	human_mob.set_hairstyle(random_hairstyle(human_mob.gender), update = FALSE)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob,
/// but will not update the body right away.
/datum/species/proc/randomize_active_underwear_only(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob
/datum/species/proc/randomize_active_underwear(mob/living/carbon/human/human_mob)
	randomize_active_underwear_only(human_mob)
	human_mob.update_body()

/datum/species/proc/randomize_active_features(mob/living/carbon/human/human_mob)
	var/list/new_features = randomize_features()
	for(var/feature_key in new_features)
		human_mob.dna.features[feature_key] = new_features[feature_key]
	human_mob.updateappearance(mutcolor_update = TRUE)

/**
 * Returns a list of features, randomized, to be used by DNA
 */
/datum/species/proc/randomize_features()
	SHOULD_CALL_PARENT(TRUE)

	var/list/new_features = list()
	var/static/list/organs_to_randomize = list()
	for(var/obj/item/organ/organ_path as anything in mutant_organs)
		if(!organ_path.bodypart_overlay)
			continue
		var/overlay_path = initial(organ_path.bodypart_overlay)
		var/datum/bodypart_overlay/mutant/sample_overlay = organs_to_randomize[overlay_path]
		if(isnull(sample_overlay))
			sample_overlay = new overlay_path()
			organs_to_randomize[overlay_path] = sample_overlay

		new_features["[sample_overlay.feature_key]"] = sample_overlay.get_random_appearance().name

	return new_features

/datum/species/proc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	if(HAS_TRAIT(H, TRAIT_NOBREATH) && (H.health < H.crit_threshold) && !HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		H.adjustBruteLoss(0.5 * seconds_per_tick)

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(no_equip_flags & slot)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	// if there's an item in the slot we want, fail
	if(!ignore_equipped)
		if(H.get_item_by_slot(slot))
			return FALSE

	// this check prevents us from equipping something to a slot it doesn't support, WITH the exceptions of storage slots (pockets, suit storage, and backpacks)
	// we don't require having those slots defined in the item's slot_flags, so we'll rely on their own checks further down
	if(!(I.slot_flags & slot))
		var/excused = FALSE
		// Anything that's small or smaller can fit into a pocket by default
		if((slot & (ITEM_SLOT_RPOCKET|ITEM_SLOT_LPOCKET)) && I.w_class <= POCKET_WEIGHT_CLASS)
			excused = TRUE
		else if(slot & (ITEM_SLOT_SUITSTORE|ITEM_SLOT_HANDS))
			excused = TRUE
		if(!excused)
			return FALSE

	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(!(H.mobility_flags & MOBILITY_PICKUP))
				return FALSE
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_NECK)
			return TRUE
		if(ITEM_SLOT_BACK)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_OCLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_GLOVES)
			if(H.num_hands == 0)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(H.num_legs < 2)
				return FALSE
			if((H.bodyshape & BODYSHAPE_DIGITIGRADE) && !(I.item_flags & IGNORE_DIGITIGRADE))
				if(!(I.supports_variations_flags & DIGITIGRADE_VARIATIONS))
					if(!disable_warning)
						to_chat(H, span_warning("The footwear around here isn't compatible with your feet!"))
					return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
			if(eyes?.no_glasses)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_HEAD)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EARS)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ICLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ID)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(!isnull(H.l_store) && H.l_store != I) // no pocket swaps at all
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!isnull(H.r_store) && H.r_store != I)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_SUITSTORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, span_warning("You need a suit before you can attach this [I.name]!"))
				return FALSE
			var/any_suit_storage = (is_type_in_typecache(I, GLOB.any_suit_storage) || I.w_class == WEIGHT_CLASS_TINY)
			if(any_suit_storage)
				return TRUE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, span_warning("\The [I] is too big to attach!")) //should be src?
				return FALSE
			if( is_type_in_list(I, H.wear_suit.allowed) )
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(H.num_hands < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEGCUFFED)
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(H.num_legs < 2)
				return FALSE
			return TRUE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message(span_notice("[H] start putting on [I]..."), span_notice("You start putting on [I]..."))
	return do_after(H, I.equip_delay_self, target = H)


/// Equips the necessary species-relevant gear before putting on the rest of the uniform.
/datum/species/proc/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	human_to_equip.equipOutfit(outfit_important_for_life)

/**
 * Species based handling for irradiation
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The mob requesting handling
 * - time_since_irradiated: The amount of time since the mob was first irradiated
 * - seconds_per_tick: The amount of time that has passed since the last tick
 */
/datum/species/proc/handle_radiation(mob/living/carbon/human/source, time_since_irradiated, seconds_per_tick)
	if(time_since_irradiated > RAD_MOB_KNOCKDOWN && SPT_PROB(RAD_MOB_KNOCKDOWN_PROB, seconds_per_tick))
		if(!source.IsParalyzed())
			source.emote("collapse")
		source.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(source, span_danger("You feel weak."))

	if(time_since_irradiated > RAD_MOB_VOMIT && SPT_PROB(RAD_MOB_VOMIT_PROB, seconds_per_tick))
		source.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 10)

	if(time_since_irradiated > RAD_MOB_MUTATE && SPT_PROB(RAD_MOB_MUTATE_PROB, seconds_per_tick))
		to_chat(source, span_danger("You mutate!"))
		source.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
		source.emote("gasp")
		source.domutcheck()

	if(time_since_irradiated > RAD_MOB_HAIRLOSS && SPT_PROB(RAD_MOB_HAIRLOSS_PROB, seconds_per_tick))
		var/obj/item/bodypart/head/head = source.get_bodypart(BODY_ZONE_HEAD)
		if(!(source.hairstyle == "Bald") && (head?.head_flags & HEAD_HAIR|HEAD_FACIAL_HAIR))
			to_chat(source, span_danger("Your hair starts to fall out in clumps..."))
			addtimer(CALLBACK(src, PROC_REF(go_bald), source), 5 SECONDS)

/**
 * Makes the target human bald.
 *
 * Arguments:
 * - [target][/mob/living/carbon/human]: The mob to make go bald.
 */
/datum/species/proc/go_bald(mob/living/carbon/human/target)
	if(QDELETED(target)) //may be called from a timer
		return
	target.set_facial_hairstyle("Shaved", update = FALSE)
	target.set_hairstyle("Bald") //This calls update_body_parts()

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(SEND_SIGNAL(target, COMSIG_CARBON_PRE_HELP, user, attacker_style) & COMPONENT_BLOCK_HELP_ACT)
		return TRUE

	if(target.body_position == STANDING_UP || (target.appears_alive() && target.stat != SOFT_CRIT && target.stat != HARD_CRIT))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return TRUE

	user.do_cpr(target)

///This proc handles punching damage. IMPORTANT: Our owner is the TARGET and not the USER in this proc. For whatever reason...
/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && !attacker_style?.pacifist_style)
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE

	var/obj/item/organ/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/bodypart/attacking_bodypart
	if(brain)
		attacking_bodypart = brain.get_attacking_limb(target)
	if(!attacking_bodypart)
		attacking_bodypart = user.get_active_hand()

	// Whether or not we get some protein for a successful attack. Nom.
	var/biting = FALSE

	var/atk_verb_index = rand(1, length(attacking_bodypart.unarmed_attack_verbs))
	var/atk_verb = attacking_bodypart.unarmed_attack_verbs[atk_verb_index]
	var/atk_verb_continuous = "[atk_verb]s"
	if (length(attacking_bodypart.unarmed_attack_verbs_continuous) >= atk_verb_index) // Just in case
		atk_verb_continuous = attacking_bodypart.unarmed_attack_verbs_continuous[atk_verb_index]

	var/atk_effect = attacking_bodypart.unarmed_attack_effect

	if(atk_effect == ATTACK_EFFECT_BITE)
		if(!user.is_mouth_covered(ITEM_SLOT_MASK))
			biting = TRUE
		else if(user.get_active_hand()) //In the event we can't bite, emergency swap to see if we can attack with a hand.
			attacking_bodypart = user.get_active_hand()
			atk_verb_index = rand(1, length(attacking_bodypart.unarmed_attack_verbs))
			atk_verb = attacking_bodypart.unarmed_attack_verbs[atk_verb_index]
			atk_verb_continuous = "[atk_verb]s"
			if (length(attacking_bodypart.unarmed_attack_verbs_continuous) >= atk_verb_index) // Just in case
				atk_verb_continuous = attacking_bodypart.unarmed_attack_verbs_continuous[atk_verb_index]
			atk_effect = attacking_bodypart.unarmed_attack_effect
		else  //Nothing? Okay. Fail.
			user.balloon_alert(user, "can't attack!")
			return FALSE

	user.do_attack_animation(target, atk_effect)

	//has our target been shoved recently? If so, they're staggered and we get an easy hit.
	var/staggered = target.has_status_effect(/datum/status_effect/staggered)

	//Someone in a grapple is much more vulnerable to being harmed by punches.
	var/grappled = (target.pulledby && target.pulledby.grab_state >= GRAB_AGGRESSIVE)

	var/damage = rand(attacking_bodypart.unarmed_damage_low, attacking_bodypart.unarmed_damage_high)
	var/limb_accuracy = attacking_bodypart.unarmed_effectiveness
	var/limb_sharpness = attacking_bodypart.unarmed_sharpness

	if(grappled)
		var/pummel_bonus = attacking_bodypart.unarmed_pummeling_bonus
		damage = floor(damage * pummel_bonus)
		limb_accuracy = floor(limb_accuracy * pummel_bonus)

	//Get our puncher's combined brute and burn damage.
	var/puncher_brute_and_burn = (user.getFireLoss() + user.getBruteLoss())

	//Get our targets combined brute and burn damage.
	var/target_brute_and_burn = (target.getFireLoss() + target.getBruteLoss())

	// In a brawl, drunkenness can make you swing more wildly and with more force, and thus catch your opponent off guard, but it could also totally throw you off if you're too intoxicated
	// But god is it going to make you sick moving too much while drunk
	var/user_drunkenness = user.get_drunk_amount()

	if(user_drunkenness)
		if(HAS_TRAIT(user, TRAIT_DRUNKEN_BRAWLER)) // Drunken brawlers only need to be intoxicated, doesn't matter how much
			limb_accuracy += clamp(puncher_brute_and_burn / 2, 10, 200)
			damage += damage * clamp(puncher_brute_and_burn / 100, 0.3, 2) //Basically a multiplier of how much extra damage you get based on how low your health is overall. A floor of about a 30%.
			var/drunken_martial_descriptor = pick("Drunken", "Intoxicated", "Tipsy", "Inebriated", "Delirious", "Day-Drinker's", "Firegut", "Blackout")
			atk_verb = "[drunken_martial_descriptor] [capitalize(atk_verb)]"
			atk_verb_continuous = "[drunken_martial_descriptor] [capitalize(atk_verb_continuous)]"

		else if(user_drunkenness >= 60)
			limb_accuracy = -limb_accuracy // good luck landing a punch now, you drunk fuck
			user.adjust_disgust(5)

		else if(user_drunkenness >= 30)
			limb_accuracy *= 1.2
			user.adjust_disgust(2)

	// Select a zone to hit, blacklisting the part we're attacking with if we're attacking ourselves.
	var/hit_zone = target.get_random_valid_zone(user.zone_selected, blacklisted_parts = (user == target ? list(attacking_bodypart.body_zone) : null))
	var/obj/item/bodypart/affecting = target.get_bodypart(hit_zone)

	var/miss_chance = 100//calculate the odds that a punch misses entirely. considers stamina and brute damage of the puncher. punches miss by default to prevent weird cases
	if(attacking_bodypart.unarmed_damage_low)
		if((target.body_position == LYING_DOWN) || HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER) || staggered || user_drunkenness && HAS_TRAIT(user, TRAIT_DRUNKEN_BRAWLER)) //kicks and attacks against staggered targets never miss (provided your species deals more than 0 damage). Drunken brawlers while drunk also don't miss
			miss_chance = 0
		else
			miss_chance = clamp(UNARMED_MISS_CHANCE_BASE - limb_accuracy + (puncher_brute_and_burn / 2), 0, UNARMED_MISS_CHANCE_MAX) //Limb miss chance + various damage. capped at 80 so there is at least a chance to land a hit.

	if(!damage || !affecting || prob(miss_chance))//future-proofing for species that have 0 damage/weird cases where no zone is targeted
		playsound(target.loc, attacking_bodypart.unarmed_miss_sound, 25, TRUE, -1)
		target.visible_message(span_danger("[user]'s [atk_verb] misses [target]!"), \
						span_danger("You avoid [user]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your [atk_verb] misses [target]!"))
		log_combat(user, target, "attempted to punch")
		return FALSE

	var/armor_block = target.run_armor_check(affecting, MELEE)

	// In a brawl, drunkenness is a boon if you're a bit drunk but not too much. Else you're easier to hit.
	// But, generally, getting hit while drunk is probably a good way to start throwing up
	var/target_drunkenness = target.get_drunk_amount()

	if(target_drunkenness)
		if(HAS_TRAIT(target, TRAIT_DRUNKEN_BRAWLER)) // Drunken brawlers only need to be intoxicated, doesn't matter how much
			armor_block += 20

		else if(target_drunkenness >= 60)
			armor_block *= 0.5
			target.adjust_disgust(5)

		else if(target_drunkenness >= 30)
			armor_block += 10
			target.adjust_disgust(2)

	playsound(target.loc, attacking_bodypart.unarmed_attack_sound, 25, TRUE, -1)

	if(grappled && attacking_bodypart.grappled_attack_verb)
		atk_verb = attacking_bodypart.grappled_attack_verb
		atk_verb_continuous = attacking_bodypart.grappled_attack_verb_continuous

	target.visible_message(span_danger("[user] [atk_verb_continuous] [target]!"), \
					span_userdanger("[user] [atk_verb_continuous] you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You [atk_verb] [target]!"))

	target.lastattacker = user.real_name
	target.lastattackerckey = user.ckey

	if(user.limb_destroyer)
		target.dismembering_strike(user, affecting.body_zone)

	var/attack_direction = get_dir(user, target)
	var/attack_type = attacking_bodypart.attack_type
	var/kicking = (atk_effect == ATTACK_EFFECT_KICK)
	var/final_armor_block = armor_block
	if(kicking || grappled) //kicks and punches when grappling bypass armor slightly.
		if(damage >= 9)
			target.force_say()
		log_combat(user, target, grappled ? "grapple punched" : "kicked")
		final_armor_block -= limb_accuracy
		target.apply_damage(damage, attack_type, affecting, final_armor_block, attack_direction = attack_direction, sharpness = limb_sharpness)
	else // Normal attacks do not gain the benefit of armor penetration.
		target.apply_damage(damage, attack_type, affecting, armor_block, attack_direction = attack_direction, sharpness = limb_sharpness)
		if(damage >= 9)
			target.force_say()
		log_combat(user, target, "punched")

	if(user != target && biting && (target.mob_biotypes & MOB_ORGANIC)) //Good for you. You probably just ate someone alive.
		var/datum/reagents/tasty_meal = new()
		tasty_meal.add_reagent(/datum/reagent/consumable/nutriment/protein, round(damage/3, 1))
		tasty_meal.trans_to(user, tasty_meal.total_volume, transferred_by = user, methods = INGEST)

	SEND_SIGNAL(target, COMSIG_HUMAN_GOT_PUNCHED, user, damage, attack_type, affecting, final_armor_block, kicking, limb_sharpness)

	// If our target is staggered and has sustained enough damage, we can apply a randomly determined status effect to inflict when we punch them.
	// The effects are based on the punching effectiveness of our attacker. Some effects are not reachable by the average human, and require augmentation to reach or being a species with a heavy punch effectiveness.
	// Or they're just drunk enough.
	if(HAS_TRAIT(target, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED) || target.stat == DEAD) //If our target is dead or has specailized armor, there is no way to inflict these effects.
		return

	// If our target is staggered, the target's armor, minus our limb effectiveness sets the minimum necessary amount of damage sustained to cause an effect. We clamp the value for sanity reasons.
	var/effective_armor = max(armor_block, UNARMED_COMBO_HIT_HEALTH_BASE) - limb_accuracy
	if(staggered && target_brute_and_burn >= clamp(effective_armor, 0, 200))
		stagger_combo(user, target, atk_verb, limb_accuracy, armor_block)

/// Handles the stagger combo effect of our punch. Follows the same logic as the above proc, target is our owner, user is our attacker.
/datum/species/proc/stagger_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, atk_verb = "hit", limb_accuracy = 0, armor_block = 0)
	// Randomly determines the effects of our punch. Limb accuracy is a bonus, armor block is a defense
	var/roll_them_bones = rand(-20, 20) + limb_accuracy - armor_block

	switch(roll_them_bones)
		if (-INFINITY to 0) //Mostly a gimmie, this one just keeps them staggered briefly
			target.adjust_staggered_up_to(1 SECONDS, 10 SECONDS)
			target.visible_message(span_warning("[user]'s [atk_verb] briefly winds [target]!"), \
				span_warning("You are briefly winded by [user]'s [atk_verb]!"), span_hear("You hear a thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] briefly winds [target]!"))

		if (1 to 10)
			target.adjust_eye_blur_up_to(5 SECONDS, 10 SECONDS)
			target.visible_message(span_warning("[user]'s [atk_verb] hits [target] so hard, their eyes water! Ouch!"), \
				span_warning("You are hit viciously by [user]'s [atk_verb], and your eyes begin to water!"), span_hear("You hear a thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] causes [target] to tear up!"))

		if (11 to 30)
			target.adjust_dizzy_up_to(5 SECONDS, 10 SECONDS)
			target.adjust_eye_blur_up_to(5 SECONDS, 10 SECONDS)
			target.adjust_confusion_up_to(5 SECONDS, 10 SECONDS)
			target.visible_message(span_warning("[user]'s [atk_verb] hits [target] so hard, they are sent reeling in agony! Damn!"), \
				span_warning("You are hit viciously by [user]'s [atk_verb], and everything becomes a dizzying blur!"), span_hear("You hear a thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] causes [target] to go stumbling about in a confuzed daze!"))

		if(31 to 40)
			target.adjust_dizzy_up_to(5 SECONDS, 10 SECONDS)
			target.adjust_confusion_up_to(5 SECONDS, 10 SECONDS)
			target.adjust_temp_blindness_up_to(5 SECONDS, 10 SECONDS)
			target.visible_message(span_warning("[user]'s [atk_verb] hits [target] so hard, they are sent reeling blindly in agony! Goddamn!"), \
				span_warning("You are hit viciously by [user]'s [atk_verb], and everything becomes a dizzying, blinding blur!"), span_hear("You hear a thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] causes [target] to go stumbling about in a confuzed, blind daze!"))

		if (41 to 45)
			target.apply_effect(4 SECONDS, EFFECT_KNOCKDOWN, armor_block)
			target.visible_message(span_warning("[user]'s [atk_verb] hits [target] so hard, you knock them off their feet! Holy shit!"), \
				span_warning("You are hit viciously by [user]'s [atk_verb] and sent toppling head over heels!"), span_hear("You hear a sickening thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] lands, and you send [target] sailing off their feet!"))

		if (46 to INFINITY)
			target.apply_effect(4 SECONDS, EFFECT_KNOCKDOWN, armor_block)
			var/obj/item/bodypart/affecting = target.get_bodypart(target.get_random_valid_zone(user.zone_selected))
			target.apply_damage(5, BRUTE, affecting, armor_block, wound_bonus = limb_accuracy * 2) //Mostly for the crunchy wounding effect than actually doing damage
			target.visible_message(span_warning("[user]'s [atk_verb] hits [target] so hard, you hit them off their feet with a loud crunch! Fucking hell!"), \
				span_warning("You are hit viciously by [user]'s [atk_verb], and suddenly feel an overwhelming pain as you topple head over heels!"), span_hear("You hear a sickening crack and a loud thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] lands, and [target] is sent crashing to the floor with the immense force! Good god!"))


/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user.body_position != STANDING_UP)
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	user.disarm(target)

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/owner, mob/living/carbon/human/target, datum/martial_art/attacker_style, modifiers)
	if(!istype(owner))
		return
	CHECK_DNA_AND_SPECIES(owner)
	CHECK_DNA_AND_SPECIES(target)

	if(!istype(owner)) //sanity check for drones.
		return
	if(owner.mind)
		attacker_style = GET_ACTIVE_MARTIAL_ART(owner)
	if((owner != target) && target.check_block(owner, 0, owner.name, attack_type = UNARMED_ATTACK))
		log_combat(owner, target, "attempted to touch")
		target.visible_message(span_warning("[owner] attempts to touch [target]!"), \
						span_danger("[owner] attempts to touch you!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, owner)
		to_chat(owner, span_warning("You attempt to touch [target]!"))
		return

	SEND_SIGNAL(owner, COMSIG_MOB_ATTACK_HAND, owner, target, attacker_style)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		disarm(owner, target, attacker_style)
		return // dont attack after
	if(owner.combat_mode)
		harm(owner, target, attacker_style)
	else
		help(owner, target, attacker_style)

//////////////////////////
// ENVIRONMENT HANDLERS //
//////////////////////////

/**
 * Environment handler for species
 *
 * vars:
 * * environment (required) The environment gas mix
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_environment(mob/living/carbon/human/humi, datum/gas_mixture/environment, seconds_per_tick, times_fired)
	handle_environment_pressure(humi, environment, seconds_per_tick, times_fired)
	handle_gas_interaction(humi, environment, seconds_per_tick, times_fired)

/**
 * Body temperature handler for species
 *
 * These procs manage body temp, bamage, and alerts
 * Some of these will still fire when not alive to balance body temp to the room temp.
 * vars:
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_body_temperature(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	// When in a cryo unit we suspend all natural body regulation
	if(istype(humi.loc, /obj/machinery/cryo_cell))
		return

	// Only stabilise core temp when alive and not in statis
	if(humi.stat < DEAD && !HAS_TRAIT(humi, TRAIT_STASIS))
		body_temperature_core(humi, seconds_per_tick, times_fired)

	// These do run in statis
	body_temperature_skin(humi, seconds_per_tick, times_fired)
	body_temperature_alerts(humi, seconds_per_tick, times_fired)

	// Do not cause more damage in statis
	if(!HAS_TRAIT(humi, TRAIT_STASIS))
		body_temperature_damage(humi, seconds_per_tick, times_fired)

/**
 * Used to stabilize the core temperature back to normal on living mobs
 *
 * The metabolisim heats up the core of the mob trying to keep it at the normal body temp
 * vars:
 * * humi (required) The mob we will stabilize
 */
/datum/species/proc/body_temperature_core(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	var/natural_change = get_temp_change_amount(humi.get_body_temp_normal() - humi.coretemperature, 0.06 * seconds_per_tick)
	humi.adjust_coretemperature(humi.metabolism_efficiency * natural_change)

/**
 * Used to normalize the skin temperature on living mobs
 *
 * The core temp effects the skin, then the enviroment effects the skin, then we refect that back to the core.
 * This happens even when dead so bodies revert to room temp over time.
 * vars:
 * * humi (required) The mob we will targeting
 * - seconds_per_tick: The amount of time that is considered as elapsing
 * - times_fired: The number of times SSmobs has fired
 */
/datum/species/proc/body_temperature_skin(mob/living/carbon/human/humi, seconds_per_tick, times_fired)

	// change the core based on the skin temp
	var/skin_core_diff = humi.bodytemperature - humi.coretemperature
	// change rate of 0.04 per second to be slightly below area to skin change rate and still have a solid curve
	var/skin_core_change = get_temp_change_amount(skin_core_diff, 0.04 * seconds_per_tick)

	humi.adjust_coretemperature(skin_core_change)

	// get the enviroment details of where the mob is standing
	var/datum/gas_mixture/environment = humi.loc?.return_air()
	if(!environment) // if there is no environment (nullspace) drop out here.
		return

	// Get the temperature of the environment for area
	var/area_temp = humi.get_temperature(environment)

	// Get the insulation value based on the area's temp
	var/thermal_protection = humi.get_insulation_protection(area_temp)

	// Changes to the skin temperature based on the area
	var/area_skin_diff = area_temp - humi.bodytemperature
	if(!humi.on_fire || area_skin_diff > 0)
		// change rate of 0.05 as area temp has large impact on the surface
		var/area_skin_change = get_temp_change_amount(area_skin_diff, 0.05 * seconds_per_tick)

		// We need to apply the thermal protection of the clothing when applying area to surface change
		// If the core bodytemp goes over the normal body temp you are overheating and becom sweaty
		// This will cause the insulation value of any clothing to reduced in effect (70% normal rating)
		// we add 10 degree over normal body temp before triggering as thick insulation raises body temp
		if(humi.get_body_temp_normal(apply_change=FALSE) + 10 < humi.coretemperature)
			// we are overheating and sweaty insulation is not as good reducing thermal protection
			area_skin_change = (1 - (thermal_protection * 0.7)) * area_skin_change
		else
			area_skin_change = (1 - thermal_protection) * area_skin_change

		humi.adjust_bodytemperature(area_skin_change)

	// Core to skin temp transfer, when not on fire
	if(!humi.on_fire)
		// Get the changes to the skin from the core temp
		var/core_skin_diff = humi.coretemperature - humi.bodytemperature
		// change rate of 0.045 to reflect temp back to the skin at the slight higher rate then core to skin
		var/core_skin_change = (1 + thermal_protection) * get_temp_change_amount(core_skin_diff, 0.045 * seconds_per_tick)

		// We do not want to over shoot after using protection
		if(core_skin_diff > 0)
			core_skin_change = min(core_skin_change, core_skin_diff)
		else
			core_skin_change = max(core_skin_change, core_skin_diff)

		humi.adjust_bodytemperature(core_skin_change)


/**
 * Used to set alerts and debuffs based on body temperature
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_alerts(mob/living/carbon/human/humi)
	var/old_bodytemp = humi.old_bodytemperature
	var/bodytemp = humi.bodytemperature
	// Body temperature is too hot, and we do not have resist traits
	if(bodytemp > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		// Clear cold mood and apply hot mood
		humi.clear_mood_event("cold")
		humi.add_mood_event("hot", /datum/mood_event/hot)

		//Remove any slowdown from the cold.
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		// display alerts based on how hot it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in bodytemp_heat_damage_limit to BODYTEMP_HEAT_WARNING_2)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
		else if(bodytemp in BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
		else
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)

	// Body temperature is too cold, and we do not have resist traits
	else if(bodytemp < bodytemp_cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD) && !humi.has_status_effect(/datum/status_effect/inebriated))
		// clear any hot moods and apply cold mood
		humi.clear_mood_event("hot")
		humi.add_mood_event("cold", /datum/mood_event/cold)
		// Apply cold slow down
		humi.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((bodytemp_cold_damage_limit - humi.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		// Display alerts based how cold it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in BODYTEMP_COLD_WARNING_2 to bodytemp_cold_damage_limit)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
		else if(bodytemp in BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
		else
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)

	// We are not to hot or cold, remove status and moods
	// Optimization here, we check these things based off the old temperature to avoid unneeded work
	// We're not perfect about this, because it'd just add more work to the base case, and resistances are rare
	else if (old_bodytemp > bodytemp_heat_damage_limit || old_bodytemp < bodytemp_cold_damage_limit)
		humi.clear_alert(ALERT_TEMPERATURE)
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		humi.clear_mood_event("cold")
		humi.clear_mood_event("hot")

	// Store the old bodytemp for future checking
	humi.old_bodytemperature = bodytemp

/**
 * Used to apply wounds and damage based on core/body temp
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_damage(mob/living/carbon/human/humi, seconds_per_tick, times_fired)

	//If the body temp is above the wound limit start adding exposure stacks
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT)
		humi.heat_exposure_stacks = min(humi.heat_exposure_stacks + (0.5 * seconds_per_tick), 40)
	else //When below the wound limit, reduce the exposure stacks fast.
		humi.heat_exposure_stacks = max(humi.heat_exposure_stacks - (2 * seconds_per_tick), 0)

	//when exposure stacks are greater then 10 + rand20 try to apply wounds and reset stacks
	if(humi.heat_exposure_stacks > (10 + rand(0, 20)))
		apply_burn_wounds(humi, seconds_per_tick, times_fired)
		humi.heat_exposure_stacks = 0

	// Body temperature is too hot, and we do not have resist traits
	// Apply some burn damage to the body
	if(humi.coretemperature > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		var/firemodifier = humi.fire_stacks / 50
		if (!humi.on_fire) // We are not on fire, reduce the modifier
			firemodifier = min(firemodifier, 0)

		// this can go below 5 at log 2.5
		var/burn_damage = max(log(2 - firemodifier, (humi.coretemperature - humi.get_body_temp_normal(apply_change=FALSE))) - 5, 0)

		// Apply species and physiology modifiers to heat damage
		burn_damage = burn_damage * heatmod * humi.physiology.heat_mod * 0.5 * seconds_per_tick

		// 40% for level 3 damage on humans to scream in pain
		if (humi.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4)
			INVOKE_ASYNC(humi, TYPE_PROC_REF(/mob, emote), "scream")

		// Apply the damage to all body parts
		humi.apply_damage(burn_damage, BURN, spread_damage = TRUE, wound_clothing = FALSE)

	// For cold damage, we cap at the threshold if you're dead
	if(humi.getFireLoss() >= abs(HEALTH_THRESHOLD_DEAD) && humi.stat == DEAD)
		return

	// Apply some burn / brute damage to the body (Dependent if the person is hulk or not)
	var/is_hulk = HAS_TRAIT(humi, TRAIT_HULK)

	var/cold_damage_limit = bodytemp_cold_damage_limit + (is_hulk ? BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER : 0)

	if(humi.coretemperature < cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		var/damage_type = is_hulk ? BRUTE : BURN // Why?
		var/damage_mod = coldmod * humi.physiology.cold_mod * (is_hulk ? HULK_COLD_DAMAGE_MOD : 1)
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(humi.coretemperature in 201 to cold_damage_limit)
			humi.apply_damage(COLD_DAMAGE_LEVEL_1 * damage_mod * seconds_per_tick, damage_type, wound_clothing = FALSE)
		else if(humi.coretemperature in 120 to 200)
			humi.apply_damage(COLD_DAMAGE_LEVEL_2 * damage_mod * seconds_per_tick, damage_type, wound_clothing = FALSE)
		else
			humi.apply_damage(COLD_DAMAGE_LEVEL_3 * damage_mod * seconds_per_tick, damage_type, wound_clothing = FALSE)

/**
 * Used to apply burn wounds on random limbs
 *
 * This is called from body_temperature_damage when exposure to extream heat adds up and causes a wound.
 * The wounds will increase in severity as the temperature increases.
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/apply_burn_wounds(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	// If we are resistant to heat exit
	if(HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		return

	// If our body temp is to low for a wound exit
	if(humi.bodytemperature < BODYTEMP_HEAT_WOUND_LIMIT)
		return

	// Lets pick a random body part and check for an existing burn
	var/obj/item/bodypart/bodypart = pick(humi.bodyparts)
	var/datum/wound/existing_burn
	for (var/datum/wound/iterated_wound as anything in bodypart.wounds)
		var/datum/wound_pregen_data/pregen_data = iterated_wound.get_pregen_data()
		if (pregen_data.wound_series in GLOB.wounding_types_to_series[WOUND_BURN])
			existing_burn = iterated_wound
			break
	// If we have an existing burn try to upgrade it
	var/severity
	if(existing_burn)
		switch(existing_burn.severity)
			if(WOUND_SEVERITY_MODERATE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400) // 800k
					severity = WOUND_SEVERITY_SEVERE
			if(WOUND_SEVERITY_SEVERE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800) // 3200k
					severity = WOUND_SEVERITY_CRITICAL
	else // If we have no burn apply the lowest level burn
		severity = WOUND_SEVERITY_MODERATE

	humi.cause_wound_of_type_and_severity(WOUND_BURN, bodypart, severity, wound_source = "hot temperatures")

	// always take some burn damage
	var/burn_damage = HEAT_DAMAGE_LEVEL_1
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400)
		burn_damage = HEAT_DAMAGE_LEVEL_2
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800)
		burn_damage = HEAT_DAMAGE_LEVEL_3

	humi.apply_damage(burn_damage * seconds_per_tick, BURN, bodypart, wound_clothing = FALSE)

/// Handle the air pressure of the environment
/datum/species/proc/handle_environment_pressure(mob/living/carbon/human/H, datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure)

	// Set alerts and apply damage based on the amount of pressure
	switch(adjusted_pressure)
		// Very high pressure, show an alert and take damage
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.clear_alert(ALERT_PRESSURE)
			else
				var/pressure_damage = min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod * H.physiology.brute_mod * seconds_per_tick
				H.adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)

		// High pressure, show an alert
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)

		// No pressure issues here clear pressure alerts
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert(ALERT_PRESSURE)

		// Low pressure here, show an alert
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert(ALERT_PRESSURE)
			else
				H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)

		// Very low pressure, show an alert and take damage
		else
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert(ALERT_PRESSURE)
			else
				var/pressure_damage = LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod * H.physiology.brute_mod * seconds_per_tick
				H.adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)

/**
 *	Handles exposure to the skin of various gases.
 */
/datum/species/proc/handle_gas_interaction(mob/living/carbon/human/human, datum/gas_mixture/environment, seconds_per_tick, times_fired)
	if((human?.wear_suit?.clothing_flags & STOPSPRESSUREDAMAGE) && (human?.head?.clothing_flags & STOPSPRESSUREDAMAGE))
		return

	for(var/gas_id in environment.gases)
		var/gas_amount = environment.gases[gas_id][MOLES]
		switch(gas_id)
			if(/datum/gas/antinoblium) // Antinoblium - irradiates the target.
				if(gas_amount >= MOLES_GAS_VISIBLE && SPT_PROB(1, gas_amount * seconds_per_tick))
					SSradiation.irradiate(human)

////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	if((H.movement_type & FLYING) && !H.buckled)
		var/obj/item/organ/wings/functional/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(wings)
			wings.toggle_flight(H)
			wings.fly_slip(H)
	. = stunmod * H.physiology.stun_mod * amount

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

////////////////
//Tail Wagging//
////////////////

/*
 * Clears all tail related moodlets when they lose their species.
 *
 * former_tail_owner - the mob that was once a species with a tail and now is a different species
 */
/datum/species/proc/clear_tail_moodlets(mob/living/carbon/human/former_tail_owner)
	former_tail_owner.clear_mood_event("tail_lost")
	former_tail_owner.clear_mood_event("tail_balance_lost")
	former_tail_owner.clear_mood_event("tail_regained")

/// Returns a list of strings representing features this species has.
/// Used by the preferences UI to know what buttons to show.
/datum/species/proc/get_features()
	var/cached_features = GLOB.features_by_species[type]
	if (!isnull(cached_features))
		return cached_features

	var/list/features = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if ( \
			(preference.relevant_inherent_trait in inherent_traits) \
			|| (preference.relevant_external_organ in get_mut_organs()) \
			|| (preference.relevant_head_flag && check_head_flags(preference.relevant_head_flag)) \
			|| (preference.relevant_body_markings in body_markings) \
		)
			features += preference.savefile_key

	for (var/obj/item/organ/organ_type as anything in mutant_organs)
		var/preference = initial(organ_type.preference)
		if (!isnull(preference))
			features += preference

	GLOB.features_by_species[type] = features

	return features

/// Given a human, will adjust it before taking a picture for the preferences UI.
/// This should create a CONSISTENT result, so the icons don't randomly change.
/datum/species/proc/prepare_human_for_preview(mob/living/carbon/human/human)
	return

/// Returns the species' scream sound.
/datum/species/proc/get_scream_sound(mob/living/carbon/human/human)
	return

/// Returns the species' cry sound.
/datum/species/proc/get_cry_sound(mob/living/carbon/human/human)
	return

/// Returns the species' sigh sound.
/datum/species/proc/get_sigh_sound(mob/living/carbon/human/human)
	return

/// Returns the species' sniff sound.
/datum/species/proc/get_sniff_sound(mob/living/carbon/human/human)
	return

/// Returns the species' cough sound.
/datum/species/proc/get_cough_sound(mob/living/carbon/human/human)
	return

/// Returns the species' laugh sound
/datum/species/proc/get_laugh_sound(mob/living/carbon/human/human)
	return

/// Returns the species' sneeze sound.
/datum/species/proc/get_sneeze_sound(mob/living/carbon/human/human)
	return

/// Returns the species' snore sound.
/datum/species/proc/get_snore_sound(mob/living/carbon/human/human)
	return

/// Returns the species' hiss sound
/datum/species/proc/get_hiss_sound(mob/living/carbon/human/human)
	return

/datum/species/proc/get_mut_organs(include_brain = TRUE)
	var/list/mut_organs = list()
	mut_organs += mutant_organs
	if (include_brain)
		mut_organs += mutantbrain
	mut_organs += mutantheart
	mut_organs += mutantlungs
	mut_organs += mutanteyes
	mut_organs += mutantears
	mut_organs += mutanttongue
	mut_organs += mutantliver
	mut_organs += mutantstomach
	mut_organs += mutantappendix
	list_clear_nulls(mut_organs)
	return mut_organs

/datum/species/proc/get_types_to_preload()
	return get_mut_organs(FALSE)


/**
 * Owner login
 */

/**
 * A simple proc to be overwritten if something needs to be done when a mob logs in. Does nothing by default.
 *
 * Arguments:
 * * owner - The owner of our species.
 */
/datum/species/proc/on_owner_login(mob/living/carbon/human/owner)
	return

/**
 * Gets a description of the species' *physical* attributes. What makes playing as one different. Used in magic mirrors.
 *
 * Returns a string.
 */

/datum/species/proc/get_physical_attributes()
	return "An unremarkable species."
/**
 * Gets a short description for the specices. Should be relatively succinct.
 * Used in the preference menu.
 *
 * Returns a string.
 */

/datum/species/proc/get_species_description()
	SHOULD_CALL_PARENT(FALSE)

	stack_trace("Species [name] ([type]) did not have a description set, and is a selectable roundstart race! Override get_species_description.")
	return "No species description set, file a bug report!"

/**
 * Gets the lore behind the type of species. Can be long.
 * Used in the preference menu.
 *
 * Returns a list of strings.
 * Between each entry in the list, a newline will be inserted, for formatting.
 */
/datum/species/proc/get_species_lore()
	SHOULD_CALL_PARENT(FALSE)
	RETURN_TYPE(/list)

	stack_trace("Species [name] ([type]) did not have lore set, and is a selectable roundstart race! Override get_species_lore.")
	return list("No species lore set, file a bug report!")

/**
 * Translate the species liked foods from bitfields into strings
 * and returns it in the form of an associated list.
 *
 * Returns a list, or null if they have no diet.
 */
/datum/species/proc/get_species_diet()
	if((TRAIT_NOHUNGER in inherent_traits) || !mutanttongue)
		return null

	var/static/list/food_flags = FOOD_FLAGS
	var/obj/item/organ/tongue/fake_tongue = mutanttongue

	return list(
		"liked_food" = bitfield_to_list(initial(fake_tongue.liked_foodtypes), food_flags),
		"disliked_food" = bitfield_to_list(initial(fake_tongue.disliked_foodtypes), food_flags),
		"toxic_food" = bitfield_to_list(initial(fake_tongue.toxic_foodtypes), food_flags),
	)

/**
 * Generates a list of "perks" related to this species
 * (Postives, neutrals, and negatives)
 * in the format of a list of lists.
 * Used in the preference menu.
 *
 * "Perk" format is as followed:
 * list(
 *   SPECIES_PERK_TYPE = type of perk (postiive, negative, neutral - use the defines)
 *   SPECIES_PERK_ICON = icon shown within the UI
 *   SPECIES_PERK_NAME = name of the perk on hover
 *   SPECIES_PERK_DESC = description of the perk on hover
 * )
 *
 * Returns a list of lists.
 * The outer list is an assoc list of [perk type]s to a list of perks.
 * The innter list is a list of perks. Can be empty, but won't be null.
 */
/datum/species/proc/get_species_perks()
	var/list/species_perks = list()

	// Let us get every perk we can conceive of in one big list.
	// The order these are called (kind of) matters.
	// Species unique perks first, as they're more important than genetic perks,
	// and language perk last, as it comes at the end of the perks list
	species_perks += create_pref_unique_perks()
	species_perks += create_pref_blood_perks()
	species_perks += create_pref_damage_perks()
	species_perks += create_pref_temperature_perks()
	species_perks += create_pref_traits_perks()
	species_perks += create_pref_biotypes_perks()
	species_perks += create_pref_organs_perks()
	species_perks += create_pref_language_perk()

	// Some overrides may return `null`, prevent those from jamming up the list.
	list_clear_nulls(species_perks)

	// Now let's sort them out for cleanliness and sanity
	var/list/perks_to_return = list(
		SPECIES_POSITIVE_PERK = list(),
		SPECIES_NEUTRAL_PERK = list(),
		SPECIES_NEGATIVE_PERK =  list(),
	)

	for(var/list/perk as anything in species_perks)
		var/perk_type = perk[SPECIES_PERK_TYPE]
		// If we find a perk that isn't postiive, negative, or neutral,
		// it's a bad entry - don't add it to our list. Throw a stack trace and skip it instead.
		if(isnull(perks_to_return[perk_type]))
			stack_trace("Invalid species perk ([perk[SPECIES_PERK_NAME]]) found for species [name]. \
				The type should be positive, negative, or neutral. (Got: [perk_type])")
			continue

		perks_to_return[perk_type] += list(perk)

	return perks_to_return

/**
 * Used to add any species specific perks to the perk list.
 *
 * Returns null by default. When overriding, return a list of perks.
 */
/datum/species/proc/create_pref_unique_perks()
	return null

/**
 * Adds adds any perks related to sustaining damage.
 * For example, brute damage vulnerability, or fire damage resistance.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_damage_perks()
	// We use the chest to figure out brute and burn mod perks
	var/obj/item/bodypart/chest/fake_chest = bodypart_overrides[BODY_ZONE_CHEST]

	var/list/to_add = list()

	// Brute related
	if(initial(fake_chest.brute_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Brutal Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to brute damage.",
		))

	if(initial(fake_chest.brute_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Brutal Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to brute damage.",
		))

	// Burn related
	if(initial(fake_chest.burn_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Burn Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to burn damage.",
		))

	if(initial(fake_chest.burn_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Burn Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to burn damage.",
		))

	// Shock damage
	if(siemens_coeff > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shock Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to being shocked.",
		))

	if(siemens_coeff < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Shock Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to being shocked.",
		))

	return to_add

/**
 * Adds adds any perks related to how the species deals with temperature.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_temperature_perks()
	var/list/to_add = list()

	// Hot temperature tolerance
	if(heatmod > 1 || bodytemp_heat_damage_limit < BODYTEMP_HEAT_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-high",
			SPECIES_PERK_NAME = "Heat Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to high temperatures.",
		))

	if(heatmod < 1 || bodytemp_heat_damage_limit > BODYTEMP_HEAT_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Heat Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to hotter environments.",
		))

	// Cold temperature tolerance
	if(coldmod > 1 || bodytemp_cold_damage_limit > BODYTEMP_COLD_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to cold temperatures.",
		))

	if(coldmod < 1 || bodytemp_cold_damage_limit < BODYTEMP_COLD_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Cold Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to colder environments.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' blood (or lack thereof).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_blood_perks()
	var/list/to_add = list()
	var/datum/blood_type/blood_type = exotic_bloodtype ? get_blood_type(exotic_bloodtype) : null

	// TRAIT_NOBLOOD takes priority by default
	if(TRAIT_NOBLOOD in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Bloodletted",
			SPECIES_PERK_DESC = "[plural_form] do not have blood.",
		))

	// Otherwise, check if their exotic blood is a valid typepath
	else if(ispath(blood_type?.reagent_type))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = initial(blood_type.reagent_type.name),
			SPECIES_PERK_DESC = "[name] blood is [initial(blood_type.reagent_type.name)], which can make receiving medical treatment harder.",
		))

	// Otherwise otherwise, see if they have an exotic bloodtype set
	else if(exotic_bloodtype)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Exotic Blood",
			SPECIES_PERK_DESC = "[plural_form] have \"[exotic_bloodtype]\" type blood, which can make receiving medical treatment harder.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_traits list.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_traits_perks()
	var/list/to_add = list()

	if(TRAIT_LIMBATTACHMENT in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-plus",
			SPECIES_PERK_NAME = "Limbs Easily Reattached",
			SPECIES_PERK_DESC = "[plural_form] limbs are easily readded, and as such do not \
				require surgery to restore. Simply pick it up and pop it back in, champ!",
		))

	if(TRAIT_EASYDISMEMBER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Limbs Easily Dismembered",
			SPECIES_PERK_DESC = "[plural_form] limbs are not secured well, and as such they are easily dismembered.",
		))

	if(TRAIT_EASILY_WOUNDED in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Easily Wounded",
			SPECIES_PERK_DESC = "[plural_form] skin is very weak and fragile. They are much easier to apply serious wounds to.",
		))

	if(TRAIT_TOXINLOVER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Toxins Lover",
			SPECIES_PERK_DESC = "Toxins damage dealt to [plural_form] are reversed - healing toxins will instead cause harm, and \
				causing toxins will instead cause healing. Be careful around purging chemicals!",
		))

	if (TRAIT_GENELESS in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "No Genes",
			SPECIES_PERK_DESC = "[plural_form] have no genes, making genetic scrambling a useless weapon, but also locking them out from getting genetic powers.",
		))

	if (TRAIT_NOBREATH in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "No Respiration",
			SPECIES_PERK_DESC = "[plural_form] have no need to breathe!",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_biotypes flags.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_biotypes_perks()
	var/list/to_add = list()

	if(inherent_biotypes & MOB_UNDEAD)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Undead",
			SPECIES_PERK_DESC = "[plural_form] are of the undead! The undead do not have the need to eat or breathe, and \
				most viruses will not be able to infect a walking corpse. Their worries mostly stop at remaining in one piece, really.",
		))

	return to_add

/**
 * Adds any perks relating to inherent differences to this species' organs.
 * This proc is only suitable for generic differences, like alcohol tolerance, or heat threshold for breathing.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_organs_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	to_add += create_pref_liver_perks()
	to_add += create_pref_lung_perks()

	return to_add

/datum/species/proc/create_pref_liver_perks()
	RETURN_TYPE(/list)

	if(isnull(mutantliver) || (TRAIT_LIVERLESS_METABOLISM in inherent_traits))
		return null

	var/list/to_add = list()

	var/alcohol_tolerance = initial(mutantliver.alcohol_tolerance)
	var/obj/item/organ/liver/base_liver = /obj/item/organ/liver
	var/tolerance_difference = alcohol_tolerance - initial(base_liver.alcohol_tolerance)

	if (tolerance_difference != 0)
		var/difference_positive = (tolerance_difference > 0)
		var/more_or_less = (difference_positive) ? "more" : "less"
		var/perk_type = (difference_positive) ? SPECIES_NEGATIVE_PERK : SPECIES_POSITIVE_PERK
		var/perk_name = "Alcohol " + ((difference_positive) ? "Weakness" : "Tolerance")
		var/percent_difference = (alcohol_tolerance / initial(base_liver.alcohol_tolerance)) * 100

		to_add += list(list(
			SPECIES_PERK_TYPE = perk_type,
			SPECIES_PERK_ICON = "wine-glass",
			SPECIES_PERK_NAME = perk_name,
			SPECIES_PERK_DESC = "[name] livers are [more_or_less] susceptable to alcohol than human livers, by about [percent_difference]%."
		))

	var/tox_shrugging = initial(mutantliver.toxTolerance)
	var/shrugging_difference = tox_shrugging - initial(base_liver.toxTolerance)
	if (shrugging_difference != 0)
		var/difference_positive = (shrugging_difference > 0)
		var/more_or_less = (difference_positive) ? "more" : "less"
		var/perk_type = (difference_positive) ? SPECIES_POSITIVE_PERK : SPECIES_NEGATIVE_PERK
		var/perk_name = ("Toxin " + ((difference_positive) ? "Resistant" : "Vulnerable")) + " Liver"

		to_add += list(list(
			SPECIES_PERK_TYPE = perk_type,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = perk_name,
			SPECIES_PERK_DESC = "[name] livers are capable of rapidly shrugging off [tox_shrugging]u of toxins, which is [more_or_less] than humans."
		))

	return to_add

/datum/species/proc/create_pref_lung_perks()
	RETURN_TYPE(/list)

	if(isnull(mutantlungs) || (TRAIT_NOBREATH in inherent_traits))
		return null

	var/list/to_add = list()

	if (breathid != GAS_O2)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "[capitalize(breathid)] Breathing",
			SPECIES_PERK_DESC = "[plural_form] must breathe [breathid] to survive. You receive a tank when you arrive.",
		))

	return to_add

/**
 * Adds in a language perk based on all the languages the species
 * can speak by default (according to their language holder).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_language_perk()

	// Grab galactic common as a path, for comparisons
	var/datum/language/common_language = /datum/language/common

	// Now let's find all the languages they can speak that aren't common
	var/list/bonus_languages = list()
	var/datum/language_holder/basic_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/datum/language/language_type as anything in basic_holder.spoken_languages)
		if(ispath(language_type, common_language))
			continue
		bonus_languages += initial(language_type.name)

	if(!length(bonus_languages))
		return // You're boring

	var/list/to_add = list()
	if(common_language in basic_holder.spoken_languages)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Native Speaker",
			SPECIES_PERK_DESC = "Alongside [initial(common_language.name)], [plural_form] gain the ability to speak [english_list(bonus_languages)].",
		))

	else
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Foreign Speaker",
			SPECIES_PERK_DESC = "[plural_form] may not speak [initial(common_language.name)], but they can speak [english_list(bonus_languages)].",
		))

	return to_add

///Handles replacing all of the bodyparts with their species version during set_species()
/datum/species/proc/replace_body(mob/living/carbon/target, datum/species/new_species)
	new_species ||= target.dna.species //If no new species is provided, assume its src.
	//Note for future: Potentionally add a new C.dna.species() to build a template species for more accurate limb replacement

	var/list/final_bodypart_overrides = new_species.bodypart_overrides.Copy()
	if((new_species.digitigrade_customization == DIGITIGRADE_OPTIONAL && target.dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS) || new_species.digitigrade_customization == DIGITIGRADE_FORCED)
		final_bodypart_overrides[BODY_ZONE_R_LEG] = /obj/item/bodypart/leg/right/digitigrade
		final_bodypart_overrides[BODY_ZONE_L_LEG] = /obj/item/bodypart/leg/left/digitigrade

	for(var/obj/item/bodypart/old_part as anything in target.bodyparts)
		if((old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES) || (old_part.bodypart_flags & BODYPART_IMPLANTED))
			continue

		var/path = final_bodypart_overrides?[old_part.body_zone]
		var/obj/item/bodypart/new_part
		if(path)
			new_part = new path()
			new_part.replace_limb(target, TRUE)
			new_part.update_limb(is_creating = TRUE)
			new_part.set_initial_damage(old_part.brute_dam, old_part.burn_dam)
		qdel(old_part)

/// Creates body parts for the target completely from scratch based on the species
/datum/species/proc/create_fresh_body(mob/living/carbon/target)
	var/list/override_limbs = list()
	for(var/bodypart in bodypart_overrides)
		override_limbs += bodypart_overrides[bodypart]
	target.create_bodyparts(override_limbs)

/**
 * Checks if the species has a head with these head flags, by default.
 * Admittedly, this is a very weird and seemingly redundant proc, but it
 * gets used by some preferences (such as hair style) to determine whether
 * or not they are accessible.
 **/
/datum/species/proc/check_head_flags(check_flags = NONE)
	var/obj/item/bodypart/head/fake_head = bodypart_overrides[BODY_ZONE_HEAD]
	return (initial(fake_head.head_flags) & check_flags)

/datum/species/dump_harddel_info()
	if(harddel_deets_dumped)
		return
	harddel_deets_dumped = TRUE
	return "Gained / Owned: [properly_gained ? "Yes" : "No"]"

/**
 * Get what hair color is used by this species for a mob.
 *
 * Arguments
 * * for_mob - The mob to get the hair color for. Required.
 *
 * Returns a color string or null.
 */
/datum/species/proc/get_fixed_hair_color(mob/living/carbon/for_mob)
	ASSERT(!isnull(for_mob))
	switch(hair_color_mode)
		if(USE_MUTANT_COLOR)
			return for_mob.dna.features[FEATURE_MUTANT_COLOR]
		if(USE_FIXED_MUTANT_COLOR)
			return fixed_mut_color

	return null

/// Add species appropriate body markings
/datum/species/proc/add_body_markings(mob/living/carbon/human/hooman)
	for(var/markings_type in body_markings) //loop through possible species markings
		var/datum/bodypart_overlay/simple/body_marking/markings = new markings_type() // made to die... mostly because we cant use initial on lists but its convenient and organized
		var/accessory_name = hooman.dna.features[markings.dna_feature_key] || body_markings[markings_type] //get the accessory name from dna
		for(var/obj/item/bodypart/part as anything in markings.applies_to) //check through our limbs
			var/obj/item/bodypart/people_part = hooman.get_bodypart(initial(part.body_zone)) // and see if we have a compatible marking for that limb
			if(isnull(people_part))
				continue

			var/datum/bodypart_overlay/simple/body_marking/overlay = new markings_type()
			overlay.set_appearance(accessory_name, hooman.dna.features[FEATURE_MUTANT_COLOR])
			people_part.add_bodypart_overlay(overlay)

		qdel(markings)

/// Remove body markings
/datum/species/proc/remove_body_markings(mob/living/carbon/human/hooman)
	for(var/obj/item/bodypart/part as anything in hooman.bodyparts)
		for(var/datum/bodypart_overlay/simple/body_marking/marking in part.bodypart_overlays)
			part.remove_bodypart_overlay(marking)

/**
 * Calculates the expected height values for this species
 *
 * Return a height value corresponding to a specific height filter
 * Return null to just use the mob's base height
 */
/datum/species/proc/update_species_heights(mob/living/carbon/human/holder)
	if(HAS_TRAIT(holder, TRAIT_DWARF))
		return HUMAN_HEIGHT_DWARF

	if(HAS_TRAIT(holder, TRAIT_TOO_TALL))
		return HUMAN_HEIGHT_TALLEST

	return null
