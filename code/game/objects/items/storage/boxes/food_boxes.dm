// This contains all boxes with edible stuffs or stuff related to edible stuffs.

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "Instructions: Heat in microwave. Product will stay perpetually warmed with cutting edge Donk Co. technology."
	icon_state = "donkpocketbox"
	illustration = null
	/// What type of donk pocket are we gonna cram into this box?
	var/donktype = /obj/item/food/donkpocket

/obj/item/storage/box/donkpockets/PopulateContents()
	for(var/i in 1 to 6)
		new donktype(src)

/obj/item/storage/box/donkpockets/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(/obj/item/food/donkpocket)

/obj/item/storage/box/donkpockets/donkpocketspicy
	name = "box of spicy-flavoured donk-pockets"
	icon_state = "donkpocketboxspicy"
	donktype = /obj/item/food/donkpocket/spicy

/obj/item/storage/box/donkpockets/donkpocketteriyaki
	name = "box of teriyaki-flavoured donk-pockets"
	icon_state = "donkpocketboxteriyaki"
	donktype = /obj/item/food/donkpocket/teriyaki

/obj/item/storage/box/donkpockets/donkpocketpizza
	name = "box of pizza-flavoured donk-pockets"
	icon_state = "donkpocketboxpizza"
	donktype = /obj/item/food/donkpocket/pizza

/obj/item/storage/box/donkpockets/donkpocketgondola
	name = "box of gondola-flavoured donk-pockets"
	icon_state = "donkpocketboxgondola"
	donktype = /obj/item/food/donkpocket/gondola

/obj/item/storage/box/donkpockets/donkpocketberry
	name = "box of berry-flavoured donk-pockets"
	icon_state = "donkpocketboxberry"
	donktype = /obj/item/food/donkpocket/berry

/obj/item/storage/box/donkpockets/donkpockethonk
	name = "box of banana-flavoured donk-pockets"
	icon_state = "donkpocketboxbanana"
	donktype = /obj/item/food/donkpocket/honk

/obj/item/storage/box/donkpockets/donkpocketshell
	name = "box of Donk Co. 'Donk Spike' flechette shells"
	desc = "Instructions: DO NOT heat in microwave. Product will remove all hostile threats with cutting edge Donk Co. technology."
	icon_state = "donkpocketboxshell"
	donktype = /obj/item/ammo_casing/shotgun/flechette/donk

/obj/item/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon = 'icons/obj/storage/paperbag.dmi'
	icon_state = "paperbag_None"
	inhand_icon_state = null
	illustration = null
	resistance_flags = FLAMMABLE
	foldable_result = null
	/// A list of all available papersack reskins
	var/list/papersack_designs = list()
	///What design from papersack_designs we are currently using.
	var/design_choice = "None"

/obj/item/storage/box/papersack/Initialize(mapload)
	. = ..()
	papersack_designs = sort_list(list(
		"None" = image(icon = src.icon, icon_state = "paperbag_None"),
		"NanotrasenStandard" = image(icon = src.icon, icon_state = "paperbag_NanotrasenStandard"),
		"SyndiSnacks" = image(icon = src.icon, icon_state = "paperbag_SyndiSnacks"),
		"Heart" = image(icon = src.icon, icon_state = "paperbag_Heart"),
		"SmileyFace" = image(icon = src.icon, icon_state = "paperbag_SmileyFace")
		))
	update_appearance()

/obj/item/storage/box/papersack/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, design_choice))
		update_appearance()

/obj/item/storage/box/papersack/update_icon_state()
	icon_state = "paperbag_[design_choice][(contents.len == 0) ? null : "_closed"]"
	return ..()

/obj/item/storage/box/papersack/update_desc(updates)
	switch(design_choice)
		if("None")
			desc = "A sack neatly crafted out of paper."
		if("NanotrasenStandard")
			desc = "A standard Nanotrasen paper lunch sack for loyal employees on the go."
		if("SyndiSnacks")
			desc = "The design on this paper sack is a remnant of the notorious 'SyndieSnacks' program."
		if("Heart")
			desc = "A paper sack with a heart etched onto the side."
		if("SmileyFace")
			desc = "A paper sack with a crude smile etched onto the side."
	return ..()

/obj/item/storage/box/papersack/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(IS_WRITING_UTENSIL(tool))
		var/choice = show_radial_menu(user, src , papersack_designs, custom_check = CALLBACK(src, PROC_REF(check_menu), user, tool), radius = 36, require_near = TRUE)
		if(!choice || choice == design_choice)
			return ITEM_INTERACT_BLOCKING
		design_choice = choice
		balloon_alert(user, "modified")
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	if(tool.get_sharpness() && !contents.len)
		if(design_choice == "None")
			user.show_message(span_notice("You cut eyeholes into [src]."), MSG_VISUAL)
			new /obj/item/clothing/head/costume/papersack(drop_location())
			qdel(src)
			return ITEM_INTERACT_SUCCESS
		else if(design_choice == "SmileyFace")
			user.show_message(span_notice("You cut eyeholes into [src] and modify the design."), MSG_VISUAL)
			new /obj/item/clothing/head/costume/papersack/smiley(drop_location())
			qdel(src)
			return ITEM_INTERACT_SUCCESS
	return ..()

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 * * P The pen used to interact with a menu
 */
/obj/item/storage/box/papersack/proc/check_menu(mob/user, obj/item/pen/P)
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	if(contents.len)
		balloon_alert(user, "items inside!")
		return FALSE
	if(!P || !user.is_holding(P))
		balloon_alert(user, "needs pen!")
		return FALSE
	return TRUE

/obj/item/storage/box/papersack/meat
	desc = "It's slightly moist and smells like a slaughterhouse."

/obj/item/storage/box/papersack/meat/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/food/meat/slab(src)

/obj/item/storage/box/papersack/wheat
	desc = "It's a bit dusty, and smells like a barnyard."

/obj/item/storage/box/papersack/wheat/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/food/grown/wheat(src)

/obj/item/storage/box/ingredients //This box is for the randomly chosen version the chef used to spawn with, it shouldn't actually exist.
	name = "ingredients box"
	illustration = "fruit"
	var/theme_name

/obj/item/storage/box/ingredients/Initialize(mapload)
	. = ..()
	if(theme_name)
		name = "[name] ([theme_name])"
		desc = "A box containing supplementary ingredients for the aspiring chef. The box's theme is '[theme_name]'."
		inhand_icon_state = "syringe_kit"

/obj/item/storage/box/ingredients/wildcard
	theme_name = "wildcard"

/obj/item/storage/box/ingredients/wildcard/PopulateContents()
	for(var/i in 1 to 7)
		var/random_food = pick(
			/obj/item/food/chocolatebar,
			/obj/item/food/grown/apple,
			/obj/item/food/grown/banana,
			/obj/item/food/grown/cabbage,
			/obj/item/food/grown/carrot,
			/obj/item/food/grown/cherries,
			/obj/item/food/grown/chili,
			/obj/item/food/grown/corn,
			/obj/item/food/grown/cucumber,
			/obj/item/food/grown/mushroom/chanterelle,
			/obj/item/food/grown/mushroom/plumphelmet,
			/obj/item/food/grown/potato,
			/obj/item/food/grown/potato/sweet,
			/obj/item/food/grown/soybeans,
			/obj/item/food/grown/tomato,
		)
		new random_food(src)

/obj/item/storage/box/ingredients/fiesta
	theme_name = "fiesta"

/obj/item/storage/box/ingredients/fiesta/PopulateContents()
	new /obj/item/food/tortilla(src)
	for(var/i in 1 to 2)
		new /obj/item/food/grown/chili(src)
		new /obj/item/food/grown/corn(src)
		new /obj/item/food/grown/soybeans(src)

/obj/item/storage/box/ingredients/italian
	theme_name = "italian"

/obj/item/storage/box/ingredients/italian/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/grown/tomato(src)
		new /obj/item/food/meatball(src)
	new /obj/item/reagent_containers/cup/glass/bottle/wine(src)

/obj/item/storage/box/ingredients/vegetarian
	theme_name = "vegetarian"

/obj/item/storage/box/ingredients/vegetarian/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/carrot(src)
	new /obj/item/food/grown/apple(src)
	new /obj/item/food/grown/corn(src)
	new /obj/item/food/grown/eggplant(src)
	new /obj/item/food/grown/potato(src)
	new /obj/item/food/grown/tomato(src)

/obj/item/storage/box/ingredients/american
	theme_name = "american"

/obj/item/storage/box/ingredients/american/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/corn(src)
		new /obj/item/food/grown/potato(src)
		new /obj/item/food/grown/tomato(src)
	new /obj/item/food/meatball(src)

/obj/item/storage/box/ingredients/fruity
	theme_name = "fruity"

/obj/item/storage/box/ingredients/fruity/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/apple(src)
		new /obj/item/food/grown/citrus/orange(src)
	new /obj/item/food/grown/citrus/lemon(src)
	new /obj/item/food/grown/citrus/lime(src)
	new /obj/item/food/grown/watermelon(src)

/obj/item/storage/box/ingredients/sweets
	theme_name = "sweets"

/obj/item/storage/box/ingredients/sweets/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/cherries(src)
		new /obj/item/food/grown/banana(src)
	new /obj/item/food/chocolatebar(src)
	new /obj/item/food/grown/apple(src)
	new /obj/item/food/grown/cocoapod(src)

/obj/item/storage/box/ingredients/delights
	theme_name = "delights"

/obj/item/storage/box/ingredients/delights/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/bluecherries(src)
		new /obj/item/food/grown/potato/sweet(src)
	new /obj/item/food/grown/berries(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/food/grown/vanillapod(src)

/obj/item/storage/box/ingredients/grains
	theme_name = "grains"

/obj/item/storage/box/ingredients/grains/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/grown/oat(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/food/grown/wheat(src)
	new /obj/item/food/honeycomb(src)
	new /obj/item/seeds/poppy(src)

/obj/item/storage/box/ingredients/carnivore
	theme_name = "carnivore"

/obj/item/storage/box/ingredients/carnivore/PopulateContents()
	new /obj/item/food/meat/slab/bear(src)
	new /obj/item/food/meat/slab/corgi(src)
	new /obj/item/food/meat/slab/penguin(src)
	new /obj/item/food/meat/slab/spider(src)
	new /obj/item/food/meat/slab/xeno(src)
	new /obj/item/food/meatball(src)
	new /obj/item/food/spidereggs(src)

/obj/item/storage/box/ingredients/exotic
	theme_name = "exotic"

/obj/item/storage/box/ingredients/exotic/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/fishmeat/carp(src)
		new /obj/item/food/grown/cabbage(src)
		new /obj/item/food/grown/soybeans(src)
	new /obj/item/food/grown/chili(src)

/obj/item/storage/box/ingredients/seafood
	theme_name = "seafood"

/obj/item/storage/box/ingredients/seafood/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/fishmeat/armorfish(src)
		new /obj/item/food/fishmeat/carp(src)
		new /obj/item/food/fishmeat/moonfish(src)
	new /obj/item/food/fishmeat/gunner_jellyfish/supply(src)

/obj/item/storage/box/ingredients/salads
	theme_name = "salads"

/obj/item/storage/box/ingredients/salads/PopulateContents()
	new /obj/item/food/grown/cabbage(src)
	new /obj/item/food/grown/carrot(src)
	new /obj/item/food/grown/olive(src)
	new /obj/item/food/grown/onion/red(src)
	new /obj/item/food/grown/onion/red(src)
	new /obj/item/food/grown/tomato(src)
	new /obj/item/reagent_containers/condiment/olive_oil(src)

/obj/item/storage/box/ingredients/random
	theme_name = "random"
	desc = "This box should not exist, contact the proper authorities."

/obj/item/storage/box/ingredients/random/Initialize(mapload)
	. = ..()
	var/chosen_box = pick(subtypesof(/obj/item/storage/box/ingredients) - /obj/item/storage/box/ingredients/random)
	new chosen_box(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/storage/box/gum
	name = "bubblegum packet"
	desc = "The packaging is entirely in Japanese, apparently. You can't make out a single word of it."
	icon = 'icons/obj/storage/gum.dmi'
	icon_state = "bubblegum_generic"
	w_class = WEIGHT_CLASS_TINY
	illustration = null
	foldable_result = null
	custom_price = PAYCHECK_CREW

	///Typepath of the type of gum that spawns with this box, this is passed to the wrapper for spawning in.
	var/spawning_gum_type = /obj/item/food/bubblegum

/obj/item/storage/box/gum/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(/obj/item/storage/bubblegum_wrapper)
	atom_storage.max_slots = 4
	atom_storage.allow_big_nesting = TRUE

/obj/item/storage/box/gum/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/storage/bubblegum_wrapper(src, spawning_gum_type)

/obj/item/storage/bubblegum_wrapper
	name = "bubblegum wrapper"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "bubblegum_wrapper"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	item_flags = NOBLUDGEON|SKIP_FANTASY_ON_SPAWN
	grind_results = list(/datum/reagent/aluminium = 1)

	///The typepath of the type of gum that will spawn in our PopulateContents,
	///this is set in Initialize by the gum box if there is one.
	var/gum_to_spawn = /obj/item/food/bubblegum

/obj/item/storage/bubblegum_wrapper/Initialize(mapload, spawning_gum_type)
	if(!isnull(spawning_gum_type))
		gum_to_spawn = spawning_gum_type
	. = ..()
	atom_storage.set_holdable(/obj/item/food/bubblegum)
	atom_storage.max_slots = 1
	atom_storage.display_contents = FALSE
	update_appearance(UPDATE_OVERLAYS)

/obj/item/storage/bubblegum_wrapper/PopulateContents()
	new gum_to_spawn(src)

/obj/item/storage/bubblegum_wrapper/update_overlays()
	. = ..()
	var/obj/item/food/bubblegum/gum_inside = locate() in contents
	if(isnull(gum_inside))
		return .
	var/mutable_appearance/gum_overlay = mutable_appearance(gum_inside.icon, gum_inside.icon_state, layer = src.layer - 0.01)
	gum_overlay.color = gum_inside.color
	. += gum_overlay

//These procs are copied over from cigarette packets
/obj/item/storage/bubblegum_wrapper/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(istype(interacting_with, /obj/item/food/bubblegum))
		atom_storage.item_interact_insert(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	if(interacting_with != user)
		return ..()
	quick_remove_item(/obj/item/food/bubblegum, user, equip_to_mouth = TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/bubblegum_wrapper/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	quick_remove_item(/obj/item/food/bubblegum, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/storage/bubblegum_wrapper/click_alt(mob/user)
	quick_remove_item(/obj/item/food/bubblegum, user)
	return CLICK_ACTION_SUCCESS

/obj/item/storage/box/gum/nicotine
	name = "nicotine gum packet"
	desc = "Designed to help with nicotine addiction and oral fixation all at once without destroying your lungs in the process. Mint flavored!"
	icon_state = "bubblegum_nicotine"
	custom_premium_price = PAYCHECK_CREW * 1.5
	spawning_gum_type = /obj/item/food/bubblegum/nicotine

/obj/item/storage/box/gum/happiness
	name = "HP+ gum packet"
	desc = "A seemingly homemade packaging with an odd smell. It has a weird drawing of a smiling face sticking out its tongue."
	icon_state = "bubblegum_happiness"
	custom_price = PAYCHECK_COMMAND * 3
	custom_premium_price = PAYCHECK_COMMAND * 3
	spawning_gum_type = /obj/item/food/bubblegum/happiness

/obj/item/storage/box/gum/happiness/Initialize(mapload)
	. = ..()
	if (prob(25))
		desc += " You can faintly make out the word 'Hemopagopril' was once scribbled on it."

/obj/item/storage/box/gum/bubblegum
	name = "bubblegum gum packet"
	desc = "The packaging is entirely in Demonic, apparently. You feel like even opening this would be a sin."
	icon_state = "bubblegum_bubblegum"
	spawning_gum_type = /obj/item/food/bubblegum/bubblegum

/obj/item/storage/box/mothic_rations
	name = "Mothic Rations Pack"
	desc = "A box containing a few rations and some Activin gum, for keeping a starving moth going."
	icon_state = "moth_package"
	illustration = null

/obj/item/storage/box/mothic_rations/PopulateContents()
	for(var/i in 1 to 3)
		var/random_food = pick_weight(list(
			/obj/item/food/sustenance_bar = 10,
			/obj/item/food/sustenance_bar/cheese = 5,
			/obj/item/food/sustenance_bar/mint = 5,
			/obj/item/food/sustenance_bar/neapolitan = 5,
			/obj/item/food/sustenance_bar/wonka = 1,
			))
		new random_food(src)
	new /obj/item/storage/box/gum/wake_up(src)

/obj/item/storage/box/tiziran_goods
	name = "Tiziran Farm-Fresh Pack"
	desc = "A box containing an assortment of fresh Tiziran goods- perfect for making the foods of the Lizard Empire."
	icon_state = "lizard_package"
	illustration = null

/obj/item/storage/box/tiziran_goods/PopulateContents()
	for(var/i in 1 to 12)
		var/random_food = pick_weight(list(
			/obj/item/food/bread/root = 2,
			/obj/item/food/grown/ash_flora/seraka = 2,
			/obj/item/food/grown/korta_nut = 10,
			/obj/item/food/grown/korta_nut/sweet = 2,
			/obj/item/food/liver_pate = 5,
			/obj/item/food/lizard_dumplings = 5,
			/obj/item/food/moonfish_caviar = 5,
			/obj/item/food/root_flatbread = 5,
			/obj/item/food/rootroll = 5,
			/obj/item/food/spaghetti/nizaya = 5,
			))
		new random_food(src)

/obj/item/storage/box/tiziran_cans
	name = "Tiziran Canned Goods Pack"
	desc = "A box containing an assortment of canned Tiziran goods- to be eaten as is, or used in cooking."
	icon_state = "lizard_package"
	illustration = null

/obj/item/storage/box/tiziran_cans/PopulateContents()
	for(var/i in 1 to 8)
		var/random_food = pick_weight(list(
			/obj/item/food/canned/jellyfish = 5,
			/obj/item/food/canned/desert_snails = 5,
			/obj/item/food/canned/larvae = 5,
			))
		new random_food(src)

/obj/item/storage/box/tiziran_meats
	name = "Tiziran Meatmarket Pack"
	desc = "A box containing an assortment of fresh-frozen Tiziran meats and fish- the keys to lizard cooking."
	icon_state = "lizard_package"
	illustration = null

/obj/item/storage/box/tiziran_meats/PopulateContents()
	for(var/i in 1 to 10)
		var/random_food = pick_weight(list(
			/obj/item/food/fishmeat/armorfish = 5,
			/obj/item/food/fishmeat/gunner_jellyfish = 5,
			/obj/item/food/fishmeat/moonfish = 5,
			/obj/item/food/meat/slab = 5,
			))
		new random_food(src)

/obj/item/storage/box/mothic_goods
	name = "Mothic Farm-Fresh Pack"
	desc = "A box containing an assortment of Mothic cooking supplies."
	icon_state = "moth_package"
	illustration = null

/obj/item/storage/box/mothic_goods/PopulateContents()
	for(var/i in 1 to 12)
		var/random_food = pick_weight(list(
			/obj/item/food/cheese/cheese_curds = 5,
			/obj/item/food/cheese/curd_cheese = 5,
			/obj/item/food/cheese/firm_cheese = 5,
			/obj/item/food/cheese/mozzarella = 5,
			/obj/item/food/cheese/wheel = 5,
			/obj/item/food/grown/toechtauese = 10,
			/obj/item/reagent_containers/condiment/cornmeal = 5,
			/obj/item/reagent_containers/condiment/olive_oil = 5,
			/obj/item/reagent_containers/condiment/yoghurt = 5,
			))
		new random_food(src)

/obj/item/storage/box/mothic_cans_sauces
	name = "Mothic Pantry Pack"
	desc = "A box containing an assortment of Mothic canned goods and premade sauces."
	icon_state = "moth_package"
	illustration = null

/obj/item/storage/box/mothic_cans_sauces/PopulateContents()
	for(var/i in 1 to 8)
		var/random_food = pick_weight(list(
			/obj/item/food/bechamel_sauce = 5,
			/obj/item/food/canned/pine_nuts = 5,
			/obj/item/food/canned/tomatoes = 5,
			/obj/item/food/pesto = 5,
			/obj/item/food/tomato_sauce = 5,
			))
		new random_food(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	illustration = "condiment"

/obj/item/storage/box/condimentbottles/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/condiment(src)


/obj/item/storage/box/coffeepack
	icon_state = "arabica_beans"
	name = "arabica beans"
	desc = "A bag containing fresh, dry coffee arabica beans. Ethically sourced and packaged by Waffle Corp."
	illustration = null
	icon = 'icons/obj/food/containers.dmi'
	var/beantype = /obj/item/food/grown/coffee

/obj/item/storage/box/coffeepack/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(/obj/item/food/grown/coffee)

/obj/item/storage/box/coffeepack/PopulateContents()
	atom_storage.max_slots = 5
	for(var/i in 1 to 5)
		var/obj/item/food/grown/coffee/bean = new beantype(src)
		ADD_TRAIT(bean, TRAIT_DRIED, ELEMENT_TRAIT(type))
		bean.add_atom_colour(COLOR_DRIED_TAN, FIXED_COLOUR_PRIORITY) //give them the tan just like from the drying rack

/obj/item/storage/box/coffeepack/robusta
	icon_state = "robusta_beans"
	name = "robusta beans"
	desc = "A bag containing fresh, dry coffee robusta beans. Ethically sourced and packaged by Waffle Corp."
	beantype = /obj/item/food/grown/coffee/robusta
