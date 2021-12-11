//*******************Contains everything related to the flora on lavaland.*******************************
//This includes: The structures, their produce, their seeds and the crafting recipe for the mushroom bowl

/obj/structure/flora/ash
	gender = PLURAL
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER //sporangiums up don't shoot
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom"
	name = "large mushrooms"
	desc = "A number of large mushrooms, covered in a faint layer of ash and what can only be spores."
	var/harvested_name = "shortened mushrooms"
	var/harvested_desc = "Some quickly regrowing mushrooms, formerly known to be quite large."
	var/needs_sharp_harvest = TRUE
	var/harvest = /obj/item/food/grown/ash_flora/shavings
	var/harvest_amount_low = 1
	var/harvest_amount_high = 3
	var/harvest_time = 60
	var/harvest_message_low = "You pick a mushroom, but fail to collect many shavings from its cap."
	var/harvest_message_med = "You pick a mushroom, carefully collecting the shavings from its cap."
	var/harvest_message_high = "You harvest and collect shavings from several mushroom caps."
	var/harvested = FALSE
	var/base_icon
	var/regrowth_time_low = 8 MINUTES
	var/regrowth_time_high = 16 MINUTES
	var/number_of_variants = 4

/obj/structure/flora/ash/Initialize(mapload)
	. = ..()
	base_icon = "[icon_state][rand(1, number_of_variants)]"
	icon_state = base_icon

/obj/structure/flora/ash/proc/harvest(user)
	if(harvested)
		return FALSE

	var/rand_harvested = rand(harvest_amount_low, harvest_amount_high)
	if(rand_harvested)
		if(user)
			var/msg = harvest_message_med
			if(rand_harvested == harvest_amount_low)
				msg = harvest_message_low
			else if(rand_harvested == harvest_amount_high)
				msg = harvest_message_high
			to_chat(user, span_notice("[msg]"))
		for(var/i in 1 to rand_harvested)
			new harvest(get_turf(src))

	icon_state = "[base_icon]p"
	name = harvested_name
	desc = harvested_desc
	harvested = TRUE
	addtimer(CALLBACK(src, .proc/regrow), rand(regrowth_time_low, regrowth_time_high))
	return TRUE

/obj/structure/flora/ash/proc/regrow()
	icon_state = base_icon
	name = initial(name)
	desc = initial(desc)
	harvested = FALSE

/obj/structure/flora/ash/attackby(obj/item/W, mob/user, params)
	if(!harvested && needs_sharp_harvest && W.get_sharpness())
		user.visible_message(span_notice("[user] starts to harvest from [src] with [W]."),span_notice("You begin to harvest from [src] with [W]."))
		if(do_after(user, harvest_time, target = src))
			harvest(user)
	else
		return ..()

/obj/structure/flora/ash/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!harvested && !needs_sharp_harvest)
		user.visible_message(span_notice("[user] starts to harvest from [src]."),span_notice("You begin to harvest from [src]."))
		if(do_after(user, harvest_time, target = src))
			harvest(user)

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things
	regrowth_time_low = 4200

/obj/structure/flora/ash/leaf_shroom
	icon_state = "s_mushroom"
	name = "leafy mushrooms"
	desc = "A number of mushrooms, each of which surrounds a greenish sporangium with a number of leaf-like structures."
	harvested_name = "leafless mushrooms"
	harvested_desc = "A bunch of formerly-leafed mushrooms, with their sporangiums exposed. Scandalous?"
	harvest = /obj/item/food/grown/ash_flora/mushroom_leaf
	needs_sharp_harvest = FALSE
	harvest_amount_high = 4
	harvest_time = 20
	harvest_message_low = "You pluck a single, suitable leaf."
	harvest_message_med = "You pluck a number of leaves, leaving a few unsuitable ones."
	harvest_message_high = "You pluck quite a lot of suitable leaves."
	regrowth_time_low = 2400
	regrowth_time_high = 6000

/obj/structure/flora/ash/cap_shroom
	icon_state = "r_mushroom"
	name = "tall mushrooms"
	desc = "Several mushrooms, the larger of which have a ring of conks at the midpoint of their stems."
	harvested_name = "small mushrooms"
	harvested_desc = "Several small mushrooms near the stumps of what likely were larger mushrooms."
	harvest = /obj/item/food/grown/ash_flora/mushroom_cap
	harvest_amount_high = 4
	harvest_time = 50
	harvest_message_low = "You slice the cap off a mushroom."
	harvest_message_med = "You slice off a few conks from the larger mushrooms."
	harvest_message_high = "You slice off a number of caps and conks from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 5400

/obj/structure/flora/ash/stem_shroom
	icon_state = "t_mushroom"
	name = "numerous mushrooms"
	desc = "A large number of mushrooms, some of which have long, fleshy stems. They're radiating light!"
	light_range = 1.5
	light_power = 2.1
	harvested_name = "tiny mushrooms"
	harvested_desc = "A few tiny mushrooms around larger stumps. You can already see them growing back."
	harvest = /obj/item/food/grown/ash_flora/mushroom_stem
	harvest_amount_high = 4
	harvest_time = 40
	harvest_message_low = "You pick and slice the cap off a mushroom, leaving the stem."
	harvest_message_med = "You pick and decapitate several mushrooms for their stems."
	harvest_message_high = "You acquire a number of stems from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 6000

/obj/structure/flora/ash/cacti
	icon_state = "cactus"
	name = "fruiting cacti"
	desc = "Several prickly cacti, brimming with ripe fruit and covered in a thin layer of ash."
	harvested_name = "cacti"
	harvested_desc = "A bunch of prickly cacti. You can see fruits slowly growing beneath the covering of ash."
	harvest = /obj/item/food/grown/ash_flora/cactus_fruit
	needs_sharp_harvest = FALSE
	harvest_amount_high = 2
	harvest_time = 10
	harvest_message_low = "You pick a cactus fruit."
	harvest_message_med = "You pick several cactus fruit." //shouldn't show up, because you can't get more than two
	harvest_message_high = "You pick a pair of cactus fruit."
	regrowth_time_low = 4800
	regrowth_time_high = 7200

/obj/structure/flora/ash/cacti/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 3, max_damage = 6, probability = 70)

/obj/structure/flora/ash/seraka
	icon_state = "seraka_mushroom"
	name = "seraka mushrooms"
	desc = "A small cluster of seraka mushrooms. These must have come with the ashlizards."
	needs_sharp_harvest = FALSE
	harvested_name = "harvested seraka mushrooms"
	harvested_desc = "A couple of small seraka mushrooms, with the larger ones clearly having been recently removed. They'll grow back... eventually."
	harvest = /obj/item/food/grown/ash_flora/seraka
	harvest_amount_high = 6
	harvest_time = 25
	harvest_message_low = "You pluck a few choice tasty mushrooms."
	harvest_message_med = "You grab a good haul of mushrooms."
	harvest_message_high = "You hit the mushroom motherlode and make off with a bunch of tasty mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 5400
	number_of_variants = 2

///Snow flora to exist on icebox.
/obj/structure/flora/ash/chilly
	icon_state = "chilly_pepper"
	name = "springy grassy fruit"
	desc = "A number of bright, springy blue fruiting plants. They seem to be unconcerned with the hardy, cold environment."
	harvested_name = "springy grass"
	harvested_desc = "A bunch of springy, bouncy fruiting grass, all picked. Or maybe they were never fruiting at all?"
	harvest = /obj/item/food/grown/icepepper
	needs_sharp_harvest = FALSE
	harvest_amount_high = 3
	harvest_time = 15
	harvest_message_low = "You pluck a single, curved fruit."
	harvest_message_med = "You pluck a number of curved fruit."
	harvest_message_high = "You pluck quite a lot of curved fruit."
	regrowth_time_low = 2400
	regrowth_time_high = 5500
	number_of_variants = 2

//SNACKS

/obj/item/food/grown/ash_flora
	name = "mushroom shavings"
	desc = "Some shavings from a tall mushroom. With enough, might serve as a bowl."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_shavings"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 100
	seed = /obj/item/seeds/lavaland/polypore
	wine_power = 20

/obj/item/food/grown/ash_flora/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-4, 4)
	pixel_y = base_pixel_y + rand(-4, 4)

/obj/item/food/grown/ash_flora/shavings //So we can't craft bowls from everything.
	grind_results = list(/datum/reagent/toxin/mushroom_powder = 5)

/obj/item/food/grown/ash_flora/mushroom_leaf
	name = "mushroom leaf"
	desc = "A leaf, from a mushroom."
	icon_state = "mushroom_leaf"
	seed = /obj/item/seeds/lavaland/porcini
	wine_power = 40

/obj/item/food/grown/ash_flora/mushroom_cap
	name = "mushroom cap"
	desc = "The cap of a large mushroom."
	icon_state = "mushroom_cap"
	seed = /obj/item/seeds/lavaland/inocybe
	wine_power = 70

/obj/item/food/grown/ash_flora/mushroom_stem
	name = "mushroom stem"
	desc = "A long mushroom stem. It's slightly glowing."
	icon_state = "mushroom_stem"
	seed = /obj/item/seeds/lavaland/ember
	wine_power = 60

/obj/item/food/grown/ash_flora/cactus_fruit
	name = "cactus fruit"
	desc = "A cactus fruit covered in a thick, reddish skin. And some ash."
	icon_state = "cactus_fruit"
	seed = /obj/item/seeds/lavaland/cactus
	wine_power = 50

/obj/item/food/grown/ash_flora/seraka
	name = "seraka cap"
	desc = "Small, deeply flavourful mushrooms originally native to Tizira."
	icon_state = "seraka_cap"
	seed = /obj/item/seeds/lavaland/seraka
	wine_power = 40

//SEEDS

/obj/item/seeds/lavaland
	name = "lavaland seeds"
	desc = "You should never see this."
	lifespan = 50
	endurance = 25
	maturation = 7
	production = 4
	yield = 4
	potency = 15
	growthstages = 3
	rarity = 20
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)
	species = "polypore" // silence unit test
	genes = list(/datum/plant_gene/trait/fire_resistance)
	graft_gene = /datum/plant_gene/trait/fire_resistance

/obj/item/seeds/lavaland/cactus
	name = "pack of fruiting cactus seeds"
	desc = "These seeds grow into fruiting cacti."
	icon_state = "seed-cactus"
	species = "cactus"
	plantname = "Fruiting Cactus"
	product = /obj/item/food/grown/ash_flora/cactus_fruit
	mutatelist = list(/obj/item/seeds/star_cactus)
	genes = list(/datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	growthstages = 2
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.04, /datum/reagent/consumable/vitfro = 0.08)

///Star Cactus seeds, mutation of lavaland cactus.
/obj/item/seeds/star_cactus
	name = "pack of star cacti seeds"
	desc = "These seeds grow into star cacti."
	icon_state = "seed-starcactus"
	species = "starcactus"
	plantname = "Star Cactus Cluster"
	product = /obj/item/food/grown/star_cactus
	lifespan = 60
	endurance = 30
	maturation = 7
	production = 6
	yield = 3
	growthstages = 4
	genes = list(/datum/plant_gene/trait/sticky, /datum/plant_gene/trait/stinging)
	graft_gene = /datum/plant_gene/trait/sticky
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list(/datum/reagent/water = 0.08, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/medicine/c2/helbital = 0.05)

///Star Cactus Plants.
/obj/item/food/grown/star_cactus
	seed = /obj/item/seeds/star_cactus
	name = "star cacti"
	desc = "A spikey, round cluster of prickly star cacti. And no, it's not called a star cactus because it's in space."
	icon_state = "starcactus"
	filling_color = "#1c801c"
	foodtypes = VEGETABLES
	distill_reagent = /datum/reagent/consumable/ethanol/tequila

/obj/item/seeds/lavaland/polypore
	name = "pack of polypore mycelium"
	desc = "This mycelium grows into bracket mushrooms, also known as polypores. Woody and firm, shaft miners often use them for makeshift crafts."
	icon_state = "mycelium-polypore"
	species = "polypore"
	plantname = "Polypore Mushrooms"
	product = /obj/item/food/grown/ash_flora/shavings
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/consumable/sugar = 0.06, /datum/reagent/consumable/ethanol = 0.04, /datum/reagent/stabilizing_agent = 0.06, /datum/reagent/toxin/minttoxin = 0.02)

/obj/item/seeds/lavaland/porcini
	name = "pack of porcini mycelium"
	desc = "This mycelium grows into Boletus edulus, also known as porcini. Native to the late Earth, but discovered on Lavaland. Has culinary, medicinal and relaxant effects."
	icon_state = "mycelium-porcini"
	species = "porcini"
	plantname = "Porcini Mushrooms"
	product = /obj/item/food/grown/ash_flora/mushroom_leaf
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.06, /datum/reagent/consumable/vitfro = 0.04, /datum/reagent/drug/nicotine = 0.04)


/obj/item/seeds/lavaland/inocybe
	name = "pack of inocybe mycelium"
	desc = "This mycelium grows into an inocybe mushroom, a species of Lavaland origin with hallucinatory and toxic effects."
	icon_state = "mycelium-inocybe"
	species = "inocybe"
	plantname = "Inocybe Mushrooms"
	product = /obj/item/food/grown/ash_flora/mushroom_cap
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/toxin/mindbreaker = 0.04, /datum/reagent/consumable/entpoly = 0.08, /datum/reagent/drug/mushroomhallucinogen = 0.04)

/obj/item/seeds/lavaland/ember
	name = "pack of embershroom mycelium"
	desc = "This mycelium grows into embershrooms, a species of bioluminescent mushrooms native to Lavaland."
	icon_state = "mycelium-ember"
	species = "ember"
	plantname = "Embershroom Mushrooms"
	product = /obj/item/food/grown/ash_flora/mushroom_stem
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/glow, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/consumable/tinlux = 0.04, /datum/reagent/consumable/nutriment/vitamin = 0.02, /datum/reagent/drug/space_drugs = 0.02)

/obj/item/seeds/lavaland/seraka
	name = "pack of seraka mycelium"
	desc = "This mycelium grows into seraka mushrooms, a species of savoury mushrooms originally native to Tizira used in food and traditional medicine."
	icon_state = "mycelium-seraka"
	species = "seraka"
	plantname = "Seraka Mushrooms"
	product = /obj/item/food/grown/ash_flora/seraka
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/toxin/mushroom_powder = 0.1, /datum/reagent/medicine/coagulant/seraka_extract = 0.02)

//CRAFTING

/datum/crafting_recipe/mushroom_bowl
	name = "Mushroom Bowl"
	result = /obj/item/reagent_containers/glass/bowl/mushroom_bowl
	reqs = list(/obj/item/food/grown/ash_flora/shavings = 5)
	time = 30
	category = CAT_PRIMAL
/obj/item/reagent_containers/glass/bowl/mushroom_bowl
	name = "mushroom bowl"
	desc = "A bowl made out of mushrooms. Not food, though it might have contained some at some point."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"

/obj/item/reagent_containers/glass/bowl/mushroom_bowl/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance('icons/obj/lavaland/ash_flora.dmi', "fullbowl")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/item/reagent_containers/glass/bowl/mushroom_bowl/update_icon_state()
	if(!reagents || !reagents.total_volume)
		icon_state = "mushroom_bowl"
	return ..()
