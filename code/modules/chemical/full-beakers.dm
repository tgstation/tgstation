/obj/item/weapon/reagent_containers/glass/fullbeaker
	name = "fullbeaker"
	desc = "A beaker with an exciting chrome finish. Its volume rating is 1000 units!"
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"
	volume = 1000
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)
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

////////////////////////////////////////////////////////////////////////////////
/// Complex chemicals
////////////////////////////////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/alkysine
	name = "ALKYSINE"
	New()
		..()
		reagents.add_reagent("alkysine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/ammonia
	name = "AMMONIA"
	New()
		..()
		reagents.add_reagent("ammonia", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/anti_toxin
	name = "ANTI-TOXIN"
	New()
		..()
		reagents.add_reagent("anti_toxin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/arithrazine
	name = "ARITHRAZINE"
	New()
		..()
		reagents.add_reagent("arithrazine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/bicaridine
	name = "BICARIDINE"
	New()
		..()
		reagents.add_reagent("bicaridine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/chloral_hydrate
	name = "CHLORAL HYDRATE"
	New()
		..()
		reagents.add_reagent("chloralhydrate", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/clonexadone
	name = "CLONEXADONE"
	New()
		..()
		reagents.add_reagent("clonexadone", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/cryoxadone
	name = "CRYOXADONE"
	New()
		..()
		reagents.add_reagent("cryoxadone", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/cryptobiolin
	name = "CRYPTOBIOLIN"
	New()
		..()
		reagents.add_reagent("cryptobiolin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/cyanide
	name = "CYANIDE"
	New()
		..()
		reagents.add_reagent("cyanide", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/dermaline
	name = "DERMALINE"
	New()
		..()
		reagents.add_reagent("dermaline", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/dexalin
	name = "DEXALIN"
	New()
		..()
		reagents.add_reagent("dexalin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/dexalin_plus
	name = "DEXALIN PLUS"
	New()
		..()
		reagents.add_reagent("dexalinp", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/diethylamine
	name = "DIETHYLAMINE"
	New()
		..()
		reagents.add_reagent("diethylamine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/ethylredoxrazine
	name = "ETHYLREDOXRAZINE"
	New()
		..()
		reagents.add_reagent("ethylredoxrazine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/fluorosurfactant
	name = "FLUOROSURFACTANT"
	New()
		..()
		reagents.add_reagent("fluorosurfactant", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/foaming_agent
	name = "FOAMING AGENT"
	New()
		..()
		reagents.add_reagent("foaming_agent", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/glycerol
	name = "GLYCEROL"
	New()
		..()
		reagents.add_reagent("glycerol", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/hyperzine
	name = "HYPERZINE"
	New()
		..()
		reagents.add_reagent("hyperzine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/hyronalin
	name = "HYRONALIN"
	New()
		..()
		reagents.add_reagent("hyronalin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/imidazoline
	name = "IMIDAZOLINE"
	New()
		..()
		reagents.add_reagent("imidazoline", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/impedrezene
	name = "IMPEDREZENE"
	New()
		..()
		reagents.add_reagent("impedrezene", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/inaprovaline
	name = "INAPROVALINE"
	New()
		..()
		reagents.add_reagent("inaprovaline", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/kelotane
	name = "KELOTANE"
	New()
		..()
		reagents.add_reagent("kelotane", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/leporazine
	name = "LEPORAZINE"
	New()
		..()
		reagents.add_reagent("leporazine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/lexorin
	name = "LEXORIN"
	New()
		..()
		reagents.add_reagent("lexorin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/mint_toxin
	name = "MINT TOXIN"
	New()
		..()
		reagents.add_reagent("minttoxin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/nitroglycerin
	name = "NITROGLYCERIN"
	New()
		..()
		reagents.add_reagent("nitroglycerin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/plant_b_gone
	name = "PLANT-B-GONE"
	New()
		..()
		reagents.add_reagent("plantbgone", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/polytrinic_acid
	name = "POLYTRINIC ACID"
	New()
		..()
		reagents.add_reagent("pacid", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/ryetalyn
	name = "RYETALYN"
	New()
		..()
		reagents.add_reagent("ryetalyn", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/serotrotium
	name = "SEROTROTIUM"
	New()
		..()
		reagents.add_reagent("serotrotium", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/silicate
	name = "SILICATE"
	New()
		..()
		reagents.add_reagent("silicate", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/sleep_toxin
	name = "SLEEP TOXIN"
	New()
		..()
		reagents.add_reagent("stoxin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/space_cleaner
	name = "SPACE CLEANER"
	New()
		..()
		reagents.add_reagent("cleaner", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/space_drugs
	name = "SPACE DRUGS"
	New()
		..()
		reagents.add_reagent("space_drugs", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/space_lube
	name = "SPACE LUBE"
	New()
		..()
		reagents.add_reagent("lube", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/spacecillin
	name = "SPACECILLIN"
	New()
		..()
		reagents.add_reagent("spaceacillin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/sterilizine
	name = "STERILIZINE"
	New()
		..()
		reagents.add_reagent("sterilizine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/synaptizine
	name = "SYNAPTIZINE"
	New()
		..()
		reagents.add_reagent("synaptizine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/thermite
	name = "THERMITE"
	New()
		..()
		reagents.add_reagent("thermite", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/toxin
	name = "TOXIN"
	New()
		..()
		reagents.add_reagent("toxin", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/tricordrazine
	name = "TRIDORDRAZINE"
	New()
		..()
		reagents.add_reagent("tricordrazine", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/unstable_mutagen
	name = "UNSTABLE MUTAGEN"
	New()
		..()
		reagents.add_reagent("mutagen", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/virus_food
	name = "VIRUS FOOD"
	New()
		..()
		reagents.add_reagent("virusfood", 1000)


/obj/item/weapon/reagent_containers/glass/fullbeaker/admin/zombie_powder
	name = "ZOMBIE POWDER"
	New()
		..()
		reagents.add_reagent("zombiepowder", 1000)


////////////////////////////////////////////////////////////////////////////////
/// Complex chemicals END
////////////////////////////////////////////////////////////////////////////////
