/datum/component/sizzle
	var/mutable_appearance/sizzleicon
	var/sizzlealpha = 0
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/sizzle/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	sizzlealpha += 5
	setup_sizzle()

/datum/component/sizzle/proc/setup_sizzle()
	var/atom/food = parent
	var/icon/grillmarks = icon(initial(food.icon), initial(food.icon_state))	//we only want to apply grill marks to the initial icon_state for each object
	if(!isnull(sizzleicon))
		food.cut_overlay(sizzleicon)
	grillmarks.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
	grillmarks.Blend(icon('icons/obj/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparent
	sizzleicon = grillmarks
	sizzleicon.alpha = sizzlealpha
	food.add_overlay(sizzleicon)

