/obj/machinery/computer/curer
	name = "Cure Research Machine"
	icon_state = "dna"
	var/curing
	var/virusing

	var/obj/item/reagent_containers/cup/tube/container = null

/obj/machinery/computer/curer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/cup/tube))
		var/mob/living/carbon/C = user
		if(!container)
			if(C.forceMove(I, src))
				container = I
	if(istype(I,/obj/item/weapon/virusdish))
		if(virusing)
			to_chat(user, "<b>The pathogen materializer is still recharging..")
			return
		var/obj/item/reagent_containers/cup/tube/product = new(src.loc)

		var/list/data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"viruses"=list(),"immunity"=0)
		data["viruses"] |= I:viruses
		product.reagents.add_reagent(/datum/reagent/blood, 30,data)

		virusing = 1
		spawn(1200) virusing = 0

		return
	src.attack_hand(user)
	return

/obj/machinery/computer/curer/attack_hand(mob/user)
	if(..())
		return
	var/dat
	if(curing)
		dat = "Antibody production in progress"
	else if(virusing)
		dat = "Virus production in progress"
	else if(container)
		// see if there's any blood in the container
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in container.reagents.reagent_list

		if(B)
			dat = "Blood sample inserted."
			var/code = ""
			for(var/V in GLOB.all_antigens) if(text2num(V) & B.data["antibodies"]) code += GLOB.all_antigens[V]
			dat += "<BR>Antibodies: [code]"
			dat += "<BR><A href='?src=\ref[src];antibody=1'>Begin antibody production</a>"
		else
			dat += "<BR>Please check container contents."
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject container</a>"
	else
		dat = "Please insert a container."

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/curer/process()
	..()

	if(machine_stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(curing)
		curing -= 1
		if(curing == 0)
			if(container)
				createcure(container)
	return

/obj/machinery/computer/curer/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if (href_list["antibody"])
		curing = 10
	else if(href_list["eject"])
		container.forceMove(src.loc)
		container = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/curer/proc/createcure(obj/item/reagent_containers/cup/beaker/container)
	var/obj/item/reagent_containers/cup/tube/product = new(src.loc)

	var/datum/reagent/blood/B = locate() in container.reagents.reagent_list

	var/list/data = list()
	data["antigen"] = B.data["immunity"]

	product.reagents.add_reagent(/datum/reagent/vaccine , 30, data)

