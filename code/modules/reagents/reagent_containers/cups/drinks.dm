////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/cup/glass
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks/drinks.dmi'
	icon_state = "glass_empty"
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	resistance_flags = NONE

	isGlass = TRUE


/obj/item/reagent_containers/cup/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = TRUE)
	. = ..()
	if(!.) //if the bottle wasn't caught
		var/mob/thrower = throwingdatum?.get_thrower()
		smash(hit_atom, thrower, TRUE)

/obj/item/reagent_containers/cup/glass/proc/smash(atom/target, mob/thrower, ranged = FALSE, break_top = FALSE)
	if(!isGlass)
		return
	if(QDELING(src) || !target) //Invalid loc
		return
	if(bartender_check(target) && ranged)
		return
	SplashReagents(target, ranged, override_spillable = TRUE)
	var/obj/item/broken_bottle/B = new (loc)
	B.mimic_broken(src, target, break_top)
	qdel(src)
	target.Bumped(B)

/obj/item/reagent_containers/cup/glass/bullet_act(obj/projectile/P)
	. = ..()
	if(QDELETED(src))
		return
	if(P.damage > 0 && P.damage_type == BRUTE)
		var/atom/T = get_turf(src)
		smash(T)


/obj/item/reagent_containers/cup/glass/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "pewter_cup"
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT)
	has_variable_transfer_amount = FALSE
	volume = 5
	obj_flags = CONDUCTS_ELECTRICITY
	spillable = TRUE
	resistance_flags = FIRE_PROOF
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "golden_cup"
	inhand_icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	custom_materials = list(/datum/material/gold=HALF_SHEET_MATERIAL_AMOUNT)
	volume = 150

/obj/item/reagent_containers/cup/glass/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	custom_materials = list(/datum/material/silver=SMALL_MATERIAL_AMOUNT*8)
	volume = 100


/obj/item/reagent_containers/cup/glass/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 4)
	volume = 25

///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
// rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
// Formatting is the same as food.

/obj/item/reagent_containers/cup/glass/coffee
	name = "robust coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "coffee"
	base_icon_state = "coffee"
	list_reagents = list(/datum/reagent/consumable/coffee = 30)
	spillable = TRUE
	resistance_flags = FREEZE_PROOF
	isGlass = FALSE
	drink_type = BREAKFAST
	var/lid_open = 0

/obj/item/reagent_containers/cup/glass/coffee/no_lid
	icon_state = "coffee_empty"
	list_reagents = null

/obj/item/reagent_containers/cup/glass/coffee/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to toggle cup lid.")
	return

/obj/item/reagent_containers/cup/glass/coffee/click_alt(mob/user)
	lid_open = !lid_open
	update_icon_state()
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/glass/coffee/update_icon_state()
	if(lid_open)
		icon_state = reagents.total_volume ? "[base_icon_state]_full" : "[base_icon_state]_empty"
	else
		icon_state = base_icon_state
	return ..()

/obj/item/reagent_containers/cup/glass/ice
	name = "ice cup"
	desc = "Careful, cold ice, do not chew."
	custom_price = PAYCHECK_LOWER * 0.6
	icon_state = "icecup"
	list_reagents = list(/datum/reagent/consumable/ice = 30)
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/ice/prison
	name = "dirty ice cup"
	desc = "Either Nanotrasen's water supply is contaminated, or this machine actually vends lemon, chocolate, and cherry snow cones."
	list_reagents = list(/datum/reagent/consumable/ice = 25, /datum/reagent/consumable/liquidgibs = 5)

/obj/item/reagent_containers/cup/glass/mug // parent type is literally just so empty mug sprites are a thing
	name = "mug"
	desc = "A drink served in a classy mug."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "tea_empty"
	base_icon_state = "tea"
	inhand_icon_state = "coffee"
	spillable = TRUE

/obj/item/reagent_containers/cup/glass/mug/update_icon_state()
	icon_state = "[base_icon_state][reagents.total_volume ? null : "_empty"]"
	return ..()

/obj/item/reagent_containers/cup/glass/mug/tea
	name = "Duke Purple tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "tea"
	list_reagents = list(/datum/reagent/consumable/tea = 30)

/obj/item/reagent_containers/cup/glass/mug/coco
	name = "Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "tea"
	list_reagents = list(/datum/reagent/consumable/hot_coco = 15, /datum/reagent/consumable/sugar = 5)
	drink_type = SUGAR
	resistance_flags = FREEZE_PROOF
	custom_price = PAYCHECK_CREW * 1.2

/obj/item/reagent_containers/cup/glass/mug/nanotrasen
	name = "\improper Nanotrasen mug"
	desc = "A mug to display your corporate pride."
	icon_state = "mug_nt_empty"
	base_icon_state = "mug_nt"

/obj/item/reagent_containers/cup/glass/coffee_cup
	name = "coffee cup"
	desc = "A heat-formed plastic coffee cup. Can theoretically be used for other hot drinks, if you're feeling adventurous."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "coffee_cup_e"
	base_icon_state = "coffee_cup"
	possible_transfer_amounts = list(10)
	volume = 30
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/coffee_cup/update_icon_state()
	icon_state = reagents.total_volume ? base_icon_state : "[base_icon_state]_e"
	return ..()

/obj/item/reagent_containers/cup/glass/dry_ramen
	name = "cup ramen"
	desc = "Just add 5ml of water, self heats! A taste that reminds you of your school years. Now new with salty flavour!"
	icon_state = "ramen"
	list_reagents = list(/datum/reagent/consumable/dry_ramen = 15, /datum/reagent/consumable/salt = 3)
	drink_type = GRAIN
	isGlass = FALSE
	custom_price = PAYCHECK_CREW * 0.9

/obj/item/reagent_containers/cup/glass/waterbottle
	name = "bottle of water"
	desc = "A bottle of water filled at an old Earth bottling facility."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "smallbottle"
	inhand_icon_state = null
	list_reagents = list(/datum/reagent/water = 49.5, /datum/reagent/fluorine = 0.5)//see desc, don't think about it too hard
	custom_materials = list(/datum/material/plastic=HALF_SHEET_MATERIAL_AMOUNT)
	volume = 50
	amount_per_transfer_from_this = 10
	fill_icon_thresholds = list(0, 10, 25, 50, 75, 80, 90)
	isGlass = FALSE
	// The 2 bottles have separate cap overlay icons because if the bottle falls over while bottle flipping the cap stays fucked on the moved overlay
	var/cap_icon = 'icons/obj/drinks/drink_effects.dmi'
	var/cap_icon_state = "bottle_cap_small"
	var/cap_on = TRUE
	var/cap_lost = FALSE
	var/mutable_appearance/cap_overlay
	var/flip_chance = 10
	custom_price = PAYCHECK_LOWER * 0.8

/obj/item/reagent_containers/cup/glass/waterbottle/Initialize(mapload)
	cap_overlay = mutable_appearance(cap_icon, cap_icon_state)
	. = ..()
	if(cap_on)
		spillable = FALSE
		update_appearance()

/obj/item/reagent_containers/cup/glass/waterbottle/update_overlays()
	. = ..()
	if(cap_on)
		. += cap_overlay

/obj/item/reagent_containers/cup/glass/waterbottle/examine(mob/user)
	. = ..()
	if(cap_lost)
		. += span_notice("The cap seems to be missing.")
	else if(cap_on)
		. += span_notice("The cap is firmly on to prevent spilling. Alt-click to remove the cap.")
	else
		. += span_notice("The cap has been taken off. Alt-click to put a cap on.")

/obj/item/reagent_containers/cup/glass/waterbottle/click_alt(mob/user)
	if(cap_lost)
		to_chat(user, span_warning("The cap seems to be missing! Where did it go?"))
		return CLICK_ACTION_BLOCKING

	var/fumbled = HAS_TRAIT(user, TRAIT_CLUMSY) && prob(5)
	if(cap_on || fumbled)
		cap_on = FALSE
		spillable = TRUE
		animate(src, transform = null, time = 2, loop = 0)
		if(fumbled)
			to_chat(user, span_warning("You fumble with [src]'s cap! The cap falls onto the ground and simply vanishes. Where the hell did it go?"))
			cap_lost = TRUE
		else
			to_chat(user, span_notice("You remove the cap from [src]."))
			playsound(loc, 'sound/effects/can_open1.ogg', 50, TRUE)
	else
		cap_on = TRUE
		spillable = FALSE
		to_chat(user, span_notice("You put the cap on [src]."))
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/glass/waterbottle/is_refillable()
	if(cap_on)
		return FALSE
	return ..()

/obj/item/reagent_containers/cup/glass/waterbottle/is_drainable()
	if(cap_on)
		return FALSE
	return ..()

/obj/item/reagent_containers/cup/glass/waterbottle/attack(mob/target, mob/living/user, def_zone)
	if(!target)
		return

	if(cap_on && reagents.total_volume && istype(target))
		to_chat(user, span_warning("You must remove the cap before you can do that!"))
		return

	return ..()

/obj/item/reagent_containers/cup/glass/waterbottle/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(cap_on && (target.is_refillable() || target.is_drainable() || (reagents.total_volume && !user.combat_mode)))
		to_chat(user, span_warning("You must remove the cap before you can do that!"))
		return ITEM_INTERACT_BLOCKING

	if(istype(target, /obj/item/reagent_containers/cup/glass/waterbottle))
		var/obj/item/reagent_containers/cup/glass/waterbottle/other_bottle = target
		if(other_bottle.cap_on)
			to_chat(user, span_warning("[other_bottle] has a cap firmly twisted on!"))
			return ITEM_INTERACT_BLOCKING

	return ..()

// heehoo bottle flipping
/obj/item/reagent_containers/cup/glass/waterbottle/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(QDELETED(src))
		return
	if(!cap_on || !reagents.total_volume)
		return
	if(prob(flip_chance)) // landed upright
		src.visible_message(span_notice("[src] lands upright!"))
		var/mob/living/thrower = throwingdatum?.get_thrower()
		if(thrower)
			thrower.add_mood_event("bottle_flip", /datum/mood_event/bottle_flip)
	else // landed on it's side
		animate(src, transform = matrix(prob(50)? 90 : -90, MATRIX_ROTATE), time = 3, loop = 0)

/obj/item/reagent_containers/cup/glass/waterbottle/pickup(mob/user)
	. = ..()
	animate(src, transform = null, time = 1, loop = 0)

/obj/item/reagent_containers/cup/glass/waterbottle/empty
	list_reagents = list()
	cap_on = FALSE

/obj/item/reagent_containers/cup/glass/waterbottle/large
	desc = "A fresh commercial-sized bottle of water."
	icon_state = "largebottle"
	custom_materials = list(/datum/material/plastic=SHEET_MATERIAL_AMOUNT * 1.5)
	list_reagents = list(/datum/reagent/water = 100)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)
	cap_icon_state = "bottle_cap"

/obj/item/reagent_containers/cup/glass/waterbottle/large/empty
	list_reagents = list()
	cap_on = FALSE

// Admin spawn
/obj/item/reagent_containers/cup/glass/waterbottle/relic
	name = "mysterious bottle"
	desc = "A bottle quite similar to a water bottle, but with some words scribbled on with a marker. It seems to be radiating some kind of energy."
	flip_chance = 100 // FLIPP

/obj/item/reagent_containers/cup/glass/waterbottle/relic/Initialize(mapload)
	var/reagent_id = get_random_reagent_id()
	var/datum/reagent/random_reagent = new reagent_id
	list_reagents = list(random_reagent.type = 50)
	. = ..()
	desc += span_notice("The writing reads '[random_reagent.name]'.")
	update_appearance()


/obj/item/reagent_containers/cup/glass/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = list(10)
	volume = 10
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/sillycup/update_icon_state()
	icon_state = reagents.total_volume ? "water_cup" : "water_cup_e"
	return ..()

/obj/item/reagent_containers/cup/glass/bottle/juice/smallcarton
	name = "small carton"
	desc = "A small carton, intended for holding drinks."
	icon = 'icons/obj/drinks/boxes.dmi'
	icon_state = "juicebox"
	volume = 15
	drink_type = NONE

/obj/item/reagent_containers/cup/glass/bottle/juice/smallcarton/Initialize(mapload, vol)
	. = ..()
	AddComponent( \
		/datum/component/takes_reagent_appearance, \
		on_icon_changed = CALLBACK(src, PROC_REF(on_cup_change)), \
		on_icon_reset = CALLBACK(src, PROC_REF(on_cup_reset)), \
		base_container_type = /obj/item/reagent_containers/cup/glass/bottle/juice/smallcarton, \
	)

/obj/item/reagent_containers/cup/glass/bottle/juice/smallcarton/smash(atom/target, mob/thrower, ranged = FALSE)
	if(bartender_check(target) && ranged)
		return
	SplashReagents(target, ranged, override_spillable = TRUE)
	var/obj/item/broken_bottle/bottle_shard = new (loc)
	bottle_shard.mimic_broken(src, target)
	qdel(src)
	target.Bumped(bottle_shard)

/obj/item/reagent_containers/cup/glass/colocup
	name = "colo cup"
	desc = "A cheap, mass produced style of cup, typically used at parties. They never seem to come out red, for some reason..."
	icon = 'icons/obj/drinks/colo.dmi'
	icon_state = "colocup"
	inhand_icon_state = "colocup"
	custom_materials = list(/datum/material/plastic =HALF_SHEET_MATERIAL_AMOUNT)
	possible_transfer_amounts = list(5, 10, 15, 20)
	volume = 20
	amount_per_transfer_from_this = 5
	isGlass = FALSE
	/// Allows the lean sprite to display upon crafting
	var/random_sprite = TRUE

/obj/item/reagent_containers/cup/glass/colocup/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	if(!random_sprite)
		return
	icon_state = "colocup[rand(0, 6)]"
	if(icon_state == "colocup6")
		desc = "A cheap, mass produced style of cup, typically used at parties. Woah, this one is in red! What the hell?"

//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
// itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
// icon states.


/obj/item/reagent_containers/cup/glass/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "shaker"
	custom_materials = list(/datum/material/iron= HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	amount_per_transfer_from_this = 10
	volume = 100
	isGlass = FALSE
	interaction_flags_click = NEED_HANDS|FORBID_TELEKINESIS_REACH
	/// Whether or not poured drinks should use custom names and descriptions
	var/using_custom_drinks = FALSE
	/// Name custom drinks will have
	var/custom_drink_name = "Custom drink"
	/// Description custom drinks will have
	var/custom_drink_desc = "Mixed by your favourite bartender!"

/obj/item/reagent_containers/cup/glass/shaker/Initialize(mapload)
	. = ..()
	register_context()
	if(prob(10))
		name = "\improper Nanotrasen 20th Anniversary Shaker"
		desc += " It has an emblazoned Nanotrasen logo on it."
		icon_state = "shaker_n"

/obj/item/reagent_containers/cup/glass/shaker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "[using_custom_drinks ? "Disable" : "Enable"] custom drinks"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/reagent_containers/cup/glass/shaker/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to [using_custom_drinks ? "disable" : "enable"] custom drink naming")
	if(using_custom_drinks)
		. += span_notice("Drinks poured from this shaker will have the following name: [custom_drink_name]")
		. += span_notice("Drinks poured from this shaker will have the following description: [custom_drink_desc]")

/obj/item/reagent_containers/cup/glass/shaker/click_alt(mob/user)
	if(using_custom_drinks)
		using_custom_drinks = FALSE
		disable_custom_drinks()
		balloon_alert(user, "custom drinks disabled")
		return CLICK_ACTION_BLOCKING

	var/new_name = reject_bad_text(tgui_input_text(user, "Drink name", "Set drink name", custom_drink_name, 45, FALSE), 64)
	if(!new_name)
		balloon_alert(user, "invalid drink name!")
		using_custom_drinks = FALSE
		return CLICK_ACTION_BLOCKING

	if(!user.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING

	var/new_desc = reject_bad_text(tgui_input_text(user, "Drink description", "Set drink description", custom_drink_desc, 64, TRUE), 128)
	if(!new_desc)
		balloon_alert(user, "invalid drink description!")
		using_custom_drinks = FALSE
		return CLICK_ACTION_BLOCKING

	if(!user.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING

	using_custom_drinks = TRUE
	custom_drink_name = new_name
	custom_drink_desc = new_desc

	enable_custom_drinks()
	balloon_alert(user, "now pouring custom drinks")
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/glass/shaker/proc/enable_custom_drinks()
	RegisterSignal(src, COMSIG_REAGENTS_CUP_TRANSFER_TO, PROC_REF(handle_transfer))

/obj/item/reagent_containers/cup/glass/shaker/proc/disable_custom_drinks()
	UnregisterSignal(src, COMSIG_REAGENTS_CUP_TRANSFER_TO)

/obj/item/reagent_containers/cup/glass/shaker/proc/handle_transfer(atom/origin, atom/target)
	SIGNAL_HANDLER
	// Should only work on drinking/shot glasses
	if(!istype(target, /obj/item/reagent_containers/cup/glass/drinkingglass))
		return

	var/obj/item/reagent_containers/cup/glass/drinkingglass/target_glass = target
	target_glass.name = custom_drink_name
	target_glass.desc = custom_drink_desc
	ADD_TRAIT(target_glass, TRAIT_WAS_RENAMED, SHAKER_LABEL_TRAIT)

/obj/item/reagent_containers/cup/glass/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	custom_price = PAYCHECK_COMMAND * 2
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "flask"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2.5)
	volume = 60
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/flask/gold
	name = "captain's flask"
	desc = "A gold flask belonging to the captain."
	icon_state = "flask_gold"
	custom_materials = list(/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)

/obj/item/reagent_containers/cup/glass/flask/det
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 30)

/obj/item/reagent_containers/cup/glass/flask/det/minor
	list_reagents = list(/datum/reagent/consumable/applejuice = 30)

/obj/item/reagent_containers/cup/glass/mug/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "britcup_empty"
	base_icon_state = "britcup"
	volume = 30
	spillable = TRUE
