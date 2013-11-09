#define FORWARD -1
#define BACKWARD 1

/datum/construction
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
				del src
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
		var/valid_step = is_right_key(user,used_atom)
		if(valid_step)
			if(custom_action(valid_step, used_atom, user))
				next_step(user)
				return 1
		return 0

	proc/is_right_key(mob/user as mob, atom/used_atom) // returns current step num if used_atom is of the right type.
		var/list/L = steps[steps.len]
		if(istype(used_atom, L["key"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return 0
			return steps.len
		return 0

	proc/custom_action(step, used_atom, user)
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
			testing("[user] finished a [result]!")
			if(taskpath)
				var/datum/job_objective/task = user.mind.findJobTask(taskpath)
				testing("task is [task==null?"null":task]")
				if(istype(task))
					task.unit_completed()

			new result(get_turf(holder))
			spawn()
				del holder
		return

	proc/set_desc(index as num)
		var/list/step = steps[index]
		holder.desc = step["desc"]
		return

	proc/try_consume(mob/user as mob, atom/used_atom, amount)
		if(amount>0)
			// STACKS
			if(istype(used_atom,/obj/item/stack))
				var/obj/item/stack/stack=used_atom
				if(stack.amount < amount)
					user << "\red You don't have enough [stack]! You need at least [amount]."
					return 0
				stack.use(amount)
			// CABLES
			if(istype(used_atom,/obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/coil=used_atom
				if(coil.amount < amount)
					user << "\red You don't have enough cable! You need at least [amount] coils."
					return 0
				coil.use(amount)
			// WELDER
			if(istype(used_atom,/obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder=used_atom
				if(!welder.isOn())
					user << "\blue You tap the [src] with your unlit welder.  [pick("Ding","Dong")]."
					return 0
				if(!welder.remove_fuel(amount,user))
					user << "\red You don't have enough fuel!"
					return 0
		return 1


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
		if(istype(used_atom, L["key"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return 0
			return FORWARD //to the first step -> forward
		else if(L["backkey"] && istype(used_atom, L["backkey"]))
			//if(L["consume"] && !try_consume(used_atom,L["consume"]))
			//	return 0
			return BACKWARD //to the last step -> backwards
		return 0

	check_step(atom/used_atom,mob/user as mob)
		var/diff = is_right_key(user,used_atom)
		if(diff)
			if(custom_action(index, diff, used_atom, user))
				update_index(diff,user)
				return 1
		return 0

	custom_action(index, diff, used_atom, user)
		return 1