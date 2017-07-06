/datum/goap_action/russian/attack
	name = "Attack"
	cost = 5 // reload + firing = 3, new mag + reload + firing = 4, so this comes if you can't fire/reload+fire/grab mag+reload+fire

/datum/goap_action/russian/attack/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/attack/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C && !C.stat)
		target = C
	return (target != null)

/datum/goap_action/russian/attack/RequiresInRange()
	return TRUE

/datum/goap_action/russian/attack/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/A = agent
	var/mob/living/carbon/C = target
	C.attack_animal(A)
	action_done = TRUE
	return TRUE

/datum/goap_action/russian/attack/CheckDone(atom/agent)
	return action_done


/datum/goap_action/russian/attack_ranged
	name = "Attack Ranged"
	cost = 2

/datum/goap_action/russian/attack_ranged/New()
	..()
	preconditions = list()
	preconditions["reloadNeeded"] = FALSE
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/attack_ranged/AdvancedPreconditions(atom/agent, list/worldstate)
	var/mob/living/simple_animal/hostile/russian/RU = agent
	if(!RU.ammo_left)
		return FALSE
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C && !C.stat)
		target = C
	return (target != null)

/datum/goap_action/russian/attack_ranged/RequiresInRange()
	return FALSE

/datum/goap_action/russian/attack_ranged/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/russian/A = agent
	var/mob/living/carbon/C = target
	A.visible_message("<span class = 'danger'>[A] fires at [C]!</span>")
	A.Shoot(C)
	A.ammo_left--
	action_done = TRUE
	return TRUE

/datum/goap_action/russian/attack_ranged/CheckDone(atom/agent)
	return action_done

/datum/goap_action/russian/grenade_out_take_cover
	name = "Throw Grenade"
	cost = 1
	cooldown = 15

/datum/goap_action/russian/grenade_out_take_cover/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/grenade_out_take_cover/AdvancedPreconditions(atom/agent, list/worldstate)
	var/mob/living/simple_animal/hostile/russian/A = agent
	if(A.grenade_to_throw == null)
		return FALSE
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C && !C.stat)
		target = C
	if(!target)
		return FALSE
	return (A.grenades_left >= 1)

/datum/goap_action/russian/grenade_out_take_cover/RequiresInRange()
	return FALSE

/datum/goap_action/russian/grenade_out_take_cover/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/russian/A = agent
	var/mob/living/carbon/C = target
	A.say(pick(list("GRENADA VYKHODA KRYSHKA!","GRANADA, GRANADA!","LOZHIS'!")))
	A.visible_message("<span class = 'danger'>[A] throws a grenade at [C]!</span>")
	var/obj/item/weapon/grenade/G = new A.grenade_to_throw(get_turf(agent))
	G.preprime(A, 0)
	G.throw_at(C, 10, 1)
	A.grenades_left--
	cooldown_time = world.time + cooldown
	action_done = TRUE
	return TRUE

/datum/goap_action/russian/grenade_out_take_cover/CheckDone(atom/agent)
	return action_done


/datum/goap_action/russian/reload
	name = "Reload"
	cost = 1 // reload + firing = 3, so this comes if you can't fire/reload+fire/

/datum/goap_action/russian/reload/New()
	..()
	preconditions = list()
	preconditions["reloadNeeded"] = TRUE
	preconditions["ammoNeeded"] = FALSE
	effects = list()
	effects["reloadNeeded"] = FALSE

/datum/goap_action/russian/reload/AdvancedPreconditions(atom/agent, list/worldstate)
	var/mob/living/simple_animal/hostile/russian/A = agent
	if(A.reloads_left)
		return TRUE
	else
		return FALSE

/datum/goap_action/russian/reload/RequiresInRange()
	return FALSE

/datum/goap_action/russian/reload/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/russian/A = agent
	A.say(pick(list("REKLAMA, KRYSHKA MENYA!","Novyy mag, day mne sekundu!","Peregruzochnyy!")))
	A.ammo_left = A.max_ammo
	A.reloads_left--
	action_done = TRUE
	return TRUE

/datum/goap_action/russian/reload/CheckDone(atom/agent)
	return action_done


/datum/goap_action/russian/medic
	name = "Heal Allies"
	cost = 1
	cooldown = 10

/datum/goap_action/russian/medic/New()
	..()
	preconditions = list()
	preconditions["allyNeedsHealed"] = TRUE
	effects = list()
	effects["allyNeedsHealed"] = FALSE

/datum/goap_action/russian/medic/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = spiral_range(10, agent)
	for(var/mob/living/simple_animal/hostile/russian/R in viewl)
		if(!R.stat)
			if(R.health < (R.maxHealth/2))
				target = R
				break
	return (target != null)

/datum/goap_action/russian/medic/RequiresInRange()
	return TRUE

/datum/goap_action/russian/medic/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/russian/A = agent
	if(target)
		A.say(pick(list("Isprav'te sebya!","Medik na stsene!","Ostanovite poluchat' vystrel tak mnogo!")))
		if(prob(1))
			A.visible_message("[A] hands [target] some vodka! [target] chugs it, feeling rejuvenated!")
		else
			A.visible_message(pick(list("[A] applies some QuikClot to [target]!", "[A] bandages some wounds on [target]!", "[A] quickly stitches close a cut on [target]!")))
		var/mob/living/simple_animal/hostile/russian/R = target
		R.health += (R.maxHealth/4)
		action_done = TRUE
		cooldown_time = world.time + cooldown
		return TRUE
	else
		action_done = TRUE
		return FALSE

/datum/goap_action/russian/medic/CheckDone(atom/agent)
	return action_done

/datum/goap_action/russian/resupply
	name = "Resupply Allies"
	cost = 1
	cooldown = 10

/datum/goap_action/russian/resupply/New()
	..()
	preconditions = list()
	preconditions["allyNeedsAmmo"] = TRUE
	effects = list()
	effects["allyNeedsAmmo"] = FALSE

/datum/goap_action/russian/resupply/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = spiral_range(10, agent)
	for(var/mob/living/simple_animal/hostile/russian/R in viewl)
		if(!R.stat)
			if(!R.reloads_left)
				target = R
				break
	return (target != null)

/datum/goap_action/russian/resupply/RequiresInRange()
	return FALSE

/datum/goap_action/russian/resupply/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/russian/A = agent
	var/mob/living/simple_animal/hostile/russian/RU = target
	if(target)
		A.say(pick(list("Voz'mi eto boyepripasy, tovarishch!","Perezagruzite oruzhiye!","Perezagruzite svoy grebanyy idiot!")))
		A.visible_message("[A] throws a new magazine to [target]!")
		var/obj/item/russian_reload/RE = new /obj/item/russian_reload(get_turf(agent))
		RE.throw_at(target, 10, 1)
		RU.reloads_left += 3
		RU.say(pick(list("Spasibo!","Spasibo za boyepripasy!","Ti khahroshiy spetsiahlist!")))
		qdel(RE)
		action_done = TRUE
		cooldown_time = world.time + cooldown
		return TRUE
	else
		action_done = TRUE
		return FALSE


/datum/goap_action/russian/resupply/CheckDone(atom/agent)
	return action_done