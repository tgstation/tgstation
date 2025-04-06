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
	habitable_atmos = null
	minimum_survivable_temperature = 0
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	attack_verb_continuous = "drills"
	attack_verb_simple = "drill"
	attack_sound = 'sound/items/weapons/circsawhit.ogg'
	sentience_type = SENTIENCE_MINEBOT
	speak_emote = list("states")
	mob_biotypes = MOB_ROBOTIC
	death_message = "blows apart!"
	light_system = OVERLAY_LIGHT
	light_range = 6
	// I want this to be a bit more dim, for vibes
	light_power = 0.6
	light_color = "#ff9933"
	light_on = FALSE
	combat_mode = FALSE
	ai_controller = /datum/ai_controller/basic_controller/minebot
	///the gun we use to kill
	var/obj/item/gun/energy/recharge/kinetic_accelerator/minebot/stored_gun
	///our normal overlay
	var/mutable_appearance/neutral_overlay
	///our combat mode overlay
	var/mutable_appearance/combat_overlay
	///our current color, if any
	var/selected_color
	///the commands our owner can give us
	var/static/list/pet_commands = list(
		/datum/pet_command/idle/minebot,
		/datum/pet_command/move,
		/datum/pet_command/protect_owner/minebot,
		/datum/pet_command/minebot_ability/light,
		/datum/pet_command/minebot_ability/dump,
		/datum/pet_command/automate_mining,
		/datum/pet_command/free/minebot,
		/datum/pet_command/follow,
		/datum/pet_command/attack/minebot,
	)
	///possible colors the bot can have
	var/static/list/possible_colors= list(
		"Default" = null, //default color state
		"Blue" = "#70d5e7",
		"Red" = "#ee7fb9",
		"Green" = "#5fea94",
	)

/mob/living/basic/mining_drone/Initialize(mapload)
	. = ..()
	neutral_overlay = mutable_appearance(icon = 'icons/mob/silicon/aibots.dmi', icon_state = "mining_drone_grey")
	combat_overlay = mutable_appearance(icon = 'icons/mob/silicon/aibots.dmi', icon_state = "mining_drone_offense_grey")
	AddComponent(/datum/component/obeys_commands, pet_commands)
	var/static/list/death_drops = list(/obj/effect/decal/cleanable/robot_debris/old)
	AddElement(/datum/element/death_drops, death_drops)
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, sound_vary = TRUE)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/missile_launcher = BB_MINEBOT_MISSILE_ABILITY,
		/datum/action/cooldown/mob_cooldown/drop_landmine = BB_MINEBOT_LANDMINE_ABILITY,
		/datum/action/cooldown/mob_cooldown/minedrone/toggle_light = BB_MINEBOT_LIGHT_ABILITY,
		/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision = null,
		/datum/action/cooldown/mob_cooldown/minedrone/dump_ore = BB_MINEBOT_DUMP_ABILITY,
	)

	grant_actions_by_list(innate_actions)

	stored_gun = new(src)
	var/obj/item/implant/radio/mining/comms = new(src)
	comms.implant(src)
	var/static/list/accesses = list(
		/datum/id_trim/job/shaft_miner,
	)
	AddElement(/datum/element/mob_access, accesses)

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
	if(ai_controller && ai_controller.ai_status == AI_STATUS_IDLE)
		. += "The [src] appears to be in <b>sleep mode</b>. You can restore normal functions by <b>tapping</b> it."


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
	if(!user.combat_mode)
		if(ai_controller && ai_controller.ai_status == AI_STATUS_IDLE)
			ai_controller.set_ai_status(AI_STATUS_ON)
		if(LAZYACCESS(modifiers, LEFT_CLICK)) //Lets Right Click be specifically for re-enabling their AI (and avoiding the UI popup), while Left Click simply does both.
			ui_interact(user)
		return
	return ..()

/mob/living/basic/mining_drone/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MineBot", name)
		ui.open()

/mob/living/basic/mining_drone/ui_data(mob/user)
	var/list/data = list()
	data["auto_defend"] = ai_controller.blackboard[BB_MINEBOT_AUTO_DEFEND]
	data["repair_node_drone"] = ai_controller.blackboard[BB_MINEBOT_REPAIR_DRONE]
	data["plant_mines"] = ai_controller.blackboard[BB_MINEBOT_PLANT_MINES]
	data["bot_maintain_distance"] = ai_controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE]
	data["bot_name"] = name
	data["bot_mode"] = combat_mode
	data["bot_health"] = health
	data["bot_maxhealth"] = maxHealth
	data["bot_color"] = ""
	var/color_value = neutral_overlay.color
	for(var/index in possible_colors)
		if(possible_colors[index] == color_value)
			data["bot_color"] = index
			break
	return data

/mob/living/basic/mining_drone/ui_static_data(mob/user)
	var/list/data = list()
	data["bot_icon"] = icon2base64(getFlatIcon(src))
	data["possible_colors"] = list()
	for(var/color in possible_colors)
		data["possible_colors"] += list(list(
			"color_name" = color,
			"color_value" = possible_colors[color],
		))
	return data

/mob/living/basic/mining_drone/ui_act(action, params, datum/tgui/ui)
	. = ..()
	switch(action)
		if("change_min_distance")
			var/new_distance = clamp(params["distance"], 0, 5)
			ai_controller.set_blackboard_key(BB_MINIMUM_SHOOTING_DISTANCE, new_distance)
		if("toggle_defend")
			var/new_toggle = !ai_controller.blackboard[BB_MINEBOT_AUTO_DEFEND]
			ai_controller.set_blackboard_key(BB_MINEBOT_AUTO_DEFEND, new_toggle)
		if("toggle_repair")
			var/new_defend = !ai_controller.blackboard[BB_MINEBOT_REPAIR_DRONE]
			ai_controller.set_blackboard_key(BB_MINEBOT_REPAIR_DRONE, new_defend)
		if("toggle_mines")
			var/new_mines = !ai_controller.blackboard[BB_MINEBOT_PLANT_MINES]
			ai_controller.set_blackboard_key(BB_MINEBOT_PLANT_MINES, new_mines)
		if("set_name")
			var/input_name = sanitize_name(params["chosen_name"], allow_numbers = TRUE)
			name = (input_name ? input_name : initial(name))
		if("toggle_mode")
			set_combat_mode(!combat_mode)
		if("set_color")
			change_color(params["chosen_color"])
			update_static_data(ui.user, ui)
	return TRUE

/mob/living/basic/mining_drone/proc/change_color(new_color)
	selected_color = new_color
	if(!isnull(selected_color))
		neutral_overlay.color = selected_color
		combat_overlay.color = selected_color
	update_appearance()

/mob/living/basic/mining_drone/click_alt(mob/living/user)
	if(user.combat_mode)
		return CLICK_ACTION_BLOCKING
	set_combat_mode(!combat_mode)
	balloon_alert(user, "now [combat_mode ? "attacking wildlife" : "collecting loose ore"]")
	return CLICK_ACTION_SUCCESS

/mob/living/basic/mining_drone/RangedAttack(atom/target, list/modifiers)
	if(!combat_mode)
		return
	stored_gun.try_fire_gun(target, src, list2params(modifiers))

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

/mob/living/basic/mining_drone/death(gibbed)
	drop_ore()

	if(isnull(stored_gun))
		return ..()

	for(var/obj/item/borg/upgrade/modkit/modkit as anything in stored_gun.modkits)
		modkit.uninstall(stored_gun)

	return ..()

/mob/living/basic/mining_drone/Destroy()
	QDEL_NULL(stored_gun)
	return ..()

/mob/living/basic/mining_drone/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(target, /mob/living/basic/node_drone))
		return TRUE
	repair_node_drone(target)
	return FALSE

/mob/living/basic/mining_drone/proc/repair_node_drone(mob/living/my_target)
	do_sparks(5, FALSE, source = my_target)
	if(!do_after(src, 6 SECONDS, my_target))
		return
	my_target.heal_overall_damage(brute = 50)

/mob/living/basic/mining_drone/update_overlays()
	. = ..()
	if(stat == DEAD || isnull(selected_color))
		return

	. += combat_mode ? combat_overlay : neutral_overlay
