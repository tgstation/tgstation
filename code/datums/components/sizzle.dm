/datum/component/sizzle
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	///The sizzling appearance to put on top of the food item
	var/mutable_appearance/sizzling
	///The amount of time the food item has been sizzling for
	var/grilled_time = 0

/datum/component/sizzle/Initialize(grilled_time)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/food = parent
	var/icon/grill_marks = icon(food.icon, food.icon_state)
	grill_marks.Blend("#fff", ICON_ADD) //fills the icon_state with white (except where it's transparent)
	grill_marks.Blend(icon('icons/obj/machines/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparent
	sizzling = new(grill_marks)
	food.add_overlay(sizzling)

	src.grilled_time = grilled_time

/datum/component/sizzle/InheritComponent(datum/component/C, i_am_original, grilled_time)
	var/atom/food = parent
	sizzling.alpha += 5
	food.cut_overlay(sizzling)
	food.add_overlay(sizzling)
	src.grilled_time = grilled_time

///Returns how long the food item has been sizzling for
/datum/component/sizzle/proc/time_elapsed()
	return src.grilled_time
