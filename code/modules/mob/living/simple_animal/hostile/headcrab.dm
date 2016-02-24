#define EGG_INCUBATION_TIME 120

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

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/internal/body_egg/changeling_egg/egg = new(victim)
	egg.Insert(victim)
	if(mind)
		mind.transfer_to(egg.mind_holder)
	for(var/obj/item/organ/internal/I in src)
		I.loc = egg
	visible_message("<span class='warning'>[src] lays an egg in a [victim].</span>")
	egg_lain = 1

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	if(egg_lain)
		target.attack_animal(src)
		return
	if(iscarbon(target) && !ismonkey(target))
		// Changeling egg can survive in aliens!
		var/mob/living/carbon/C = target
		if(C.stat == DEAD)
			Infect(target)
			src << "<span class='userdanger'>With your egg laid you feel your death rapidly approaching, time to die...</span>"
			spawn(100)
				death()
			return
	target.attack_animal(src)


//defined here because why not?
/mob/living/mind_holder
	name = "abstract mind holder"

/mob/living/mind_holder/say(var/message)
	return

/mob/living/mind_holder/emote(var/message)
	return


/mob/living/mind_holder/Stat()
	..()
	if(istype(loc, /obj/item/organ/internal/body_egg/changeling_egg))
		var/obj/item/organ/internal/body_egg/changeling_egg/egg = loc
		stat("Bursting progress", "[egg.progress]/[egg.time_to_live]")



/obj/item/organ/internal/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	origin_tech = "biotech=7" // You need to be really lucky to obtain it.
	//	var/datum/mind/owner  //Replaced by the mind holder
	var/mob/living/mind_holder/mind_holder //Allow storing minds inside so they can't ghost out and meta it up
	var/progress
	var/time_to_live = EGG_INCUBATION_TIME

/obj/item/organ/internal/body_egg/changeling_egg/New()
	mind_holder = new(src)
	..()

/obj/item/organ/internal/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in dead people
	progress++
	if(progress >= time_to_live)
		Pop()
		organdatum.dismember(ORGAN_REMOVED)
		qdel(src)

/obj/item/organ/internal/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/monkey/M = new(owner)
	owner.stomach_contents += M

	for(var/obj/item/organ/internal/I in src)
		I.Insert(M, 1)

	if(mind_holder && mind_holder.mind && mind_holder.key)
		var/datum/mind/owner = mind_holder.mind
		owner.transfer_to(M)
		if(owner.changeling)
			owner.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
		M.key = owner.key
	owner.gib()

#undef EGG_INCUBATION_TIME
