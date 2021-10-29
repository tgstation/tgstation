//inject chemicals into your host
/datum/action/cooldown/inject_chemical
	name = "Inject 5u Chemical (10 chemicals)"
	cooldown_time = 1 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "chemical"

/datum/action/cooldown/inject_chemical/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(!cortical_owner.human_host)
		to_chat(cortical_owner, span_warning("You need a host in order to use this ability!"))
		return
	if(cortical_owner.host_sugar())
		to_chat(cortical_owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(!cortical_owner.known_chemicals.len)
		to_chat(cortical_owner, span_warning("You need to learn chemicals first!"))
		return
	if(cortical_owner.chemical_storage < 10)
		to_chat(cortical_owner, span_warning("You require at least 10 chemical units to inject a chemical!"))
		return
	cortical_owner.chemical_storage -= 10
	var/choice = tgui_input_list(cortical_owner, "Choose a chemical to inject!", "Chemical Selection", cortical_owner.known_chemicals)
	if(!choice)
		to_chat(cortical_owner, span_warning("No selection made!"))
		return
	cortical_owner.reagent_holder.reagents.add_reagent(choice, 5, added_purity = 1)
	cortical_owner.reagent_holder.reagents.trans_to(cortical_owner.human_host, 30, methods = INGEST)
	to_chat(cortical_owner.human_host, span_warning("You feel something cool inside of you!"))
	var/turf/human_turf = get_turf(cortical_owner.human_host)
	var/datum/reagent/reagent_name = initial(choice)
	var/logging_text = "[key_name(cortical_owner)] injected [key_name(cortical_owner.human_host)] with [reagent_name] at [loc_name(human_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)
	StartCooldown()

/datum/action/cooldown/choose_focus
	name = "Choose Focus (5 stat points)"
	cooldown_time = 1 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "level"

/datum/action/cooldown/choose_focus/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You require a host to upgrade!"))
		return
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(cortical_owner.stat_evolution < 5)
		to_chat(owner, span_warning("You do not have 5 upgrade points for a focus!"))
		return
	cortical_owner.stat_evolution -= 5
	var/focus_choice = tgui_input_list(cortical_owner, "Choose your focus!", "Focus Choice", list("Head focus", "Chest focus", "Arm focus", "Leg focus"))
	if(!focus_choice)
		to_chat(owner, span_warning("You did not choose a focus"))
		cortical_owner.stat_evolution += 5
		return
	switch(focus_choice)
		if("Head focus")
			if(cortical_owner.body_focus & FOCUS_HEAD)
				to_chat(cortical_owner, span_warning("You already have this focus!"))
				cortical_owner.stat_evolution += 5
				return
			cortical_owner.body_focus |= FOCUS_HEAD
		if("Chest focus")
			if(cortical_owner.body_focus & FOCUS_CHEST)
				to_chat(cortical_owner, span_warning("You already have this focus!"))
				cortical_owner.stat_evolution += 5
				return
			cortical_owner.body_focus |= FOCUS_CHEST
		if("Arm focus")
			if(cortical_owner.body_focus & FOCUS_ARMS)
				to_chat(cortical_owner, span_warning("You already have this focus!"))
				cortical_owner.stat_evolution += 5
				return
			cortical_owner.body_focus |= FOCUS_ARMS
		if("Leg focus")
			if(cortical_owner.body_focus & FOCUS_LEGS)
				to_chat(cortical_owner, span_warning("You already have this focus!"))
				cortical_owner.stat_evolution += 5
				return
			cortical_owner.body_focus |= FOCUS_LEGS
	borer_focus_remove(cortical_owner.human_host)
	borer_focus_add(cortical_owner.human_host)

/datum/action/cooldown/learn_bloodchemical
	name = "Learn Chemical from Blood (5 stat points)"
	cooldown_time = 1 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "level"

/datum/action/cooldown/learn_bloodchemical/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You require a host to upgrade!"))
		return
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(cortical_owner.human_host.reagents.reagent_list.len <= 0)
		to_chat(owner, span_warning("There are no reagents inside the host!"))
		return
	if(cortical_owner.chemical_evolution < 5)
		to_chat(owner, span_warning("You do not have 5 upgrade points for a focus!"))
		return
	cortical_owner.chemical_evolution -= 5
	var/datum/reagent/reagent_choice = tgui_input_list(cortical_owner, "Choose a chemical to learn.", "Chemical Selection", cortical_owner.human_host.reagents.reagent_list)
	if(!reagent_choice)
		to_chat(owner, span_warning("No selection made!"))
		cortical_owner.chemical_evolution += 5
		return
	if(locate(reagent_choice) in cortical_owner.known_chemicals)
		to_chat(owner, span_warning("You already know this chemical!"))
		cortical_owner.chemical_evolution += 5
		return
	cortical_owner.known_chemicals += reagent_choice.type
	to_chat(owner, span_notice("You have learned [initial(reagent_choice.name)]"))
	StartCooldown()

//become stronger by learning new chemicals
/datum/action/cooldown/upgrade_chemical
	name = "Learn New Chemical"
	cooldown_time = 1 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "level"

/datum/action/cooldown/upgrade_chemical/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You require a host to upgrade!"))
		return
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(cortical_owner.chemical_evolution < 1)
		to_chat(owner, span_warning("You do not have any upgrade points for chemicals!"))
		return
	cortical_owner.chemical_evolution--
	if(!cortical_owner.potential_chemicals.len)
		to_chat(owner, span_warning("There are no more chemicals!"))
		cortical_owner.chemical_evolution++
		return
	var/datum/reagent/reagent_choice = tgui_input_list(cortical_owner, "Choose a chemical to learn.", "Chemical Selection", cortical_owner.potential_chemicals)
	if(!reagent_choice)
		to_chat(owner, span_warning("No selection made!"))
		cortical_owner.chemical_evolution++
		return
	cortical_owner.known_chemicals += reagent_choice
	cortical_owner.potential_chemicals -= reagent_choice
	to_chat(owner, span_notice("You have learned [initial(reagent_choice.name)]"))
	StartCooldown()

//become stronger by affecting the stats
/datum/action/cooldown/upgrade_stat
	name = "Become Stronger"
	cooldown_time = 1 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "level"

/datum/action/cooldown/upgrade_stat/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You require a host to upgrade!"))
		return
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(cortical_owner.stat_evolution < 1)
		to_chat(owner, span_warning("You do not have any upgrade points for stats!"))
		return
	cortical_owner.stat_evolution--
	cortical_owner.maxHealth += 10
	cortical_owner.health_regen += 0.02
	cortical_owner.max_chemical_storage += 20
	cortical_owner.chemical_regen++
	to_chat(cortical_owner, span_notice("You have grown!"))
	StartCooldown()

//go between either hiding behind tables or behind mobs
/datum/action/cooldown/toggle_hiding
	name = "Toggle Hiding"
	cooldown_time = 1 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "hide"

/datum/action/cooldown/toggle_hiding/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	if(owner.layer == PROJECTILE_HIT_THRESHHOLD_LAYER)
		to_chat(owner, span_notice("You stop hiding."))
		owner.layer = BELOW_MOB_LAYER
		StartCooldown()
		return
	to_chat(owner, span_notice("You start hiding."))
	owner.layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	StartCooldown()

//to paralyze people
/datum/action/cooldown/fear_human
	name = "Incite Fear"
	cooldown_time = 12 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "fear"

/datum/action/cooldown/fear_human/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(cortical_owner.human_host)
		to_chat(cortical_owner, span_notice("You incite fear into your host."))
		cortical_owner.human_host.Paralyze(10 SECONDS)
		to_chat(cortical_owner.human_host, span_warning("Something moves inside of you violently!"))
		StartCooldown()
		return
	var/list/potential_freezers = list()
	for(var/mob/living/carbon/human/listed_human in range(1, cortical_owner))
		if(!ishuman(listed_human)) //no nonhuman hosts
			continue
		if(listed_human.stat == DEAD) //no dead hosts
			continue
		if(considered_afk(listed_human.mind)) //no afk hosts
			continue
		potential_freezers += listed_human
	if(length(potential_freezers) == 1)
		var/mob/living/carbon/human/singular_fear = pick(potential_freezers)
		to_chat(singular_fear, span_warning("Something glares menacingly at you!"))
		singular_fear.Paralyze(7 SECONDS)
		var/turf/human_turfone = get_turf(singular_fear)
		var/logging_text = "[key_name(cortical_owner)] feared/paralyzed [key_name(singular_fear)] at [loc_name(human_turfone)]"
		cortical_owner.log_message(logging_text, LOG_GAME)
		singular_fear.log_message(logging_text, LOG_GAME)
		StartCooldown()
		return
	var/mob/living/carbon/human/choose_fear = tgui_input_list(cortical_owner, "Choose who you will fear!", "Fear Choice", potential_freezers)
	if(!choose_fear)
		to_chat(cortical_owner, span_warning("No selection was made!"))
		return
	if(get_dist(choose_fear, cortical_owner) > 1)
		to_chat(cortical_owner, span_warning("The chosen is too far"))
		return
	to_chat(choose_fear, span_warning("Something glares menacingly at you!"))
	choose_fear.Paralyze(7 SECONDS)
	var/turf/human_turftwo = get_turf(choose_fear)
	var/logging_text = "[key_name(cortical_owner)] feared/paralyzed [key_name(choose_fear)] at [loc_name(human_turftwo)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	choose_fear.log_message(logging_text, LOG_GAME)
	StartCooldown()

//to check the health of the human
/datum/action/cooldown/check_blood
	name = "Check Blood"
	cooldown_time = 5 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "blood"

/datum/action/cooldown/check_blood/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(!cortical_owner.human_host)
		to_chat(owner, span_warning("You must have a host to check blood!"))
		return
	var/message = ""
	message += "Brute: [cortical_owner.human_host.getBruteLoss()] "
	message += "Fire: [cortical_owner.human_host.getFireLoss()] "
	message += "Toxin: [cortical_owner.human_host.getToxLoss()] "
	message += "Oxygen: [cortical_owner.human_host.getOxyLoss()] "
	var/reagent_message = "Current Reagents: "
	for(var/check_reagents in cortical_owner.human_host.reagents.reagent_list)
		var/datum/reagent/reagent_name = check_reagents
		reagent_message += reagent_name.name
		reagent_message += ", "
	message += reagent_message
	to_chat(cortical_owner, span_notice(message))
	StartCooldown()

//to either get inside, or out, of a host
/datum/action/cooldown/choosing_host
	name = "Inhabit/Uninhabit Host"
	cooldown_time = 10 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "host"

/datum/action/cooldown/choosing_host/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(cortical_owner.human_host)
		to_chat(cortical_owner, span_notice("You forcefully detach from the host."))
		to_chat(cortical_owner.human_host, span_notice("Something carefully tickles your inner ear..."))
		var/obj/item/organ/borer_body/borer_organ = locate() in cortical_owner.human_host.internal_organs
		if(borer_organ)
			borer_organ.Remove(cortical_owner.human_host)
		cortical_owner.human_host = null
		var/turf/human_turfone = get_turf(cortical_owner.human_host)
		var/logging_text = "[key_name(cortical_owner)] left [key_name(cortical_owner.human_host)] at [loc_name(human_turfone)]"
		cortical_owner.log_message(logging_text, LOG_GAME)
		cortical_owner.human_host.log_message(logging_text, LOG_GAME)
		StartCooldown()
		return
	var/list/usable_hosts = list()
	for(var/mob/living/carbon/human/listed_human in range(1, cortical_owner))
		if(!ishuman(listed_human)) //no nonhuman hosts
			continue
		if(listed_human.stat == DEAD) //no dead hosts
			continue
		if(listed_human.has_borer())
			continue
		if(!(listed_human.dna.species.inherent_biotypes & MOB_ORGANIC))
			continue
		if(!(listed_human.mob_biotypes & MOB_ORGANIC))
			continue
		usable_hosts += listed_human
	if(length(usable_hosts) == 1)
		var/mob/living/carbon/human/singular_host = pick(usable_hosts)
		if(singular_host.has_borer())
			to_chat(cortical_owner, span_warning("You cannot occupy a body already occupied!"))
			return
		if(!do_after(cortical_owner, 5 SECONDS, target = singular_host))
			to_chat(cortical_owner, span_warning("You and the host must be still."))
			return
		if(get_dist(singular_host, cortical_owner) > 1)
			to_chat(cortical_owner, span_warning("The host is too far away."))
			return
		cortical_owner.human_host = singular_host
		cortical_owner.forceMove(cortical_owner.human_host)
		to_chat(cortical_owner.human_host, span_notice("A chilling sensation goes down your spine..."))
		cortical_owner.copy_languages(cortical_owner.human_host)
		var/obj/item/organ/borer_body/borer_organ = new(cortical_owner.human_host)
		borer_organ.Insert(cortical_owner.human_host)
		var/turf/human_turftwo = get_turf(cortical_owner.human_host)
		var/logging_text = "[key_name(cortical_owner)] went into [key_name(cortical_owner.human_host)] at [loc_name(human_turftwo)]"
		cortical_owner.log_message(logging_text, LOG_GAME)
		cortical_owner.human_host.log_message(logging_text, LOG_GAME)
		StartCooldown()
		return
	var/choose_host = tgui_input_list(cortical_owner, "Choose your host!", "Host Choice", usable_hosts)
	if(!choose_host)
		to_chat(cortical_owner, span_warning("You failed to choose a host."))
		return
	var/mob/living/carbon/human/choosen_human = choose_host
	if(choosen_human.has_borer())
		to_chat(cortical_owner, span_warning("You cannot occupy a body already occupied!"))
		return
	if(!do_after(cortical_owner, 5 SECONDS, target = choose_host))
		to_chat(cortical_owner, span_warning("You and the host must be still."))
		return
	if(get_dist(choose_host, cortical_owner) > 1)
		to_chat(cortical_owner, span_warning("The host is too far away."))
		return
	cortical_owner.human_host = choose_host
	cortical_owner.forceMove(cortical_owner.human_host)
	to_chat(cortical_owner.human_host, span_notice("A chilling sensation goes down your spine..."))
	cortical_owner.copy_languages(cortical_owner.human_host)
	var/obj/item/organ/borer_body/borer_organ = new(cortical_owner.human_host)
	borer_organ.Insert(cortical_owner.human_host)
	var/turf/human_turfthree = get_turf(cortical_owner.human_host)
	var/logging_text = "[key_name(cortical_owner)] went into [key_name(cortical_owner.human_host)] at [loc_name(human_turfthree)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)
	StartCooldown()

//you can force your host to speak... dont abuse this
/datum/action/cooldown/force_speak
	name = "Force Host Speak"
	cooldown_time = 30 SECONDS
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "speak"

/datum/action/cooldown/force_speak/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You must be inside a human in order to do this!"))
		return
	var/borer_message = input(cortical_owner, "What would you like to force your host to say?", "Force Speak") as message|null
	if(!borer_message)
		to_chat(cortical_owner, span_warning("No message given!"))
		return
	borer_message = sanitize(borer_message)
	var/mob/living/carbon/human/cortical_host = cortical_owner.human_host
	to_chat(cortical_host, span_boldwarning("Your voice moves without your permission!"))
	cortical_host.say(message = borer_message, forced = TRUE)
	var/turf/human_turf = get_turf(cortical_owner.human_host)
	var/logging_text = "[key_name(cortical_owner)] forced [key_name(cortical_owner.human_host)] to say [borer_message] at [loc_name(human_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)
	StartCooldown()

//we need a way to produce offspring
/datum/action/cooldown/produce_offspring
	name = "Produce Offspring (100 chemicals)"
	cooldown_time = 1 MINUTES
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "reproduce"

/datum/action/cooldown/produce_offspring/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You need a host to reproduce!"))
		return
	if(cortical_owner.chemical_storage < 100)
		to_chat(cortical_owner, span_warning("You require at least 100 chemical units before you can reproduce!"))
		return
	cortical_owner.chemical_storage -= 100
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to spawn as a cortical borer?", ROLE_PAI, FALSE, 100, POLL_IGNORE_CORTICAL_BORER)
	if(!LAZYLEN(candidates))
		to_chat(cortical_owner, span_notice("No available borers in the hivemind."))
		cortical_owner.chemical_storage = min(cortical_owner.max_chemical_storage, cortical_owner.chemical_storage + 100)
		return
	var/turf/borer_turf = get_turf(cortical_owner)
	var/mob/dead/observer/pick_candidate = pick(candidates)
	if(!pick_candidate)
		return
	var/mob/living/simple_animal/cortical_borer/spawn_borer = new /mob/living/simple_animal/cortical_borer(borer_turf)
	if(!spawn_borer.ckey)
		spawn_borer.ckey = pick_candidate.ckey
	spawn_borer.generation = cortical_owner.generation + 1
	spawn_borer.name = "[initial(spawn_borer.name)] ([spawn_borer.generation]-[rand(100,999)])"
	if(spawn_borer.mind)
		spawn_borer.mind.add_antag_datum(/datum/antagonist/cortical_borer)
	cortical_owner.children_produced++
	if(prob(25))
		cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)
		to_chat(cortical_owner.human_host, span_warning("Your brain begins to hurt..."))
	new /obj/effect/decal/cleanable/vomit(borer_turf)
	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	to_chat(spawn_borer, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))
	var/logging_text = "[key_name(cortical_owner)] gave birth to [key_name(spawn_borer)] at [loc_name(borer_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	spawn_borer.log_message(logging_text, LOG_GAME)
	StartCooldown()

//revive your host
/datum/action/cooldown/revive_host
	name = "Revive Host (200 chemicals)"
	cooldown_time = 2 MINUTES
	icon_icon = 'modular_skyrat/modules/cortical_borer/icons/actions.dmi'
	button_icon_state = "revive"

/datum/action/cooldown/revive_host/Trigger()
	if(!IsAvailable())
		to_chat(owner, span_warning("This action is still on cooldown!"))
		return
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return
	var/mob/living/simple_animal/cortical_borer/cortical_owner = owner
	if(cortical_owner.host_sugar())
		to_chat(owner, span_warning("Sugar inhibits your abilities to function!"))
		return
	if(!cortical_owner.inside_human())
		to_chat(cortical_owner, span_warning("You must be inside a human in order to do this!"))
		return
	if(cortical_owner.chemical_storage < 200)
		to_chat(cortical_owner, span_warning("You require at least 200 chemical units before you can revive your host!"))
		return
	cortical_owner.chemical_storage -= 200
	if(cortical_owner.human_host.getBruteLoss())
		cortical_owner.human_host.adjustBruteLoss(-(cortical_owner.human_host.getBruteLoss()*0.5))
	if(cortical_owner.human_host.getToxLoss())
		cortical_owner.human_host.adjustToxLoss(-(cortical_owner.human_host.getToxLoss()*0.5))
	if(cortical_owner.human_host.getFireLoss())
		cortical_owner.human_host.adjustFireLoss(-(cortical_owner.human_host.getFireLoss()*0.5))
	if(cortical_owner.human_host.getOxyLoss())
		cortical_owner.human_host.adjustOxyLoss(-(cortical_owner.human_host.getOxyLoss()*0.5))
	if(cortical_owner.human_host.blood_volume < BLOOD_VOLUME_BAD)
		cortical_owner.human_host.blood_volume = BLOOD_VOLUME_BAD
	cortical_owner.human_host.revive()
	to_chat(cortical_owner.human_host, span_boldwarning("Your heart jumpstarts!"))
	var/turf/human_turf = get_turf(cortical_owner.human_host)
	var/logging_text = "[key_name(cortical_owner)] revived [key_name(cortical_owner.human_host)] at [loc_name(human_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)
	StartCooldown()
