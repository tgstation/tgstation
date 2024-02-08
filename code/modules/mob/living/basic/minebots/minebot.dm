/mob/living/basic/mining_drone
	name = "\improper Nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife. Insert any type of ore into it to make it start listening to your commands!"
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
		/datum/pet_command/idle/minebot,
		/datum/pet_command/minebot_ability/light,
		/datum/pet_command/minebot_ability/dump,
		/datum/pet_command/automate_mining,
		/datum/pet_command/free/minebot,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/minebot,
	)

/mob/living/basic/mining_drone/Initialize(mapload)
	. = ..()

	var/static/list/death_drops = list(/obj/effect/decal/cleanable/robot_debris/old)
	AddElement(/datum/element/death_drops, death_drops)
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, sound_vary = TRUE)
	AddComponent(\
		/datum/component/tameable,\
		food_types = list(/obj/item/stack/ore),\
		tame_chance = 100,\
		bonus_tame_chance = 5,\
		after_tame = CALLBACK(src, PROC_REF(activate_bot)),\
	)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/minedrone/toggle_light = BB_MINEBOT_LIGHT_ABILITY,
		/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision = null,
		/datum/action/cooldown/mob_cooldown/minedrone/dump_ore = BB_MINEBOT_DUMP_ABILITY,
	)

	grant_actions_by_list(innate_actions)

	stored_gun = new(src)
	var/obj/item/implant/radio/mining/comms = new(src)
	comms.implant(src)
	access_card = new /obj/item/card/id/advanced/gold(src)
	SSid_access.apply_trim_to_card(access_card, /datum/id_trim/job/shaft_miner)

	RegisterSignal(src, COMSIG_MOB_TRIED_ACCESS, PROC_REF(attempt_access))

/mob/living/basic/mining_drone/set_combat_mode(new_mode, silent = TRUE)
	. = ..()
	icon_state = combat_mode ? "mining_drone_offense" : "mining_drone"
	balloon_alert(src, "now [combat_mode ? "attacking" : "collecting"]")

/mob/living/basic/mining_drone/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += span_warning("[p_They()] look slightly dented.")
		else
			. += span_boldwarning("[p_They()] look severely dented!")

	if(isnull(stored_gun) || !stored_gun.max_mod_capacity)
		return

	. += "<b>[stored_gun.get_remaining_mod_capacity()]%</b> mod capacity remaining."

	for(var/obj/item/borg/upgrade/modkit/modkit as anything in stored_gun.modkits)
		. += span_notice("There is \a [modkit] installed, using <b>[modkit.cost]%</b> capacity.")


/mob/living/basic/mining_drone/welder_act(mob/living/user, obj/item/welder)
	if(user.combat_mode)
		return FALSE
	if(combat_mode)
		user.balloon_alert(user, "can't repair in attack mode!")
		return TRUE
	if(maxHealth == health)
		user.balloon_alert(user, "at full integrity!")
		return TRUE
	if(welder.use_tool(src, user, 0, volume=40))
		adjustBruteLoss(-15)
		user.balloon_alert(user, "successfully repaired!")
	return TRUE

/mob/living/basic/mining_drone/attackby(obj/item/item_used, mob/user, params)
	if(item_used.tool_behaviour == TOOL_CROWBAR || istype(item_used, /obj/item/borg/upgrade/modkit))
		item_used.melee_attack_chain(user, stored_gun, params)
		return

	return ..()

/mob/living/basic/mining_drone/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.combat_mode)
		return ..()
	set_combat_mode(!combat_mode)
	balloon_alert(user, "now [combat_mode ? "attacking wildlife" : "collecting loose ore"]")

/mob/living/basic/mining_drone/RangedAttack(atom/target)
	if(!combat_mode)
		return
	stored_gun.afterattack(target, src)


/mob/living/basic/mining_drone/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag || combat_mode)
		return

	if(istype(attack_target, /obj/item/stack/ore))
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

	if(isnull(stored_gun))
		return ..()

	for(var/obj/item/borg/upgrade/modkit/modkit as anything in stored_gun.modkits)
		modkit.uninstall(stored_gun)

	return ..()

/mob/living/basic/mining_drone/Destroy()
	QDEL_NULL(stored_gun)
	QDEL_NULL(access_card)
	return ..()

