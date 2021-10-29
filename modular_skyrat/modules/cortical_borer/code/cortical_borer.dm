//we need a way of buffing leg speed... here
/datum/movespeed_modifier/borer_speed
	multiplicative_slowdown = -0.40

//so that we know if a mob has a borer (only humans should have one, but in case)
/mob/proc/has_borer()
	for(var/check_content in contents)
		if(iscorticalborer(check_content))
			return check_content
	return FALSE

//this allows borers to slide under/through a door
/obj/machinery/door/Bumped(atom/movable/movable_atom)
	if(iscorticalborer(movable_atom) && density)
		if(!do_after(movable_atom, 5 SECONDS, src))
			return ..()
		movable_atom.forceMove(get_turf(src))
		to_chat(movable_atom, span_notice("You squeeze through [src]."))
		return
	return ..()

//so if a person is debrained, the borer is removed
/obj/item/organ/brain/Remove(mob/living/carbon/target, special = 0, no_id_transfer = FALSE)
	. = ..()
	var/mob/living/simple_animal/cortical_borer/cb_inside = target.has_borer()
	if(cb_inside)
		cb_inside.leave_host()

//borers also create an organ, so you dont need to debrain someone
/obj/item/organ/borer_body
	name = "engorged cortical borer"
	desc = "the body of a cortical borer, full of human viscera, blood, and more."
	zone = BODY_ZONE_HEAD

/proc/borer_focus_add(mob/living/carbon/carbon_target)
	var/mob/living/simple_animal/cortical_borer/cb_inside = carbon_target.has_borer()
	if(!cb_inside)
		return
	if(cb_inside.body_focus & FOCUS_HEAD)
		to_chat(carbon_target, span_notice("Your eyes begin to feel strange..."))
		var/obj/item/organ/eyes/my_eyes = carbon_target.getorgan(/obj/item/organ/eyes)
		if(my_eyes)
			my_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			my_eyes.see_in_dark = 11
			my_eyes.flash_protect = FLASH_PROTECTION_WELDER
		if(!HAS_TRAIT(carbon_target, TRAIT_KNOW_ENGI_WIRES))
			ADD_TRAIT(carbon_target, TRAIT_KNOW_ENGI_WIRES, cb_inside)
	if(cb_inside.body_focus & FOCUS_CHEST)
		to_chat(carbon_target, span_notice("Your chest begins to slow down..."))
		if(!HAS_TRAIT(carbon_target, TRAIT_NOBREATH))
			ADD_TRAIT(carbon_target, TRAIT_NOBREATH, cb_inside)
		if(!HAS_TRAIT(carbon_target, TRAIT_NOHUNGER))
			ADD_TRAIT(carbon_target, TRAIT_NOHUNGER, cb_inside)
		if(!HAS_TRAIT(carbon_target, TRAIT_STABLEHEART))
			ADD_TRAIT(carbon_target, TRAIT_STABLEHEART, cb_inside)
	if(cb_inside.body_focus & FOCUS_ARMS)
		to_chat(carbon_target, span_notice("Your arm starts to feel funny..."))
		var/datum/action/cooldown/borer_armblade/give_owner = new /datum/action/cooldown/borer_armblade
		give_owner.Grant(cb_inside.human_host)
		if(!HAS_TRAIT(carbon_target, TRAIT_SHOCKIMMUNE))
			ADD_TRAIT(carbon_target, TRAIT_SHOCKIMMUNE, cb_inside)
	if(cb_inside.body_focus & FOCUS_LEGS)
		to_chat(carbon_target, span_notice("You feel faster..."))
		carbon_target.add_movespeed_modifier(/datum/movespeed_modifier/borer_speed)
		if(!HAS_TRAIT(carbon_target, TRAIT_LIGHT_STEP))
			ADD_TRAIT(carbon_target, TRAIT_LIGHT_STEP, cb_inside)
		if(!HAS_TRAIT(carbon_target, TRAIT_FREERUNNING))
			ADD_TRAIT(carbon_target, TRAIT_FREERUNNING, cb_inside)

/proc/borer_focus_remove(mob/living/carbon/carbon_target)
	var/mob/living/simple_animal/cortical_borer/cb_inside = carbon_target.has_borer()
	if(cb_inside.body_focus & FOCUS_HEAD)
		to_chat(carbon_target, span_notice("Your eyes begin to return to normal..."))
		var/obj/item/organ/eyes/my_eyes = carbon_target.getorgan(/obj/item/organ/eyes)
		if(my_eyes)
			my_eyes.lighting_alpha = initial(my_eyes.lighting_alpha)
			my_eyes.see_in_dark = initial(my_eyes.see_in_dark)
			my_eyes.flash_protect = initial(my_eyes.flash_protect)
		carbon_target.update_sight()
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_KNOW_ENGI_WIRES, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_KNOW_ENGI_WIRES, cb_inside)
	if(cb_inside.body_focus & FOCUS_CHEST)
		to_chat(carbon_target, span_notice("Your chest begins to heave again..."))
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_NOBREATH, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_NOBREATH, cb_inside)
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_NOHUNGER, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_NOHUNGER, cb_inside)
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_STABLEHEART, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_STABLEHEART, cb_inside)
	if(cb_inside.body_focus & FOCUS_ARMS)
		to_chat(carbon_target, span_notice("Your arm starts to feel normal again..."))
		for(var/datum/action/listed_actions in cb_inside.human_host.actions)
			if(istype(listed_actions, /datum/action/cooldown/borer_armblade))
				listed_actions.Remove(cb_inside.human_host)
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_SHOCKIMMUNE, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_SHOCKIMMUNE, cb_inside)
	if(cb_inside.body_focus & FOCUS_LEGS)
		to_chat(carbon_target, span_notice("You feel slower..."))
		carbon_target.remove_movespeed_modifier(/datum/movespeed_modifier/borer_speed)
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_LIGHT_STEP, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_LIGHT_STEP, cb_inside)
		if(HAS_TRAIT_FROM(carbon_target, TRAIT_FREERUNNING, cb_inside))
			REMOVE_TRAIT(carbon_target, TRAIT_FREERUNNING, cb_inside)

/obj/item/organ/borer_body/Insert(mob/living/carbon/carbon_target, special, drop_if_replaced)
	. = ..()
	borer_focus_add(carbon_target)

//on removal, force the borer out
/obj/item/organ/borer_body/Remove(mob/living/carbon/carbon_target, special)
	. = ..()
	var/mob/living/simple_animal/cortical_borer/cb_inside = carbon_target.has_borer()
	borer_focus_remove(carbon_target)
	if(cb_inside)
		cb_inside.leave_host()
	qdel(src)

/datum/action/cooldown/borer_armblade
	name = "Borer Armblade (20 chemicals)"
	cooldown_time = 5 SECONDS
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "armblade"

/datum/action/cooldown/borer_armblade/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!owner.has_borer())
		to_chat(owner, span_warning("You need a borer to use this ability!"))
		Remove(owner)
		return
	var/mob/living/simple_animal/cortical_borer/cb_owner = owner.has_borer()
	if(cb_owner.host_sugar())
		to_chat(owner, span_warning("You have sugar, making unable to use this!"))
		return
	if(cb_owner.chemical_storage < 20)
		to_chat(owner, span_warning("The borer does not have enough chemicals stored!"))
		return
	cb_owner.chemical_storage -= 20
	for(var/obj/item/hosts_items in cb_owner.human_host.held_items) //if you have the armblade, remove it
		if(!istype(hosts_items, /obj/item/melee/arm_blade))
			continue
		cb_owner.human_host.temporarilyRemoveItemFromInventory(hosts_items, TRUE)
		playsound(cb_owner.human_host, 'sound/effects/blobattack.ogg', 30, TRUE)
		cb_owner.human_host.visible_message(span_warning("With a sickening crunch, [cb_owner.human_host] reforms [cb_owner.human_host.p_their()] armblade into an arm!"), span_notice("We assimilate the armblade back into our body."), "<span class='italics>You hear organic matter ripping and tearing!</span>")
		cb_owner.human_host.update_inv_hands()
		return
	var/obj/item/spawn_armblade = new /obj/item/melee/arm_blade(cb_owner.human_host) //if you dont have the armblade, add it
	cb_owner.human_host.put_in_hands(spawn_armblade)
	playsound(cb_owner.human_host, 'sound/effects/blobattack.ogg', 30, TRUE)

/mob/living/simple_animal/cortical_borer
	name = "cortical borer"
	desc = "A slimy creature that is known to go into the ear canal of unsuspecting victims."
	icon = 'modular_skyrat/modules/cortical_borer/icons/animal.dmi'
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	maxHealth = 50
	health = 50
	//they need to be able to pass tables and mobs
	pass_flags = PASSTABLE | PASSMOB
	//they are below mobs, or below tables
	layer = BELOW_MOB_LAYER
	//corticals are tiny
	mob_size = MOB_SIZE_TINY
	//because they are small, why can't they be held?
	can_be_held = TRUE
	///what chemicals borers know, starting with none
	var/list/known_chemicals = list()
	///what chemicals the borer can learn
	var/list/potential_chemicals = list(/datum/reagent/medicine/spaceacillin,
										/datum/reagent/medicine/potass_iodide,
										/datum/reagent/medicine/diphenhydramine,
										/datum/reagent/medicine/epinephrine,
										/datum/reagent/medicine/antihol,
										/datum/reagent/medicine/haloperidol,
										/datum/reagent/consumable/nutriment,
										/datum/reagent/consumable/hell_ramen,
										/datum/reagent/consumable/tearjuice,
										/datum/reagent/drug/thc,
										/datum/reagent/drug/quaalude,
										/datum/reagent/drug/happiness,
										/datum/reagent/consumable/tea,
										/datum/reagent/consumable/hot_coco,
										/datum/reagent/toxin/formaldehyde,
										/datum/reagent/impurity/libitoil,
										/datum/reagent/impurity/mannitol,
										/datum/reagent/medicine/c2/libital/borer_version,
										/datum/reagent/medicine/c2/lenturi/borer_version,
										/datum/reagent/medicine/c2/convermol,
										/datum/reagent/medicine/c2/seiver,
										/datum/reagent/lithium,
										/datum/reagent/consumable/orangejuice,
										/datum/reagent/consumable/tomatojuice,
										/datum/reagent/consumable/limejuice,
										/datum/reagent/consumable/carrotjuice,
										/datum/reagent/consumable/milk,
										/datum/reagent/medicine/salglu_solution,
										/datum/reagent/medicine/mutadone,
										/datum/reagent/toxin/heparin,
										/datum/reagent/consumable/ethanol/beer,
										/datum/reagent/medicine/mannitol,
										/datum/reagent/drug/methamphetamine/borer_version,
										/datum/reagent/medicine/morphine,
										/datum/reagent/medicine/inacusiate,
										/datum/reagent/medicine/oculine,
	)
	///how old the borer is, starting from zero. Goes up only when inside a host
	var/maturity_age = 0
	///the amount of "evolution" points a borer has for chemicals. Start with one
	var/chemical_evolution = 1
	///the amount of "evolution" points a borer has for stats
	var/stat_evolution = 0
	///how many chemical points the borer can have. Can be upgraded
	var/max_chemical_storage = 50
	///how many chemical points the borer has
	var/chemical_storage = 50
	///how fast chemicals are gained. Goes up only when inside a host
	var/chemical_regen = 1
	///the list of actions that the borer has
	var/list/known_abilities = list(/datum/action/cooldown/toggle_hiding,
									/datum/action/cooldown/choosing_host,
									/datum/action/cooldown/produce_offspring,
									/datum/action/cooldown/inject_chemical,
									/datum/action/cooldown/upgrade_chemical,
									/datum/action/cooldown/choose_focus,
									/datum/action/cooldown/learn_bloodchemical,
									/datum/action/cooldown/upgrade_stat,
									/datum/action/cooldown/force_speak,
									/datum/action/cooldown/fear_human,
									/datum/action/cooldown/check_blood,
									/datum/action/cooldown/revive_host,
	)
	///the host
	var/mob/living/carbon/human/human_host
	//what the host gains or loses with the borer
	var/list/hosts_abilities = list(

	)
	//just a little "timer" to compare to world.time
	var/timed_maturity = 0
	///multiplies the current health up to the max health
	var/health_regen = 1.02
	//holds the chems right before injection
	var/obj/item/reagent_containers/reagent_holder
	//just a flavor kind of thing
	var/generation = 1
	///what the borer focuses to increase the hosts capabilities
	var/body_focus = null
	///how many children the borer has produced
	var/children_produced = 0
	///we dont want to spam the chat
	var/deathgasp_once = FALSE

/mob/living/simple_animal/cortical_borer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT) //they need to be able to move around
	name = "[initial(name)] ([generation]-[rand(100,999)])" //so their gen and a random. ex 1-288 is first gen named 288, 4-483 if fourth gen named 483
	if(prob(5))
		var/switching = rand(1,2)
		switch(switching)
			if(1)
				name = "cortical boner ([generation]-[rand(100,999)])"
			if(2)
				name = "cortical vorer ([generation]-[rand(100,999)])"
	GLOB.cortical_borers += src
	reagent_holder = new /obj/item/reagent_containers(src)
	for(var/action_type in known_abilities)
		var/datum/action/attack_action = new action_type()
		attack_action.Grant(src)
	if(mind)
		if(!mind.has_antag_datum(/datum/antagonist/cortical_borer))
			mind.add_antag_datum(/datum/antagonist/cortical_borer)

/mob/living/simple_animal/cortical_borer/Destroy()
	human_host = null
	GLOB.cortical_borers -= src
	if(mind)
		mind.remove_all_antag_datums()
	QDEL_NULL(reagent_holder)
	return ..()

/mob/living/simple_animal/cortical_borer/death(gibbed)
	if(inside_human())
		var/turf/human_turf = get_turf(human_host)
		forceMove(human_turf)
		human_host = null
	GLOB.cortical_borers -= src
	if(!deathgasp_once)
		deathgasp_once = TRUE
		for(var/borers in GLOB.cortical_borers)
			to_chat(borers, span_boldwarning("[src] has left the hivemind forcibly!"))
	if(mind)
		mind.remove_all_antag_datums()
	QDEL_NULL(reagent_holder)
	return ..()

//so we can add some stuff to status, making it easier to read... maybe some hud some day
/mob/living/simple_animal/cortical_borer/get_status_tab_items()
	. = ..()
	. += "Chemical Storage: [chemical_storage]/[max_chemical_storage]"
	. += "Chemical Evolution Points: [chemical_evolution]"
	. += "Stat Evolution Points: [stat_evolution]"
	if(host_sugar())
		. += "Sugar detected! Unable to generate resources!"

/mob/living/simple_animal/cortical_borer/Life(delta_time, times_fired)
	. = ..()
	//can only do stuff when we are inside a human
	if(!inside_human())
		return
	//cant do anything if the host has sugar
	if(host_sugar())
		return

	if(chemical_storage < max_chemical_storage)
		chemical_storage = min(chemical_storage + chemical_regen, max_chemical_storage)
		if(chemical_storage > max_chemical_storage)
			chemical_storage = max_chemical_storage

	if(health < maxHealth)
		health = min(health * health_regen, maxHealth)
		if(health > maxHealth)
			health = maxHealth

	if(timed_maturity < world.time)
		timed_maturity = world.time + 1 SECONDS
		maturity_age++

		if(maturity_age == 20)
			chemical_evolution++
			to_chat(src, span_notice("You gain a chemical evolution point. Spend it to learn a new chemical!"))
		if(maturity_age == 40)
			stat_evolution++
			to_chat(src, span_notice("You gain a stat evolution point. Spend it to become stronger!"))
			maturity_age = 0

//if it doesnt have a ckey, let ghosts have it
/mob/living/simple_animal/cortical_borer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(ckey || key)
		return
	if(stat == DEAD)
		return
	var/choice = tgui_input_list(usr, "Do you want to control [src]?", "Confirmation", list("Yes", "No"))
	if(choice != "Yes")
		return
	if(ckey || key)
		return
	to_chat(user, span_warning("As a borer, you have the option to be friendly or not. Note that how you act will determine how a host responds!"))
	to_chat(user, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))
	ckey = user.ckey
	if(mind)
		mind.add_antag_datum(/datum/antagonist/cortical_borer)

//check if we are inside a human
/mob/living/simple_animal/cortical_borer/proc/inside_human()
	if(!ishuman(loc))
		return FALSE
	return TRUE

//check if the host has sugar
/mob/living/simple_animal/cortical_borer/proc/host_sugar()
	if(human_host?.reagents?.has_reagent(/datum/reagent/consumable/sugar))
		return TRUE
	return FALSE

//leave the host, forced or not
/mob/living/simple_animal/cortical_borer/proc/leave_host()
	if(!human_host)
		return
	var/obj/item/organ/borer_body/borer_organ = locate() in human_host.internal_organs
	if(borer_organ)
		borer_organ.Remove(human_host)
	var/turf/human_turf = get_turf(human_host)
	forceMove(human_turf)
	human_host = null

//borers shouldnt be able to whisper...
/mob/living/simple_animal/cortical_borer/whisper(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof)
	to_chat(src, span_warning("You are not able to whisper!"))
	return FALSE

//previously had borers unable to emote... but that means less RP, and we want that

//borers should not be talking without a host at least
/mob/living/simple_animal/cortical_borer/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	if(!inside_human())
		to_chat(src, span_warning("You are not able to speak without a host!"))
		return
	if(host_sugar())
		message = scramble_message_replace_chars(message, 10)
	message = sanitize(message)
	var/list/split_message = splittext(message, "")
	if(split_message[1] == ";")
		message = copytext(message, 2)
		for(var/borer in GLOB.cortical_borers)
			to_chat(borer, span_purple("Cortical Hivemind: [src] sings, \"[message]\""))
		for(var/mob/dead_mob in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, src)
			to_chat(dead_mob, span_purple("[link] Cortical Hivemind: [src] sings, \"[message]\""))
		var/logging_textone = "[key_name(src)] spoke into the hivemind: [message]"
		log_say(logging_textone)
		return
	to_chat(human_host, span_purple("Cortical Link: [src] sings, \"[message]\""))
	var/logging_texttwo = "[key_name(src)] spoke to [key_name(human_host)]: [message]"
	log_say(logging_texttwo)
	to_chat(src, span_purple("Cortical Link: [src] sings, \"[message]\""))
	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, src)
		to_chat(dead_mob, span_purple("[link] Cortical Hivemind: [src] sings to [human_host], \"[message]\""))

/mob/living/simple_animal/cortical_borer/start_pulling(atom/movable/AM, state, force, supress_message)
	to_chat(src, span_warning("You cannot pull things!"))
	return
