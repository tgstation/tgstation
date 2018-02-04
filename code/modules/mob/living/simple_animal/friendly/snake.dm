#define AMBUSH_DELAY 150 //15 seconds before boas may ambush again.

/mob/living/simple_animal/hostile/retaliate/poison
	var/poison_per_bite = 0
	var/poison_type = "toxin"

/mob/living/simple_animal/hostile/retaliate/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents && !poison_per_bite == 0)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		return .

/mob/living/simple_animal/hostile/retaliate/poison/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	health = 20
	maxHealth = 20
	attacktext = "bites"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	faction = list("hostile")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE


/mob/living/simple_animal/hostile/retaliate/poison/snake/ListTargets(atom/the_target)
	. = oview(vision_range, targets_from) //get list of things in vision range
	var/list/living_mobs = list()
	var/list/mice = list()
	for (var/HM in .)
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
	if(istype(target, /mob/living/simple_animal/mouse))
		visible_message("<span class='notice'>[name] consumes [target] in a single gulp!</span>", "<span class='notice'>You consume [target] in a single gulp!</span>")
		QDEL_NULL(target)
		adjustBruteLoss(-2)
	else
		return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/cobra
	name = "cobra"
	desc = "A slithery snake. This one looks much more poisonous, keep your distance."
	icon_state = "cobra"
	icon_living = "cobra"
	icon_dead = "cobra_dead"
	poison_per_bite = 1
	poison_type = "calciseptine"

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa
	name = "boa constrictor"
	desc = "A slithery snake. This one looks much more constricting, keep your distance."
	icon_state = "boa"
	icon_living = "boa"
	icon_dead = "boa_dead"
	health = 80
	maxHealth = 80
	can_buckle = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	friend_buckle = FALSE //as hilarious as buckling someone into a boa would be, no we can't have that
	friend_unbuckle = FALSE
	self_unbuckle = FALSE
	var/ambush_cooldown = 0
	var/constricting = FALSE

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/AttackingTarget()
	if(ambush_cooldown < world.time && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			buckle_mob(L, force = 1)
			icon_state = "boa_constricting"
			constricting = TRUE
			layer = 4.21
			return
	. = ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Life()
	if(!buckled_mobs) //if the victim gets gibbed while in your grasp!
		icon_state = "boa"
		constricting = FALSE
		layer = 4.1
	for(var/mob/living/L in buckled_mobs)
		to_chat(L, "<span class='danger'>You're getting crushed by the immense pressure of the [src]!</span>")
		L.adjustBruteLoss(10)
		if(L.stat == DEAD)
			unbuckle_mob(L, force = 1)
			icon_state = "boa"
			constricting = FALSE
			layer = 4.1 //you might think this is not needed since it resets when the boa moves but if it doesn't move it could overlap any mob until it does

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Move(turf/NewLoc)
	if(constricting)
		if(client)
			to_chat(src, "<span class='warning'>You cannot move, you're constricting someone to death!</span>")
		return 0
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(.)
		ambush_cooldown = world.time + AMBUSH_DELAY
	if(stat)
		unbuckle_all_mobs(force = 1)



#undef AMBUSH_DELAY