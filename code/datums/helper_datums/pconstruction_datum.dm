#define FORWARD -1
#define BACKWARD 1

/*
This only exists so I don't break mecha construction
because the system mecha uses sucks horribly

so i'm using paradise's superior construction datum

which looks 100x better in practice and is just generally better
*/

/datum/pconstruction
	var/list/steps
	var/atom/holder
	var/result
	var/list/steps_desc
	var/taskpath = null // Path of job objective completed.

	New(atom)
		..()
		holder = atom
		if(!holder) //don't want this without a holder
			spawn
				qdel(src)
		set_desc(steps.len)
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
		var/valid_step = is_right_key(used_atom)
		if(valid_step)
			if(custom_action(valid_step, used_atom, user))
				next_step(user)
				return 1
		return 0

	proc/is_right_key(atom/used_atom) // returns current step num if used_atom is of the right type.
		var/list/L = steps[steps.len]
		if(istype(used_atom, L["key"]))
			return steps.len
		return 0

	proc/custom_action(step, used_atom, user)
		if(istype(used_atom, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = used_atom
			if(W.remove_fuel(0, user))
				playsound(holder, W.usesound, 50, 1)
			else
				return 0
		else if(istype(used_atom, /obj/item/weapon/wrench))
			var/obj/item/weapon/wrench/W = used_atom
			playsound(holder, W.usesound, 50, 1)

		else if(istype(used_atom, /obj/item/weapon/screwdriver))
			var/obj/item/weapon/screwdriver/S = used_atom
			playsound(holder, S.usesound, 50, 1)

		else if(istype(used_atom, /obj/item/weapon/wirecutters))
			var/obj/item/weapon/wirecutters/W = used_atom
			playsound(holder, W.usesound, 50, 1)

		else if(istype(used_atom, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = used_atom
			if(C.amount<4)
				to_chat(user, ("<span class='warning'>There's not enough cable to finish the task.</span>"))
				return 0
			else
				C.use(4)
				playsound(holder, C.usesound, 50, 1)
		else if(istype(used_atom, /obj/item/stack))
			var/obj/item/stack/S = used_atom
			if(S.amount < 5)
				to_chat(user, ("<span class='warning'>There's not enough material in this stack.</span>"))
				return 0
			else
				S.use(5)
		return 1

	proc/check_all_steps(atom/used_atom,mob/user as mob) //check all steps, remove matching one.
		for(var/i=1;i<=steps.len;i++)
			var/list/L = steps[i];
			if(istype(used_atom, L["key"]))
				if(custom_action(i, used_atom, user))
					steps[i]=null;//stupid byond list from list removal...
					listclearnulls(steps);
					if(!steps.len)
						spawn_result(user)
					return 1
		return 0


	proc/spawn_result(mob/user as mob)
		if(result)
			/*if(taskpath)
				var/datum/job_objective/task = user.mind.findJobTask(taskpath)
				if(istype(task))
					task.unit_completed() */
					//we don't have job objectives for some crappy reason, so this needs to be commented out

			new result(get_turf(holder))
			spawn()
				qdel(holder)
		return

	proc/set_desc(index as num)
		var/list/step = steps[index]
		holder.desc = step["desc"]
		return

	proc/try_consume(mob/user as mob, atom/used_atom, amount)
		if(amount > 0)
			// CABLES
			if(istype(used_atom,/obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil=used_atom
				if(!coil.use(amount))
					to_chat(user, "<span class='warning'>You don't have enough cable! You need at least [amount] coils.</span>")
					return 0
			// WELDER
			if(istype(used_atom,/obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder=used_atom
				if(!welder.isOn())
					to_chat(user, "<span class='notice'>You tap the [src] with your unlit welder. [pick("Ding","Dong")].</span>")
					return 0
				if(!welder.remove_fuel(amount,user))
					to_chat(user, "<span class='warning'>You don't have enough fuel!</span>")
					return 0
			// STACKS
			if(istype(used_atom,/obj/item/stack))
				var/obj/item/stack/stack=used_atom
				if(stack.amount < amount)
					to_chat(user, "<span class='warning'>You don't have enough [stack]! You need at least [amount].</span>")
					return 0
				stack.use(amount)
		return 1

/datum/pconstruction/reversible
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

	is_right_key(atom/used_atom) // returns index step
		var/list/L = steps[index]
		if(istype(used_atom, L["key"]))
			return FORWARD //to the first step -> forward
		else if(L["backkey"] && istype(used_atom, L["backkey"]))
			return BACKWARD //to the last step -> backwards
		return 0

	check_step(atom/used_atom,mob/user as mob)
		var/diff = is_right_key(used_atom)
		if(diff)
			if(custom_action(index, diff, used_atom, user))
				update_index(diff, user)
				return 1
		return 0

	custom_action(index, diff, used_atom, user)
		if(!..(index,used_atom,user))
			return 0
		return 1

#define state_next "next"
#define state_prev "prev"

/datum/pconstruction/reversible2
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
			if(istype(used_atom, step["key"]))
				//if(L["consume"] && !try_consume(used_atom,L["consume"]))
				//	return 0
				return FORWARD //to the first step -> forward
		else if(state_prev in state)
			var/list/step = state[state_prev]
			if(istype(used_atom, step["key"]))
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

	proc/fixText(text,user)
		text = replacetext(text,"{USER}","[user]")
		text = replacetext(text,"{HOLDER}","[holder]")
		return text

	custom_action(index, diff, used_atom, var/mob/user)
		if(!..(index,used_atom,user))
			return 0

		var/list/step = steps[index]
		var/list/state = step[diff==FORWARD ? state_next : state_prev]
		user.visible_message(fixText(state["vis_msg"],user),fixText(state["self_msg"],user))

		if("delete" in state)
			qdel(used_atom)
		else if("spawn" in state)
			var/spawntype=state["spawn"]
			var/atom/A = new spawntype(holder.loc)
			if("amount" in state)
				if(istype(A,/obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C=A
					C.amount=state["amount"]
				if(istype(A,/obj/item/stack))
					var/obj/item/stack/S=A
					S.amount=state["amount"]

		return 1
	action(used_atom,user)
		return check_step(used_atom,user)