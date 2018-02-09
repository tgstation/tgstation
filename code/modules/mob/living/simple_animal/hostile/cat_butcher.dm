/mob/living/simple_animal/hostile/cat_butcherer
	name = "Cat Surgeon"
	desc = "A man with the quest of chasing endless feline tail."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "cat_butcher"
	icon_living = "cat_butcher"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "slashes at"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/mob_spawn/human/corpse/cat_butcher, /obj/item/circular_saw)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("hostile")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1

/mob/living/simple_animal/hostile/cat_butcherer/AttackingTarget()
	. = ..()
	if(. && prob(35) && iscarbon(target))
		var/mob/living/carbon/human/L = target
		if(L.dna.features["tail_human"] == "Cat")
			visible_message("[src] severs [L]'s tail in one swift swipe!", "<span class='notice'>You sever [L]'s tail in one swift swipe.</span>")
			L.dna.features["tail_human"] -= "Cat"
			L.dna.species.mutant_bodyparts -= "tail_human"
			L.update_body()
			new /obj/item/organ/tail/cat(get_turf(target))
		return 1
