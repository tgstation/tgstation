/**********************Mint**************************/

/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/list/ore = list()

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

		for(var/oredata in typesof(/datum/material) - /datum/material)
			var/datum/material/ore_datum = new oredata
			// Only add ores that can be run through the minter.
			if(ore_datum.cointype)
				ore[ore_datum.id]=ore_datum

		processing_objects.Add(src)
		return
	return


/obj/machinery/mineral/mint/process()
	if ( src.input)
		var/obj/item/stack/sheet/O
		O = locate(/obj/item/stack/sheet, input.loc)
		if(O)
			for(var/ore_id in ore)
				var/datum/material/po =ore[ore_id]
				if (po.cointype && istype(O,po.sheettype))
					po.stored += 5 * O.amount // 100/20 = 5 coins per sheet.
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
	for(var/ore_id in ore)
		var/datum/material/ore_info=ore[ore_id]
		if(ore_info.stored && ore_info.cointype)
			html += {"
			<tr>
				<td class="clmName">[ore_info.processed_name]</td>
				<td>[ore_info.stored]</td>
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
			processing = 1
			icon_state = "coinpress1"
			var/obj/item/weapon/moneybag/M
			var/datum/material/po=ore[chosen]
			if(!po)
				chosen=null
				processing=0
				return
			while(po.stored > 0 && coinsToProduce > 0)
				if (locate(/obj/item/weapon/moneybag,output.loc))
					M = locate(/obj/item/weapon/moneybag,output.loc)
				else
					M = new/obj/item/weapon/moneybag(output.loc)
				new po.cointype(M)
				po.stored--
				ore[chosen]=po
				coinsToProduce--
				newCoins++
				src.updateUsrDialog()
				sleep(5)
			icon_state = "coinpress0"
			processing = 0
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return