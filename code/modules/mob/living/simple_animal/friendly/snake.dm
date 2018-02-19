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
	gold_core_spawnable = NO_SPAWN

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
	buckle_restrictions = CANT_BUCKLE_OTHER | CANT_UNBUCKLE_OTHER | CANT_BUCKLE_SELF | CANT_UNBUCKLE_SELF
	gold_core_spawnable = NO_SPAWN
	var/ambush_cooldown = 0
	var/constrict_dmg_define = 10 //admins, set this for what you want the snake's constriction damage. don't set the one below or it'll reset when switching intents
	var/constrict_dmg_current = 10
	var/constricting = FALSE
	var/datum/action/innate/jungle/release/release
	var/datum/action/innate/jungle/constriction_intent/constriction_intent

///mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Login()

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Initialize()
	. = ..()
	release = new
	release.Grant(src)
	constriction_intent = new
	constriction_intent.Grant(src)

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Destroy()
	QDEL_NULL(release)
	QDEL_NULL(constriction_intent)
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/mouse)) //just for eating mice instead of constricting them
		. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/poison/snake/boa)) //if a boa is constricting don't DO IT
		var/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/S = target
		if(S.constricting)
			to_chat(src, "<span class='userdanger'>We cannot constrict a boa that is constricting! That would break the snake time constrictinuum!</span>")
			return
	if(isliving(target))
		var/mob/living/L = target
		if(L.buckled)
			to_chat(src, "<span class='userdanger'>We cannot constrict a critter that is buckled!</span>")
			return
		if(ambush_cooldown < world.time && L.stat != DEAD)
			to_chat(src, "<span class='notice'>we begin to constrict [L]!</span>")
			to_chat(L, "<span class='userdanger'>[src] begins to constrict you!</span>")
			buckle_mob(L, force = 1)
			icon_state = "boa_constricting"
			constricting = TRUE
			layer = WALL_OBJ_LAYER
			return
	. = ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Life()
	if(!buckled_mobs) //if the victim gets gibbed while in your grasp!
		icon_state = "boa"
		constricting = FALSE
		layer = ABOVE_MOB_LAYER
	for(var/mob/living/L in buckled_mobs)
		if(constrict_dmg_current >= 1)
			to_chat(L, "<span class='danger'>You're getting crushed by the immense pressure of the [src]!</span>")
			L.adjustBruteLoss(constrict_dmg_current)
		if(L.stat == DEAD)
			unbuckle_mob(L, force = 1)
			icon_state = "boa"
			constricting = FALSE
			layer = ABOVE_MOB_LAYER //you might think this is not needed since it resets when the boa moves but if it doesn't move it could overlap any mob until it does

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/Move(turf/NewLoc)
	if(constricting)
		if(client)
			to_chat(src, "<span class='warning'>You cannot move, you're constricting something!</span>")
		return 0
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(.)
		ambush_cooldown = world.time + AMBUSH_DELAY
	if(stat)
		unbuckle_all_mobs(force = 1)
		constricting = FALSE
		layer = ABOVE_MOB_LAYER
		return

/datum/action/innate/jungle
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_jungle"

/datum/action/innate/jungle/release
	name = "Release Prey"
	desc = "Give the stupid creature mercy, but also useful if you're getting attacked while constricting I guess."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "release"

/datum/action/innate/jungle/release/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/retaliate/poison/snake/boa))
		return
	var/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/S = owner
	if(S.buckled_mobs)
		S.unbuckle_all_mobs(force = 1)
		S.icon_state = "boa"
		S.constricting = FALSE
		S.layer = ABOVE_MOB_LAYER
		S.visible_message("<span class='notice'>[S] releases it's victims.</span>", "<span class='notice'>We let our prey go.</span>")

/datum/action/innate/jungle/constriction_intent
	name = "Toggle Constriction Strength"
	desc = "Sometimes you wanna constrict someone without killing them. Watch out though, they might yell..."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "pause"

/datum/action/innate/jungle/constriction_intent/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/retaliate/poison/snake/boa))
		return
	var/mob/living/simple_animal/hostile/retaliate/poison/snake/boa/S = owner
	if(S.constrict_dmg_current)
		to_chat(S, "<span class='notice'>We relax our muscles, and will now not do any damage while constricting.</span>")
		S.constrict_dmg_current = 0
	else
		var/flufftext = list("angry greyshirts", "hyperspace shuttles", "fully armed operatives", "deranged eldrich gods", "great big slimes", "normal boa constrictors", "evil corporations", "lava planets", "all-powerful fruit", "ash storms", "cosmic scientists", "tactical chairs", "reaper leviathans", "anomalous singularities", "big guys", "revolutionary forces", "xenomorph hives", "changelings", "fireball wizards", "shadowling ascendants")
		to_chat(S, "<span class='notice'>We tensen our muscles, and will now crush our victim with the power of [S.constrict_dmg_define] [pick(flufftext)]!</span>")
		S.constrict_dmg_current = S.constrict_dmg_define

#undef AMBUSH_DELAY
