//Place lavaland small game trophies here.


/**
 * Goliath
 * Detonating a mark causes extra damage to the victim based on how much health the user is missing.
 */
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_types = list(/obj/item/crusher_trophy/goliath_tentacle)
	///How much damage does the crusher deal per missing health
	var/bonus_damage = 2
	///How much of user's missing health is converted into bonus damage, %
	var/missing_health_ratio = 0.1

/obj/item/crusher_trophy/goliath_tentacle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_SPELL, bonus_damage)

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "mark detonation to do <b>[bonus_damage]</b> more damage for every <b>[100 * missing_health_ratio]</b> health you are missing"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(datum/source, mob/living/target, mob/living/user)
	. = ..()

	var/missing_health = user.maxHealth - user.health
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_damage //multiply the remaining amount by bonus_damage
	if(missing_health > 0)
		log_combat(user, target, "struck for bonus damage with a trophy ", src, "crusher damage")
		playsound(target, 'sound/weapons/whipgrab.ogg', 35 + 2 * missing_health, TRUE)
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
	denied_types = list(/obj/item/crusher_trophy/watcher_wing)
	///By how long does the victim's attack get delayed
	var/victim_attack_delay = 0.5 SECONDS

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[DisplayTimeText(victim_attack_delay)]</b>"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(datum/source, mob/living/target, mob/living/user)
	. = ..()

	if(ishostile(target))
		var/mob/living/simple_animal/hostile/victim = target //this is fun, doesn't apply to basic mobs. need to look into that
		if(victim.ranged) //briefly delay ranged attacks
			if(victim.ranged_cooldown >= world.time)
				victim.ranged_cooldown += victim_attack_delay
			else
				victim.ranged_cooldown = victim_attack_delay + world.time

/**
 * Watcher - icewing variant
 * Detonating a mark causes the victim's next ranged attack/special attack to cool down even slower.
 */
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	victim_attack_delay = 0.8 SECONDS

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
	projectile_damage = 5

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[projectile_damage]</b> damage"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(datum/source, obj/projectile/destabilizer/marker, mob/living/user)
	. = ..()

	if(!deadly_shot)
		return
	marker.name = "heated [marker.name]"
	marker.icon_state = "lava"
	marker.damage = projectile_damage
	marker.AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_PROJECTILE, projectile_damage)
	deadly_shot = FALSE

/**
 * Legion - the carbon-sized one
 * Causes the crusher's destabilizer shot to recharge faster.
 */
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_types = list(/obj/item/crusher_trophy/legion_skull)
	///By how much does the trophy reduce the crusher's destabilizer shot recharge delay
	var/recharge_delay_decrease = 0.3 SECONDS

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[DisplayTimeText(recharge_delay_decrease)]</b> faster"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(!.)
		return
	target_crusher.charge_time -= recharge_delay_decrease

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(!.)
		return
	target_crusher.charge_time += recharge_delay_decrease

/**
 * Lobstrosity
 * Detonating a mark causes the victim to stagger for 1 second, which slows down movement
 * and more than doubles the cooldown for the victim's ranged attack (if it's a simple hostile mob).
 */
/obj/item/crusher_trophy/lobster_claw
	name = "lobster claw"
	icon_state = "lobster_claw"
	desc = "A lobster claw. Suitable as a trophy for a kinetic crusher."
	denied_types = list(/obj/item/crusher_trophy/lobster_claw)
	///How long does the stagger effect last for on the affected mob
	var/effect_duration = 1 SECONDS

/obj/item/crusher_trophy/lobster_claw/effect_desc()
	return "mark detonation to briefly stagger the target for <b>[DisplayTimeText(effect_duration)]</b>"

/obj/item/crusher_trophy/lobster_claw/on_mark_detonation(datum/source, mob/living/target, mob/living/user)
	. = ..()

	target.apply_status_effect(/datum/status_effect/stagger, effect_duration)

/**
 * Brimdemon
 * Detonating a mark causes a loud = funny sound and a comedic message to appear on the victim.
 */
/obj/item/crusher_trophy/brimdemon_fang
	name = "brimdemon's fang"
	icon_state = "brimdemon_fang"
	desc = "A fang from a brimdemon's corpse. Suitable as a trophy for a kinetic crusher."
	denied_types = list(/obj/item/crusher_trophy/brimdemon_fang)
	///Humorous words to display on mark detonation
	var/static/list/comic_phrases = list("BOOM", "BANG", "KABLOW", "KAPOW", "OUCH", "BAM", "KAPOW", "WHAM", "POW", "KABOOM")

/obj/item/crusher_trophy/brimdemon_fang/effect_desc()
	return "mark detonation to create <b>visual and audiosensory effects</b> on the target"

/obj/item/crusher_trophy/brimdemon_fang/on_mark_detonation(datum/source, mob/living/target, mob/living/user)
	. = ..()

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
	denied_types = list(/obj/item/crusher_trophy/bileworm_spewlet)
	COOLDOWN_DECLARE(spew_cooldown)
	///How long does the cooldown between the shots last
	var/spew_cooldown_time = 10 SECONDS

/obj/item/crusher_trophy/bileworm_spewlet/effect_desc()
	return "mark detonation to <b>launch projectiles</b> in cardinal directions on a <b>[DisplayTimeText(spew_cooldown_time)]</b> cooldown"

/obj/item/crusher_trophy/bileworm_spewlet/on_mark_detonation(datum/source, mob/living/target, mob/living/user)
	. = ..()

	if(!COOLDOWN_FINISHED(src, spew_cooldown))
		return
	var/list/firing_directions = GLOB.cardinals.Copy()
	var/turf/user_turf = get_turf(user)
	playsound(user_turf, 'sound/creatures/bileworm/bileworm_spit.ogg', 80, TRUE)
	for(var/firing_dir in firing_directions)
		var/obj/projectile/bileworm_acid/spewlet_trophy/new_spew = new(user_turf)
		new_spew.preparePixelProjectile(target, user)
		new_spew.firer = user
		INVOKE_ASYNC(new_spew, TYPE_PROC_REF(/obj/projectile, fire), dir2angle(firing_dir))

	COOLDOWN_START(src, spew_cooldown, spew_cooldown_time)

/obj/projectile/bileworm_acid/spewlet_trophy

/obj/projectile/bileworm_acid/spewlet_trophy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_PROJECTILE, damage)
