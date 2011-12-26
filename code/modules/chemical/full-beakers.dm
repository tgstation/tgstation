/obj/item/weapon/reagent_containers/glass/fullbeaker
	name = "fullbeaker"
	desc = "A beaker with an exciting chrome finish. Its volume rating is 1000 units!"
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"
	volume = 1000
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	pickup(mob/user)
		on_reagent_change(user)

	dropped(mob/user)
		on_reagent_change()

	on_reagent_change(var/mob/user)
		/*
		if(reagents.total_volume)
			icon_state = "beaker1"
		else
			icon_state = "beaker0"
		*/
		overlays = null

		if(reagents.total_volume)
			var/obj/effect/overlay = new/obj
			overlay.icon = 'beaker1.dmi'
			var/percent = round((reagents.total_volume / volume) * 100)
			switch(percent)
				if(0 to 9)		overlay.icon_state = "-10"
				if(10 to 24) 	overlay.icon_state = "10"
				if(25 to 49)	overlay.icon_state = "25"
				if(50 to 74)	overlay.icon_state = "50"
				if(75 to 79)	overlay.icon_state = "75"
				if(80 to 90)	overlay.icon_state = "80"
				if(91 to 100)	overlay.icon_state = "100"

			var/list/rgbcolor = list(0,0,0)
			var/finalcolor
			for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
				if(!finalcolor)
					rgbcolor = GetColors(re.color)
					finalcolor = re.color
				else
					var/newcolor[3]
					var/prergbcolor[3]
					prergbcolor = rgbcolor
					newcolor = GetColors(re.color)

					rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
					rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
					rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

					finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
					// This isn't a perfect color mixing system, the more reagents that are inside,
					// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
					// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
					// If you add brighter colors to it it'll eventually get lighter, though.

			overlay.icon += finalcolor
			if(user || !istype(src.loc, /turf))
				overlay.layer = 30
			overlays += overlay


////////////////////////////////////////////////////////////////////////////////
/// Simple Chemicals
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/aluminum
	name = "ALUMINUM"
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"
	New()
		..()
		reagents.add_reagent("aluminum", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/carbon
	name = "CARBON"
	New()
		..()
		reagents.add_reagent("carbon", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/chlorine
	name = "CHLORINE"
	New()
		..()
		reagents.add_reagent("chlorine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/copper
	name = "COPPER"
	New()
		..()
		reagents.add_reagent("copper", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/ethanol
	name = "ETHANOL"
	New()
		..()
		reagents.add_reagent("ethanol", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/fluorine
	name = "FLUORINE"
	New()
		..()
		reagents.add_reagent("fluorine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/hydrogen
	name = "HYDROGEN"
	New()
		..()
		reagents.add_reagent("hydrogen", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/iron
	name = "IRON"
	New()
		..()
		reagents.add_reagent("iron", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/lithium
	name = "LITHIUM"
	New()
		..()
		reagents.add_reagent("lithium", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/mercury
	name = "MERCURY"
	New()
		..()
		reagents.add_reagent("mercury", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/nitrogen
	name = "NITROGEN"
	New()
		..()
		reagents.add_reagent("nitrogen", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/oxygen
	name = "OXYGEN"
	New()
		..()
		reagents.add_reagent("oxygen", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/phosphorus
	name = "PHOSPHORUS"
	New()
		..()
		reagents.add_reagent("phosphorus", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/potassium
	name = "POTASSIUM"
	New()
		..()
		reagents.add_reagent("potassium", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/radium
	name = "RADIUM"
	New()
		..()
		reagents.add_reagent("radium", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/sodium
	name = "SODIUM"
	New()
		..()
		reagents.add_reagent("sodium", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/sugar
	name = "SUGAR"
	New()
		..()
		reagents.add_reagent("sugar", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/silicon
	name = "SILICON"
	New()
		..()
		reagents.add_reagent("silicon", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/sulfur
	name = "SULFUR"
	New()
		..()
		reagents.add_reagent("sulfur", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/sulphuric_acid
	name = "SULPHURIC ACID"
	New()
		..()
		reagents.add_reagent("acid", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/water
	name = "WATER"
	New()
		..()
		reagents.add_reagent("water", 1000)


////////////////////////////////////////////////////////////////////////////////
/// Simple Chemicals END
////////////////////////////////////////////////////////////////////////////////