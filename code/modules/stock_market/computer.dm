/obj/machinery/computer/stockexchange
	name = "stock exchange computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "oldcomp"
	icon_screen = "stock_computer"
	icon_keyboard = "no_keyboard"
	var/logged_in = "Cargo Department"
	var/vmode = 1
	circuit = /obj/item/circuitboard/computer/stockexchange
	clockwork = TRUE //it'd look weird

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/stockexchange/Initialize()
	. = ..()
	logged_in = "[station_name()] Cargo Department"

/obj/machinery/computer/stockexchange/proc/balance()
	if (!logged_in)
		return 0
	return SSshuttle.points

/obj/machinery/computer/stockexchange/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/stockexchange/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/computer/stockexchange/attack_hand(var/mob/user)
	if(..())
		return
	user.machine = src

	var/css={"<style>
.change {
	font-weight: bold;
	font-family: monospace;
}
.up {
	background: #00a000;
}
.down {
	background: #a00000;
}
.stable {
	width: 100%
	border-collapse: collapse;
	border: 1px solid #305260;
	border-spacing: 4px 4px;
}
.stable td, .stable th {
	border: 1px solid #305260;
	padding: 0px 3px;
}
.bankrupt {
	border: 1px solid #a00000;
	background: #a00000;
}

a.updated {
	color: red;
}
</style>"}
	var/dat = "<html><head><title>[station_name()] Stock Exchange</title>[css]</head><body>"

	dat += "<span class='user'>Welcome, <b>[logged_in]</b></span><br><span class='balance'><b>Credits:</b> [balance()] </span><br>"
	for (var/datum/stock/S in GLOB.stockExchange.last_read)
		var/list/LR = GLOB.stockExchange.last_read[S]
		if (!(logged_in in LR))
			LR[logged_in] = 0
	dat += "<b>View mode:</b> <a href='?src=\ref[src];cycleview=1'>[vmode ? "Compact" : "Full"]</a> "
	dat += "<b>Stock Transaction Log:</b> <a href='?src=\ref[src];show_logs=1'>Check</a><br>"

	dat += "<i>This is a work in progress. Certain features may not be available.</i>"

	dat += "<h3>Listed stocks</h3>"

	if (vmode == 0)
		for (var/datum/stock/S in GLOB.stockExchange.stocks)
			var/mystocks = 0
			if (logged_in && (logged_in in S.shareholders))
				mystocks = S.shareholders[logged_in]
			dat += "<hr /><div class='stock'><span class='company'>[S.name]</span> <span class='s_company'>([S.short_name])</span>[S.bankrupt ? " <b style='color:red'>BANKRUPT</b>" : null]<br>"
			if (S.last_unification)
				dat += "<b>Unified shares</b> [(world.time - S.last_unification) / 600] minutes ago.<br>"
			dat += "<b>Current value per share:</b> [S.current_value] | <a href='?src=\ref[src];viewhistory=\ref[S]'>View history</a><br><br>"
			dat += "You currently own <b>[mystocks]</b> shares in this company. There are [S.available_shares] purchasable shares on the market currently.<br>"
			if (S.bankrupt)
				dat += "You cannot buy or sell shares in a bankrupt company!<br><br>"
			else
				dat += "<a href='?src=\ref[src];buyshares=\ref[S]'>Buy shares</a> | <a href='?src=\ref[src];sellshares=\ref[S]'>Sell shares</a><br><br>"
			dat += "<b>Prominent products:</b><br>"
			for (var/prod in S.products)
				dat += "<i>[prod]</i><br>"
			var/news = 0
			if (logged_in)
				var/list/LR = GLOB.stockExchange.last_read[S]
				var/lrt = LR[logged_in]
				for (var/datum/article/A in S.articles)
					if (A.ticks > lrt)
						news = 1
						break
				if (!news)
					for (var/datum/stockEvent/E in S.events)
						if (E.last_change > lrt && !E.hidden)
							news = 1
							break
			dat += "<a href='?src=\ref[src];archive=\ref[S]'>View news archives</a>[news ? " <span style='color:red'>(updated)</span>" : null]</div>"
	else if (vmode == 1)
		dat += "<b>Actions:</b> + Buy, - Sell, (A)rchives, (H)istory<br><br>"
		dat += "<table class='stable'>"
		dat += "<tr><th>&nbsp;</th><th>ID</th><th>Name</th><th>Value</th><th>Owned</th><th>Avail</th><th>Actions</th></tr>"

		for (var/datum/stock/S in GLOB.stockExchange.stocks)
			var/mystocks = 0
			if (logged_in && (logged_in in S.shareholders))
				mystocks = S.shareholders[logged_in]

			if(S.bankrupt)
				dat += "<tr class='bankrupt'>"
			else
				dat += "<tr>"

			if(S.disp_value_change > 0)
				dat += "<td class='change up'>+</td>"
			else if(S.disp_value_change < 0)
				dat += "<td class='change down'>-</td>"
			else
				dat += "<td class='change'>=</td>"

			dat += "<td><b>[S.short_name]</b></td>"
			dat += "<td>[S.name]</td>"

			if(!S.bankrupt)
				dat += "<td>[S.current_value]</td>"
			else
				dat += "<td>0</td>"

			if(mystocks)
				dat += "<td><b>[mystocks]</b></td>"
			else
				dat += "<td>0</td>"

			dat += "<td>[S.available_shares]</td>"
			var/news = 0
			if (logged_in)
				var/list/LR = GLOB.stockExchange.last_read[S]
				var/lrt = LR[logged_in]
				for (var/datum/article/A in S.articles)
					if (A.ticks > lrt)
						news = 1
						break
				if (!news)
					for (var/datum/stockEvent/E in S.events)
						if (E.last_change > lrt && !E.hidden)
							news = 1
							break
			dat += "<td>"
			if (S.bankrupt)
				dat += "<span class='linkOff'>+</span> <span class='linkOff'>-</span> "
			else
				dat += "<a href='?src=\ref[src];buyshares=\ref[S]'>+</a> <a href='?src=\ref[src];sellshares=\ref[S]'>-</a> "
			dat += "<a href='?src=\ref[src];archive=\ref[S]' class='[news ? "updated" : "default"]'>(A)</a> <a href='?src=\ref[src];viewhistory=\ref[S]'>(H)</a></td>"

			dat += "</tr>"

		dat += "</table>"

	dat += "</body></html>"
	var/datum/browser/popup = new(user, "computer", "Stock Exchange", 600, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/stockexchange/proc/sell_some_shares(var/datum/stock/S, var/mob/user)
	if (!user || !S)
		return
	var/li = logged_in
	if (!li)
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return
	var/b = SSshuttle.points
	var/avail = S.shareholders[logged_in]
	if (!avail)
		to_chat(user, "<span class='danger'>This account does not own any shares of [S.name]!</span>")
		return
	var/price = S.current_value
	var/amt = round(input(user, "How many shares? \n(Have: [avail], unit price: [price])", "Sell shares in [S.name]", 0) as num|null)
	amt = min(amt, S.shareholders[logged_in])

	if (!user || (!(user in range(1, src)) && iscarbon(user)))
		return
	if (!amt)
		return
	if (li != logged_in)
		return
	b = SSshuttle.points
	if (!isnum(b))
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return

	var/total = amt * S.current_value
	if (!S.sellShares(logged_in, amt))
		to_chat(user, "<span class='danger'>Could not complete transaction.</span>")
		return
	to_chat(user, "<span class='notice'>Sold [amt] shares of [S.name] at [S.current_value] a share for [total] credits.</span>")
	GLOB.stockExchange.add_log(/datum/stock_log/sell, user.name, S.name, amt, S.current_value, total)

/obj/machinery/computer/stockexchange/proc/buy_some_shares(var/datum/stock/S, var/mob/user)
	if (!user || !S)
		return
	var/li = logged_in
	if (!li)
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return
	var/b = balance()
	if (!isnum(b))
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return
	var/avail = S.available_shares
	var/price = S.current_value
	var/canbuy = round(b / price)
	var/amt = round(input(user, "How many shares? \n(Available: [avail], unit price: [price], can buy: [canbuy])", "Buy shares in [S.name]", 0) as num|null)
	if (!user || (!(user in range(1, src)) && iscarbon(user)))
		return
	if (li != logged_in)
		return
	b = balance()
	if (!isnum(b))
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return

	amt = min(amt, S.available_shares, round(b / S.current_value))
	if (!amt)
		return
	if (!S.buyShares(logged_in, amt))
		to_chat(user, "<span class='danger'>Could not complete transaction.</span>")
		return

	var/total = amt * S.current_value
	to_chat(user, "<span class='notice'>Bought [amt] shares of [S.name] at [S.current_value] a share for [total] credits.</span>")
	GLOB.stockExchange.add_log(/datum/stock_log/buy, user.name, S.name, amt, S.current_value,  total)

/obj/machinery/computer/stockexchange/proc/do_borrowing_deal(var/datum/borrow/B, var/mob/user)
	if (B.stock.borrow(B, logged_in))
		to_chat(user, "<span class='notice'>You successfully borrowed [B.share_amount] shares. Deposit: [B.deposit].</span>")
		GLOB.stockExchange.add_log(/datum/stock_log/borrow, user.name, B.stock.name, B.share_amount, B.deposit)
	else
		to_chat(user, "<span class='danger'>Could not complete transaction. Check your account balance.</span>")

/obj/machinery/computer/stockexchange/Topic(href, href_list)
	if (..())
		return 1

	if (!usr || (!(usr in range(1, src)) && iscarbon(usr)))
		usr.machine = src

	if (href_list["viewhistory"])
		var/datum/stock/S = locate(href_list["viewhistory"]) in GLOB.stockExchange.stocks
		if (S)
			S.displayValues(usr)

	if (href_list["logout"])
		logged_in = null

	if (href_list["buyshares"])
		var/datum/stock/S = locate(href_list["buyshares"]) in GLOB.stockExchange.stocks
		if (S)
			buy_some_shares(S, usr)

	if (href_list["sellshares"])
		var/datum/stock/S = locate(href_list["sellshares"]) in GLOB.stockExchange.stocks
		if (S)
			sell_some_shares(S, usr)

	if (href_list["show_logs"])
		var/dat = "<html><head><title>Stock Transaction Logs</title></head><body><h2>Stock Transaction Logs</h2><div><a href='?src=\ref[src];show_logs=1'>Refresh</a></div><br>"
		for(var/D in GLOB.stockExchange.logs)
			var/datum/stock_log/L = D
			if(istype(L, /datum/stock_log/buy))
				dat += "[L.time] | <b>[L.user_name]</b> bought <b>[L.stocks]</b> stocks at [L.shareprice] a share for <b>[L.money]</b> total credits in <b>[L.company_name]</b>.<br>"
				continue
			if(istype(L, /datum/stock_log/sell))
				dat += "[L.time] | <b>[L.user_name]</b> sold <b>[L.stocks]</b> stocks at [L.shareprice] a share for <b>[L.money]</b> total credits from <b>[L.company_name]</b>.<br>"
				continue
			if(istype(L, /datum/stock_log/borrow))
				dat += "[L.time] | <b>[L.user_name]</b> borrowed <b>[L.stocks]</b> stocks with a deposit of <b>[L.money]</b> credits in <b>[L.company_name]</b>.<br>"
				continue
		var/datum/browser/popup = new(usr, "stock_logs", "Stock Transaction Logs", 600, 400)
		popup.set_content(dat)
		popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()

	if (href_list["archive"])
		var/datum/stock/S = locate(href_list["archive"])
		if (logged_in && logged_in != "")
			var/list/LR = GLOB.stockExchange.last_read[S]
			LR[logged_in] = world.time
		var/dat = "<html><head><title>News feed for [S.name]</title></head><body><h2>News feed for [S.name]</h2><div><a href='?src=\ref[src];archive=\ref[S]'>Refresh</a></div>"
		dat += "<div><h3>Events</h3>"
		var/p = 0
		for (var/datum/stockEvent/E in S.events)
			if (E.hidden)
				continue
			if (p > 0)
				dat += "<hr>"
			dat += "<div><b style='font-size:1.25em'>[E.current_title]</b><br>[E.current_desc]</div>"
			p++
		dat += "</div><hr><div><h3>Articles</h3>"
		p = 0
		for (var/datum/article/A in S.articles)
			if (p > 0)
				dat += "<hr>"
			dat += "<div><b style='font-size:1.25em'>[A.headline]</b><br><i>[A.subtitle]</i><br><br>[A.article]<br>- [A.author], [A.spacetime] (via <i>[A.outlet]</i>)</div>"
			p++
		dat += "</div></body></html>"
		var/datum/browser/popup = new(usr, "archive_[S.name]", "Stock News", 600, 400)
		popup.set_content(dat)
		popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()

	if (href_list["cycleview"])
		vmode++
		if (vmode > 1)
			vmode = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
