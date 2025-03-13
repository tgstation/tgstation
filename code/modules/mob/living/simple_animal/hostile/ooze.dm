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
	atmos_requirements = null
	hud_type = /datum/hud/ooze
	minbodytemp = 250
	maxbodytemp = INFINITY
	faction = list(FACTION_SLIME)
	melee_damage_lower = 10
	melee_damage_upper = 10
	health = 200
	maxHealth = 200
	attack_verb_continuous = "slimes"
	attack_verb_simple = "slime"
	attack_sound = 'sound/effects/blob/blobattack.ogg'
	combat_mode = TRUE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	mob_size = MOB_SIZE_LARGE
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
	AddElement(/datum/element/content_barfer)

	grant_actions_by_list(get_innate_actions())

/mob/living/simple_animal/hostile/ooze/attacked_by(obj/item/I, mob/living/user)
	if(!eat_atom(I, TRUE))
		return ..()

/mob/living/simple_animal/hostile/ooze/AttackingTarget(atom/attacked_target)
	if(!eat_atom(attacked_target))
		return ..()

///Handles nutrition gain/loss of mob and also makes it take damage if it's too low on nutrition, only happens for sentient mobs.
/mob/living/simple_animal/hostile/ooze/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()

	if(!.) //dead or deleted
		return

	if(!mind && stat != DEAD)//no mind no change
		return

	var/nutrition_change = ooze_nutrition_loss

	//Eat a bit of all the reagents we have. Gaining nutrition for actual nutritional ones.
	for(var/i in reagents?.reagent_list)
		var/datum/reagent/reagent = i
		var/consumption_amount = min(reagents.get_reagent_amount(reagent.type), ooze_metabolism_modifier * REAGENTS_METABOLISM * seconds_per_tick)
		if(istype(reagent, /datum/reagent/consumable))
			var/datum/reagent/consumable/consumable = reagent
			nutrition_change += consumption_amount * consumable.get_nutriment_factor(src)
		reagents.remove_reagent(reagent.type, consumption_amount)
	adjust_ooze_nutrition(nutrition_change)

	if(ooze_nutrition <= 0)
		adjustBruteLoss(0.25 * seconds_per_tick)

/// Returns an applicable list of actions to grant to the mob. Will return a list or null.
/mob/living/simple_animal/hostile/ooze/proc/get_innate_actions()
	return null

///Does ooze_nutrition + supplied amount and clamps it within 0 and 500
/mob/living/simple_animal/hostile/ooze/proc/adjust_ooze_nutrition(amount)
	ooze_nutrition = clamp(ooze_nutrition + amount, 0, 500)
	updateNutritionDisplay()

///Tries to transfer the atoms reagents then delete it
/mob/living/simple_animal/hostile/ooze/proc/eat_atom(atom/eat_target, silent)
	if(isnull(eat_target))
		return
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
	damage_coeff = list(BRUTE = 1, BURN = 0.6, TOX = 0.5, STAMINA = 0, OXY = 1)
	melee_damage_lower = 20
	melee_damage_upper = 20
	armour_penetration = 15
	obj_damage = 20
	death_message = "collapses into a pile of goo!"
	///The ability to consume mobs
	var/datum/action/consume/consume

///Initializes the mobs abilities and gives them to the mob
/mob/living/simple_animal/hostile/ooze/gelatinous/Initialize(mapload)
	. = ..()
	consume = new
	consume.Grant(src)

/mob/living/simple_animal/hostile/ooze/gelatinous/get_innate_actions()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/metabolicboost,
	)
	return innate_actions

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
	overlay_icon_state = "bg_hive_border"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "metabolic_boost"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE
	cooldown_time = 24 SECONDS
	var/nutrition_cost = 10
	var/active = FALSE


///Mob needs to have enough nutrition
/datum/action/cooldown/metabolicboost/IsAvailable(feedback = FALSE)
	. = ..()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	if(!.)
		return FALSE
	return (ooze.ooze_nutrition >= nutrition_cost && !active)

///Give the mob a speed boost, heat it up every second, and end the ability in 6 seconds
/datum/action/cooldown/metabolicboost/Activate(atom/target)
	StartCooldown(10 SECONDS)
	trigger_boost()
	StartCooldown()
	return TRUE

/*
 * Actually trigger the boost.
 */
/datum/action/cooldown/metabolicboost/proc/trigger_boost()
	var/mob/living/simple_animal/hostile/ooze/ooze = owner
	ooze.add_movespeed_modifier(/datum/movespeed_modifier/metabolicboost)
	var/timerid = addtimer(CALLBACK(src, PROC_REF(HeatUp)), 1 SECONDS, TIMER_STOPPABLE | TIMER_LOOP) //Heat up every second
	addtimer(CALLBACK(src, PROC_REF(FinishSpeedup), timerid), 6 SECONDS)
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
	desc = "Consume a mob that you are dragging to gain nutrition from them."
	background_icon_state = "bg_hive"
	overlay_icon_state = "bg_hive_border"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "consume"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	/// What do we call devouring something
	var/devour_verb = "devour"
	/// how much time to eat someone
	var/devour_time = 1.5 SECONDS
	///The mob thats being consumed by this creature
	var/mob/living/vored_mob

///Register for owner death
/datum/action/consume/New(Target)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(stop_consuming))

///Try to consume the pulled mob
/datum/action/consume/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	if(vored_mob) //one happy meal at a time, buddy
		stop_consuming()
		return FALSE
	if(!isliving(ooze.pulling))
		to_chat(src, span_warning("You need to be pulling a creature for this to work!"))
		return FALSE
	var/mob/living/eat_target = ooze.pulling
	owner.visible_message(span_warning("[ooze] starts attempting to [devour_verb] [eat_target]!"), span_notice("You start attempting to [devour_verb] [eat_target]."))
	if(!do_after(ooze, devour_time, eat_target))
		return FALSE

	if(!(eat_target.mob_biotypes & MOB_ORGANIC) || eat_target.stat == DEAD)
		to_chat(src, span_warning("This creature isn't to my tastes!"))
		return FALSE
	start_consuming(eat_target)

///Start allowing this datum to process to handle the damage done to  this mob.
/datum/action/consume/proc/start_consuming(mob/living/target)
	vored_mob = target
	vored_mob.forceMove(owner) ///AAAAAAAAAAAAAAAAAAAAAAHHH!!!
	RegisterSignal(vored_mob, COMSIG_QDELETING, PROC_REF(stop_consuming))
	playsound(owner,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	owner.visible_message(span_warning("[owner] [devour_verb]s [target]!"), span_notice("You [devour_verb] [target]."))
	START_PROCESSING(SSprocessing, src)
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

///Stop consuming the mob; dump them on the floor
/datum/action/consume/proc/stop_consuming()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)
	if (isnull(vored_mob))
		return
	vored_mob.forceMove(get_turf(owner))
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
	owner.visible_message(span_warning("[owner] pukes out [vored_mob]!"), span_notice("You puke out [vored_mob]."))
	UnregisterSignal(vored_mob, COMSIG_QDELETING)
	vored_mob = null
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

///Gain health for the consumption and dump some brute loss on the target.
/datum/action/consume/process()
	var/mob/living/simple_animal/hostile/ooze/gelatinous/ooze = owner
	vored_mob.adjustBruteLoss(5)
	ooze.heal_ordered_damage((ooze.maxHealth * 0.03), list(BRUTE, BURN, OXY)) ///Heal 6% of these specific damage types each process
	if(istype(ooze))
		ooze.adjust_ooze_nutrition(3)

	///Dump 'em if they're dead.
	if(vored_mob.stat == DEAD)
		stop_consuming()

/datum/action/consume/Remove(mob/remove_from)
	stop_consuming()
	return ..()

/datum/action/consume/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if(vored_mob)
		name = "Eject Mob"
		desc = "Eject the mob you're currently consuming."
	else
		name = "Consume"
		desc = "Consume a mob that you are dragging to gain nutrition from them."
	return ..()

/datum/action/consume/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = vored_mob ? "eject" : "consume"
	return ..()

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
	damage_coeff = list(BRUTE = 1, BURN = 0.8, TOX = 0.5, STAMINA = 0, OXY = 1)
	melee_damage_lower = 12
	melee_damage_upper = 12
	obj_damage = 15
	death_message = "deflates and spills its vital juices!"
	edible_food_types = MEAT | VEGETABLES

/mob/living/simple_animal/hostile/ooze/grapes/get_innate_actions()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/globules,
		/datum/action/cooldown/gel_cocoon,
	)
	return innate_actions

/mob/living/simple_animal/hostile/ooze/grapes/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_GRAPE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

///Ability that allows the owner to fire healing globules at mobs, targeting specific limbs.
/datum/action/cooldown/globules
	name = "Fire Mending globule"
	desc = "Fires a mending globule at someone, healing a specific limb of theirs."
	background_icon_state = "bg_hive"
	overlay_icon_state = "bg_hive_border"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "globules"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	cooldown_time = 5 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/globules/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare to launch a mending globule. <B>Left-click to fire at a target!</B>"))

/datum/action/cooldown/globules/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You stop preparing your mending globules."))

/datum/action/cooldown/globules/Activate(atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/simple_animal/hostile/ooze/oozy_owner = owner
	if(istype(oozy_owner))
		if(oozy_owner.ooze_nutrition < 5)
			to_chat(oozy_owner, span_warning("You need at least 5 nutrition to launch a mending globule."))
			return FALSE

	return TRUE

/datum/action/cooldown/globules/InterceptClickOn(mob/living/clicker, params, atom/target)
	. = ..()
	if(!.)
		return FALSE

	// Why is this in InterceptClickOn() and not Activate()?
	// Well, we need to use the params of the click intercept
	// for passing into aim_projectile, so we'll handle it here instead.
	// We just need to make sure Pre-activate and Activate return TRUE so we make it this far
	clicker.visible_message(
		span_nicegreen("[clicker] launches a mending globule!"),
		span_notice("You launch a mending globule."),
	)

	var/mob/living/simple_animal/hostile/ooze/oozy = clicker
	if(istype(oozy))
		oozy.adjust_ooze_nutrition(-5)

	var/modifiers = params2list(params)
	var/obj/projectile/globule/globule = new(clicker.loc)
	globule.aim_projectile(target, clicker, modifiers)
	globule.def_zone = clicker.zone_selected
	globule.fire()

	StartCooldown()

	return TRUE

// Needs to return TRUE otherwise PreActivate() will fail, see above
/datum/action/cooldown/globules/Activate(atom/target)
	return TRUE

///This projectile embeds into mobs and heals them over time.
/obj/projectile/globule
	name = "mending globule"
	icon_state = "glob_projectile"
	shrapnel_type = /obj/item/mending_globule
	embed_type = /datum/embedding/mending_globule
	damage = 0

///This item is what is embedded into the mob
/obj/item/mending_globule
	name = "mending globule"
	desc = "It somehow heals those who touch it."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "globule"
	var/heals_left = 35

/datum/embedding/mending_globule
	embed_chance = 100
	ignore_throwspeed_threshold = TRUE
	pain_mult = 0
	jostle_pain_mult = 0
	fall_chance = 0.5

// This already processes, zero logic to add additional tracking to the item
/datum/embedding/mending_globule/process(seconds_per_tick)
	. = ..()
	var/obj/item/mending_globule/globule = parent
	owner_limb.heal_damage(0.5 * seconds_per_tick, 0.5 * seconds_per_tick)
	globule.heals_left--
	if(globule.heals_left <= 0)
		qdel(globule)

///This action lets you put a mob inside of a cacoon that will inject it with some chemicals.
/datum/action/cooldown/gel_cocoon
	name = "Gel Cocoon"
	desc = "Puts a mob inside of a cocoon, allowing it to slowly heal."
	background_icon_state = "bg_hive"
	overlay_icon_state = "bg_hive_border"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "gel_cocoon"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	cooldown_time = 10 SECONDS

/datum/action/cooldown/gel_cocoon/Activate(atom/target)
	StartCooldown(10 SECONDS)
	gel_cocoon()
	StartCooldown()

///Try to put the pulled mob in a cocoon
/datum/action/cooldown/gel_cocoon/proc/gel_cocoon()
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
/datum/action/cooldown/gel_cocoon/IsAvailable(feedback = FALSE)
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

/obj/structure/gel_cocoon
	name = "gel cocoon"
	desc = "It looks gross, but helpful."
	icon = 'icons/obj/science/vatgrowing.dmi'
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
