#define SCOOP_OFFSET 4
#define SUGAR_PER_SCOOP 10
#define EXTRA_MAX_VOLUME_PER_SCOOP 20

/**
  * Don't make subtypes off of this instead of [/datum/ice_cream_flavour]. It supports both cones and scoop flavours
  * so you have no excuses (unless you know what you are doing; be my guest if you plan to add whipped cream, wafers or jimmies).
  */
/obj/item/food/icecream
	name = "ice cream cone"
	desc = "Placeholder text for an ice cream cone filled with the dimwittedness of those who dared to code but couldn't."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cone_waffle" //default for admin-spawned cones, href_list["cone"] should overwrite this all the time
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("cream" = 2, "waffle" = 1)
	bite_consumption = 4
	foodtypes = DAIRY | SUGAR
	max_volume = 10 //The max volumes scales up with the number of scoops.
	/// List of scoops of icecream that fill this cone. Key value is the overlay, assoc is the name.
	var/list/scoops
	/// Scoops with custom names that still require their generic names (stored as assoc values) to access the flavour datum.
	var/list/special_scoops
	var/cone_name = ICE_CREAM_CONE_WAFFLE

/obj/item/food/icecream/Initialize(mapload, cone_name = ICE_CREAM_CONE_WAFFLE)
	. = ..()
	GLOB.ice_cream_cones[cone_name].add_flavour(src)

/obj/item/food/icecream/update_desc(updates)
	if(renamedByPlayer)
		return
	. = ..()
	var/scoops_len = length(scoops)
	if(!scoops_len)
		var/datum/ice_cream_flavour/cone = GLOB.ice_cream_cones[cone_name]
		if(cone)
			desc = replacetext(cone.desc, "$CONE_NAME", cone_name)
	else if(scoops_len == 1 || length(uniqueList(scoops)) == 1)
		var/key = scoops[1]
		var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[LAZYACCESS(special_scoops, key) || key]
		if(!flavour?.desc) //I scream.
			desc = initial(desc)
		else
			desc = replacetext(replacetext(flavour.desc, "$CONE_NAME", cone_name), "$CUSTOM_NAME", key)
	else
		desc = "A delicious [cone_name] filled with scoops of [english_list(scoops)] icecream. That's as many as [length(scoops)] scoops!"

/obj/item/food/icecream/update_name(updates)
	if(renamedByPlayer)
		return
	. = ..()
	var/scoops_len = length(scoops)
	if(!scoops_len)
		name = cone_name
	else
		if(scoops_len > 1 && length(uniqueList(scoops)) == 1) // multiple flavours, and all of the same type
			name = "[make_tuple(scoops_len)] [scoops[1]] ice cream" // "double vanilla" sounds cooler than "vanilla and vanilla"
		else
			name = "[english_list(scoops)] ice cream"

/obj/item/food/icecream/update_icon_state()
	. = ..()
	var/datum/ice_cream_flavour/cone = GLOB.ice_cream_cones[cone_name]
	if(cone)
		icon_state = cone.icon_state

/obj/item/food/icecream/update_overlays()
	. = ..()
	var/offset = 0
	for(var/i in 1 to length(scoops))
		var/scoop = scoops[i]
		var/mutable_appearance/scoop_overlay = scoops[scoop]
		if(!istype(scoop_overlay))
			scoop_overlay = mutable_appearance('icons/obj/kitchen.dmi', scoop_overlay)
		scoop_overlay.pixel_y = offset
		. += scoop_overlay
		offset += SCOOP_OFFSET

/////ICE CREAM FLAVOUR DATUM

GLOBAL_LIST_EMPTY_TYPED(ice_cream_cones, /datum/ice_cream_flavour)
GLOBAL_LIST_INIT_TYPED(ice_cream_flavours, /datum/ice_cream_flavour, init_ice_cream_flavours())

/proc/init_ice_cream_flavours()
	. = list()
	for(var/datum/ice_cream_flavour/flavour as anything in subtypesof(/datum/ice_cream_flavour))
		flavour = new flavour
		if(flavour.is_a_cone)
			GLOB.ice_cream_cones[flavour.name] = flavour
		else
			.[flavour.name] = flavour

/**
  * The ice cream datums. What makes these digital frozen snacks so yummy.
  * They are singletons, so please bear with me if they feel a little tortous to use at time.
  */
/datum/ice_cream_flavour
	/// Make sure the same name is not found on other types; These are singletons keyed by their name.
	var/name = "Coderlicious Gourmet Double Deluxe Undefined"
	/// The icon state of the flavour, overlay or not.
	var/icon_state = "icecream_vanilla"
	/**
	  * The description of the food when it contains exactly one scoop of ice cream. Make sure your new subtypes have one.
	  * $CONE_NAME and $CUSTOM_NAME are both placeholder names for
	  * the cone and the custom ice cream respectively, as shown in [/obj/item/food/icecream/update_desc].
	  */
	var/desc = ""
	/// The ingredients required to make one scoop
	var/list/ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/vanilla)
	/// The same as above, but in a readable text generated on spawn that can also contain extra ingredients such as "lot of love" or "optional flavorings".
	var/ingredients_text = ""
	/// reagent added in 'add_flavour'
	var/reagent_type
	/// the amount of reagent added in 'add_flavour'
	var/reagent_amount = 3
	/// Is this shown on the ice cream vat menu or not?
	var/hidden = FALSE
	/// Is it actually an ice cream cone? Makes it possible for cone flavours to be a subtype without overriding too many procs.
	var/is_a_cone = FALSE

/datum/ice_cream_flavour/New()
	if(ingredients)
		var/list/temp_names = list()
		for(var/datum/reagent/R as anything in ingredients)
			temp_names |= initial(R.name)
		if(ingredients_text)
			temp_names += ingredients_text
		ingredients_text = " (Ingredients: [jointext(temp_names, null, ", ", ", ")])"

///Adds a new flavour to the ice cream cone.
/datum/ice_cream_flavour/proc/add_flavour(obj/item/food/icecream/target, datum/reagents/R, custom_name)
	if(reagent_type)
		target.reagents.add_reagent(reagent_type, reagent_amount, reagtemp = T0C)
	if(icon_state && !is_a_cone)
		LAZYADD(target.scoops, custom_name || name)
		target.scoops[custom_name || name] = icon_state
	if(custom_name)
		LAZYSET(target.special_scoops, custom_name, name)
	if(!is_a_cone) // Add some sugar to make it a more substantial snack.
		target.reagents.maximum_volume += EXTRA_MAX_VOLUME_PER_SCOOP
		if(target.reagents.total_volume < length(target.scoops))
			target.reagents.add_reagent(/datum/reagent/consumable/sugar, min(SUGAR_PER_SCOOP, SUGAR_PER_SCOOP - target.reagents.total_volume), reagtemp = T0C)
	target.update_icon()
	target.update_name()
	target.update_desc()
	return TRUE

/////SCOOP AND CONE FLAVOUR SUBTYPES

/datum/ice_cream_flavour/vanilla
	name = ICE_CREAM_VANILLA
	desc = "A delicious $CONE_NAME filled with vanilla ice cream. All the other ice creams take content from it."
	reagent_type = /datum/reagent/consumable/vanilla

/datum/ice_cream_flavour/chocolate
	name = ICE_CREAM_CHOCOLATE
	icon_state = "icecream_chocolate"
	desc = "A delicious $CONE_NAME filled with chocolate ice cream. Surprisingly, made with real cocoa."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/coco)
	reagent_type = /datum/reagent/consumable/coco

/datum/ice_cream_flavour/strawberry
	name = ICE_CREAM_STRAWBERRY
	icon_state = "icecream_strawberry"
	desc = "A delicious $CONE_NAME filled with strawberry ice cream. Definitely not made with real strawberries."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/berryjuice)
	reagent_type = /datum/reagent/consumable/berryjuice

/datum/ice_cream_flavour/blue
	name = ICE_CREAM_BLUE
	icon_state = "icecream_blue"
	desc = "A delicious $CONE_NAME filled with blue ice cream. Made with real... blue?"
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/ethanol/singulo)
	reagent_type = /datum/reagent/consumable/ethanol/singulo

/datum/ice_cream_flavour/mob
	name = ICE_CREAM_MOB
	desc = "A suspicious $CONE_NAME filled with bright red ice cream. That's probably not strawberry..."
	reagent_type = /datum/reagent/liquidgibs
	hidden = TRUE

/datum/ice_cream_flavour/custom
	name = ICE_CREAM_CUSTOM
	icon_state = "" //has its own mutable appearance overlay.
	desc = "A delicious $CONE_NAME cone filled with artisanal icecream. Made with real $CUSTOM_NAME. Ain't that something."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice)
	ingredients_text = "optional flavorings"

/datum/ice_cream_flavour/custom/add_flavour(obj/item/food/icecream/target, datum/reagents/R, custom_name)
	if(!R || R.total_volume < 4) //consumable reagents have stronger taste so higher volume are required to allow non-food flavourings to break through better.
		return GLOB.ice_cream_flavours[ICE_CREAM_BLAND].add_flavour(target) //Bland, sugary ice and milk.
	var/mutable_appearance/flavoring = mutable_appearance('icons/obj/kitchen.dmi', "icecream_custom")
	var/datum/reagent/master = R.get_master_reagent()
	flavoring.color = master.color
	LAZYADDASSOC(target.scoops, master.name, flavoring)
	. = ..() // Make some space for reagents before attempting to transfer some to the target.
	R.trans_to(target, 4)

/datum/ice_cream_flavour/bland
	name = ICE_CREAM_BLAND
	icon_state = "icecream_custom"
	desc = "A delicious $CONE_NAME filled with anemic, flavorless icecream. You wonder why this was ever scooped..."
	hidden = TRUE

/// These are actually cones stored in a different list, but they share many lines of code with scoop flavours, hence the subtype.
/datum/ice_cream_flavour/cone
	/// In order to distinguish them from other flavours, their names should also include " cone".
	name = ICE_CREAM_CONE_WAFFLE
	/// the description that shows up when the ice cream cone is empty.
	desc = "Delicious $CONE_NAME, but no ice cream."
	icon_state = "icecream_cone_waffle"
	ingredients = list(/datum/reagent/consumable/flour, /datum/reagent/consumable/sugar)
	reagent_type = /datum/reagent/consumable/nutriment
	reagent_amount = 1
	is_a_cone = TRUE

/datum/ice_cream_flavour/cone/add_flavour(obj/item/food/icecream/target, datum/reagents/R, custom_name)
	target.cone_name = custom_name || name
	return ..()

/datum/ice_cream_flavour/cone/choco
	name = ICE_CREAM_CONE_CHOCO
	icon_state = "icecream_cone_chocolate"
	ingredients = list(/datum/reagent/consumable/flour, /datum/reagent/consumable/sugar, /datum/reagent/consumable/coco)
	reagent_type = /datum/reagent/consumable/coco

#undef SCOOP_OFFSET
#undef SUGAR_PER_SCOOP
#undef EXTRA_MAX_VOLUME_PER_SCOOP
