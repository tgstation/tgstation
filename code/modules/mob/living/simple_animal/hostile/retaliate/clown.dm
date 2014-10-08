/mob/living/simple_animal/hostile/retaliate/clown
	name = "Clown"
	desc = "A denizen of clown planet"
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
	emote_see = list("honks")
	speak_chance = 1
	a_intent = "harm"
	stop_automated_movement_when_pulled = 0
	maxHealth = 75
	health = 75
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	environment_smash = 0

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atmos_damage = 10

/////////////////////////
//Spookoween Insane Clown
/////////////////////////

/mob/living/simple_animal/hostile/retaliate/clown/insane
	name = "Insane Clown"
	desc = "May the HonkMother have mercy..."
	icon_state = "scary_clown"
	icon_living = "scary_clown"
	icon_dead = "scary_clown"
	icon_gib = "scary_clown"
	speak = list("...", ". . .")
	maxHealth = 1e6
	health = 1e6
	emote_see = list("silently stares")
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	unsuitable_atmos_damage = 0

	var/timer

/mob/living/simple_animal/hostile/retaliate/clown/insane/New()
	..()
	//timer = rand(10,180)
	timer = rand(5,15)
	status_flags = (status_flags | GODMODE)
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Retaliate()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/ex_act()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Life()
	timer--
	if(target)
		stalk()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/proc/stalk()
	var/mob/living/M = target
	if(M.stat == DEAD)
		playsound(M.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
		qdel(src)
	if(timer == 0)
		//timer = rand(10,180)
		timer = rand(5,15)
		playsound(M.loc, pick('sound/spookoween/scary_horn.ogg','sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg'), 300, 1)
		spawn(12)
			loc = M.loc
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/MoveToTarget()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/AttackTarget()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/adjustBruteLoss()
	if(prob(5))
		playsound(src.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/nullrod))
		if(prob(5))
			visible_message("<span class='notice'>[src] finally found the peace it deserves. HONK for the HonkMother !</span>");
			playsound(src.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
			qdel(src)
			return
		else
			visible_message("<span class='userdanger'>It seems to be resisting the effect!!!</span>");
			return
	..()

