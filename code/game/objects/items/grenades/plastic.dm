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
	var/atom/target = null
	var/mutable_appearance/plastic_overlay
	var/directional = FALSE
	var/aim_dir = NORTH
	var/boom_sizes = list(0, 0, 3)
	var/full_damage_on_mobs = FALSE

/obj/item/grenade/c4/Initialize(mapload)
	. = ..()
	plastic_overlay = mutable_appearance(icon, "[inhand_icon_state]2", HIGH_OBJ_LAYER)
	wires = new /datum/wires/explosive/c4(src)

/obj/item/grenade/c4/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)

/obj/item/grenade/c4/Destroy()
	qdel(wires)
	wires = null
	target = null
	return ..()

/obj/item/grenade/c4/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, span_notice("The wire panel can be accessed without a screwdriver."))
	else if(is_wire_tool(item))
		wires.interact(user)
	else
		return ..()

/obj/item/grenade/c4/detonate(mob/living/lanced_by)
	if(QDELETED(src))
		return

	. = ..()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target.cut_overlay(plastic_overlay, TRUE)
			if(!ismob(target) || full_damage_on_mobs)
				target.ex_act(EXPLODE_HEAVY, target)
	else
		location = get_turf(src)
	if(location)
		if(directional && target?.density)
			var/turf/turf = get_step(location, aim_dir)
			explosion(get_step(turf, aim_dir), devastation_range = boom_sizes[1], heavy_impact_range = boom_sizes[2], light_impact_range = boom_sizes[3], explosion_cause = src)
		else
			explosion(location, devastation_range = boom_sizes[1], heavy_impact_range = boom_sizes[2], light_impact_range = boom_sizes[3], explosion_cause = src)
	qdel(src)

//assembly stuff
/obj/item/grenade/c4/receive_signal()
	detonate()

/obj/item/grenade/c4/attack_self(mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num|null

	if (isnull(newtime))
		return

	if(user.get_active_held_item() == src)
		newtime = clamp(newtime, 10, 60000)
		det_time = newtime
		to_chat(user, "Timer set for [det_time] seconds.")

/obj/item/grenade/c4/afterattack(atom/movable/bomb_target, mob/user, flag)
	. = ..()
	aim_dir = get_dir(user, bomb_target)
	if(!flag)
		return
	if(bomb_target != user && HAS_TRAIT(user, TRAIT_PACIFISM) && isliving(bomb_target))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return

	to_chat(user, span_notice("You start planting [src]. The timer is set to [det_time]..."))

	if(do_after(user, 30, target = bomb_target))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		target = bomb_target

		message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at [ADMIN_VERBOSEJMP(target)] with [det_time] second fuse")
		log_game("[key_name(user)] planted [name] on [target.name] at [AREACOORD(user)] with a [det_time] second fuse")

		notify_ghosts("[user] has planted \a [src] on [target] with a [det_time] second fuse!", source = target, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Explosive Planted")

		moveToNullspace() //Yep

		if(istype(bomb_target, /obj/item)) //your crappy throwing star can't fly so good with a giant brick of c4 on it.
			var/obj/item/thrown_weapon = bomb_target
			thrown_weapon.throw_speed = max(1, (thrown_weapon.throw_speed - 3))
			thrown_weapon.throw_range = max(1, (thrown_weapon.throw_range - 3))
			if(thrown_weapon.embedding)
				thrown_weapon.embedding["embed_chance"] = 0
				thrown_weapon.updateEmbedding()
		else if(istype(bomb_target, /mob/living))
			plastic_overlay.layer = FLOAT_LAYER

		target.add_overlay(plastic_overlay)
		to_chat(user, span_notice("You plant the bomb. Timer counting down from [det_time]."))
		addtimer(CALLBACK(src, .proc/detonate), det_time*10)

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
	log_game("[key_name(user)] suicided with [src] at [AREACOORD(user)]")
	user.visible_message(span_suicide("[user] activates [src] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!"))
	shout_syndicate_crap(user)
	explosion(user, heavy_impact_range = 2, explosion_cause = src) //Cheap explosion imitation because putting detonate() here causes runtimes
	user.gib(1, 1)
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
