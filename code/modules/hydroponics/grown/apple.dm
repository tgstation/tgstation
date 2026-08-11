// Apple
/obj/item/seeds/apple
	name = "apple seed pack"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/food/grown/apple
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/one_bite)
	mutatelist = list(/obj/item/seeds/apple/gold)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/apple
	seed = /obj/item/seeds/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	foodtypes = FRUIT
	tastes = list("apple" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/hcider
	/// Do we know about the worm?
	var/found_worm = FALSE
	/// The worm in question
	var/obj/item/food/bait/worm/appleworm
	/// Chance for a worm
	var/worm_chance

/obj/item/food/grown/apple/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PLANT_ON_HARVEST, PROC_REF(try_make_wormy))

/obj/item/food/grown/apple/proc/try_make_wormy(datum/source, obj/item/seeds/our_seed)
	SIGNAL_HANDLER

	if(our_seed)
		var/obj/machinery/hydroponics/tray = our_seed.loc
		worm_chance = tray.pestlevel // max 10%

	if(prob(worm_chance))
		appleworm = new(src) // There is a worm in this apple!
		tastes = list("apple" = 1, "worms" = 2)
		var/datum/component/edible/ediblecomponent = IS_EDIBLE(src)
		if(ediblecomponent)
			ediblecomponent.foodtypes |= (GROSS | MEAT | BUGS)
		return

/obj/item/food/grown/apple/examine(mob/user)
	. = ..()
	if(!found_worm && !isobserver(user) && appleworm)
		balloon_alert(user, "there is a hole in this [src.name]!")
		found_worm = TRUE
		desc = "It's a little piece of Eden. Serpent not included, contains a worm as a replacement."
		return

/obj/item/food/grown/apple/attack_self(mob/user)
	if(appleworm)
		balloon_alert(user, "pulling out [appleworm.name]...")
		if(!do_after(user, 5 SECONDS, target = src))
			return
		appleworm.forceMove(drop_location())
		appleworm = null
		tastes = list("apple" = 1)
		var/datum/component/edible/ediblecomponent = IS_EDIBLE(src)
		if(ediblecomponent)
			ediblecomponent.foodtypes &= ~(GROSS | MEAT | BUGS)
		desc = "It's a little piece of Eden. The [pick("serpent", "worm", "extra protein", "friendly neighbor")] is gone."
		return

/obj/item/food/grown/apple/proc/on_consume(mob/living/eater)
	if(ishuman(eater))
		to_chat(eater, span_alert("That apple was wormy!"))
		return

/obj/item/food/grown/apple/juice_typepath()
	return /datum/reagent/consumable/applejuice

/obj/item/food/grown/apple/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/appleslice, 5, 20, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/grown/apple/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if (.) //it's been caught.
		return
	if (!ishuman(hit_atom))
		return
	var/mob/living/carbon/human/einstein = hit_atom
	var/obj/item/organ/liver/liver_organ = einstein.get_organ_slot(ORGAN_SLOT_LIVER)
	if (isnull(liver_organ))
		return
	if (HAS_TRAIT(liver_organ, TRAIT_MEDICAL_METABOLISM))
		einstein.apply_damage(2, BRUTE, throwingdatum.target_zone)
	else if (HAS_TRAIT(liver_organ, TRAIT_SCIENTIST_LIVER) && throwingdatum.target_zone == BODY_ZONE_HEAD && prob(2))
		gravity_reminder(einstein)

/obj/item/food/grown/apple/onZImpact(turf/impacted_turf, levels, impact_flags)
	. = ..()
	var/mob/living/carbon/human/einstein = locate(/mob/living/carbon/human) in impacted_turf
	if (isnull(einstein))
		return
	var/obj/item/organ/liver/liver_organ = einstein.get_organ_slot(ORGAN_SLOT_LIVER)
	if (liver_organ && HAS_TRAIT(liver_organ, TRAIT_SCIENTIST_LIVER) && prob(40))
		gravity_reminder(einstein)

/// Provide an important insight
/obj/item/food/grown/apple/proc/gravity_reminder(mob/living/einstein)
	einstein.do_alert_animation()
	playsound(einstein, 'sound/machines/chime.ogg', 50, TRUE)
	einstein.say(pick_list_replacements(VISTA_FILE, "ballmer_good_msg"), forced = "apple inspiration")

// Gold Apple
/obj/item/seeds/apple/gold
	name = "golden apple seed pack"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/food/grown/apple/gold
	maturation = 10
	production = 10
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/gold = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 40 // Alchemy!

/obj/item/food/grown/apple/gold/make_processable()
	return // You're going to break your knife!

/obj/item/food/grown/apple/gold
	seed = /obj/item/seeds/apple/gold
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	distill_reagent = null
	wine_power = 50
