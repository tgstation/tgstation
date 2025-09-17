#define MAX_DISK_STACK_SIZE 10
#define STACK_PIXEL_STEP 2
#define MAX_TEXT_LENGTH 30

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
	/// Was the sticker icon already selected?
	var/sticker_changed = FALSE
	/// Custom description
	var/custom_description

/obj/item/disk/Initialize(mapload)
	. = ..()
	add_overlay("o_empty")

/obj/item/disk/examine(mob/user)
	. = ..()
	. += span_notice("The write-protect tab is set to [span_bold("[read_only ? "\"protected\"" : "\"unprotected\""]")].")

	if(custom_description)
		. += span_notice("There's something scribbled on the sticker.")
		. += span_notice(span_italics("[custom_description]"))

/obj/item/disk/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/pen))
		if(sticker_changed)
			to_chat(user, span_warning("You can't add anything else!"))
			return ITEM_INTERACT_FAILURE

		var/newdescription = sanitize_text(tgui_input_text(user, "What do you want to write?", "Floppy Disk", max_length = MAX_TEXT_LENGTH, multiline = TRUE))
		if(!newdescription)
			return ITEM_INTERACT_FAILURE

		if(!user.CanReach(src))
			return ITEM_INTERACT_FAILURE

		playsound(src, SFX_WRITING_PEN, 30)
		to_chat(user, span_notice("You sign the [src]."))

		custom_description = newdescription
		cut_overlays()
		add_overlay(pick("o_text1", "o_text2", "o_text3"))
		sticker_changed = TRUE
		unique_reskin = list()
		return ITEM_INTERACT_SUCCESS

	. = ..()

/obj/item/disk/attack_self(mob/user)
	if(read_only_locked)
		to_chat(user, span_warning("The write-portect tab seems to be stuck in place!"))
	read_only = !read_only
	to_chat(user, span_notice("You flip the write-protect tab to [read_only ? "\"protected\"" : "\"unprotected\""]."))

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
	. += span_notice("There are [span_bold("[length(stacked_disks) + 1]")] disks in the stack.")

/obj/item/disk/proc/handle_interaction(mob/living/user, obj/item/other)
  if(istype(other, /obj/item/disk_stack))
    var/obj/item/disk_stack/held_stack = other
    var/obj/item/disk_stack/new_stack = new(get_turf(src))
    new_stack.add_to_stack(user, src)

    for(var/obj/item/disk/disk_from_hand in held_stack.stacked_disks)
      if(length(new_stack.stacked_disks) >= MAX_DISK_STACK_SIZE)
        break
      disk_from_hand.forceMove(new_stack)
      new_stack.stacked_disks += disk_from_hand

    held_stack.stacked_disks.Cut()
    new_stack.update_overlays()
    qdel(held_stack)

    balloon_alert(user, "merged stacks")
    return ITEM_INTERACT_SUCCESS

  if(istype(other, /obj/item/disk))
    var/obj/item/disk_stack/new_stack = new(get_turf(src))
    new_stack.add_to_stack(user, src)
    new_stack.add_to_stack(user, other)
    balloon_alert(user, "created stack")
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
	update_overlays()
	return ITEM_INTERACT_SUCCESS

/obj/item/disk_stack/update_overlays()
	. = ..()
	var/i = 1
	overlays.Cut()
	for(var/obj/item/disk/D in stacked_disks)
		var/mutable_appearance/ma = mutable_appearance(D.icon, D.icon_state, D.layer + (0.1 * i))
		ma.pixel_y += i * STACK_PIXEL_STEP
		overlays += ma
		i++

/obj/item/disk_stack/proc/pop_top_disk(mob/living/user)
	if(!length(stacked_disks))
		return FALSE

	var/obj/item/disk/top = stacked_disks[length(stacked_disks)]
	stacked_disks.Cut(length(stacked_disks))
	balloon_alert(user, "removed top disk")
	user.put_in_hands(top)
	update_overlays()
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

	update_overlays()
	to_chat(user, span_notice("You merge two stacks of disks together."))
	qdel(diskstack)
	balloon_alert(user, "[amount_counter] merged")
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
	src.update_overlays()
	throw_at(get_step(src, pick(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)), 1, 0.8)

/obj/item/disk_stack/attack_hand_secondary(mob/user, list/modifiers)
	if(pop_top_disk(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	. = ..()

