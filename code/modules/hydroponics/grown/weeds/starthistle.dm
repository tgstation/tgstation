// Starthistle
/obj/item/seeds/starthistle
	name = "pack of starthistle seeds"
	desc = "A robust species of weed that often springs up in-between the cracks of spaceship parking lots."
	icon_state = "seed-starthistle"
	plant_icon_offset = 3
	species = "starthistle"
	plantname = "Starthistle"
	lifespan = 70
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = 20
	potency = 10
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	possible_mutations = list(/datum/hydroponics/plant_mutation/galaxy_thistle, /datum/hydroponics/plant_mutation/corpse_flower)
	graft_gene = /datum/plant_gene/trait/plant_type/weed_hardy


// Corpse flower
/obj/item/seeds/starthistle/corpse_flower
	name = "pack of corpse flower seeds"
	desc = "A species of plant that emits a horrible odor. The odor stops being produced in difficult atmospheric conditions."
	icon_state = "seed-corpse-flower"
	species = "corpse-flower"
	plantname = "Corpse flower"
	production = 2
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/gas_production)
	possible_mutations = list()
	reagents_add = list(/datum/reagent/toxin/formaldehyde = 0.1, /datum/reagent/fluorine = 0.1)

//Galaxy Thistle
/obj/item/seeds/galaxythistle
	name = "pack of galaxythistle seeds"
	desc = "An impressive species of weed that is thought to have evolved from the simple milk thistle. Contains flavolignans that can help repair a damaged liver."
	icon_state = "seed-galaxythistle"
	species = "galaxythistle"
	plantname = "Galaxythistle"
	product = /obj/item/food/grown/galaxythistle
	lifespan = 70
	endurance = 40
	maturation = 30
	production = 2
	yield = 20
	potency = 25
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/invasive/galaxythistle)
	possible_mutations = list()
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05, /datum/reagent/medicine/silibinin = 0.1)
	graft_gene = /datum/plant_gene/trait/invasive

/obj/item/food/grown/galaxythistle
	seed = /obj/item/seeds/galaxythistle
	name = "galaxythistle flower head"
	desc = "This spiny cluster of florets reminds you of the highlands."
	icon_state = "galaxythistle"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 35
	tastes = list("thistle" = 2, "artichoke" = 1)
