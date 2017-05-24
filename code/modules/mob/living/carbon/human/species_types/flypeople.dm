/datum/species/fly
	name = "Flyperson"
	id = "fly"
	say_mod = "buzzes"
	mutanttongue = /obj/item/organ/tongue/fly
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	armor = list("melee" = -10, "bullet" = -10, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 20, "rad" = 20, "fire" = 0, "acid" = 0)

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1
	if(istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor > 0)
			var/turf/pos = get_turf(H)
			H.vomit(0, 0, 0, 1, 1)
			playsound(pos, 'sound/effects/splat.ogg', 50, 1)
			H.visible_message("<span class='danger'>[H] vomits on the floor!</span>", \
						"<span class='userdanger'>You throw up on the floor!</span>")
	..()

/datum/species/fly/check_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon,/obj/item/weapon/melee/flyswatter))
		return 29 //Flyswatters deal 30x damage to flypeople.
	return 0
