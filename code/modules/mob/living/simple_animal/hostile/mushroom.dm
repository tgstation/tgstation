/mob/living/simple_animal/hostile/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom"
	icon_living = "mushroom"
	icon_dead = "mushroom_dead"
	speak_chance = 0
	turns_per_move = 1
	maxHealth = 50
	health = 50
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 15
	attack_same = 2
	attacktext = "chomps"
	faction = "mushroom"
	environment_smash = 0
	stat_attack = 2
	var/powerlevel = 0 //Tracks our killcount
	var/bruised = 0 //If someone tries to cheat the system by attacking a shroom to lower its health, punish them so that it wont award levels to shrooms that eat it

/mob/living/simple_animal/hostile/mushroom/attack_animal(var/mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/mushroom) && stat == 2)
		var/mob/living/simple_animal/hostile/mushroom/M = L
		M.visible_message("<span class='notice'>The [M.name] devours the [src.name]!</span>")
		if(!bruised)
			M.LevelUp()
		del(src)
	..()

/mob/living/simple_animal/hostile/mushroom/proc/LevelUp()
	if(powerlevel <= 9)
		powerlevel += 1
	melee_damage_lower += 5
	melee_damage_upper += 5
	maxHealth += 5
	health = maxHealth

/mob/living/simple_animal/hostile/mushroom/proc/Bruise()
	if(!bruised && !stat)
		src.visible_message("<span class='notice'>The [src.name] was bruised!</span>")
		bruised = 1

/mob/living/simple_animal/hostile/mushroom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	Bruise()

/mob/living/simple_animal/hostile/mushroom/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if(M.a_intent == "harm")
		Bruise()

/mob/living/simple_animal/hostile/mushroom/hitby(atom/movable/AM)
	..()
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(T.throwforce)
			Bruise()

/mob/living/simple_animal/hostile/mushroom/harvest()
	var/counter
	for(counter=0, counter<=powerlevel, counter++)
		var/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/S = new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
		S.reagents.add_reagent("mushroomhallucinogen", powerlevel)
		S.reagents.add_reagent("doctorsdelight", powerlevel)
		S.reagents.add_reagent("synaptizine", powerlevel)
	del(src)