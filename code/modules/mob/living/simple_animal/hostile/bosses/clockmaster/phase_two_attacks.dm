//Bunkers up wherever standing, charging up an AoE attack to blast anyone back who decided to stay close during this period. Reduced damage taken during the charge up.
/datum/action/boss/steam_blast
	name = "Steam Blast"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	say_when_triggered = "shes gonna BLOW!!!"

/datum/action/boss/steam_blast/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/action/boss/steam_blast/Trigger(trigger_flags)
	if(..())
		boss.atb.refund(boss_cost)

//Violently spin and move towards a random target. Walking into them causes severe damage and throws you back. Cannot be melee attacked during this, but also moves a bit slower
/datum/action/boss/spinning_bronze
	name = "Spinning Bronze"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	say_when_triggered = "u spin me rite round baby"

/datum/action/boss/spinning_bronze/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/action/boss/spinning_bronze/Trigger(trigger_flags)
	if(..())
		boss.atb.refund(boss_cost)

//Spawn several marauders and jaunt the boss into an observation area, boss will jaunt back in once all marauders are dead. Make the boss do funny insults at people during the fight.
/datum/action/boss/marauder_swarm
	name = "Marauder Swarm"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	say_when_triggered = "i got my boys to jump u lets see how tough u really r mfer"
	var/id = "clockmasterocularwarden"

/datum/action/boss/marauder_swarm/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/action/boss/marauder_swarm/Trigger(trigger_flags)
	if(..())
		boss.atb.refund(boss_cost)

/mob/living/simple_animal/hostile/clockwork/marauder
	name = "clockwork marauder"
	desc = "A hulking machine adorned in shining bronze armor, wielding a sword and shield."
	icon_state = "clockwork_marauader"
	icon_living = "clockwork_marauader"
	icon_dead = "shade_dead"
	turns_per_move = 5
	speed = 4
	maxHealth = 75
	health = 75
	melee_damage_lower = 12
	melee_damage_upper = 15
	rapid_melee = 2
	attack_verb_continuous = "stabs at"
	attack_verb_simple = "stab at"
	attack_sound = 'sound/weapons/rapierhit.ogg'
