/mob/living/simple_animal/hostile/retaliate/poison
	var/poison_per_bite = 0
	var/datum/reagent/poison_type = /datum/reagent/toxin
	///if set to TRUE, this will make us not inject any chems if doing so would make the person we're biting OD on them
	var/careful = FALSE

/mob/living/simple_animal/hostile/retaliate/poison/AttackingTarget()
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/living_target = target
	if(poison_per_bite != 0 && living_target.reagents)
		if(careful && poison_type.overdose_threshold && living_target.reagents.has_reagent(poison_type, (poison_type.overdose_threshold - poison_per_bite)))
			return
		living_target.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_animal/hostile/retaliate/poison/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	health = 20
	maxHealth = 20
	poison_per_bite = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "steps on"
	response_harm_simple = "step on"
	faction = list("hostile")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	food_type = list(/obj/item/reagent_containers/food/snacks/deadmouse) //mmmm, mice
	tame_chance = 25
	bonus_tame_chance = 15 

/mob/living/simple_animal/hostile/retaliate/poison/snake/Initialize()
	. = ..()
	add_cell_sample()

/mob/living/simple_animal/hostile/retaliate/poison/snake/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SNAKE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/retaliate/poison/snake/ListTargets(atom/the_target)
	. = oview(vision_range, targets_from) //get list of things in vision range
	var/list/living_mobs = list()
	var/list/mice = list()
	for(var/HM in .)
		//Yum a tasty mouse
		if(istype(HM, /mob/living/simple_animal/mouse))
			mice += HM
		if(isliving(HM))
			living_mobs += HM

	// if no tasty mice to chase, lets chase any living mob enemies in our vision range
	if(length(mice) == 0)
		//Filter living mobs (in range mobs) by those we consider enemies (retaliate behaviour)
		return  living_mobs & enemies
	return mice

/mob/living/simple_animal/hostile/retaliate/poison/snake/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/mouse) && melee_damage_upper > 0) //asclepius's snakes are pacifists
		visible_message("<span class='notice'>[name] consumes [target] in a single gulp!</span>", "<span class='notice'>You consume [target] in a single gulp!</span>")
		QDEL_NULL(target)
		adjustBruteLoss(-2)
		return
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius
	name = "Asclepius's snake"
	desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Its bites are rumored to have healing properties."
	poison_type = /datum/reagent/medicine/omnizine //while using godblood instead of omnizine here would be flavorful, doing that would also allow the snake to pump you with up to 150u of godblood (it has an OD threshold of 150u), which would basically leave you set for the rest of the round
	gold_core_spawnable = NO_SPAWN //only obtainable from the rod of ascelpius and/or adminbus
	melee_damage_lower = 0 //do no harm
	melee_damage_upper = 0
	friendly_verb_continuous = "bites" //so that it will bite people instead of nuzzle them
	friendly_verb_simple = "bite"
	buffed = FALSE //so that you can't use a wumborian fugu gland on it to allow it to break its oath
	food_type = list(/obj/item/reagent_containers/food/snacks/grown) //it's vegan (or at least trying to be a vegetarian)
	careful = TRUE //otherwise, NPC asclepius snakes will kill people by ODing them on omnizine
	attack_same = TRUE //we "attack" our allies to heal them

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius/Initialize()
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(src)
	notify_ghosts("A controllable snake of Asclepius has been created in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Sentient Snake Created")

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius/ListTargets(atom/the_target)
	var/list/patients = list()
	for(var/mob/living/living_in_oview in oview(vision_range, targets_from)) //get list of things in vision range
		//can I heal you?
		if(!living_in_oview.reagents || (living_in_oview.health >= living_in_oview.maxHealth)) //yeah, clone damage, robotic limbs, and such will still cause the snake to bite people it can't fully heal, but eh, even divine doctors can be dentheads sometimes
			continue
		if(careful && poison_type.overdose_threshold && living_in_oview.reagents.has_reagent(poison_type, (poison_type.overdose_threshold - poison_per_bite))) //if they're already full of our reagent, let's not remain obsessed with them
			continue
		patients += living_in_oview
	return patients

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius/tamed()
	. = ..()
	friends.Cut() //we WANT to be able to "attack" our friends so that we can heal them

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius/attack_ghost(mob/user)
	. = ..()
	if(. || !(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return
	humanize_snek(user)

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius/proc/humanize_snek(mob/user)
	if(key || stat)
		return
	var/pod_ask = alert("Become a snake of Asclepius?", "Are you a true pacifist?", "Yes", "No")
	if(pod_ask == "No" || QDELETED(src))
		return
	if(key)
		to_chat(user, "<span class='warning'>Someone else already took this snake!</span>")
		return
	key = user.key
	log_game("[key_name(src)] took control of [name].")

/mob/living/simple_animal/hostile/retaliate/poison/snake/asclepius/Login()
	. = ..()
	to_chat(src, "<span class='boldwarning'>You are one of Asclepius's divine snakes! Unlike a normal snake, when you bite someone, you'll inject them with [poison_per_bite]u of [poison_type.name] instead of toxin(s). Fortunately, due to your medical training, your bites will deal no (direct) damage and you'll never inject anyone with enough [poison_type.name] to overdose them.\n\
	Above all else, follow the tenets of the Hippocratic Oath.</span>")
