// Ratwood soups, stews, porridges, juices and hot drinks (modular/Neu_Food/code/drinks/stew.dm, drinks_reagents.dm) as TG
// reagents, ported by hand: the porter keeps only the reagents TG already has. The pot on the hearth brews them from water and
// ingredients (survival/stews.dm), a bowl takes them out of the pot (survival/vessels.dm).
// Ratwood counts a reagent once per Life tick of two seconds, TG every second: metabolization rates go through
// ROGUE_REAGENT_RATE(), per-tick effects are scaled by the seconds of the TG tick, nutriment by ROGUE_REAGENT_NUTRITION.
// Ratwood alpha is folded into the colour. Ratwood hydration of soups and milk is in survival/thirst.dm. Ratwood's hot drinks that
// mend wounds mend them by rogue_heal_wounds() (combat/medicine.dm). Names TG already uses got another (TG wants every reagent
// name once): oat porridge, shellfish bisque, tomato broth, brewed coffee, brewed tea; the poisoned berry stew is "berry soup".

/// What Ratwood's broths and hot drinks restore, each number per Ratwood tick, scaled to the seconds of this TG tick: heal is
/// brute, burn and brain; blood comes only below normal; energy is the rogue energy of humans; wounds is the wound health mended
/// (Ratwood heal_wounds()). UPDATE_MOB_HEALTH when health changed.
/proc/rogue_reagent_restore(mob/living/carbon/drinker, seconds_per_tick, heal = 0, oxy = 0, toxin = 0, blood = 0, energy = 0, wounds = 0)
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	var/updated = FALSE
	if(blood && drinker.get_blood_volume() < BLOOD_VOLUME_NORMAL)
		drinker.adjust_blood_volume(blood * ticks, maximum = BLOOD_VOLUME_NORMAL)
	if(energy && ishuman(drinker))
		var/mob/living/carbon/human/human_drinker = drinker
		human_drinker.rogue_energy_add(energy * ticks)
	if(heal)
		if(drinker.adjust_brute_loss(-heal * ticks, updating_health = FALSE))
			updated = TRUE
		if(drinker.adjust_fire_loss(-heal * ticks, updating_health = FALSE))
			updated = TRUE
		drinker.adjust_organ_loss(ORGAN_SLOT_BRAIN, -heal * ticks)
	if(oxy && drinker.adjust_oxy_loss(-oxy * ticks, updating_health = FALSE))
		updated = TRUE
	if(toxin && drinker.adjust_tox_loss(-toxin * ticks, updating_health = FALSE))
		updated = TRUE
	if(wounds)
		drinker.rogue_heal_wounds(wounds * ticks)
	return updated ? UPDATE_MOB_HEALTH : NONE

/// The sickness of Ratwood's vile broths and waters per Ratwood tick: nausea as TG disgust, and toxins. UPDATE_MOB_HEALTH on toxins.
/proc/rogue_reagent_sicken(mob/living/carbon/drinker, seconds_per_tick, nausea = 0, toxin = 0)
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	if(nausea)
		drinker.adjust_disgust(nausea * ROGUE_NAUSEA_TO_DISGUST * ticks)
	if(toxin && drinker.adjust_tox_loss(toxin * ticks, updating_health = FALSE))
		return UPDATE_MOB_HEALTH
	return NONE

/// Ratwood soup root: whatever was boiled in the pot. A soup refills blood below normal (Ratwood +10 a tick); some heal and give
/// energy (chicken), some sicken (slop, poisoned berries, pure butter).
/datum/reagent/consumable/soup
	abstract_type = /datum/reagent/consumable/soup
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	/// Per Ratwood tick: brute, burn and brain healed, oxygen healed, extra blood below normal, energy given.
	var/rogue_heal = 0
	var/rogue_oxy_heal = 0
	var/rogue_blood = 0
	var/rogue_energy = 0
	/// Per Ratwood tick: the wound health mended (Ratwood heal_wounds() of the chicken stews, "a lesser health potion").
	var/rogue_wound_heal = 0
	/// Per Ratwood tick: nausea and toxins dealt.
	var/rogue_nausea = 0
	var/rogue_toxin = 0

/datum/reagent/consumable/soup/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_sicken(affected_mob, seconds_per_tick, rogue_nausea, rogue_toxin))
		. = UPDATE_MOB_HEALTH
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, rogue_heal, rogue_oxy_heal, 0, ROGUE_SOUP_BLOOD + rogue_blood, rogue_energy, rogue_wound_heal))
		. = UPDATE_MOB_HEALTH

// What the Ratwood hot drinks restore, per Ratwood tick (declared here, their data follows below).
/datum/reagent/water/rosewater
	var/rogue_heal = 0
	var/rogue_oxy_heal = 0
	var/rogue_toxin_heal = 0
	var/rogue_wound_heal = 0

/datum/reagent/water/rosewater_spiced
	var/rogue_heal = 0
	var/rogue_oxy_heal = 0
	var/rogue_toxin_heal = 0
	var/rogue_wound_heal = 0

/datum/reagent/consumable/caffeine
	var/rogue_heal = 0
	var/rogue_oxy_heal = 0
	var/rogue_wound_heal = 0
	/// Units of it the drinker has taken in since it reached the blood (Ratwood metabolized_caffeine): coffee lifts the night
	/// fatigue (survival/fatigue.dm) by how much of it went down.
	var/rogue_taken = 0

/datum/reagent/consumable/chocolate
	var/rogue_heal = 0
	var/rogue_oxy_heal = 0
	var/rogue_blood = 0
	var/rogue_energy = 0
	var/rogue_wound_heal = 0

/datum/reagent/consumable/spiced_chocolate
	var/rogue_heal = 0
	var/rogue_oxy_heal = 0
	var/rogue_blood = 0
	var/rogue_energy = 0
	var/rogue_wound_heal = 0

/datum/reagent/consumable/poppy_milk
	/// Toxins per Ratwood tick of an overdose.
	var/rogue_overdose_toxin = 3

// Porridges and puddings.

/datum/reagent/consumable/soup/porridge
	name = "porridge"
	description = "Softened grain boiled in water. Suitable for peasants."
	color = "#F8F0E3"
	taste_description = "porridge"
	taste_mult = 3
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.5)

/datum/reagent/consumable/soup/porridge/oatmeal
	name = "oat porridge"
	description = "Fitting for a peasant."
	color = "#c38553"
	taste_description = "oatmeal"

/datum/reagent/consumable/soup/porridge/thick
	name = "thick porridge"
	description = "Fitting for a yeoman."
	color = "#9E6B43C8"
	taste_description = "thickened porridge"
	nutriment_factor = 25 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/porridge/pudding
	name = "berried porridge-pudding"
	description = "Fitting for a nobleman."
	color = "#8E4074DE"
	taste_description = "spongey-sweet doughiness with caramelized berries"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/porridge/thickpudding
	name = "thick berried porridge-pudding"
	description = "Fitting for a king."
	color = "#8C1564DE"
	taste_description = "spongey-sweet doughiness, caramelized berries, and a hint of fragrance"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/porridge/frostedpudding
	name = "frosted porridge-pudding"
	description = "Fitting for a nobleman."
	color = "#8C88C6DE"
	taste_description = "spongey-sweet doughiness and velvety frosting"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/porridge/thickfrostedpudding
	name = "thick frosted porridge-pudding"
	description = "Fitting for a king."
	color = "#604E8EDE"
	taste_description = "spongey-sweet doughiness, velvety frosting, and a hint of fruitiness"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/porridge/fudgepudding
	name = "chocolate porridge-pudding"
	description = "Fitting for a nobleman."
	color = "#6B4A51DE"
	taste_description = "spongey-sweet doughiness and creamy fudge"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/porridge/thickfudgepudding
	name = "thick chocolate porridge-pudding"
	description = "Fitting for a king."
	color = "#44242ADE"
	taste_description = "spongey-sweet doughiness, creamy fudge, and a hint of herbiness"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/porridge/congee
	name = "congee"
	description = "Rice boiled in water until it is softened. Eaten by the poor and sick in the east. Here, it is considered a medicinal food."
	color = "#F8F0E3"

/datum/reagent/consumable/soup/porridge/frycongee
	name = "fried congee"
	description = "Boiled rice that's been lightly fried inside of a pot. Perplexingly soft for a fried foodstuff, but a little more filling."
	color = "#F7E2C0C8"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION

// Vegetable soups.

/datum/reagent/consumable/soup/veggie
	name = "vegetable broth"
	description = "Boiled, mashed, and stuck in a stew."
	taste_mult = 4
	nutriment_factor = 10 * ROGUE_REAGENT_NUTRITION
	abstract_type = /datum/reagent/consumable/soup/veggie

/datum/reagent/consumable/soup/veggie/potato
	name = "potato soup"
	color = "#869256"
	taste_description = "potato broth"

/datum/reagent/consumable/soup/veggie/thickpotato
	name = "thick potato soup"
	color = "#AE9256C8"
	taste_description = "creamy potato broth"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

/datum/reagent/consumable/soup/veggie/thickfrypotato
	name = "roasted potato soup"
	color = "#968563C8"
	taste_description = "deliciously creamy potatoes within a thick, buttery broth"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/veggie/onion
	name = "onion soup"
	color = "#a6b457"
	taste_description = "boiled onions"

/datum/reagent/consumable/soup/veggie/thickonion
	name = "thick onion soup"
	color = "#96924FC8"
	taste_description = "savory onions"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

/datum/reagent/consumable/soup/veggie/thickfryonion
	name = "roasted onion soup"
	color = "#B29252C8"
	taste_description = "deliciously soft onions within a rich, light broth"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/veggie/cabbage
	name = "cabbage soup"
	color = "#859e56"
	taste_description = "boiled cabbage"

/datum/reagent/consumable/soup/veggie/thickcabbage
	name = "thick cabbage soup"
	color = "#687A43C8"
	taste_description = "savory cabbage"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

/datum/reagent/consumable/soup/veggie/thickfrycabbage
	name = "roasted cabbage soup"
	color = "#685D34C8"
	taste_description = "deliciously rich cabbage within a savory broth"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/veggie/turnip
	name = "turnip soup"
	color = "#becf9d"
	taste_description = "boiled turnips"

/datum/reagent/consumable/soup/veggie/thickturnip
	name = "thick turnip soup"
	color = "#AFCE71C8"
	taste_description = "savory turnips"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

// Juices, butter and broth.

/datum/reagent/consumable/soup/purebutter
	name = "pure butter"
	color = "#FFE88FDE"
	taste_description = "disgustingly rich butter and a violent rumbling of the humors"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(4)
	rogue_nausea = 3
	rogue_toxin = 0.5

/datum/reagent/consumable/soup/lemon
	name = "juice of lemon"
	color = "#FFE88F"
	taste_description = "puckeringly bright lemoniness"
	nutriment_factor = 8 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/lime
	name = "juice of lime"
	color = "#BAE88F"
	taste_description = "puckeringly bright limeyness"
	nutriment_factor = 8 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/pear
	name = "juice of pear"
	color = "#BAAE8F"
	taste_description = "pleasantly crisp peariness"
	nutriment_factor = 8 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/apple
	name = "juice of apple"
	color = "#E0BE6D"
	taste_description = "pleasantly crisp appleness"
	nutriment_factor = 8 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/tangerine_marmalade
	name = "juice of tangerine"
	color = "#f0935d"
	taste_description = "extremely sweet tangerines"
	nutriment_factor = 8 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/bone_broth
	name = "bone broth"
	color = "#7F6556"
	taste_description = "nurturing warmth"
	nutriment_factor = 10 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)

// Stews.

/datum/reagent/consumable/soup/stew
	name = "thick stew"
	description = "All manners of edible bits went into this."
	taste_mult = 4
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION
	abstract_type = /datum/reagent/consumable/soup/stew

/datum/reagent/consumable/soup/stew/hardtack
	name = "hardtack stew"
	description = "Fitting for a soldier."
	color = "#9E6B43C8"
	taste_description = "salted porridge with softened flakes of crispiness"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/stew/hardtacksalo
	name = "balefire stew"
	description = "Fitting for an adventurer."
	color = "#9E4643DC"
	taste_description = "salted porridge, crispy meat, and a remarkably fatty broth"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.4)

/datum/reagent/consumable/soup/stew/thickhardtacksalo
	name = "thick balefire stew"
	description = "Fitting for a legend."
	color = "#7A3534DC"
	taste_description = "thickly salted porridge, crispy meat, a fatty broth, and a lingering warmth in the gullet"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.4)

/datum/reagent/consumable/soup/stew/egg
	name = "egg drop soup"
	color = "#dedbaf"
	taste_description = "egg soup"

/datum/reagent/consumable/soup/stew/fryegg
	name = "custardy egg drop soup"
	color = "#DDC689"
	taste_description = "creamy egg soup"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)

/datum/reagent/consumable/soup/stew/thickfryegg
	name = "scrambled cacklehash stew"
	color = "#B78F71C8"
	taste_description = "creamy eggs with chunks of crispy meat"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/lavishfryegg
	name = "lavish cacklehash stew"
	color = "#B5934AC8"
	taste_description = "sumptuously creamy eggs, chunks of crispy meat, and cheesy goodness"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1.2)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/cheese
	name = "cheese soup"
	description = "A thick cheese soup. Creamy and comforting."
	color = "#c4be70"
	taste_description = "creamy cheese"

/datum/reagent/consumable/soup/stew/thickcheese
	name = "fondue"
	description = "A ridiculously thick cheese soup. Creamy, comforting, and decadant."
	color = "#c4be70DE"
	taste_description = "velvety cheese"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/parmesan
	name = "aged cheese soup"
	description = "A thick aged cheese soup. Creamy and comforting."
	color = "#A8AA70"
	taste_description = "creamy aged cheese"
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

/datum/reagent/consumable/soup/stew/thickparmesan
	name = "aged fondue"
	description = "A ridiculously thick aged cheese soup. Creamy, comforting, and decadant."
	color = "#A8AA70DE"
	taste_description = "velvety aged cheese"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/chicken
	name = "chicken stew"
	color = "#baa21c"
	taste_description = "chicken"
	rogue_heal = 0.1 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.1
	rogue_blood = 1
	rogue_energy = 1
	rogue_wound_heal = 1

/datum/reagent/consumable/soup/stew/thickchicken
	name = "thick chicken stew"
	color = "#BA841C"
	taste_description = "savory chicken"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	rogue_heal = 0.15 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_blood = 2
	rogue_energy = 1
	rogue_wound_heal = 1

/datum/reagent/consumable/soup/stew/bakedchicken
	name = "frybird stew"
	color = "#A0781C"
	taste_description = "savory chicken with flakes of crispy skin"
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE
	rogue_heal = 0.15 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_blood = 2
	rogue_energy = 1
	rogue_wound_heal = 1

/datum/reagent/consumable/soup/stew/bakedthickchicken
	name = "thick frybird stew"
	color = "#8F6119C8"
	taste_description = "tender chicken with flakes of crispy skin"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD
	rogue_heal = 0.2 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_blood = 3
	rogue_energy = 1
	rogue_wound_heal = 1

/datum/reagent/consumable/soup/stew/veggiethickchicken
	name = "frybird stew with vegetables"
	color = "#8F6916C8"
	taste_description = "savory chicken with slow-roasted vegetables, flakes of crispy skin, and a sense of lingering warmth"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD
	rogue_heal = 0.2 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_blood = 3
	rogue_energy = 1
	rogue_wound_heal = 1

/datum/reagent/consumable/soup/stew/pepperchicken
	name = "pepper-spiced frybird stew"
	color = "#A0421CC8"
	taste_description = "deliciously tender chicken with flakes of crispy skin, and a hint of tongue-tickling spice"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_VERYGOOD
	rogue_heal = 0.25 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_blood = 4
	rogue_energy = 1
	rogue_wound_heal = 1

/datum/reagent/consumable/soup/stew/lavishchicken
	name = "lavish frybird stew"
	color = "#A0421CC8"
	taste_description = "sumptuously tender chicken with flakes of crispy skin, buttery richness, and a hint of tongue-tickling spice"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD
	rogue_heal = 0.3 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_blood = 5
	rogue_energy = 1
	rogue_wound_heal = 2

/datum/reagent/consumable/soup/stew/meat
	name = "meat stew"
	color = "#80432a"
	taste_description = "meat"

/datum/reagent/consumable/soup/stew/frymeat
	name = "brisket stew"
	color = "#7F3518C8"
	taste_description = "slow-roasted meat"
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/veggiefrymeat
	name = "brisket stew with vegetables"
	color = "#633012C8"
	taste_description = "savory meat with slow-roasted vegetables, with a refreshingly rich aftertaste"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/pepperfrymeat
	name = "pepper-spiced brisket stew"
	color = "#892214C8"
	taste_description = "deliciously tender meat, and a hint of tongue-tickling spice"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/lavishfrymeat
	name = "lavish brisket stew"
	color = "#722616C8"
	taste_description = "sumptuously tender meat, a rich and savory broth, and a hint of tongue-tickling spice"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/pork
	name = "fatty meat stew"
	color = "#80432a"
	taste_description = "soft and savory pork"

/datum/reagent/consumable/soup/stew/thickpork
	name = "fatty brisket stew"
	color = "#7F3518"
	taste_description = "slow-roasted pork"
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

/datum/reagent/consumable/soup/stew/frypork
	name = "crispy and fatty meaty stew"
	color = "#633012C8"
	taste_description = "savory pork with flakes of crispiness"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/thickfrypork
	name = "crispy and fatty brisket stew"
	color = "#892214C8"
	taste_description = "tongue-meltingly soft pork with flakes of crispiness"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/viscera_broth
	name = "offal stew"
	color = "#B65571"
	taste_description = "overpoweringly strange-tasting, with a mildly savory aftertaste"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/stew/slop
	name = "slop"
	color = "#18130E"
	taste_description = "charred giblets with a gravely aftertaste, and just a pinch of regret"
	nutriment_factor = 10 * ROGUE_REAGENT_NUTRITION
	rogue_nausea = 3
	rogue_toxin = 1

/datum/reagent/consumable/soup/stew/fish
	name = "fish stew"
	color = "#c7816e"
	taste_description = "fish"

/datum/reagent/consumable/soup/stew/fryfish
	name = "roasted fish stew"
	color = "#C6725DC8"
	taste_description = "flaky fish in a gently creamy broth"
	nutriment_factor = 25 * ROGUE_REAGENT_NUTRITION
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/veggiefryfish
	name = "roasted fish stew with vegetables"
	color = "#C67C78C8"
	taste_description = "flaky fish and slow-roasted vegetables in a gently creamy broth"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/pepperfryfish
	name = "pepper-spiced fish stew"
	color = "#C65D5DC8"
	taste_description = "flaky fish in a sharp, creamy broth with tongue-tingling spices"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/lavishfryfish
	name = "lavish fish stew"
	color = "#C17070C8"
	taste_description = "sumptuously flaky fish in a rich, creamy broth with subtle notes of sweetness"
	nutriment_factor = 40 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/evilfryfish
	name = "evil fish stew"
	color = "#FF3200"
	taste_description = "an overwhelming sense of dread, whispers of progress, and a surprisingly rich aftertaste"
	nutriment_factor = 66 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(6)

/datum/reagent/consumable/soup/stew/rabbit
	name = "cabbit stew"
	color = "#c59182"
	taste_description = "cabbit"

/datum/reagent/consumable/soup/stew/fryrabbit
	name = "roasted cabbit stew"
	color = "#BC7A6FC8"
	taste_description = "slow-roasted cabbit with a surprisingly pleasant aftertaste"
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/veggiefryrabbit
	name = "roasted cabbit stew with vegetables"
	color = "#A35D46C8"
	taste_description = "savory cabbit with caramelized vegetables, with a robust yet subdued aftertaste"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/volf
	name = "volf stew"
	color = "#80432a"
	taste_description = "gamey meat"

/datum/reagent/consumable/soup/stew/fryvolf
	name = "vriskette stew"
	color = "#7F3518C8"
	taste_description = "slow-roasted and gamey meat"
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/veggiefryvolf
	name = "vriskette stew with vegetables"
	color = "#633012C8"
	taste_description = "savory and gamey meat with slow-roasted vegetables, and a pleasantly warm aftertaste"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/kingvolf
	name = "king's stew"
	color = "#892214C8"
	taste_description = "deliciously soft and gamey meat, contrasted with crunchy vegetables and a hint of tongue-tickling spice"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/bisque
	name = "shellfish bisque"
	color = "#FFA74F"
	taste_description = "shellfish"

/datum/reagent/consumable/soup/stew/frybisque
	name = "roasted bisque"
	color = "#ffb74fC8"
	taste_description = "roasted shellfish, cradled in a sea of savory-yet-smooth broth"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/lavishfrybisque
	name = "lavish bisque"
	color = "#FFC688C8"
	taste_description = "sumptuously roasted shellfish, savory-yet-smooth broth, and a hint of spiced butteriness"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/seafoodbroil
	name = "seabroil chowder"
	color = "#FFA74FC8"
	taste_description = "creamy shellfish with the occassional crunch"
	nutriment_factor = 25 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/stew/fryseafoodbroil
	name = "roasted seabroil chowder"
	color = "#ffb74fDE"
	taste_description = "roasted shellfish within a creamy, delicate broth"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/lavishfryseafoodbroil
	name = "lavish seabroil chowder"
	color = "#FFE3D9DE"
	taste_description = "sumptuously creamy broth with a hint of moist clammage"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/meatrice
	name = "fried congee with roasted meat"
	color = "#E5C099FA"
	taste_description = "mushy, savory-brothed rice with chunks of tender meat"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/eggrice
	name = "fried congee with cackleberries"
	color = "#F7C997FA"
	taste_description = "mushy, savory-brothed rice with creamy yolkage and crispy eggs"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/shrimprice
	name = "fried congee with roasted shrimp"
	color = "#F7D5BEFA"
	taste_description = "mushy, savory-brothed rice with salty yet subdued shellfish"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/cheeserice
	name = "fried congee with melted cheese"
	color = "#F7E297FA"
	taste_description = "mushy, savory-brothed rice that's been smothered in cheesy goodness"
	nutriment_factor = 25 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/lavishfryrice
	name = "lavish brisket-congee"
	color = "#E0AF97FA"
	taste_description = "sumptuous, pillowy rice with slow-braised meats with hints of butteriness and cheese"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/soup/stew/yucky
	name = "strange stew"
	color = "#9e559c"
	taste_description = "overpoweringly strange-tasting, with a mildly tangy aftertaste"

/datum/reagent/consumable/soup/stew/fryyucky
	name = "strange brisket stew"
	color = "#9E6D84C8"
	taste_description = "a pleasantly implacable meat, somewhere between volf and chicken"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/berry
	name = "berry stew"
	color = "#863333"
	taste_description = "sweet berries"

/datum/reagent/consumable/soup/stew/berry_poisoned
	name = "berry soup"
	color = "#863333"
	taste_description = "suspiciously bitter berries"
	rogue_nausea = 3
	rogue_toxin = 2

/datum/reagent/consumable/soup/stew/garlick_soup
	name = "garlick soup"
	color = "#FAF9F6"
	taste_description = "clear sinuses"

/datum/reagent/consumable/soup/stew/cucumber_soup
	name = "cucumber soup"
	color = "#98fb98"
	taste_description = "rich cucumbers"

/datum/reagent/consumable/soup/stew/thickcucumber_soup
	name = "thick cucumber soup"
	color = "#98fb98"
	taste_description = "rich and chunky cucumbers"
	nutriment_factor = 25 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/stew/eggplant_soup
	name = "eggplant soup"
	color = "#fff8e3"
	taste_description = "tasty eggplant"

/datum/reagent/consumable/soup/stew/aubergine_soup
	name = "aubergine stew"
	color = "#D9E4E3"
	taste_description = "tender eggplant with nibblings of roasted mince"
	nutriment_factor = 25 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/lavishaubergine_soup
	name = "lavish aubergine stew"
	color = "#D9C6E3C8"
	taste_description = "sumptuously tender eggplant, nibblings of roasted mince, and a creamy broth"
	nutriment_factor = 35 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.6)
	quality = DRINK_GOOD

/datum/reagent/consumable/soup/stew/carrot_stew
	name = "carrot stew"
	color = "#f26818"
	taste_description = "savory carrots"

/datum/reagent/consumable/soup/stew/thickcarrot_stew
	name = "roasted carrot stew"
	color = "#f26818C8"
	taste_description = "savory and caramelized carrots"
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/nutty_stew
	name = "nutty stew"
	color = "#807b78"
	taste_description = "nutty"

/datum/reagent/consumable/soup/stew/tomato_soup
	name = "tomato broth"
	color = "#db5230"
	taste_description = "home"
	metabolization_rate = ROGUE_REAGENT_RATE(0.5)

/datum/reagent/consumable/soup/stew/plum_soup
	name = "plum soup"
	color = "#9c305b"
	taste_description = "sweet plums"

/datum/reagent/consumable/soup/stew/squash_soup
	name = "squash soup"
	color = "#C98C42"
	taste_description = "autumn's loving embrace"
	nutriment_factor = 15 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)

/datum/reagent/consumable/soup/stew/frysquash_soup
	name = "roasted squash soup"
	color = "#D3702E"
	taste_description = "a hearth kindled within your chest, and a pleasantly savory aftertaste"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(0.8)
	quality = DRINK_NICE

/datum/reagent/consumable/soup/stew/survival_broth
	name = "briquebroth"
	color = "#693346DE"
	taste_description = "heartwarmingly thick and salty, with little bursts of sweetness and pepperiness"
	nutriment_factor = 30 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/stew/thicksurvival_broth
	name = "thick briquebroth"
	color = "#681936FA"
	taste_description = "heartwarmingly thick and savory, with bursts of sweetness and pepperiness"
	nutriment_factor = 45 * ROGUE_REAGENT_NUTRITION

/datum/reagent/consumable/soup/stew/saltmeat_stew
	name = "salted meat stew"
	color = "#693346FA"
	taste_description = "overwhelmingly salty, with hints of savoriness and meatiness"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION

// Hot drinks (drinks_reagents.dm).

/datum/reagent/water/rosewater
	name = "rosa tea"
	description = "Steeped rosa petals with mild health regeneration and antidotal properties."
	color = "#f398b6AD"
	taste_description = "floral sweetness"
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	overdose_threshold = 0
	rogue_heal = 0.1 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.1
	rogue_toxin_heal = 2
	rogue_wound_heal = 1

/datum/reagent/water/rosewater_spiced
	name = "spiced rosa tea"
	description = "Spiced rose petals that help to reinvigorate the body's humors, providing modest health regeneration and antidotal properties."
	color = "#F2638CAD"
	taste_description = "floral spiciness"
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	overdose_threshold = 0
	rogue_heal = 0.46 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.2
	rogue_toxin_heal = 3
	rogue_wound_heal = 1

/datum/reagent/consumable/caffeine
	name = "caffeine"
	description = "Why are you seeing this?"
	overdose_threshold = 60
	abstract_type = /datum/reagent/consumable/caffeine

/datum/reagent/consumable/caffeine/coffee
	name = "brewed coffee"
	description = "Coffee beans brewed into a hot drink. With a hint of bitterness. Rejuvenating."
	color = "#482000C8"
	taste_description = "caramelized bitterness"
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	quality = DRINK_NICE

/datum/reagent/consumable/caffeine/coffee_spiced
	name = "spiced coffee"
	description = "Spiced offee beans brewed into a hot drink, with a hint of bitterness. Modestly rejuvenating."
	color = "#8C4221C8"
	taste_description = "caramelized spiciness"
	metabolization_rate = ROGUE_REAGENT_RATE(0.5)
	quality = DRINK_GOOD
	rogue_heal = 0.3 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_wound_heal = 1

/datum/reagent/consumable/caffeine/tea
	name = "brewed tea"
	description = "Tea leaves brewed into a hot drink. Slight hint of bitterness. Smooth."
	color = "#508141AD"
	taste_description = "smooth grassiness"
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	quality = DRINK_NICE

/datum/reagent/consumable/caffeine/tea_spiced
	name = "spiced tea"
	description = "Spiced tea leaves brewed into a hot drink. Slight hint of bitterness. Smoothly rejuvinating."
	color = "#788C41AD"
	taste_description = "spiced grassiness"
	metabolization_rate = ROGUE_REAGENT_RATE(0.5)
	quality = DRINK_GOOD
	rogue_heal = 0.3 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_wound_heal = 1

/datum/reagent/consumable/poppy_milk
	name = "poppy milk"
	description = "Infused liquid of the Poppy, this one leaves your mouth and mind numb after drinking. Drinking more than a cup might not be good for your health..."
	color = "#dbd7d5C8"
	taste_description = "instant numbness"
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	overdose_threshold = 25
	quality = DRINK_NICE
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/consumable/chocolate
	name = "hot chocolate"
	description = "Lovingly smooth, velvety, and rich. Provides a modest portion of health regeneration, and minor stamina regeneration."
	color = "#3F291CFA"
	taste_description = "a throat-clinging sweetness, paired with a rich and warming aftertaste"
	quality = DRINK_GOOD
	rogue_heal = 0.3 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_wound_heal = 1
	rogue_blood = 1
	rogue_energy = 1

/datum/reagent/consumable/spiced_chocolate
	name = "spiced chocolate"
	description = "Impossibly smooth, velvety, and rich. Provides a generous portion of health regeneration, and minor stamina regeneration."
	color = "#6D472FFA"
	taste_description = "an impossible blemd of richness, sweetness, and a hint of throat-tingling spiciness"
	quality = DRINK_VERYGOOD
	rogue_heal = 0.5 * ROGUE_REAGENT_EFFECT
	rogue_oxy_heal = 0.15
	rogue_wound_heal = 1
	rogue_blood = 2
	rogue_energy = 2

/datum/reagent/water/rosewater/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, rogue_heal, rogue_oxy_heal, rogue_toxin_heal, wounds = rogue_wound_heal))
		. = UPDATE_MOB_HEALTH

/datum/reagent/water/rosewater_spiced/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, rogue_heal, rogue_oxy_heal, rogue_toxin_heal, wounds = rogue_wound_heal))
		. = UPDATE_MOB_HEALTH

/datum/reagent/consumable/caffeine/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	rogue_taken = 0

/// Ratwood caffeine: coffee and tea give energy and the Vigorized buff (survival/fatigue.dm), the spiced ones also heal a little,
/// and what went down lifts the night fatigue; too much of it shakes the drinker and may stop the heart. Ratwood's caffeine
/// addiction (a vice of the character menu) is not ported.
/datum/reagent/consumable/caffeine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, rogue_heal, rogue_oxy_heal, 0, 0, ROGUE_CAFFEINE_ENERGY, rogue_wound_heal))
		. = UPDATE_MOB_HEALTH
	affected_mob.apply_status_effect(/datum/status_effect/rogue_vigorized)
	rogue_taken += metabolization_rate * seconds_per_tick
	affected_mob.rogue_coffee_wakes(rogue_taken, metabolization_rate * ROGUE_REAGENT_TICK)

/datum/reagent/consumable/caffeine/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.adjust_jitter_up_to(ROGUE_CAFFEINE_JITTER * seconds_per_tick / ROGUE_REAGENT_TICK, ROGUE_CAFFEINE_JITTER_MAX)
	if(!iscarbon(affected_mob) || !SPT_PROB(ROGUE_CAFFEINE_HEART_CHANCE / ROGUE_REAGENT_TICK, seconds_per_tick))
		return
	var/mob/living/carbon/heart_owner = affected_mob
	heart_owner.set_heartattack(TRUE)

/// Ratwood poppy milk numbs (its ozium buff is TG analgesia while it lasts); more than a cup poisons.
/datum/reagent/consumable/poppy_milk/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(affected_mob.adjust_tox_loss(rogue_overdose_toxin * seconds_per_tick / ROGUE_REAGENT_TICK, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/datum/reagent/consumable/chocolate/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, rogue_heal, rogue_oxy_heal, 0, rogue_blood, rogue_energy, rogue_wound_heal))
		. = UPDATE_MOB_HEALTH

/datum/reagent/consumable/spiced_chocolate/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, rogue_heal, rogue_oxy_heal, 0, rogue_blood, rogue_energy, rogue_wound_heal))
		. = UPDATE_MOB_HEALTH

/// Ratwood allspice (powderspice.dm): spices simmered long in the pot; every sip of the broth is a great meal.
/datum/reagent/allspice
	name = "allspice"
	description = "A blend of toasted spices, temptingly aromatic to the senses."
	color = "#CE8C33"
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	taste_description = "fragrant spiciness"

/datum/reagent/allspice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/rogue_food_buff/great_meal)

// Other Ratwood food reagents the kitchen uses.

/// Ratwood cooking oils (food_reagents.dm oil); only tallow is ported.
/datum/reagent/consumable/oil
	abstract_type = /datum/reagent/consumable/oil

/// Ratwood tallow (food_reagents.dm oil/tallow): fat melted in a dry pot on the hearth, for deep frying (survival/stews.dm).
/datum/reagent/consumable/oil/tallow
	name = "tallow"
	description = "Oil made from rendering animal fat. Used for deep frying."
	color = "#A6987B"
	taste_description = "rendered fat"
	nutriment_factor = 20 * ROGUE_REAGENT_NUTRITION

/// Ratwood salted milk (others/dairy.dm): milk with salt worked in, for churning butter and straining fresh cheese.
/datum/reagent/consumable/milk/salted
	name = "salted milk"
	description = "Milk with salt worked into it, ready to be churned into butter or strained into cheese."
	taste_description = "salty milk"

/// Ratwood dirty water (other_reagents.dm water/gross): from swamps, muddy rivers and sewers. It sickens whoever drinks it
/// unless they have the stomach of an orc, a goblin or a Dendorite; boiled in a pot it comes clean.
/datum/reagent/water/gross
	name = "dirty water"
	description = "Murky, smelly water. Boiling it should make it safe to drink."
	color = "#98934BC6"
	taste_description = "something vile"
	rogue_harmful = TRUE

/datum/reagent/water/gross/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_NASTY_EATER) || HAS_TRAIT(affected_mob, TRAIT_WILD_EATER))
		return
	if(rogue_reagent_sicken(affected_mob, seconds_per_tick, ROGUE_GROSS_WATER_NAUSEA, ROGUE_GROSS_WATER_TOXIN))
		. = UPDATE_MOB_HEALTH

/// Ratwood grosswaterboil: dirty water boiled in a pot comes clean.
/datum/chemical_reaction/food/rogue_boiled_water
	results = list(/datum/reagent/water = 1)
	required_reagents = list(/datum/reagent/water/gross = 1)
	required_temp = ROGUE_BOIL_TEMPERATURE
	mob_react = FALSE
