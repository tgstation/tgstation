/datum/construction
	var/list/steps
	var/atom/holder
	var/result

	New(atom)
		..()
		holder = atom
		if(!holder) //don't want this without a holder
			spawn
				del src
		return

	proc/next_step()
		steps.len--
		if(!steps.len && result)
			new result(get_turf(holder))
			spawn()
				del holder
		return

	proc/check_step(used_atom,user as mob)
		var/valid_step = is_right_key(used_atom)
		if(valid_step)
			if(custom_action(valid_step, used_atom, user))
				next_step()
				return 1
		return 0

	proc/is_right_key(used_atom) // returns current step num if used_atom is of the right type.
		var/list/L = steps[steps.len]
		if(istype(used_atom, text2path(L["key"])))
			return steps.len
		return 0

	proc/custom_action(used_atom, user)
		return 1


/datum/construction/mecha/gygax

	result = "/obj/mecha/combat/gygax"
	steps = list(list("key"="/obj/item/weapon/wrench"),//1
					 list("key"="/obj/item/weapon/weldingtool"),//2
					 list("key"="/obj/item/weapon/screwdriver"),//3
					 list("key"="/obj/item/stack/sheet/metal")//4
					)

	custom_action(step, used_atom, mob/user)
		switch(step)
			if(4)
				var/obj/item/stack/sheet/metal/metal = used_atom
				if(metal.amount < 1)
					del metal
					return 0
				metal.use(1)
				playsound(holder, 'bang.ogg', 50, 1)
				user.visible_message("[user] has added [used_atom] to [holder].", "You add [used_atom] to [holder]")
			if(3)
				holder.icon_state = "gygax"
				user.visible_message("[user] screwed the metal sheet in place.", "You screw the metal sheet in place")
			if(2)
				var/obj/item/weapon/weldingtool/W = used_atom
				if(!W.welding)
					return 0
				if(W.get_fuel() < 2)
					user << ("You need more fuel to complete current task")
					return 0
				W.use_fuel(1)
				playsound(holder, 'Welder.ogg', 50, 1)
				user.visible_message("[user] welded the metal sheet to [holder].", "You weld the metal sheet to [holder].")


		return 1





