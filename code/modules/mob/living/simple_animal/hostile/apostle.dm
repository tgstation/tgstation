/mob/living/simple_animal/hostile/apostle //what they all should have
	name = "Apostle"
	desc = "if you read this i fucked up and also you're gay"
	icon = 'icons/mob/apostles.dmi'
	vision_range = 20
	pass_flags = PASSTABLE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	robust_searching = 1
	AIStatus = AI_ON
	deathmessage = "explodes into a pile of stuffing!"
	faction = list("neutral","silicon","turret")

/mob/living/simple_animal/hostile/apostle/robot
	name = "Yehûdâh Ish-Kerayot"
	desc = "A minion of the feral spirit Beschützer. It has the appearance of a ragdoll with a noose around its neck and coins spill from its mouth. It's generally harmless, but... why does it look so familiar? It really looks like it could have its coins returned."
	icon_state = "apgui"
	icon_dead = "apdead"
	vision_range = 4
	wander = 1
	robust_searching = 1
	gender = MALE
	speed = 5
	maxHealth = 20
	health = 20
	speak_chance = 10
	melee_damage_lower = 0
	melee_damage_upper = 1
	attack_verb_continuous = "nudges"
	attack_verb_simple = "nudge"
	speak_emote = list("cries")
	speak = list("Es tut mir Leid...", "Vergib mir...", "Ich wollte nicht!", "Ich bin ein Verräter...", "Du solltest mich hassen...")
	emote_hear = list("cries.","weeps.")
	emote_see = list("drops coins from its mouth.", "jerks around unsteadily.")
	attack_sound = 'sound/items/toysqueak2.ogg'
	response_help_continuous = "pets"
	response_help_simple = "pet"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/retreat_message_said = FALSE

/mob/living/simple_animal/hostile/apostle/robot/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(Dir)
		if(prob(25))
			new /obj/item/coin/gold(src.loc)
	return ..()

/mob/living/simple_animal/hostile/apostle/robot/attackby(obj/item/I,mob/living/user,params)
	if(istype(I, /obj/item/coin/gold))
		user.visible_message("<span class='notice'>[user] feeds [src] a coin!</span>", "<span class='notice'>[src] looks at [user] with wide, pitiful eyes. [user] feels blessed!</span>")
		playsound(src, 'sound/items/toysqueak2.ogg', 50, 1)
		qdel(I)
		var/mob/living/carbon/H = user
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "Blessed", /datum/mood_event/sabbat1)

/mob/living/simple_animal/hostile/apostle/robot/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(stat == DEAD || health > maxHealth*0.1)
		retreat_distance = initial(retreat_distance)
		return
	if(!retreat_message_said && target)
		visible_message("<span class='danger'>[name] tries to flee from [target]!</span>")
		retreat_message_said = TRUE
	retreat_distance = 30

/mob/living/simple_animal/hostile/apostle/robot/Life()
	. = ..()
	if(!. || target)
		return
	adjustHealth(-maxHealth*0.025)
	retreat_message_said = FALSE


/mob/living/simple_animal/hostile/apostle/poison
    var/poison_per_bite = 0
    var/poison_type = /datum/reagent/toxin

/mob/living/simple_animal/hostile/apostle/poison/AttackingTarget()
    . = ..()
    if(. && isliving(target))
        var/mob/living/L = target
        if(L.reagents && !poison_per_bite == 0)
            L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_animal/hostile/apostle/poison/guirec
	name = "Yohanan ben Zavdi"
	desc = "A minion of the feral spirit Beschützer. It has the appearance of a ragdoll being choked by a snake made of its own hair. It's face is torn off and the doll is unrecognizable. It really looks like it could use some juice in a carton."
	icon_state = "apguirec"
	icon_dead = "apdead"
	vision_range = 9
	wander = 1
	robust_searching = 1
	gender = MALE
	speed = 2
	maxHealth = 40
	health = 40
	speak_chance = 10
	melee_damage_type = TOX
	melee_damage_lower = 7
	melee_damage_upper = 13
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	emote_hear = list("makes a muffled scream.","hisses.")
	emote_see = list("pulls at its throat.", "jerks around violently.")
	attack_sound = 'sound/items/toysqueak2.ogg'
	response_help_continuous = "pets"
	response_help_simple = "pet"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE



/mob/living/simple_animal/hostile/apostle/poison/guirec/Initialize()
	. = ..()
	add_cell_sample()

/mob/living/simple_animal/hostile/apostle/poison/guirec/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SNAKE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/apostle/poison/guirec/ListTargets(atom/the_target)
	. = oview(vision_range, targets_from) //get list of things in vision range
	var/list/living_mobs = list()
	for (var/HM in .)
		if(isliving(HM))
			living_mobs += HM

/mob/living/simple_animal/hostile/apostle/poison/guirec/attackby(obj/item/I,mob/living/user,params)
	if(istype(I, /obj/item/reagent_containers/food/drinks/sillycup/smallcarton))
		user.visible_message("<span class='notice'>[user] gives [src] some juice!</span>", "<span class='notice'>Though [src] can't drink, it still seems to appreciate it. [user] feels blessed!</span>")
		playsound(src, 'sound/items/toysqueak2.ogg', 50, 1)
		qdel(I)
		var/mob/living/carbon/H = user
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "Redeemed", /datum/mood_event/sabbat2)

/mob/living/simple_animal/hostile/apostle/carrey
	name = "Protokletos"
	desc = "A minion of the feral spirit Beschützer. It has the appearance of a ragdoll tied to a fish cross. It moves in an unnatural way. It looks like it could use some security sunglasses."
	icon_state = "apcarrey"
	icon_dead = "apdead"
	vision_range = 7
	wander = 1
	robust_searching = 1
	speed = 1
	gender = FEMALE
	maxHealth = 30
	health = 30
	speak_chance = 10
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_verb_continuous = "bludgeons"
	attack_verb_simple = "bludgeon"
	speak_emote = list("laughs")
	speak = list("HAHAHAHAHAHA", "UFUFUFUFUFUFU", "KYAHAHAHAHA", "EHEHEHEHEHEHE", "GYAHAHAHAHA")
	emote_hear = list("laughs.","cackles.")
	emote_see = list("drips blood on the floor.", "twitches horribly.")
	attack_sound = 'sound/items/toysqueak2.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/apostle/carrey/AttackingTarget()
	. =..()
	var/mob/living/carbon/L = .
	if(istype(L))
		if(prob(90))
			L.Knockdown(20)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/apostle/carrey/attackby(obj/item/I,mob/living/user,params)
	if(istype(I, /obj/item/clothing/glasses/hud/security/sunglasses))
		user.visible_message("<span class='notice'>[user] puts the secglasses on [src]!</span>", "<span class='notice'>They fit perfectly. [user] feels blessed!</span>")
		playsound(src, 'sound/items/toysqueak2.ogg', 50, 1)
		qdel(I)
		var/mob/living/carbon/H = user
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "Salvaged", /datum/mood_event/sabbat3)

/mob/living/simple_animal/hostile/apostle/olivia
	name = "Bar-Tôlmay"
	desc = "A minion of the feral spirit Beschützer. It has the appearance of a ragdoll impaled by three knives. It drags itself across the ground. It really looks like it could use some carp meat."
	icon_state = "apolivia"
	icon_dead = "apdead"
	vision_range = 5
	wander = 1
	robust_searching = 1
	speed = 20
	maxHealth = 70
	health = 70
	speak_chance = 10
	ranged = 1
	ranged_message = "charges"
	gender = FEMALE
	ranged_cooldown_time = 40
	melee_damage_lower = 5
	melee_damage_upper = 25
	attack_verb_continuous = "impales"
	attack_verb_simple = "impale"
	speak_emote = list("cackles")
	speak = list("DU BIST SO SÜSS!!", "DAS MACHT SO VIEL SPASS!!", "NETTES SPIELZEUG!!", "SPASS!! SPASS!!", "AUF WIEDERSEHEN!")
	emote_hear = list("laughs.","cackles.")
	emote_see = list("stands deathly still.", "twists her head around.")
	attack_sound = 'sound/items/toysqueak2.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/range = 10
	var/charging = 0
	var/aggressive_message_said = FALSE

/mob/living/simple_animal/hostile/apostle/olivia/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health > maxHealth*0.5)
		rapid_melee = initial(rapid_melee)
		return
	if(!aggressive_message_said && target)
		visible_message("<span class='danger'>[name] stands more upright and stares at [target]!</span>")
		aggressive_message_said = TRUE
	rapid_melee = 2

/mob/living/simple_animal/hostile/apostle/olivia/attackby(obj/item/I,mob/living/user,params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/carpmeat))
		user.visible_message("<span class='notice'>[user] feeds [src] the carpmeat!</span>", "<span class='notice'>You don't really know how you could feed a doll, but [user] feels blessed anyways!</span>")
		playsound(src, 'sound/items/toysqueak2.ogg', 50, 1)
		qdel(I)
		var/mob/living/carbon/H = user
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "Patience", /datum/mood_event/sabbat4)

/mob/living/simple_animal/hostile/apostle/olivia/OpenFire(atom/A)
	if(!charging)
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		Shoot(A)

/mob/living/simple_animal/hostile/apostle/olivia/Shoot(atom/targeted_atom)
	charging = 1
	throw_at(targeted_atom, range, 1, src, FALSE, TRUE, callback = CALLBACK(src, .proc/charging_end))

/mob/living/simple_animal/hostile/apostle/olivia/proc/charging_end()
	charging = 0

/mob/living/simple_animal/hostile/apostle/olivia/Life()
	. = ..()
	if(!. || target)
		return
	adjustHealth(-maxHealth*0.025)
	aggressive_message_said = FALSE