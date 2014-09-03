/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	a_intent = "hurt"
	var/corpse = /obj/effect/landmark/mobcorpse/syndicatesoldier
	var/weapon1
	var/weapon2
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "syndicate"
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/syndicate/Die()
	..()
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	if(weapon2)
		new weapon2 (src.loc)
	del src
	return

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	weapon1 = /obj/item/weapon/melee/energy/sword/red
	weapon2 = /obj/item/weapon/shield/energy
	attacktext = "slashes"
	status_flags = 0

/mob/living/simple_animal/hostile/syndicate/melee/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			health -= damage
			visible_message("\red \b [src] has been attacked with [O] by [user]. ")
		else
			visible_message("\red \b [src] blocks [O] with its shield! ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		visible_message("\red [user] gently taps [src] with [O]. ")


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(65))
		src.health -= Proj.damage
	else
		visible_message("\red <B>[src] blocks [Proj] with its shield!</B>")
	return 0


/mob/living/simple_animal/hostile/syndicate/melee/space
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
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/hostile/syndicate/melee/space/Process_Spacemove(var/check_drift = 0)
	return

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	casingtype = /obj/item/ammo_casing/a12mm
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	projectiletype = /obj/item/projectile/bullet/midbullet2

	weapon1 = /obj/item/weapon/gun/projectile/automatic/c20r

/mob/living/simple_animal/hostile/syndicate/ranged/space
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
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/hostile/syndicate/ranged/space/Process_Spacemove(var/check_drift = 0)
	return



/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE
	health = 15
	maxHealth = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "syndicate"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/viscerator/Die()
	..()
	visible_message("\red <b>[src]</b> is smashed into pieces!")
	del src
	return