#define FORWARD -1
#define BACKWARD 1

#define Co_KEY			"key"
#define Co_BACKKEY		"backkey"
#define Co_VIS_MSG		"vis_msg"
#define Co_BACK_MSG		"back_msg"
#define Co_AMOUNT		"amount"
#define Co_MAX_AMOUNT	"max_amount"
#define Co_KEEP			"keep"
#define Co_DESC			"desc"

/datum/construction
	var/list/steps
	var/atom/holder
	var/result
	var/list/steps_desc
	var/taskpath = null // Path of job objective completed.
	var/assembling = 0 //if we're in a step, we won't be allowed to do another step
	var/permanence = 0
	var/list/used_atoms = list() //contains the stuff we add. Can be used in multiple-choice construction

	New(atom)
		..()
		holder = atom
		if(!holder) //don't want this without a holder
			spawn
				del src
		set_desc(steps.len)
		add_max_amounts()
		return

	proc/next_step(mob/user as mob)
		steps.len--
		if(!steps.len)
			spawn_result(user)
		else
			set_desc(steps.len)
		return

	proc/action(atom/used_atom,mob/user as mob)
		return

	proc/check_step(atom/used_atom,mob/user as mob) //check last step only
		var/valid_step = is_right_key(user,used_atom)
		if(valid_step && !assembling)
			assembling = 1
			if(custom_action(valid_step, used_atom, user))
				next_step(user)
				assembling = 0
				return 1
			assembling = 0
		return 0

	proc/is_right_key(mob/user as mob, atom/used_atom) // returns current step num if used_atom is of the right type.
		var/list/L = steps[steps.len]
		if((istype(L[Co_KEY], /list) && is_type_in_list(used_atom, L[Co_KEY])) || istype(used_atom, L[Co_KEY]))
		//if our keys are in a list, we want to check them all
		//otherwise, sanity permits setting it as a single type and checking that
			if(!try_consume(user, used_atom, L))
				return 0
			return steps.len
		return 0

	proc/custom_action(step, used_atom, user)
		if(istype(used_atom, /obj/item/weapon/weldingtool))
			playsound(holder, 'sound/items/Welder2.ogg', 50, 1)

		else if(istype(used_atom, /obj/item/weapon/wrench))
			playsound(holder, 'sound/items/Ratchet.ogg', 50, 1)

		else if(istype(used_atom, /obj/item/weapon/screwdriver))
			playsound(holder, 'sound/items/Screwdriver.ogg', 50, 1)

		else if(istype(used_atom, /obj/item/weapon/wirecutters))
			playsound(holder, 'sound/items/Wirecutter.ogg', 50, 1)

		construct_message(step, user)
		return 1


	proc/fixText(text,user)
		text = replacetext(text,"{USER}","[user]")
		text = replacetext(text,"{HOLDER}","[holder]")
		return text

	proc/construct_message(step, mob/user)
		user.visible_message(fixText(step[Co_VIS_MSG],user))

	proc/check_all_steps(atom/used_atom,mob/user as mob) //check all steps, remove matching one.
		for(var/i=1;i<=steps.len;i++)
			var/list/L = steps[i];
			if(istype(used_atom, L[Co_KEY]))
				if(custom_action(i, used_atom, user))
					steps[i]=null;//stupid byond list from list removal...
					listclearnulls(steps);
					if(!steps.len)
						spawn_result(user)
					return 1
		return 0


	proc/spawn_result(mob/user as mob)
		if(result)
			testing("[user] finished a [result]!")

			new result(get_turf(holder))
			spawn()
				del holder
		return

	proc/set_desc(index as num)
		var/list/step = steps[index]
		holder.desc = step[Co_DESC]
		return

	proc/try_consume(mob/user as mob, atom/movable/used_atom, given_step)
		if(!(Co_AMOUNT in given_step))
			return 1
		var/amount = given_step[Co_AMOUNT]
		if(amount>0)
			// STACKS
			if(istype(used_atom,/obj/item/stack))
				var/obj/item/stack/stack=used_atom
				if(stack.amount < amount)
					user << "<span class='notice'>You start adding [stack] to the [holder]. It still needs [amount - stack.amount] [stack.singular_name].</span>"
					given_step[Co_AMOUNT] -= stack.amount
					stack.use(stack.amount)
					return 0
				stack.use(amount)
			// WELDER
			else if(istype(used_atom,/obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder=used_atom
				if(!welder.isOn())
					user << "\blue You tap the [src] with your unlit welder.  [pick("Ding","Dong")]."
					return 0
				if(!welder.remove_fuel(amount,user))
					user << "\red You don't have enough fuel!"
					return 0
			//generic things
			else
				if(permanence || (Co_KEEP in given_step))
					user.drop_item(holder)
					used_atom.loc = holder
					used_atoms.Add(list("[steps.Find(given_step)]" = used_atom))
				else
					qdel(used_atom)
		return 1

	proc/add_max_amounts()
		for(var/list/this_step in steps)
			if((Co_AMOUNT in this_step) && this_step[Co_AMOUNT] > 1)
				this_step.Add(list(Co_MAX_AMOUNT = this_step[Co_AMOUNT])) //puts in something we can refer to when we reset the step

/datum/construction/reversible
	var/index

	New(atom)
		..()
		index = steps.len
		return

	proc/update_index(diff as num, mob/user as mob)
		index+=diff
		if(index==0)
			spawn_result(user)
		else
			set_desc(index)
		return

	is_right_key(mob/user as mob,atom/used_atom) // returns index step
		var/list/L = steps[index]
		if((istype(L[Co_KEY], /list) && is_type_in_list(used_atom, L[Co_KEY])) || istype(used_atom, L[Co_KEY]))
		//if our keys are in a list, we want to check them all
		//otherwise, sanity permits setting it as a single type and checking that
			if(!try_consume(user, used_atom, L))
				return 0
			return FORWARD //to the first step -> forward
		if((istype(L[Co_BACKKEY], /list) && is_type_in_list(used_atom, L[Co_BACKKEY])) || istype(used_atom, L[Co_BACKKEY]))
		//if our keys are in a list, we want to check them all
		//otherwise, sanity permits setting it as a single type and checking that
			return BACKWARD //to the last step -> backwards
		return 0

	check_step(atom/used_atom,mob/user as mob)
		var/diff = is_right_key(user,used_atom)
		if(diff && !assembling)
			assembling = 1
			if(custom_action(index, diff, used_atom, user))
				update_index(diff,user)
				assembling = 0
				return 1
			assembling = 0
		return 0

	custom_action(index, diff, used_atom, user)
		. = ..(index,used_atom,user)

		if(.)
			construct_message(steps[index], user, diff, 1)
		//handles spawning consumed items
		if(. && diff == BACKWARD)

			var/current_step = steps[index]
			if((Co_AMOUNT in current_step) && (Co_MAX_AMOUNT in current_step) && current_step[Co_AMOUNT] < current_step[Co_MAX_AMOUNT])
				var/obj/item/stack/S = new current_step[Co_KEY]
				if(istype(S))
					S.amount = current_step[Co_MAX_AMOUNT] - current_step[Co_AMOUNT]
				current_step[Co_AMOUNT] = current_step[Co_MAX_AMOUNT]
				S.loc = holder.loc


			var/prev_step = steps[index + 1]
			var/atom/movable/to_drop
			if(("[index + 1]" in used_atoms) && used_atoms["[index + 1]"])
				to_drop = used_atoms["[index + 1]"]
				used_atoms.Remove("[index + 1]")
			else if(Co_AMOUNT in prev_step)
				var/to_create = prev_step[Co_KEY]
				to_drop = new to_create
			if(istype(to_drop, /obj/item/stack))
				var/obj/item/stack/S = to_drop
				if(Co_MAX_AMOUNT in prev_step)
					S.amount = prev_step[Co_MAX_AMOUNT]
					prev_step[Co_AMOUNT] = prev_step[Co_MAX_AMOUNT]
				else
					S.amount = 5
					prev_step[Co_AMOUNT] = 5
					prev_step[Co_MAX_AMOUNT] = 5
			if(to_drop)
				to_drop.loc = holder.loc

	construct_message(step, mob/user, diff, override = 0)
		if(!override)
			return
		if(diff == FORWARD && (Co_VIS_MSG in step))
			user.visible_message(fixText(step[Co_VIS_MSG], user),fixText(step[Co_VIS_MSG], user, 1))
		else if(diff == BACKWARD && (Co_BACK_MSG in step))
			user.visible_message(fixText(step[Co_BACK_MSG], user),fixText(step[Co_BACK_MSG], user, 1))

	//NOT IN PLACE: message segments like verbs can be written as {UN|forwardmessage|backwardmessage}. This formats that in selection
	//the {s} tag makes a verb a plural
	fixText(message, mob/user, self = 0)
		var/text = message
		if(self)
			text = replacetext(text, "{s}", "")
			text = replacetext(text, "{USER}", "You")
		else
			text = replacetext(text, "{s}", "s")
		return ..(text, user)
		/*
		while("{UN|" in text)
			var/start_bracket = findtext(text, "{")
			var/this_verb = copytext(text, start_bracket, findtext(text, "}", start_bracket + 1))
			world << this_verb
			var/marker = findtext(this_verb, "|")
			var/final_verb = ""
			if(diff == FORWARD)
				final_verb = copytext(this_verb, marker + 1, findtext(this_verb, "|", marker + 1))
			else
				final_verb = copytext(this_verb, findtext(this_verb, "|", marker + 1), findtext(text, "}", start_bracket + 1))
			world << final_verb
			replacetext(text, this_verb, final_verb)
		*/


#define state_next "next"
#define state_prev "prev"

/datum/construction/reversible2
	var/index
	var/base_icon = "durand"

	New(atom)
		..()
		index = 1
		return

	proc/update_index(diff as num, mob/user as mob)
		index-=diff
		if(index==steps.len+1)
			spawn_result(user)
		else
			set_desc(index)
		return

	proc/update_icon()
		holder.icon_state="[base_icon]_[index]"

	is_right_key(mob/user as mob,atom/used_atom) // returns index step
		var/list/state = steps[index]
		if(state_next in state)
			var/list/step = state[state_next]
			if(istype(used_atom, step[Co_KEY]))
				//if(L["consume"] && !try_consume(used_atom,L["consume"]))
				//	return 0
				return FORWARD //to the first step -> forward
		else if(state_prev in state)
			var/list/step = state[state_prev]
			if(istype(used_atom, step[Co_KEY]))
				//if(L["consume"] && !try_consume(used_atom,L["consume"]))
				//	return 0
				return BACKWARD //to the first step -> forward
		return 0

	check_step(atom/used_atom,mob/user as mob)
		var/diff = is_right_key(user,used_atom)
		if(diff)
			if(custom_action(index, diff, used_atom, user))
				update_index(diff,user)
				update_icon()
				return 1
		return 0

	custom_action(index, diff, used_atom, var/mob/user)
		if(!..(index,used_atom,user))
			return 0

		var/list/step = steps[index]
		var/list/state = step[diff==FORWARD ? state_next : state_prev]

		if("delete" in state)
			qdel(used_atom)
		else if("spawn" in state)
			var/spawntype=state["spawn"]
			var/atom/A = new spawntype(holder.loc)
			if(Co_AMOUNT in state)
				if(istype(A,/obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C=A
					C.amount=state[Co_AMOUNT]
				if(istype(A,/obj/item/stack))
					var/obj/item/stack/S=A
					S.amount=state[Co_AMOUNT]

		return 1
	action(used_atom,user)
		return check_step(used_atom,user)
