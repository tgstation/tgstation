/obj/structure/closet/crate/flatpack
	name = "flatpack"
	desc = "A ready-to-assemble machine flatpack produced in the space-Swedish style.<br>Crowbar the flatpack open and follow the obtuse instructions to make the resulting machine."
	icon = 'icons/obj/machines/flatpack.dmi'
	icon_state = "flatpack"
	density = 1
	anchored = 0
	var/obj/machinery/machine = null
	var/datum/construction/flatpack_unpack/unpacking
	var/opening = 0
	var/assembling = 0

/obj/structure/closet/crate/flatpack/New()
	..()
	unpacking = new (src)
	icon_state = "flatpack" //it gets changed in the crate code, so we reset it here

/obj/structure/closet/crate/flatpack/attackby(var/atom/A, mob/user)
	if(assembling)
		if(unpacking.assemble_busy)
			return
		if(unpacking.action(A, user))
			return 1
	if(istype(A, /obj/item/weapon/crowbar) && !assembling)
		if(opening)
			user << "<span class='warning'>This is already being opened.</span>"
			return 1
		user <<"<span class='notice'>You begin to open the flatpack...</span>"
		opening = 1
		if(do_after(user, rand(10,40)))
			if(machine)
				user <<"<span class='notice'>\icon [src]You successfully unpack \the [src]!</span>"
				overlays += "assembly"
				assembling = 1
				opening = 0
				var/obj/item/weapon/paper/instructions = new (get_turf(src))
				var/list/inst_list = unpacking.GenerateInstructions()
				instructions.name = "instructions ([machine.name])"
				instructions.info = inst_list["instructions"]
				if(inst_list["misprint"])
					instructions.overlays += "paper_stamped_denied"
					instructions.name = "misprinted " + instructions.name
				instructions.update_icon()
			else
				user <<"<span class='notice'>\icon [src]It seems this [src] was empty...</span>"
				qdel(src)
		opening = 0
		return

/obj/structure/closet/crate/flatpack/proc/Finalize()
	machine.loc = get_turf(src)
	machine.RefreshParts()
	for(var/atom/movable/AM in src)
		AM.loc = get_turf(src)
	qdel(src)

/obj/structure/closet/crate/flatpack/attack_hand()
	return

/datum/construction/flatpack_unpack
	steps = list()
	var/assemble_busy = 0

/datum/construction/flatpack_unpack/New(var/atom/A)
	var/last_step = ""
	while(((steps.len <= 7) && prob(80)) || steps.len <= 3)
		var/current_tool = pick(list("weldingtool", "wrench", "screwdriver", "wirecutter")  - last_step) //anything but what we just did
		last_step = current_tool
		steps += null
		switch(current_tool)
			if("weldingtool")
				steps[steps.len] = list("key"=/obj/item/weapon/weldingtool,
							"tool_name" = "welding tool",
							"action" = "weld the plates")
			if("screwdriver")
				steps[steps.len] = list("key"=/obj/item/weapon/screwdriver,
							"tool_name" = "screwdriver",
							"action" = "tighten the screws")
			if("wrench")
				steps[steps.len] = list("key"=/obj/item/weapon/wrench,
							"tool_name" = "wrench",
							"action" = "secure the bolts")
			if("wirecutter")
				steps[steps.len] = list("key"=/obj/item/weapon/wirecutters,
							"tool_name" = "wirecutter",
							"action" = "strip the wiring")
	holder = A
	..()

/datum/construction/flatpack_unpack/proc/GenerateInstructions()
	var/instructions = ""
	var/misprinted = 0
	for(var/list_step = steps.len; list_step > 0; list_step--)
		var/list/current_step = steps[list_step]
		if(prob(5) && !misprinted)
			current_step = steps[rand(1, steps.len)] //misprints ahoy
			misprinted = 1
		instructions += "<b>You see a small pictogram of \a [current_step["tool_name"]].</b><br> The minute script says: \"Be sure to [current_step["action"]] [pick("on a clear carpet", "with an adult", "with your friends", "under the captain's watchful gaze")].\"<br>"
	return list("instructions" = instructions, "misprint" = misprinted)

/datum/construction/flatpack_unpack/action(atom/used_atom, mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/flatpack_unpack/set_desc(index as num)
	return

/datum/construction/flatpack_unpack/check_step(atom/used_atom,mob/user as mob) //check last step only
	var/valid_step = is_right_key(user,used_atom)
	if(valid_step)
		if(custom_action(valid_step, used_atom, user))
			assemble_busy = 1
			if(do_after(user, 30))
				assemble_busy = 0
				var/list/step = steps[steps.len]
				user << "You successfully [step["action"]] in the assembly."
				next_step(user)
			assemble_busy = 0
			return 1
	return 0

/datum/construction/flatpack_unpack/spawn_result(mob/user as mob)
	var/obj/structure/closet/crate/flatpack/FP = holder
	if(!istype(FP))
		del(src)
		return
	else
		FP.Finalize()
		del(src)
		return 1