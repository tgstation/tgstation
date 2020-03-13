///Oozes are slime-esque creatures unlike xenobio slimes that feed off of a lot of things.
/mob/living/simple_animal/hostile/ooze
	name = "Ooze"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "gelatinous"
	mob_biotypes = MOB_ORGANIC
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	//minbodytemp = 250
	//maxbodytemp = 350
	//healable = FALSE

	//speak_chance = 0
	//maxHealth = 100
	//health = 100

	//harm_intent_damage = 5
	//melee_damage_lower = 21
	//melee_damage_upper = 21
	//attack_verb_continuous = "bites"
	//attack_verb_simple = "bite"
	//attack_sound = 'sound/hallucinations/growl1.ogg'
	//a_intent = INTENT_HARM

	///Oozes have their own nutrition. Changes based on them eating
	var/ooze_nutrition = 50
	var/ooze_nutrition_loss = 0.15
	var/ooze_metabolism_modifier = 2

/mob/living/simple_animal/hostile/ooze/Initialize()
	. = ..()
	create_reagents(300)

/mob/living/simple_animal/hostile/ooze/attacked_by(obj/item/I, mob/living/user)
	if(!check_edible(I))
		return ..()
	eat_atom(I)

/mob/living/simple_animal/hostile/ooze/AttackingTarget(var/atom/A)
	. = ..()
	if(!check_edible(A))
		return ..()
	eat_atom(A)

///Handles nutrition gain/loss of mob and also makes it take damage if it's too low on nutrition, only happens for sentient mobs.
/mob/living/simple_animal/hostile/ooze/Life()
	. = ..()

	if(!mind)//no mind no change
		return

	var/nutrition_change

	//Eat a bit of all the reagents we have. Gaining nutrition for actual nutritional ones.
	for(var/i in reagents.reagent_list)
		var/datum/reagent/R = i
		var/consumption_amount = min(reagents.get_reagent_amount(R.type), ooze_metabolism_modifier * REAGENTS_METABOLISM)
		if(istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/consumable = R
			nutrition_change += consumption_amount * consumable.nutriment_factor
		reagents.remove_reagent(R.type, consumption_amount)
	nutrition_change -= 0.15
	adjust_ooze_nutrition(nutrition_change)

	if(ooze_nutrition <= 0)
		adjustBruteLoss(0.5)

///Returns whether or not the supplied movable atom is edible.
/mob/living/simple_animal/hostile/ooze/proc/check_edible(var/atom/movable/AM)
	if(ismob(AM))
		return FALSE
	var/foodtype
	if(istype(AM, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/meal = AM
		foodtype = meal.foodtype
	return foodtype & MEAT //Dont forget to add edible component compat here later

///Does ooze_nutrition + supplied amount and clamps it within 0 and 500
/mob/living/simple_animal/hostile/ooze/proc/adjust_ooze_nutrition(amount)
	return ooze_nutrition = clamp(ooze_nutrition + amount, 0, 500)

///Tries to transfer the atoms reagents then delete it
/mob/living/simple_animal/hostile/ooze/proc/eat_atom(obj/item/A)
	A.reagents.trans_to(src, A.reagents.total_volume, transfered_by = src)
	playsound(loc,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	qdel(A)
