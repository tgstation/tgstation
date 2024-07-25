/obj/machinery/disease2/isolator
	name = "Pathogenic Isolator"
	desc = "Takes a syringe of blood, and isolates the pathogens inside into a dish."
	density = 1
	anchored = 1
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "isolator"
	var/datum/disease/advanced/isolated_disease = null
	var/isolating = 0
	var/beaker = null

/obj/machinery/disease2/isolator/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I,/obj/item/reagent_containers/syringe))
		return

	var/obj/item/reagent_containers/syringe/B = I

	if(src.beaker)
		to_chat(user, "A syringe is already loaded into the machine.")
		return

	if(user.dropItemToGround(B))
		B.forceMove(src)
		src.beaker =  B
		if(istype(B,/obj/item/reagent_containers/syringe))
			to_chat(user, "You add the syringe to the machine!")
			src.updateUsrDialog()
			icon_state = "isolator_in"

/obj/machinery/disease2/isolator/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	if(!beaker)
		return
	var/datum/reagents/R = beaker:reagents

	if (href_list["isolate"])
		var/datum/reagent/Blood
		for(var/datum/reagent/B in R.reagent_list)
			if(length(B.data) && ("viruses" in B.data))
				Blood = B
				break
		// /vg/: Try to fix isolators
		if(!Blood)
			to_chat(usr, span_warning("ERROR: Unable to locate blood within the beaker.  Bug?"))
//			testing("Unable to locate blood in [beaker]!")
			return
		var/list/virus = virus_copylist(Blood.data["viruses"])
		var/choice = text2num(href_list["isolate"])
		for (var/datum/disease/advanced/V as anything in virus)
			if (V.uniqueID == choice)
				isolated_disease = V
				isolating = 40
				icon_state = "isolator_processing"
		src.updateUsrDialog()
		return

	else if (href_list["main"])
		attack_hand(usr)
		return
	else if (href_list["eject"])
		beaker:forceMove(src.loc)
		beaker = null
		icon_state = "isolator"
		src.updateUsrDialog()
		return

/obj/machinery/disease2/isolator/attack_hand(mob/user, list/modifiers)
	if(machine_stat & BROKEN)
		return
	user.machine = src
	var/dat = ""
	if(!beaker)

		dat = {"Please insert sample into the isolator.<BR>
<A href='?src=\ref[src];close=1'>Close</A>"}
	else if(isolating)
		dat = "Isolating"
	else
		var/datum/reagents/R = beaker:reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject</A><BR><BR>"
		if(!R.total_volume)
			dat += "[beaker] is empty."
		else
			dat += "Contained reagents:<ul>"
			var/passes = FALSE
			for(var/datum/reagent/G in R.reagent_list)
				if(length(G.data) && ("viruses" in G.data))
					var/list/virus = G.data["viruses"]
					passes = TRUE
					for (var/datum/disease/advanced/V as anything in virus)
						dat |= "<li>[G.name]: <A href='?src=\ref[src];isolate=[V.uniqueID]'>Isolate pathogen #[V.uniqueID]</a></li>"
			if(!passes)
				dat += "<li><em>No pathogen</em></li>"
	user << browse("<TITLE>Pathogenic Isolator</TITLE>Isolator menu:<BR><BR>[dat]</ul>", "window=isolator;size=575x400")
	onclose(user, "isolator")
	return

/obj/machinery/disease2/isolator/process()
	if(isolating > 0)
		isolating -= 1
		if(isolating == 0)
			var/obj/item/weapon/virusdish/d = new /obj/item/weapon/virusdish(src.loc)
			d.contained_virus = isolated_disease.Copy()
			d.contained_virus.log += "[ROUND_TIME()] <br />Transferred to Virus dish"
			d.update_icon()
			isolated_disease = null
			icon_state = "isolator_in"
