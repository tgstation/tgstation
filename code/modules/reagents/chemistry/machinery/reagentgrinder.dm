
#define MILK_TO_BUTTER_COEFF 15

/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
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
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/list/holdingitems

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	holdingitems = list()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	beaker.desc += " May contain blended dust. Don't breathe this in!"

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	drop_all_items()
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(beaker)
		beaker.ex_act(severity, target)

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

/obj/machinery/reagentgrinder/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (drop_location(), 3)
	qdel(src)

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return

	if (istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER_1) )
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
		var/obj/item/storage/bag/B = I
		for (var/obj/item/reagent_containers/food/snacks/grown/G in B.contents)
			B.remove_from_storage(G, src)
			holdingitems[G] = TRUE
			if(length(holdingitems) >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "<span class='notice'>You fill [src] to the brim.</span>")
				break

		if(!I.contents.len)
			to_chat(user, "<span class='notice'>You empty [I] into [src].</span>")

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

/obj/machinery/reagentgrinder/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user)
	return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave
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

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(!beaker || (beaker && (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)))
		return
	operate_for(50, juicing = TRUE)

	//Snacks
	for(var/obj/item/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.juice_results)
			juice_item(I)
		/*if(istype(I, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/O = I
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
			var/list/allowed = get_allowed_juice_by_obj(O)
			if(isnull(allowed))
				break
			for(var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = get_juice_amount(O)
				beaker.reagents.add_reagent(r_id, min(amount, space))
				if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
					break
			remove_object(O)*/

/obj/machinery/reagentgrinder/proc/juice_item(obj/item/I) //Juicing results can be found in respective object definitions
	if(I.on_juice(src) == -1)
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to juice up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.juice_results)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shaking, old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time)
	updateUsrDialog()
	operating = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', 50, 1)
		else
			playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, .proc/stop_operating), time)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/grind()
	power_change()
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	operate_for(60)
	for(var/i in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/obj/item/I = i
		if(I.grind_results)
			grind_item(i)
		/*
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/O = I
			var/list/allowed = get_allowed_by_obj(O)
			if(isnull(allowed))
				continue
			for(var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				if(amount <= 0)
					if(amount == 0)
						if (O.reagents != null && O.reagents.has_reagent("nutriment"))
							beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
							O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					else
						if (O.reagents != null && O.reagents.has_reagent("nutriment"))
							beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
							O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					O.reagents.trans_id_to(beaker, r_id, min(amount, space))
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
					break
			if(O.reagents.reagent_list.len == 0)
				remove_object(O)
		//Sheets
		else if(istype(I, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/O = I
			var/list/allowed = get_allowed_by_obj(O)
			for(var/t in 1 to round(O.amount, 1))
				for(var/r_id in allowed)
					var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
					var/amount = allowed[r_id]
					beaker.reagents.add_reagent(r_id,min(amount, space))
					if (space < amount)
						break
				if(t == round(O.amount, 1))
					remove_object(O)
					break
		//Plants
		else if(istype(I, /obj/item/grown))
			var/obj/item/grown/O = I
			var/list/allowed = get_allowed_by_obj(O)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				if (amount == 0)
					if (O.reagents != null && O.reagents.has_reagent(r_id))
						beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
				else
					beaker.reagents.add_reagent(r_id,min(amount, space))
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
					break
			remove_object(O)
		else if(istype(I, /obj/item/slime_extract))
			var/obj/item/slime_extract/O = I
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			if (O.reagents != null)
				var/amount = O.reagents.total_volume
				O.reagents.trans_to(beaker, min(amount, space))
			if (O.Uses > 0)
				beaker.reagents.add_reagent("slimejelly",min(20, space))
			remove_object(O)
		if(istype(I, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/O = I
			var/amount = O.reagents.total_volume
			O.reagents.trans_to(beaker, amount)
			if(!O.reagents.total_volume)
				remove_object(O)
		else if(istype(I, /obj/item/toy/crayon))
			var/obj/item/toy/crayon/O = I
			for (var/r_id in O.reagent_contents)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				if(!space)
					break
				beaker.reagents.add_reagent(r_id, min(O.reagent_contents[r_id], space))
				remove_object(O)*/

/obj/machinery/reagentgrinder/proc/grind_item(obj/item/I) //Grind results can be found in respective object definitions
	if(I.on_grind(src) == -1) //Call on_grind() to change amount as needed, and stop grinding the item if it returns -1
		to_chat(usr, "<span class='danger'>[src] shorts out as it tries to grind up [I], and transfers it back to storage.</span>")
		return
	beaker.reagents.add_reagent_list(I.grind_results)
	if(I.reagents)
		I.reagents.trans_to(beaker, I.reagents.total_volume)
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
		var/butter_amt = Floor(beaker.reagents.get_reagent_amount("milk") / MILK_TO_BUTTER_COEFF)
		beaker.reagents.remove_reagent("milk", MILK_TO_BUTTER_COEFF * butter_amt)
		for(var/i in 1 to butter_amt)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
		//Recipe to make Mayonnaise
		if (beaker.reagents.has_reagent("eggyolk"))
			var/amount = beaker.reagents.get_reagent_amount("eggyolk")
			beaker.reagents.remove_reagent("eggyolk", amount)
			beaker.reagents.add_reagent("mayonnaise", amount)
