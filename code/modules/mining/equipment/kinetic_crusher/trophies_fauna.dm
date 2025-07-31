/*!
 * Contains crusher trophies you can obtain from regular fauna
 */

//watcher
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	trophy_id = TROPHY_WATCHER
	bonus_value = 5
	wildhunter_drop = /obj/item/stack/sheet/sinew

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[bonus_value*0.1]</b> second\s"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(!ishostile(target))
		return
	var/mob/living/simple_animal/hostile/hostile_animal = target
	if(!hostile_animal.ranged)
		return
	if(hostile_animal.ranged_cooldown >= world.time) //briefly delay ranged attacks
		hostile_animal.ranged_cooldown += bonus_value
	else
		hostile_animal.ranged_cooldown = bonus_value + world.time

//magmawing watcher
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "A still-searing wing from a magmawing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5
	wildhunter_drop = /obj/item/stack/sheet/sinew

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		deadly_shot = FALSE

//icewing watcher
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8
	wildhunter_drop = /obj/item/stack/sheet/sinew

//legion
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3
	wildhunter_drop = /obj/item/organ/monster_core/regenerative_core/legion // if you killed blood drunk you can afford stabilizer potions sooo....

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[bonus_value*0.1]</b> second\s faster"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/pkc, mob/living/user)
	. = ..()
	if(.)
		pkc.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/pkc, mob/living/user)
	. = ..()
	if(.)
		pkc.charge_time += bonus_value

// Goliath - Increases damage as your health decreases.
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	trophy_id = TROPHY_GOLIATH_TENTACLE
	wildhunter_drop = /obj/item/stack/sheet/animalhide/goliath_hide
	/// Your missing health is multiplied by this value to find the bonus damage
	var/missing_health_ratio = 0.1
	/// Amount of health you must lose to gain damage, according to the examine text. Cached so we don't recalculate it every examine.
	var/missing_health_desc

/obj/item/crusher_trophy/goliath_tentacle/Initialize(mapload)
	. = ..()
	missing_health_desc = 1 / missing_health_ratio / bonus_value

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> more damage for every <b>[missing_health_desc]</b> health you are missing"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	var/missing_health = user.maxHealth - user.health
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		return missing_health //and do that much damage

// Lobstrosity - Rebukes targets, increasing their click cooldown.
/obj/item/crusher_trophy/lobster_claw
	name = "lobster claw"
	icon_state = "lobster_claw"
	desc = "A lobster claw."
	denied_type = /obj/item/crusher_trophy/lobster_claw
	trophy_id = TROPHY_LOBSTER_CLAW
	bonus_value = 1
	wildhunter_drop = /obj/item/organ/monster_core/rush_gland

/obj/item/crusher_trophy/lobster_claw/effect_desc()
	return "mark detonation to briefly rebuke the target for [bonus_value] second[bonus_value > 1 ? "s" : ""]"

/obj/item/crusher_trophy/lobster_claw/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	target.apply_status_effect(/datum/status_effect/rebuked, bonus_value SECONDS)

// Brimdemon - makes a funny sound, the most essential trophy out of all
/obj/item/crusher_trophy/brimdemon_fang
	name = "brimdemon's fang"
	icon_state = "brimdemon_fang"
	desc = "A fang from a brimdemon's corpse."
	denied_type = /obj/item/crusher_trophy/brimdemon_fang
	trophy_id = TROPHY_BRIMDEMON_FANG
	wildhunter_drop = /obj/item/organ/monster_core/brimdust_sac
	/// Cartoon punching vfx
	var/static/list/comic_phrases = list("BOOM", "BANG", "KABLOW", "KAPOW", "OUCH", "BAM", "KAPOW", "WHAM", "POW", "KABOOM")

/obj/item/crusher_trophy/brimdemon_fang/effect_desc()
	return "mark detonation to create visual and audiosensory effects at the target"

/obj/item/crusher_trophy/brimdemon_fang/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	target.balloon_alert_to_viewers("[pick(comic_phrases)]!")
	playsound(target, 'sound/mobs/non-humanoids/brimdemon/brimdemon_crush.ogg', 100)

// Bileworm
/obj/item/crusher_trophy/bileworm_spewlet
	name = "bileworm spewlet"
	icon = 'icons/mob/simple/lavaland/bileworm.dmi'
	icon_state = "bileworm_spewlet"
	desc = "A baby bileworm. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/bileworm_spewlet
	wildhunter_drop = /obj/item/stack/sheet/animalhide/bileworm
	///item ability that handles the effect
	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet/ability

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

/obj/item/crusher_trophy/bileworm_spewlet/effect_desc()
	return "mark detonation launches projectiles in cardinal directions on a 10 second cooldown. Also gives you an AOE when mining minerals"

/obj/item/crusher_trophy/bileworm_spewlet/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	//ability itself handles cooldowns.
	ability.InterceptClickOn(user, null, target)

/obj/item/crusher_trophy/bileworm_spewlet/on_projectile_hit_mineral(turf/closed/mineral, mob/living/user)
	for(var/turf/closed/mineral/mineral_turf in RANGE_TURFS(1, mineral) - mineral)
		mineral_turf.gets_drilled(user, 1)

//yes this is a /mob_cooldown subtype being added to an item. I can't recommend you do what I'm doing
/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet
	check_flags = NONE
	owner_has_control = FALSE
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/bileworm_acid/crusher
	projectile_sound = 'sound/mobs/non-humanoids/bileworm/bileworm_spit.ogg'

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet/New(Target)
	firing_directions = GLOB.cardinals.Copy()
	return ..()

/obj/projectile/bileworm_acid/crusher
	damage_type = BRUTE // Otherwise the mobs take heavily reduced damage

/obj/projectile/bileworm_acid/crusher/prehit_pierce(atom/target)
	if (!isliving(target))
		return ..()
	var/mob/living/as_living = target
	// Only hit hostile things, or mining mobs if we have no firer (somehow)
	if (firer)
		if (firer.faction_check_atom(as_living))
			return PROJECTILE_DELETE_WITHOUT_HITTING
		return ..()
	if (as_living.mob_biotypes & MOB_MINING)
		return ..()
	return PROJECTILE_DELETE_WITHOUT_HITTING

// demonic watcher
/obj/item/crusher_trophy/ice_demon_cube
	name = "demonic cube"
	desc = "A stone cold cube dropped from an ice demon."
	icon_state = "ice_demon_cube"
	denied_type = /obj/item/crusher_trophy/ice_demon_cube
	trophy_id = TROPHY_ICE_DEMON
	///how many will we summon?
	var/summon_amount = 2
	///cooldown to summon demons upon the target
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/crusher_trophy/ice_demon_cube/effect_desc()
	return "mark detonation to unleash demonic ice clones upon the target"

/obj/item/crusher_trophy/ice_demon_cube/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(isnull(target) || !COOLDOWN_FINISHED(src, summon_cooldown))
		return
	for(var/i in 1 to summon_amount)
		var/turf/drop_off = find_dropoff_turf(target, user)
		var/mob/living/basic/mining/demon_afterimage/crusher/friend = new(drop_off)
		friend.faction = list(FACTION_NEUTRAL)
		friend.befriend(user)
		friend.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
	COOLDOWN_START(src, summon_cooldown, 30 SECONDS)

///try to make them spawn all around the target to surround him
/obj/item/crusher_trophy/ice_demon_cube/proc/find_dropoff_turf(mob/living/target, mob/living/user)
	var/list/turfs_list = get_adjacent_open_turfs(target)
	for(var/turf/possible_turf in turfs_list)
		if(possible_turf.is_blocked_turf())
			continue
		return possible_turf
	return get_turf(user)

// Wolf

/obj/item/crusher_trophy/wolf_ear
	name = "wolf ear"
	desc = "It's a wolf ear."
	icon_state = "wolf_ear"
	trophy_id = TROPHY_WOLF_EAR
	denied_type = /obj/item/crusher_trophy/wolf_ear

/obj/item/crusher_trophy/wolf_ear/effect_desc()
	return "mark detonation to gain a slight speed boost temporarily"

/obj/item/crusher_trophy/wolf_ear/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	user.apply_status_effect(/datum/status_effect/speed_boost, 1 SECONDS)

// Polar bear - If you're hurt, you attack twice when you detonate a mark
/obj/item/crusher_trophy/bear_paw
	name = "polar bear paw"
	desc = "It's a polar bear paw."
	icon_state = "bear_paw"
	trophy_id = TROPHY_BEAR_PAW
	denied_type = /obj/item/crusher_trophy/bear_paw

/obj/item/crusher_trophy/bear_paw/effect_desc()
	return "mark detonation to attack twice if you are below half your life"

/obj/item/crusher_trophy/bear_paw/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(user.health / user.maxHealth > 0.5)
		return
	var/obj/item/weapon = user.get_active_held_item()
	if(weapon)
		addtimer(CALLBACK(weapon, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, target), 0.1 SECONDS)

// Raptor - Your shots now go through your allied mobs. You monster.
/obj/item/crusher_trophy/raptor_feather
	name = "raptor feather"
	desc = "A feather of an innocent raptor. You'd go to hell for this one, if you weren't already mining in it."
	icon_state = "raptor_feather"
	denied_type = /obj/item/crusher_trophy/raptor_feather
	trophy_id = TROPHY_RAPTOR_FEATHER
	wildhunter_drop = /obj/item/food/meat/slab/chicken

/obj/item/crusher_trophy/raptor_feather/effect_desc()
	return "your shots to go through your allies"

/obj/item/crusher_trophy/raptor_feather/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	marker.ignore_allies = TRUE
