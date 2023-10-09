//rim size defines, this is passed into the string for the icon_state of both glasses and garnishes
#define RIM_SMALL "s"
#define RIM_MEDIUM "m"
#define RIM_LARGE "l"

//glass variant defines, if you're adding new glasses make sure to update these
#define SMALL_VARIANTS 6
#define MEDIUM_VARIANTS 13
#define LARGE_VARIANTS 5

//garnish layer defines, higher numbers go above low ones, add more of these if you manage to get sprites that can fit in a new part of the glass
#define GARNISH_RIM 1
#define GARNISH_CENTER 2
#define GARNISH_RIGHT 3
#define GARNISH_LEFT 4
#define GARNISH_MAX 4

//global list for reskinning
GLOBAL_LIST_EMPTY(glass_variants)

//glass that can be reskinned via alt-click, and have garnishes added to its rim
/obj/item/reagent_containers/cup/glass/modglass
	name = "malleable glass"
	desc = "Not your standard drinking glass!"
	icon = 'monkestation/code/modules/modular_bartending/icons/modglass.dmi'
	icon_state = "mglass-1-"
	fill_icon = 'monkestation/code/modules/modular_bartending/icons/modglass_fillings.dmi'
	fill_icon_thresholds = list(50,90)
	amount_per_transfer_from_this = 10
	volume = 50
	custom_materials = list(/datum/material/glass=500, /datum/material/silver=100)
	max_integrity = 30
	spillable = TRUE
	resistance_flags = ACID_PROOF
	obj_flags = UNIQUE_RENAME
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound = 'sound/items/handling/drinkglass_pickup.ogg'
	custom_price = 25
	//rim defines the size of rim the glass has, used to decide which skins are available, and which garnish sprites to use
	var/rim = RIM_MEDIUM
	//stores the number of variations this glass sprite has to select from
	var/variants = MEDIUM_VARIANTS
	//a list to be filled with the associative list containing possible skins
	var/list/glass_skins = list()
	//a list to be filled with the current garnishes placed on the glass
	var/list/garnishes = list()

/obj/item/reagent_containers/cup/glass/modglass/small
	name = "small malleable glass"
	icon_state = "sglass-1-"
	custom_materials = list(/datum/material/glass=100, /datum/material/silver=100)
	volume = 25
	rim = RIM_SMALL
	variants = SMALL_VARIANTS

/obj/item/reagent_containers/cup/glass/modglass/large
	name = "large malleable glass"
	icon_state = "lglass-1-"
	rim = RIM_LARGE
	variants = LARGE_VARIANTS

/obj/item/reagent_containers/cup/glass/modglass/Initialize()
	. = ..()
	if(variants)
		glass_skins = glass_variants_list()

//steals code from tile_reskinning.dm to cache an associative list containing possible reskins of the glass
/obj/item/reagent_containers/cup/glass/modglass/proc/glass_variants_list()
	. = GLOB.glass_variants[rim]
	if(.)
		return
	for(var/variant in 1 to variants)
		var/name_string = "[rim]glass-[variant]-"
		glass_skins[name_string] = icon('monkestation/code/modules/modular_bartending/icons/modglass.dmi', "[name_string]")
	return GLOB.glass_variants[rim] = glass_skins

//if this glass can be reskinned, open a radial menu containing the skins, and change the icon_state to whatever is chosen
/obj/item/reagent_containers/cup/glass/modglass/AltClick(mob/user)
	if(!glass_skins)
		return
	var/choice = show_radial_menu(user, src, glass_skins, radius = 48, require_near = TRUE)
	if(!choice || choice == icon_state)
		return
	icon_state = choice
	update_icon()

//if the object is a garnish, with a valid garnish_state, and there isnt already a garnish of the same type, add it to the list at the index of its layer
/obj/item/reagent_containers/cup/glass/modglass/attackby(obj/item/garnish/garnish, mob/user, params)
	if(!istype(garnish))
		return ..()
	if(!garnish.garnish_state)
		return ..()
	if(garnishes["[garnish.garnish_layer]"])
		to_chat(user, "<span class='notice'>Theres already something on this part of the glass!</span>")
		return ..()
	garnishes["[garnish.garnish_layer]"] = garnish.garnish_state
	update_icon()
	qdel(garnish)

//clear garnishes on wash
/obj/item/reagent_containers/cup/glass/modglass/wash(clean_types)
	. = ..()
	garnishes = list()
	update_icon()

/**
  * for each layer a garnish can be on, if there is a garnish in that layers index, apply a mutable appearance of its type and our rim size
  * if the garnish is a "rim" garnish, it is instead split into two halves, one drawn below all others,
  * and one above all others, allowing garnishes to be placed "inside" the glass
  */
/obj/item/reagent_containers/cup/glass/modglass/update_overlays()
	. = ..()
	var/rimtype = garnishes["1"]
	if(rimtype)
		var/mutable_appearance/rimbottom = mutable_appearance('monkestation/code/modules/modular_bartending/icons/modglass_garnishes.dmi', "[rimtype]-[rim]")
		. += rimbottom
	for(var/i in 2 to GARNISH_MAX)
		var/type = garnishes["[i]"]
		if(type)
			var/mutable_appearance/garnish = mutable_appearance('monkestation/code/modules/modular_bartending/icons/modglass_garnishes.dmi', "[type]-[rim]")
			. += garnish
	if(rimtype)
		var/mutable_appearance/rimtop = mutable_appearance('monkestation/code/modules/modular_bartending/icons/modglass_garnishes.dmi', "[rimtype]-[rim]-top")
		. += rimtop
