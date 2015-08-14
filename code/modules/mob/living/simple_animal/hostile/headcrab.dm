#define EGG_INCUBATION_TIME 180

/mob/living/simple_animal/hostile/headcrab
	name = "Headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = 2
	environment_smash = 0
	speak_emote = list("squeaks")
	ventcrawler = 2
	var/datum/mind/origin
	var/egg_lain = 0

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/human/victim)
	var/obj/item/body_egg/changeling_egg/egg = new(victim)
	if(origin)
		egg.owner = origin
	else if(mind) // Let's make this a feature
		egg.owner = mind
	victim.internal_organs += egg
	visible_message("<span class='warning'>[src] lays an egg in a [victim].</span>")
	egg_lain = 1

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	if(egg_lain)
		target.attack_animal(src)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat == DEAD)
			Infect(target)
			src << "<span class='userdanger'>With your egg laid you feel your death rapidly approaching, time to die...</span>"
			spawn(100)
				death()
			return
	target.attack_animal(src)




/obj/item/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting"
	var/datum/mind/owner
	var/time
	var/used

/obj/item/body_egg/changeling_egg/egg_process()
	//Changeling eggs grow in dead people
	time++
	if(time >= EGG_INCUBATION_TIME)
		Pop()

/obj/item/body_egg/changeling_egg/proc/Pop()
	if(!used)
		var/mob/living/carbon/monkey/M = new(affected_mob.loc)
		if(owner)
			owner.transfer_to(M)
			if(owner.changeling)
				owner.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
			M.key = owner.key
		if(ishuman(affected_mob))
			var/mob/living/carbon/human/H = affected_mob
			H.internal_organs.Remove(src)
		affected_mob.gib()
		used = 1
	qdel(src)

#undef EGG_INCUBATION_TIME
