#define FORWARD -1
#define BACKWARD 1

/datum/construction
	var/list/steps
	var/atom/holder
	var/result
	var/list/steps_desc

/datum/construction/New(atom)
	..()
	holder = atom
	if(!holder) //don't want this without a holder
		qdel(src)
	set_desc(steps.len)
	return

/datum/construction/proc/next_step()
	steps.len--
	if(!steps.len)
		spawn_result()
	else
		set_desc(steps.len)
	return

/datum/construction/proc/action(atom/used_atom,mob/user)
	return

/datum/construction/proc/check_step(atom/used_atom,mob/user) //check last step only
	var/valid_step = is_right_key(used_atom)
	if(valid_step)
		if(custom_action(valid_step, used_atom, user))
			next_step()
			return 1
	return 0

/datum/construction/proc/is_right_key(atom/used_atom) // returns current step num if used_atom is of the right type.
	var/list/L = steps[steps.len]
	if(istype(used_atom, L["key"]))
		return steps.len
	return 0

/datum/construction/proc/custom_action(step, used_atom, user)
	return 1

/datum/construction/proc/check_all_steps(atom/used_atom,mob/user) //check all steps, remove matching one.
	for(var/i=1;i<=steps.len;i++)
		var/list/L = steps[i];
		if(istype(used_atom, L["key"]))
			if(custom_action(i, used_atom, user))
				steps[i]=null;//stupid byond list from list removal...
				listclearnulls(steps);
				if(!steps.len)
					spawn_result()
				return 1
	return 0


/datum/construction/proc/spawn_result()
	if(result)
		new result(get_turf(holder))
		qdel(holder)
	return

/datum/construction/proc/spawn_mecha_result()
	if(result)
		var/obj/mecha/m = new result(get_turf(holder))
		var/obj/item/oldcell = locate (/obj/item/stock_parts/cell) in m
		QDEL_NULL(oldcell)
		m.CheckParts(holder.contents)
		SSblackbox.record_feedback("tally", "mechas_created", 1, m.name)
		QDEL_NULL(holder)

/datum/construction/proc/set_desc(index as num)
	var/list/step = steps[index]
	holder.desc = step["desc"]
	return

/datum/construction/reversible
	var/index

/datum/construction/reversible/New(atom)
	..()
	index = steps.len
	return

/datum/construction/reversible/proc/update_index(diff as num)
	index+=diff
	if(index==0)
		spawn_result()
	else
		set_desc(index)
	return

/datum/construction/reversible/is_right_key(atom/used_atom) // returns index step
	var/list/L = steps[index]
	if(istype(used_atom, L["key"]))
		return FORWARD //to the first step -> forward
	else if(L["backkey"] && istype(used_atom, L["backkey"]))
		return BACKWARD //to the last step -> backwards
	return 0

/datum/construction/reversible/check_step(atom/used_atom,mob/user)
	var/diff = is_right_key(used_atom)
	if(diff)
		if(custom_action(index, diff, used_atom, user))
			update_index(diff)
			return 1
	return 0

/datum/construction/reversible/custom_action(index, diff, used_atom, user)
	return 1


#define STATE_NEXT "next"
#define STATE_PREV "prev"

//i couldn't think of a way to verbosify these names more so i just added _THING to them
#define DELETE_THING "delete"
#define SPAWN_THING "spawn"
#define AMOUNT_THING "amount"


/datum/construction/reversible2
	var/index = 1
	var/base_icon = "durand"

/datum/construction/reversible2/proc/update_index(diff as num, mob/user as mob)
	index-=diff
	if(index==steps.len+1)
		spawn_result(user)
	else
		set_desc(index)
	return

/datum/construction/reversible2/proc/update_icon()
	if(holder)
		holder.icon_state="[base_icon]_[index]"

/datum/construction/reversible2/is_right_key(mob/user as mob,atom/used_atom) // returns index step
	var/list/state = steps[index]
	if(STATE_NEXT in state)
		var/list/le_step = state[STATE_NEXT]
		if(istype(used_atom, le_step["key"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return FALSE
			return FORWARD //to the first step -> forward
	else if(STATE_PREV in state)
		var/list/le_step = state[STATE_PREV]
		if(istype(used_atom, le_step["key"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return FALSE
			return BACKWARD //to the first step -> forward
	return FALSE

/datum/construction/reversible2/check_step(atom/used_atom,mob/user as mob)
	var/diff = is_right_key(user,used_atom)
	if(diff)
		if(custom_action(index, diff, used_atom, user))
			update_index(diff,user)
			update_icon()
			return TRUE
	return FALSE

/datum/construction/reversible2/proc/fixText(text,user)
	text = replacetext(text,"{USER}","[user]")
	text = replacetext(text,"{HOLDER}","[holder]")
	return text

/datum/construction/reversible2/custom_action(index, diff, used_atom, var/mob/user)
	if(!..())
		return FALSE

	var/list/le_fucking_step = steps[index]
	var/list/state = le_fucking_step[diff==FORWARD ? STATE_NEXT : STATE_PREV]
	user.visible_message(fixText(state["vis_msg"],user),fixText(state["self_msg"],user)) //show messages

	if(DELETE_THING in state) //delete it if it needs to be deleted
		qdel(used_atom)
	else if(state[SPAWN_THING]) //if we need to create a thing, then do it
		var/spawntype=state[SPAWN_THING]
		var/atom/A = new spawntype(holder.loc)
		if(state[AMOUNT_THING]) //create X amount of thing if applicable
			if(istype(A,/obj/item/stack/cable_coil)) //why don't we have universal stackcode
				var/obj/item/stack/cable_coil/C=A
				C.amount=state[AMOUNT_THING]
			if(istype(A,/obj/item/stack))
				var/obj/item/stack/S=A
				S.amount=state[AMOUNT_THING]
	return TRUE

/datum/construction/reversible2/action(used_atom,user)
	return check_step(used_atom,user)

#undef DELETE_THING
#undef SPAWN_THING
#undef AMOUNT_THING