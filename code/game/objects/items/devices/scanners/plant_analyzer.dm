#define PLANT_ANALYZER_STAT_TAB 1
#define PLANT_ANALYZER_CHEM_TAB 2

/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth, genetic traits and chemicals."
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
	/// Weakref to the last thing we scanned
	var/datum/weakref/last_tray_scanned
	/// Cached data for the product grinder results
	var/static/list/product_grinder_results = list()
	/// If TRUE the UI opens to the second tab / the chem tab
	var/shown_tab = PLANT_ANALYZER_STAT_TAB

/obj/item/plant_analyzer/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/plant_analyzer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

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
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/// When we use the analyzer in hand - try to show the results of the last scan
/obj/item/plant_analyzer/interact(mob/user)
	if(user.stat != CONSCIOUS || !user.can_read(src) || user.is_blind())
		return
	if(last_scan_data)
		return ..()

/// When we attack something, try to scan something we hit with left click. Left-clicking uses scans for stats
/obj/item/plant_analyzer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isliving(interacting_with))
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		var/mob/living/living_target = interacting_with
		if(living_target.mob_biotypes & MOB_PLANT)
			plant_biotype_health_scan(living_target, user)
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	shown_tab = PLANT_ANALYZER_STAT_TAB
	return analyze(user, interacting_with)

/// Same as above, but with right click. Right-clicking scans for chemicals.
/obj/item/plant_analyzer/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return do_plant_chem_scan(interacting_with, user)

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
	if(isliving(scan_target))
		var/mob/living/living_target = scan_target
		if(living_target.mob_biotypes & MOB_PLANT)
			plant_biotype_chem_scan(scan_target, user)
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	shown_tab = PLANT_ANALYZER_CHEM_TAB
	return analyze(user, scan_target)

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

/obj/item/plant_analyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantAnalyzer", "Plant Analyzer")
		ui.open()

/obj/item/plant_analyzer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("setTab")
			var/tab = params["tab"]
			if(tab == PLANT_ANALYZER_STAT_TAB || tab == PLANT_ANALYZER_CHEM_TAB)
				shown_tab = tab
			return TRUE

/obj/item/plant_analyzer/ui_data(mob/user)
	var/list/data = list()
	data["active_tab"] = shown_tab
	data += last_scan_data
	return data

/obj/item/plant_analyzer/ui_static_data(mob/user)
	var/list/data = list()
	data["cycle_seconds"] = HYDROTRAY_CYCLE_DELAY / 10
	data["trait_db"] = list()
	for(var/datum/plant_gene/trait as anything in GLOB.plant_traits)
		var/trait_data = list(list(
			"path" = trait.type,
			"name" = trait.get_name(),
			"icon" = trait.icon,
			"description" = trait.description
		))
		data["trait_db"] += trait_data
	return data

/obj/item/plant_analyzer/process(seconds_per_tick)
	var/atom/real_last_tray_scanned = last_tray_scanned?.resolve()
	if(QDELETED(real_last_tray_scanned))
		return PROCESS_KILL

	if(loc.Adjacent(real_last_tray_scanned))
		analyze(null, real_last_tray_scanned)

/// Called when our analyzer is used on something
/obj/item/plant_analyzer/proc/analyze(mob/user, atom/target)
	var/obj/item/graft/graft
	var/obj/item/seeds/seed
	var/obj/machinery/hydroponics/tray

	if(user)
		playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)

	if (istype(target, /obj/machinery/hydroponics))
		tray = target
		seed = tray.myseed
	else if (istype(target, /obj/structure/glowshroom))
		var/obj/structure/glowshroom/shroom_plant = target
		seed = shroom_plant.myseed
	else if(istype(target, /obj/item/graft))
		graft = target
	else if (isitem(target))
		var/obj/item/scanned_object = target
		if(istype(scanned_object, /obj/item/seeds))
			seed = scanned_object
		else if (scanned_object.get_plant_seed())
			seed = scanned_object.get_plant_seed()

	if (!seed && !tray && !graft)
		return NONE

	if(user)
		if(!user.can_read(src))
			return ITEM_INTERACT_BLOCKING
		START_PROCESSING(SSobj, src)
		last_tray_scanned = WEAKREF(tray) // sets it to null if no tray

	last_scan_data = list(
		"tray_data" = null,
		"seed_data" = null,
		"plant_data" = null,
		"graft_data" = null,
	)

	if(tray)
		last_scan_data["tray_data"] = list(
			"plant_health" = tray.plant_health,
			"plant_age" = tray.age,
			"is_dead" = tray.plant_status == HYDROTRAY_PLANT_DEAD,
			"name" = tray.name,
			"icon" = tray.icon,
			"icon_state" = tray.icon_state,
			"water" = tray.waterlevel,
			"water_max" = tray.maxwater,
			"nutri" = tray.reagents.total_volume,
			"nutri_max" = tray.maxnutri,
			"yield_mod" = tray.yieldmod,
			"being_pollinated" = tray.being_pollinated,
			"self_sustaining" = tray.self_sustaining,
			"light_level" = tray.light_level,
			"weeds" = tray.weedlevel,
			"weeds_max" = MAX_TRAY_WEEDS,
			"pests" = tray.pestlevel,
			"pests_max" = MAX_TRAY_PESTS,
			"toxins" = tray.toxic,
			"toxins_max" = MAX_TRAY_TOXINS,
			"reagents" = list(),
		)
		for(var/datum/reagent/reagent as anything in tray.reagents.reagent_list)
			last_scan_data["tray_data"]["reagents"] += list(list(
				"name" = reagent.name,
				"volume" = round(reagent.volume, CHEMICAL_QUANTISATION_LEVEL),
				"color" = reagent.color,
			))

	if(seed)
		last_scan_data["seed_data"] = make_seed_data(seed)

	if(isitem(target) && target.reagents)
		last_scan_data["plant_data"] = list(
			"reagents" = list(),
		)
		for(var/datum/reagent/reagent as anything in target.reagents.reagent_list)
			last_scan_data["plant_data"]["reagents"] += list(list(
				"name" = reagent.name,
				"volume" = round(reagent.volume, CHEMICAL_QUANTISATION_LEVEL),
				"color" = reagent.color,
			))

	if(graft)
		last_scan_data["graft_data"] = list(
			"name" = graft.parent_name,
			"icon" = graft.icon,
			"icon_state" = graft.icon_state,
			"yield" = graft.yield,
			"production" = graft.production,
			"lifespan" = graft.lifespan,
			"endurance" = graft.endurance,
			"weed_rate" = graft.weed_rate,
			"weed_chance" = graft.weed_chance,
			"graft_gene" = graft.stored_trait.type,
		)

	if(user)
		ui_interact(user)
	return ITEM_INTERACT_SUCCESS


/obj/item/plant_analyzer/proc/make_seed_data(obj/item/seeds/seed)
	var/list/seed_data = list(
		"name" = seed.plantname,
		"icon" = seed.growing_icon,
		"icon_state" = seed.icon_harvest,
		"product" = seed.product?.name,
		"product_icon" = seed.product?.icon,
		"product_icon_state" = seed.product?.icon_state,
		"potency" = seed.potency,
		"yield" = seed.yield,
		"instability" = seed.instability,
		"maturation" = seed.maturation,
		"production" = seed.production,
		"lifespan" = seed.lifespan,
		"endurance" = seed.endurance,
		"weed_rate" = seed.weed_rate,
		"weed_chance" = seed.weed_chance,
		"graft_gene" = seed.graft_gene || /datum/plant_gene/trait/repeated_harvest,
	)
	seed_data["removable_traits"] = list()
	seed_data["core_traits"] = list()
	for(var/datum/plant_gene/trait/trait in seed.genes)
		if(trait.mutability_flags & PLANT_GENE_REMOVABLE)
			seed_data["removable_traits"] += trait.type
		else
			seed_data["core_traits"] += trait.type
	seed_data["reagents"] = list()
	for(var/datum/plant_gene/reagent/reagent in seed.genes)
		seed_data["reagents"] += list(list(
			"name" = reagent.name,
			"rate" = reagent.rate
		))
	var/datum/plant_gene/trait/maxchem/volume_trait = locate(/datum/plant_gene/trait/maxchem) in seed.genes
	var/datum/plant_gene/trait/modified_volume/volume_unit_trait = locate(/datum/plant_gene/trait/modified_volume) in seed.genes
	seed_data["volume_mod"] = volume_trait ? volume_trait.rate : 1
	seed_data["volume_units"] = volume_unit_trait ? volume_unit_trait.new_capcity : PLANT_REAGENT_VOLUME
	seed_data["mutatelist"] = list()
	for(var/obj/item/seeds/mutant as anything in seed.mutatelist)
		seed_data["mutatelist"] += initial(mutant.plantname)
	if(seed.product)
		if(!product_grinder_results[seed.product])
			product_grinder_results[seed.product] = list()
			var/obj/item/food/grown/product = new seed.product
			var/datum/reagent/product_distill_reagent = product.distill_reagent
			var/datum/reagent/product_juice_typepath = product.juice_typepath
			product_grinder_results[seed.product]["distill_reagent"] = initial(product_distill_reagent.name)
			product_grinder_results[seed.product]["juice_name"] = initial(product_juice_typepath.name)
			product_grinder_results[seed.product]["grind_results"] = list()
			for(var/datum/reagent/reagent as anything in product.grind_results)
				product_grinder_results[seed.product]["grind_results"] += initial(reagent.name)
			qdel(product)
		seed_data["distill_reagent"] = product_grinder_results[seed.product]["distill_reagent"]
		seed_data["juice_name"] = product_grinder_results[seed.product]["juice_name"]
		seed_data["grind_results"] = product_grinder_results[seed.product]["grind_results"]

	seed_data["unique_labels"] = list()
	seed_data["unique_collapsibles"] = list()
	var/list/unique_data = seed.get_unique_analyzer_data()
	for(var/label in unique_data)
		seed_data[islist(unique_data[label]) ? "unique_collapsibles" : "unique_labels"] += list(list(
			"label" = label,
			"data" = unique_data[label],
		))
	return seed_data

#undef PLANT_ANALYZER_STAT_TAB
#undef PLANT_ANALYZER_CHEM_TAB
