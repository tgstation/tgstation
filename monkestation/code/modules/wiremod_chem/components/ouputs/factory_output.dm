/obj/structure/chemical_tank/factory
	name = "remote factory output"
	desc = "Produces patchs, pills or bottles on demand."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "bottler"
	component_name = "Factory Output"

	reagent_flags =  TRANSPARENT

	///current operating product (pills or patches)
	var/product = "pill"
	///the minimum size a pill or patch can be
	var/min_volume = 5
	///the maximum size a pill or patch can be
	var/max_volume = 50
	///selected size of the product
	var/current_volume = 10
	///prefix for the product name
	var/product_name = "factory"
	///the icon_state number for the pill.
	var/pill_number = RANDOM_PILL_STYLE
	///list of id's and icons for the pill selection of the ui
	var/list/pill_styles
	/// Currently selected patch style
	var/patch_style = DEFAULT_PATCH_STYLE
	/// List of available patch styles for UI
	var/list/patch_styles

/obj/structure/chemical_tank/factory/proc/load_styles()
	//expertly copypasted from chemmasters
	pill_styles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		pill_styles += list("[x]" = image(icon = 'icons/obj/medical/chemical.dmi', icon_state = "pill[x]"))

	patch_styles = list()
	for (var/raw_patch_style in PATCH_STYLE_LIST)
		patch_styles += list("[raw_patch_style]" = image(icon = 'icons/obj/medical/chemical.dmi', icon_state = raw_patch_style))

/obj/structure/chemical_tank/factory/proc/generate_product(mob/user)
	if(reagents.total_volume < current_volume)
		return
	if (product == "pill")
		var/obj/item/reagent_containers/pill/P = new(get_turf(src))
		reagents.trans_to(P, current_volume)
		P.name = trim("[product_name] pill")
		user.put_in_hands(P)
		if(pill_number == RANDOM_PILL_STYLE)
			P.icon_state = "pill[rand(1,21)]"
		else
			P.icon_state = "pill[pill_number]"
		if(P.icon_state == "pill4") //mirrored from chem masters
			P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
	else if (product == "patch")
		var/obj/item/reagent_containers/pill/patch/P = new(get_turf(src))
		reagents.trans_to(P, current_volume)
		P.name = trim("[product_name] patch")
		P.icon_state = patch_style
		user.put_in_hands(P)
	else if (product == "bottle")
		var/obj/item/reagent_containers/cup/bottle/P = new(get_turf(src))
		reagents.trans_to(P, current_volume)
		P.name = trim("[product_name] bottle")
		user.put_in_hands(P)

/obj/structure/chemical_tank/factory/AltClick(mob/user)
	. = ..()
	if(!length(pill_styles) || !length(patch_styles))
		load_styles()
	var/choice_product = tgui_input_list(user, "Pick Product", "[name]", list("pill", "patch", "bottle"))
	if(choice_product)
		product = choice_product

	var/choice_name = tgui_input_text(user, "Pick Product Name", "[name]")
	if(choice_name)
		product_name = choice_name

	var/choice_volume = tgui_input_number(user, "Choose a product volume", "[name]", current_volume, max_volume, min_volume)
	if(choice_volume)
		current_volume = choice_volume

	if(choice_product == "patch")
		var/patch_choice = show_radial_menu(user, src, patch_styles)
		if(patch_choice)
			patch_style = patch_choice

	if(choice_product == "pill")
		var/pill_choice = show_radial_menu(user, src, pill_styles)
		if(pill_choice)
			pill_number = text2num(pill_choice)


/obj/structure/chemical_tank/factory/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	generate_product(user)
