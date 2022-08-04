// Plant analyzer
/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth, and genetic traits. Comes with a growth scanning mode and a chemical scanning mode."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	inhand_icon_state = "analyzer"
	worn_icon_state = "plantanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron = 30, /datum/material/glass = 20)

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
		to_chat(user, examine_block(scan_tray_stats(scan_target)))
		return TRUE
	if(istype(scan_target, /obj/structure/glowshroom))
		var/obj/structure/glowshroom/shroom_plant = scan_target
		to_chat(user, examine_block(scan_plant_stats(shroom_plant.myseed)))
		return TRUE
	if(istype(scan_target, /obj/item/graft))
		to_chat(user, examine_block(get_graft_text(scan_target)))
		return TRUE
	if(isitem(scan_target))
		var/obj/item/scanned_object = scan_target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			to_chat(user, examine_block(scan_plant_stats(scanned_object)))
			return TRUE
	if(isliving(scan_target))
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
		to_chat(user, examine_block(scan_tray_chems(scan_target)))
		return TRUE
	if(istype(scan_target, /obj/structure/glowshroom))
		var/obj/structure/glowshroom/shroom_plant = scan_target
		to_chat(user, examine_block(scan_plant_chems(shroom_plant.myseed)))
		return TRUE
	if(istype(scan_target, /obj/item/graft))
		to_chat(user, examine_block(get_graft_text(scan_target)))
		return TRUE
	if(isitem(scan_target))
		var/obj/item/scanned_object = scan_target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			to_chat(user, examine_block(scan_plant_chems(scanned_object)))
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
 * It formats the plant name, it's age, the plant's stats, and the tray's stats.
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


// *************************************
// Hydroponics Tools
// *************************************

/obj/item/reagent_containers/spray/weedspray // -- Skie
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "weed spray"
	icon_state = "weedspray"
	inhand_icon_state = "spraycan"
	worn_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 100)

/obj/item/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (TOXLOSS)

/obj/item/reagent_containers/spray/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "pest spray"
	icon_state = "pestspray"
	inhand_icon_state = "plantbgone"
	worn_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/pestkiller = 100)

/obj/item/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (TOXLOSS)

/obj/item/cultivator
	name = "cultivator"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cultivator"
	inhand_icon_state = "cultivator"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50)
	attack_verb_continuous = list("slashes", "slices", "cuts", "claws")
	attack_verb_simple = list("slash", "slice", "cut", "claw")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/cultivator/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is scratching [user.p_their()] back as hard as [user.p_they()] can with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/cultivator/rake
	name = "rake"
	icon_state = "rake"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("slashes", "slices", "bashes", "claws")
	attack_verb_simple = list("slash", "slice", "bash", "claw")
	hitsound = null
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)
	flags_1 = NONE
	resistance_flags = FLAMMABLE

/obj/item/cultivator/rake/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/cultivator/rake/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	if(has_gravity(loc) && HAS_TRAIT(H, TRAIT_CLUMSY) && !H.resting)
		H.set_timed_status_effect(10 SECONDS, /datum/status_effect/confusion, only_if_higher = TRUE)
		H.Stun(20)
		playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		H.visible_message(span_warning("[H] steps on [src] causing the handle to hit [H.p_them()] right in the face!"), \
						  span_userdanger("You step on [src] causing the handle to hit you right in the face!"))

/obj/item/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "hatchet"
	inhand_icon_state = "hatchet"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 12
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 15
	throw_speed = 4
	throw_range = 7
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	custom_materials = list(/datum/material/iron = 15000)
	attack_verb_continuous = list("chops", "tears", "lacerates", "cuts")
	attack_verb_simple = list("chop", "tear", "lacerate", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED

/obj/item/hatchet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 7 SECONDS, \
	effectiveness = 100, \
	)

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is chopping at [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/hatchet/wooden
	desc = "A crude axe blade upon a short wooden handle."
	icon_state = "woodhatchet"
	custom_materials = null
	flags_1 = NONE

/obj/item/scythe
	icon_state = "scythe0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	armour_penetration = 20
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("chops", "slices", "cuts", "reaps")
	attack_verb_simple = list("chop", "slice", "cut", "reap")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/swiping = FALSE

/obj/item/scythe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 9 SECONDS, \
	effectiveness = 105, \
	)

/obj/item/scythe/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is beheading [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
		if(BP)
			BP.drop_limb()
			playsound(src, SFX_DESECRATION ,50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/scythe/pre_attack(atom/A, mob/living/user, params)
	if(swiping || !istype(A, /obj/structure/spacevine) || get_turf(A) == get_turf(user))
		return ..()
	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(A))
	swiping = TRUE
	var/static/list/scythe_slash_angles = list(0, 45, 90, -45, -90)
	for(var/i in scythe_slash_angles)
		var/turf/T = get_step(user_turf, turn(dir_to_target, i))
		for(var/obj/structure/spacevine/V in T)
			if(user.Adjacent(V))
				melee_attack_chain(user, V)
	swiping = FALSE
	return TRUE

/obj/item/secateurs
	name = "secateurs"
	desc = "It's a tool for cutting grafts off plants."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "secateurs"
	inhand_icon_state = "secateurs"
	worn_icon_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=4000)
	attack_verb_continuous = list("slashes", "slices", "cuts", "claws")
	attack_verb_simple = list("slash", "slice", "cut", "claw")
	hitsound = 'sound/weapons/bladeslice.ogg'

/// Secateurs can be used to style podperson "hair"
/obj/item/secateurs/attack(mob/trimmed, mob/living/trimmer)
	if(ispodperson(trimmed))
		var/mob/living/carbon/human/pod = trimmed
		var/location = trimmer.zone_selected
		if((location in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_HEAD)) && !pod.get_bodypart(BODY_ZONE_HEAD))
			to_chat(trimmer, span_warning("[pod] [pod.p_do()]n't have a head!"))
			return
		if(location == BODY_ZONE_HEAD && !trimmer.combat_mode)
			if(!trimmer.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			var/new_style = tgui_input_list(trimmer, "Select a hairstyle", "Grooming", GLOB.pod_hair_list)
			if(isnull(new_style))
				return
			trimmer.visible_message(
				span_notice("[trimmer] tries to change [pod == trimmer ? trimmer.p_their() : pod.name + "'s"] hairstyle using [src]."),
				span_notice("You try to change [pod == trimmer ? "your" : pod.name + "'s"] hairstyle using [src].")
			)
			if(new_style && do_after(trimmer, 6 SECONDS, target = pod))
				trimmer.visible_message(
					span_notice("[trimmer] successfully changes [pod == trimmer ? trimmer.p_their() : pod.name + "'s"] hairstyle using [src]."),
					span_notice("You successfully change [pod == trimmer ? "your" : pod.name + "'s"] hairstyle using [src].")
				)

				var/datum/species/pod/species = pod.dna?.species
				species?.change_hairstyle(pod, new_style)
		else
			return ..()
	else
		return ..()

/obj/item/geneshears
	name = "Botanogenetic Plant Shears"
	desc = "A high tech, high fidelity pair of plant shears, capable of cutting genetic traits out of a plant."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "genesheers"
	inhand_icon_state = "secateurs"
	worn_icon_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 8
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=4000, /datum/material/uranium=1500, /datum/material/gold=500)
	attack_verb_continuous = list("slashes", "slices", "cuts")
	attack_verb_simple = list("slash", "slice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/reagent_containers/glass/bottle/nutrient
	name = "bottle of nutrient"
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	desc = "Contains a fertilizer that causes mild mutations and gradual plant growth with each harvest."
	list_reagents = list(/datum/reagent/plantnutriment/eznutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/l4z
	name = "bottle of Left 4 Zed"
	desc = "Contains a fertilizer that lightly heals the plant but causes significant mutations in plants over generations."
	list_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/rh
	name = "bottle of Robust Harvest"
	desc = "Contains a fertilizer that increases the yield of a plant while gradually preventing mutations."
	list_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/empty
	name = "bottle"

/obj/item/reagent_containers/glass/bottle/killer
	volume = 30
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1,2,5)

/obj/item/reagent_containers/glass/bottle/killer/weedkiller
	name = "bottle of weed killer"
	desc = "Contains a herbicide."
	list_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 30)

/obj/item/reagent_containers/glass/bottle/killer/pestkiller
	name = "bottle of pest spray"
	desc = "Contains a pesticide."
	list_reagents = list(/datum/reagent/toxin/pestkiller = 30)
