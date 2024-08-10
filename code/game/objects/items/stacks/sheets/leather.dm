/obj/item/stack/sheet/animalhide
	name = "hide"
	desc = "Something went wrong."
	icon_state = "sheet-hide"
	inhand_icon_state = null
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/animalhide
	pickup_sound = 'sound/items/skin_pick_up.ogg'
	drop_sound = 'sound/items/skin_drop.ogg'

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	novariants = FALSE
	merge_type = /obj/item/stack/sheet/animalhide/human

GLOBAL_LIST_INIT(human_recipes, list( \
	new/datum/stack_recipe("bloated human costume", /obj/item/clothing/suit/hooded/bloated_human, 5, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("human skin hat", /obj/item/clothing/head/fedora/human_leather, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/obj/item/stack/sheet/animalhide/human/get_main_recipes()
	. = ..()
	. += GLOB.human_recipes

/obj/item/stack/sheet/animalhide/human/five
	amount = 5

/obj/item/stack/sheet/animalhide/generic
	name = "skin"
	desc = "A piece of skin."
	singular_name = "skin piece"
	novariants = FALSE
	merge_type = /obj/item/stack/sheet/animalhide/generic

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/corgi

/obj/item/stack/sheet/animalhide/corgi/five
	amount = 5

/obj/item/stack/sheet/animalhide/mothroach
	name = "mothroach hide"
	desc = "A thin layer of mothroach hide."
	singular_name = "mothroach hide piece"
	icon_state = "sheet-mothroach"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/mothroach

/obj/item/stack/sheet/animalhide/mothroach/five
	amount = 5

GLOBAL_LIST_INIT(gondola_recipes, list ( \
	new/datum/stack_recipe("gondola mask", /obj/item/clothing/mask/gondola, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("gondola suit", /obj/item/clothing/under/costume/gondola, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("gondola bedsheet", /obj/item/bedsheet/gondola, 1, crafting_flags = NONE, category = CAT_FURNITURE), \
	))

/obj/item/stack/sheet/animalhide/gondola
	name = "gondola hide"
	desc = "The extremely valuable product of gondola hunting."
	singular_name = "gondola hide piece"
	icon_state = "sheet-gondola"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/gondola

/obj/item/stack/sheet/animalhide/gondola/get_main_recipes()
	. = ..()
	. += GLOB.gondola_recipes

GLOBAL_LIST_INIT(corgi_recipes, list ( \
	new/datum/stack_recipe("corgi costume", /obj/item/clothing/suit/hooded/ian_costume, 3, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/obj/item/stack/sheet/animalhide/corgi/get_main_recipes()
	. = ..()
	. += GLOB.corgi_recipes

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/cat

/obj/item/stack/sheet/animalhide/cat/five
	amount = 5

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/monkey

GLOBAL_LIST_INIT(monkey_recipes, list ( \
	new/datum/stack_recipe("monkey mask", /obj/item/clothing/mask/gas/monkeymask, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("monkey suit", /obj/item/clothing/suit/costume/monkeysuit, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/obj/item/stack/sheet/animalhide/monkey/get_main_recipes()
	. = ..()
	. += GLOB.monkey_recipes

/obj/item/stack/sheet/animalhide/monkey/five
	amount = 5

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/lizard

/obj/item/stack/sheet/animalhide/lizard/five
	amount = 5

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/xeno

GLOBAL_LIST_INIT(xeno_recipes, list ( \
	new/datum/stack_recipe("alien helmet", /obj/item/clothing/head/costume/xenos, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("alien suit", /obj/item/clothing/suit/costume/xenos, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/obj/item/stack/sheet/animalhide/xeno/get_main_recipes()
	. = ..()
	. += GLOB.xeno_recipes

/obj/item/stack/sheet/animalhide/xeno/five
	amount = 5

/obj/item/stack/sheet/animalhide/carp
	name = "carp scales"
	desc = "The scaly skin of a space carp. It looks quite beatiful when detached from the foul creature who once wore it."
	singular_name = "carp scale"
	icon_state = "sheet-carp"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/carp

GLOBAL_LIST_INIT(carp_recipes, list ( \
	new/datum/stack_recipe("carp costume", /obj/item/clothing/suit/hooded/carp_costume, 4, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("carp mask", /obj/item/clothing/mask/gas/carp, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("carpskin chair", /obj/structure/chair/comfy/carp, 2, crafting_flags = NONE, category = CAT_FURNITURE), \
	new/datum/stack_recipe("carpskin suit", /obj/item/clothing/under/suit/carpskin, 3, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("carpskin fedora", /obj/item/clothing/head/fedora/carpskin, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/obj/item/stack/sheet/animalhide/carp/get_main_recipes()
	. = ..()
	. += GLOB.carp_recipes

/obj/item/stack/sheet/animalhide/carp/five
	amount = 5

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	icon_state = "chitin"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/xenochitin

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	icon_state = "claw"

/*
 * Leather SHeet
 */
/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon_state = "sheet-leather"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/leather
	pickup_sound = 'sound/items/skin_pick_up.ogg'
	drop_sound = 'sound/items/skin_drop.ogg'

GLOBAL_LIST_INIT(leather_recipes, list ( \
	new/datum/stack_recipe("wallet", /obj/item/storage/wallet, 1, crafting_flags = NONE, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("muzzle", /obj/item/clothing/mask/muzzle, 2, crafting_flags = NONE, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("basketball", /obj/item/toy/basketball, 20, crafting_flags = NONE, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("baseball", /obj/item/toy/beach_ball/baseball, 3, crafting_flags = NONE, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("saddle", /obj/item/goliath_saddle, 5, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("leather shoes", /obj/item/clothing/shoes/laceup, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("cowboy boots", /obj/item/clothing/shoes/cowboy, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("botany gloves", /obj/item/clothing/gloves/botanic_leather, 3, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("leather satchel", /obj/item/storage/backpack/satchel/leather, 5, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("sheriff vest", /obj/item/clothing/accessory/vest_sheriff, 4, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("leather jacket", /obj/item/clothing/suit/jacket/leather, 7, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("biker jacket", /obj/item/clothing/suit/jacket/leather/biker, 7, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe_list("belts", list( \
		new/datum/stack_recipe("tool belt", /obj/item/storage/belt/utility, 4, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("botanical belt", /obj/item/storage/belt/plant, 2, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("janitorial belt", /obj/item/storage/belt/janitor, 2, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("medical belt", /obj/item/storage/belt/medical, 2, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("security belt", /obj/item/storage/belt/security, 2, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("shoulder holster", /obj/item/storage/belt/holster, 3, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("bandolier", /obj/item/storage/belt/bandolier, 5, crafting_flags = NONE, category = CAT_CONTAINERS), \
	)),
	new/datum/stack_recipe_list("cowboy hats", list( \
		new/datum/stack_recipe("sheriff hat", /obj/item/clothing/head/cowboy/brown, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
		new/datum/stack_recipe("desperado hat", /obj/item/clothing/head/cowboy/black, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
		new/datum/stack_recipe("ten-gallon hat", /obj/item/clothing/head/cowboy/white, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
		new/datum/stack_recipe("deputy hat", /obj/item/clothing/head/cowboy/red, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
		new/datum/stack_recipe("drifter hat", /obj/item/clothing/head/cowboy/grey, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	)),
))

/obj/item/stack/sheet/leather/get_main_recipes()
	. = ..()
	. += GLOB.leather_recipes

/obj/item/stack/sheet/leather/five
	amount = 5

/*
 * Sinew
 */
/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/mining.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/sinew

/obj/item/stack/sheet/sinew/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()

	// As bone and sinew have just a little too many recipes for this, we'll just split them up.
	// Sinew slapcrafting will mostly-sinew recipes, and bones will have mostly-bones recipes.
	var/static/list/slapcraft_recipe_list = list(\
		/datum/crafting_recipe/goliathcloak, /datum/crafting_recipe/skilt, /datum/crafting_recipe/drakecloak,\
		)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/stack/sheet/sinew/wolf
	name = "wolf sinew"
	desc = "Long stringy filaments which came from the insides of a wolf."
	singular_name = "wolf sinew"
	merge_type = /obj/item/stack/sheet/sinew/wolf

GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/restraints/handcuffs/cable/sinew, 1, crafting_flags = NONE, category = CAT_EQUIPMENT), \
))

/obj/item/stack/sheet/sinew/get_main_recipes()
	. = ..()
	. += GLOB.sinew_recipes


/*Plates*/
/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "goliath_hide"
	singular_name = "hide plate"
	max_amount = 6
	novariants = FALSE
	item_flags = NOBLUDGEON
	resistance_flags = FIRE_PROOF
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	merge_type = /obj/item/stack/sheet/animalhide/goliath_hide

/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide
	name = "polar bear hides"
	desc = "Pieces of a polar bear's fur, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon_state = "polar_bear_hide"
	singular_name = "polar bear hide"
	merge_type = /obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide

/obj/item/stack/sheet/animalhide/ashdrake
	name = "ash drake hide"
	desc = "The strong, scaled hide of an ash drake."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "dragon_hide"
	singular_name = "drake plate"
	max_amount = 10
	novariants = FALSE
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	merge_type = /obj/item/stack/sheet/animalhide/ashdrake

/obj/item/stack/sheet/animalhide/ashdrake/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()

	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/drakecloak)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message(span_notice("[user] starts cutting hair off \the [src]."), span_notice("You start cutting the hair off \the [src]..."), span_hear("You hear the sound of a knife rubbing against flesh."))
		if(do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_notice("You cut the hair from [src.name]."))
			new /obj/item/stack/sheet/hairlesshide(user.drop_location(), amount)
			use(amount)
	else
		return ..()

/obj/item/stack/sheet/animalhide/examine(mob/user)
	. = ..()
	. += span_notice("You can remove the hair with any sharp object.")

//Step two - washing..... it's actually in washing machine code.

/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of its hair, but still needs washing and tanning."
	singular_name = "hairless hide piece"
	icon_state = "sheet-hairlesshide"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/hairlesshide

/obj/item/stack/sheet/hairlesshide/examine(mob/user)
	. = ..()
	. += span_notice("You can clean it up by washing in the water.")

//Step three - drying
/obj/item/stack/sheet/wethide
	name = "wet hide"
	desc = "This hide has been cleaned but still needs to be dried."
	singular_name = "wet hide piece"
	icon_state = "sheet-wetleather"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/wethide
	/// Reduced when exposed to high temperatures
	var/wetness = 30
	/// Kelvin to start drying
	var/drying_threshold_temperature = 500

/obj/item/stack/sheet/wethide/examine(mob/user)
	. = ..()
	. += span_notice("You can dry it up to make leather.")

/obj/item/stack/sheet/wethide/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddElement(/datum/element/dryable, /obj/item/stack/sheet/leather)
	AddElement(/datum/element/microwavable, /obj/item/stack/sheet/leather)
	AddComponent(/datum/component/grillable, /obj/item/stack/sheet/leather, rand(1 SECONDS, 3 SECONDS), TRUE)
	AddComponent(/datum/component/bakeable, /obj/item/stack/sheet/leather, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/stack/sheet/wethide/burn()
	visible_message(span_notice("[src] dries up!"))
	new /obj/item/stack/sheet/leather(loc, amount) // all the sheets to incentivize not losing your whole stack by accident
	qdel(src)

/obj/item/stack/sheet/wethide/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > drying_threshold_temperature)

/obj/item/stack/sheet/wethide/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	wetness--
	if(wetness == 0)
		new /obj/item/stack/sheet/leather(drop_location(), amount)
		wetness = initial(wetness)
		use(1)
