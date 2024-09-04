/obj/item/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells and batteries."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	inhand_icon_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 7
	/// Multiplier that determines the speed at which this inducer works at.
	var/power_transfer_multiplier = 1
	var/opened = FALSE
	var/cell_type = /obj/item/stock_parts/power_store/battery/high
	var/obj/item/stock_parts/power_store/powerdevice
	var/recharging = FALSE

/obj/item/inducer/Initialize(mapload)
	. = ..()
	if(!powerdevice && cell_type)
		powerdevice = new cell_type

/obj/item/inducer/proc/induce(obj/item/stock_parts/power_store/target, coefficient)
	var/obj/item/stock_parts/power_store/our_cell = get_cell()
	var/rating_base = target.rating_base
	var/totransfer = min(our_cell.charge, (rating_base * coefficient * power_transfer_multiplier))
	var/transferred = target.give(totransfer)

	our_cell.use(transferred)
	our_cell.update_appearance()
	target.update_appearance()

/obj/item/inducer/get_cell()
	return powerdevice

/obj/item/inducer/emp_act(severity)
	. = ..()
	var/obj/item/stock_parts/power_store/our_cell = get_cell()
	if(!isnull(our_cell) && !(. & EMP_PROTECT_CONTENTS))
		our_cell.emp_act(severity)

/obj/item/inducer/attack_atom(obj/target, mob/living/carbon/user, params)
	if(user.combat_mode)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(target, user))
		return

	return ..()

/obj/item/inducer/proc/cantbeused(mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to use [src]!"))
		return TRUE

	var/obj/item/stock_parts/power_store/our_cell = get_cell()

	if(isnull(our_cell))
		balloon_alert(user, "no cell installed!")
		return TRUE

	if(!our_cell.charge)
		balloon_alert(user, "no charge!")
		return TRUE
	return FALSE

/obj/item/inducer/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	tool.play_tool_sound(src)
	if(!opened)
		to_chat(user, span_notice("You unscrew the battery compartment."))
		opened = TRUE
		update_appearance()
		return
	else
		to_chat(user, span_notice("You close the battery compartment."))
		opened = FALSE
		update_appearance()
		return

/obj/item/inducer/attackby(obj/item/used_item, mob/user)
	var/obj/item/stock_parts/power_store/our_cell = get_cell()
	if(istype(used_item, /obj/item/stock_parts/power_store))
		if(opened)
			if(isnull(our_cell))
				if(!user.transferItemToLoc(used_item, src))
					return
				to_chat(user, span_notice("You insert [used_item] into [src]."))
				powerdevice = used_item
				update_appearance()
				return
			else
				to_chat(user, span_warning("[src] already has \a [our_cell] installed!"))
				return

	if (istype(used_item, /obj/item/stack/sheet/mineral/plasma) && !isnull(our_cell))
		if(our_cell.charge == our_cell.maxcharge)
			balloon_alert(user, "already fully charged!")
			return
		used_item.use(1)
		our_cell.give(1.5 * STANDARD_CELL_CHARGE)
		balloon_alert(user, "cell recharged")
		return

	if(cantbeused(user))
		return

	if(recharge(used_item, user))
		return

	return ..()

/obj/item/inducer/proc/recharge(atom/movable/target, mob/user)
	if(!isturf(target) && user.loc == target)
		return FALSE
	if(recharging)
		return TRUE

	recharging = TRUE
	var/obj/item/stock_parts/power_store/our_cell = get_cell()
	var/obj/item/stock_parts/power_store/target_cell = target.get_cell()
	var/obj/target_as_object = target
	var/coefficient = 1

	if(istype(target, /obj/item/gun/energy) || istype(target, /obj/item/clothing/suit/space))
		to_chat(user, span_alert("Error: unable to interface with device."))
		return FALSE

	if(target_cell)
		var/done_any = FALSE
		if(target_cell.charge >= target_cell.maxcharge)
			balloon_alert(user, "it's fully charged!")
			recharging = FALSE
			return TRUE

		user.visible_message(span_notice("[user] starts recharging [target] with [src]."), span_notice("You start recharging [target] with [src]."))

		while(target_cell.charge < target_cell.maxcharge)
			if(do_after(user, 1 SECONDS, target = user) && our_cell.charge)
				done_any = TRUE
				induce(target_cell, coefficient)
				do_sparks(1, FALSE, target)
				if(istype(target_as_object))
					target_as_object.update_appearance()
			else
				break
		if(done_any) // Only show a message if we succeeded at least once
			user.visible_message(span_notice("[user] recharged [target]!"), span_notice("You recharged [target]!"))
		recharging = FALSE
		return TRUE
	recharging = FALSE


/obj/item/inducer/attack(mob/target, mob/living/user)
	if(user.combat_mode)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(target, user))
		return

	return ..()


/obj/item/inducer/attack_self(mob/user)
	if(opened && powerdevice)
		user.visible_message(span_notice("[user] removes [powerdevice] from [src]!"), span_notice("You remove [powerdevice]."))
		powerdevice.update_appearance()
		user.put_in_hands(powerdevice)
		powerdevice = null
		update_appearance()


/obj/item/inducer/examine(mob/living/user)
	. = ..()
	var/obj/item/stock_parts/power_store/our_cell = get_cell()
	if(!isnull(our_cell))
		. += span_notice("Its display shows: [display_energy(our_cell.charge)].")
	else
		. += span_notice("Its display is dark.")
	if(opened)
		. += span_notice("Its battery compartment is open.")

/obj/item/inducer/update_overlays()
	. = ..()
	if(!opened)
		return
	. += "inducer-[!isnull(get_cell()) ? "bat" : "nobat"]"

/obj/item/inducer/empty
	cell_type = null
	opened = TRUE

/obj/item/inducer/orderable
	cell_type = /obj/item/stock_parts/power_store/battery/upgraded
	opened = FALSE

/obj/item/inducer/sci
	icon_state = "inducer-sci"
	inhand_icon_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than its engineering counterpart."
	cell_type = null
	opened = TRUE

/obj/item/inducer/sci/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/inducer/syndicate
	icon_state = "inducer-syndi"
	inhand_icon_state = "inducer-syndi"
	desc = "A tool for inductively charging internal power cells. This one has a suspicious colour scheme, and seems to be rigged to transfer charge at a much faster rate."
	power_transfer_multiplier = 2 // 2x the base speed
	cell_type = /obj/item/stock_parts/power_store/cell/super
