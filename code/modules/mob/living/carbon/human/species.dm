GLOBAL_LIST_EMPTY(roundstart_races)

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
	//This is used if you want to use a different species' limb sprites.
	var/limbs_id
	///This is the fluff name. They are displayed on health analyzers and in the character setup menu. Leave them generic for other servers to customize.
	var/name
	// Default color. If mutant colors are disabled, this is the color that will be used by that race.
	var/default_color = "#FFFFFF"

	///Whether or not the race has sexual characteristics (biological genders). At the moment this is only FALSE for skeletons and shadows
	var/sexes = TRUE

	///Clothing offsets. If a species has a different body than other species, you can offset clothing so they look less weird.
	var/list/offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))

	///This allows races to have specific hair colors. If null, it uses the H's hair/facial hair colors. If "mutcolor", it uses the H's mutant_color. If "fixedmutcolor", it uses fixedmutcolor
	var/hair_color
	///The alpha used by the hair. 255 is completely solid, 0 is invisible.
	var/hair_alpha = 255

	///Does the species use skintones or not? As of now only used by humans.
	var/use_skintones = FALSE
	///If your race bleeds something other than bog standard blood, change this to reagent id. For example, ethereals bleed liquid electricity.
	var/exotic_blood = ""
	///If your race uses a non standard bloodtype (A+, O-, AB-, etc). For example, lizards have L type blood.
	var/exotic_bloodtype = ""
	///What the species drops when gibbed by a gibber machine.
	var/meat = /obj/item/food/meat/slab/human
	///What skin the species drops when gibbed by a gibber machine.
	var/skinned_type
	///Bitfield for food types that the species likes, giving them a mood boost. Lizards like meat, for example.
	var/liked_food = NONE
	///Bitfield for food types that the species dislikes, giving them disgust. Humans hate raw food, for example.
	var/disliked_food = GROSS
	///Bitfield for food types that the species absolutely hates, giving them even more disgust than disliked food. Meat is "toxic" to moths, for example.
	var/toxic_food = TOXIC
	///Inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example.
	var/list/no_equip = list()
	/// Allows the species to equip items that normally require a jumpsuit without having one equipped. Used by golems.
	var/nojumpsuit = FALSE
	///Affects the speech message, for example: Motharula flutters, "My speech message is flutters!"
	var/say_mod = "says"
	///What languages this species can understand and say. Use a [language holder datum][/datum/language_holder] in this var.
	var/species_language_holder = /datum/language_holder
	/**
	  * Visible CURRENT bodyparts that are unique to a species.
	  * DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK
	  * SHIT UP! Changes to this list for non-species specific bodyparts (ie
	  * cat ears and tails) should be assigned at organ level if possible.
	  * Assoc values are defaults for given bodyparts, also modified by aforementioned organs.
	  * They also allow for faster '[]' list access versus 'in'. Other than that, they are useless right now.
	  * Layer hiding is handled by [/datum/species/proc/handle_mutant_bodyparts] below.
	  */
	var/list/mutant_bodyparts = list()
	///Internal organs that are unique to this race, like a tail.
	var/list/mutant_organs = list()
	///The bodyparts this species uses. assoc of bodypart string - bodypart type. Make sure all the fucking entries are in or I'll skin you alive.
	var/list/bodypart_overides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm,\
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm,\
		BODY_ZONE_HEAD = /obj/item/bodypart/head,\
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg,\
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg,\
		BODY_ZONE_CHEST = /obj/item/bodypart/chest)

	///List of external organs to generate like horns, frills, wings, etc. list(typepath of organ = "Round Beautiful BDSM Snout"). Still WIP
	var/list/external_organs = list()

	///Multiplier for the race's speed. Positive numbers make it move slower, negative numbers make it move faster.
	var/speedmod = 0
	///Percentage modifier for overall defense of the race, or less defense, if it's negative.
	var/armor = 0
	///multiplier for brute damage
	var/brutemod = 1
	///multiplier for burn damage
	var/burnmod = 1
	///multiplier for damage from cold temperature
	var/coldmod = 1
	///multiplier for damage from hot temperature
	var/heatmod = 1
	///multiplier for stun durations
	var/stunmod = 1
	///multiplier for money paid at payday
	var/payday_modifier = 1
	///Type of damage attack does. Ethereals attack with burn damage for example.
	var/attack_type = BRUTE
	///Lowest possible punch damage this species can give. If this is set to 0, punches will always miss.
	var/punchdamagelow = 1
	///Highest possible punch damage this species can give.
	var/punchdamagehigh = 10
	///Damage at which punches from this race will stun
	var/punchstunthreshold = 10 //yes it should be to the attacked race but it's not useful that way even if it's logical
	///Base electrocution coefficient.  Basically a multiplier for damage from electrocutions.
	var/siemens_coeff = 1
	///What kind of damage overlays (if any) appear on our species when wounded? If this is "", does not add an overlay.
	var/damage_overlay_type = "human"
	///To use MUTCOLOR with a fixed color that's independent of the mcolor feature in DNA.
	var/fixed_mut_color = ""
	///Special mutation that can be found in the genepool exclusively in this species. Dont leave empty or changing species will be a headache
	var/inert_mutation = DWARFISM
	///Used to set the mob's deathsound upon species change
	var/deathsound
	///Sounds to override barefeet walking
	var/list/special_step_sounds
	///Special sound for grabbing
	var/grab_sound
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life

	///Is this species a flying species? Used as an easy check for some things
	var/flying_species = FALSE
	///The actual flying ability given to flying species
	var/datum/action/innate/flight/fly
	//Dictates which wing icons are allowed for a given species. If count is >1 a radial menu is used to choose between all icons in list
	var/list/wings_icons = list("Angel")
	///Used to determine what description to give when using a potion of flight, if false it will describe them as growing new wings
	var/has_innate_wings = FALSE

	/// The natural temperature for a body
	var/bodytemp_normal = BODYTEMP_NORMAL
	/// Minimum amount of kelvin moved toward normal body temperature per tick.
	var/bodytemp_autorecovery_min = BODYTEMP_AUTORECOVERY_MINIMUM
	/// The body temperature limit the body can take before it starts taking damage from heat.
	var/bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT
	/// The body temperature limit the body can take before it starts taking damage from cold.
	var/bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT

	/// The icon_state of the fire overlay added when sufficently ablaze and standing. see onfire.dmi
	var/fire_overlay = "Standing"

	///the species that body parts are surgically compatible with (found in _DEFINES/mobs.dm)
	///current acceptable bitfields are HUMAN_BODY, ALIEN_BODY, LARVA_BODY, MONKEY_BODY, or NONE
	var/allowed_animal_origin = HUMAN_BODY


	///Species-only traits. Can be found in [code/__DEFINES/DNA.dm]
	var/list/species_traits = list()
	///Generic traits tied to having the species.
	var/list/inherent_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP)
	/// List of biotypes the mob belongs to. Used by diseases.
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	///Punch-specific attack verb.
	var/attack_verb = "punch"
	/// The visual effect of the attack.
	var/attack_effect = ATTACK_EFFECT_PUNCH
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	///What gas does this species breathe? Used by suffocation screen alerts, most of actual gas breathing is handled by mutantlungs. See [life.dm][code/modules/mob/living/carbon/human/life.dm]
	var/breathid = "o2"

	///What anim to use for dusting
	var/dust_anim = "dust-h"
	///What anim to use for gibbing
	var/gib_anim = "gibbed-h"


	//Do NOT remove by setting to null. use OR make a RESPECTIVE TRAIT (removing stomach? add the NOSTOMACH trait to your species)
	//why does it work this way? because traits also disable the downsides of not having an organ, removing organs but not having the trait will make your species die

	///Replaces default brain with a different organ
	var/obj/item/organ/brain/mutantbrain = /obj/item/organ/brain
	///Replaces default heart with a different organ
	var/obj/item/organ/heart/mutantheart = /obj/item/organ/heart
	///Replaces default lungs with a different organ
	var/obj/item/organ/lungs/mutantlungs = /obj/item/organ/lungs
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
	///Forces an item into this species' hands. Only an honorary mutantthing because this is not an organ and not loaded in the same way, you've been warned to do your research.
	var/obj/item/mutanthands



	///Bitflag that controls what in game ways something can select this species as a spawnable source, such as magic mirrors. See [mob defines][code/__DEFINES/mobs.dm] for possible sources.
	var/changesource_flags = NONE

	///For custom overrides for species ass images
	var/icon/ass_image

	/// List of family heirlooms this species can get with the family heirloom quirk. List of types.
	var/list/family_heirlooms

	///List of results you get from knife-butchering. null means you cant butcher it. Associated by resulting type - value of amount
	var/list/knife_butcher_results

	///List of visual overlays created by handle_body()
	var/list/body_vis_overlays = list()

	/// Should we preload this species's organs?
	var/preload = TRUE

	/// Do we try to prevent reset_perspective() from working? Useful for Dullahans to stop perspective changes when they're looking through their head.
	var/prevent_perspective_change = FALSE

///////////
// PROCS //
///////////


/datum/species/New()

	if(!limbs_id) //if we havent set a limbs id to use, just use our own id
		limbs_id = id
	wings_icons = string_list(wings_icons)
	..()

/// Gets a list of all species available to choose in roundstart.
/proc/get_selectable_species()
	RETURN_TYPE(/list)

	if (!GLOB.roundstart_races.len)
		GLOB.roundstart_races = generate_selectable_species()

	return GLOB.roundstart_races

/**
 * Generates species available to choose in character setup at roundstart
 *
 * This proc generates which species are available to pick from in character setup.
 * If there are no available roundstart species, defaults to human.
 */
/proc/generate_selectable_species()
	var/list/selectable_species = list()

	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = new species_type
		if(species.check_roundstart_eligible())
			selectable_species += species.id
			qdel(species)

	if(!selectable_species.len)
		selectable_species += SPECIES_HUMAN

	return selectable_species

/**
 * Checks if a species is eligible to be picked at roundstart.
 *
 * Checks the config to see if this species is allowed to be picked in the character setup menu.
 * Used by [/proc/generate_selectable_species].
 */
/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/**
 * Generates a random name for a carbon.
 *
 * This generates a random unique name based on a human's species and gender.
 * Arguments:
 * * gender - The gender that the name should adhere to. Use MALE for male names, use anything else for female names.
 * * unique - If true, ensures that this new name is not a duplicate of anyone else's name currently on the station.
 * * lastname - Does this species' naming system adhere to the last name system? Set to false if it doesn't.
 */
/datum/species/proc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_name(gender)

	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male)
	else
		randname = pick(GLOB.first_names_female)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names)]"

	return randname

/**
 * Copies some vars and properties over that should be kept when creating a copy of this species.
 *
 * Used by slimepeople to copy themselves, and by the DNA datum to hardset DNA to a species
 * Arguments:
 * * old_species - The species that the carbon used to be before copying
 */
/datum/species/proc/copy_properties_from(datum/species/old_species)
	return

/**
 * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does.
 *
 * Takes all organ slots, removes organs a species should not have, adds organs a species should have.
 * can use replace_current to refresh all organs, creating an entirely new set.
 *
 * Arguments:
 * * C - carbon, the owner of the species datum AKA whoever we're regenerating organs in
 * * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
 * * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
 * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 * * visual_only - boolean, only load organs that change how the species looks. Do not use for normal gameplay stuff
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	//what should be put in if there is no mutantorgan (brains handled separately)
	var/list/slot_mutantorgans = list(ORGAN_SLOT_BRAIN = mutantbrain, ORGAN_SLOT_HEART = mutantheart, ORGAN_SLOT_LUNGS = mutantlungs, ORGAN_SLOT_APPENDIX = mutantappendix, \
	ORGAN_SLOT_EYES = mutanteyes, ORGAN_SLOT_EARS = mutantears, ORGAN_SLOT_TONGUE = mutanttongue, ORGAN_SLOT_LIVER = mutantliver, ORGAN_SLOT_STOMACH = mutantstomach)

	for(var/slot in list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_APPENDIX, \
	ORGAN_SLOT_EYES, ORGAN_SLOT_EARS, ORGAN_SLOT_TONGUE, ORGAN_SLOT_LIVER, ORGAN_SLOT_STOMACH))

		var/obj/item/organ/oldorgan = C.getorganslot(slot) //used in removing
		var/obj/item/organ/neworgan = slot_mutantorgans[slot] //used in adding

		if(visual_only && !initial(neworgan.visual))
			continue

		var/used_neworgan = FALSE
		neworgan = SSwardrobe.provide_type(neworgan)
		var/should_have = neworgan.get_availability(src) //organ proc that points back to a species trait (so if the species is supposed to have this organ)

		if(oldorgan && (!should_have || replace_current) && !(oldorgan.zone in excluded_zones) && !(oldorgan.organ_flags & ORGAN_UNREMOVABLE))
			if(slot == ORGAN_SLOT_BRAIN)
				var/obj/item/organ/brain/brain = oldorgan
				if(!brain.decoy_override)//"Just keep it if it's fake" - confucius, probably
					brain.before_organ_replacement(neworgan)
					brain.Remove(C,TRUE, TRUE) //brain argument used so it doesn't cause any... sudden death.
					QDEL_NULL(brain)
					oldorgan = null //now deleted
			else
				oldorgan.before_organ_replacement(neworgan)
				oldorgan.Remove(C,TRUE)
				QDEL_NULL(oldorgan) //we cannot just tab this out because we need to skip the deleting if it is a decoy brain.

		if(oldorgan)
			oldorgan.setOrganDamage(0)
		else if(should_have && !(initial(neworgan.zone) in excluded_zones))
			used_neworgan = TRUE
			neworgan.Insert(C, TRUE, FALSE)

		if(!used_neworgan)
			qdel(neworgan)

	if(old_species)
		for(var/mutantorgan in old_species.mutant_organs)
			// Snowflake check. If our species share this mutant organ, let's not remove it
			// just yet as we'll be properly replacing it later.
			if(mutantorgan in mutant_organs)
				continue
			var/obj/item/organ/I = C.getorgan(mutantorgan)
			if(I)
				I.Remove(C)
				QDEL_NULL(I)

	for(var/organ_path in mutant_organs)
		var/obj/item/organ/current_organ = C.getorgan(organ_path)
		if(!current_organ || replace_current)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			// If there's an existing mutant organ, we're technically replacing it.
			// Let's abuse the snowflake proc that skillchips added. Basically retains
			// feature parity with every other organ too.
			if(current_organ)
				current_organ.before_organ_replacement(replacement)
			// organ.Insert will qdel any current organs in that slot, so we don't need to.
			replacement.Insert(C, TRUE, FALSE)

/**
 * Proc called when a carbon becomes this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_GAIN] signal.
 * Arguments:
 * * C - Carbon, this is whoever became the new species.
 * * old_species - The species that the carbon used to be before becoming this race, used for regenerating organs.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)
	// Drop the items the new species can't wear
	if((AGENDER in species_traits))
		C.gender = PLURAL
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src,thing.species_exception)))
			C.dropItemToGround(thing)
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	fix_non_native_limbs(C)

	// this needs to be FIRST because qdel calls update_body which checks if we have DIGITIGRADE legs or not and if not then removes DIGITIGRADE from species_traits
	if(C.dna.species.mutant_bodyparts["legs"] && C.dna.features["legs"] == "Digitigrade Legs")
		species_traits += DIGITIGRADE
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(FALSE)

	C.mob_biotypes = inherent_biotypes

	regenerate_organs(C, old_species, visual_only = C.visual_only_organs)

	if(exotic_bloodtype && C.dna.blood_type != exotic_bloodtype)
		C.dna.blood_type = exotic_bloodtype

	if(old_species.mutanthands)
		for(var/obj/item/I in C.held_items)
			if(istype(I, old_species.mutanthands))
				qdel(I)

	if(mutanthands)
		// Drop items in hands
		// If you're lucky enough to have a TRAIT_NODROP item, then it stays.
		for(var/V in C.held_items)
			var/obj/item/I = V
			if(istype(I))
				C.dropItemToGround(I)
			else //Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				INVOKE_ASYNC(C, /mob/proc/put_in_hands, new mutanthands)

	if(ishuman(C))
		var/mob/living/carbon/human/human = C
		for(var/obj/item/organ/external/organ_path as anything in external_organs)
			//Load a persons preferences from DNA
			var/feature_key_name = human.dna.features[initial(organ_path.feature_key)]

			var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.set_sprite(feature_key_name)
			new_organ.Insert(human)

	for(var/X in inherent_traits)
		ADD_TRAIT(C, X, SPECIES_TRAIT)

	if(TRAIT_VIRUSIMMUNE in inherent_traits)
		for(var/datum/disease/A in C.diseases)
			A.cure(FALSE)

	if(TRAIT_TOXIMMUNE in inherent_traits)
		C.setToxLoss(0, TRUE, TRUE)

	if(TRAIT_NOMETABOLISM in inherent_traits)
		C.reagents.end_metabolization(C, keep_liverless = TRUE)

	if(TRAIT_GENELESS in inherent_traits)
		C.dna.remove_all_mutations() // Radiation immune mobs can't get mutations normally

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	if(flying_species && isnull(fly))
		fly = new
		fly.Grant(C)

	C.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species, multiplicative_slowdown=speedmod)

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)

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
/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)
	if(C.dna.species.exotic_bloodtype)
		C.dna.blood_type = random_blood_type()
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(TRUE)
	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)
	for(var/obj/item/organ/external/organ in C.internal_organs)
		if(organ.type in external_organs)
			organ.Remove(C)
			qdel(organ)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(C.dna.mutation_index) && (inert_mutation in C.dna.mutation_index))
		C.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = C.dna.mutation_index.Find(inert_mutation)
		C.dna.mutation_index[location] = new_species.inert_mutation
		C.dna.default_mutation_genes[location] = C.dna.mutation_index[location]
		C.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		C.dna.default_mutation_genes[new_species.inert_mutation] = C.dna.mutation_index[new_species.inert_mutation]

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction -= i

	clear_tail_moodlets(C)

	C.remove_movespeed_modifier(/datum/movespeed_modifier/species)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

/**
 * Handles hair icons and dynamic hair.
 *
 * Handles hiding hair with clothing, hair layers, losing hair due to husking or augmented heads, facial hair, head hair, and hair styles.
 * Arguments:
 * * H - Human, whoever we're handling the hair for
 * * forced_colour - The colour of hair we're forcing on this human. Leave null to not change. Mind the british spelling!
 */
/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	var/obj/item/bodypart/head/noggin = H.get_bodypart(BODY_ZONE_HEAD)
	if(!noggin) //Decapitated
		return

	if(HAS_TRAIT(H, TRAIT_HUSK) || HAS_TRAIT(H, TRAIT_INVISIBLE_MAN))
		return
	var/datum/sprite_accessory/S
	var/list/standing = list()

	var/hair_hidden = FALSE //ignored if the matching dynamic_X_suffix is non-empty
	var/facialhair_hidden = FALSE // ^

	var/dynamic_hair_suffix = "" //if this is non-null, and hair+suffix matches an iconstate, then we render that hair instead
	var/dynamic_fhair_suffix = ""

	//for augmented heads
	if(noggin.status == BODYPART_ROBOTIC)
		return

	//we check if our hat or helmet hides our facial hair.
	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix //mask > head in terms of facial hair
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.facial_hairstyle && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hairstyles_list[H.facial_hairstyle]
		if(S)

			//List of all valid dynamic_fhair_suffixes
			var/static/list/fextensions
			if(!fextensions)
				var/icon/fhair_extensions = icon('icons/mob/facialhair_extensions.dmi')
				fextensions = list()
				for(var/s in fhair_extensions.IconStates(1))
					fextensions[s] = TRUE
				qdel(fhair_extensions)

			//Is hair+dynamic_fhair_suffix a valid iconstate?
			var/fhair_state = S.icon_state
			var/fhair_file = S.icon
			if(fextensions[fhair_state+dynamic_fhair_suffix])
				fhair_state += dynamic_fhair_suffix
				fhair_file = 'icons/mob/facialhair_extensions.dmi'

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, -HAIR_LAYER)
			var/mutable_appearance/gradient_overlay

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						facial_overlay.color = H.dna.features["mcolor"]
					else if(hair_color == "fixedmutcolor")
						facial_overlay.color = fixed_mut_color
					else
						facial_overlay.color = hair_color
				else
					facial_overlay.color = H.facial_hair_color
				//Gradients
				var/grad_style = LAZYACCESS(H.grad_style, GRADIENT_FACIAL_HAIR_KEY)
				if(grad_style)
					var/grad_color = LAZYACCESS(H.grad_color, GRADIENT_FACIAL_HAIR_KEY)
					gradient_overlay = make_gradient_overlay(fhair_file, fhair_state, HAIR_LAYER, GLOB.facial_hair_gradients_list[grad_style], grad_color)
			else
				facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha
			facial_overlay.overlays += emissive_blocker(fhair_file, fhair_state, alpha = hair_alpha)

			standing += facial_overlay
			if(gradient_overlay)
				standing += gradient_overlay

	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.w_uniform)
		var/obj/item/item_uniform = H.w_uniform
		if(isclothing(item_uniform))
			var/obj/item/clothing/clothing_object = item_uniform
			dynamic_hair_suffix = clothing_object.dynamic_hair_suffix
		if(item_uniform.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(!hair_hidden || dynamic_hair_suffix)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = -HAIR_LAYER)
		var/mutable_appearance/gradient_overlay
		if(!hair_hidden && !H.getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			if(!(NOBLOOD in species_traits))
				hair_overlay.icon = 'icons/mob/human_face.dmi'
				hair_overlay.icon_state = "debrained"

		else if(H.hairstyle && (HAIR in species_traits))
			S = GLOB.hairstyles_list[H.hairstyle]
			if(S)

				//List of all valid dynamic_hair_suffixes
				var/static/list/extensions
				if(!extensions)
					var/icon/hair_extensions = icon('icons/mob/hair_extensions.dmi') //hehe
					extensions = list()
					for(var/s in hair_extensions.IconStates(1))
						extensions[s] = TRUE
					qdel(hair_extensions)

				//Is hair+dynamic_hair_suffix a valid iconstate?
				var/hair_state = S.icon_state
				var/hair_file = S.icon
				if(extensions[hair_state+dynamic_hair_suffix])
					hair_state += dynamic_hair_suffix
					hair_file = 'icons/mob/hair_extensions.dmi'

				hair_overlay.icon = hair_file
				hair_overlay.icon_state = hair_state

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							hair_overlay.color = H.dna.features["mcolor"]
						else if(hair_color == "fixedmutcolor")
							hair_overlay.color = fixed_mut_color
						else
							hair_overlay.color = hair_color
					else
						hair_overlay.color = H.hair_color

					//Gradients
					var/grad_style = LAZYACCESS(H.grad_style, GRADIENT_HAIR_KEY)
					if(grad_style)
						var/grad_color = LAZYACCESS(H.grad_color, GRADIENT_HAIR_KEY)
						gradient_overlay = make_gradient_overlay(hair_file, hair_state, HAIR_LAYER, GLOB.hair_gradients_list[grad_style], grad_color)
				else
					hair_overlay.color = forced_colour

				hair_overlay.alpha = hair_alpha
				if(OFFSET_FACE in H.dna.species.offset_features)
					hair_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
					hair_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]

		if(hair_overlay.icon)
			hair_overlay.overlays += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, alpha = hair_alpha)
			standing += hair_overlay
			if(gradient_overlay)
				standing += gradient_overlay

	if(standing.len)
		H.overlays_standing[HAIR_LAYER] = standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/proc/make_gradient_overlay(file, icon, layer, datum/sprite_accessory/gradient, grad_color)
	var/mutable_appearance/gradient_overlay = mutable_appearance(layer = -layer)
	var/icon/temp = icon(gradient.icon, gradient.icon_state)
	var/icon/temp_hair = icon(file, icon)
	temp.Blend(temp_hair, ICON_ADD)
	gradient_overlay.icon = temp
	gradient_overlay.color = grad_color
	return gradient_overlay

/**
 * Handles the body of a human
 *
 * Handles lipstick, having no eyes, eye color, undergarnments like underwear, undershirts, and socks, and body layers.
 * Calls [handle_mutant_bodyparts][/datum/species/proc/handle_mutant_bodyparts]
 * Arguments:
 * * species_human - Human, whoever we're handling the body for
 */
/datum/species/proc/handle_body(mob/living/carbon/human/species_human)
	species_human.remove_overlay(BODY_LAYER)
	if(HAS_TRAIT(species_human, TRAIT_INVISIBLE_MAN))
		return handle_mutant_bodyparts(species_human)
	var/list/standing = list()

	var/obj/item/bodypart/head/noggin = species_human.get_bodypart(BODY_ZONE_HEAD)

	if(noggin && !(HAS_TRAIT(species_human, TRAIT_HUSK)))
		// lipstick
		if(species_human.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[species_human.lip_style]", -BODY_LAYER)
			lip_overlay.color = species_human.lip_color
			if(OFFSET_FACE in species_human.dna.species.offset_features)
				lip_overlay.pixel_x += species_human.dna.species.offset_features[OFFSET_FACE][1]
				lip_overlay.pixel_y += species_human.dna.species.offset_features[OFFSET_FACE][2]
			standing += lip_overlay

		// eyes
		if(!(NOEYESPRITES in species_traits))
			var/obj/item/organ/eyes/eye_organ = species_human.getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/no_eyeslay
			var/mutable_appearance/eye_overlay
			var/obscured = species_human.check_obscured_slots(TRUE) //eyes that shine in the dark shouldn't show when you have glasses
			var/add_pixel_x = 0
			var/add_pixel_y = 0
			//cut any possible vis overlays
			if(body_vis_overlays.len)
				SSvis_overlays.remove_vis_overlay(species_human, body_vis_overlays)
			if(OFFSET_FACE in species_human.dna.species.offset_features)
				add_pixel_x = species_human.dna.species.offset_features[OFFSET_FACE][1]
				add_pixel_y = species_human.dna.species.offset_features[OFFSET_FACE][2]
			if(!eye_organ)
				no_eyeslay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
				no_eyeslay.pixel_x += add_pixel_x
				no_eyeslay.pixel_y += add_pixel_y
				standing += no_eyeslay
			if(!no_eyeslay)//we need eyes
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', eye_organ.eye_icon_state, -BODY_LAYER)
				if(eye_organ.overlay_ignore_lighting && !(obscured & ITEM_SLOT_EYES))
					eye_overlay.overlays += emissive_appearance(eye_overlay.icon, eye_overlay.icon_state, alpha = eye_overlay.alpha)

				eye_overlay.pixel_x += add_pixel_x
				eye_overlay.pixel_y += add_pixel_y
				if((EYECOLOR in species_traits) && eye_organ)
					eye_overlay.color = species_human.eye_color
				standing += eye_overlay

	// organic body markings
	if(HAS_MARKINGS in species_traits)
		var/obj/item/bodypart/chest/chest = species_human.get_bodypart(BODY_ZONE_CHEST)
		var/obj/item/bodypart/r_arm/right_arm = species_human.get_bodypart(BODY_ZONE_R_ARM)
		var/obj/item/bodypart/l_arm/left_arm = species_human.get_bodypart(BODY_ZONE_L_ARM)
		var/obj/item/bodypart/r_leg/right_leg = species_human.get_bodypart(BODY_ZONE_R_LEG)
		var/obj/item/bodypart/l_leg/left_leg = species_human.get_bodypart(BODY_ZONE_L_LEG)
		var/datum/sprite_accessory/markings = GLOB.moth_markings_list[species_human.dna.features["moth_markings"]]

		if(!HAS_TRAIT(species_human, TRAIT_HUSK))
			if(noggin && (noggin.status != BODYPART_ROBOTIC))
				var/mutable_appearance/markings_head_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_head", -BODY_LAYER)
				standing += markings_head_overlay

			if(chest && (chest.status != BODYPART_ROBOTIC))
				var/mutable_appearance/markings_chest_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_chest", -BODY_LAYER)
				standing += markings_chest_overlay

			if(right_arm && (right_arm.status != BODYPART_ROBOTIC))
				var/mutable_appearance/markings_r_arm_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_r_arm", -BODY_LAYER)
				standing += markings_r_arm_overlay

			if(left_arm && (left_arm.status != BODYPART_ROBOTIC))
				var/mutable_appearance/markings_l_arm_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_l_arm", -BODY_LAYER)
				standing += markings_l_arm_overlay

			if(right_leg && (right_leg.status != BODYPART_ROBOTIC))
				var/mutable_appearance/markings_r_leg_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_r_leg", -BODY_LAYER)
				standing += markings_r_leg_overlay

			if(left_leg && (left_leg.status != BODYPART_ROBOTIC))
				var/mutable_appearance/markings_l_leg_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_l_leg", -BODY_LAYER)
				standing += markings_l_leg_overlay

	//Underwear, Undershirts & Socks
	if(!(NO_UNDERWEAR in species_traits))
		if(species_human.underwear)
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[species_human.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				if(species_human.dna.species.sexes && species_human.body_type == FEMALE && (underwear.gender == MALE))
					underwear_overlay = wear_female_version(underwear.icon_state, underwear.icon, BODY_LAYER, FEMALE_UNIFORM_FULL)
				else
					underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)
				if(!underwear.use_static)
					underwear_overlay.color = species_human.underwear_color
				standing += underwear_overlay

		if(species_human.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[species_human.undershirt]
			if(undershirt)
				if(species_human.dna.species.sexes && species_human.body_type == FEMALE)
					standing += wear_female_version(undershirt.icon_state, undershirt.icon, BODY_LAYER)
				else
					standing += mutable_appearance(undershirt.icon, undershirt.icon_state, -BODY_LAYER)

		if(species_human.socks && species_human.num_legs >= 2 && !(DIGITIGRADE in species_traits))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[species_human.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)

	if(standing.len)
		species_human.overlays_standing[BODY_LAYER] = standing

	species_human.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(species_human)

/**
 * Handles the mutant bodyparts of a human
 *
 * Handles the adding and displaying of, layers, colors, and overlays of mutant bodyparts and accessories.
 * Handles digitigrade leg displaying and squishing.
 * Arguments:
 * * H - Human, whoever we're handling the body for
 * * forced_colour - The forced color of an accessory. Leave null to use mutant color.
 */
/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/source, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing = list()

	source.remove_overlay(BODY_BEHIND_LAYER)
	source.remove_overlay(BODY_ADJ_LAYER)
	source.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts || HAS_TRAIT(source, TRAIT_INVISIBLE_MAN))
		return

	var/obj/item/bodypart/head/noggin = source.get_bodypart(BODY_ZONE_HEAD)

	if(mutant_bodyparts["tail_lizard"])
		if(source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_lizard"

	if(mutant_bodyparts["waggingtail_lizard"])
		if(source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_lizard"
		else if (mutant_bodyparts["tail_lizard"])
			bodyparts_to_add -= "waggingtail_lizard"

	if(mutant_bodyparts["tail_human"])
		if(source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_human"

	if("tail_monkey" in mutant_bodyparts)
		if(source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_monkey"

	if(mutant_bodyparts["waggingtail_human"])
		if(source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_human"
		else if (mutant_bodyparts["tail_human"])
			bodyparts_to_add -= "waggingtail_human"

	if(mutant_bodyparts["spines"])
		if(!source.dna.features["spines"] || source.dna.features["spines"] == "None" || source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "spines"

	if(mutant_bodyparts["waggingspines"])
		if(!source.dna.features["spines"] || source.dna.features["spines"] == "None" || source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingspines"
		else if (mutant_bodyparts["tail"])
			bodyparts_to_add -= "waggingspines"

	if(mutant_bodyparts["ears"])
		if(!source.dna.features["ears"] || source.dna.features["ears"] == "None" || source.head && (source.head.flags_inv & HIDEHAIR) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEHAIR)) || !noggin || noggin.status == BODYPART_ROBOTIC)
			bodyparts_to_add -= "ears"

	//Digitigrade legs are stuck in the phantom zone between true limbs and mutant bodyparts. Mainly it just needs more aggressive updating than most limbs.
	var/update_needed = FALSE
	var/not_digitigrade = TRUE
	for(var/obj/item/bodypart/bodypart as anything in source.bodyparts)
		if(!bodypart.use_digitigrade)
			continue
		not_digitigrade = FALSE
		if(!(DIGITIGRADE in species_traits)) //Someone cut off a digitigrade leg and tacked it on
			species_traits += DIGITIGRADE
		var/should_be_squished = FALSE
		if(source.wear_suit && ((source.wear_suit.flags_inv & HIDEJUMPSUIT) || (source.wear_suit.body_parts_covered & LEGS)) || (source.w_uniform && (source.w_uniform.body_parts_covered & LEGS)))
			should_be_squished = TRUE
		if(bodypart.use_digitigrade == FULL_DIGITIGRADE && should_be_squished)
			bodypart.use_digitigrade = SQUISHED_DIGITIGRADE
			update_needed = TRUE
		else if(bodypart.use_digitigrade == SQUISHED_DIGITIGRADE && !should_be_squished)
			bodypart.use_digitigrade = FULL_DIGITIGRADE
			update_needed = TRUE
	if(update_needed)
		source.update_body_parts()
	if(not_digitigrade && (DIGITIGRADE in species_traits)) //Curse is lifted
		species_traits -= DIGITIGRADE

	if(!bodyparts_to_add)
		return

	var/g = (source.body_type == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/accessory
			switch(bodypart)
				if("tail_lizard")
					accessory = GLOB.tails_list_lizard[source.dna.features["tail_lizard"]]
				if("waggingtail_lizard")
					accessory = GLOB.animated_tails_list_lizard[source.dna.features["tail_lizard"]]
				if("tail_human")
					accessory = GLOB.tails_list_human[source.dna.features["tail_human"]]
				if("waggingtail_human")
					accessory = GLOB.animated_tails_list_human[source.dna.features["tail_human"]]
				if("spines")
					accessory = GLOB.spines_list[source.dna.features["spines"]]
				if("waggingspines")
					accessory = GLOB.animated_spines_list[source.dna.features["spines"]]
				if("ears")
					accessory = GLOB.ears_list[source.dna.features["ears"]]
				if("body_markings")
					accessory = GLOB.body_markings_list[source.dna.features["body_markings"]]
				if("legs")
					accessory = GLOB.legs_list[source.dna.features["legs"]]
				if("caps")
					accessory = GLOB.caps_list[source.dna.features["caps"]]
				if("tail_monkey")
					accessory = GLOB.tails_list_monkey[source.dna.features["tail_monkey"]]
			if(!accessory || accessory.icon_state == "none")
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(accessory.icon, layer = -layer)

			//A little rename so we don't have to use tail_lizard or tail_human when naming the sprites.
			if(bodypart == "tail_lizard" || bodypart == "tail_human" || bodypart == "tail_monkey")
				bodypart = "tail"
			else if(bodypart == "waggingtail_lizard" || bodypart == "waggingtail_human")
				bodypart = "waggingtail"

			if(accessory.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[accessory.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[accessory.icon_state]_[layertext]"

			if(accessory.em_block)
				accessory_overlay.overlays += emissive_blocker(accessory_overlay.icon, accessory_overlay.icon_state, accessory_overlay.alpha)

			if(accessory.center)
				accessory_overlay = center_image(accessory_overlay, accessory.dimension_x, accessory.dimension_y)

			if(!(HAS_TRAIT(source, TRAIT_HUSK)))
				if(!forced_colour)
					switch(accessory.color_src)
						if(MUTCOLORS)
							if(fixed_mut_color)
								accessory_overlay.color = fixed_mut_color
							else
								accessory_overlay.color = source.dna.features["mcolor"]
						if(HAIR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = source.dna.features["mcolor"]
							else if(hair_color == "fixedmutcolor")
								accessory_overlay.color = fixed_mut_color
							else
								accessory_overlay.color = source.hair_color
						if(FACEHAIR)
							accessory_overlay.color = source.facial_hair_color
						if(EYECOLOR)
							accessory_overlay.color = source.eye_color
				else
					accessory_overlay.color = forced_colour
			standing += accessory_overlay

			if(accessory.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(accessory.icon, layer = -layer)
				if(accessory.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[bodypart]inner_[accessory.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[bodypart]inner_[accessory.icon_state]_[layertext]"

				if(accessory.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, accessory.dimension_x, accessory.dimension_y)

				standing += inner_accessory_overlay

		source.overlays_standing[layer] = standing.Copy()
		standing = list()

	source.apply_overlay(BODY_BEHIND_LAYER)
	source.apply_overlay(BODY_ADJ_LAYER)
	source.apply_overlay(BODY_FRONT_LAYER)

//This exists so sprite accessories can still be per-layer without having to include that layer's
//number in their sprite name, which causes issues when those numbers change.
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
	human_mob.hairstyle = random_hairstyle(human_mob.gender)
	human_mob.update_hair()

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob
/datum/species/proc/randomize_active_underwear(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)
	human_mob.update_body()

/datum/species/proc/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		H.setOxyLoss(0)
		H.losebreath = 0

		var/takes_crit_damage = (!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		if((H.health < H.crit_threshold) && takes_crit_damage && H.stat != DEAD)
			H.adjustBruteLoss(0.5 * delta_time)

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/H)
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	// if there's an item in the slot we want, fail
	if(H.get_item_by_slot(slot))
		return FALSE

	// this check prevents us from equipping something to a slot it doesn't support, WITH the exceptions of storage slots (pockets, suit storage, and backpacks)
	// we don't require having those slots defined in the item's slot_flags, so we'll rely on their own checks further down
	if(!(I.slot_flags & slot))
		var/excused = FALSE
		// Anything that's small or smaller can fit into a pocket by default
		if((slot == ITEM_SLOT_RPOCKET || slot == ITEM_SLOT_LPOCKET) && I.atom_size <= ITEM_SIZE_SMALL)
			excused = TRUE
		else if(slot == ITEM_SLOT_SUITSTORE || slot == ITEM_SLOT_BACKPACK || slot == ITEM_SLOT_HANDS)
			excused = TRUE
		if(!excused)
			return FALSE

	switch(slot)
		if(ITEM_SLOT_HANDS)
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
			if(H.num_hands < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(H.num_legs < 2)
				return FALSE
			if((DIGITIGRADE in species_traits) && !(I.item_flags & IGNORE_DIGITIGRADE))
				if(!disable_warning)
					to_chat(H, span_warning("The footwear around here isn't compatible with your feet!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
			if(E?.no_glasses)
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
			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(H.l_store) // no pocket swaps at all
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.r_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || O.status != BODYPART_ROBOTIC))
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
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, span_warning("You somehow have a suit with no defined allowed items for suit storage, stop that."))
				return FALSE
			if(I.atom_size > ITEM_SIZE_BULKY)
				if(!disable_warning)
					to_chat(H, span_warning("The [I.name] is too big to attach!")) //should be src?
				return FALSE
			if( istype(I, /obj/item/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed) )
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
		if(ITEM_SLOT_BACKPACK)
			if(H.back && SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
				return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message(span_notice("[H] start putting on [I]..."), span_notice("You start putting on [I]..."))
	return do_after(H, I.equip_delay_self, target = H)


/// Equips the necessary species-relevant gear before putting on the rest of the uniform.
/datum/species/proc/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return


/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == exotic_blood)
		H.blood_volume = min(H.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
		H.reagents.del_reagent(chem.type)
		return TRUE
	if(!chem.overdosed && chem.overdose_threshold && chem.volume >= chem.overdose_threshold)
		chem.overdosed = TRUE
		chem.overdose_start(H)
		log_game("[key_name(H)] has started overdosing on [chem.name] at [chem.volume] units.")

/datum/species/proc/check_species_weakness(obj/item, mob/living/attacker)
	return 1 //This is not a boolean, it's the multiplier for the damage that the user takes from the item. The force of the item is multiplied by this value

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	outfit_important_for_life= new()
	outfit_important_for_life.equip(human_to_equip)

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return FALSE

/**
 * Species based handling for irradiation
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The mob requesting handling
 * - time_since_irradiated: The amount of time since the mob was first irradiated
 * - delta_time: The amount of time that has passed since the last tick
 */
/datum/species/proc/handle_radiation(mob/living/carbon/human/source, time_since_irradiated, delta_time)
	if(time_since_irradiated > RAD_MOB_KNOCKDOWN && DT_PROB(RAD_MOB_KNOCKDOWN_PROB, delta_time))
		if(!source.IsParalyzed())
			source.emote("collapse")
		source.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(source, span_danger("You feel weak."))

	if(time_since_irradiated > RAD_MOB_VOMIT && DT_PROB(RAD_MOB_VOMIT_PROB, delta_time))
		source.vomit(10, TRUE)

	if(time_since_irradiated > RAD_MOB_MUTATE && DT_PROB(RAD_MOB_MUTATE_PROB, delta_time))
		to_chat(source, span_danger("You mutate!"))
		source.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
		source.emote("gasp")
		source.domutcheck()

	if(time_since_irradiated > RAD_MOB_HAIRLOSS && DT_PROB(RAD_MOB_HAIRLOSS_PROB, delta_time))
		if(!(source.hairstyle == "Bald") && (HAIR in species_traits))
			to_chat(source, span_danger("Your hair starts to fall out in clumps..."))
			addtimer(CALLBACK(src, .proc/go_bald, source), 5 SECONDS)

/**
 * Makes the target human bald.
 *
 * Arguments:
 * - [target][/mob/living/carbon/human]: The mob to make go bald.
 */
/datum/species/proc/go_bald(mob/living/carbon/human/target)
	if(QDELETED(target)) //may be called from a timer
		return
	target.facial_hairstyle = "Shaved"
	target.hairstyle = "Bald"
	target.update_hair()

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_updatehealth(mob/living/carbon/human/H)
	return

/datum/species/proc/spec_fully_heal(mob/living/carbon/human/H)
	return


/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.body_position == STANDING_UP || (target.health >= 0 && !HAS_TRAIT(target, TRAIT_FAKEDEATH)))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return TRUE

	user.do_cpr(target)


/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s grab!"), \
						span_userdanger("You block [user]'s grab!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your grab at [target] was blocked!"))
		return FALSE
	if(attacker_style?.grab_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	else
		target.grabbedby(user)
		return TRUE

///This proc handles punching damage. IMPORTANT: Our owner is the TARGET and not the USER in this proc. For whatever reason...
/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s attack!"), \
						span_userdanger("You block [user]'s attack!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your attack at [target] was blocked!"))
		return FALSE
	if(attacker_style?.harm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	else

		var/atk_verb = user.dna.species.attack_verb
		var/atk_effect = user.dna.species.attack_effect
		if(target.body_position == LYING_DOWN)
			atk_verb = "kick"
			atk_effect = ATTACK_EFFECT_KICK

		if(atk_effect == ATTACK_EFFECT_BITE)
			if(user.is_mouth_covered(mask_only = TRUE))
				to_chat(user, span_warning("You can't [atk_verb] with your mouth covered!"))
				return FALSE
		user.do_attack_animation(target, atk_effect)

		var/damage = rand(user.dna.species.punchdamagelow, user.dna.species.punchdamagehigh)

		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))

		var/miss_chance = 100//calculate the odds that a punch misses entirely. considers stamina and brute damage of the puncher. punches miss by default to prevent weird cases
		if(user.dna.species.punchdamagelow)
			if(atk_effect == ATTACK_EFFECT_KICK || HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER)) //kicks never miss (provided your species deals more than 0 damage)
				miss_chance = 0
			else
				miss_chance = min((user.dna.species.punchdamagehigh/user.dna.species.punchdamagelow) + user.getStaminaLoss() + (user.getBruteLoss()*0.5), 100) //old base chance for a miss + various damage. capped at 100 to prevent weirdness in prob()

		if(!damage || !affecting || prob(miss_chance))//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, user.dna.species.miss_sound, 25, TRUE, -1)
			target.visible_message(span_danger("[user]'s [atk_verb] misses [target]!"), \
							span_danger("You avoid [user]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] misses [target]!"))
			log_combat(user, target, "attempted to punch")
			return FALSE

		var/armor_block = target.run_armor_check(affecting, MELEE)

		playsound(target.loc, user.dna.species.attack_sound, 25, TRUE, -1)

		target.visible_message(span_danger("[user] [atk_verb]ed [target]!"), \
						span_userdanger("You're [atk_verb]ed by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [atk_verb] [target]!"))

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		user.dna.species.spec_unarmedattacked(user, target)

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		if(atk_effect == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage
			target.apply_damage(damage*1.5, user.dna.species.attack_type, affecting, armor_block)
			log_combat(user, target, "kicked")
		else//other attacks deal full raw damage + 1.5x in stamina damage
			target.apply_damage(damage, user.dna.species.attack_type, affecting, armor_block)
			target.apply_damage(damage*1.5, STAMINA, affecting, armor_block)
			log_combat(user, target, "punched")

		if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
			target.visible_message(span_danger("[user] knocks [target] down!"), \
							span_userdanger("You're knocked down by [user]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You knock [target] down!"))
			var/knockdown_duration = 40 + (target.getStaminaLoss() + (target.getBruteLoss()*0.5))*0.8 //50 total damage = 40 base stun + 40 stun modifier = 80 stun duration, which is the old base duration
			target.apply_effect(knockdown_duration, EFFECT_KNOCKDOWN, armor_block)
			log_combat(user, target, "got a stun punch with their previous punch")

/datum/species/proc/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[user]'s shove is blocked by [target]!"), \
						span_danger("You block [user]'s shove!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your shove at [target] was blocked!"))
		return FALSE
	if(attacker_style?.disarm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	if(user.body_position != STANDING_UP)
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	user.disarm(target)


/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	return

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style, modifiers)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return
	if(M.mind)
		attacker_style = M.mind.martial_art
	if((M != H) && M.combat_mode && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		log_combat(M, H, "attempted to touch")
		H.visible_message(span_warning("[M] attempts to touch [H]!"), \
						span_danger("[M] attempts to touch you!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, M)
		to_chat(M, span_warning("You attempt to touch [H]!"))
		return

	SEND_SIGNAL(M, COMSIG_MOB_ATTACK_HAND, M, H, attacker_style)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		disarm(M, H, attacker_style)
		return // dont attack after
	if(M.combat_mode)
		harm(M, H, attacker_style)
	else
		help(M, H, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	// Allows you to put in item-specific reactions based on species
	if(user != H)
		if(H.check_shields(I, I.force, "the [I.name]", MELEE_ATTACK, I.armour_penetration))
			return FALSE
	if(H.check_block())
		H.visible_message(span_warning("[H] blocks [I]!"), \
						span_userdanger("You block [I]!"))
		return FALSE

	var/hit_area
	if(!affecting) //Something went wrong. Maybe the limb is missing?
		affecting = H.bodyparts[1]

	hit_area = affecting.name
	var/def_zone = affecting.body_zone

	var/armor_block = H.run_armor_check(affecting, MELEE, span_notice("Your armor has protected your [hit_area]!"), span_warning("Your armor has softened a hit to your [hit_area]!"),I.armour_penetration, weak_against_armour = I.weak_against_armour)
	armor_block = min(90,armor_block) //cap damage reduction at 90%
	var/Iwound_bonus = I.wound_bonus

	// this way, you can't wound with a surgical tool on help intent if they have a surgery active and are lying down, so a misclick with a circular saw on the wrong limb doesn't bleed them dry (they still get hit tho)
	if((I.item_flags & SURGICAL_TOOL) && !user.combat_mode && H.body_position == LYING_DOWN && (LAZYLEN(H.surgeries) > 0))
		Iwound_bonus = CANT_WOUND

	var/weakness = check_species_weakness(I, user)

	H.send_item_attack_message(I, user, hit_area, affecting)

	apply_damage(I.force * weakness, I.damtype, def_zone, armor_block, H, wound_bonus = Iwound_bonus, bare_wound_bonus = I.bare_wound_bonus, sharpness = I.get_sharpness())

	if(!I.force)
		return FALSE //item force is zero

	var/bloody = FALSE
	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.status == BODYPART_ORGANIC)
			I.add_mob_blood(H) //Make the weapon bloody, not the person.
			if(prob(I.force * 2)) //blood spatter!
				bloody = TRUE
				var/turf/location = H.loc
				if(istype(location))
					H.add_splatter_floor(location)
				if(get_dist(user, H) <= 1) //people with TK won't get smeared with blood
					user.add_mob_blood(H)

		switch(hit_area)
			if(BODY_ZONE_HEAD)
				if(!I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
						if(H.stat == CONSCIOUS)
							H.visible_message(span_danger("[H] is knocked senseless!"), \
											span_userdanger("You're knocked senseless!"))
							H.set_confusion(max(H.get_confusion(), 20))
							H.adjust_blurriness(10)
						if(prob(10))
							H.gain_trauma(/datum/brain_trauma/mild/concussion)
					else
						H.adjustOrganLoss(ORGAN_SLOT_BRAIN, I.force * 0.2)

					if(H.mind && H.stat == CONSCIOUS && H != user && prob(I.force + ((100 - H.health) * 0.5))) // rev deconversion through blunt trauma.
						var/datum/antagonist/rev/rev = H.mind.has_antag_datum(/datum/antagonist/rev)
						if(rev)
							rev.remove_revolutionary(FALSE, user)

				if(bloody) //Apply blood
					if(H.wear_mask)
						H.wear_mask.add_mob_blood(H)
						H.update_inv_wear_mask()
					if(H.head)
						H.head.add_mob_blood(H)
						H.update_inv_head()
					if(H.glasses && prob(33))
						H.glasses.add_mob_blood(H)
						H.update_inv_glasses()

			if(BODY_ZONE_CHEST)
				if(H.stat == CONSCIOUS && !I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						H.visible_message(span_danger("[H] is knocked down!"), \
									span_userdanger("You're knocked down!"))
						H.apply_effect(60, EFFECT_KNOCKDOWN, armor_block)

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_mob_blood(H)
						H.update_inv_wear_suit()
					if(H.w_uniform)
						H.w_uniform.add_mob_blood(H)
						H.update_inv_w_uniform()

	return TRUE

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE, spread_damage = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE)
	SEND_SIGNAL(H, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone, wound_bonus, bare_wound_bonus, sharpness) // make sure putting wound_bonus here doesn't screw up other signals or uses for this signal
	var/hit_percent = (100-(blocked+armor))/100
	hit_percent = (hit_percent * (100-H.physiology.damage_resistance))/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone))
			BP = def_zone
		else
			if(!def_zone)
				def_zone = ran_zone(def_zone)
			BP = H.get_bodypart(check_zone(def_zone))
			if(!BP)
				BP = H.bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * brutemod * H.physiology.brute_mod
			if(BP)
				if(BP.receive_damage(damage_amount, 0, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness))
					H.update_damage_overlays()
			else//no bodypart, we deal damage with a more general method.
				H.adjustBruteLoss(damage_amount)
		if(BURN)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * burnmod * H.physiology.burn_mod
			if(BP)
				if(BP.receive_damage(0, damage_amount, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness))
					H.update_damage_overlays()
			else
				H.adjustFireLoss(damage_amount)
		if(TOX)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.tox_mod
			H.adjustToxLoss(damage_amount)
		if(OXY)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.oxy_mod
			H.adjustOxyLoss(damage_amount)
		if(CLONE)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.clone_mod
			H.adjustCloneLoss(damage_amount)
		if(STAMINA)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.stamina_mod
			if(BP)
				if(BP.receive_damage(0, 0, damage_amount))
					H.update_stamina()
			else
				H.adjustStaminaLoss(damage_amount)
		if(BRAIN)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.brain_mod
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)
	return 1

/datum/species/proc/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(P.type)
		if(/obj/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))
		if(/obj/projectile/energy/florayield)
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))
		if(/obj/projectile/energy/florarevolution)
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))

/datum/species/proc/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	// called before a projectile hit
	return 0

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
/datum/species/proc/handle_environment(mob/living/carbon/human/humi, datum/gas_mixture/environment, delta_time, times_fired)
	handle_environment_pressure(humi, environment, delta_time, times_fired)

/**
 * Body temperature handler for species
 *
 * These procs manage body temp, bamage, and alerts
 * Some of these will still fire when not alive to balance body temp to the room temp.
 * vars:
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_body_temperature(mob/living/carbon/human/humi, delta_time, times_fired)
	//when in a cryo unit we suspend all natural body regulation
	if(istype(humi.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	//Only stabilise core temp when alive and not in statis
	if(humi.stat < DEAD && !IS_IN_STASIS(humi))
		body_temperature_core(humi, delta_time, times_fired)

	//These do run in statis
	body_temperature_skin(humi, delta_time, times_fired)
	body_temperature_alerts(humi, delta_time, times_fired)

	//Do not cause more damage in statis
	if(!IS_IN_STASIS(humi))
		body_temperature_damage(humi, delta_time, times_fired)

/**
 * Used to stabilize the core temperature back to normal on living mobs
 *
 * The metabolisim heats up the core of the mob trying to keep it at the normal body temp
 * vars:
 * * humi (required) The mob we will stabilize
 */
/datum/species/proc/body_temperature_core(mob/living/carbon/human/humi, delta_time, times_fired)
	var/natural_change = get_temp_change_amount(humi.get_body_temp_normal() - humi.coretemperature, 0.06 * delta_time)
	humi.adjust_coretemperature(humi.metabolism_efficiency * natural_change)

/**
 * Used to normalize the skin temperature on living mobs
 *
 * The core temp effects the skin, then the enviroment effects the skin, then we refect that back to the core.
 * This happens even when dead so bodies revert to room temp over time.
 * vars:
 * * humi (required) The mob we will targeting
 * - delta_time: The amount of time that is considered as elapsing
 * - times_fired: The number of times SSmobs has fired
 */
/datum/species/proc/body_temperature_skin(mob/living/carbon/human/humi, delta_time, times_fired)

	// change the core based on the skin temp
	var/skin_core_diff = humi.bodytemperature - humi.coretemperature
	// change rate of 0.04 per second to be slightly below area to skin change rate and still have a solid curve
	var/skin_core_change = get_temp_change_amount(skin_core_diff, 0.04 * delta_time)

	humi.adjust_coretemperature(skin_core_change)

	// get the enviroment details of where the mob is standing
	var/datum/gas_mixture/environment = humi.loc.return_air()
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
		var/area_skin_change = get_temp_change_amount(area_skin_diff, 0.05 * delta_time)

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
		var/core_skin_change = (1 + thermal_protection) * get_temp_change_amount(core_skin_diff, 0.045 * delta_time)

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
	// Body temperature is too hot, and we do not have resist traits
	if(humi.bodytemperature > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		// Clear cold mood and apply hot mood
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(humi, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		//Remove any slowdown from the cold.
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		// display alerts based on how hot it is
		switch(humi.bodytemperature)
			if(bodytemp_heat_damage_limit to BODYTEMP_HEAT_WARNING_2)
				humi.throw_alert("temp", /atom/movable/screen/alert/hot, 1)
			if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
				humi.throw_alert("temp", /atom/movable/screen/alert/hot, 2)
			else
				humi.throw_alert("temp", /atom/movable/screen/alert/hot, 3)

	// Body temperature is too cold, and we do not have resist traits
	else if(humi.bodytemperature < bodytemp_cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		// clear any hot moods and apply cold mood
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(humi, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		// Apply cold slow down
		humi.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((bodytemp_cold_damage_limit - humi.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		// Display alerts based how cold it is
		switch(humi.bodytemperature)
			if(BODYTEMP_COLD_WARNING_2 to bodytemp_cold_damage_limit)
				humi.throw_alert("temp", /atom/movable/screen/alert/cold, 1)
			if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
				humi.throw_alert("temp", /atom/movable/screen/alert/cold, 2)
			else
				humi.throw_alert("temp", /atom/movable/screen/alert/cold, 3)

	// We are not to hot or cold, remove status and moods
	else
		humi.clear_alert("temp")
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "hot")

/**
 * Used to apply wounds and damage based on core/body temp
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_damage(mob/living/carbon/human/humi, delta_time, times_fired)

	//If the body temp is above the wound limit start adding exposure stacks
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT)
		humi.heat_exposure_stacks = min(humi.heat_exposure_stacks + (0.5 * delta_time), 40)
	else //When below the wound limit, reduce the exposure stacks fast.
		humi.heat_exposure_stacks = max(humi.heat_exposure_stacks - (2 * delta_time), 0)

	//when exposure stacks are greater then 10 + rand20 try to apply wounds and reset stacks
	if(humi.heat_exposure_stacks > (10 + rand(0, 20)))
		apply_burn_wounds(humi, delta_time, times_fired)
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
		burn_damage = burn_damage * heatmod * humi.physiology.heat_mod * 0.5 * delta_time

		// 40% for level 3 damage on humans to scream in pain
		if (humi.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4)
			humi.emote("scream")

		// Apply the damage to all body parts
		humi.apply_damage(burn_damage, BURN, spread_damage = TRUE)

	// Apply some burn / brute damage to the body (Dependent if the person is hulk or not)
	var/is_hulk = HAS_TRAIT(humi, TRAIT_HULK)

	var/cold_damage_limit = bodytemp_cold_damage_limit + (is_hulk ? BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER : 0)

	if(humi.coretemperature < cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		var/damage_type = is_hulk ? BRUTE : BURN // Why?
		var/damage_mod = coldmod * humi.physiology.cold_mod * (is_hulk ? HULK_COLD_DAMAGE_MOD : 1)
		switch(humi.coretemperature)
			if(201 to cold_damage_limit)
				humi.apply_damage(COLD_DAMAGE_LEVEL_1 * damage_mod * delta_time, damage_type)
			if(120 to 200)
				humi.apply_damage(COLD_DAMAGE_LEVEL_2 * damage_mod * delta_time, damage_type)
			else
				humi.apply_damage(COLD_DAMAGE_LEVEL_3 * damage_mod * delta_time, damage_type)

/**
 * Used to apply burn wounds on random limbs
 *
 * This is called from body_temperature_damage when exposure to extream heat adds up and causes a wound.
 * The wounds will increase in severity as the temperature increases.
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/apply_burn_wounds(mob/living/carbon/human/humi, delta_time, times_fired)
	// If we are resistant to heat exit
	if(HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		return

	// If our body temp is to low for a wound exit
	if(humi.bodytemperature < BODYTEMP_HEAT_WOUND_LIMIT)
		return

	// Lets pick a random body part and check for an existing burn
	var/obj/item/bodypart/bodypart = pick(humi.bodyparts)
	var/datum/wound/burn/existing_burn = locate(/datum/wound/burn) in bodypart.wounds

	// If we have an existing burn try to upgrade it
	if(existing_burn)
		switch(existing_burn.severity)
			if(WOUND_SEVERITY_MODERATE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400) // 800k
					bodypart.force_wound_upwards(/datum/wound/burn/severe)
			if(WOUND_SEVERITY_SEVERE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800) // 3200k
					bodypart.force_wound_upwards(/datum/wound/burn/critical)
	else // If we have no burn apply the lowest level burn
		bodypart.force_wound_upwards(/datum/wound/burn/moderate)

	// always take some burn damage
	var/burn_damage = HEAT_DAMAGE_LEVEL_1
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400)
		burn_damage = HEAT_DAMAGE_LEVEL_2
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800)
		burn_damage = HEAT_DAMAGE_LEVEL_3

	humi.apply_damage(burn_damage * delta_time, BURN, bodypart)

/// Handle the air pressure of the environment
/datum/species/proc/handle_environment_pressure(mob/living/carbon/human/H, datum/gas_mixture/environment, delta_time, times_fired)
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure)

	// Set alerts and apply damage based on the amount of pressure
	switch(adjusted_pressure)
		// Very high pressure, show an alert and take damage
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.adjustBruteLoss(min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod * delta_time)
				H.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)
			else
				H.clear_alert("pressure")

		// High pressure, show an alert
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 1)

		// No pressure issues here clear pressure alerts
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert("pressure")

		// Low pressure here, show an alert
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert("pressure")
			else
				H.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 1)

		// Very low pressure, show an alert and take damage
		else
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert("pressure")
			else
				H.adjustBruteLoss(LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod * delta_time)
				H.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)


//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, delta_time, times_fired, no_protection = FALSE)
	if(!CanIgniteMob(H))
		return TRUE
	if(H.on_fire)
		SEND_SIGNAL(H, COMSIG_HUMAN_BURNING)
		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		var/obscured = H.check_obscured_slots(TRUE)
		//HEAD//

		if(H.glasses && !(obscured & ITEM_SLOT_EYES))
			burning_items += H.glasses
		if(H.wear_mask && !(obscured & ITEM_SLOT_MASK))
			burning_items += H.wear_mask
		if(H.wear_neck && !(obscured & ITEM_SLOT_NECK))
			burning_items += H.wear_neck
		if(H.ears && !(obscured & ITEM_SLOT_EARS))
			burning_items += H.ears
		if(H.head)
			burning_items += H.head

		//CHEST//
		if(H.w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
			burning_items += H.w_uniform
		if(H.wear_suit)
			burning_items += H.wear_suit

		//ARMS & HANDS//
		var/obj/item/clothing/arm_clothes = null
		if(H.gloves && !(obscured & ITEM_SLOT_GLOVES))
			arm_clothes = H.gloves
		else if(H.wear_suit && ((H.wear_suit.body_parts_covered & HANDS) || (H.wear_suit.body_parts_covered & ARMS)))
			arm_clothes = H.wear_suit
		else if(H.w_uniform && ((H.w_uniform.body_parts_covered & HANDS) || (H.w_uniform.body_parts_covered & ARMS)))
			arm_clothes = H.w_uniform
		if(arm_clothes)
			burning_items |= arm_clothes

		//LEGS & FEET//
		var/obj/item/clothing/leg_clothes = null
		if(H.shoes && !(obscured & ITEM_SLOT_FEET))
			leg_clothes = H.shoes
		else if(H.wear_suit && ((H.wear_suit.body_parts_covered & FEET) || (H.wear_suit.body_parts_covered & LEGS)))
			leg_clothes = H.wear_suit
		else if(H.w_uniform && ((H.w_uniform.body_parts_covered & FEET) || (H.w_uniform.body_parts_covered & LEGS)))
			leg_clothes = H.w_uniform
		if(leg_clothes)
			burning_items |= leg_clothes

		for(var/X in burning_items)
			var/obj/item/I = X
			I.fire_act((H.fire_stacks * 50)) //damage taken is reduced to 2% of this value by fire_act()

		var/thermal_protection = H.get_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
			H.adjust_bodytemperature(5.5 * delta_time)
		else
			H.adjust_bodytemperature((BODYTEMP_HEATING_MAX + (H.fire_stacks * 12)) * 0.5 * delta_time)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)
			H.mind?.add_memory(MEMORY_FIRE, list(DETAIL_PROTAGONIST = H), story_value = STORY_VALUE_OKAY)

/datum/species/proc/CanIgniteMob(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return FALSE
	return TRUE

/datum/species/proc/extinguish_mob(mob/living/carbon/human/H)
	return


////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	if(H.movement_type & FLYING)
		var/obj/item/organ/external/wings/functional/wings = H.getorganslot(ORGAN_SLOT_EXTERNAL_WINGS)
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

/datum/species/proc/can_wag_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/is_wagging_tail(mob/living/carbon/human/H)
	return FALSE

/*
 * This proc is called when a mob loses their tail.
 *
 * tail_owner - the owner of the tail (who holds our species datum)
 * lost_tail - the tail that was removed
 * on_species_init - whether or not this was called when the species was initialized, or if it was called due to an ingame means (like surgery)
 */
/datum/species/proc/on_tail_lost(mob/living/carbon/human/tail_owner, obj/item/organ/tail/lost_tail, on_species_init = FALSE)
	SEND_SIGNAL(tail_owner, COMSIG_CLEAR_MOOD_EVENT, "right_tail_regained")
	SEND_SIGNAL(tail_owner, COMSIG_CLEAR_MOOD_EVENT, "wrong_tail_regained")
	stop_wagging_tail(tail_owner)

	// If it's initializing the species, don't add moodlets
	if(on_species_init)
		return
	// If we don't have a set tail, don't bother adding moodlets
	if(!mutant_organs.len)
		return

	SEND_SIGNAL(tail_owner, COMSIG_ADD_MOOD_EVENT, "tail_lost", /datum/mood_event/tail_lost)
	SEND_SIGNAL(tail_owner, COMSIG_ADD_MOOD_EVENT, "tail_balance_lost", /datum/mood_event/tail_balance_lost)

/*
 * This proc is called when a mob gains a tail.
 *
 * tail_owner - the owner of the tail (who holds our species datum)
 * lost_tail - the tail that was added
 * on_species_init - whether or not this was called when the species was initialized, or if it was called due to an ingame means (like surgery)
 */
/datum/species/proc/on_tail_regain(mob/living/carbon/human/tail_owner, obj/item/organ/tail/found_tail, on_species_init = FALSE)
	SEND_SIGNAL(tail_owner, COMSIG_CLEAR_MOOD_EVENT, "tail_lost")
	SEND_SIGNAL(tail_owner, COMSIG_CLEAR_MOOD_EVENT, "tail_balance_lost")

	// If it's initializing the species, don't add moodlets
	if(on_species_init)
		return
	// If we don't have a set tail, don't add moodlets
	if(!mutant_organs.len)
		return

	if(found_tail.type in mutant_organs)
		SEND_SIGNAL(tail_owner, COMSIG_ADD_MOOD_EVENT, "right_tail_regained", /datum/mood_event/tail_regained_right)
	else
		SEND_SIGNAL(tail_owner, COMSIG_ADD_MOOD_EVENT, "wrong_tail_regained", /datum/mood_event/tail_regained_wrong)

/*
 * Clears all tail related moodlets when they lose their species.
 *
 * former_tail_owner - the mob that was once a species with a tail and now is a different species
 */
/datum/species/proc/clear_tail_moodlets(mob/living/carbon/human/former_tail_owner)
	SEND_SIGNAL(former_tail_owner, COMSIG_CLEAR_MOOD_EVENT, "tail_lost")
	SEND_SIGNAL(former_tail_owner, COMSIG_CLEAR_MOOD_EVENT, "tail_balance_lost")
	SEND_SIGNAL(former_tail_owner, COMSIG_CLEAR_MOOD_EVENT, "right_tail_regained")
	SEND_SIGNAL(former_tail_owner, COMSIG_CLEAR_MOOD_EVENT, "wrong_tail_regained")
	stop_wagging_tail(former_tail_owner)

/datum/species/proc/start_wagging_tail(mob/living/carbon/human/H)

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)

///////////////
//FLIGHT SHIT//
///////////////

/datum/species/proc/GiveSpeciesFlight(mob/living/carbon/human/H)
	if(flying_species) //species that already have flying traits should not work with this proc
		return
	flying_species = TRUE
	var/wings_icon
	if(wings_icons.len > 1)
		if(!H.client)
			wings_icon = pick(wings_icons)
		else
			var/list/wings = list()
			for(var/W in wings_icons)
				var/datum/sprite_accessory/S = GLOB.wings_list[W] //Gets the datum for every wing this species has, then prompts user with a radial menu
				var/image/img = image(icon = 'icons/mob/clothing/wings.dmi', icon_state = "m_wingsopen_[S.icon_state]_BEHIND") //Process the HUD elements
				img.transform *= 0.5
				img.pixel_x = -32
				if(wings[S.name])
					stack_trace("Different wing types with repeated names. Please fix as this may cause issues.")
				else
					wings[S.name] = img
			wings_icon = show_radial_menu(H, H, wings, tooltips = TRUE)
			if(!wings_icon)
				wings_icon = pick(wings_icons)
	else
		wings_icon = wings_icons[1]

	var/obj/item/organ/external/wings/functional/wings = new(null, wings_icon, H.body_type)
	wings.Insert(H)
	handle_mutant_bodyparts(H)

/**
 * The human species version of [/mob/living/carbon/proc/get_biological_state]. Depends on the HAS_FLESH and HAS_BONE species traits, having bones lets you have bone wounds, having flesh lets you have burn, slash, and piercing wounds
 */
/datum/species/proc/get_biological_state(mob/living/carbon/human/H)
	. = BIO_INORGANIC
	if(HAS_FLESH in species_traits)
		. |= BIO_JUST_FLESH
	if(HAS_BONE in species_traits)
		. |= BIO_JUST_BONE

///Species override for unarmed attacks because the attack_hand proc was made by a mouth-breathing troglodyte on a tricycle. Also to whoever thought it would be a good idea to make it so the original spec_unarmedattack was not actually linked to unarmed attack needs to be checked by a doctor because they clearly have a vast empty space in their head.
/datum/species/proc/spec_unarmedattack(mob/living/carbon/human/user, atom/target, modifiers)
	return FALSE


///Removes any non-native limbs from the mob
/datum/species/proc/fix_non_native_limbs(mob/living/carbon/human/H)
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/current_part = X
		var/obj/item/bodypart/species_part = bodypart_overides[current_part.body_zone]

		if(current_part.type == species_part)
			continue

		current_part.change_bodypart(species_part)

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
			(preference.relevant_mutant_bodypart in mutant_bodyparts) \
			|| (preference.relevant_species_trait in species_traits) \
		)
			features += preference.savefile_key

	for (var/obj/item/organ/external/organ_type as anything in external_organs)
		var/preference = initial(organ_type.preference)
		if (!isnull(preference))
			features += preference

	GLOB.features_by_species[type] = features

	return features

/// Given a human, will adjust it before taking a picture for the preferences UI.
/// This should create a CONSISTENT result, so the icons don't randomly change.
/datum/species/proc/prepare_human_for_preview(mob/living/carbon/human/human)
	return

/// Returns the species's scream sound.
/datum/species/proc/get_scream_sound(mob/living/carbon/human/human)
	return

/datum/species/proc/get_types_to_preload()
	var/list/to_store = list()
	to_store += mutant_organs
	for(var/obj/item/organ/external/horny as anything in external_organs)
		to_store += horny //Haha get it?

	//Don't preload brains, cause reuse becomes a horrible headache
	to_store += mutantheart
	to_store += mutantlungs
	to_store += mutanteyes
	to_store += mutantears
	to_store += mutanttongue
	to_store += mutantliver
	to_store += mutantstomach
	to_store += mutantappendix
	//We don't cache mutant hands because it's not constrained enough, too high a potential for failure
	return to_store


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
