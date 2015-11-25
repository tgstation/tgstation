#define MAX_FLATPACK_STACKS	6 //how many flatpacks we can stack at once
#define FLATPACK_HEIGHT		4 //the height of the icon

/obj/structure/closet/crate/flatpack
	name = "\improper flatpack"
	desc = "A ready-to-assemble machine flatpack produced in the space-Swedish style."
	icon = 'icons/obj/machines/flatpack.dmi'
	icon_state = "flatpack"
	density = 1
	anchored = 0
	var/obj/machinery/machine = null
//	var/datum/construction/flatpack_unpack/unpacking
	var/assembling = 0

	var/list/image/stacked = list() //assoc ref list

/obj/structure/closet/crate/flatpack/examine(mob/user)
	..()
	if(stacked.len)
		for(var/stackpack in stacked)
			to_chat(user, "There's \a [locate(stackpack)] stacked on top of it.")

/obj/structure/closet/crate/flatpack/New()
	..()
//	unpacking = new (src)
	icon_state = "flatpack" //it gets changed in the crate code, so we reset it here

/obj/structure/closet/crate/flatpack/update_icon()
	overlays.len = 0

	icon_state = "flatpack"

	if(machine)
		var/list/check_accesses = (machine.req_access | machine.req_one_access)
		if(check_accesses && check_accesses.len)
			for(var/i = 1 to 4) //if the machine's access lines up with security's - and so on
				var/list/access_overlap = check_accesses & get_region_accesses(i)
				if(access_overlap.len)
					switch(i)
						if (1)
							icon_state = "flatpacksec"
						if (2)
							icon_state = "flatpackmed"
						if (3)
							icon_state = "flatpacksci"
						if (4)
							icon_state = "flatpackeng"
					break

/*	if(assembling)
		overlays += "assembly" */
	else if(stacked.len)
		for(var/i = 1 to stacked.len)
			var/image/stack_image = stacked[stacked[i]] //because it's an assoc list
			overlays -= stack_image
			stack_image.pixel_y = 4*i
			overlays += stack_image

/obj/structure/closet/crate/flatpack/attackby(var/atom/A, mob/user)
/*	if(assembling)
		if(unpacking.action(A, user))
			return 1 */
	if(istype(A, /obj/item/weapon/crowbar) && !assembling)
		if(stacked.len)
			to_chat(user, "<span class='rose'>You can't open this flatpack while others are stacked on top of it!</span>")
			return
		assembling = 1
		user.visible_message("<span class='notice'>[user] begins to open the flatpack...</span>", "<span class='notice'>You begin to open the flatpack...</span>")
		if(do_after(user, src, rand(10,40)))
			if(machine)
				to_chat(user, "<span class='notice'>\icon [src]You successfully unpack \the [machine]!</span>")
//				overlays += "assembly"
/*				var/obj/item/weapon/paper/instructions = new (get_turf(src))
				var/list/inst_list = unpacking.GenerateInstructions()
				instructions.name = "instructions ([machine.name])"
				instructions.info = inst_list["instructions"]
				if(inst_list["misprint"])
					instructions.overlays += "paper_stamped_denied"
					instructions.name = "misprinted " + instructions.name
				instructions.update_icon()
*/
				machine.forceMove(src.loc)
				machine = null
				qdel(src)
			else
				to_chat(user, "<span class='notice'>\icon [src]It seems this [src] was empty...</span>")
				qdel(src)
		assembling = 0
		return

/obj/structure/closet/crate/flatpack/proc/Finalize()
	machine.loc = get_turf(src)
	machine.RefreshParts()
	for(var/atom/movable/AM in src)
		AM.loc = get_turf(src)
	qdel(src)

/obj/structure/closet/crate/flatpack/attack_hand(mob/user, params)
	if(params && stacked.len)
		var/list/params_list = params2list(params)
		var/clicked_index = round((text2num(params_list["icon-y"]) - FLATPACK_HEIGHT)/ FLATPACK_HEIGHT) //which number are we clicking?

		if(clicked_index == 0) //clicked the bottom pack? Too bad, nothing happens
			return
		clicked_index = Clamp(clicked_index, 1, stacked.len)

		var/obj/structure/closet/crate/flatpack/bottom_pack = locate(stacked[clicked_index]) //so the very bottom pack is selected

		var/list/removed_packs = list()
		for(var/i = stacked.len; i > clicked_index; i--)
			var/obj/structure/closet/crate/flatpack/above = locate(stacked[i])
			removed_packs += above
			remove_stack(above) //remove all the flatpacks stacked above the clicked one

		remove_stack(bottom_pack) //moves the flatpack to where the user is
		bottom_pack.forceMove(get_turf(user))

		for(var/obj/structure/closet/crate/flatpack/newpack in removed_packs) //readd all the stacks we took off above it to the new one
			bottom_pack.add_stack(newpack)

		user.visible_message("[user] removes the top [bottom_pack.stacked.len + 1] flatpack\s from the stack.",
								"You remove the top [bottom_pack.stacked.len + 1] flatpack\s from the stack.")

		return 1
	return

/obj/structure/closet/crate/flatpack/MouseDrop_T(atom/dropping, mob/user)
	if(istype(dropping, /obj/structure/closet/crate/flatpack) && dropping != src)
		var/obj/structure/closet/crate/flatpack/stacking = dropping
/*		if(assembling || stacking.assembling)
			to_chat(user, "You can't stack opened flatpacks.")
			return */
		if((stacked.len + stacking.stacked.len + 2) >= MAX_FLATPACK_STACKS) //how many flatpacks we can in a stack (including the bases)
			to_chat(user, "You can't stack flatpacks that high.")
			return
		user.visible_message("[user] adds [stacking.stacked.len + 1] flatpack\s to the stack.",
								"You add [stacking.stacked.len + 1] flatpack\s to the stack.")
		add_stack(stacking)
		return 1
	return

/obj/structure/closet/crate/flatpack/proc/add_stack(obj/structure/closet/crate/flatpack/flatpack)
	if(!flatpack)
		return

	flatpack.loc = src

	var/image/flatimage = image(flatpack.icon, icon_state = flatpack.icon_state)

	stacked.Add(list("\ref[flatpack]" = flatimage))

	flatimage.pixel_y = stacked.len * FLATPACK_HEIGHT //the height of the icon
	overlays += flatimage

	if(flatpack.stacked.len) //if it's got stacks of its own
		var/flatpack_stacked = flatpack.stacked.Copy()
		for(var/stackedpack in flatpack_stacked)
			var/obj/structure/closet/crate/flatpack/newpack = locate(stackedpack)
			flatpack.remove_stack(newpack)
			add_stack(newpack)

/obj/structure/closet/crate/flatpack/proc/remove_stack(obj/structure/closet/crate/flatpack/flatpack)
	if(isnull(flatpack))
		return
	if(!("\ref[flatpack]" in stacked))
		return

	var/image/oldimage = stacked["\ref[flatpack]"]
	overlays.Remove(oldimage)

	stacked.Remove("\ref[flatpack]")

	update_icon()

/*
#define Fl_ACTION	"action"

/datum/construction/flatpack_unpack
	steps = list()

/datum/construction/flatpack_unpack/New(var/atom/A)
	var/last_step = ""
	while(((steps.len <= 7) && prob(80)) || steps.len <= 3)
		var/current_tool = pick(list("weldingtool", "wrench", "screwdriver", "wirecutter")  - last_step) //anything but what we just did
		last_step = current_tool
		steps += null
		switch(current_tool)
			if("weldingtool")
				steps[steps.len] = list(Co_KEY=/obj/item/weapon/weldingtool,
							Co_AMOUNT = 3, //requires the weldingtool is on
							Co_VIS_MSG = "{USER} weld{S} the plates in {HOLDER}",
							Co_START_MSG = "{USER} start{s} welding the plates in {HOLDER}",
							Fl_ACTION = "weld the plates",
							Co_DELAY = 30)
			if("screwdriver")
				steps[steps.len] = list(Co_KEY=/obj/item/weapon/screwdriver,
							Co_VIS_MSG = "{USER} tighten{S} the screws in {HOLDER}",
							Co_START_MSG = "{USER} start{s} tightening the screws in {HOLDER}",
							Fl_ACTION = "tighten the screws",
							Co_DELAY = 30)
			if("wrench")
				steps[steps.len] = list(Co_KEY=/obj/item/weapon/wrench,
							Co_VIS_MSG = "{USER} secure{S} the bolts in {HOLDER}",
							Co_START_MSG = "{USER} start{s} securing the bolts in {HOLDER}",
							Fl_ACTION = "secure the bolts",
							Co_DELAY = 30)
			if("wirecutter")
				steps[steps.len] = list(Co_KEY=/obj/item/weapon/wirecutters,
							Co_VIS_MSG = "{USER} strip{s} the wiring in {HOLDER}",
							Co_START_MSG = "{USER} start{s} stripping the wiring in {HOLDER}",
							Fl_ACTION = "strip the wiring",
							Co_DELAY = 30)
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

		var/obj/item/current_tool = current_step[Co_KEY]

		instructions += "<b>You see a small pictogram of \a [initial(current_tool.name)].</b><br> The minute script says: \"Be sure to [current_step[Fl_ACTION]] [pick("on a clear carpet", "with an adult", "with your friends", "under the captain's watchful gaze")].\"<br>"
	return list("instructions" = instructions, "misprint" = misprinted)

/datum/construction/flatpack_unpack/action(atom/used_atom, mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/flatpack_unpack/set_desc(index as num)
	return

/datum/construction/flatpack_unpack/spawn_result(mob/user as mob)
	var/obj/structure/closet/crate/flatpack/FP = holder
	if(!istype(FP))
		del(src)
		return
	else
		FP.Finalize()
		del(src)
		return 1

#undef Fl_ACTION
*/
