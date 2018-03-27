/datum/reagent/consumable/boyarishneek
	name = "Boyarishneek Juice"
	id = "boyarishneek"
	description = "Сок боярышника. Если смешать с этанолом то может получиться что-то интересное..."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "berries"
	glass_icon_state = "berryjuice"
	glass_name = "glass of boyarishneek juice"
	glass_desc = "Сок боярышника. Если смешать с этанолом то может получиться что-то интересное..."

/obj/item/seeds/berry/boyarishneek
	name = "pack of boyarishneek seeds"
	desc = "These seeds grow into boyarishneek bushes."
	icon = 'code/white/hule/boyareeshneek/boyarishneek_hydroponics.dmi'
	icon_state = "seeds"
	species = "boyarishneek"
	plantname = "Boyarishneek Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/berries/boyarishneek
	growing_icon = 'code/white/hule/boyareeshneek/boyarishneek_hydroponics.dmi'
	icon_grow = "berry-grow"
	icon_dead = "berry-dead"
	icon_harvest = "berry-harvest"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/berry/glow)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1, "boyarishneek" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/berries/boyarishneek
	seed = /obj/item/seeds/berry/boyarishneek
	name = "bunch of boyarishneek berries"
	desc = "Nutritious!"
	icon = 'code/white/hule/boyareeshneek/boyarishneek_hydroponics.dmi'
	icon_state = "berrypile"
	gender = PLURAL
	filling_color = "#FF00FF"
	bitesize_mod = 2
	foodtype = FRUIT
	juice_results = list("boyarishneek" = 0)

/datum/chemical_reaction/boyarka
	name = "Boyarka"
	id = "boyarka"
	results = list("boyarka" = 3)
	required_reagents = list("ethanol" = 2, "boyarishneek" = 1)