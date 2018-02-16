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

/datum/construction/proc/action(obj/item/I, mob/user)
	return

/datum/construction/proc/check_step(obj/item/I, mob/user) //check last step only
	var/valid_step = is_right_key(I)
	if(valid_step)
		if(custom_action(valid_step, I, user))
			next_step()
			return 1
	return 0

/datum/construction/proc/is_right_key(obj/item/I) // returns current step num if I is of the right type.
	var/list/L = steps[steps.len]
	if(check_used_item(I, L["key"]))
		return steps.len
	return 0

/datum/construction/proc/check_used_item(obj/item/I, key)
	if(!key)
		return FALSE

	if(ispath(key) && istype(I, key))
		return TRUE

	else if(I.tool_behaviour == key)
		return TRUE

	return FALSE


/datum/construction/proc/custom_action(step, obj/item/I, user)
	return 1

/datum/construction/proc/check_all_steps(obj/item/I, mob/user) //check all steps, remove matching one.
	for(var/i=1;i<=steps.len;i++)
		var/list/L = steps[i]
		if(check_used_item(I, L["key"]))
			if(custom_action(i, I, user))
				steps[i] = null//stupid byond list from list removal...
				listclearnulls(steps)
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

/datum/construction/proc/drop_location()
	return holder.drop_location()

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

/datum/construction/reversible/is_right_key(obj/item/I) // returns index step
	var/list/L = steps[index]
	if(check_used_item(I, L["key"]))
		return FORWARD //to the first step -> forward
	else if(check_used_item(I, L["backkey"]))
		return BACKWARD //to the last step -> backwards
	return FALSE

/datum/construction/reversible/check_step(obj/item/I, mob/user)
	var/diff = is_right_key(I)
	if(diff)
		if(custom_action(index, diff, I, user))
			update_index(diff)
			return 1
	return 0

/datum/construction/reversible/custom_action(index, diff, obj/item/I, user)
	return 1
