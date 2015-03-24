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
	var/datum/mind/origin

/mob/living/simple_animal/hostile/headcrab/proc/Infect(var/mob/living/carbon/human/victim)
	var/obj/item/changeling_egg/egg = new(victim)
	egg.owner = origin
	victim.internal_organs += egg
	visible_message("<span class='notice'>[src] lays an egg in a [victim]!</span>")

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat == DEAD)
			Infect(target)
			src.Die()
			return
	target.attack_animal(src)

/obj/item/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob
	var/datum/mind/owner
	var/time

/obj/item/changeling_egg/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		affected_mob.status_flags |= XENO_HOST
		SSobj.processing |= src
		if(istype(affected_mob,/mob/living/carbon))
			var/mob/living/carbon/H = affected_mob
			H.med_hud_set_status()
	else
		qdel(src)

/obj/item/changeling_egg/process()
	if(!affected_mob)	return
	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		SSobj.processing.Remove(src)
		if(istype(affected_mob,/mob/living/carbon))
			var/mob/living/carbon/H = affected_mob
			H.med_hud_set_status()
		affected_mob = null
		return
	//Changeling eggs grow in dead people
	time++
	if(time >= EGG_INCUBATION_TIME)
		Pop()

obj/item/changeling_egg/proc/Pop()
	var/mob/living/carbon/monkey/M = new(affected_mob.loc)
	owner.transfer_to(M)
	owner.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
	M.key = owner.key
	affected_mob.gib()
	qdel(src)

#undef EGG_INCUBATION_TIME
