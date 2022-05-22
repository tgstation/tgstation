/mob/living/simple_animal/hostile/megafauna/clockwork_golem
	name = "clockwork golem"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE)
	speak_emote = list("clanks")
	pixel_x = -16
	gps_name = "Clockwork Signal"
	del_on_death = TRUE
	deathmessage = "cracks, beaking into multiple pieces."
	deathsound = SFX_CLOCKFALL
	footstep_type = FOOTSTEP_MOB_HEAVY

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/Initialize(mapload)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/death(gibbed)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(2, location = loc)
	smoke.start()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete
	icon_state = "clockwork_golem_complete"
	icon_living = "clockwork_golem_complete"
	desc = "Remnants of an ancient group of craftsman."
	health = 1700
	maxHealth = 1700
	attack_verb_continuous = "drills"
	attack_verb_simple = "drill"
	attack_sound = 'sound/creatures/clockwork_golem_attack.ogg'
	attack_vis_effect = ATTACK_EFFECT_DRILL
	armour_penetration = 20
	melee_damage_lower = 25
	melee_damage_upper = 25
	ranged = TRUE
	speed = 12
	move_to_delay = 12
	ranged_cooldown_time = 8 SECONDS
	loot = list(/obj/item/stack/sheet/bronze/ten, /obj/effect/decal/cleanable/oil)
	small_sprite_type = /datum/action/small_sprite/megafauna/clockwork_golem
	/// Ruby blast
	var/datum/action/cooldown/mob_cooldown/projectile_attack/ruby_blast/ruby_blast
	/// Oil ball
	var/datum/action/cooldown/mob_cooldown/projectile_attack/oil_ball/oil_ball
	/// Release smoke
	var/datum/action/cooldown/mob_cooldown/release_smoke/release_smoke
	/// Summon spider
	var/datum/action/cooldown/mob_cooldown/summon_minion/summon_spider

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_damage, ORGAN_SLOT_HEART, 15) // Yes, this is what it looks like.
	ruby_blast = new /datum/action/cooldown/mob_cooldown/projectile_attack/ruby_blast()
	release_smoke = new /datum/action/cooldown/mob_cooldown/release_smoke()
	oil_ball = new /datum/action/cooldown/mob_cooldown/projectile_attack/oil_ball()
	summon_spider = new /datum/action/cooldown/mob_cooldown/summon_minion()
	ruby_blast.Grant(src)
	release_smoke.Grant(src)
	oil_ball.Grant(src)
	summon_spider.Grant(src)

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete/Destroy()
	QDEL_NULL(ruby_blast)
	QDEL_NULL(release_smoke)
	QDEL_NULL(oil_ball)
	QDEL_NULL(summon_spider)
	return ..()

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete/death()
	new /mob/living/simple_animal/hostile/megafauna/clockwork_golem/broken(loc)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/clockwork_golem/complete/OpenFire()
	if(client)
		return
	if(prob(40))
		oil_ball.Trigger(target = target)
	else if(prob(30))
		summon_spider.Trigger(target = target)
	else if(prob(20))
		ruby_blast.Trigger(target = target)
	else
		release_smoke.Trigger(target = target)


/mob/living/simple_animal/hostile/megafauna/clockwork_golem/broken
	icon_state = "clockwork_golem_broken"
	icon_living = "clockwork_golem_broken"
	desc = "A broken down version of a historical masterpiece."
	health = 300
	maxHealth = 300
	attack_verb_continuous = "cuts"
	attack_verb_simple = "cut"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	vision_range = 9
	armour_penetration = 40
	melee_damage_lower = 15
	melee_damage_upper = 20
	rapid_melee = 4
	dodging = TRUE
	dodge_prob = 50
	speed = 1
	move_to_delay = 2
	melee_queue_distance = 10
	robust_searching = TRUE
	loot = list(/obj/item/stack/sheet/bronze/ten, /obj/effect/decal/cleanable/oil, /obj/item/book/granter/spell/oiljaunt)
	crusher_loot = list(/obj/item/stack/sheet/bronze/ten, /obj/effect/decal/cleanable/oil, /obj/item/crusher_trophy/clockwork_rocket)
	small_sprite_type = /datum/action/small_sprite/megafauna/clockwork_golem/broken

/obj/projectile/bullet/ruby_blast
	name = "ruby blast"
	icon_state = "ruby_blast"
	speed = 4
	damage = 50
	damage_type = BURN
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/ruby_blast/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, explosion_cause = src)
	return BULLET_ACT_HIT

/obj/projectile/bullet/oil_ball
	name = "oil ball"
	icon_state = "oilball"
	speed = 4
	damage = 30
	damage_type = BURN
	embedding = null
	ricochets_max = 4
	ricochet_chance = 120
	ricochet_decay_chance = 0.8
	ricochet_incidence_leeway = 0
	knockdown = 10

/obj/projectile/bullet/oil_ball/on_ricochet(atom/A)
	new /obj/effect/decal/cleanable/oil/slippery(get_turf(loc))
	. = ..()

/obj/projectile/bullet/oil_ball/on_hit(atom/target, blocked = FALSE)
	new /obj/effect/decal/cleanable/oil/slippery(get_turf(loc))
	. = ..()

/obj/projectile/bullet/oil_ball/on_range()
	new /obj/effect/decal/cleanable/oil/slippery(get_turf(loc))
	. = ..()
