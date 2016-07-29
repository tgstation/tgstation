<<<<<<< HEAD
/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1
	var/datum/material_container/materials
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen = MAT_METAL //which material will be used to make coins
	var/coinsToProduce = 10
	speed_process = 1


/obj/machinery/mineral/mint/New()
	..()
	materials = new /datum/material_container(src,
		list(MAT_METAL, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_URANIUM, MAT_DIAMOND, MAT_BANANIUM),
		max_amt = MINERAL_MATERIAL_AMOUNT*50)

/obj/machinery/mineral/mint/Destroy()
	qdel(materials)
	materials = null
	return ..()


/obj/machinery/mineral/mint/process()
	var/turf/T = get_step(src, input_dir)
	if(!T)
		return

	for(var/obj/item/stack/sheet/O in T)
		materials.insert_stack(O, O.amount)

/obj/machinery/mineral/mint/attack_hand(mob/user)
	var/dat = "<b>Coin Press</b><br>"

	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		if(!M.amount && chosen != mat_id)
			continue
		dat += "<br><b>[M.name] amount:</b> [M.amount] cm<sup>3</sup> "
		if (chosen == mat_id)
			dat += "<b>Chosen</b>"
		else
			dat += "<A href='?src=\ref[src];choose=[mat_id]'>Choose</A>"

	var/datum/material/M = materials.materials[chosen]

	dat += "<br><br>Will produce [coinsToProduce] [lowertext(M.name)] coins if enough materials are available.<br>"
	dat += "<A href='?src=\ref[src];chooseAmt=-10'>-10</A> "
	dat += "<A href='?src=\ref[src];chooseAmt=-5'>-5</A> "
	dat += "<A href='?src=\ref[src];chooseAmt=-1'>-1</A> "
	dat += "<A href='?src=\ref[src];chooseAmt=1'>+1</A> "
	dat += "<A href='?src=\ref[src];chooseAmt=5'>+5</A> "
	dat += "<A href='?src=\ref[src];chooseAmt=10'>+10</A> "

	dat += "<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins."
	dat += "<br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>"
	user << browse("[dat]", "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing==1)
		usr << "<span class='notice'>The machine is processing.</span>"
		return
	if(href_list["choose"])
		if(materials.materials[href_list["choose"]])
			chosen = href_list["choose"]
	if(href_list["chooseAmt"])
		coinsToProduce = Clamp(coinsToProduce + text2num(href_list["chooseAmt"]), 0, 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		processing = 1
		icon_state = "coinpress1"
		var/coin_mat = MINERAL_MATERIAL_AMOUNT * 0.2
		var/datum/material/M = materials.materials[chosen]
		if(!M || !M.coin_type)
			updateUsrDialog()
			return

		while(coinsToProduce > 0 && materials.use_amount_type(coin_mat, chosen))
			create_coins(M.coin_type)
			coinsToProduce--
			newCoins++
			src.updateUsrDialog()
			sleep(5)

		icon_state = "coinpress0"
		processing = 0
		coinsToProduce = temp_coins
	src.updateUsrDialog()
	return

/obj/machinery/mineral/mint/proc/create_coins(P)
	var/turf/T = get_step(src,output_dir)
	if(T)
		var/obj/item/O = new P(src)
		var/obj/item/weapon/storage/bag/money/M = locate(/obj/item/weapon/storage/bag/money, T)
		if(!M)
			M = new /obj/item/weapon/storage/bag/money(src)
			unload_mineral(M)
		O.loc = M
=======
/**********************Mint**************************/

/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null

	starting_materials = list() //makes the new empty datum

	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen = "iron" //which material will be used to make coins
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

		return
	return


/obj/machinery/mineral/mint/process()
	if ( src.input)
		var/obj/item/stack/sheet/O
		O = locate(/obj/item/stack/sheet, input.loc)
		if(O)
			for(var/ore_id in materials.storage)
				var/datum/material/po = materials.getMaterial(ore_id)
				if (po.cointype && istype(O,po.sheettype))
					materials.addAmount(ore_id, 5 * O.amount) // 100/20 = 5 coins per sheet.
					qdel(O)
					break


/obj/machinery/mineral/mint/attack_hand(user as mob)
	var/html = {"<html>
	<head>
		<title>Mint</title>
		<style type="text/css">
html,body {
	font-family:sans-serif,verdana;
	font-size:smaller;
	color:#666;
}
h1 {
	border-bottom:1px solid maroon;
}
table {
	border-spacing: 0;
	border-collapse: collapse;
}
td, th {
	margin: 0;
	font-size: small;
	border-bottom: 1px solid #ccc;
	padding: 3px;
}

tr:nth-child(even) {
	background: #efefef;
}

a.smelting {
	color:white;
	font-weight:bold;
	text-decoration:none;
	background-color:green;
}

a.notsmelting {
	color:white;
	font-weight:bold;
	text-decoration:none;
	background-color:maroon;
}
		</style>
	</head>
	<body>
		<h1>Mint</h1>
		<p><b>Current Status:</b> (<a href='?src=\ref[user];mach_close=recyk_furnace'>Close</a>)</p>"}


	if (!input)
		html += "<p style='color:red;font-weight:bold;'>INPUT NOT SET</p>"
	if (!output)
		html += "<p style='color:red;font-weight:bold;'>OUTPUT NOT SET</p>"
	html+={"
		<table>
			<tr>
				<th>Material</th>
				<th># Coins</th>
				<th>Controls</th>
			</tr>"}

	var/nloaded=0
	for(var/ore_id in materials.storage)
		var/datum/material/ore_info = materials.getMaterial(ore_id)
		if(materials.storage[ore_id] && ore_info.cointype)
			html += {"
			<tr>
				<td class="clmName">[ore_info.processed_name]</td>
				<td>[materials.storage[ore_id]]</td>
				<td>
					<a href="?src=\ref[src];choose=[ore_id]" "}
			if (chosen==ore_id)
				html += "class=\"smelting\">Selected"
			else
				html += "class=\"notsmelting\">Select"
			html += "</a></td></tr>"
			nloaded++
		else
			if(chosen==ore_id)
				chosen=null
	if(nloaded)
		html += {"
			</table>"}
	else
		html+="<tr><td colspan=\"3\"><em>No Materials Loaded</em></td></tr></table>"

	html += "<p>Will produce [coinsToProduce] [chosen] coins if enough materials are available.</p>"
	html += {"
		<p>
			\[
				<A href='?src=\ref[src];chooseAmt=-10'>-10</A>
				<A href='?src=\ref[src];chooseAmt=-5'>-5</A>
				<A href='?src=\ref[src];chooseAmt=-1'>-1</A>
				<A href='?src=\ref[src];chooseAmt=1'>+1</A>
				<A href='?src=\ref[src];chooseAmt=5'>+5</A>
				<A href='?src=\ref[src];chooseAmt=10'>+10</A>
			\]
		</p>
		<p>In total, this machine produced <font color='green'><b>[newCoins]</b></font> coins.</p>
		<p><A href="?src=\ref[src];makeCoins=[1]">Make coins</A></p>
	</body>
</html>
	"}
	user << browse(html, "window=mint")
	onclose(user, "mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing==1)
		to_chat(usr, "<span class='notice'>The machine is processing.</span>")
		return
	if(href_list["choose"])
		chosen = href_list["choose"]
	if(href_list["chooseAmt"])
		coinsToProduce = Clamp(coinsToProduce + text2num(href_list["chooseAmt"]), 0, 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		if (src.output)
			processing = 1
			icon_state = "coinpress1"
			//var/obj/item/weapon/storage/bag/money/M
			var/datum/material/po=materials.getMaterial(chosen)
			if(!po)
				chosen=null
				processing=0
				return
			while(materials.storage[chosen] > 0 && coinsToProduce > 0)
			/*	if (locate(/obj/item/weapon/storage/bag/money,output.loc))
					M = locate(/obj/item/weapon/storage/bag/money,output.loc)
					if(M.can_be_inserted(po.cointype, 1))
						new po.cointype(M)
					else
						new po.cointype(output.loc)
				else
				//Can't seem to be able to get the can_be_inserted check to work, would always drop the coin at the output loc
				*/
					//M = new/obj/item/weapon/storage/bag/money(output.loc)
				new po.cointype(output.loc)
				materials.removeAmount(chosen, 1)
				coinsToProduce--
				newCoins++
				src.updateUsrDialog()
				sleep(5)
			icon_state = "coinpress0"
			processing = 0
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
