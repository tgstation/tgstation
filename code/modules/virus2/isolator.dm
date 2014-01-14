/obj/machinery/disease2/isolator/
	name = "Pathogenic Isolator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "isolator"
	var/datum/disease2/disease/virus2 = null
	var/isolating = 0
	var/beaker = null

/obj/machinery/disease2/isolator/attackby(var/W as obj, var/mob/user)
	if(!istype(W,/obj/item/weapon/reagent_containers/syringe))
		return

	var/obj/item/weapon/reagent_containers/syringe/B = W

	if(src.beaker)
		user << "A syringe is already loaded into the machine."
		return

	src.beaker =  B
	user.drop_item()
	B.loc = src
	if(istype(B,/obj/item/weapon/reagent_containers/syringe))
		user << "You add the syringe to the machine!"
		src.updateUsrDialog()
		icon_state = "isolator_in"

/obj/machinery/disease2/isolator/Topic(href, href_list)
	if(..()) return

	usr.machine = src
	if(!beaker) return
	var/datum/reagents/R = beaker:reagents

	if (href_list["isolate"])
		var/datum/reagent/blood/Blood
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B && B.data["virus2"])
				Blood = B
				break
		// /vg/: Try to fix isolators
		if(!Blood)
			usr << "\red ERROR: Unable to locate blood within the beaker.  Bug?"
			testing("Unable to locate blood in [beaker]!")
			return
		var/list/virus = virus_copylist(Blood.data["virus2"])
		var/choice = text2num(href_list["isolate"])
		for (var/datum/disease2/disease/V in virus)
			if (V.uniqueID == choice)
				virus2 = virus
				isolating = 40
				icon_state = "isolator_processing"
		src.updateUsrDialog()
		return

	else if (href_list["main"])
		attack_hand(usr)
		return
	else if (href_list["eject"])
		beaker:loc = src.loc
		beaker = null
		icon_state = "isolator"
		src.updateUsrDialog()
		return

/obj/machinery/disease2/isolator/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.machine = src
	var/dat = ""
	if(!beaker)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\virus2\isolator.dm:68: dat = "Please insert sample into the isolator.<BR>"
		dat = {"Please insert sample into the isolator.<BR>
<A href='?src=\ref[src];close=1'>Close</A>"}
		// END AUTOFIX
	else if(isolating)
		dat = "Isolating"
	else
		var/datum/reagents/R = beaker:reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject</A><BR><BR>"
		if(!R.total_volume)
			dat += "[beaker] is empty."
		else
			dat += "Contained reagents:<ul>"
			for(var/datum/reagent/blood/G in R.reagent_list)
				if(G.data["virus2"])
					var/list/virus = G.data["virus2"]
					for (var/datum/disease2/disease/V in virus)
						dat += "<li>[G.name]: <A href='?src=\ref[src];isolate=[V.uniqueID]'>Isolate pathogen #[V.uniqueID]</a></li>"
				else
					dat += "<li><em>No pathogen</em></li>"
	user << browse("<TITLE>Pathogenic Isolator</TITLE>Isolator menu:<BR><BR>[dat]</ul>", "window=isolator;size=575x400")
	onclose(user, "isolator")
	return

/obj/machinery/disease2/isolator/process()
	if(isolating > 0)
		isolating -= 1
		if(isolating == 0)
			var/obj/item/weapon/virusdish/d = new /obj/item/weapon/virusdish(src.loc)
			d.virus2 = virus2.getcopy()
			virus2 = null
			icon_state = "isolator_in"
