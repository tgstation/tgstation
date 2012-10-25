/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/amt_silver = 0 //amount of silver
	var/amt_gold = 0   //amount of gold
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/amt_adamantine = 0
	var/amt_mythril = 0
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen = "metal" //which material will be used to make coins
	var/coinsToProduce = 10


/obj/machinery/mineral/mint/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_objects.Add(src)
		return
	return


/obj/machinery/mineral/mint/process()
	if ( src.input)
		var/obj/item/stack/sheet/O
		O = locate(/obj/item/stack/sheet, input.loc)
		if(O)
			if (istype(O,/obj/item/stack/sheet/gold))
				amt_gold += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/silver))
				amt_silver += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/diamond))
				amt_diamond += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/plasma))
				amt_plasma += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/uranium))
				amt_uranium += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/metal))
				amt_iron += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/clown))
				amt_clown += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/adamantine))
				amt_adamantine += 100 * O.amount
				del(O) //Commented out for now. -Durandan


/obj/machinery/mineral/mint/attack_hand(user as mob) //TODO: Adamantine coins! -Durandan

	var/dat = "<b>Coin Press</b><br>"

	if (!input)
		dat += text("input connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")
	if (!output)
		dat += text("<br>output connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")

	dat += text("<br><font color='#ffcc00'><b>Gold inserted: </b>[amt_gold]</font> ")
	if (chosen == "gold")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=gold'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Silver inserted: </b>[amt_silver]</font> ")
	if (chosen == "silver")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=silver'>Choose</A>")
	dat += text("<br><font color='#555555'><b>Iron inserted: </b>[amt_iron]</font> ")
	if (chosen == "metal")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=metal'>Choose</A>")
	dat += text("<br><font color='#8888FF'><b>Diamond inserted: </b>[amt_diamond]</font> ")
	if (chosen == "diamond")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=diamond'>Choose</A>")
	dat += text("<br><font color='#FF8800'><b>Plasma inserted: </b>[amt_plasma]</font> ")
	if (chosen == "plasma")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=plasma'>Choose</A>")
	dat += text("<br><font color='#008800'><b>uranium inserted: </b>[amt_uranium]</font> ")
	if (chosen == "uranium")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=uranium'>Choose</A>")
	if(amt_clown > 0)
		dat += text("<br><font color='#AAAA00'><b>Bananium inserted: </b>[amt_clown]</font> ")
		if (chosen == "clown")
			dat += text("chosen")
		else
			dat += text("<A href='?src=\ref[src];choose=clown'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Adamantine inserted: </b>[amt_adamantine]</font> ")//I don't even know these color codes, so fuck it.
	if (chosen == "adamantine")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=adamantine'>Choose</A>")

	dat += text("<br><br>Will produce [coinsToProduce] [chosen] coins if enough materials are available.<br>")
	//dat += text("The dial which controls the number of conins to produce seems to be stuck. A technician has already been dispatched to fix this.")
	dat += text("<A href='?src=\ref[src];chooseAmt=-10'>-10</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-5'>-5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-1'>-1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=1'>+1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=5'>+5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=10'>+10</A> ")

	dat += text("<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins.")
	dat += text("<br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>")
	user << browse("[dat]", "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing==1)
		usr << "\blue The machine is processing."
		return
	if(href_list["choose"])
		chosen = href_list["choose"]
	if(href_list["chooseAmt"])
		coinsToProduce = between(0, coinsToProduce + text2num(href_list["chooseAmt"]), 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		if (src.output)
			processing = 1;
			icon_state = "coinpress1"
			var/obj/item/weapon/moneybag/M
			switch(chosen)
				if("metal")
					while(amt_iron > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new/obj/item/weapon/coin/iron(M)
						amt_iron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("gold")
					while(amt_gold > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/gold(M)
						amt_gold -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("silver")
					while(amt_silver > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/silver(M)
						amt_silver -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("diamond")
					while(amt_diamond > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/diamond(M)
						amt_diamond -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("plasma")
					while(amt_plasma > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/plasma(M)
						amt_plasma -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("uranium")
					while(amt_uranium > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/uranium(M)
						amt_uranium -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("clown")
					while(amt_clown > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/clown(M)
						amt_clown -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("adamantine")
					while(amt_adamantine > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/adamantine(M)
						amt_adamantine -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("mythril")
					while(amt_adamantine > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/mythril(M)
						amt_mythril -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
			icon_state = "coinpress0"
			processing = 0;
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return