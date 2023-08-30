/mob/living/basic/mining_drone
	name = "\improper Nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife."
	gender = NEUTER
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	basic_mob_flags = DEL_ON_DEATH
	status_flags = CANSTUN|CANKNOCKDOWN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	combat_mode = TRUE
	habitable_atmos  = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	attack_verb_continuous = "drills"
	attack_verb_simple = "drill"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	sentience_type = SENTIENCE_MINEBOT
	speak_emote = list("states")
	mob_biotypes = MOB_ROBOTIC
	death_message = "blows apart!"
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_on = FALSE
	combat_mode = FALSE
	ai_controller = /datum/ai_controller/basic_controller/minebot
	///the access card we use to access mining
	var/obj/item/card/id/access_card
	///the gun we use to kill
	var/obj/item/gun/energy/recharge/kinetic_accelerator/minebot/stored_gun
	///the commands our owner can give us
	var/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/minebot_ability/light,
		/datum/pet_command/minebot_ability/dump,
		/datum/pet_command/automate_mining,
		/datum/pet_command/free/minebot,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/attack/minebot,
	)

/mob/living/basic/mining_drone/Initialize(mapload)
	. = ..()

	var/static/list/death_loot = list(/obj/effect/decal/cleanable/robot_debris)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, sound_vary = TRUE)
	AddComponent(\
		/datum/component/tameable,\
		food_types = list(/obj/item/stack/ore),\
		tame_chance = 100,\
		bonus_tame_chance = 5,\
		after_tame = CALLBACK(src, PROC_REF(activate_bot)),\
	)

	var/datum/action/cooldown/mob_cooldown/minedrone/toggle_light/toggle_light_action = new(src)
	var/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision/toggle_meson_vision_action = new(src)
	var/datum/action/cooldown/mob_cooldown/minedrone/dump_ore/dump_ore_action = new(src)
	toggle_light_action.Grant(src)
	toggle_meson_vision_action.Grant(src)
	dump_ore_action.Grant(src)
	ai_controller.set_blackboard_key(BB_MINEBOT_LIGHT_ABILITY, toggle_light_action)
	ai_controller.set_blackboard_key(BB_MINEBOT_DUMP_ABILITY, dump_ore_action)

	stored_gun = new(src)
	var/obj/item/implant/radio/mining/imp = new(src)
	imp.implant(src)
	access_card = new /obj/item/card/id/advanced/gold(src)
	SSid_access.apply_trim_to_card(access_card, /datum/id_trim/job/shaft_miner)

	RegisterSignal(src, COMSIG_MOB_TRIED_ACCESS, PROC_REF(attempt_access))

/mob/living/basic/mining_drone/set_combat_mode(new_mode, silent = TRUE)
	. = ..()
	var/functioning_mode = combat_mode ? "attack" : "collect"
	icon_state = combat_mode ? "mining_drone_offense" : "mining_drone"
	to_chat(src, span_info("You are set to [functioning_mode] mode."))

/mob/living/basic/mining_drone/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += span_warning("[p_They()] look slightly dented.")
		else
			. += span_boldwarning("[p_They()] look severely dented!")

	if(!stored_gun?.max_mod_capacity)
		return

	. += "<b>[stored_gun.get_remaining_mod_capacity()]%</b> mod capacity remaining."

	for(var/obj/item/borg/upgrade/modkit/modkit as anything in stored_gun.modkits)
		. += span_notice("There is \a [modkit] installed, using <b>[modkit.cost]%</b> capacity.")


/mob/living/basic/mining_drone/welder_act(mob/living/user, obj/item/welder)
	if(user.combat_mode)
		return
	. = TRUE
	if(combat_mode)
		user.balloon_alert(user, "")
		to_chat(user, span_warning("[src] can't be repaired while in attack mode!"))
		return
	if(maxHealth == health)
		to_chat(user, span_info("[src] is at full integrity."))
		return
	if(welder.use_tool(src, user, 0, volume=40))
		adjustBruteLoss(-15)
		to_chat(user, span_info("You repair some of the armor on [src]."))

/mob/living/basic/mining_drone/attackby(obj/item/item_used, mob/user, params)
	if(item_used.tool_behaviour == TOOL_CROWBAR || istype(item_used, /obj/item/borg/upgrade/modkit))
		item_used.melee_attack_chain(user, stored_gun, params)
		return

	return ..()

/mob/living/basic/mining_drone/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()

	if(. || user.combat_mode)
		return
	set_combat_mode(!combat_mode)
	if(combat_mode)
		to_chat(user, span_info("[src] has been set to search and store loose ore."))
		return
	to_chat(user, span_info("[src] has been set to attack hostile wildlife."))

/mob/living/basic/mining_drone/RangedAttack(atom/target)
	if(!combat_mode)
		return
	stored_gun.afterattack(target, src)


/mob/living/basic/mining_drone/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag)
		return

	if(istype(attack_target, /obj/item/stack/ore) && !combat_mode)
		var/obj/item/target_ore = attack_target
		target_ore.forceMove(src)

/mob/living/basic/mining_drone/proc/drop_ore()
	to_chat(src, span_notice("You dump your stored ore."))
	for(var/obj/item/stack/ore/dropped_item in contents)
		dropped_item.forceMove(get_turf(src))

/mob/living/basic/mining_drone/proc/attempt_access(mob/drone, obj/door_attempt)
	SIGNAL_HANDLER

	if(door_attempt.check_access(access_card))
		return ACCESS_ALLOWED
	return ACCESS_DISALLOWED

/mob/living/basic/mining_drone/proc/activate_bot()
	AddComponent(/datum/component/obeys_commands, pet_commands)

/mob/living/basic/mining_drone/death(gibbed)
	drop_ore()

	if(!stored_gun)
		return ..()

	for(var/obj/item/borg/upgrade/modkit/modkit as anything in stored_gun.modkits)
		modkit.uninstall(stored_gun)

	return ..()

/mob/living/basic/mining_drone/Destroy()
	QDEL_NULL(stored_gun)
	QDEL_NULL(access_card)
	return ..()

/**********************Minebot Upgrades**********************/

//Melee

/obj/item/mine_bot_upgrade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/assemblies/module.dmi'

/obj/item/mine_bot_upgrade/afterattack(mob/living/basic/mining_drone/minebot, mob/user, proximity)
	. = ..()
	if(!istype(minebot) || !proximity)
		return
	upgrade_bot(minebot, user)

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/basic/mining_drone/minebot, mob/user)
	if(minebot.melee_damage_upper != initial(minebot.melee_damage_upper))
		to_chat(user, span_warning("[minebot] already has a combat upgrade installed!"))
		return
	minebot.melee_damage_lower += 7
	minebot.melee_damage_upper += 7
	to_chat(user, "<span class='notice'>You increase the close-quarter combat abilities of [minebot].")
	qdel(src)

//Health

/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/basic/mining_drone/minebot, mob/user)
	if(minebot.maxHealth != initial(minebot.maxHealth))
		to_chat(user, span_warning("[minebot] already has reinforced armor!"))
		return
	minebot.maxHealth += 45
	minebot.updatehealth()
	to_chat(user, "<span class='notice'>You reinforce the armor of [minebot].")
	qdel(src)

//AI

/obj/item/slimepotion/slime/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots. It's incompatible with minebot armor and melee upgrades, and will override them."
	icon_state = "door_electronics"
	icon = 'icons/obj/assemblies/module.dmi'
	sentience_type = SENTIENCE_MINEBOT
	///health boost to add
	var/base_health_add = 5
	///damage boost to add
	var/base_damage_add = 1
	///speed boost to add
	var/base_speed_add = 1
	///cooldown boost to add
	var/base_cooldown_add = 10

/obj/item/slimepotion/slime/sentience/mining/after_success(mob/living/user, mob/living/basic/basic_mob)
	if(!istype(basic_mob, /mob/living/basic/mining_drone))
		return
	var/mob/living/basic/mining_drone/minebot = basic_mob
	minebot.maxHealth = initial(minebot.maxHealth) + base_health_add
	minebot.melee_damage_lower = initial(minebot.melee_damage_lower) + base_damage_add
	minebot.melee_damage_upper = initial(minebot.melee_damage_upper) + base_damage_add
	minebot.stored_gun?.recharge_time += base_cooldown_add
