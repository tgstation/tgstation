// Cannabis
/obj/item/seeds/cannabis
	name = "pack of cannabis seeds"
	desc = "Taxable."
	icon_state = "seed-cannabis"
	species = "cannabis"
	plantname = "Cannabis Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis
	maturation = 8
	potency = 20
	growthstages = 1
	growing_icon = 'goon/icons/obj/hydroponics.dmi'
	icon_grow = "cannabis-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "cannabis-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cannabis/rainbow,
						/obj/item/seeds/cannabis/death,
						/obj/item/seeds/cannabis/white,
						/obj/item/seeds/cannabis/ultimate)
	reagents_add = list("space_drugs" = 0.15, "lipolicide" = 0.35) // gives u the munchies


/obj/item/seeds/cannabis/rainbow
	name = "pack of rainbow weed seeds"
	desc = "These seeds grow into rainbow weed. Groovy."
	icon_state = "seed-megacannabis"
	species = "megacannabis"
	plantname = "Rainbow Weed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow
	mutatelist = list()
	reagents_add = list("mindbreaker" = 0.15, "lipolicide" = 0.35)
	rarity = 40

/obj/item/seeds/cannabis/death
	name = "pack of deathweed seeds"
	desc = "These seeds grow into deathweed. Not groovy."
	icon_state = "seed-blackcannabis"
	species = "blackcannabis"
	plantname = "Deathweed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/death
	mutatelist = list()
	reagents_add = list("cyanide" = 0.35, "space_drugs" = 0.15, "lipolicide" = 0.15)
	rarity = 40

/obj/item/seeds/cannabis/white
	name = "pack of lifeweed seeds"
	desc = "I will give unto him that is munchies of the fountain of the cravings of life, freely."
	icon_state = "seed-whitecannabis"
	species = "whitecannabis"
	plantname = "Lifeweed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/white
	mutatelist = list()
	reagents_add = list("omnizine" = 0.35, "space_drugs" = 0.15, "lipolicide" = 0.15)
	rarity = 40


/obj/item/seeds/cannabis/ultimate
	name = "pack of omega weed seeds"
	desc = "These seeds grow into omega weed."
	icon_state = "seed-ocannabis"
	species = "ocannabis"
	plantname = "Omega Weed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/ultimate
	mutatelist = list()
	reagents_add = list("space_drugs" = 0.3,
						"mindbreaker" = 0.3,
						"mercury" = 0.15,
						"lithium" = 0.15,
						"atropine" = 0.15,
						"haloperidol" = 0.15,
						"methamphetamine" = 0.15,
						"capsaicin" = 0.15,
						"barbers_aid" = 0.15,
						"bath_salts" = 0.15,
						"itching_powder" = 0.15,
						"crank" = 0.15,
						"krokodil" = 0.15,
						"histamine" = 0.15,
						"lipolicide" = 0.15)
	rarity = 69

/obj/item/seeds/cannabis/ultimate/harvest
	harvest(mob/user)
		var/obj/machinery/hydroponics/parent = loc //for ease of access
		var/t_amount = 0
		var/list/result = list()
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
		var/product_name
		while(t_amount < getYield())
			var/obj/item/reagent_containers/food/snacks/grown/t_prod = new product(output_loc, src)
			result.Add(t_prod) // User gets a consumable
			t_amount++
			product_name = t_prod.name
		if(getYield() >= 1)
			SSblackbox.record_feedback("tally", "food_harvested", getYield(), product_name)
		parent.update_tray(user)

		return result

	prepare_result(var/obj/item/T)
		if(!T.reagents)
			CRASH("[T] has no reagents.")
		for(var/rid in reagents_add)
			var/amount = 1 + round(potency * reagents_add[rid], 1)
			var/list/data = null
			if(rid == "blood") // Hack to make blood in plants always O-
				data = list("blood_type" = "O-")

			T.reagents.add_reagent(rid, amount, data)

// ---------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/grown/cannabis
	seed = /obj/item/seeds/cannabis
	icon = 'goon/icons/obj/hydroponics.dmi'
	name = "cannabis leaf"
	desc = "Recently legalized in most galaxies."
	icon_state = "cannabis"
	filling_color = "#00FF00"
	bitesize_mod = 2
	foodtype = VEGETABLES //i dont really know what else weed could be to be honest
	tastes = list("cannabis" = 1)
	wine_power = 20

/obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow
	seed = /obj/item/seeds/cannabis/rainbow
	name = "rainbow cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megacannabis"
	wine_power = 60

/obj/item/reagent_containers/food/snacks/grown/cannabis/death
	seed = /obj/item/seeds/cannabis/death
	name = "death cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackcannabis"
	wine_power = 40

/obj/item/reagent_containers/food/snacks/grown/cannabis/white
	seed = /obj/item/seeds/cannabis/white
	name = "white cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whitecannabis"
	wine_power = 10

/obj/item/reagent_containers/food/snacks/grown/cannabis/ultimate
	seed = /obj/item/seeds/cannabis/ultimate
	name = "omega cannabis leaf"
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "ocannabis"
	volume = 420
	wine_power = 90
