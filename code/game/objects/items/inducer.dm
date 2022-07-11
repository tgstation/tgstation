/obj/item/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	inhand_icon_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 7
	var/powertransfer = 1000
	var/opened = FALSE
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/recharging = FALSE

/obj/item/inducer/Initialize(mapload)
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target, coefficient)
	var/totransfer = min(cell.charge,(powertransfer * coefficient))
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	cell.update_appearance()
	target.update_appearance()

/obj/item/inducer/get_cell()
	return cell

/obj/item/inducer/emp_act(severity)
	. = ..()
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		cell.emp_act(severity)

/obj/item/inducer/attack_atom(obj/O, mob/living/carbon/user, params)
	if(user.combat_mode)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(O, user))
		return

	return ..()

/obj/item/inducer/proc/cantbeused(mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to use [src]!"))
		return TRUE

	if(!cell)
		balloon_alert(user, "no cell installed!")
		return TRUE

	if(!cell.charge)
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

/obj/item/inducer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You insert [W] into [src]."))
				cell = W
				update_appearance()
				return
			else
				to_chat(user, span_warning("[src] already has \a [cell] installed!"))
				return

	if(cantbeused(user))
		return

	if(recharge(W, user))
		return

	return ..()

/obj/item/inducer/proc/recharge(atom/movable/A, mob/user)
	if(!isturf(A) && user.loc == A)
		return FALSE
	if(recharging)
		return TRUE
	else
		recharging = TRUE
	var/obj/item/stock_parts/cell/C = A.get_cell()
	var/obj/O
	var/coefficient = 1
	if(istype(A, /obj/item/gun/energy))
		to_chat(user, span_alert("Error unable to interface with device."))
		return FALSE
	if(istype(A, /obj/item/clothing/suit/space))
		to_chat(user, span_alert("Error unable to interface with device."))
		return FALSE
	if(istype(A, /obj))
		O = A
	if(C)
		var/done_any = FALSE
		if(C.charge >= C.maxcharge)
			balloon_alert(user, "it's fully charged!")
			recharging = FALSE
			return TRUE
		user.visible_message(span_notice("[user] starts recharging [A] with [src]."), span_notice("You start recharging [A] with [src]."))
		while(C.charge < C.maxcharge)
			if(do_after(user, 10, target = user) && cell.charge)
				done_any = TRUE
				induce(C, coefficient)
				do_sparks(1, FALSE, A)
				if(O)
					O.update_appearance()
			else
				break
		if(done_any) // Only show a message if we succeeded at least once
			user.visible_message(span_notice("[user] recharged [A]!"), span_notice("You recharged [A]!"))
		recharging = FALSE
		return TRUE
	recharging = FALSE


/obj/item/inducer/attack(mob/M, mob/living/user)
	if(user.combat_mode)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(M, user))
		return
	return ..()


/obj/item/inducer/attack_self(mob/user)
	if(opened && cell)
		user.visible_message(span_notice("[user] removes [cell] from [src]!"), span_notice("You remove [cell]."))
		cell.update_appearance()
		user.put_in_hands(cell)
		cell = null
		update_appearance()


/obj/item/inducer/examine(mob/living/M)
	. = ..()
	if(cell)
		. += span_notice("Its display shows: [display_energy(cell.charge)].")
	else
		. += span_notice("Its display is dark.")
	if(opened)
		. += span_notice("Its battery compartment is open.")

/obj/item/inducer/update_overlays()
	. = ..()
	if(!opened)
		return
	. += "inducer-[cell ? "bat" : "nobat"]"

/obj/item/inducer/sci
	icon_state = "inducer-sci"
	inhand_icon_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than its engineering counterpart."
	cell_type = null
	powertransfer = 500
	opened = TRUE

/obj/item/inducer/sci/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/inducer/syndicate
	icon_state = "inducer-syndi"
	inhand_icon_state = "inducer-syndi"
	desc = "A tool for inductively charging internal power cells. This one has a suspicious colour scheme, and seems to be rigged to transfer charge at a much faster rate."
	powertransfer = 2000
	cell_type = /obj/item/stock_parts/cell/super
