/obj/item/seeds/seedling
	name = "seedling seed pack"
	desc = "These seeds grow into a floral assistant which can help look after other plants!"
	icon_state = "seed-seedling"
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	species = "seedling"
	plantname = "Seedling Plant"
	product = /mob/living/basic/seedling
	lifespan = 40
	endurance = 7
	maturation = 10
	production = 1
	growthstages = 2
	yield = 1
	instability = 15
	potency = 30

/obj/item/seeds/seedling/harvest(mob/harvester)
	var/obj/machinery/hydroponics/parent = loc
	var/list/grow_locations = get_adjacent_open_turfs(parent)
	var/turf/final_location = length(grow_locations) ? pick(grow_locations) : get_turf(parent)
	var/mob/living/basic/seedling/seed_pet = new product(final_location)
	seed_pet.befriend(harvester)
	parent.update_tray(user = harvester, product_count = 1)

/obj/item/seeds/seedling/evil
	product = /mob/living/basic/seedling/meanie
	icon_state = "seed-seedling-evil"
