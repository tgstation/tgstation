/datum/species/human/cerulean
	name = "\improper Cerulean"
	id = SPECIES_CERULEAN
	mutant_organs = list(/obj/item/organ/tail/fish/cerulean = /datum/sprite_accessory/tails/fish/cerulean::name)
	mutanttongue = /obj/item/organ/tongue/fish
	mutantstomach = /obj/item/organ/stomach/fish
	mutantliver = /obj/item/organ/liver/fish
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/cerulean
	species_cookie = /obj/item/food/chips/shrimp
	inert_mutation = /datum/mutation/echolocation
	payday_modifier = 0.9
	family_heirlooms = list(
		/obj/item/ammo_casing/harpoon,
		/obj/item/toy/seashell,
	)

/datum/species/human/cerulean/get_physical_attributes()
	return "Ceruleans struggle with the pull of gravity yet are otherwise similar to humans. \
		They are slightly more durable, and adore Martian culinary culture, though not much else..."

/datum/species/human/cerulean/get_species_description()
	return "Ceruleans are descendants of humans and vastly altered \"Animalids\" \
		who originated from a populace of fanatic body modders devoted to perfecting biomechanics. \
		Not much of these origins remain, par for their insatiable drive to endlessly chase scientific advancement."

/datum/species/human/cerulean/get_species_lore()
	return list(
		"Ceruleans are a scarcely common \"Animalid\" variant, sought mostly for their labor in vacuum environments. \
		They are descendant of a radically spliced human society, who inhabit two tidal locked hycean worlds: planets Marina and Moryana. \
		Most of the early Cerulean society still reside there today, granted they posess water-breathing lungs \
		or financial means to occupy limited terrestrial living-space.",

		"Most of the scientific development of early Cerulean kind, directly post migration from humans, are left in obscurity or destroyed. \
		In part due to the self-centered nature of the problems they were designed to solve, like the \"hydro-vaporizer\", a device which respirates \
		gills in dry atmosphere. Or, their arrogant and inexorable attitude in favor for their inventions and the pursuit for improvement.",

		"There is one category of technology the Ceruleans have managed to stand out with: they are pioneers of gravity manipulation technology. \
		Not many decades ago, Ceruleans of planet Marina, known as the Marinians, built grav-gen megastructures onto their sea beds to cast its \
		planet's ocean currents upward past atmosphere,	building an aquatic bridge flowing towards Moryana into a connection between the two worlds.",

		"Outwardly, this was done to show-boat their planetary technology as well as their unity portraying to be two kindred planets, but to the Moryan \
		it was an obvious attempt of the mightier celestial body to seize control over a new, peculiar society. Taking shape deep in the perpetually \
		lightless region behind Moryana, known around space as Moryana's \"Abyss\" region.",
	)

/datum/species/human/cerulean/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fish-fins",
			SPECIES_PERK_NAME = "Flip-Flap",
			SPECIES_PERK_DESC = "Ceruleans are hard to keep ahold of, becoming slippery and tough to grab if soaked in water.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield",
			SPECIES_PERK_NAME = "Scaled Up",
			SPECIES_PERK_DESC = "Ceruleans have slightly higher damage and pressure resistance.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dragon",
			SPECIES_PERK_NAME = "Little Space Dragon",
			SPECIES_PERK_DESC = "Ceruleans and their dexterity are tied to gravity, turning lethally agile if its taken out the question.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wheelchair-move",
			SPECIES_PERK_NAME = "No Leg to Stand On",
			SPECIES_PERK_DESC = "Ceruleans do not have legs, requiring a brutal surgery to opt for a pair.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shrimp",
			SPECIES_PERK_NAME = "Fried Shrimp",
			SPECIES_PERK_DESC = "Ceruleans gain more damage from burn damage and heat sources.",
		),
	)

	return to_add

/datum/species/human/cerulean/prepare_human_for_preview(mob/living/carbon/human/preview_human)
	preview_human.skin_tone = "asian1"
	preview_human.set_haircolor("#a54ea1", update = FALSE)
	preview_human.set_hairstyle(/datum/sprite_accessory/hair/countryponytail::name, update = TRUE)
	preview_human.dna.features[FEATURE_TAIL_FISH_COLOR] = COLOR_CARP_TEAL
	preview_human.dna.features[FEATURE_FRILLS] = /datum/sprite_accessory/frills/aquatic::name
	preview_human.dna.species.mutant_organs[/obj/item/organ/frills] = /datum/sprite_accessory/frills/aquatic::name
	regenerate_organs(preview_human, excluded_zones = GLOB.leg_zones)
	preview_human.update_body(is_creating = TRUE)

/datum/species/human/cerulean/get_features()
	var/list/features = ..()
	LAZYOR(features, /datum/preference/choiced/cerulean_lungs::savefile_key)
	LAZYOR(features, /datum/preference/toggle/cerulean_frills::savefile_key)
	LAZYOR(features, /datum/preference/color/fish_tail_color::savefile_key)
	return features

/datum/species/human/cerulean/randomize_features()
	var/list/features = ..()
	LAZYSET(features, FEATURE_TAIL_FISH_COLOR, pick(GLOB.carp_colors - COLOR_CARP_SILVER))
	return features

/datum/species/human/cerulean/on_species_gain(mob/living/carbon/human/cerulean, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if (isdummy(cerulean))
		cerulean.visual_only_organs = FALSE //sorry but we need them all for the organ set bonus
		return
	if (cerulean.has_gravity())
		cerulean.set_resting(TRUE, silent = TRUE, instant = TRUE)
	//apply a free wet stack to prevent the choking screen alert to appear for a second on mob creation
	cerulean.apply_status_effect(/datum/status_effect/fire_handler/wet_stacks, 1, FALSE)

/// good guy nanotrasen provides a wheelchair to their employees
/datum/species/human/cerulean/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/cerulean, visuals_only)
	if (visuals_only)
		return
	if (!istype(job))
		return
	cerulean.put_in_wheelchair()

/// gives a 'necessary for life' device to Ceruleans with gills
/datum/species/human/cerulean/post_equip_species_outfit(mob/living/carbon/human/cerulean, visuals_only)
	if (visuals_only)
		return
	var/obj/item/organ/lungs/lungs = cerulean.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (/datum/gas/oxygen in lungs?.breathe_always)
		return
	// try to attach to uniform
	var/obj/item/clothing/under/uniform = cerulean.w_uniform
	var/attached = uniform?.attach_accessory(SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer/with_cell, cerulean))
	if (attached)
		return
	// try anything else
	cerulean.equip_in_one_of_slots(
		equipping = SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer/with_cell, cerulean),
		slots = list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_HANDS, LOCATION_BACKPACK),
		qdel_on_fail = FALSE,
		indirect_action = TRUE,
	)

/// The inverse multiplyer indicating how much blood compared to default_blood_volume() needs to exist for a clean detachment surgery
#define CLEAN_CUT_MULT 0.5

/*
 * the main driver of the species and the source of the strongest species perks
 * allowing free movement in any atmosphere if zero g
 */
/obj/item/organ/tail/fish/cerulean
	name = "oversized fish tail"
	desc = "A hugely sized and scaled fish tail, clearly severed from something much larger than a mere space carp."
	external_bodyshapes = BODYSHAPE_CERULEAN
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/cerulean
	w_class = WEIGHT_CLASS_BULKY
	fillet_amount = 12
	organ_traits = list(
		TRAIT_FREE_FLOAT_MOVEMENT,
		TRAIT_FLOPPING,
		TRAIT_SWIMMER,
		TRAIT_BLOCK_ATTACHING_LEGS,
	)

/obj/item/organ/tail/fish/cerulean/on_mob_insert(mob/living/carbon/owner, special)
	. = ..()
	get_your_sealegs(owner, special)

/obj/item/organ/tail/fish/cerulean/on_mob_remove(mob/living/carbon/owner, special)
	. = ..()
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	if(special)
		return
	var/limb_name = "\improper [bodypart_owner.name]"
	var/tail_name = "\improper [name]"
	owner.apply_damage(rand(35, 45), def_zone = BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	if(!HAS_TRAIT(owner, TRAIT_ANALGESIA))
		owner.emote("scream") //owowowowowow
		owner.set_jitter_if_lower(1 SECONDS)
		shake_camera(owner, 1 SECONDS, 2)
		to_chat(owner, span_userdanger("You wince and scream as your [tail_name] is grotesquely torn from your [limb_name]!"))
	if(!splatter_check(owner))
		// if you have no blood or are missing half of it, its a clean cut
		return
	owner.blood_volume -= (owner.blood_volume / 3)
	owner.add_splatter_floor(get_turf(src))
	owner.spray_blood(REVERSE_DIR(owner.dir), 2)
	owner.visible_message(span_danger("[src] detaches from [owner]'s [limb_name], spilling out liters of [LOWER_TEXT(owner.get_bloodtype()?.get_blood_name())]!"))
	REMOVE_TRAIT(src, TRAIT_NODROP, ORGAN_INSIDE_BODY_TRAIT) //do this early so we can fling it
	throw_at(get_edge_target_turf(owner, REVERSE_DIR(owner.dir))) //ok so it doesnt actually fling it it just spins but idk hwo to fling
	playsound(src, 'sound/effects/cartoon_sfx/cartoon_splat.ogg', rand(50, 75), TRUE)

/obj/item/organ/tail/fish/cerulean/on_surgical_removal(mob/living/user, obj/item/bodypart/limb, obj/item/tool)
	. = ..()
	if(!splatter_check(limb.owner))
		return
	shake_camera(user, 1 SECONDS, 2) //you shake too hehe
	user.set_jitter_if_lower(1 SECONDS)

// limit restyle to our tail's unique pool
/obj/item/organ/tail/fish/cerulean/get_valid_restyles()
	return bodypart_overlay.get_global_feature_list()

/// check if we have (enough) blood for an (un)clean cut
/obj/item/organ/tail/fish/cerulean/proc/splatter_check(mob/living/carbon/owner)
	if(isnull(owner))
		return FALSE
	return (owner.blood_volume && !HAS_TRAIT(owner, TRAIT_NOBLOOD) && owner.blood_volume >= (owner.default_blood_volume * CLEAN_CUT_MULT))

/// if legs are present remove them silently if special = true, not so silently else
/obj/item/organ/tail/fish/cerulean/proc/get_your_sealegs(mob/living/carbon/owner, special)
	var/list/legs = list(owner.get_bodypart(BODY_ZONE_R_LEG), owner.get_bodypart(BODY_ZONE_L_LEG))
	for(var/obj/item/bodypart/leg/leg as anything in legs)
		(special || QDELING(owner)) ? leg?.drop_limb(TRUE, FALSE, FALSE) : leg?.dismember()

/// the bodypart overlay for cerulean fish tails!
/datum/bodypart_overlay/mutant/tail/fish/cerulean
	layers = list(
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
	)
	/// which datums are blocked in get_global_feature_list
	var/list/locked_sprite_datums = list(
		/datum/sprite_accessory/tails/fish/cerulean/skeleton,
	)

/datum/bodypart_overlay/mutant/tail/fish/cerulean/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

// simpler than parent. we don't care about locked/natural_spawn. all the accessories in our pool are locked
/datum/bodypart_overlay/mutant/tail/fish/cerulean/get_random_appearance()
	return fetch_sprite_datum_from_name(pick(get_global_feature_list()))

// make our own little feature list by copying the global and removing the normal fish tails
/datum/bodypart_overlay/mutant/tail/fish/cerulean/get_global_feature_list()
	var/static/list/glob_feature_list = list()
	if(!length(glob_feature_list))
		glob_feature_list = SSaccessories.feature_list[feature_key]
	var/list/feature_list = glob_feature_list.Copy()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		if(!istype(accessory_datum, /datum/sprite_accessory/tails/fish/cerulean))
			feature_list -= accessory
		if(accessory_datum.type in locked_sprite_datums)
			feature_list -= accessory
	return feature_list

/*
 * same as parent, but with a pretty skeleton texture
 */
/obj/item/organ/tail/fish/cerulean/abyssal
	name = "translucent oversized fish tail"
	desc = "A hugely sized and scaled fish tail, it is partially translucent and shows the skeleton inside."
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal

/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal
	var/abyssal_tweak = /datum/bodypart_texture/abyssal_cerulean

// an additional overlay to be added to the image stack. used by abyssal cerulean's skeleton
/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	var/list/created_overlays = ..()
	created_overlays += mutable_appearance(sprite_datum.icon, "abyssal_skeleton", offset_spokesman = limb, alpha = 105, layer = layer_real)
	created_overlays += emissive_appearance(sprite_datum.icon, "abyssal_skeleton", offset_spokesman = limb, alpha = 35, layer = layer_real)
	return created_overlays

/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal/added_to_limb(obj/item/bodypart/limb)
	limb.add_bodypart_texture(abyssal_tweak, FALSE)

/datum/bodypart_overlay/mutant/tail/fish/cerulean/abyssal/removed_from_limb(obj/item/bodypart/limb)
	limb.remove_bodypart_texture(abyssal_tweak, FALSE)

/datum/bodypart_texture/abyssal_cerulean/modify_bodypart_appearance(image/appearance)
	var/icon/new_appearance = new(appearance.icon)
	new_appearance.Blend(icon(/datum/sprite_accessory/tails/fish/cerulean::icon, "abyssal_mask"), ICON_SUBTRACT)
	appearance.icon = new_appearance

/datum/bodypart_texture/abyssal_cerulean/can_texture_bodypart(obj/item/bodypart/bodypart_owner)
	return TRUE

/*
 * same as parent, but for cerulean skeletons
 */
/obj/item/organ/tail/fish/cerulean/skeletal
	name = "skeletal oversized fish tail"
	desc = "A hugely sized fish tail skeleton."
	post_init_icon_state = null
	greyscale_config = null
	greyscale_colors = null

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/cerulean/skeletal

	food_reagents = list(/datum/reagent/consumable/nutriment = 1) //i guess
	restyle_flags = EXTERNAL_RESTYLE_ENAMEL
	foodtype_flags = GORE
	food_tastes = list("bone" = 1)
	fillet_amount = 0

/obj/item/organ/tail/fish/cerulean/skeletal/LateInitialize()
	RemoveElement(/datum/element/processable)

/obj/item/organ/tail/fish/cerulean/skeletal/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/organ/tail/fish/cerulean/skeletal/splatter_check(mob/living/carbon/owner)
	return FALSE //no blood in this one

/datum/bodypart_overlay/mutant/tail/fish/cerulean/skeletal
	locked_sprite_datums = list(
		/datum/sprite_accessory/tails/fish/cerulean,
	)

#undef CLEAN_CUT_MULT
