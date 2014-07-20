/obj/machinery/computer/merch
	name = "Merch Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "comm_logs"
	circuit = "/obj/item/weapon/circuitboard/merch"

	l_color = "#50AB00"

/obj/item/weapon/circuitboard/merch
	name = "\improper Merchandise Computer Circuitboard"
	build_path = /obj/machinery/computer/merch

/obj/machinery/computer/merch/New()
	..()

/obj/machinery/computer/merch/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/merch/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/merch/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	var/balance=0
	if(user.mind)
		if(user.mind.initial_account)
			balance = user.mind.initial_account.money

	var/dat = {"
<html>
	<head>
		<title>[command_name()] Merchandise</title>
		<style type="text/css">
* {
	font-family:sans-serif;
	font-size:x-small;
}
html {
	background:#333;
	color:#999;
}

a {
	color:#cfcfcf;
	text-decoration:none;
	font-weight:bold;
}

a:hover {
	color:#ffffff;
}
tr {
	background:#303030;
	border-radius:6px;
	margin-bottom:0.5em;
	border-bottom:1px solid black;
}
tr:nth-child(even) {
	background:#3f3f3f;
}

td.cost {
	font-size:20pt;
	font-weight:bold;
}

td.cost.affordable {
	background:green;
}

td.cost.toomuch {
	background:maroon;
}


		</style>
	</head>
	<body>
	<p style="float:right"><a href='byond://?src=\ref[src];refresh=1'>Refresh</a> | <b>Balance:</b> $[balance]</p>
	<h1>[command_name()] Merchandise</h1>
	<p>
		<b>Doing your job and not getting any recognition at work?</b>  Well, welcome to the
		merch shop!  Here, you can buy cool things in exchange for money you earn when you've
		completed your Job Objectives.
	</p>
	<p>Work hard. Get cash. Acquire bragging rights.</p>
	<h2>In Stock:</h2>
	<table cellspacing="0" cellpadding="0">
		<thead>
			<th>#</th>
			<th>Name/Description</th>
			<th>Price</th>
		</thead>
		<tbody>
	"}
	for(var/datum/storeitem/item in centcomm_store.items)
		var/cost_class="affordable"
		if(item.cost>balance)
			cost_class="toomuch"
		var/itemID=centcomm_store.items.Find(item)
		dat += {"
			<tr>
				<th>
					[itemID]
				</th>
				<td>
					<p><b>[item.name]</b></p>
					<p>[item.desc]</p>
				</td>
				<td class="cost [cost_class]">
					<a href="byond://?src=\ref[src];buy=[itemID]">$[item.cost]</a>
				</td>
			</tr>
		"}
	dat += {"
		</tbody>
	</table>
	</body>
</html>"}
	user << browse(dat, "window=merch")
	onclose(user, "merch")
	return

/obj/machinery/computer/merch/Topic(href, href_list)
	if(..())
		return

	//testing(href)

	src.add_fingerprint(usr)

	if (href_list["buy"])
		var/itemID = text2num(href_list["buy"])
		var/datum/storeitem/item = centcomm_store.items[itemID]
		var/sure = alert(usr,"Are you sure you wish to purchase [item.name] for $[item.cost]?","You sure?","Yes","No") in list("Yes","No")
		if(sure=="No")
			updateUsrDialog()
			return
		if(!centcomm_store.PlaceOrder(usr,itemID))
			usr << "\red Unable to charge your account."
		else
			usr << "\blue You've successfully purchased the item.  It should be in your hands or on the floor."
	src.updateUsrDialog()
	return

/obj/machinery/computer/merch/update_icon()

	if(stat & BROKEN)
		icon_state = "comm_logs0"
	else
		if(stat & NOPOWER)
			src.icon_state = "comm_logs"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
