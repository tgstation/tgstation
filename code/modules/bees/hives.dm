/obj/structure/hive
	name = "hive"
	icon = 'icons/obj/beekeeping/hives.dmi'
	var/obj/item/bees/queen/queen = null
	anchored = TRUE
	density = TRUE
	var/list/frames = list()
	var/obj/item/bees/princess/princess
	var/obj/item/bees/drone/drone
	var/nutrition = 0
/obj/structure/hive/Initialize()
	. = ..()
/obj/structure/hive/process()
	if(!queen)
		if(princess & drone)
			queen = new /obj/item/bees/queen(src)
			queen.species = princess.specie
			queen.strength = princess.strength + drone.strength /2
			queen.aggresivity = drone.aggresivity
			queen.size = princess.size
			queen.endurance = princess.endurance
			if(prob(50))queen.endurance = drone.endurance
			queen.sting_potency = princess.sting_potency
			queen.production_speed = princess.production_speed + drone.production_speed/2

	else
		if(frames.len >0 | istype(src , /obj/structure/hive/natural))
			var/N = 200
			for(var/obj/item/reagent_containers/frame/F in frames)
				nutrition += F.get_reagent_amount(/datum/reagent/consumable/honey)*4
				if(nutrition>200)
					F.remove_reagent(/datum/reagent/consumable/honey,N/4)
					nutrition = 200
					break
				else
					F.del_reagent(/datum/reagent/consumable/sugar)
					N-=F.get_reagent_amount(/datum/reagent/consumable/honey)*4
				nutrition += F.get_reagent_amount(/datum/reagent/consumable/sugar)*2
				if(nutrition>200)
					F.remove_reagent(/datum/reagent/consumable/sugar,N/2)
					nutrition = 200
					break
				else
					F.del_reagent(/datum/reagent/consumable/sugar)
					N-=F.get_reagent_amount(/datum/reagent/consumable/sugar)*2
				nutrition += F.get_reagent_amount(/datum/reagent/consumable/nutriment)/2
				if(nutrition>200)
					F.remove_reagent(/datum/reagent/consumable/nutriment,N*2)
					nutrition = 200
					break
				else
					F.del_reagent(/datum/reagent/consumable/nutriment)
					N-=F.get_reagent_amount(/datum/reagent/consumable/nutriment)/2	queen.life = queen.endurance