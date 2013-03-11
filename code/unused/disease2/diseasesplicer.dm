/obj/machinery/computer/diseasesplicer
	name = "Disease Splicer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "crew"
	//brightnessred = 0
//	brightnessgreen = 2
//	brightnessblue = 2
//	broken_icon

	var/datum/disease2/effectholder/memorybank = null
	var/analysed = 0
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0

	var/splicing = 0
	var/scanning = 0

/obj/machinery/computer/diseasesplicer/attackby(var/obj/I as obj, var/mob/user as mob)
/*
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/diseasesplicer/M = new /obj/item/weapon/circuitboard/diseasesplicer( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/diseasesplicer/M = new /obj/item/weapon/circuitboard/diseasesplicer( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)*/
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)

			dish = I
			c.drop_item()
			I.loc = src
	if(istype(I,/obj/item/weapon/diseasedisk))
		user << "You upload the contents of the disk into the buffer"
		memorybank = I:effect


	//else
	src.attack_hand(user)
	return

/obj/machinery/computer/diseasesplicer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/computer/diseasesplicer/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	if(splicing)
		dat = "Splicing in progress"
	else if(scanning)
		dat = "Splicing in progress"
	else if(burning)
		dat = "Data disk burning in progress"
	else
		if(dish)
			dat = "Virus dish inserted"

		dat += "<BR>Current DNA strand : "
		if(memorybank)
			dat += "<A href='?src=\ref[src];splice=1'>"
			if(analysed)
				dat += "[memorybank.effect.name] ([5-memorybank.effect.stage])"
			else
				dat += "Unknown DNA strand ([5-memorybank.effect.stage])"
			dat += "</a>"

			dat += "<BR><A href='?src=\ref[src];disk=1'>Burn DNA Sequence to data storage disk</a>"
		else
			dat += "Empty"

		dat += "<BR><BR>"

		if(dish)
			if(dish.virus2)
				if(dish.growth >= 50)
					for(var/datum/disease2/effectholder/e in dish.virus2.effects)
						dat += "<BR><A href='?src=\ref[src];grab=\ref[e]'> DNA strand"
						if(dish.analysed)
							dat += ": [e.effect.name]"
						dat += " (5-[e.effect.stage])</a>"
				else
					dat += "<BR>Insufficent cells to attempt gene splicing"
			else
				dat += "<BR>No virus found in dish"

			dat += "<BR><BR><A href='?src=\ref[src];eject=1'>Eject disk</a>"
		else
			dat += "<BR>Please insert dish"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/diseasesplicer/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()

	if(scanning)
		scanning -= 1
		if(!scanning)
			state("The [src.name] beeps")
			icon_state = "crew"
	if(splicing)
		splicing -= 1
		if(!splicing)
			state("The [src.name] pings")
			icon_state = "crew"
	if(burning)
		burning -= 1
		if(!burning)
			var/obj/item/weapon/diseasedisk/d = new /obj/item/weapon/diseasedisk(src.loc)
			if(analysed)
				d.name = "[memorybank.effect.name] GNA disk (Stage: [5-memorybank.effect.stage])"
			else
				d.name = "Unknown GNA disk (Stage: [5-memorybank.effect.stage])"
			d.effect = memorybank
			state("The [src.name] zings")
			icon_state = "crew"


	return

/obj/machinery/computer/diseasesplicer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["grab"])
			memorybank = locate(href_list["grab"])
			analysed = dish.analysed
			del(dish)
			dish = null
			scanning =  30
			icon_state = "crew"

		else if(href_list["eject"])
			dish.loc = src.loc
			dish = null

		else if(href_list["splice"])
			for(var/datum/disease2/effectholder/e in dish.virus2.effects)
				if(e.stage == memorybank.stage)
					e.effect = memorybank.effect
			splicing = 50
			dish.virus2.spreadtype = "Blood"
			icon_state = "crew"

		else if(href_list["disk"])
			burning = 20
			icon_state = "crew"

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/diseasesplicer/proc/state(var/msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("\icon[src] \blue [msg]", 2)


/obj/item/weapon/diseasedisk
	name = "Blank GNA disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	var/datum/disease2/effectholder/effect = null
	var/stage = 1

/obj/item/weapon/diseasedisk/premade/New()
	name = "Blank GNA disk (stage: [5-stage])"
	effect = new /datum/disease2/effectholder
	effect.effect = new /datum/disease2/effect/invisible
	effect.stage = stage
