/obj/item/wallframe/fish
	name = "fish mount"
	desc = "The frame for a frame used to mount your proudest catch."
	icon_state = "fish_mount"
	result_path = /obj/structure/fish_mount
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 30
	///Reference to the persistent_id of the mount this was spawned from.
	var/persistence_id

/obj/item/wallframe/fish/after_attach(obj/structure/fish_mount/mount)
	. = ..()
	mount.find_and_hang_on_wall()
	mount.persistence_id = persistence_id

/obj/structure/fish_mount
	name = "fish mount"
	icon_state = "fish_mount"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	/// The instance of the fish mounted on this.
	var/obj/item/fish/mounted_fish
	/// The identifier for mounts that carry the trophy between rounds.
	var/persistence_id
	/// Trophies from persistence are dusted if removed to be safe.
	var/persistence_loaded_fish = FALSE
	var/catcher_name
	var/catch_date

/obj/structure/fish_mount/Initialize(mapload)
	. = ..()
	//Mounted fish shouldn't flop. It should also show size and weight to everyone.
	add_traits(list(TRAIT_STOP_FISH_FLOPPING, TRAIT_EXAMINE_FISH), INNATE_TRAIT)
	if(mapload)
		find_and_hang_on_wall()
	if(!persistence_id)
		return
	SSpersistence.load_trophy_fish(src)

/obj/structure/fish_mount/atom_deconstruct(disassembled = TRUE)
	. = ..()
	if(disassembled)
		var/obj/item/wallframe/fish/frame = new (loc)
		frame.persistence_id = persistence_id
		mounted_fish?.forceMove(loc)

/obj/structure/fish_mount/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	if(!isfish(item) || user.combat_mode)
		return ..()
	if(mounted_fish)
		balloon_alert(user, "remove other fish first!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "mounting fish...")
	if(!do_after(user, 3 SECONDS, src) || mounted_fish)
		return ITEM_INTERACT_BLOCKING
	add_fish(item)
	catcher_name = user.name
	catch_date = "[time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR]"
	balloon_alert_to_viewers("fish mounted!")
	playsound(loc, 'sound/machines/click.ogg', 30, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/fish_mount/proc/add_fish(obj/item/fish/fish, from_persistence = FALSE)
	if(mounted_fish)
		mounted_fish.forceMove(loc)
	fish.forceMove(src)
	vis_contents += fish
	fish.flags_1 |= IS_ONTOP_1
	fish.vis_flags |= VIS_INHERIT_PLANE
	mounted_fish = fish
	AddElement(/datum/element/beauty, 100 + fish.beauty * 1.5)
	RegisterSignal(fish, COMSIG_ATOM_EXAMINE, PROC_REF(on_fish_examined))
	RegisterSignal(fish, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_fish_attack_hand))
	rotate_fish(dir)
	if(from_persistence)
		persistence_loaded_fish = TRUE
		fish.remove_fillet_type()
		fish.fillet_type = null
	else if(persistence_id)
		SSpersistence.save_trophy_fish(src)

/obj/structure/fish_mount/proc/rotate_fish(direction, old_direction)
	var/rotation = SIMPLIFY_DEGREES(angle2dir(direction) - angle2dir(old_direction))
	if(!rotation)
		return
	mounted_fish.transform = mounted_fish.transform.Turn(rotation)

/obj/structure/fish_mount/setDir(newdir)
	var/old_dir = dir
	. = ..()
	rotate_fish(dir, old_dir)

/obj/structure/fish_mount/proc/on_fish_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_greentext("Caught by [catcher_name] on [catch_date].")

/obj/structure/fish_mount/proc/on_fish_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(remove_fish), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fish_mount/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!mounted_fish)
		balloon_alert(user, "no fish mounted!")
	else
		remove_fish(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fish_mount/proc/remove_fish(mob/living/user)
	balloon_alert(user, "removing fish...")
	if(!do_after(user, 3 SECONDS, src) && mounted_fish)
		return
	var/obj/item/fish/fish_reference = mounted_fish
	user.put_in_hands(mounted_fish)
	if(QDELETED(fish_reference))
		var/ash_type = /obj/effect/decal/cleanable/ash
		if(fish_reference.w_class >= WEIGHT_CLASS_BULKY)
			ash_type = /obj/effect/decal/cleanable/ash/large
		new ash_type(loc)
		visible_message("[fish_reference] turns into dust as [fish_reference.p_theyre()] removed from [src].")
	balloon_alert_to_viewers("fish removed!")

/obj/structure/fish_mount/Exited(atom/movable/gone)
	if(gone == mounted_fish)
		RemoveElement(/datum/element/beauty, 100 + mounted_fish.beauty * 1.5)
		if(persistence_loaded_fish && !QDELETED(gone))
			qdel(gone)
		else
			if(persistence_id)
				SSpersistence.trophy_fishes_database.remove(persistence_id)
			rotate_fish(0, dir)
		persistence_loaded_fish = FALSE
		UnregisterSignal(gone, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACK_HAND))
		gone.flags_1 &= ~IS_ONTOP_1
		gone.vis_flags &= ~VIS_INHERIT_PLANE
		catcher_name = null
		catch_date = null
		mounted_fish = null
	return ..()
