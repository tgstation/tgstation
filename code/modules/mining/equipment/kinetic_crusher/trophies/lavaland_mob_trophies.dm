/**
 * Place lavaland small game trophies here.
 */

/**
 * Goliath
 * Detonating a mark causes extra damage to the victim based on how much health the user is missing.
 */
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	///How much of user's missing health is converted into bonus damage, %
	var/missing_health_ratio = 0.1
	/// Amount of health you must lose to gain damage, according to the examine text. Cached so we don't recalculate it every examine.
	var/missing_health_desc

/obj/item/crusher_trophy/goliath_tentacle/Initialize(mapload)
	. = ..()
	missing_health_desc = 100 * missing_health_ratio
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_SPELL, bonus_value)

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> more damage for every <b>[missing_health_desc]</b> health you are missing"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	var/missing_health = user.maxHealth - user.health
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		target.adjustBruteLoss(missing_health) //and do that much damage
		SEND_SIGNAL(src, COMSIG_CRUSHER_SPELL_HIT, target, user, missing_health)

/**
 * Watcher
 * Detonating a mark causes the victim's next ranged attack/special attack to cool down slower.
 */
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 5

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[bonus_value * 0.1]</b> second\s"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/victim = target //this is fun, doesn't apply to basic mobs. need to look into that
		if(victim.ranged) //briefly delay ranged attacks
			if(victim.ranged_cooldown >= world.time)
				victim.ranged_cooldown += bonus_value
			else
				victim.ranged_cooldown = bonus_value + world.time

/**
 * Watcher - icewing variant
 * Detonating a mark causes the victim's next ranged attack/special attack to cool down even slower.
 */
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8

/**
 * Watcher - magmawing variant
 * Detonating a mark causes the next destabilizer shot to deal damage.
 * The bonus lasts for a single shot and resets after 30 seconds.
 */
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "A still-searing wing from a magmawing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		marker.AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_PROJECTILE, bonus_value)
		deadly_shot = FALSE

/**
 * Legion - the carbon-sized one
 * Causes the crusher's destabilizer shot to recharge faster.
 */
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[bonus_value*0.1]</b> second\s faster"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(.)
		target_crusher.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(.)
		target_crusher.charge_time += bonus_value

/**
 * Lobstrosity
 * Detonating a mark causes the victim to stagger for 1 second, which slows down movement
 * and more than doubles the cooldown for the victim's ranged attack (if it's a simple hostile mob).
 */
/obj/item/crusher_trophy/lobster_claw
	name = "lobster claw"
	icon_state = "lobster_claw"
	desc = "A lobster claw. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/lobster_claw
	bonus_value = 1 SECONDS

/obj/item/crusher_trophy/lobster_claw/effect_desc()
	return "mark detonation to briefly stagger the target for [bonus_value * 0.1] seconds"

/obj/item/crusher_trophy/lobster_claw/on_mark_detonation(mob/living/target, mob/living/user)
	target.apply_status_effect(/datum/status_effect/stagger, bonus_value)

/**
 * Brimdemon
 * Detonating a mark causes a loud = funny sound and a comedic message to appear on the victim.
 */
/obj/item/crusher_trophy/brimdemon_fang
	name = "brimdemon's fang"
	icon_state = "brimdemon_fang"
	desc = "A fang from a brimdemon's corpse. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/brimdemon_fang
	///Humorous words to display on mark detonation
	var/static/list/comic_phrases = list("BOOM", "BANG", "KABLOW", "KAPOW", "OUCH", "BAM", "KAPOW", "WHAM", "POW", "KABOOM")

/obj/item/crusher_trophy/brimdemon_fang/effect_desc()
	return "mark detonation to create visual and audiosensory effects on the target"

/obj/item/crusher_trophy/brimdemon_fang/on_mark_detonation(mob/living/target, mob/living/user)
	var/turf/victim_turf = get_turf(target)
	victim_turf.balloon_alert_to_viewers("[pick(comic_phrases)]!")
	playsound(victim_turf, 'sound/lavaland/brimdemon_crush.ogg', 100)

/**
 * Bileworm
 * Detonating a mark causes 4 acid spewlets to be shot in 4 cardinal directions, on a 10 seconds cooldown.
 */
/obj/item/crusher_trophy/bileworm_spewlet
	name = "bileworm spewlet"
	icon = 'icons/mob/simple/lavaland/bileworm.dmi'
	icon_state = "bileworm_spewlet"
	desc = "A baby bileworm. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/bileworm_spewlet
	///item ability that handles the effect
	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet/ability

/obj/item/crusher_trophy/bileworm_spewlet/effect_desc()
	return "mark detonation to launch projectiles in cardinal directions on a 10 second cooldown"

/obj/item/crusher_trophy/bileworm_spewlet/Initialize(mapload)
	. = ..()
	ability = new()

/obj/item/crusher_trophy/bileworm_spewlet/Destroy(force)
	. = ..()
	QDEL_NULL(ability)

/obj/item/crusher_trophy/bileworm_spewlet/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(.)
		crusher.add_item_action(ability)

/obj/item/crusher_trophy/bileworm_spewlet/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	crusher.remove_item_action(ability)

/obj/item/crusher_trophy/bileworm_spewlet/on_mark_detonation(mob/living/target, mob/living/user)
	//ability itself handles cooldowns.
	ability.InterceptClickOn(user, null, target)

//yes this is a /mob_cooldown subtype being added to an item. I can't recommend you do what I'm doing
/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet
	check_flags = NONE
	owner_has_control = FALSE
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/bileworm_acid/spewlet_trophy
	projectile_sound = 'sound/creatures/bileworm/bileworm_spit.ogg'

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet/New(Target)
	firing_directions = GLOB.cardinals.Copy()
	return ..()

/obj/projectile/bileworm_acid/spewlet_trophy

/obj/projectile/bileworm_acid/spewlet_trophy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_PROJECTILE, damage)
