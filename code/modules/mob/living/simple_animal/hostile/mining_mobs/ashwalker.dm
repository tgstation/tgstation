/mob/living/simple_animal/hostile/ashwalker
	name = "ashwalker"
	desc = "A wanderer of these ashen lands. Has an affinity for sacrificing people and stabbing you with their spear."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "ashwalker"
	icon_living = "ashwalker"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	speak_emote = list("hisses")
	faction = list("mining", "ashwalker")
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	weather_immunities = list(TRAIT_ASHSTORM_IMMUNE)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	dodging = TRUE
	dodge_prob = 15
	stat_attack = HARD_CRIT
	combat_mode = TRUE
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	status_flags = CANPUSH
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	maxHealth = 125
	health = 125
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 15
	attack_verb_continuous = "pokes"
	attack_verb_simple = "poke"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	combat_mode = TRUE
	loot = list(/obj/item/spear/bonespear, 
		/obj/effect/mob_spawn/corpse/human/ashwalker)
	del_on_death = 1

/mob/living/simple_animal/hostile/ashwalker/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))
		return FALSE
	return ..()
