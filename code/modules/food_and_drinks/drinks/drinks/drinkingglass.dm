/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	base_icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	fill_icon_thresholds = list(0)
	fill_icon_state = "drinking_glass"
	volume = 50
	custom_materials = list(/datum/material/glass=500)
	max_integrity = 20
	spillable = TRUE
	resistance_flags = ACID_PROOF
	obj_flags = UNIQUE_RENAME
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound = 'sound/items/handling/drinkglass_pickup.ogg'
	custom_price = PAYCHECK_PRISONER

/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change(datum/reagents/holder, ...)
	. = ..()
	if(!length(reagents.reagent_list))
		renamedByPlayer = FALSE //so new drinks can rename the glass

/obj/item/reagent_containers/food/drinks/drinkingglass/update_name(updates)
	if(renamedByPlayer)
		return
	. = ..()
	var/datum/reagent/largest_reagent = reagents.get_master_reagent()
	name = largest_reagent?.glass_name || initial(name)

/obj/item/reagent_containers/food/drinks/drinkingglass/update_desc(updates)
	if(renamedByPlayer)
		return
	. = ..()
	var/datum/reagent/largest_reagent = reagents.get_master_reagent()
	desc = largest_reagent?.glass_desc || initial(desc)

/obj/item/reagent_containers/food/drinks/drinkingglass/update_icon_state()
	if(!reagents.total_volume)
		icon_state = base_icon_state
		return ..()

	var/glass_icon = get_glass_icon(reagents.get_master_reagent())
	if(glass_icon)
		icon_state = glass_icon
		fill_icon_thresholds = null
	else
		//Make sure the fill_icon_thresholds and the icon_state are reset. We'll use reagent overlays.
		fill_icon_thresholds = fill_icon_thresholds || list(1)
		icon_state = base_icon_state
	return ..()

/obj/item/reagent_containers/food/drinks/drinkingglass/proc/get_glass_icon(datum/reagent/largest_reagent)
	return largest_reagent?.glass_icon_state

//Shot glasses!//
//  This lets us add shots in here instead of lumping them in with drinks because >logic  //
//  The format for shots is the exact same as iconstates for the drinking glass, except you use a shot glass instead.  //
//  If it's a new drink, remember to add it to Chemistry-Reagents.dm  and Chemistry-Recipes.dm as well.  //
//  You can only mix the ported-over drinks in shot glasses for now (they'll mix in a shaker, but the sprite won't change for glasses). //
//  This is on a case-by-case basis, and you can even make a separate sprite for shot glasses if you want. //

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "A shot glass - the universal symbol for bad decisions."
	icon_state = "shotglass"
	base_icon_state = "shotglass"
	gulp_size = 15
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list(15)
	fill_icon_state = "shot_glass"
	volume = 15
	custom_materials = list(/datum/material/glass=100)
	custom_price = PAYCHECK_ASSISTANT * 0.4

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/update_name(updates)
	if(renamedByPlayer)
		return
	. = ..()
	name = "[length(reagents.reagent_list) ? "filled " : null]shot glass"

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/update_desc(updates)
	if(renamedByPlayer)
		return
	. = ..()
	if(!length(reagents.reagent_list))
		desc = "A shot glass - the universal symbol for bad decisions."
	else
		desc = "The challenge is not taking as many as you can, but guessing what it is before you pass out."

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/get_glass_icon(datum/reagent/largest_reagent)
	return largest_reagent?.shot_glass_icon_state

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/soda
	name = "Soda Water"
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/cola
	name = "Space Cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola
	name = "Nuka Cola"
	list_reagents = list(/datum/reagent/consumable/nuka_cola = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/egg)) //breaking eggs
		var/obj/item/food/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, span_notice("[src] is full."))
			else
				to_chat(user, span_notice("You break [E] in [src]."))
				reagents.add_reagent(/datum/reagent/consumable/eggyolk, 2)
				reagents.add_reagent(/datum/reagent/consumable/eggwhite, 4)
				qdel(E)
			return
	else
		..()
