/datum/component/sizzle
	var/mutable_appearance/sizzleicon
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/sizzle/Initialize(continue = 0)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(continue)
		sizzleicon.alpha += 5
		return
	setup_sizzle()

/datum/component/sizzle/setup_sizzle()
	var/atom/I = parent
	var/index = "[REF(initial(icon))]-[initial(icon_state)]"
	var/static/list/grill_icons = list()
	var/icon/grill_icon = grill_icons[index]
	grill_icon = icon(initial(I.icon), initial(I.icon_state), , 1)	//we only want to apply grill marks to the initial icon_state for each object
	grill_icon.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
	grill_icon.Blend(icon('icons/obj/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparent
	grill_icon = fcopy_rsc(grill_icon)
	grill_icons[index] = grill_icon
	sizzleicon = grill_icon
	I.add_overlay(sizzleicon)
	sizzleicon.alpha = 0
