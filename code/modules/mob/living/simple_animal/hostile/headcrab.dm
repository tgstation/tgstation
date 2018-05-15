#define EGG_INCUBATION_TIME 120

/mob/living/simple_animal/hostile/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	gender = NEUTER
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_ALWAYS
	var/egg_lain = FALSE
	gold_core_spawnable = HOSTILE_SPAWN //are you sure about this??
	var/datum/mind/origin

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/body_egg/changeling_egg/egg = new(victim)
	egg.Insert(victim)
	if(mind) // Let's make this a feature //sounds good to me!
		egg.origin = mind
	else if(isnull(origin))
		notify_ghosts("A mindless headslug has implanted a being!", source = egg, action=NOTIFY_ATTACK, flashwindow = FALSE)
	else
		egg.origin = origin // admins can rig it without disappointing ghosts
	for(var/obj/item/organ/I in src)
		I.forceMove(egg)
	visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
	egg_lain = TRUE

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	. = ..()
	if(. && !egg_lain && iscarbon(target) && !ismonkey(target))
		// Changeling egg can survive in aliens!
		var/mob/living/carbon/C = target
		if(C.stat == DEAD)
			if(C.has_trait(TRAIT_XENO_HOST))
				to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
				return
			Infect(target)
			to_chat(src, "<span class='userdanger'>With our egg laid, our death approaches rapidly...</span>")
			addtimer(CALLBACK(src, .proc/death), 100)

/mob/living/simple_animal/hostile/headcrab/death()
	..()
	ghostize(TRUE) //you need to be a ghost to be the ling. Here, let me help.

/obj/item/organ/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	var/datum/mind/origin
	var/time = 0
	var/cooldown = 60
	var/true_hatch_time = EGG_INCUBATION_TIME

/obj/item/organ/body_egg/changeling_egg/Initialize(mapload)
	. = ..()
	var/randomization = (rand(80,120)/100) //+- 20%
	true_hatch_time = CEILING(true_hatch_time*randomization, 1) 

/obj/item/organ/body_egg/changeling_egg/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(isnull(origin) && !QDELETED(user) && user.mind) //you managed to be pulled (IE cloning) right as you attacked.
		origin = user.mind
		to_chat(user, "<span class='notice'>You will later spawn as a changeling, please remain as a ghost during this time or you may lose your spot!</span>")

/obj/item/organ/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in dead people
	time++
	if(time >= true_hatch_time)
		if(origin)
			if(!isobserver(origin.current)) //if you're doing something else when it's time to pop then you lose the role.
				origin = null
			else
				Pop()
				Remove(owner)
				qdel(src)
		else if(time > cooldown)
			notify_ghosts("A changeling is about to burst!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)
			cooldown = time + cooldown // (x*2cooldown)+cooldown where x is the amount of times the above notification is thrown. tldr it gets longer each time it's thrown.

/obj/item/organ/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/monkey/M = new(owner)
	owner.stomach_contents += M

	for(var/obj/item/organ/I in src)
		I.Insert(M, 1)

	if(origin)
		origin.transfer_to(M)
		var/datum/antagonist/changeling/C = origin.has_antag_datum(/datum/antagonist/changeling)
		if(!C)
			C = origin.add_antag_datum(/datum/antagonist/changeling/xenobio)
		if(C.can_absorb_dna(owner))
			C.add_new_profile(owner)

		C.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
		M.key = origin.key
	owner.gib()

#undef EGG_INCUBATION_TIME
