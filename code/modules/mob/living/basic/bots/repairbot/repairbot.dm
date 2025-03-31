
/mob/living/basic/bot/repairbot
	name = "\improper Repairbot"
	desc = "I can fix it!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "repairbot1"
	base_icon_state = "repairbot"
	pass_flags = parent_type::pass_flags | PASSTABLE
	layer = BELOW_MOB_LAYER
	anchored = FALSE
	health = 100
	can_be_held = TRUE
	maxHealth = 100
	path_image_color = "#80dae7"
	bot_ui = "RepairBot"
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_ENGINEERING)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = REPAIR_BOT
	additional_access = /datum/id_trim/job/station_engineer
	ai_controller = /datum/ai_controller/basic_controller/bot/repairbot
	mob_size = MOB_SIZE_SMALL
	possessed_message = "You are a repairbot, cursed to prolong the swiss-cheesening of this death metal trap!"
	///our iron stack
	var/obj/item/stack/sheet/iron/our_iron
	///our glass stack
	var/obj/item/stack/sheet/glass/our_glass
	///our floor stack
	var/obj/item/stack/tile/our_tiles
	///our welder
	var/obj/item/weldingtool/repairbot/our_welder
	///our crowbar
	var/obj/item/crowbar/our_crowbar
	///our screwdriver
	var/obj/item/screwdriver/our_screwdriver
	///our iron rods
	var/obj/item/stack/rods/our_rods
	///our rcd object we use to deconstruct when emagged
	var/obj/item/construction/rcd/repairbot/deconstruction_device
	///possible interactions
	var/static/list/possible_stack_interactions = list(
		/obj/item/stack/sheet/iron = typecacheof(list(/obj/structure/girder)),
		/obj/item/stack/tile = typecacheof(list(/turf/open/space, /turf/open/floor/plating)),
		/obj/item/stack/sheet/glass = typecacheof(list(/obj/structure/grille)),
	)
	var/static/list/possible_tool_interactions = list(
		/obj/item/weldingtool/repairbot = typecacheof(list(/obj/structure/window)),
		/obj/item/crowbar = typecacheof(list(/obj/machinery/door, /turf/open/floor)),
	)
	///our neutral voicelines
	var/static/list/neutral_voicelines = list(
		REPAIRBOT_VOICED_BRICK = 'sound/mobs/non-humanoids/repairbot/brick.ogg',
		REPAIRBOT_VOICED_ENTROPY = 'sound/mobs/non-humanoids/repairbot/entropy.ogg',
		REPAIRBOT_VOICED_FIX_IT = 'sound/mobs/non-humanoids/repairbot/fixit.ogg',
		REPAIRBOT_VOICED_FIX_TOUCH = 'sound/mobs/non-humanoids/repairbot/fixtouch.ogg',
		REPAIRBOT_VOICED_HOLE = 'sound/mobs/non-humanoids/repairbot/patchingholes.ogg',
		REPAIRBOT_VOICED_PAY = 'sound/mobs/non-humanoids/repairbot/pay.ogg',
	)
	///our emagged voicelines
	var/static/list/emagged_voicelines = list(
		REPAIRBOT_VOICED_ENTROPY = 'sound/mobs/non-humanoids/repairbot/entropy.ogg',
		REPAIRBOT_VOICED_STRINGS = 'sound/mobs/non-humanoids/repairbot/strings.ogg',
		REPAIRBOT_VOICED_PASSION = 'sound/mobs/non-humanoids/repairbot/passionproject.ogg',
	)
	///types we can retrieve from our ui
	var/static/list/retrievable_types = list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/tile,
	)

	///our flags
	var/repairbot_flags = REPAIRBOT_FIX_BREACHES | REPAIRBOT_FIX_GIRDERS | REPAIRBOT_REPLACE_WINDOWS | REPAIRBOT_REPLACE_TILES | REPAIRBOT_BUILD_GIRDERS
	///our color
	var/toolbox_color = "#445eb3"
	///toolbox type we drop on death
	var/toolbox = /obj/item/storage/toolbox/mechanical

/mob/living/basic/bot/repairbot/Initialize(mapload)
	. = ..()
	ai_controller.set_blackboard_key(BB_REPAIRBOT_EMAGGED_SPEECH, emagged_voicelines)
	ai_controller.set_blackboard_key(BB_REPAIRBOT_NORMAL_SPEECH, neutral_voicelines)
	var/static/list/abilities = list(
		/datum/action/cooldown/mob_cooldown/bot/build_girder = BB_GIRDER_BUILD_ABILITY,
		/datum/action/repairbot_resources = null,
	)
	grant_actions_by_list(abilities)
	add_traits(list(TRAIT_SPACEWALK, TRAIT_NEGATES_GRAVITY, TRAIT_MOB_MERGE_STACKS, TRAIT_FIREDOOR_OPENER), INNATE_TRAIT)
	our_welder = new(src)
	our_welder.switched_on(src)
	our_crowbar = new(src)
	our_screwdriver = new(src)
	our_rods = new(src, our_rods::max_amount)
	set_color(toolbox_color)
	START_PROCESSING(SSobj, src)

/mob/living/basic/bot/repairbot/proc/set_color(new_color)
	toolbox_color = new_color
	update_appearance()

/mob/living/basic/bot/repairbot/attackby(obj/item/potential_stack, mob/living/carbon/human/user, list/modifiers)
	if(!istype(potential_stack, /obj/item/stack))
		return ..()
	attempt_merge(potential_stack, user)

/mob/living/basic/bot/repairbot/proc/attempt_merge(obj/item/stack/potential_stack, mob/living/user)
	var/static/list/our_contents = list(/obj/item/stack/sheet/iron, /obj/item/stack/sheet/glass, /obj/item/stack/tile, /obj/item/stack/rods)
	for(var/obj/item/stack/content as anything in our_contents)
		if(!istype(potential_stack, content))
			continue
		var/obj/item/stack/our_sheet = locate(content) in src
		if(isnull(our_sheet))
			if(!user.transferItemToLoc(potential_stack, src))
				user.balloon_alert(user, "stuck to your hand!")
				return
			balloon_alert(src, "inserted")
			return
		if(our_sheet.amount >= our_sheet.max_amount)
			user?.balloon_alert(user, "full!")
			return
		if(!our_sheet.can_merge(potential_stack))
			user?.balloon_alert(user, "not suitable!")
			return
		var/atom/movable/to_move = potential_stack.split_stack(user, min(our_sheet.max_amount - our_sheet.amount, potential_stack.amount))
		if(!user.transferItemToLoc(to_move, src))
			user.balloon_alert(user, "stuck to your hand!")
			return
		balloon_alert(src, "inserted")
		return

/mob/living/basic/bot/repairbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/stack/sheet/iron) && isnull(our_iron)) //show iron tiles and glass in our hands
		our_iron = arrived
		update_appearance()
	if(istype(arrived, /obj/item/stack/sheet/glass) && isnull(our_glass))
		our_glass = arrived
		update_appearance()
	if(istype(arrived, /obj/item/stack/tile) && isnull(our_tiles))
		our_tiles = arrived
	if(istype(arrived, /obj/item/stack/rods) && isnull(our_rods))
		our_rods = arrived

/mob/living/basic/bot/repairbot/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag)
		return

	if(bot_access_flags & BOT_COVER_EMAGGED)
		emagged_interactions(target, modifiers)
		return

	if(istype(target, /obj/item/stack))
		attempt_merge(target, src)
		return

	//priority interactions
	if(istype(target, /turf/open/space))
		var/turf/open/space/space_target = target
		if(!space_target.has_valid_support() && !(locate(/obj/structure/lattice) in space_target))
			attempt_use_stack(our_rods ? our_rods : our_rods::name, space_target)

	if(istype(target, /obj/structure/grille))
		var/obj/structure/grille/grille_target = target
		if(grille_target.broken)
			attempt_use_stack(our_rods ? our_rods : our_rods::name, grille_target)

	if(istype(target, /turf/open))
		var/turf/open/open_target = target
		if(open_target.broken || open_target.burnt)
			our_welder?.melee_attack_chain(src, open_target)

	if(istype(target, /obj/structure/window))
		var/obj/structure/window/target_window = target
		if(!target_window.anchored)
			our_screwdriver?.melee_attack_chain(src, target_window)

	//stack interactions
	for(var/obj/item/stack/stack_type as anything in possible_stack_interactions)
		if(!is_type_in_typecache(target, possible_stack_interactions[stack_type]))
			continue
		var/obj/item/target_stack = locate(stack_type) in src
		attempt_use_stack(target_stack ? target_stack : stack_type::name, target)
		return

	//tool interactions
	var/list/our_tools = list(our_welder, our_crowbar)
	for(var/obj/item/tool in our_tools)
		if(is_type_in_typecache(target, possible_tool_interactions[tool.type]) && !combat_mode)
			tool.melee_attack_chain(src, target)
			return

/mob/living/basic/bot/repairbot/proc/emagged_interactions(atom/target, modifiers)
	if(!istype(target, /mob/living/silicon/robot))
		deconstruction_device?.interact_with_atom_secondary(target, src, modifiers)
		return
	if(HAS_TRAIT(target, TRAIT_MOB_TIPPED))
		return
	var/old_combat_mode = combat_mode
	set_combat_mode(TRUE)
	target.attack_hand_secondary(src, modifiers) //tip the guy!
	set_combat_mode(old_combat_mode)

/mob/living/basic/bot/repairbot/start_pulling(atom/movable/movable_pulled, state, force, supress_message)
	. = ..()
	if(pulling)
		setGrabState(GRAB_AGGRESSIVE) //automatically aggro grab everything!

/mob/living/basic/bot/repairbot/proc/attempt_use_stack(obj/item/stack_to_use, atom/target)
	if(!isdatum(stack_to_use))
		to_chat(src, span_warning("You do not have anymore [stack_to_use]!"))
		return
	stack_to_use.melee_attack_chain(src, target)

/mob/living/basic/bot/repairbot/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 25)
	if(affect_silicon)
		return ..()

/mob/living/basic/bot/repairbot/Destroy()
	. = ..()
	QDEL_NULL(our_iron)
	QDEL_NULL(our_glass)
	QDEL_NULL(our_tiles)
	QDEL_NULL(our_welder)
	QDEL_NULL(our_screwdriver)
	QDEL_NULL(our_crowbar)
	QDEL_NULL(our_rods)
	QDEL_NULL(deconstruction_device)

/mob/living/basic/bot/repairbot/Exited(atom/movable/gone, direction)
	if(gone == our_crowbar)
		our_crowbar = null
	if(gone == our_screwdriver)
		our_screwdriver = null
	if(gone == our_welder)
		our_welder = null
	if(gone == our_tiles)
		our_tiles = null
	if(gone == our_iron)
		our_iron = null
	if(gone == our_glass)
		our_glass = null
	if(gone == our_rods)
		our_rods = null
	update_appearance()
	return ..()

/mob/living/basic/bot/repairbot/process(seconds_per_tick) //generate 1 iron rod every 2 seconds
	if(isnull(our_rods) || our_rods.amount < our_rods.max_amount)
		var/obj/item/stack/rods/new_rods = new()
		new_rods.forceMove(src)

/mob/living/basic/bot/repairbot/turn_on()
	. = ..()
	if(!.)
		return
	START_PROCESSING(SSobj, src)

/mob/living/basic/bot/repairbot/turn_off()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/mob/living/basic/bot/repairbot/update_overlays()
	. = ..()
	var/mutable_appearance/our_box = mutable_appearance(icon, "repairbot_box", BELOW_MOB_LAYER - 0.02)
	our_box.color = toolbox_color
	. += our_box
	if(our_glass)
		var/mutable_appearance/glass =  mutable_appearance(icon, "repairbot_glass_overlay", BELOW_MOB_LAYER - 0.02, appearance_flags = RESET_COLOR|KEEP_APART)
		glass.pixel_w = -6
		glass.pixel_z = -5
		. += glass
	if(our_iron)
		var/mutable_appearance/iron =  mutable_appearance(icon, "repairbot_iron_overlay", BELOW_MOB_LAYER - 0.02, appearance_flags = RESET_COLOR|KEEP_APART)
		iron.pixel_w = 7
		iron.pixel_z = -5
		. += iron

/mob/living/basic/bot/repairbot/generate_speak_list()
	return neutral_voicelines + emagged_voicelines

/mob/living/basic/bot/repairbot/Bump(atom/movable/bumped_object)
	. = ..()
	if(istype(bumped_object, /obj/machinery/door/firedoor) && bumped_object.density)
		our_crowbar.melee_attack_chain(src, bumped_object)

/mob/living/basic/bot/repairbot/ui_data(mob/user)
	var/list/data = ..()
	data["repairbot_materials"] = list()
	if((bot_access_flags & BOT_COVER_LOCKED) && !issilicon(user) && !isAdminGhostAI(user))
		return data
	data["custom_controls"]["fix_breaches"] = repairbot_flags & REPAIRBOT_FIX_BREACHES
	data["custom_controls"]["replace_windows"] = repairbot_flags & REPAIRBOT_REPLACE_WINDOWS
	data["custom_controls"]["replace_tiles"] = repairbot_flags & REPAIRBOT_REPLACE_TILES
	data["custom_controls"]["fix_girders"] = repairbot_flags & REPAIRBOT_FIX_GIRDERS
	data["custom_controls"]["build_girders"] = repairbot_flags & REPAIRBOT_BUILD_GIRDERS

	for(var/data_path in retrievable_types)
		var/atom/to_retrieve = locate(data_path) in src
		if(isnull(to_retrieve))
			continue

		data["repairbot_materials"] += list(list(
			"material_ref" = REF(to_retrieve),
			"material_icon" = to_retrieve::icon,
			"material_icon_state" = to_retrieve::icon_state,
		))

	return data

/mob/living/basic/bot/repairbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isliving(ui.user) || (bot_access_flags & BOT_COVER_LOCKED) && !(HAS_SILICON_ACCESS(ui.user)))
		return
	switch(action)
		if("fix_breaches")
			repairbot_flags ^= REPAIRBOT_FIX_BREACHES
		if("replace_windows")
			repairbot_flags ^= REPAIRBOT_REPLACE_WINDOWS
		if("replace_tiles")
			repairbot_flags ^= REPAIRBOT_REPLACE_TILES
		if("fix_girders")
			repairbot_flags ^= REPAIRBOT_FIX_GIRDERS
		if("build_girders")
			repairbot_flags ^= REPAIRBOT_BUILD_GIRDERS
		if("remove_item")
			var/item_params = params["item_reference"]
			if(isnull(item_params))
				return TRUE
			var/obj/item/retrieved = locate(item_params) in contents
			if(isnull(retrieved) || !is_type_in_list(retrieved, retrievable_types))
				return TRUE
			var/mob/living/user = ui.user
			user.put_in_hands(retrieved)
	return TRUE


/mob/living/basic/bot/repairbot/emag_effects(mob/user)
	if(isnull(deconstruction_device))
		deconstruction_device = new(src)

/mob/living/basic/bot/repairbot/explode()
	drop_part(toolbox, drop_location())
	return ..()

/obj/item/weldingtool/repairbot
	max_fuel = INFINITY
	starting_fuel = TRUE
	change_icons = FALSE

/obj/item/construction/rcd/repairbot
	matter = INFINITY
	has_ammobar = FALSE

/mob/living/basic/bot/repairbot/mob_pickup(mob/living/user)
	var/obj/item/carried_repairbot/carried = new(get_turf(src))
	carried.set_bot(src)
	if(carried.icon_state == "toolbox_default")
		carried.add_atom_colour(toolbox_color, FIXED_COLOUR_PRIORITY)
	user.visible_message(span_warning("[user] scoops up [src]!"))
	user.put_in_hands(carried)

/obj/item/carried_repairbot
	desc = "A most robust bot!"
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")
	hitsound = 'sound/items/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox/toolbox_pickup.ogg'
	///the bot we own
	var/atom/movable/our_bot

/obj/item/carried_repairbot/proc/set_bot(mob/living/basic/bot/repairbot/repairbot)
	var/obj/item/bot_toolbox = repairbot.toolbox
	name = repairbot.name
	icon = bot_toolbox::icon
	icon_state = bot_toolbox::icon_state
	lefthand_file = bot_toolbox::lefthand_file
	righthand_file = bot_toolbox::righthand_file
	inhand_icon_state = bot_toolbox::inhand_icon_state
	force = bot_toolbox::force
	repairbot.forceMove(src)

/obj/item/carried_repairbot/dropped()
	. = ..()
	if(isturf(loc))
		release_bot()

/obj/item/carried_repairbot/proc/release_bot(bypass_delete = FALSE)
	if(!isnull(our_bot))
		our_bot.forceMove(drop_location())
		our_bot.balloon_alert_to_viewers("plops down")
	if(!bypass_delete)
		qdel(src)

/obj/item/carried_repairbot/Destroy()
	. = ..()
	release_bot(bypass_delete = TRUE)

/obj/item/carried_repairbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		our_bot = arrived

/obj/item/carried_repairbot/Exited(atom/movable/gone, direction)
	if(gone == our_bot)
		our_bot = null
	return ..()
