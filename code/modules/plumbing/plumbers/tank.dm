/obj/structure/tank
	name = "liquid tank"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "tank"

/obj/structure/tank/Initialize()
	create_reagents(200, OPENCONTAINER)
	. = ..() //ComponentInitialize is called here, and we need to create the reagents first


/obj/structure/tank/ComponentInitialize()
	AddComponent(/datum/component/plumbing/tank, OPENCONTAINER)

/obj/structure/tank/on_reagent_change()
	update_icon()

/obj/structure/tank/update_icon()
	cut_overlay()

	if(!reagents.total_volume)
		return
	var/mutable_appearance/soup = mutable_appearance('icons/obj/reagentfillings.dmi')
	switch(reagents.total_volume / reagents.maximum_volume * 100)
		if(0 to 9)
			soup.icon_state = "[icon_state]-1"
		if(10 to 24)
			soup.icon_state = "[icon_state]-2"
		if(25 to 49)
			soup.icon_state = "[icon_state]-3"
		if(50 to 74)
			soup.icon_state = "[icon_state]-4"
		if(75 to 90)
			soup.icon_state = "[icon_state]-5"
		if(90 to 99)
			soup.icon_state = "[icon_state]-6"
		else
			soup.icon_state = "[icon_state]-7"
	soup.color = mix_color_from_reagents(reagents.reagent_list)
	add_overlay(soup)