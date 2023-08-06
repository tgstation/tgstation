/// Watchers' ground-dwelling cousins, they shoot at you until they get into melee and absorb laser fire to power up.
/mob/living/basic/mining/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a diamond shell which absorbs heat. Its stare causes victims to freeze from the inside."
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_dead = "Basilisk_dead"
	speak_emote = list("chimes")
	damage_coeff = list(BRUTE = 1, BURN = 0.1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	speed = 20
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attack_verb_continuous = "bites into"
	attack_verb_simple = "bite into"
	throw_blocked_message = "bounces off the shell of"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/sheet/sinew = 2,
	)
	/// How often can we shoot?
	var/ranged_cooldown = 3 SECONDS
	/// What kind of beam do we fire?
	var/default_projectile_type = /obj/projectile/temp/watcher
	/// What does it sound like when we fire a beam?
	var/default_projectile_sound = 'sound/weapons/pierce.ogg'

/mob/living/basic/mining/basilisk/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_GLIDE, INNATE_TRAIT)
	AddElement(/datum/element/ranged_attacks, projectiletype = default_projectile_type, projectilesound = default_projectile_sound)

/mob/living/basic/mining/basilisk/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	heat_up() // Who would do this?

/mob/living/basic/mining/basilisk/bullet_act(obj/projectile/bullet, def_zone, piercing_hit)
	. = .. ()
	if (istype(bullet, /obj/projectile/temp))
		var/obj/projectile/temp/heat_bullet = bullet
		if (heat_bullet.temperature < 0)
			return
		heat_up()
		return

	if (bullet.damage == 0 || bullet.damage_type != BURN)
		return
	heat_up()

/mob/living/basic/mining/basilisk/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/turf/open/lava/entered_lava = loc
	if (!islava(entered_lava) || entered_lava.immunity_trait != TRAIT_LAVA_IMMUNE)
		return
	heat_up()

/// We got hit by something hot, go into heat mode
/mob/living/basic/mining/basilisk/proc/heat_up()
	if (stat != CONSCIOUS || has_status_effect(/datum/status_effect/basilisk_overheat))
		return
	apply_status_effect(/datum/status_effect/basilisk_overheat)
