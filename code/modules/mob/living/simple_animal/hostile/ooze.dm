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

/mob/living/simple_animal/hostile/ooze/AttackingTarget(atom/A)
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
/mob/living/simple_animal/hostile/ooze/proc/check_edible(atom/movable/AM)
	if(ismob(AM))
		return FALSE
	var/foodtype
	if(istype(AM, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/meal = AM
		foodtype = meal.foodtype
	return foodtype & MEAT //Dont forget to add edible component compat here later

///Does ooze_nutrition + supplied amount and clamps it within 0 and 500
/mob/living/simple_animal/hostile/ooze/proc/adjust_ooze_nutrition(amount)
	ooze_nutrition = clamp(ooze_nutrition + amount, 0, 500)
	updateNutritionDisplay()

///Tries to transfer the atoms reagents then delete it
/mob/living/simple_animal/hostile/ooze/proc/eat_atom(obj/item/A)
	A.reagents.trans_to(src, A.reagents.total_volume, transfered_by = src)
	playsound(loc,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	qdel(A)

///Updates the display that shows the mobs nutrition
/mob/living/simple_animal/hostile/ooze/proc/updateNutritionDisplay()
	if(hud_used) //clientless oozes
		hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='green'>[round(getPlasma())]</font></div>"

///Child of the ooze mob which is fast and is more suited for assassin esque behavior.
/mob/living/simple_animal/hostile/ooze/gelatinous
	name = "Gelatinous Cube"
	desc = "It's a gummy cube, it's a gummy cube, it's a gummy gummy gummy gummy gummy cube."
	speed = 1
	///The ability to give yourself a metabolic speed boost which raises heat
	var/datum/action/innate/metabolicboost/boost
	///The ability to consume mobs
	var/obj/effect/proc_holder/consume/consume

///Initializes the mobs abilities and gives them to the mob
/mob/living/simple_animal/hostile/ooze/gelatinous/Initialize()
	. = ..()
	boost = new
	boost.Grant(src)
	consume = new
	AddAbility(consume)

/datum/action/cooldown/metabolicboost
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	cooldown_time = 240
	var/nutrition_cost

/datum/action/cooldown/metabolicboost/IsAvailable()
	. = ..()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	if(. && ooze.ooze_nutrition >= 10)
		return TRUE

/datum/action/cooldown/metabolicboost/Trigger()
	. = ..()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.add_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	var/timerid = addtimer(CALLBACK(src, .proc/HeatUp), 1 SECONDS, TIMER_STOPPABLE) //Heat up every second
	addtimer(CALLBACK(ooze, .proc/FinishSpeedup, timerid), 6 SECONDS)
	ooze.adjust_ooze_nutrition(-10)

/datum/action/cooldown/metabolicboost/proc/HeatUp()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.increase_temperature(5)

/datum/action/cooldown/metabolicboost/proc/FinishSpeedup(timerid)
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.remove_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	deltimer(timerid)



/obj/effect/proc_holder/consume
	name = "Consume"
	panel = "Spider"
	active = FALSE
	datum/action/spell_action/action = null
	desc = "Consume your target to get some nutrition"
	ranged_mousepointer = 'icons/effects/wrap_target.dmi'
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "wrap_0"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/consume/Initialize()
	. = ..()
	action = new(src)

/obj/effect/proc_holder/consume/update_icon()
	action.button_icon_state = "wrap_[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/consume/Click()
	if(!istype(usr, /mob/living/carbon))
		return FALSE
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/user = usr
	activate(user)
	return TRUE

/obj/effect/proc_holder/wrap/proc/activate(mob/living/user)
	var/message
	if(active)
		message = "<span class='notice'>You no longer prepare to wrap something in a cocoon.</span>"
		remove_ranged_ability(message)
	else
		message = "<span class='notice'>You prepare to wrap something in a cocoon. <B>Left-click your target to start wrapping!</B></span>"
		add_ranged_ability(user, message, TRUE)
		return 1

/obj/effect/proc_holder/wrap/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !istype(ranged_ability_user, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		remove_ranged_ability()
		return

	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/user = ranged_ability_user

	if(user.Adjacent(target) && (ismob(target) || isobj(target)))
		var/atom/movable/target_atom = target
		if(target_atom.anchored)
			return
		user.cocoon_target = target_atom
		INVOKE_ASYNC(user, /mob/living/simple_animal/hostile/poison/giant_spider/nurse/.proc/cocoon)
		remove_ranged_ability()
		return TRUE

/obj/effect/proc_holder/wrap/on_lose(mob/living/carbon/user)
	remove_ranged_ability()
