/obj/item/seeds/seedling
	name = "pack of seedling seeds"
	desc = "These seeds grow into a floral assistant which can help look after other plants!"
	icon_state = "seed-seedling"
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon = 'icons/obj/service/hydroponics/seeds.dmi'
	species = "seedling"
	plantname = "Seedling Plant"
	product = /mob/living/basic/seedling
	lifespan = 40
	endurance = 7
	maturation = 10
	production = 1
	growthstages = 2
	yield = 10
	potency = 30

/obj/item/seeds/seedling/harvest(mob/harvester)
	var/atom/movable/parent = loc
	var/list/grow_locations = get_adjacent_open_turfs(parent)
	var/turf/final_location = length(grow_locations) ? pick(grow_locations) : get_turf(parent)
	var/mob/living/basic/seedling/seed_pet = new product(final_location)
	seed_pet.befriend(harvester)

/obj/item/seeds/seedling/evil
	product = /mob/living/basic/seedling/meanie
	icon_state = "seed-seedling-evil"
