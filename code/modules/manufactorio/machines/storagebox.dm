/obj/machinery/power/manufacturing/storagebox
	name = "manufacturing storage unit"
	desc = "Its basically a box. Receives resources (if anchored). Needs a machine to take stuff out of without dumping everything out."
	icon_state = "box"
	/// how much can we hold
	var/max_stuff = 16

/obj/machinery/power/manufacturing/request_resource() //returns last inserted item
	if(!length(contents - circuit))
		return
	return (contents - circuit)[length(contents - circuit)]

/obj/machinery/power/manufacturing/storagebox/receive_resource(atom/movable/receiving, atom/from, receive_dir)
	if(iscloset(receiving) && length(receiving.contents))
		return MANUFACTURING_FAIL
	if(!may_merge_in_contents(receiving) && length(contents - circuit) >= max_stuff)
		return MANUFACTURING_FAIL_FULL
	receiving.Move(src,receive_dir)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/storagebox/container_resist_act(mob/living/user)
	. = ..()
	user.Move(drop_location())

/obj/machinery/power/manufacturing/storagebox/screwdriver_act(mob/living/user, obj/item/tool)
	. = NONE
	balloon_alert(user, "disassembling...")
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_FAILURE
	atom_destruction()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/storagebox/atom_destruction(damage_flag)
	new /obj/item/stack/sheet/iron(drop_location(), 10)
	for(var/atom/movable/movable as anything in contents - circuit)
		movable.Move(drop_location())
	return ..()

/obj/machinery/power/manufacturing/storagebox/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		return
	balloon_alert(user, "dumping..")
	if(!do_after(user, 1.25 SECONDS, src))
		return
	for(var/atom/movable/movable as anything in contents - circuit)
		movable.Move(drop_location())
