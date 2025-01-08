/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth, and genetic traits. Comes with a growth scanning mode and a chemical scanning mode."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "hydro"
	inhand_icon_state = "analyzer"
	worn_icon_state = "plantanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass =SMALL_MATERIAL_AMOUNT*0.2)
	/// Cached data from ui_interact
	var/list/last_scan_data

/obj/item/plant_analyzer/Initialize(mapload)
	. = ..()
	register_item_context()


/obj/item/plant_analyzer/examine()
	. = ..()
	. += span_notice("Left click a plant to scan its growth stats, and right click to scan its chemical reagent stats.")

/obj/item/plant_analyzer/add_item_context(
	obj/item/source,
	list/context,
	atom/target,
)

	if(isliving(target))
		// It's a health analyzer, but for podpeople.
		var/mob/living/living_target = target
		if(!(living_target.mob_biotypes & MOB_PLANT))
			return NONE

		context[SCREENTIP_CONTEXT_LMB] = "Scan health"
		context[SCREENTIP_CONTEXT_RMB] = "Scan chemicals"
		return CONTEXTUAL_SCREENTIP_SET

	if(isitem(target))
		// Easier to handle this here, as grown items are split across two type-paths
		var/obj/item/item_target = target
		if(!item_target.get_plant_seed())
			return NONE

		context[SCREENTIP_CONTEXT_LMB] = "Scan plant stats"
		context[SCREENTIP_CONTEXT_RMB] = "Scan plant chemicals"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/// When we attack something, first - try to scan something we hit with left click. Left-clicking uses scans for stats
/obj/item/plant_analyzer/pre_attack(atom/target, mob/living/user)
	. = ..()
	if(user.combat_mode || !user.can_read(src))
		return

	analyze(user, target)

	return do_plant_stats_scan(target, user)

/// Same as above, but with right click. Right-clicking scans for chemicals.
/obj/item/plant_analyzer/pre_attack_secondary(atom/target, mob/living/user)
	if(user.combat_mode || !user.can_read(src))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return do_plant_chem_scan(target, user) ? SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN : SECONDARY_ATTACK_CONTINUE_CHAIN

/*
 * Scan the target on plant scan mode. This prints traits and stats to the user.
 *
 * scan_target - the atom we're scanning
 * user - the user doing the scanning.
 *
 * returns FALSE if it's not an object or item that does something when we scan it.
 * returns TRUE if we can scan the object, and outputs the message to the USER.
 */
/obj/item/plant_analyzer/proc/do_plant_stats_scan(atom/scan_target, mob/user)
	if(istype(scan_target, /obj/machinery/hydroponics))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		to_chat(user, boxed_message(scan_tray_stats(scan_target)))
		return TRUE
	if(istype(scan_target, /obj/structure/glowshroom))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		var/obj/structure/glowshroom/shroom_plant = scan_target
		to_chat(user, boxed_message(scan_plant_stats(shroom_plant.myseed)))
		return TRUE
	if(istype(scan_target, /obj/item/graft))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		to_chat(user, boxed_message(get_graft_text(scan_target)))
		return TRUE
	if(isitem(scan_target))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		var/obj/item/scanned_object = scan_target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			to_chat(user, boxed_message(scan_plant_stats(scanned_object)))
			return TRUE
	if(isliving(scan_target))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		var/mob/living/L = scan_target
		if(L.mob_biotypes & MOB_PLANT)
			plant_biotype_health_scan(scan_target, user)
			return TRUE

	return FALSE

/*
 * Scan the target on chemical scan mode. This prints chemical genes and reagents to the user.
 *
 * scan_target - the atom we're scanning
 * user - the user doing the scanning.
 *
 * returns FALSE if it's not an object or item that does something when we scan it.
 * returns TRUE if we can scan the object, and outputs the message to the USER.
 */
/obj/item/plant_analyzer/proc/do_plant_chem_scan(atom/scan_target, mob/user)
	if(istype(scan_target, /obj/machinery/hydroponics))
		to_chat(user, boxed_message(scan_tray_chems(scan_target)))
		return TRUE
	if(istype(scan_target, /obj/structure/glowshroom))
		var/obj/structure/glowshroom/shroom_plant = scan_target
		to_chat(user, boxed_message(scan_plant_chems(shroom_plant.myseed)))
		return TRUE
	if(istype(scan_target, /obj/item/graft))
		to_chat(user, boxed_message(get_graft_text(scan_target)))
		return TRUE
	if(isitem(scan_target))
		var/obj/item/scanned_object = scan_target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			to_chat(user, boxed_message(scan_plant_chems(scanned_object)))
			return TRUE
	if(isliving(scan_target))
		var/mob/living/L = scan_target
		if(L.mob_biotypes & MOB_PLANT)
			plant_biotype_chem_scan(scan_target, user)
			return TRUE

	return FALSE

/*
 * Scan a living mob's (with MOB_PLANT biotype) health with the plant analyzer. No wound scanning, though.
 *
 * scanned_mob - the living mob being scanned
 * user - the person doing the scanning
 */
/obj/item/plant_analyzer/proc/plant_biotype_health_scan(mob/living/scanned_mob, mob/living/carbon/human/user)
	user.visible_message(
		span_notice("[user] analyzes [scanned_mob]'s vitals."),
		span_notice("You analyze [scanned_mob]'s vitals.")
		)

	healthscan(user, scanned_mob, advanced = TRUE)
	add_fingerprint(user)

/*
 * Scan a living mob's (with MOB_PLANT biotype) chemical contents with the plant analyzer.
 *
 * scanned_mob - the living mob being scanned
 * user - the person doing the scanning
 */
/obj/item/plant_analyzer/proc/plant_biotype_chem_scan(mob/living/scanned_mob, mob/living/carbon/human/user)
	user.visible_message(
		span_notice("[user] analyzes [scanned_mob]'s bloodstream."),
		span_notice("You analyze [scanned_mob]'s bloodstream.")
		)
	chemscan(user, scanned_mob)
	add_fingerprint(user)

/**
 * This proc is called when we scan a hydroponics tray or soil on left click (stats mode)
 * It formats the plant name, its age, the plant's stats, and the tray's stats.
 *
 * - scanned_tray - the tray or soil we are scanning.
 *
 * Returns the formatted message as text.
 */
/obj/item/plant_analyzer/proc/scan_tray_stats(obj/machinery/hydroponics/scanned_tray)
	var/returned_message = ""
	if(scanned_tray.myseed)
		returned_message += "[span_bold("[scanned_tray.myseed.plantname]")]"
		returned_message += "\nPlant Age: [span_notice("[scanned_tray.age]")]"
		returned_message += "\nPlant Health: [span_notice("[scanned_tray.plant_health]")]"
		returned_message += scan_plant_stats(scanned_tray.myseed, TRUE)
		returned_message += "\n<b>Growth medium</b>"
	else
		returned_message += span_bold("No plant found.")

	returned_message += "\nWeed level: [span_notice("[scanned_tray.weedlevel] / [MAX_TRAY_WEEDS]")]"
	returned_message += "\nPest level: [span_notice("[scanned_tray.pestlevel] / [MAX_TRAY_PESTS]")]"
	returned_message += "\nToxicity level: [span_notice("[scanned_tray.toxic] / [MAX_TRAY_TOXINS]")]"
	returned_message += "\nWater level: [span_notice("[scanned_tray.waterlevel] / [scanned_tray.maxwater]")]"
	returned_message += "\nNutrition level: [span_notice("[scanned_tray.reagents.total_volume] / [scanned_tray.maxnutri]")]"
	if(scanned_tray.yieldmod != 1)
		returned_message += "\nYield modifier on harvest: [span_notice("[scanned_tray.yieldmod]x")]"

	return span_info(returned_message)

/**
 * This proc is called when we scan a hydroponics tray or soil on right click (chemicals mode)
 * It formats the plant name and age, as well as the plant's chemical genes and the tray's contents.
 *
 * - scanned_tray - the tray or soil we are scanning.
 *
 * Returns the formatted message as text.
 */
/obj/item/plant_analyzer/proc/scan_tray_chems(obj/machinery/hydroponics/scanned_tray)
	var/returned_message = ""
	if(scanned_tray.myseed)
		returned_message += "[span_bold("[scanned_tray.myseed.plantname]")]"
		returned_message += "\nPlant Age: [span_notice("[scanned_tray.age]")]"
		returned_message += scan_plant_chems(scanned_tray.myseed, TRUE)
	else
		returned_message += span_bold("No plant found.")

	returned_message += "\nGrowth medium contains:"
	if(scanned_tray.reagents.reagent_list.len)
		for(var/datum/reagent/reagent_id in scanned_tray.reagents.reagent_list)
			returned_message += "\n[span_notice("&bull; [reagent_id.volume] / [scanned_tray.maxnutri] units of [reagent_id]")]"
	else
		returned_message += "\n[span_notice("No reagents found.")]"

	return span_info(returned_message)

/**
 * This proc is called when a seed or any grown plant is scanned on left click (stats mode).
 * It formats the plant name as well as either its traits and stats.
 *
 * - scanned_object - the source objecte for what we are scanning. This can be a grown food, a grown inedible, or a seed.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/scan_plant_stats(obj/item/scanned_object, in_tray = FALSE)
	var/returned_message = ""
	if(!in_tray)
		returned_message += "This is [span_name("\a [scanned_object]")]."
	else
		returned_message += "\n<b>Seed Stats</b>"
	var/obj/item/seeds/our_seed = scanned_object
	if(!istype(our_seed)) //if we weren't passed a seed, we were passed a plant with a seed
		our_seed = scanned_object.get_plant_seed()

	if(our_seed && istype(our_seed))
		returned_message += get_analyzer_text_traits(our_seed)
	else
		returned_message += "\nNo genes found."

	return span_info(returned_message)

/**
 * This proc is called when a seed or any grown plant is scanned on right click (chemical mode).
 * It formats the plant name as well as its chemical contents.
 *
 * - scanned_object - the source objecte for what we are scanning. This can be a grown food, a grown inedible, or a seed.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/scan_plant_chems(obj/item/scanned_object, in_tray = FALSE)
	var/returned_message = ""
	if(!in_tray)
		returned_message += "This is [span_name("\a [scanned_object]")]."
	else
		returned_message += "\n<b>Seed Stats</b>"
	var/obj/item/seeds/our_seed = scanned_object
	if(!istype(our_seed)) //if we weren't passed a seed, we were passed a plant with a seed
		our_seed = scanned_object.get_plant_seed()

	if(scanned_object.reagents) //we have reagents contents
		returned_message += get_analyzer_text_chem_contents(scanned_object)
	else if (our_seed.reagents_add?.len) //we have a seed with reagent genes
		returned_message += get_analyzer_text_chem_genes(our_seed)
	else
		returned_message += "\nNo reagents found."

	return span_info(returned_message)

/**
 * This proc is formats the traits and stats of a seed into a message.
 *
 * - scanned - the source seed for what we are scanning for traits.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_traits(obj/item/seeds/scanned)
	var/text = ""
	if(scanned.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
		text += "\nPlant type: [span_notice("Weed. Can grow in nutrient-poor soil.")]"
	else if(scanned.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		text += "\nPlant type: [span_notice("Mushroom. Can grow in dry soil.")]"
	else if(scanned.get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
		text += "\nPlant type: [span_warning("UNKNOWN")]"
	else
		text += "\nPlant type: [span_notice("Normal plant")]"

	if(scanned.potency != -1)
		text += "\nPotency: [span_notice("[scanned.potency]")]"
	if(scanned.yield != -1)
		text += "\nYield: [span_notice("[scanned.yield]")]"
	text += "\nMaturation speed: [span_notice("[scanned.maturation]")]"
	if(scanned.yield != -1)
		text += "\nProduction speed: [span_notice("[scanned.production]")]"
	text += "\nEndurance: [span_notice("[scanned.endurance]")]"
	text += "\nLifespan: [span_notice("[scanned.lifespan]")]"
	text += "\nInstability: [span_notice("[scanned.instability]")]"
	text += "\nWeed Growth Rate: [span_notice("[scanned.weed_rate]")]"
	text += "\nWeed Vulnerability: [span_notice("[scanned.weed_chance]")]"
	if(scanned.rarity)
		text += "\nSpecies Discovery Value: [span_notice("[scanned.rarity]")]"
	var/all_removable_traits = ""
	var/all_immutable_traits = ""
	for(var/datum/plant_gene/trait/traits in scanned.genes)
		if(istype(traits, /datum/plant_gene/trait/plant_type))
			continue
		if(traits.mutability_flags & PLANT_GENE_REMOVABLE)
			all_removable_traits += "[(all_removable_traits == "") ? "" : ", "][traits.get_name()]"
		else
			all_immutable_traits += "[(all_immutable_traits == "") ? "" : ", "][traits.get_name()]"

	text += "\nPlant Traits: [span_notice("[all_removable_traits? all_removable_traits : "None."]")]"
	text += "\nCore Plant Traits: [span_notice("[all_immutable_traits? all_immutable_traits : "None."]")]"
	var/datum/plant_gene/scanned_graft_result = scanned.graft_gene? new scanned.graft_gene : new /datum/plant_gene/trait/repeated_harvest
	text += "\nGrafting this plant would give: [span_notice("[scanned_graft_result.get_name()]")]"
	QDEL_NULL(scanned_graft_result) //graft genes are stored as typepaths so if we want to get their formatted name we need a datum ref - musn't forget to clean up afterwards
	var/unique_text = scanned.get_unique_analyzer_text()
	if(unique_text)
		text += "\n[unique_text]"
	return text

/**
 * This proc is formats the chemical GENES of a seed into a message.
 *
 * - scanned - the source seed for what we are scanning for chemical genes.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_chem_genes(obj/item/seeds/scanned)
	var/text = "\nPlant Reagent Genes:"
	for(var/datum/plant_gene/reagent/gene in scanned.genes)
		text += "\n&bull; [gene.get_name()]"
	return text

/**
 * This proc is formats the chemical CONTENTS of a plant into a message.
 *
 * - scanned_plant - the source plant we are reading out its reagents contents.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_chem_contents(obj/item/scanned_plant)
	var/text = ""
	var/reagents_text = ""
	text += "\nPlant Reagents:"
	var/chem_cap = 0
	for(var/_reagent in scanned_plant.reagents.reagent_list)
		var/datum/reagent/reagent = _reagent
		var/amount = reagent.volume
		chem_cap += reagent.volume
		reagents_text += "\n&bull; [reagent.name]: [amount]"
	if(reagents_text)
		text += reagents_text
	text += "\nMaximum reagent capacity: [scanned_plant.reagents.maximum_volume]"
	if(chem_cap > 100)
		text += "\n[span_danger("Reagent Traits Over 100% Production")]"

	return text

/**
 * This proc is formats the scan of a graft of a seed into a message.
 *
 * - scanned_graft - the graft for what we are scanning.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_graft_text(obj/item/graft/scanned_graft)
	var/text = "Plant Graft"
	if(scanned_graft.parent_name)
		text += "\nParent Plant: [span_notice("[scanned_graft.parent_name]")]"
	if(scanned_graft.stored_trait)
		text += "\nGraftable Traits: [span_notice("[scanned_graft.stored_trait.get_name()]")]"
	text += "\nYield: [span_notice("[scanned_graft.yield]")]"
	text += "\nProduction speed: [span_notice("[scanned_graft.production]")]"
	text += "\nEndurance: [span_notice("[scanned_graft.endurance]")]"
	text += "\nLifespan: [span_notice("[scanned_graft.lifespan]")]"
	text += "\nWeed Growth Rate: [span_notice("[scanned_graft.weed_rate]")]"
	text += "\nWeed Vulnerability: [span_notice("[scanned_graft.weed_chance]")]"
	return span_info(text)

/obj/item/plant_analyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantAnalyzer", "Plant Analyzer")
		ui.open()

/obj/item/plant_analyzer/ui_static_data(mob/user)
	return last_scan_data

/// Called when our analyzer is used on something
/obj/item/plant_analyzer/proc/analyze(mob/user, atom/target)
	if(!target)
		return FALSE

	if(isliving(target))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		var/mob/living/L = target
		if(L.mob_biotypes & MOB_PLANT)
			plant_biotype_health_scan(target, user)
			return TRUE

	if(istype(target, /obj/item/graft))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		to_chat(user, boxed_message(get_graft_text(target)))
		return TRUE

	var/obj/item/seeds/seed
	var/obj/machinery/hydroponics/tray

	if (istype(target, /obj/machinery/hydroponics))
		tray = target
		seed = tray.myseed
	else if (istype(target, /obj/structure/glowshroom))
		var/obj/structure/glowshroom/shroom_plant = target
		seed = shroom_plant.myseed
	else if (isitem(target))
		var/obj/item/scanned_object = target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			seed = scanned_object

	if (!seed && !tray)
		return FALSE

	last_scan_data = list()

	if(tray)
		last_scan_data["tray_data"] = list(
			"name" = tray.name,
			"icon" = tray.icon,
			"icon_state" = tray.icon_state,
			"water" = tray.waterlevel,
			"water_max" = tray.maxwater,
			"nutri" = tray.reagents.total_volume,
			"nutri_max" = tray.maxnutri,
			"yield_mod" = tray.yieldmod,
			"weeds" = tray.weedlevel,
			"weeds_max" = MAX_TRAY_WEEDS,
			"pests" = tray.pestlevel,
			"pests_max" = MAX_TRAY_PESTS,
			"toxins" = tray.toxic,
			"toxins_max" = MAX_TRAY_TOXINS,
		)
	if(seed)
		last_scan_data["seed_data"] = list(
			"name" = seed.plantname,
			"icon" = seed.growing_icon,
			"icon_state" = "[seed.icon_grow][seed.growthstages]",
			"product" = seed.product.name,
			"product_icon" = seed.product.icon,
			"product_icon_state" = seed.product.icon_state,
			"potency" = seed.potency,
			"yield" = seed.yield,
			"instability" = seed.instability,
			"maturation" = seed.maturation,
			"production" = seed.production,
			"lifespan" = seed.lifespan,
			"endurance" = seed.endurance,
			"genes" = seed.genes,
		)

	ui_interact(user)

	return TRUE

