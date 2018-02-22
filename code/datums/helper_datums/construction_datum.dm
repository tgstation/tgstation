#define FORWARD 1
#define BACKWARD -1

#define ITEM_DELETE "delete"
#define ITEM_MOVE_INSIDE "move_inside"


/datum/construction
	var/list/steps
	var/atom/holder
	var/result
	var/index = 1

/datum/construction/New(atom)
	..()
	holder = atom
	if(!holder) //don't want this without a holder
		qdel(src)
	update_holder(index)

/datum/construction/proc/on_step()
	if(index > steps.len)
		spawn_result()
	else
		update_holder(index)

/datum/construction/proc/action(obj/item/I, mob/living/user)
	return check_step(I, user)

/datum/construction/proc/update_index(diff)
	index += diff
	on_step()

/datum/construction/proc/check_step(obj/item/I, mob/living/user)
	var/diff = is_right_key(I)
	if(diff && custom_action(I, user, diff))
		update_index(diff)
		return TRUE
	return FALSE

/datum/construction/proc/is_right_key(obj/item/I) // returns index step
	var/list/L = steps[index]
	if(check_used_item(I, L["key"]))
		return FORWARD //to the first step -> forward
	else if(check_used_item(I, L["back_key"]))
		return BACKWARD //to the last step -> backwards
	return FALSE

/datum/construction/proc/check_used_item(obj/item/I, key)
	if(!key)
		return FALSE

	if(ispath(key) && istype(I, key))
		return TRUE

	else if(I.tool_behaviour == key)
		return TRUE

	return FALSE

/datum/construction/proc/custom_action(obj/item/I, mob/living/user, diff)
	return TRUE

/datum/construction/proc/spawn_result()
	if(result)
		new result(drop_location())
		qdel(holder)

/datum/construction/proc/update_holder(step_index)
	var/list/step = steps[step_index]

	if(step["desc"])
		holder.desc = step["desc"]

	if(step["icon_state"])
		holder.icon_state = step["icon_state"]

/datum/construction/proc/drop_location()
	return holder.drop_location()



// Unordered construction.
// Takes a list of part types, to be added in any order, as steps.
// Calls spawn_result() when every type has been added.
/datum/construction/unordered/check_step(obj/item/I, mob/living/user)
	for(var/typepath in steps)
		if(istype(I, typepath) && custom_action(I, user, typepath))
			steps -= typepath
			on_step()
			return TRUE
	return FALSE

/datum/construction/unordered/on_step()
	if(!steps.len)
		spawn_result()
	else
		update_holder(steps.len)

/datum/construction/unordered/update_holder(steps_left)
	return

/datum/construction/unordered/custom_action(obj/item/I, mob/living/user, typepath)
	return TRUE
