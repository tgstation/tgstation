/mob/living/simple_animal/hostile/megafauna/clockwork_golem
	name = "clockwork golem"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE)
	speak_emote = list("clanks")
	vision_range = 9
	melee_queue_distance = 10
	ranged = TRUE
	gps_name = "Clockwork Signal"
	del_on_death = TRUE
	deathmessage = "cracks, beaking into multiple pieces."
	deathsound = SFX_CLOCKFALL
	footstep_type = FOOTSTEP_MOB_HEAVY

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete
	icon_state = "clockwork_golem_complete"
	icon_living = "clockwork_golem_complete"
	desc = "Remnants of an ancient group of craftsman."
	health = 1000
	maxHealth = 1000
	attack_verb_continuous = "drills"
	attack_verb_simple = "drill"
	attack_sound = 'sound/creatures/clockwork_golem_attack.ogg'
	attack_vis_effect = ATTACK_EFFECT_DRILL
	armour_penetration = 20
	melee_damage_lower = 25
	melee_damage_upper = 25
	speed = 15
	move_to_delay = 15
	/// Ruby blast
	var/datum/action/cooldown/mob_cooldown/projectile_attack/ruby_blast/ruby_blast
	/// Ruby blast
	var/datum/action/cooldown/mob_cooldown/release_smoke/release_smoke

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_damage, ORGAN_SLOT_HEART, 2)

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/broken
	icon_state = "clockwork_golem_broken"
	icon_living = "clockwork_golem_broken"
	desc = "A broken down version of a historical masterpiece."
	health = 300
	maxHealth = 300
	attack_verb_continuous = "drills"
	attack_verb_simple = "drill"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	armour_penetration = 40
	melee_damage_lower = 15
	melee_damage_upper = 20
	speed = 3
	move_to_delay = 3
	loot = list()
	crusher_loot = list()

/obj/projectile/bullet/ruby_blast
	name = "ruby blast"
	icon_state = "ruby_blast"
	damage = 50
	damage_type = BURN
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/ruby_blast/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, explosion_cause = src)
	return BULLET_ACT_HIT
