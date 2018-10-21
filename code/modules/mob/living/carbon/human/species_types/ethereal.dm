/datum/species/ethereal
	name = "Ethereal"
	id = "ethereal"
	attack_verb = "burn"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ethereal
	exotic_bloodtype = "LE" //Liquid Electricity. fuck you think of something better gamer
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	attack_type = BURN //burn bish
	damage_overlay_type = "" //We are too cool for regular damage overlays
	species_traits = list(DYNCOLORS, NOSTOMACH)
	inherent_traits = list(TRAIT_NOHUNGER)
	default_features = list("mcolor" = "97ee63")
	fixed_mut_color = "97ee63"
	default_color = "#97ee63"
	sexes = FALSE //no fetish content allowed
	toxic_food = NONE
	var/current_color
	var/ethereal_charge = ETHEREAL_CHARGE_FULL

	var/static/r1 = 151
	var/static/g1 = 238
	var/static/b1 = 99
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149


/datum/species/ethereal/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	.=..()
	spec_updatehealth(C)


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
		fixed_mut_color = copytext(current_color, 2)
	else
		H.set_light(0)
		fixed_mut_color = rgb(128,128,128)
	H.update_body()

/datum/species/ethereal/spec_life(mob/living/carbon/human/H)
	.=..()
	handle_charge(H)


/datum/species/ethereal/proc/handle_charge(mob/living/carbon/human/H)
	var/charge_rate = ETHEREAL_CHARGE_FACTOR
	brutemod = 1.25
	adjust_charge(-charge_rate)
	switch(ethereal_charge)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			H.throw_alert("ethereal_charge", /obj/screen/alert/etherealcharge, 3)
			apply_damage(0.5, BRUTE)
			brutemod = 1.75
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			H.throw_alert("ethereal_charge", /obj/screen/alert/etherealcharge, 2)
			brutemod = 1.5
		if(ETHEREAL_CHARGE_NORMAL to ETHEREAL_CHARGE_ALMOSTFULL)
			H.throw_alert("ethereal_charge", /obj/screen/alert/etherealcharge, 1)
		else
			H.clear_alert("ethereal_charge")

/datum/species/ethereal/proc/adjust_charge(var/change)
	ethereal_charge = CLAMP(ethereal_charge + change, ETHEREAL_CHARGE_NONE, ETHEREAL_CHARGE_FULL)

/datum/species/ethereal/proc/set_charge(var/change)
	ethereal_charge = CLAMP(change, ETHEREAL_CHARGE_NONE, ETHEREAL_CHARGE_FULL)