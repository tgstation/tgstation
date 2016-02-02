/obj/machinery/chem_master/snackbar_machine
	name = "\improper SnackBar Machine"
	desc = "An explosion of flavour in every bite"
	condi = 1
	chem_board = /obj/item/weapon/circuitboard/snackbar_machine
	windowtype = "snackbar_machine"

/obj/machinery/chem_master/snackbar_machine/Topic(href, href_list)

	if(href_list["close"])
		usr << browse(null, "window=snackbar_machine")
		usr.unset_machine()
		return 1

	if(href_list["createpill"] || href_list["createpill_multiple"] || href_list["ejectp"] || href_list["change_pill"])
		return //No href exploits, fuck off

	if(..())
		return 1

	usr.set_machine(src)

	if(beaker && href_list["createbar"])
		var/obj/item/weapon/reagent_containers/food/snacks/snackbar/SB = new/obj/item/weapon/reagent_containers/food/snacks/snackbar(src.loc)
		reagents.trans_to(SB, 10)
		src.updateUsrDialog()
		return 1

	return

/obj/machinery/chem_master/snackbar_machine/attack_hand(mob/user as mob)

	if(..())
		return 1

	user.set_machine(src)

	var/dat = list()
	if(!beaker)
		dat += "Please insert a beaker.<BR>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += {"[G.name] , [G.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A>
					<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A>
					<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"}

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += {"[N.name] , [N.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A>
					<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"}
			dat += "<A href='?src=\ref[src];createbar=1'>Create snack bar (10 units max)</A>"
		else
			dat += "Buffer is empty.<BR>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(usr, "[windowtype]", "[name]", 575, 400, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "[windowtype]")
	return
