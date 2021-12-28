///Oozes are slime-esque creatures, they are highly gluttonous creatures primarily intended for player controll.
/mob/living/simple_animal/hostile/ooze
	name = "Ooze"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "gelatinous"
	icon_living = "gelatinous"
	icon_dead = "gelatinous_dead"
	mob_biotypes = MOB_ORGANIC
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	hud_type = /datum/hud/ooze
	minbodytemp = 250
	maxbodytemp = INFINITY
	faction = list("slime")
	melee_damage_lower = 10
	melee_damage_upper = 10
	health = 200
	maxHealth = 200
	attack_verb_continuous = "slimes"
	attack_verb_simple = "slime"
	attack_sound = 'sound/effects/blobattack.ogg'
	combat_mode = TRUE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	atom_size = MOB_SIZE_LARGE
	initial_language_holder = /datum/language_holder/slime
	footstep_type = FOOTSTEP_MOB_SLIME
	///Oozes have their own nutrition. Changes based on them eating
	var/ooze_nutrition = 50
	var/ooze_nutrition_loss = -0.15
	var/ooze_metabolism_modifier = 2
	///Bitfield of edible food types
	var/edible_food_types = MEAT

/mob/living/simple_animal/hostile/ooze/Initialize(mapload)
	. = ..()
	create_reagents(300)
	add_cell_sample()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/ooze/attacked_by(obj/item/I, mob/living/user)
	if(!eat_atom(I, TRUE))
		return ..()

/mob/living/simple_animal/hostile/ooze/AttackingTarget(atom/attacked_target)
	if(!eat_atom(attacked_target))
		return ..()

///Handles nutrition gain/loss of mob and also makes it take damage if it's too low on nutrition, only happens for sentient mobs.
/mob/living/simple_animal/hostile/ooze/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()

	if(!mind && stat != DEAD)//no mind no change
		return

	var/nutrition_change = ooze_nutrition_loss

	//Eat a bit of all the reagents we have. Gaining nutrition for actual nutritional ones.
	for(var/i in reagents.reagent_list)
		var/datum/reagent/reagent = i
		var/consumption_amount = min(reagents.get_reagent_amount(reagent.type), ooze_metabolism_modifier * REAGENTS_METABOLISM * delta_time)
		if(istype(reagent, /datum/reagent/consumable))
			var/datum/reagent/consumable/consumable = reagent
			nutrition_change += consumption_amount * consumable.nutriment_factor
		reagents.remove_reagent(reagent.type, consumption_amount)
	adjust_ooze_nutrition(nutrition_change)

	if(ooze_nutrition <= 0)
		adjustBruteLoss(0.25 * delta_time)

///Does ooze_nutrition + supplied amount and clamps it within 0 and 500
/mob/living/simple_animal/hostile/ooze/proc/adjust_ooze_nutrition(amount)
	ooze_nutrition = clamp(ooze_nutrition + amount, 0, 500)
	updateNutritionDisplay()

///Tries to transfer the atoms reagents then delete it
/mob/living/simple_animal/hostile/ooze/proc/eat_atom(atom/eat_target, silent)
	if(SEND_SIGNAL(eat_target, COMSIG_OOZE_EAT_ATOM, src, edible_food_types) & COMPONENT_ATOM_EATEN)
		return
	if(silent || !isitem(eat_target)) //Don't bother reporting it for everything
		return
	to_chat(src, span_warning("[eat_target] cannot be eaten!"))

///Updates the display that shows the mobs nutrition
/mob/living/simple_animal/hostile/ooze/proc/updateNutritionDisplay()
	if(hud_used) //clientless oozes
		hud_used.alien_plasma_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='green'>[round(ooze_nutrition)]</font></div>")


///* Gelatinious Ooze code below *\\\\


///Its good stats and high mobility makes this a good assasin type creature. It's vulnerabilites against cold, shotguns and
/mob/living/simple_animal/hostile/ooze/gelatinous
	name = "Gelatinous Cube"
	desc = "A cubic ooze native to Sholus VII.\nSince the advent of space travel this species has established itself in the waste treatment facilities of several space colonies.\nIt is often considered to be the third most infamous invasive species due to its highly aggressive and predatory nature."
	speed = 1
	damage_coeff = list(BRUTE = 1, BURN = 0.6, TOX = 0.5, CLONE = 1.5, STAMINA = 0, OXY = 1)
	melee_damage_lower = 20
	melee_damage_upper = 20
	armour_penetration = 15
	obj_damage = 20
	deathmessage = "collapses into a pile of goo!"
	///The ability to give yourself a metabolic speed boost which raises heat
	var/datum/action/cooldown/metabolicboost/boost
	///The ability to consume mobs
	var/datum/action/consume/consume

///Initializes the mobs abilities and gives them to the mob
/mob/living/simple_animal/hostile/ooze/gelatinous/Initialize(mapload)
	. = ..()
	boost = new
	boost.Grant(src)
	consume = new
	consume.Grant(src)

/mob/living/simple_animal/hostile/ooze/gelatinous/Destroy()
	. = ..()
	QDEL_NULL(boost)
	QDEL_NULL(consume)

///If this mob gets resisted by something, its trying to escape consumption.
/mob/living/simple_animal/hostile/ooze/gelatinous/container_resist_act(mob/living/user)
	. = ..()
	if(!do_after(user, 6 SECONDS)) //6 second struggle
		return FALSE
	consume.stop_consuming()

/mob/living/simple_animal/hostile/ooze/gelatinous/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_GELATINOUS, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

///This ability lets the gelatinious ooze speed up for a little bit
/datum/action/cooldown/metabolicboost
	name = "Metabolic boost"
	desc = "Gain a temporary speed boost. Costs 10 nutrition and slowly raises your temperature"
	background_icon_state = "bg_hive"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "metabolic_boost"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE
	cooldown_time = 24 SECONDS
	var/nutrition_cost = 10
	var/active = FALSE


///Mob needs to have enough nutrition
/datum/action/cooldown/metabolicboost/IsAvailable()
	. = ..()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	if(!.)
		return FALSE
	return (ooze.ooze_nutrition >= nutrition_cost && !active)

///Give the mob a speed boost, heat it up every second, and end the ability in 6 seconds
/datum/action/cooldown/metabolicboost/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.add_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	var/timerid = addtimer(CALLBACK(src, .proc/HeatUp), 1 SECONDS, TIMER_STOPPABLE | TIMER_LOOP) //Heat up every second
	addtimer(CALLBACK(src, .proc/FinishSpeedup, timerid), 6 SECONDS)
	to_chat(ooze, span_notice("You start feel a lot quicker."))
	active = TRUE
	ooze.adjust_ooze_nutrition(-10)

///Heat up the mob a little
/datum/action/cooldown/metabolicboost/proc/HeatUp()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.adjust_bodytemperature(50)

///Remove the speed modifier and delete the timer for heating up
/datum/action/cooldown/metabolicboost/proc/FinishSpeedup(timerid)
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.remove_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	to_chat(ooze, span_notice("You start slowing down again."))
	deltimer(timerid)
	active = FALSE
	StartCooldown()


///This action lets you consume the mob you're currently pulling. I'M GONNA CONSUUUUUME (this is considered one of the funny memes in the 2019-2020 era)
/datum/action/consume
	name = "Consume"
	desc = "Consume a mob that you are dragging to gain nutrition from them"
	background_icon_state = "bg_hive"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "consume"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE
	///The mob thats being consumed by this creature
	var/mob/living/vored_mob

///Register for owner death
/datum/action/consume/New(Target)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, .proc/on_owner_death)
	RegisterSignal(owner, COMSIG_PARENT_PREQDELETED, .proc/handle_mob_deletion)

/datum/action/consume/proc/handle_mob_deletion()
	SIGNAL_HANDLER
	stop_consuming() //Shit out the vored mob before u go go

///Try to consume the pulled mob
/datum/action/consume/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	if(!isliving(ooze.pulling))
		to_chat(src, span_warning("You need to be pulling a creature for this to work!"))
		return FALSE
	if(vored_mob)
		to_chat(src, span_warning("You are already consuming another creature!"))
		return FALSE
	owner.visible_message(span_warning("[ooze] starts attempting to devour [target]!"), span_notice("You start attempting to devour [target]."))
	if(!do_after(ooze, 15, target = ooze.pulling))
		return FALSE
	var/mob/living/eat_target = ooze.pulling

	if(!(eat_target.mob_biotypes & MOB_ORGANIC) || eat_target.stat == DEAD)
		to_chat(src, span_warning("This creature isn't to my tastes!"))
		return FALSE
	start_consuming(eat_target)

///Start allowing this datum to process to handle the damage done to  this mob.
/datum/action/consume/proc/start_consuming(mob/living/target)
	vored_mob = target
	vored_mob.forceMove(owner) ///AAAAAAAAAAAAAAAAAAAAAAHHH!!!
	RegisterSignal(vored_mob, COMSIG_PARENT_PREQDELETED, .proc/handle_mob_deletion)
	playsound(owner,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	owner.visible_message(span_warning("[src] devours [target]!"), span_notice("You devour [target]."))
	START_PROCESSING(SSprocessing, src)

///Stop consuming the mob; dump them on the floor
/datum/action/consume/proc/stop_consuming()
	STOP_PROCESSING(SSprocessing, src)
	vored_mob.forceMove(get_turf(owner))
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
	owner.visible_message(span_warning("[owner] pukes out [vored_mob]!"), span_notice("You puke out [vored_mob]."))
	UnregisterSignal(vored_mob, COMSIG_PARENT_PREQDELETED)
	vored_mob = null

///Gain health for the consumption and dump some clone loss on the target.
/datum/action/consume/process()
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	vored_mob.adjustBruteLoss(5)
	ooze.heal_ordered_damage((ooze.maxHealth * 0.03), list(BRUTE, BURN, OXY)) ///Heal 6% of these specific damage types each process
	ooze.adjust_ooze_nutrition(3)

	///Dump em at 200 cloneloss.
	if(vored_mob.getBruteLoss() >= 200)
		stop_consuming()

///On owner death dump the current vored mob
/datum/action/consume/proc/on_owner_death()
	SIGNAL_HANDLER
	stop_consuming()


///* Gelatinious Grapes code below *\\\\

///Child of the ooze mob which is orientated at being a healer type creature.
/mob/living/simple_animal/hostile/ooze/grapes
	name = "Sholean grapes"
	desc = "A botryoidal ooze from Sholus VII.\nXenobiologists consider it to be one of the calmer and more agreeable species on the planet, but so far little is known about its behaviour in the wild.\nIt undulates in a comforting manner."
	icon_state = "grapes"
	icon_living = "grapes"
	icon_dead = "grapes_dead"
	speed = 1
	health = 200
	maxHealth = 200
	damage_coeff = list(BRUTE = 1, BURN = 0.8, TOX = 0.5, CLONE = 1.5, STAMINA = 0, OXY = 1)
	melee_damage_lower = 12
	melee_damage_upper = 12
	obj_damage = 15
	deathmessage = "deflates and spills its vital juices!"
	edible_food_types = MEAT | VEGETABLES
	///The ability lets you envelop a carbon in a healing cocoon. Useful for saving critical carbons.
	var/datum/action/cooldown/gel_cocoon/gel_cocoon
	///The ability to shoot a mending globule, a sticky projectile that heals over time.
	var/obj/effect/proc_holder/globules/globules

/mob/living/simple_animal/hostile/ooze/grapes/Initialize(mapload)
	. = ..()
	globules = new
	AddAbility(globules)
	gel_cocoon = new
	gel_cocoon.Grant(src)

/mob/living/simple_animal/hostile/ooze/grapes/Destroy()
	. = ..()
	QDEL_NULL(gel_cocoon)
	QDEL_NULL(globules)

/mob/living/simple_animal/hostile/ooze/grapes/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_GRAPE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

///Ability that allows the owner to fire healing globules at mobs, targetting specific limbs.
/obj/effect/proc_holder/globules
	name = "Fire Mending globule"
	desc = "Fires a mending globule at someone, healing a specific limb of theirs."
	active = FALSE
	action_icon = 'icons/mob/actions/actions_slime.dmi'
	action_icon_state = "globules"
	action_background_icon_state = "bg_hive"
	var/cooldown = 5 SECONDS
	var/current_cooldown = 0

/obj/effect/proc_holder/globules/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	fire(user)

/obj/effect/proc_holder/globules/fire(mob/living/carbon/user)
	var/message
	if(current_cooldown > world.time)
		to_chat(user, span_notice("This ability is still on cooldown."))
		return
	if(active)
		message = span_notice("You stop preparing your mending globules.")
		remove_ranged_ability(message)
	else
		message = span_notice("You prepare to launch a mending globule. <B>Left-click to fire at a target!</B>")
		add_ranged_ability(user, message, TRUE)

/obj/effect/proc_holder/globules/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	if(.)
		return
	if(!istype(ranged_ability_user, /mob/living/simple_animal/hostile/ooze) || ranged_ability_user.stat)
		remove_ranged_ability()
		return

	var/mob/living/simple_animal/hostile/ooze/ooze = ranged_ability_user

	if(ooze.ooze_nutrition < 5)
		to_chat(ooze, span_warning("You need at least 5 nutrition to launch a mending globule."))
		remove_ranged_ability()
		return

	ooze.visible_message(span_nicegreen("[ooze] launches a mending globule!"), span_notice("You launch a mending globule."))
	var/modifiers = params2list(params)
	var/obj/projectile/globule/globule = new (ooze.loc)
	globule.preparePixelProjectile(target, ooze, modifiers)
	globule.def_zone = ooze.zone_selected
	globule.fire()
	ooze.adjust_ooze_nutrition(-5)
	remove_ranged_ability()
	current_cooldown = world.time + cooldown

	return TRUE

/obj/effect/proc_holder/globules/on_lose(mob/living/carbon/user)
	remove_ranged_ability()

///This projectile embeds into mobs and heals them over time.
/obj/projectile/globule
	name = "mending globule"
	icon_state = "glob_projectile"
	shrapnel_type = /obj/item/mending_globule
	embedding = list("embed_chance" = 100, ignore_throwspeed_threshold = TRUE, "pain_mult" = 0, "jostle_pain_mult" = 0, "fall_chance" = 0.5)
	nodamage = TRUE
	damage = 0

///This item is what is embedded into the mob, and actually handles healing of mending globules
/obj/item/mending_globule
	name = "mending globule"
	desc = "It somehow heals those who touch it."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "globule"
	embedding = list("embed_chance" = 100, ignore_throwspeed_threshold = TRUE, "pain_mult" = 0, "jostle_pain_mult" = 0, "fall_chance" = 0.5)
	var/obj/item/bodypart/bodypart
	var/heals_left = 35

/obj/item/mending_globule/Destroy()
	. = ..()
	bodypart = null

/obj/item/mending_globule/embedded(mob/living/carbon/human/embedded_mob, obj/item/bodypart/part)
	. = ..()
	if(!istype(part))
		return
	bodypart = part
	START_PROCESSING(SSobj, src)

/obj/item/mending_globule/unembedded()
	. = ..()
	bodypart = null
	STOP_PROCESSING(SSobj, src)

///Handles the healing of the mending globule
/obj/item/mending_globule/process()
	if(!bodypart) //this is fucked
		return FALSE
	bodypart.heal_damage(1,1)
	heals_left--
	if(heals_left <= 0)
		qdel(src)

///This action lets you put a mob inside of a cacoon that will inject it with some chemicals.
/datum/action/cooldown/gel_cocoon
	name = "Gel Cocoon"
	desc = "Puts a mob inside of a cocoon, allowing it to slowly heal."
	background_icon_state = "bg_hive"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "gel_cocoon"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE
	cooldown_time = 10 SECONDS

///Try to put the pulled mob in a cocoon
/datum/action/cooldown/gel_cocoon/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/grapes/ooze = owner
	if(!iscarbon(ooze.pulling))
		to_chat(src, span_warning("You need to be pulling an intelligent enough creature to assist it with a cocoon!"))
		return FALSE
	owner.visible_message(span_nicegreen("[ooze] starts attempting to put [target] into a gel cocoon!"), span_notice("You start attempting to put [target] into a gel cocoon."))
	if(!do_after(ooze, 1.5 SECONDS, target = ooze.pulling))
		return FALSE

	put_in_cocoon(ooze.pulling)
	ooze.adjust_ooze_nutrition(-30)

///Mob needs to have enough nutrition
/datum/action/cooldown/gel_cocoon/IsAvailable()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	return ooze.ooze_nutrition >= 30

///Puts the mob in the new cocoon
/datum/action/cooldown/gel_cocoon/proc/put_in_cocoon(mob/living/carbon/target)
	var/obj/structure/gel_cocoon/cocoon = new /obj/structure/gel_cocoon(get_turf(target))
	cocoon.insert_target(target)
	owner.visible_message(span_nicegreen("[owner] has put [target] into a gel cocoon!"), span_notice("You put [target] into a gel cocoon."))
	StartCooldown()

/obj/structure/gel_cocoon
	name = "gel cocoon"
	desc = "It looks gross, but helpful."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "gel_cocoon"
	max_integrity = 50
	var/mob/living/carbon/inhabitant

/obj/structure/gel_cocoon/Destroy()
	if(inhabitant)
		dump_inhabitant(FALSE)
	return ..()

/obj/structure/gel_cocoon/container_resist_act(mob/living/user)
	. = ..()
	user.visible_message(span_notice("You see [user] breaking out of [src]!"), \
		span_notice("You start tearing the soft tissue of the gel cocoon"))
	if(!do_after(user, 1.5 SECONDS, target = src))
		return FALSE
	dump_inhabitant()

///This proc handles the insertion of a person into the cocoon
/obj/structure/gel_cocoon/proc/insert_target(target)
	inhabitant = target
	inhabitant.forceMove(src)
	START_PROCESSING(SSobj, src)

///This proc dumps the mob and handles associated audiovisual feedback
/obj/structure/gel_cocoon/proc/dump_inhabitant(destroy_after = TRUE)
	inhabitant.forceMove(get_turf(src))
	playsound(get_turf(inhabitant), 'sound/effects/splat.ogg', 50, TRUE)
	inhabitant.Paralyze(10)
	inhabitant.visible_message(span_warning("[inhabitant] falls out of [src]!"), span_notice("You fall out of [src]."))
	if(destroy_after)
		qdel(src)


/obj/structure/gel_cocoon/process()
	if(inhabitant.reagents.get_reagent_amount(/datum/reagent/medicine/atropine) < 5)
		inhabitant.reagents.add_reagent(/datum/reagent/medicine/atropine, 0.5)

	if(inhabitant.reagents.get_reagent_amount(/datum/reagent/medicine/salglu_solution) < 15)
		inhabitant.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 1.5)

	if(inhabitant.reagents.get_reagent_amount(/datum/reagent/consumable/milk) < 20)
		inhabitant.reagents.add_reagent(/datum/reagent/consumable/milk, 2)
