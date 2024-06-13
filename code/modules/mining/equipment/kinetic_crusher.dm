/**
 * Kinetic Crusher
 *
 * Lavaland's "Hard Mode" option for players, requiring melee attacks (backstabs even better),
 * but allowing you to upgrade it with trophies gained from fighting lavaland monsters, making it
 * a good tradeoff and a decent playstyle.
 */
/obj/item/kinetic_crusher
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	inhand_icon_state = "crusher0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than a combination of various mining tools cobbled together, \
		forming a high-tech club. While it is an effective mining tool, it did little to aid any but the most skilled and/or \
		suicidal miners against local fauna."
	resistance_flags = FIRE_PROOF
	force = 0 //You can't hit stuff unless wielded
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.15, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*2.075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("smashes", "crushes", "cleaves", "chops", "pulps")
	attack_verb_simple = list("smash", "crush", "cleave", "chop", "pulp")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_range = 5
	light_power = 1.2
	light_color = "#ffff66"
	light_on = FALSE
	///List of all crusher trophies attached to this.
	var/list/obj/item/crusher_trophy/trophies = list()
	var/charged = TRUE
	var/charge_time = 1.5 SECONDS
	var/detonation_damage = 50
	var/backstab_bonus = 30

/obj/item/kinetic_crusher/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 6 SECONDS, \
		effectiveness = 110, \
	)
	//technically it's huge and bulky, but this provides an incentive to use it
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=20)
	RegisterSignal(src, COMSIG_HIT_BY_SABOTEUR, PROC_REF(on_saboteur))

/obj/item/kinetic_crusher/Destroy()
	QDEL_LIST(trophies)
	return ..()

/obj/item/kinetic_crusher/Exited(atom/movable/gone, direction)
	. = ..()
	trophies -= gone

/obj/item/kinetic_crusher/examine(mob/living/user)
	. = ..()
	. += span_notice("Mark a large creature with a destabilizing force with right-click, then hit them in melee to do <b>[force + detonation_damage]</b> damage.")
	. += span_notice("Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.")
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		. += span_notice("It has \a [crusher_trophy] attached, which causes [crusher_trophy.effect_desc()].")

/obj/item/kinetic_crusher/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/crusher_trophy = attacking_item
		crusher_trophy.add_to(src, user)
		return
	return ..()

/obj/item/kinetic_crusher/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!LAZYLEN(trophies))
		user.balloon_alert(user, "no trophies!")
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert(user, "trophies removed")
	tool.play_tool_sound(src)
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		crusher_trophy.remove_from(src, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/kinetic_crusher/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(.)
		return TRUE
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		user.balloon_alert(user, "must be wielded!")
		return TRUE
	return .

/obj/item/kinetic_crusher/afterattack(mob/living/target, mob/living/user, clickparams)
	if(!isliving(target))
		return
	// Melee effect
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		crusher_trophy.on_melee_hit(target, user)
	if(QDELETED(target))
		return
	// Clear existing marks
	var/valid_crusher_attack = FALSE
	for(var/datum/status_effect/crusher_mark/crusher_mark_effect as anything in target.get_all_status_effect_of_id(/datum/status_effect/crusher_mark))
		//this will erase ALL crusher marks, not only ones by you.
		if(crusher_mark_effect.hammer_synced != src || !target.remove_status_effect(/datum/status_effect/crusher_mark, src))
			continue
		valid_crusher_attack = TRUE
		break
	if(!valid_crusher_attack)
		return
	// Detonation effect
	var/datum/status_effect/crusher_damage/crusher_damage_effect = target.has_status_effect(/datum/status_effect/crusher_damage) || target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in trophies)
		crusher_trophy.on_mark_detonation(target, user)
	if(QDELETED(target))
		return
	if(!QDELETED(crusher_damage_effect))
		crusher_damage_effect.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did
	new /obj/effect/temp_visual/kinetic_blast(get_turf(target))
	var/backstabbed = FALSE
	var/combined_damage = detonation_damage
	var/backstab_dir = get_dir(user, target)
	var/def_check = target.getarmor(type = BOMB)
	// Backstab bonus
	if((user.dir & backstab_dir) && (target.dir & backstab_dir))
		backstabbed = TRUE
		combined_damage += backstab_bonus
		playsound(user, 'sound/weapons/kinetic_accel.ogg', 100, TRUE) //Seriously who spelled it wrong
	if(!QDELETED(crusher_damage_effect))
		crusher_damage_effect.total_damage += combined_damage
	SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, target, src, backstabbed)
	target.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		balloon_alert(user, "wield it first!")
		return ITEM_INTERACT_BLOCKING
	if(interacting_with == user)
		balloon_alert(user, "can't aim at yourself!")
		return ITEM_INTERACT_BLOCKING
	fire_kinetic_blast(interacting_with, user, modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	return ITEM_INTERACT_SUCCESS

/obj/item/kinetic_crusher/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/kinetic_crusher/proc/fire_kinetic_blast(atom/target, mob/living/user, list/modifiers)
	if(!charged)
		return
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/destabilizer/destabilizer = new(proj_turf)
	for(var/obj/item/crusher_trophy/attached_trophy as anything in trophies)
		attached_trophy.on_projectile_fire(destabilizer, user)
	destabilizer.preparePixelProjectile(target, user, modifiers)
	destabilizer.firer = user
	destabilizer.hammer_synced = src
	playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, TRUE)
	destabilizer.fire()
	charged = FALSE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(recharge_projectile)), charge_time)

/obj/item/kinetic_crusher/proc/recharge_projectile()
	if(!charged)
		charged = TRUE
		update_appearance()
		playsound(src.loc, 'sound/weapons/kinetic_reload.ogg', 60, TRUE)

/obj/item/kinetic_crusher/ui_action_click(mob/user, actiontype)
	set_light_on(!light_on)
	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_appearance()

/obj/item/kinetic_crusher/proc/on_saboteur(datum/source, disrupt_duration)
	set_light_on(FALSE)
	playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
	return COMSIG_SABOTEUR_SUCCESS

/obj/item/kinetic_crusher/update_icon_state()
	inhand_icon_state = "crusher[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent
	return ..()

/obj/item/kinetic_crusher/update_overlays()
	. = ..()
	if(!charged)
		. += "[icon_state]_uncharged"
	if(light_on)
		. += "[icon_state]_lit"

/obj/item/kinetic_crusher/compact //for admins
	name = "compact kinetic crusher"
	w_class = WEIGHT_CLASS_NORMAL

//destablizing force
/obj/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	armor_flag = BOMB
	range = 6
	log_override = TRUE
	///The crusher that's firing this projectile.
	var/obj/item/kinetic_crusher/hammer_synced

/obj/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/projectile/destabilizer/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/living_target = target
		var/has_mark_from_this_crusher = FALSE
		for(var/datum/status_effect/crusher_mark/crusher_mark_effect as anything in living_target.get_all_status_effect_of_id(/datum/status_effect/crusher_mark))
			if(crusher_mark_effect.hammer_synced != hammer_synced)
				continue
			has_mark_from_this_crusher = TRUE
			break
		if(!has_mark_from_this_crusher)
			living_target.apply_status_effect(/datum/status_effect/crusher_mark, hammer_synced)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/hit_mineral = target_turf
		new /obj/effect/temp_visual/kinetic_blast(hit_mineral)
		hit_mineral.gets_drilled(firer)
	return ..()

//trophies
/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "tail_spike"
	var/bonus_value = 10 //if it has a bonus effect, this is how much that effect is
	var/denied_type = /obj/item/crusher_trophy

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Causes [effect_desc()] when attached to a kinetic crusher.")

/obj/item/crusher_trophy/proc/effect_desc()
	return "errors"

/obj/item/crusher_trophy/attackby(obj/item/A, mob/living/user)
	if(istype(A, /obj/item/kinetic_crusher))
		add_to(A, user)
	else
		..()

/obj/item/crusher_trophy/proc/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/trophy as anything in crusher.trophies)
		if(istype(trophy, denied_type) || istype(src, trophy.denied_type))
			to_chat(user, span_warning("You can't seem to attach [src] to [crusher]. Maybe remove a few trophies?"))
			return FALSE
	if(!user.transferItemToLoc(src, crusher))
		return
	crusher.trophies += src
	to_chat(user, span_notice("You attach [src] to [crusher]."))
	return TRUE

/obj/item/crusher_trophy/proc/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	forceMove(get_turf(crusher))
	return TRUE

/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user) //the target and the user
/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user) //the projectile fired and the user
/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user) //the target and the user

//watcher
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 5

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[bonus_value*0.1]</b> second\s"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(H.ranged) //briefly delay ranged attacks
			if(H.ranged_cooldown >= world.time)
				H.ranged_cooldown += bonus_value
			else
				H.ranged_cooldown = bonus_value + world.time

//magmawing watcher
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
		deadly_shot = FALSE

//icewing watcher
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8

//legion
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[bonus_value*0.1]</b> second\s faster"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time += bonus_value

//blood-drunk hunter
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	icon_state = "hunter_eye"
	denied_type = /obj/item/crusher_trophy/miner_eye

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "mark detonation to grant stun immunity and <b>90%</b> damage reduction for <b>1</b> second"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/blooddrunk)

//ash drake
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/tail_spike
	bonus_value = 5

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> damage to nearby creatures and push them back"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/living_target in oview(2, user))
		if(user.faction_check_atom(living_target) || living_target.stat == DEAD)
			continue
		playsound(living_target, 'sound/magic/fireball.ogg', 20, TRUE)
		new /obj/effect/temp_visual/fire(living_target.loc)
		addtimer(CALLBACK(src, PROC_REF(pushback), living_target, user), 1) //no free backstabs, we push AFTER module stuff is done
		living_target.adjustFireLoss(bonus_value, forced = TRUE)

/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))

//bubblegum
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "A set of blood-drenched claws from a massive demon's hand. Suitable as a trophy for a kinetic crusher."
	icon_state = "demon_claws"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/demon_claws
	bonus_value = 10
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "melee hits to do <b>[bonus_value * 0.2]</b> more damage and heal you for <b>[bonus_value * 0.1]</b>, with <b>5X</b> effect on mark detonation"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.force += bonus_value * 0.2
		H.detonation_damage += bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=(20 + bonus_value * 0.2))

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.force -= bonus_value * 0.2
		H.detonation_damage -= bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=20)

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)

//colossus
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "The blaster tubes from a colossus's arm. Suitable as a trophy for a kinetic crusher."
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	var/deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage but move slower"

/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "deadly [marker.name]"
		marker.icon_state = "chronobolt"
		marker.damage = bonus_value
		marker.speed = 2
		deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 300, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

//hierophant
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	icon_state = "vortex_talisman"
	denied_type = /obj/item/crusher_trophy/vortex_talisman

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "mark detonation to create a homing hierophant chaser"

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	if(isliving(target))
		var/obj/effect/temp_visual/hierophant/chaser/chaser = new(get_turf(user), user, target, 3, TRUE)
		chaser.monster_damage_boost = FALSE // Weaker cuz no cooldown
		chaser.damage = 20
		log_combat(user, target, "fired a chaser at", src)

/obj/item/crusher_trophy/ice_demon_cube
	name = "demonic cube"
	desc = "A stone cold cube dropped from an ice demon."
	icon_state = "ice_demon_cube"
	denied_type = /obj/item/crusher_trophy/ice_demon_cube
	///how many will we summon?
	var/summon_amount = 2
	///cooldown to summon demons upon the target
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/crusher_trophy/ice_demon_cube/effect_desc()
	return "mark detonation to unleash demonic ice clones upon the target"

/obj/item/crusher_trophy/ice_demon_cube/on_mark_detonation(mob/living/target, mob/living/user)
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

//wolf trophy

/obj/item/crusher_trophy/wolf_ear
	name = "wolf ear"
	desc = "It's a wolf ear."
	icon_state = "wolf_ear"
	denied_type = /obj/item/crusher_trophy/wolf_ear

/obj/item/crusher_trophy/wolf_ear/effect_desc()
	return "mark detonation to gain a slight speed boost temporarily"

/obj/item/crusher_trophy/wolf_ear/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/speed_boost, 1 SECONDS)
