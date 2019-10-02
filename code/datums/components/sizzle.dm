/datum/component/sizzle
	var/mutable_appearance/sizzleicon
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/sizzle/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/food = parent
	if(!isnull(sizzleicon))
		sizzleicon.alpha += 5
		food.cut_overlay(sizzleicon)
		food.add_overlay(sizzleicon)
		return
	setup_sizzle()

/datum/component/sizzle/proc/setup_sizzle()
	var/atom/food = parent
	var/icon/grillmarks = icon(initial(food.icon), initial(food.icon_state))	//we only want to apply grill marks to the initial icon_state for each object
	grillmarks.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
	grillmarks.Blend(icon('icons/obj/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparent
	sizzleicon = grillmarks
	sizzleicon.alpha = 0
	food.add_overlay(sizzleicon)
