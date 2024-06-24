/datum/reagent/australium
	name = "Australium"
	description = "Causes people to invert into austrilians, has interesting effects on chemicals aswell."
	color = "#9b9924"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS
	taste_description = "spiders"
	requires_process = TRUE

/datum/reagent/australium/on_mob_add(mob/living/L, amount)
	. = ..()
	var/matrix/m180 = matrix(L.transform)
	m180.Turn(180)
	animate(L, transform = m180, time = 3)

/datum/reagent/australium/on_mob_delete(mob/living/L)
	. = ..()
	var/matrix/m180 = matrix(L.transform)
	m180.Turn(180)
	animate(L, transform = m180, time = 3)

/datum/reagent/australium/reagent_fire(obj/item/reagent_containers/host)
	for(var/datum/reagent/listed_reagent in host.reagents.reagent_list)
		if(!(isnull(listed_reagent.inverse_chem) || listed_reagent.inverse_chem == /datum/reagent/inverse ))
			var/listed_volume = listed_reagent.volume
			var/datum/reagent/inverse_reagent = listed_reagent.inverse_chem
			host.reagents.remove_reagent(listed_reagent.type, listed_volume)
			host.reagents.add_reagent(inverse_reagent, listed_volume)
