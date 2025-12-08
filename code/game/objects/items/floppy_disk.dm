#define MAX_DISK_STACK_SIZE 10
#define STACK_PIXEL_STEP 2
#define MAX_TEXT_LENGTH 30
#define STARTING_STICKER "o_empty"

/obj/item/disk
	name = "floppy disk"
	desc = "A generic floppy disk. No way Nanotrasen still uses those, right?"
	icon = 'icons/obj/devices/floppy_disks.dmi'
	icon_state = "datadisk3"
	w_class = WEIGHT_CLASS_TINY
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	unique_reskin = list(
		"Red" = "datadisk0",
		"Dark Blue" = "datadisk1",
		"Yellow" = "datadisk2",
		"Black" = "datadisk3",
		"Green" = "datadisk4",
		"Purple" = "datadisk5",
		"Grey" = "datadisk6",
		"Light Blue" = "datadisk7",
	)

	/// Sticker icons to choose from (as icon states)
	var/list/icon_variants = list(
		"One" = "o_one",
		"Two" = "o_two",
		"Three" = "o_three",
		"Four" = "o_four",
		"Five" = "o_five",
		"Six" = "o_six",
		"Seven" = "o_seven",
		"Eight" = "o_eight",
		"Nine" = "o_nine",
		"Zero" = "o_zero",
		"A" = "o_A",
		"B" = "o_B",
		"C" = "o_C",
		"D" = "o_D",
		"E" = "o_E",
		"F" = "o_F",
		"Code" = "o_code",
		"DNA — Green" = "o_dna1",
		"DNA — Red" = "o_dna2",
		"Medical" = "o_medical",
		"Holographic" = "o_holo",
		)

	/// Toggles the readonly state
	var/read_only = FALSE
	/// If readonly state can be toggled on and off
	var/read_only_locked = FALSE
	/// The current sticker icon state to display
	var/sticker_icon_state = STARTING_STICKER
	/// Custom description
	var/custom_description

/obj/item/disk/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/disk/update_overlays()
	. = ..()
	if(sticker_icon_state)
		. += sticker_icon_state

/obj/item/disk/examine(mob/user)
	. = ..()
	. += span_notice("The write-protect tab is set to [span_bold("[read_only ? "protected" : "unprotected"]")].")

	if(custom_description)
		. += span_notice("There's something scribbled on the sticker:")
		. += span_notice(span_italics("\"[custom_description]\""))

/obj/item/disk/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/pen))
		if(sticker_icon_state != STARTING_STICKER)
			to_chat(user, span_warning("You can't add anything else!"))
			return ITEM_INTERACT_FAILURE

		var/newdescription = sanitize_text(tgui_input_text(user, "What do you want to write?", "Floppy Disk", max_length = MAX_TEXT_LENGTH, multiline = TRUE))
		if(!newdescription)
			return ITEM_INTERACT_FAILURE

		playsound(src, SFX_WRITING_PEN, 30)
		to_chat(user, span_notice("You sign the [src]."))

		custom_description = newdescription
		set_sticker_icon_state(pick("o_text1", "o_text2", "o_text3"))
		unique_reskin = list()
		return ITEM_INTERACT_SUCCESS

	. = ..()

/obj/item/disk/attack_self(mob/user)
	if(read_only_locked)
		to_chat(user, span_warning("The write-protect tab seems to be stuck in place!"))
		return
	read_only = !read_only
	to_chat(user, span_notice("You flip the write-protect tab to [span_bold("[read_only ? "protected" : "unprotected"]")]."))

/obj/item/disk/click_alt(mob/user)
	if(sticker_icon_state != STARTING_STICKER)
		return CLICK_ACTION_BLOCKING

	if(!LAZYLEN(icon_variants))
		return CLICK_ACTION_BLOCKING

	var/list/items = list()
	for(var/variant_name in icon_variants)
		var/icon_state_name = icon_variants[variant_name]
		var/image/item_image = image(icon = icon, icon_state = icon_state)

		var/image/overlay_preview = image(icon = icon, icon_state = icon_state_name)
		item_image.overlays += overlay_preview
		items += list("[variant_name]" = item_image)

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_sticker_menu), user), radius = 38, require_near = TRUE)
	if(!pick)
		return CLICK_ACTION_BLOCKING
	if(!icon_variants[pick])
		return CLICK_ACTION_BLOCKING

	set_sticker_icon_state(icon_variants[pick])
	to_chat(user, span_notice("You change the sticker on [src] to '[pick]'."))
	return CLICK_ACTION_SUCCESS

/// Can we select a new sticker?
/obj/item/disk/proc/check_sticker_menu(mob/user)
	if(QDELETED(src))
		return FALSE
	if(sticker_icon_state != STARTING_STICKER)
		return FALSE
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

/// Sets the sticker icon state and updates the appearance
/obj/item/disk/proc/set_sticker_icon_state(new_icon_state)
	sticker_icon_state = new_icon_state
	update_appearance(UPDATE_OVERLAYS)

/obj/item/disk_stack
	name = "stack of floppy disks"
	desc = "A stack of floppy disks. You wonder what happens if you pull out the bottom one..."
	icon = null
	icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	var/list/stacked_disks = list()

/obj/item/disk_stack/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(spread))

/obj/item/disk_stack/examine(mob/user)
	. = ..()
	. += span_notice("There are [span_bold("[length(stacked_disks)]")] disks in the stack.")

/obj/item/disk/proc/handle_interaction(mob/living/user, obj/item/other)
	if(istype(other, /obj/item/disk_stack))
		var/obj/item/disk_stack/held_stack = other
		var/obj/item/disk_stack/new_stack = new(get_turf(src))
		var/was_in_hand = user.is_holding(src) || user.is_holding(held_stack)
		new_stack.add_to_stack(user, src)

		for(var/obj/item/disk/disk_from_hand in held_stack.stacked_disks)
			if(length(new_stack.stacked_disks) >= MAX_DISK_STACK_SIZE)
				break

			disk_from_hand.forceMove(new_stack)
			new_stack.stacked_disks += disk_from_hand

		held_stack.stacked_disks.Cut()
		new_stack.update_appearance(UPDATE_OVERLAYS)
		if(was_in_hand)
			user.put_in_hands(new_stack)
		QDEL_IN(held_stack, 0)

		balloon_alert(user, "merged stacks")
		return ITEM_INTERACT_SUCCESS

	if(istype(other, /obj/item/disk))
		var/obj/item/disk_stack/new_stack = new(get_turf(src))
		new_stack.pixel_x = pixel_x
		new_stack.pixel_y = pixel_y

		var/was_in_hand = user.is_holding(src)
		new_stack.add_to_stack(user, src)
		new_stack.add_to_stack(user, other)
		new_stack.update_appearance(UPDATE_OVERLAYS)
		if(was_in_hand || user.is_holding(other))
			user.put_in_hands(new_stack)
		return ITEM_INTERACT_SUCCESS


/obj/item/disk_stack/proc/handle_interaction(mob/living/user, obj/item/other)
	if(istype(other, /obj/item/disk_stack))
		return merge_stacks(user, other)

	if(istype(other, /obj/item/disk))
		return add_to_stack(user, other)

/obj/item/disk/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return handle_interaction(user, tool)

/obj/item/disk_stack/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return handle_interaction(user, tool)

/obj/item/disk_stack/proc/add_to_stack(mob/living/user, obj/item/disk/newdisk)
	if(length(stacked_disks) + 1 > MAX_DISK_STACK_SIZE)
		balloon_alert(user, "can't add more!")
		return ITEM_INTERACT_BLOCKING

	newdisk.forceMove(src)
	stacked_disks += newdisk
	balloon_alert(user, "added to top")
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/obj/item/disk_stack/update_overlays()
	. = ..()
	var/iteration_count = 1
	for(var/obj/item/disk/disk_in_stack in stacked_disks)
		var/mutable_appearance/stacked_disk_appearance = mutable_appearance(disk_in_stack.icon, disk_in_stack.icon_state, disk_in_stack.layer + (0.1 * iteration_count))
		stacked_disk_appearance.pixel_z += iteration_count * STACK_PIXEL_STEP

		if(LAZYLEN(disk_in_stack.overlays))
			stacked_disk_appearance.overlays = disk_in_stack.overlays.Copy()
		. += stacked_disk_appearance
		iteration_count++

/obj/item/disk_stack/proc/pop_top_disk(mob/living/user)
	if(!length(stacked_disks))
		return FALSE

	var/obj/item/disk/top = stacked_disks[length(stacked_disks)]
	stacked_disks.Cut(length(stacked_disks))

	balloon_alert(user, "removed top disk")
	user.put_in_hands(top)

	if(length(stacked_disks) == 1)
		var/obj/item/disk/last_disk = stacked_disks[1]
		var/was_in_hand = user.is_holding(src)
		stacked_disks.Cut()
		if(was_in_hand)
			last_disk.forceMove(user)
			user.put_in_hands(last_disk)
		else
			var/turf/T = get_turf(src)
			last_disk.forceMove(T)
			last_disk.pixel_x = pixel_x
			last_disk.pixel_y = pixel_y

		QDEL_IN(src, 0)
		return TRUE

	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/disk_stack/proc/merge_stacks(mob/user, obj/item/disk_stack/diskstack)
	var/amount_counter = 0

	for(var/obj/item/disk/each_disk as anything in diskstack.stacked_disks)
		if(length(stacked_disks) + 1 > MAX_DISK_STACK_SIZE)
			break

		each_disk.forceMove(src)
		stacked_disks += each_disk
		diskstack.stacked_disks.Remove(each_disk)
		amount_counter += 1

	diskstack.update_overlays()

	if(!amount_counter)
		balloon_alert(user, "no space!")
		return ITEM_INTERACT_BLOCKING

	update_appearance(UPDATE_OVERLAYS)
	to_chat(user, span_notice("You merge two stacks of disks together."))

	if(!length(diskstack.stacked_disks))
		QDEL_IN(diskstack, 0)

	else if(length(diskstack.stacked_disks) == 1)
		var/obj/item/disk/last_disk = diskstack.stacked_disks[1]
		var/turf/T = get_turf(diskstack)
		last_disk.forceMove(T)
		diskstack.stacked_disks.Cut()
		QDEL_IN(diskstack, 0)

	return ITEM_INTERACT_SUCCESS

/obj/item/disk_stack/proc/spread()
	SIGNAL_HANDLER

	if(!length(stacked_disks))
		return

	var/turf/landing = get_turf(src)
	for(var/obj/item/disk/each_disk as anything in stacked_disks)
		stacked_disks.Remove(each_disk)
		each_disk.forceMove(landing)
		each_disk.throw_at(get_step(src, pick(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)), 1, 0.8)

	visible_message(span_warning("The stack falls apart!"))
	update_appearance(UPDATE_OVERLAYS)
	throw_at(get_step(src, pick(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)), 1, 0.8)

/obj/item/disk_stack/attack_hand_secondary(mob/user, list/modifiers)
	if(pop_top_disk(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	. = ..()

/obj/item/disk/can_be_package_wrapped()
	return TRUE

/obj/item/disk_stack/can_be_package_wrapped()
	return FALSE

/obj/item/delivery/small/floppy
	name = "flat parcel"
	desc = "A flat paper parcel."
	icon_state = "deliveryfloppy"
	base_icon_state = "deliveryfloppy"

/obj/item/delivery/small/floppy/Initialize(mapload)
	. = ..()
	new /obj/item/disk/data(src)

#undef MAX_DISK_STACK_SIZE
#undef STACK_PIXEL_STEP
#undef MAX_TEXT_LENGTH
