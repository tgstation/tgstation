/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input/input = null
	var/obj/machinery/mineral/output/output = null
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
			if (istype(O,/obj/item/stack/sheet/mineral/gold))
				amt_gold += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/mineral/silver))
				amt_silver += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/mineral/diamond))
				amt_diamond += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/mineral/plasma))
				amt_plasma += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/mineral/uranium))
				amt_uranium += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/metal))
				amt_iron += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/mineral/clown))
				amt_clown += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/mineral/adamantine))
				amt_adamantine += 100 * O.amount
				del(O) //Commented out for now. -Durandan


/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
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
			switch(chosen)
				if("metal")
					while(amt_iron > 0 && coinsToProduce > 0)
						new/obj/item/weapon/coin/iron(output.loc)
						amt_iron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("gold")
					while(amt_gold > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/gold(output.loc)
						amt_gold -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("silver")
					while(amt_silver > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/silver(output.loc)
						amt_silver -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("diamond")
					while(amt_diamond > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/diamond(output.loc)
						amt_diamond -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("plasma")
					while(amt_plasma > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/plasma(output.loc)
						amt_plasma -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("uranium")
					while(amt_uranium > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/uranium(output.loc)
						amt_uranium -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("clown")
					while(amt_clown > 0 && coinsToProduce > 0)

						new /obj/item/weapon/coin/clown(output.loc)
						amt_clown -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("adamantine")
					while(amt_adamantine > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/adamantine(output.loc)
						amt_adamantine -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("mythril")
					while(amt_adamantine > 0 && coinsToProduce > 0)
						new /obj/item/weapon/coin/mythril(output.loc)
						amt_mythril -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
			icon_state = "coinpress0"
			processing = 0;
			coinsToProduce = temp_coins
	return