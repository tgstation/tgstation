/mob/living/simple_animal/hostile/humanoid/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0

	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10

	corpse = /obj/effect/landmark/corpse/syndicatesoldier

	faction = "syndicate"

/mob/living/simple_animal/hostile/humanoid/syndicate/CanAttack(var/atom/the_target)
	//IF WE ARE SYNDICATE MOBS WE DON'T ATTACK NUKE OPS (we still attack regular traitors, as to not blow up their cover)
	if(ismob(the_target))
		var/mob/M = the_target
		if(isnukeop(M))
			return 0
	return ..(the_target)

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/humanoid/syndicate/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"

	items_to_drop = list(/obj/item/weapon/melee/energy/sword/red, /obj/item/weapon/shield/energy)

	attacktext = "slashes"
	status_flags = 0

/mob/living/simple_animal/hostile/humanoid/syndicate/melee/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			health -= damage
			visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
		else
			visible_message("<span class='danger'>[src] blocks [O] with its shield! </span>")
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		visible_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")


/mob/living/simple_animal/hostile/humanoid/syndicate/melee/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(65))
		src.health -= Proj.damage
	else
		visible_message("<span class='danger'>[src] blocks [Proj] with its shield!</span>")
	return 0


/mob/living/simple_animal/hostile/humanoid/syndicate/melee/space
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	icon_state = "syndicatemeleespace"
	icon_living = "syndicatemeleespace"
	name = "Syndicate Commando"
	corpse = /obj/effect/landmark/corpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/hostile/humanoid/syndicate/melee/space/Process_Spacemove(var/check_drift = 0)
	return

/mob/living/simple_animal/hostile/humanoid/syndicate/ranged
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	casingtype = /obj/item/ammo_casing/a12mm
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	projectiletype = /obj/item/projectile/bullet/midbullet2

	items_to_drop = list(/obj/item/weapon/gun/projectile/automatic/c20r)

/mob/living/simple_animal/hostile/humanoid/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	corpse = /obj/effect/landmark/corpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/hostile/humanoid/syndicate/ranged/space/Process_Spacemove(var/check_drift = 0)
	return
