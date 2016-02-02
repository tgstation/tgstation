/obj/machinery/centrifuge
	name = "Isolation Centrifuge"
	desc = "Used to separate things with different weight. Spin 'em round, round, right round."
	icon = 'icons/obj/virology.dmi'
	icon_state = "centrifuge"
	density = 1
	idle_power_usage = 10
	active_power_usage = 500
	machine_flags = SCREWTOGGLE | CROWDESTROY

	var/base_state = "centrifuge"
	var/curing
	var/isolating

	var/obj/item/weapon/reagent_containers/glass/beaker/vial/sample = null
	var/datum/disease2/disease/virus2 = null
	var/general_process_time = 40

	light_color = null

/obj/machinery/centrifuge/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/centrifuge,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/centrifuge/RefreshParts()
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
	general_process_time = initial(general_process_time) / manipcount

/obj/machinery/centrifuge/attackby(var/obj/item/weapon/reagent_containers/glass/beaker/vial/I, var/mob/user as mob)
	if(!istype(I))
		return ..()

	var/mob/living/carbon/C = user
	if(!sample)
		if(!C.drop_item(I, src)) return 1

		sample = I

	attack_hand(user)

//Also handles luminosity
/obj/machinery/centrifuge/update_icon()
	if(stat & BROKEN)
		icon_state = "[base_state]b"
		set_light(0)
	else if(stat & NOPOWER)
		icon_state = "[base_state]0"
		set_light(0)
	else if(isolating || curing)
		set_light(l_range = 2, l_power = 2, l_color = LIGHT_COLOR_CYAN)
		icon_state = "[base_state]_moving"
	else
		icon_state = "[base_state]"
		set_light(0)

/obj/machinery/centrifuge/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = list()
	if(curing)
		dat += "Antibody isolation in progress"
	else if(isolating)
		dat += "Pathogen isolation in progress"
	else
		dat += "<BR>Blood sample:"
		dat += "<br><table cellpadding='10'><tr><td>"
		if(sample)
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
			if(B)
				dat += "Sample inserted."
				if (B.data["antibodies"])
					dat += "</td></tr><tr><td>"
					dat += "Antibodies: [antigens2string(B.data["antibodies"])]"
					dat += "</td><td><A href='?src=\ref[src];action=antibody'>Isolate</a>"

				var/list/virus = B.data["virus2"]
				for (var/ID in virus)
					var/datum/disease2/disease/V = virus[ID]
					dat += " </td></tr><tr><td> pathogen [V.name()]"
					dat += "</td><td><A href='?src=\ref[src];action=isolate;isolate=[V.uniqueID]'>Isolate</a>"
			else
				dat += "Please check container contents."
			dat += "</td></tr><tr><td><A href='?src=\ref[src];action=sample'>Eject container</a>"
		else
			dat += "Please insert a container."
		dat += "</td></tr></table><br>"
		dat += "<hr>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "iso_centrifuge", "Isolation Centrifuge", 400, 300, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "iso_centrifuge")

/obj/machinery/centrifuge/process()

	..()

	if(stat & (NOPOWER|BROKEN))
		update_icon()
		return

	if(curing)
		use_power = 2
		curing--
		if(!curing)
			if(sample)
				cure()
	if(isolating)
		use_power = 2
		isolating--
		if(!isolating)
			if(sample)
				isolate()

	else
		use_power = 1

	update_icon() //This might be a bit more expensive, but it's foolproof
	src.updateUsrDialog()
	return

/obj/machinery/centrifuge/Topic(href, href_list)

	if(..())
		return 1

	if(usr)
		usr.set_machine(src)

	switch(href_list["action"])
		if("antibody")
			var/delay = general_process_time
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
			if(!B)
				say("No antibody carrier detected.")

			else if(sample.reagents.has_reagent("toxins"))
				say("Pathogen purging speed above nominal.")
				delay *= 0.5

			else
				curing = delay
				playsound(get_turf(src), 'sound/machines/juicer.ogg', 50, 1)
				update_icon()

		if("isolate")
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
			if (B)
				var/list/virus = virus_copylist(B.data["virus2"])
				var/choice = href_list["isolate"]
				if (choice in virus)
					virus2 = virus[choice]
					isolating = general_process_time * 2
					update_icon()
				else
					say("No such pathogen detected.")

		if("sample")
			if(sample)
				sample.forceMove(src.loc)
				sample = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	attack_hand(usr)
	return

/obj/machinery/centrifuge/proc/cure()
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
	if (!B)
		return

	var/list/data = list("antibodies" = B.data["antibodies"])
	var/amt= sample.reagents.get_reagent_amount("blood")
	sample.reagents.remove_reagent("blood",amt)
	sample.reagents.add_reagent("antibodies",amt,data)

	alert_noise("ping")

/obj/machinery/centrifuge/proc/isolate()
	var/obj/item/weapon/virusdish/dish = new/obj/item/weapon/virusdish(src.loc)
	dish.virus2 = virus2

	alert_noise("ping")
