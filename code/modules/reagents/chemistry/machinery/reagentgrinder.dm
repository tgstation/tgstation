
#define MILK_TO_BUTTER_COEFF 15

/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/reagentgrinder
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/speed = 1
	var/list/holdingitems

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	holdingitems = list()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	beaker.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/constructed/Initialize()
	. = ..()
	holdingitems = list()
	QDEL_NULL(beaker)
	update_icon()

/obj/machinery/reagentgrinder/Destroy()
	if(beaker)
		beaker.forceMove(drop_location())
	drop_all_items()
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/reagentgrinder/RefreshParts()
	speed = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed = M.rating

/obj/machinery/reagentgrinder/examine(mob/user)
	..()
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Grinding reagents at <b>[speed*100]%</b>.<span>")

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()
		updateUsrDialog()
	if(holdingitems[A])
		holdingitems -= A

/obj/machinery/reagentgrinder/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	//You can only screw open empty grinder
	if(!beaker && !length(holdingitems) && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		if (!beaker)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You slide [I] into [src].</span>")
			beaker = I
			update_icon()
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>There's already a container inside [src].</span>")
		return TRUE //no afterattack

	if(holdingitems.len >= limit)
		to_chat(user, "<span class='warning'>[src] is filled to capacity!</span>")
		return TRUE

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/list/inserted = list()
		if(SEND_SIGNAL(I, COMSIG_TRY_STORAGE_TAKE_TYPE, /obj/item/reagent_containers/food/snacks/grown, src, limit - length(holdingitems), null, null, user, inserted))
			for(var/i in inserted)
				holdingitems[i] = TRUE
			if(!I.contents.len)
				to_chat(user, "<span class='notice'>You empty [I] into [src].</span>")
			else
				to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")

		updateUsrDialog()
		return TRUE

	if(!I.grind_results && !I.juice_results)
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>You cannot grind [I] into reagents!</span>")
			return TRUE

	if(!I.grind_requirements(src)) //Error messages should be in the objects' definitions
		return

	if(user.transferItemToLoc(I, src))
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		holdingitems[I] = TRUE
		updateUsrDialog()
		return FALSE

/obj/machinery/reagentgrinder/ui_interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave
	. = ..()
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
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = TRUE
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = FALSE
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = TRUE
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"

		dat = {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if (is_beaker_ready)
			if(!is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
				dat += "<A href='?src=[REF(src)];action=grind'>Grind the reagents</a><BR>"
				dat += "<A href='?src=[REF(src)];action=juice'>Juice the reagents</a><BR><BR>"
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
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open(TRUE)
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
		if("juice")
			juice(user)
		if("mix")
			mix(user)
		if("eject")
			eject(user)
		if("detach")
			detach(user)
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/detach(mob/user)
	if(!beaker)
		return
	beaker.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(beaker)
	beaker = null
	update_icon()
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	if(!length(holdingitems))
		return
	for(var/i in holdingitems)
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shaking, old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time / speed)
	updateUsrDialog()
	operating = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', 50, 1)
		else
			playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, .proc/stop_operating), time / speed)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(!beaker || (beaker && (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)))
		return
	operate_for(50, juicing = TRUE)
	for(var/obj/item/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.juice_results)
			juice_item(I)

/obj/machinery/reagentgrinder/proc/juice_item(obj/item/I) //Juicing results can be found in respective object definitions
	if(I.on_juice(src) == -1)
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to juice up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.juice_results)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/grind(mob/user)
	power_change()
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	operate_for(60)
	for(var/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.grind_results)
			grind_item(i, user)

/obj/machinery/reagentgrinder/proc/grind_item(obj/item/I, mob/user) //Grind results can be found in respective object definitions
	if(I.on_grind(src) == -1) //Call on_grind() to change amount as needed, and stop grinding the item if it returns -1
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to grind up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.grind_results)
	if(I.reagents)
		I.reagents.trans_to(beaker, I.reagents.total_volume, transfered_by = user)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/mix(mob/user)
	//For butter and other things that would change upon shaking or mixing
	power_change()
	if(!beaker)
		return
	operate_for(50, juicing = TRUE)
	addtimer(CALLBACK(src, /obj/machinery/reagentgrinder/proc/mix_complete), 50)

/obj/machinery/reagentgrinder/proc/mix_complete()
	if(beaker && beaker.reagents.total_volume)
		//Recipe to make Butter
		var/butter_amt = FLOOR(beaker.reagents.get_reagent_amount("milk") / MILK_TO_BUTTER_COEFF, 1)
		beaker.reagents.remove_reagent("milk", MILK_TO_BUTTER_COEFF * butter_amt)
		for(var/i in 1 to butter_amt)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
		//Recipe to make Mayonnaise
		if (beaker.reagents.has_reagent("eggyolk"))
			var/amount = beaker.reagents.get_reagent_amount("eggyolk")
			beaker.reagents.remove_reagent("eggyolk", amount)
			beaker.reagents.add_reagent("mayonnaise", amount)
