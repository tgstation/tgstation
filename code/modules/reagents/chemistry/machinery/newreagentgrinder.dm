/* BITS THAT GOTTA BE DONE IF YOU WANNA FINISH THIS OFF
- Add reagents to items that normally don't have reagents but can be ground up (iron to metal sheets, etc)
this is because the new system here uses reagents that already exist instead of a dumb hardcoded list to create new ones

- Same as above but for juice to certain plants. I removed the juicing system because it is completely stupid and the same
as the grinding system but labelled differently. It has the same problem as above, only slightly harder because it would require
changing some botany code to alter what reagents the plants grow with

- Ctrl+F `TODO`

- Maybe other stuff that I didn't account for because I never actually tried to even compile this
*/


/obj/machinery/reagentgrinder
	name = "All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/container = null
	var/max_limit = 10
	var/limit = max_limit
	var/list/holdingitems

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	holdingitems = list()
	container = new /obj/item/reagent_containers/glass/beaker/large(src)
	container.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(container)
	drop_all_items()
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(container)
		container.ex_act(severity, target)

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	. = ..()
	if(A == container)
		container = null
		update_icon()
	if(holdingitems[A])
		holdingitems -= A

/obj/machinery/reagentgrinder/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/machinery/reagentgrinder/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (drop_location(), 3)
	qdel(src)

/obj/machinery/reagentgrinder/update_icon()
	if(container)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/proc/get_weight(obj/item/I)
	var/weight = I.w_class
	if(I.w_class = WEIGHT_CLASS_NORMAL)
		limit_deduction = 5//you can still grind normal sized items, but only 2 at a time
	else if(w_class > WEIGHT_CLASS_NORMAL)
		weight = (max_limit + 1)
	return(weight)

/obj/machinery/reagentgrinder/proc/drop_in_item(obj/item/I, mob/user)
	if(!(limit - get_weight(I)) < 0)
		to_chat(user, "<span class='warning'>[src] has too much stuff inside of it already.</span>")
		return FALSE
	else
		limit -= limit_deduction
		user.transferItemToLoc(I, src)
		holdingitems[I] = TRUE
		updateUsrDialog()
		return TRUE

/obj/machinery/reagentgrinder/proc/but_do_it_got_reagents(obj/item/I, mob/user)
	if(!I.reagents)
		to_chat(user, "<span class='warning'>[I] does not contain any processable reagents.</span>")
		return FALSE
	else
		return TRUE

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(default_unfasten_wrench(user, I))
		return TRUE//no afterattack

	if (istype(I, /obj/item/reagent_containers) && I.is_open_container())
		if (!container)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
				return TRUE
			container = I
			update_icon()
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>There's already a container inside [src].</span>")
		return TRUE

	if(istype(I, /obj/item/storage/bag))
		var/obj/item/storage/bag/B = I
		for (var/obj/item/G in B.contents)
			if(!(limit - get_weight(G)) < 0 && but_do_it_got_reagents(G, user))
				B.remove_from_storage(G, src)
				drop_in_item(G)
			else //Sanity checking so the blender doesn't overfill
				if(!B.contents.len)
					to_chat(user, "<span class='notice'>You empty [I] into [src].</span>")
				else
					to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
				break
		updateUsrDialog()
		return TRUE

	if(!but_do_it_got_reagents(I, user))//it dont
		return TRUE

	drop_in_item(I, user)

/obj/machinery/reagentgrinder/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user)
	return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user)
	var/is_chamber_empty = FALSE
	var/is_beaker_ready = FALSE
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!operating)
		for (var/i in holdingitems)
			var/obj/item/O = i
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = TRUE
			processing_chamber = "Nothing."
		if (!container)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = TRUE
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = FALSE
			for(var/datum/reagent/R in container.reagents.reagent_list)
				anything = TRUE
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"

		dat = {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if(is_beaker_ready)
			if(!is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
				dat += "<A href='?src=[REF(src)];action=grind'>Grind the reagents</a><BR>"
			else if (beaker.reagents.total_volume)
				dat += "<A href='?src=[REF(src)];action=mix'>Mix the reagents</a><BR><BR>"
		if(length(holdingitems))
			dat += "<A href='?src=[REF(src)];action=eject'>Eject the reagents</a><BR>"
		if(beaker)
			dat += "<A href='?src=[REF(src)];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."

	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open(1)
	return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	var/mob/user = usr
	if(!user.canUseTopic(src))
		return
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind(user)
		if("mix")
			mix(user)
		if("eject")
			eject(user)
		if("detach")
			detach(user)
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	if(!length(holdingitems))
		return
	for(var/i in holdingitems)
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/detach(mob/user)
	if(!container)
		return
	container.forceMove(drop_location())
	container = null
	update_icon()
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/mix(mob/user)
	//For butter and other things that would change upon shaking or mixing
	power_change()
	if(!beaker)
		return
	operate_for(50)
	addtimer(CALLBACK(src, /obj/machinery/reagentgrinder/proc/mix_complete), 50)

/obj/machinery/reagentgrinder/proc/mix_complete()
	if(container && container.reagents.total_volume)
		//Recipe to make Butter
		var/butter_amt = Floor(beaker.reagents.get_reagent_amount("milk") / MILK_TO_BUTTER_COEFF)
		container.reagents.remove_reagent("milk", MILK_TO_BUTTER_COEFF * butter_amt)
		for(var/i in 1 to butter_amt)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
		//Recipe to make Mayonnaise
		if (container.reagents.has_reagent("eggyolk"))
			var/amount = container.reagents.get_reagent_amount("eggyolk")
			container.reagents.remove_reagent("eggyolk", amount)
			container.reagents.add_reagent("mayonnaise", amount)

/obj/machinery/reagentgrinder/proc/grind()
	power_change()
	if(!container || (container && container.reagents.total_volume >= container.reagents.maximum_volume))//if no beaker or it's full
		return//stop
	operate_for(60)
	var/total_new_reagents = 0
	for(var/i in holdingitems)
		total_new_reagents += i.reagents.total_volume
	if(total_new_reagents > (container.maximum_volume - container.total_volume))//if the amount of reagents we're about to add exceeds the space we have,
		//TODO: throw a warning prompt to the user and give them a chance to cancel or osmething lol
	for(var/i in holdingitems)
		i.reagents.trans_to(container, i.reagents.total_volume)
		holdingitems -= i
		qdel(i)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shaking, old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time)
	shake_for(time)
	updateUsrDialog()
	operating = TRUE
	playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, .proc/stop_operating), time)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE
	updateUsrDialog()