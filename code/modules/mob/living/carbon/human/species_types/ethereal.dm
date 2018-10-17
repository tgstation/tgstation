/datum/species/ethereal
	name = "Ethereal"
	id = "ethereal"
	attack_verb = "burn"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	exotic_bloodtype = "L"
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	attack_type = BURN //burn bish
	hair_color = "mutcolor"
	damage_overlay_type = null //We are too cool for regular damage overlays
	species_traits = list(DYNCOLORS, NOSTOMACH, NOHUNGER)
	var/current_color
	var/ethereal_charge = 100

	var/static/r1 = 151
	var/static/g1 = 238
	var/static/b1 = 99
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149


/datum/species/ethereal/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/H)
	.=..()
	if(H.stat != DEAD)
		var/percent = max(H.health, 0) / 100
		current_color = rgb(r2 + ((r1-r2)*percent), g2 + ((g1-g2)*percent), b2 + ((b1-b2)*percent))
		H.set_light(1 + (2 * percent), 1 + (1 * percent), current_color)
		H.dna.features["mcolor"] = copytext(current_color, 2)
		to_chat(world, "[percent]")
	else
		H.set_light(0)
		H.dna.features["mcolor"] = rgb(128,128,128)
	H.update_body()

