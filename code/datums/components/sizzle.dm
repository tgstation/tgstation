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
	sizzleicon = icon(initial(parent.icon), initial(parent.icon_state))	//we only want to apply grill marks to the initial icon_state for each object
	sizzleicon.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
	sizzleicon.Blend(icon('icons/obj/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparent
	I.add_overlay(sizzleicon)
	sizzleicon.alpha = 0
