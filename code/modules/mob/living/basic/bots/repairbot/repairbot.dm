
/mob/living/basic/bot/repairbot
	name = "\improper Repairbot"
	desc = "I can fix it!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "floorbot0"
	base_icon_state = "floorbot"
	pass_flags = parent_type::pass_flags | PASSTABLE
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100
	path_image_color = "#80dae7"
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_ENGINEERING)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FLOOR_BOT
//	additional_access = /datum/id_trim/job/engineer
//	ai_controller = /datum/ai_controller/basic_controller/bot/repairbot
	///our iron stack
	var/obj/item/stack/sheet/iron/our_iron
	///our glass stack
	var/obj/item/stack/sheet/glass/our_glass
	///our floor stack
	var/obj/item/stack/tile/our_tiles
	///our welder
	var/obj/item/weldingtool/repairbot/our_welder
	///possible interactions
	var/static/list/possible_stack_interactions = list(
		/obj/item/stack/sheet/iron = typecacheof(list(/obj/structure/girder)),
		/obj/item/stack/tile = typecacheof(list(/turf/open/space, /turf/open/floor/plating)),
		/obj/item/stack/sheet/glass = typecacheof(list(/obj/structure/grille)),
	)
	var/static/list/possible_welding_interactions = typecacheof(list(
		/obj/machinery,
		/obj/structure/window,
	))

/mob/living/basic/bot/repairbot/Initialize(mapload)
	. = ..()
	our_welder = new(src)
	our_welder.switched_on(src)

/mob/living/basic/bot/repairbot/attackby(obj/item/stack/potential_stack, mob/living/carbon/human/user, list/modifiers)
	var/static/list/our_contents = list(/obj/item/stack/sheet/iron, /obj/item/stack/sheet/glass, /obj/item/stack/tile)
	for(var/obj/item/stack/content as anything in our_contents)
		if(!istype(potential_stack, content))
			continue
		var/obj/item/stack/our_sheet = locate(content) in src
		if(isnull(our_sheet))
			potential_stack.forceMove(src)
			return
		if(our_sheet.amount >= our_sheet.max_amount)
			user.balloon_alert(user, "full!")
			return
		if(!our_sheet.can_merge(potential_stack))
			return
		var/atom/movable/to_move = potential_stack.split_stack(user, our_sheet.max_amount - our_sheet.amount)
		to_move.forceMove(src)
		return
	return ..()

/mob/living/basic/bot/repairbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/stack/sheet/iron) && isnull(our_iron))
		our_iron = arrived
		return
	if(istype(arrived, /obj/item/stack/sheet/glass) && isnull(our_glass))
		our_glass = arrived
		return
	if(istype(arrived, /obj/item/stack/tile) && isnull(our_tiles))
		our_tiles = arrived

/mob/living/basic/bot/repairbot/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag)
		return

	if(is_type_in_typecache(target, possible_welding_interactions))
		our_welder.melee_attack_chain(src, target)
		return

	for(var/type in possible_stack_interactions)
		var/obj/item/target_stack = locate(type) in src
		if(isnull(target_stack))
			continue
		if(!is_type_in_typecache(target, possible_stack_interactions[type]))
			continue
		target_stack.melee_attack_chain(src, target)
		return

/obj/item/weldingtool/repairbot
	max_fuel = INFINITY
	starting_fuel = TRUE
