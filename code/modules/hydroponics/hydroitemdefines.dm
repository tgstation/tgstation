
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
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)
	var/scan_mode = PLANT_SCANMODE_STATS

/obj/item/plant_analyzer/examine()
	. = ..()
	. += "<span class='notice'>Activate it in your hand to change \the [src] between a growth statistics mode and a chemical reagents mode.</span>"

/obj/item/plant_analyzer/attack_self(mob/user)
	. = ..()
	scan_mode = !scan_mode
	to_chat(user, "<span class='notice'>You switch [src] to [scan_mode == PLANT_SCANMODE_CHEMICALS ? "scan for chemical reagents and traits" : "scan for plant growth statistics"].</span>")

/obj/item/plant_analyzer/attack(mob/living/M, mob/living/carbon/human/user)
	//Checks if target is a podman
	if(ispodperson(M))
		user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", \
							"<span class='notice'>You analyze [M]'s vitals.</span>")
		if(scan_mode == PLANT_SCANMODE_STATS)
			healthscan(user, M, advanced = TRUE)
		else
			chemscan(user, M)
		add_fingerprint(user)
		return
	return ..()

/**
 * This proc is called when we scan a hydroponics tray or soil.
 * It formats the plant name, it's age, the plant's stats, and the tray's stats.
 *
 * - scanned_tray - the tray or soil we are scanning.
 *
 * Returns the formatted message as text.
 */
/obj/item/plant_analyzer/proc/scan_tray(obj/machinery/hydroponics/scanned_tray)
	var/returned_message = "<span class='info'>*---------*\n"
	if(scanned_tray.myseed)
		returned_message += "*** <B>[scanned_tray.myseed.plantname]</B> ***\n"
		returned_message += "- Plant Age: <span class='notice'>[scanned_tray.age]</span></span>\n"
		returned_message += scan_plant(scanned_tray.myseed)
	else
		returned_message += "<span class='info'><B>No plant found.</B></span>\n"

	returned_message += "<span class='info'>- Weed level: <span class='notice'>[scanned_tray.weedlevel] / [MAX_TRAY_WEEDS]</span>\n"
	returned_message += "- Pest level: <span class='notice'>[scanned_tray.pestlevel] / [MAX_TRAY_PESTS]</span>\n"
	returned_message += "- Toxicity level: <span class='notice'>[scanned_tray.toxic] / [MAX_TRAY_TOXINS]</span>\n"
	returned_message += "- Water level: <span class='notice'>[scanned_tray.waterlevel] / [scanned_tray.maxwater]</span>\n"
	returned_message += "- Nutrition level: <span class='notice'>[scanned_tray.reagents.total_volume] / [scanned_tray.maxnutri]</span>\n"
	if(scanned_tray.yieldmod != 1)
		returned_message += "- Yield modifier on harvest: <span class='notice'>[scanned_tray.yieldmod]x</span>\n"
	returned_message += "*---------*</span>"

	return returned_message

/**
 * This proc is called when a seed or any grown plant is scanned.
 * It formats the plant name as well as either its traits or its chemical contents.
 *
 * - scanned_object - the source objecte for what we are scanning. This can be a grown food, a grown inedible, or a seed.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/scan_plant(obj/item/scanned_object)
	var/returned_message = "<span class='info'>*---------*\nThis is \a <span class='name'>[scanned_object]</span>.\n"
	var/obj/item/seeds/our_seed = scanned_object
	if(!istype(our_seed)) //if we weren't passed a seed, we were passed a plant with a seed
		var/obj/item/grown/scanned_plant = scanned_object
		our_seed = scanned_plant.seed

	switch(scan_mode)
		if(PLANT_SCANMODE_STATS)
			if(our_seed && istype(our_seed))
				returned_message += get_analyzer_text_traits(our_seed)
			else
				returned_message += "*---------*\nNo genes found.\n*---------*"
		if(PLANT_SCANMODE_CHEMICALS)
			if(scanned_object.reagents) //we have reagents contents
				returned_message += get_analyzer_text_chem_contents(scanned_object)
			else if (our_seed.reagents_add?.len) //we have a seed with reagent genes
				returned_message += get_analyzer_text_chem_genes(our_seed)
			else
				returned_message += "*---------*\nNo reagents found.\n*---------*"

	returned_message += "</span>\n"
	return returned_message

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
		text += "- Plant type: <span class='notice'>Weed. Can grow in nutrient-poor soil.</span>\n"
	else if(scanned.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		text += "- Plant type: <span class='notice'>Mushroom. Can grow in dry soil.</span>\n"
	else if(scanned.get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
		text += "- Plant type: <span class='warning'>UNKNOWN</span> \n"
	else
		text += "- Plant type: <span class='notice'>Normal plant</span>\n"

	if(scanned.potency != -1)
		text += "- Potency: <span class='notice'>[scanned.potency]</span>\n"
	if(scanned.yield != -1)
		text += "- Yield: <span class='notice'>[scanned.yield]</span>\n"
	text += "- Maturation speed: <span class='notice'>[scanned.maturation]</span>\n"
	if(scanned.yield != -1)
		text += "- Production speed: <span class='notice'>[scanned.production]</span>\n"
	text += "- Endurance: <span class='notice'>[scanned.endurance]</span>\n"
	text += "- Lifespan: <span class='notice'>[scanned.lifespan]</span>\n"
	text += "- Instability: <span class='notice'>[scanned.instability]</span>\n"
	text += "- Weed Growth Rate: <span class='notice'>[scanned.weed_rate]</span>\n"
	text += "- Weed Vulnerability: <span class='notice'>[scanned.weed_chance]</span>\n"
	if(scanned.rarity)
		text += "- Species Discovery Value: <span class='notice'>[scanned.rarity]</span>\n"
	var/all_traits = ""
	for(var/datum/plant_gene/trait/traits in scanned.genes)
		if(istype(traits, /datum/plant_gene/trait/plant_type))
			continue
		all_traits += "[(all_traits == "") ? "" : ", "][traits.get_name()]"
	text += "- Plant Traits: <span class='notice'>[all_traits? all_traits : "None."]</span>\n"
	var/datum/plant_gene/scanned_graft_result = scanned.graft_gene? new scanned.graft_gene : new /datum/plant_gene/trait/repeated_harvest
	text += "- Grafting this plant would give: <span class='notice'>[scanned_graft_result.get_name()]</span>\n"
	QDEL_NULL(scanned_graft_result) //graft genes are stored as typepaths so if we want to get their formatted name we need a datum ref - musn't forget to clean up afterwards
	text += "*---------*"
	var/unique_text = scanned.get_unique_analyzer_text()
	if(unique_text)
		text += "\n"
		text += unique_text
		text += "\n*---------*"
	return text

/**
 * This proc is formats the chemical GENES of a seed into a message.
 *
 * - scanned - the source seed for what we are scanning for chemical genes.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_chem_genes(obj/item/seeds/scanned)
	var/text = ""
	text += "- Plant Reagent Genes -\n"
	text += "*---------*\n<span class='notice'>"
	for(var/datum/plant_gene/reagent/gene in scanned.genes)
		text += "- [gene.get_name()] -\n"
	text += "</span>*---------*"
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
	text += "<br><span class='info'>- Plant Reagents -</span>"
	text += "<br><span class='info'>Maximum reagent capacity: [scanned_plant.reagents.maximum_volume]</span>"
	var/chem_cap = 0
	for(var/_reagent in scanned_plant.reagents.reagent_list)
		var/datum/reagent/reagent  = _reagent
		var/amount = reagent.volume
		chem_cap += reagent.volume
		reagents_text += "\n<span class='info'>- [reagent.name]: [amount]</span>"
	if(chem_cap > 100)
		text += "<br><span class='warning'>- Reagent Traits Over 100% Production</span></br>"

	if(reagents_text)
		text += "<br><span class='info'>*---------*</span>"
		text += reagents_text
	text += "<br><span class='info'>*---------*</span>"
	return text

/**
 * This proc is formats the scan of a graft of a seed into a message.
 *
 * - scanned_graft - the graft for what we are scanning.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_graft_text(obj/item/graft/scanned_graft)
	var/text = "<span class='info'>*---------*</span>\n<span class='info'>- Plant Graft -\n"
	if(scanned_graft.parent_name)
		text += "- Parent Plant: <span class='notice'>[scanned_graft.parent_name]</span> -\n"
	if(scanned_graft.stored_trait)
		text += "- Graftable Traits: <span class='notice'>[scanned_graft.stored_trait.get_name()]</span> -\n"
	text += "*---------*\n"
	text += "- Yield: <span class='notice'>[scanned_graft.yield]</span>\n"
	text += "- Production speed: <span class='notice'>[scanned_graft.production]</span>\n"
	text += "- Endurance: <span class='notice'>[scanned_graft.endurance]</span>\n"
	text += "- Lifespan: <span class='notice'>[scanned_graft.lifespan]</span>\n"
	text += "- Weed Growth Rate: <span class='notice'>[scanned_graft.weed_rate]</span>\n"
	text += "- Weed Vulnerability: <span class='notice'>[scanned_graft.weed_chance]</span>\n"
	text += "*---------*</span>"
	return text


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
	user.visible_message("<span class='suicide'>[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
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
	user.visible_message("<span class='suicide'>[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
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
	user.visible_message("<span class='suicide'>[user] is scratching [user.p_their()] back as hard as [user.p_they()] can with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
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

/obj/item/cultivator/rake/Crossed(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	if(has_gravity(loc) && HAS_TRAIT(H, TRAIT_CLUMSY) && !H.resting)
		H.set_confusion(max(H.get_confusion(), 10))
		H.Stun(20)
		playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		H.visible_message("<span class='warning'>[H] steps on [src] causing the handle to hit [H.p_them()] right in the face!</span>", \
						  "<span class='userdanger'>You step on [src] causing the handle to hit you right in the face!</span>")

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

/obj/item/hatchet/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 70, 100)

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is chopping at [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
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

/obj/item/scythe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 90, 105)

/obj/item/scythe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beheading [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
		if(BP)
			BP.drop_limb()
			playsound(src, "desecration" ,50, TRUE, -1)
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
	material_flags = MATERIAL_NO_EFFECTS
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

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize()
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
