/datum/goap_action/russian
	var/saytext = "cyka" // Russians can speak so why not!

/datum/goap_action/russian/Perform(mob/living/simple_animal/hostile/russian/A)
	A.say(saytext)
	return ..()

/datum/goap_action/russian/attack
	name = "Attack"
	cost = 5 // reload + firing = 3, new mag + reload + firing = 4, so this comes if you can't fire/reload+fire/grab mag+reload+fire
	saytext = "Moving in to melee!"

/datum/goap_action/russian/attack/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/attack/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	var/maxdist = 11
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat && PATH_CHECK(src, C))
			var/distcheck = get_dist(agent, C)
			if(distcheck < maxdist)
				target = C
				maxdist = distcheck
	return (target != null)

/datum/goap_action/russian/attack/RequiresInRange()
	return TRUE

/datum/goap_action/russian/attack/Perform(mob/living/simple_animal/hostile/A)
	var/mob/living/carbon/C = target
	C.attack_animal(A)
	action_done = TRUE
	return ..()

/datum/goap_action/russian/attack/CheckDone(atom/agent)
	return action_done


/datum/goap_action/russian/attack_ranged
	name = "Attack Ranged"
	cost = 2
	saytext = "Suppressive fire!"

/datum/goap_action/russian/attack_ranged/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	preconditions["hasAmmo"] = TRUE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/attack_ranged/AdvancedPreconditions(mob/living/simple_animal/hostile/russian/ranged/RU, list/worldstate)
	if(!RU.ammo_left)
		return FALSE
	var/list/viewl = view(10, RU)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat && !RU.CheckFriendlyFire(C))
			target = C
	return (target != null)

/datum/goap_action/russian/attack_ranged/RequiresInRange()
	return FALSE

/datum/goap_action/russian/attack_ranged/Perform(mob/living/simple_animal/hostile/russian/ranged/A)
	var/mob/living/carbon/C = target
	A.visible_message("<span class = 'danger'>[A] fires at [C]!</span>")
	A.Shoot(C, rand(-(get_dist(A, target)), get_dist(A, target)))
	A.ammo_left--
	action_done = TRUE
	return ..()

/datum/goap_action/russian/attack_ranged/CheckDone(atom/agent)
	return action_done

/datum/goap_action/russian/grenade_out_take_cover
	name = "Throw Grenade"
	cost = 4
	cooldown = 50

/datum/goap_action/russian/grenade_out_take_cover/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/grenade_out_take_cover/AdvancedPreconditions(mob/living/simple_animal/hostile/russian/ranged/A, list/worldstate)
	if(A.grenade_to_throw == null || A.grenades_left < 1)
		return FALSE
	var/list/viewl = view(10, A)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat && !A.CheckFriendlyFire(C))
			target = C
	return (target != null)

/datum/goap_action/russian/grenade_out_take_cover/RequiresInRange()
	return FALSE

/datum/goap_action/russian/grenade_out_take_cover/Perform(mob/living/simple_animal/hostile/russian/ranged/A)
	cooldown_time = world.time + cooldown
	var/mob/living/carbon/C = target
	A.say(pick(list("GRENADA VYKHODA KRYSHKA!","GRANADA, GRANADA!","LOZHIS'!")))
	A.visible_message("<span class = 'danger'>[A] throws a grenade at [C]!</span>")
	var/obj/item/grenade/G = new A.grenade_to_throw(get_turf(A))
	G.preprime(A, 5)
	G.throw_at(C, 10, 1)
	A.grenades_left--
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
	preconditions["hasAmmo"] = FALSE
	effects = list()
	effects["hasAmmo"] = TRUE

/datum/goap_action/russian/reload/AdvancedPreconditions(mob/living/simple_animal/hostile/russian/ranged/A, list/worldstate)
	if(A.reloads_left)
		return TRUE
	else
		return FALSE

/datum/goap_action/russian/reload/RequiresInRange()
	return FALSE

/datum/goap_action/russian/reload/Perform(mob/living/simple_animal/hostile/russian/ranged/A)
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
	preconditions["allyHealed"] = FALSE
	effects = list()
	effects["allyHealed"] = TRUE

/datum/goap_action/russian/medic/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	for(var/mob/living/simple_animal/hostile/russian/ranged/R in viewl)
		if(!R.stat)
			if(R.health < (R.maxHealth/2) && PATH_CHECK(src, R))
				target = R
				break
	return (target != null)

/datum/goap_action/russian/medic/RequiresInRange()
	return TRUE

/datum/goap_action/russian/medic/Perform(mob/living/simple_animal/hostile/russian/ranged/A)
	if(target)
		A.say(pick(list("Isprav'te sebya!","Medik na stsene!","Ostanovite poluchat' vystrel tak mnogo!")))
		if(prob(1))
			A.visible_message("[A] hands [target] some vodka! [target] chugs it, feeling rejuvenated!")
		else
			A.visible_message(pick(list("[A] applies some libital to [target]!", "[A] bandages some wounds on [target]!", "[A] quickly stitches close a cut on [target]!")))
		var/mob/living/simple_animal/hostile/russian/ranged/R = target
		R.health += (R.maxHealth/4)
		action_done = TRUE
		return ..()
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
	preconditions["allyRearmed"] = FALSE
	effects = list()
	effects["allyRearmed"] = TRUE

/datum/goap_action/russian/resupply/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	for(var/mob/living/simple_animal/hostile/russian/ranged/R in viewl)
		if(!R.stat)
			if(!R.reloads_left)
				target = R
				break
	return (target != null)

/datum/goap_action/russian/resupply/RequiresInRange()
	return FALSE

/datum/goap_action/russian/resupply/Perform(mob/living/simple_animal/hostile/russian/ranged/A)
	var/mob/living/simple_animal/hostile/russian/ranged/RU = target
	if(target)
		A.say(pick(list("Voz'mi eto boyepripasy, tovarishch!","Perezagruzite oruzhiye!","Perezagruzite svoy grebanyy idiot!")))
		A.visible_message("[A] throws a new magazine to [target]!")
		var/obj/item/russian_reload/RE = new /obj/item/russian_reload(get_turf(AA_MATCH_TARGET_OVERLAYS))
		RE.throw_at(target, 10, 1)
		RU.reloads_left = 3
		RU.say(pick(list("Spasiba!","Spasiba za boyepripasy!","Ti khahroshiy spetsiahlist!")))
		QDEL_IN(RE, 15)
		action_done = TRUE
		return ..()
	else
		action_done = TRUE
		return FALSE


/datum/goap_action/russian/resupply/CheckDone(atom/agent)
	return action_done

/datum/goap_action/russian/dodge
	name = "Dodge!"
	cost = 1
	cooldown = 50
	saytext = "OPAH! CANNOT EVEN HIT RUSSIAN BABY!"

/datum/goap_action/russian/dodge/New()
	..()
	preconditions = list()
	preconditions["dodgeEnemy"] = FALSE
	effects = list()
	effects["dodgeEnemy"] = TRUE

/datum/goap_action/russian/dodge/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat)
			target = C
	return (target != null)

/datum/goap_action/russian/dodge/RequiresInRange(atom/agent)
	return FALSE

/datum/goap_action/russian/dodge/Perform(mob/living/simple_animal/hostile/H)
	H.SpinAnimation(5, 0) // half a second spin but one second immunity
	DodgeEffect(H)
	var/oldhealth = H.health
	H.health = INFINITY // Iframes!
	addtimer(VARSET_CALLBACK(H, health, oldhealth), 10) // turn their health back
	action_done = TRUE
	return ..()

/datum/goap_action/russian/dodge/proc/DodgeEffect(atom/agent)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/N = new (get_turf(agent), agent)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/E = new (get_turf(agent), agent)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/S = new (get_turf(agent), agent)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/W = new (get_turf(agent), agent)
	step(N, NORTH)
	step(E, EAST)
	step(S, SOUTH)
	step(W, WEST)

/datum/goap_action/russian/dodge/CheckDone(atom/agent)
	return action_done

/datum/goap_action/russian/throw_knives
	name = "Throw a knife"
	cost = 1// attack + dodge = 6 so this is only done if you can't attack
	cooldown = 100
	saytext = "I SHARE KNIFE WITH YOU!"

/datum/goap_action/russian/throw_knives/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/throw_knives/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat)
			target = C
	return (target != null)

/datum/goap_action/russian/throw_knives/RequiresInRange(atom/agent)
	return FALSE

/datum/goap_action/russian/throw_knives/Perform(atom/agent)
	var/obj/item/kitchen/knife/K = new /obj/item/kitchen/knife(get_turf(agent))
	K.throw_at(target, 10, 1, agent)
	action_done = TRUE
	return ..()

/datum/goap_action/russian/throw_knives/CheckDone(atom/agent)
	return action_done

/datum/goap_action/russian/melee
	name = "Melee"
	cost = 2
	saytext = "Bleed, capitalist pig!"

/datum/goap_action/russian/melee/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/russian/melee/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat)
			target = C
	return (target != null)

/datum/goap_action/russian/melee/RequiresInRange()
	return TRUE

/datum/goap_action/russian/melee/Perform(mob/living/simple_animal/hostile/A)
	var/mob/living/carbon/C = target
	C.attack_animal(A)
	action_done = TRUE
	return ..()

/datum/goap_action/russian/melee/CheckDone(atom/agent)
	return action_done
