var/list/shipping_categories = list("Clothing","Medical","Exports","Machinery","Misc","Weapons","Robotics","Materials")


/obj/machinery/computer/cargo_shipping
	name = "Shipping Price Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "oldcomp"
	icon_screen = "value_computer"
	icon_keyboard = "no_keyboard"
	var/current_category = "Clothing"

/obj/machinery/computer/cargo_shipping/attack_hand(var/mob/user)
	if(..())
		return
	user.machine = src
	var/css={"<style>
.company {
	font-weight: bold;
}
</style>"}
	var/dat = "<html><head><title>Market Prices</title>[css]</head><body><h2>Shipping</h2>"
	dat += "<b>WARNING:</b> Do <b>NOT</b> ship export products in crates, otherwise they're liable to get processed as donations to Central Command.<br>"
	dat += "<b>Stock Transaction Log:</b> <a href='?src=\ref[src];show_logs=1'>Check</a><br>"
	dat += "<b>Current Category:</b> [current_category]<br>"
	for(var/C in shipping_categories)
		dat += "<a href='?src=\ref[src];switch_category=[C]'>[C]</a>"
	dat += "<br>"
	for(var/D in SSshuttle.shipping_datums)
		var/datum/shipping/S = D
		if(S.category != current_category)
			continue
		dat += "<div><td><span class='company'>[S.name]</span></td><td>| [S.value] credits per unit |</td><td><b>Trend: [S.status]</b></td><br>"
		dat +="<td><span class='company'>Total Exported: </span>[S.amount_sold_total]</td><td>|<span class='company'>Total Profit: </span>[S.profit_made_total]</td></div><br>"
		if(S.allow_import)
			dat += "<span class='company'>Amount On Market: </span>[S.amount_on_market]<br>"
			dat += "<a href='?src=\ref[src];buy=\ref[S]'>Import</a><br>"
		dat += "---------------------------------------------------------------<br>"

	dat += "</body></html>"
	var/datum/browser/popup = new(user, "computer", "Export Computer", 600, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/cargo_shipping/Topic(href, href_list)
	if (..())
		return 1

	if (href_list["show_logs"])
		var/dat = "<html><head><title>Shipping Logs</title></head><body><h2>Shipping Logs</h2><div><a href='?src=\ref[src];show_logs=1'>Refresh</a></div><br>"
		for(var/D in SSshuttle.shipping_logs)
			var/datum/shipping_log/L = D
			if(istype(L, /datum/shipping_log/export))
				dat += "[L.time] | Exported <b>[L.amount_sold]</b> units of <b>[L.item_name]</b> for <b>[L.profit_per_unit]</b> credits per unit.<br>"
			if(istype(L, /datum/shipping_log/import))
				dat += "[L.time] | [L.user] imported <b>[L.amount_imported]</b> units of <b>[L.item_name]</b> for <b>[L.cost_per_unit]</b> credits per unit.<br>"
		var/datum/browser/popup = new(usr, "shipping_logs", "Shipping Logs", 600, 400)
		popup.set_content(dat)
		popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
	if (href_list["buy"])
		var/datum/shipping/S = locate(href_list["buy"])
		if (S)
			buy_object(S, usr)
	if (href_list["switch_category"])
		var/C = href_list["switch_category"]
		if (C)
			current_category = C


	src.add_fingerprint(usr)
	src.updateUsrDialog()

/obj/machinery/computer/cargo_shipping/proc/buy_object(var/datum/shipping/S, mob/user)
	var/avail = S.amount_on_market
	var/price = S.value
	var/canbuy = round(SSshuttle.points / price)
	if(canbuy > 50)
		canbuy = 50
	var/amt = round(input(user, "How many do you want to purchase? (Available: [avail], unit price: [price], can buy: [canbuy])", "Import", 0) as num|null)
	if (!user)
		return
	if (!amt)
		return
	if(amt > avail)
		user << "<span class='danger'>There isn't enough for you to import that many!</span>"
		return
	if (!(user in range(1, src)))
		return
	if (amt > 50)
		user << "<span class='danger'>You cannot buy more than 50 at once!</span>"
		return
	var/total = amt * S.value
	if (total > SSshuttle.points)
		user << "<span class='danger'>Insufficient credits.</span>"
		return
	var/P
	P = input(user, "Select a pad to import to", "Import", P) in shipping_pads
	if(!P)
		return
	S.buy_obj(amt, P)
	user << "<span class='notice'>Bought [amt] of [S.name] for [total] credits.</span>"
	SSshuttle.add_import_logs(S, amt, total, user)