/obj/item/grenade/c4
	name = "C-4 charge"
	desc = "Used to put holes in specific areas without too much extra hole. A saboteur's favorite."
	icon_state = "plastic-explosive0"
	inhand_icon_state = "plastic-explosive"
	worn_icon_state = "c4"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	item_flags = NOBLUDGEON
	flags_1 = NONE
	det_time = 10
	display_timer = FALSE
	w_class = WEIGHT_CLASS_SMALL
	gender = PLURAL
	/// What the charge is stuck to
	var/atom/target = null
	/// C4 overlay to put on target
	var/mutable_appearance/plastic_overlay
	/// Do we do a directional explosion when target is a a dense atom?
	var/directional = FALSE
	/// When doing a directional explosion, what arc does the explosion cover
	var/directional_arc = 120
	/// For directional charges, which cardinal direction is the charge facing?
	var/aim_dir = NORTH
	/// List of explosion radii (DEV, HEAVY, LIGHT)
	var/boom_sizes = list(0, 0, 3)
	/// Do we apply the full force of a heavy ex_act() to mob targets
	var/full_damage_on_mobs = FALSE
	/// Minimum timer for c4 charges
	var/minimum_timer = 10
	/// Maximum timer for c4 charges
	var/maximum_timer = 60000

/obj/item/grenade/c4/apply_grenade_fantasy_bonuses(quality)
	var/devIncrease = round(quality / 10)
	var/heavyIncrease = round(quality / 5)
	var/lightIncrease = round(quality / 2)
	boom_sizes[1] = modify_fantasy_variable("devIncrease", boom_sizes[1], devIncrease)
	boom_sizes[2] = modify_fantasy_variable("heavyIncrease", boom_sizes[2], heavyIncrease)
	boom_sizes[3] = modify_fantasy_variable("lightIncrease", boom_sizes[3], lightIncrease)

/obj/item/grenade/c4/remove_grenade_fantasy_bonuses(quality)
	boom_sizes[1] = reset_fantasy_variable("devIncrease", boom_sizes[1])
	boom_sizes[2] = reset_fantasy_variable("heavyIncrease", boom_sizes[2])
	boom_sizes[3] = reset_fantasy_variable("lightIncrease", boom_sizes[3])

/obj/item/grenade/c4/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)
	plastic_overlay = mutable_appearance(icon, "[inhand_icon_state]2", HIGH_OBJ_LAYER)
	set_wires(new /datum/wires/explosive/c4(src))

/obj/item/grenade/c4/Destroy()
	qdel(wires)
	set_wires(null)
	target = null
	return ..()

/obj/item/grenade/c4/screwdriver_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("The wire panel can be accessed without a screwdriver."))
	return TRUE

/obj/item/grenade/c4/attackby(obj/item/item, mob/user, params)
	if(is_wire_tool(item))
		wires.interact(user)
	else
		return ..()

/obj/item/grenade/c4/detonate(mob/living/lanced_by)
	if(QDELETED(src))
		return FALSE
	if(dud_flags)
		active = FALSE
		update_appearance()
		return FALSE

	. = ..()
	var/turf/location
	var/target_density
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target_density = target.density // We're about to blow target up, so need to save this value for later
			target.cut_overlay(plastic_overlay, TRUE)
			if(!ismob(target) || full_damage_on_mobs)
				EX_ACT(target, EXPLODE_HEAVY, target)
	else
		location = get_turf(src)
	if(location)
		if(directional && target_density)
			var/angle = dir2angle(aim_dir)
			explosion(location, devastation_range = boom_sizes[1], heavy_impact_range = boom_sizes[2], light_impact_range = boom_sizes[3], explosion_cause = src, explosion_direction = angle, explosion_arc = directional_arc)
		else
			explosion(location, devastation_range = boom_sizes[1], heavy_impact_range = boom_sizes[2], light_impact_range = boom_sizes[3], explosion_cause = src)
	qdel(src)

//assembly stuff
/obj/item/grenade/c4/receive_signal()
	detonate()

/obj/item/grenade/c4/attack_self(mob/user)
	var/newtime = tgui_input_number(user, "Please set the timer", "C4 Timer", minimum_timer, maximum_timer, minimum_timer)
	if(!newtime || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	det_time = newtime
	to_chat(user, "Timer set for [det_time] seconds.")

/obj/item/grenade/c4/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// Here lies C4 ghosts. We hardly knew ye
	if(isdead(interacting_with))
		return NONE
	aim_dir = get_dir(user, interacting_with)
	return plant_c4(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/grenade/c4/proc/plant_c4(atom/bomb_target, mob/living/user)
	if(bomb_target != user && HAS_TRAIT(user, TRAIT_PACIFISM) && isliving(bomb_target))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return FALSE

	to_chat(user, span_notice("You start planting [src]. The timer is set to [det_time]..."))

	if(!do_after(user, 3 SECONDS, target = bomb_target))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	target = bomb_target
	active = TRUE

	message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at [ADMIN_VERBOSEJMP(target)] with [det_time] second fuse")
	user.log_message("planted [name] on [target.name] with a [det_time] second fuse.", LOG_ATTACK)
	var/icon/target_icon = icon(bomb_target.icon, bomb_target.icon_state)
	target_icon.Blend(icon(icon, icon_state), ICON_OVERLAY)
	var/mutable_appearance/bomb_target_image = mutable_appearance(target_icon)
	notify_ghosts(
		"[user] has planted \a [src] on [target] with a [det_time] second fuse!",
		source = bomb_target,
		header = "Explosive Planted",
		alert_overlay = bomb_target_image,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
	)

	moveToNullspace() //Yep

	if(isitem(bomb_target)) //your crappy throwing star can't fly so good with a giant brick of c4 on it.
		var/obj/item/thrown_weapon = bomb_target
		thrown_weapon.throw_speed = max(1, (thrown_weapon.throw_speed - 3))
		thrown_weapon.throw_range = max(1, (thrown_weapon.throw_range - 3))
		if(thrown_weapon.embedding)
			thrown_weapon.embedding["embed_chance"] = 0
			thrown_weapon.updateEmbedding()
	else if(isliving(bomb_target))
		plastic_overlay.layer = FLOAT_LAYER

	target.add_overlay(plastic_overlay)
	to_chat(user, span_notice("You plant the bomb. Timer counting down from [det_time]."))
	addtimer(CALLBACK(src, PROC_REF(detonate)), det_time*10)
	return TRUE

/obj/item/grenade/c4/proc/shout_syndicate_crap(mob/player)
	if(!player)
		CRASH("[src] proc shout_syndicate_crap called without a mob to shout crap from!")

	var/final_message = "FOR NO RAISIN!!"
	if(player.mind)
		// Give our list of antag datums a shuffle and pick the first one with a suicide_cry to use as our shout.
		var/list/shuffled_antag_datums = shuffle(player.mind.antag_datums)
		for(var/datum/antagonist/found_antag as anything in shuffled_antag_datums)
			if(found_antag.suicide_cry)
				final_message = found_antag.suicide_cry
				break

	player.say(final_message, forced = "C4 suicide")

/obj/item/grenade/c4/suicide_act(mob/living/user)
	message_admins("[ADMIN_LOOKUPFLW(user)] suicided with [src] at [ADMIN_VERBOSEJMP(user)]")
	user.log_message("suicided with [src].", LOG_ATTACK)
	log_game("[key_name(user)] suicided with [src] at [AREACOORD(user)]")
	user.visible_message(span_suicide("[user] activates [src] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!"))
	shout_syndicate_crap(user)
	explosion(user, heavy_impact_range = 2, explosion_cause = src) //Cheap explosion imitation because putting detonate() here causes runtimes
	user.gib(DROP_BODYPARTS)
	qdel(src)

// X4 is an upgraded directional variant of c4 which is relatively safe to be standing next to. And much less safe to be standing on the other side of.
// C4 is intended to be used for infiltration, and destroying tech. X4 is intended to be used for heavy breaching and tight spaces.
// Intended to replace C4 for nukeops, and to be a randomdrop in surplus/random traitor purchases.

/obj/item/grenade/c4/x4
	name = "X-4 charge"
	desc = "A shaped high-explosive breaching charge. Designed to ensure user safety and wall nonsafety."
	icon_state = "plasticx40"
	inhand_icon_state = "plasticx4"
	worn_icon_state = "x4"
	directional = TRUE
	boom_sizes = list(0, 2, 5)
