/obj/machinery/computer/stockexchange
	name = "stock exchange computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "oldcomp"
	icon_screen = "stock_computer"
	icon_keyboard = "no_keyboard"
	var/logged_in = "Cargo Department"
	var/vmode = 0

/obj/machinery/computer/stockexchange/New()
	..()
	logged_in = "[world.name] Cargo Department"

/obj/machinery/computer/stockexchange/proc/balance()
	if (!logged_in)
		return 0
	return SSshuttle.points

/obj/machinery/computer/stockexchange/attack_hand(var/mob/user)
	if(..())
		return
	user.machine = src

	var/css={"<style>
.company {
	font-weight: bold;
}
.stable {
	width: 100%
	border: 1px solid black;
	border-collapse: collapse;
}
.stable tr {
	border: none;
}
.stable td, .stable th {
	border-right: 1px solid white;
	border-bottom: 1px solid black;
}
a.updated {
	color: red;
}
</style>"}
	var/dat = "<html><head><title>[station_name()] Stock Exchange</title>[css]</head><body><h2>Stock Exchange</h2>"
	dat += "<i>This is a work in progress. Certain features may not be available.</i><br>"

	dat += "<span class='user'>Welcome, <b>[logged_in]</b></span><br><span class='balance'><b>Cargo Points:</b> [balance()] points</span><br>"
	for (var/datum/stock/S in stockExchange.last_read)
		var/list/LR = stockExchange.last_read[S]
		if (!(logged_in in LR))
			LR[logged_in] = 0
	dat += "<b>View mode:</b> <a href='?src=\ref[src];cycleview=1'>[vmode ? "compact" : "full"]</a>"
	dat += "<b>Stock Transaction Log:</b> <a href='?src=\ref[src];show_logs=1'>Check</a>"
	dat += "<h3>Listed stocks</h3>"

	if (vmode == 0)
		for (var/datum/stock/S in stockExchange.stocks)
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
			dat += "<br><b>Borrow options:</b><br>"
			if (S.borrow_brokers.len)
				for (var/datum/borrow/B in S.borrow_brokers)
					dat += "<b>[B.broker]</b> offers <i>[B.share_amount] shares</i> for borrowing, for a deposit of <i>[B.deposit * 100]%</i> of the shares' value.<br>"
					dat += "The broker expects the return of the shares after <i>[B.lease_time / 600] minutes</i>, with a grace period of <i>[B.grace_time / 600]</i> minute(s).<br>"
					dat += "<i>This offer expires in [(B.offer_expires - world.time) / 600] minutes.</i><br>"
					dat += "<b>Note:</b> If you do not return all shares by the end of the grace period, you will lose your deposit and the value of all unreturned shares at current value from your account!<br>"
					dat += "<b>Note:</b> You cannot withdraw or transfer money off your account while a borrow is active.<br>"
					dat += "<a href='?src=\ref[src];take=\ref[B]'>Take offer</a> (Estimated deposit: [B.deposit * S.current_value * B.share_amount] credits)<br><br>"
			else
				dat += "<i>No borrow options available</i><br><br>"
			for (var/datum/borrow/B in S.borrows)
				if (B.borrower == logged_in)
					dat += "You are borrowing <i>[B.share_amount] shares</i> from <b>[B.broker]</b>.<br>"
					dat += "Your deposit riding on the deal is <i>[B.deposit] credits</i>.<br>"
					if (world.time < B.lease_expires)
						dat += "You are expected to return the borrowed shares in [(B.lease_expires - world.time) / 600] minutes.<br><br>"
					else
						dat += "The brokering agency is collecting. You still owe them <i>[B.share_debt]</i> shares, which you have [(B.grace_expires - world.time) / 600] minutes to present.<br><br>"
			var/news = 0
			if (logged_in)
				var/list/LR = stockExchange.last_read[S]
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
		dat += "<table class='stable'><tr><th>&nbsp;</th><th>Name</th><th>Value</th><th>Owned/Avail</th><th>Actions</th></tr>"
		for (var/datum/stock/S in stockExchange.stocks)
			var/mystocks = 0
			if (logged_in && (logged_in in S.shareholders))
				mystocks = S.shareholders[logged_in]
			dat += "<tr><td>[S.disp_value_change > 0 ? "+" : (S.disp_value_change < 0 ? "-" : "=")]</td><td><span class='company'>[S.name] "
			if (S.bankrupt)
				dat += "<b style='color:red'>B</b>"
			dat += "</span> <span class='s_company'>([S.short_name])</span></td><td>[S.current_value]</td><td><b>[mystocks]</b>/[S.available_shares]</td>"
			var/news = 0
			if (logged_in)
				var/list/LR = stockExchange.last_read[S]
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
				dat += "+ - "
			else
				dat += "<a href='?src=\ref[src];buyshares=\ref[S]'>+</a> <a href='?src=\ref[src];sellshares=\ref[S]'>-</a> "
			dat += "<a href='?src=\ref[src];archive=\ref[S]' class='[news ? "updated" : "default"]'>(A)</a> <a href='?src=\ref[src];viewhistory=\ref[S]'>(H)</a></td></tr>"
	dat += "</body></html>"
	var/datum/browser/popup = new(user, "computer", "Stock Exchange", 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/stockexchange/proc/sell_some_shares(var/datum/stock/S, var/mob/user)
	if (!user || !S)
		return
	var/li = logged_in
	if (!li)
		user << "<span class='danger'>No active account on the console!</span>"
		return
	var/b = SSshuttle.points
	var/avail = S.shareholders[logged_in]
	if (!avail)
		user << "<span class='danger'>This account does not own any shares of [S.name]!</span>"
		return
	var/price = S.current_value
	var/amt = round(input(user, "How many shares? (Have: [avail], unit price: [price])", "Sell shares in [S.name]", 0) as num|null)
	if (!user)
		return
	if (!amt)
		return
	if (!(user in range(1, src)))
		return
	if (li != logged_in)
		return
	b = SSshuttle.points
	if (!isnum(b))
		user << "<span class='danger'>No active account on the console!</span>"
		return
	if (amt > S.shareholders[logged_in])
		user << "<span class='danger'>You do not own that many shares!</span>"
		return
	var/total = amt * S.current_value
	if (!S.sellShares(logged_in, amt))
		user << "<span class='danger'>Could not complete transaction.</span>"
		return
	user << "<span class='notice'>Sold [amt] shares of [S.name] at [S.current_value] a share for [total] points.</span>"
	stockExchange.add_log(/datum/stock_log/sell, user.name, S.name, amt, S.current_value, total)

/obj/machinery/computer/stockexchange/proc/buy_some_shares(var/datum/stock/S, var/mob/user)
	if (!user || !S)
		return
	var/li = logged_in
	if (!li)
		user << "<span class='danger'>No active account on the console!</span>"
		return
	var/b = balance()
	if (!isnum(b))
		user << "<span class='danger'>No active account on the console!</span>"
		return
	var/avail = S.available_shares
	var/price = S.current_value
	var/canbuy = round(b / price)
	var/amt = round(input(user, "How many shares? (Available: [avail], unit price: [price], can buy: [canbuy])", "Buy shares in [S.name]", 0) as num|null)
	if (!user)
		return
	if (!amt)
		return
	if (!(user in range(1, src)))
		return
	if (li != logged_in)
		return
	b = balance()
	if (!isnum(b))
		user << "<span class='danger'>No active account on the console!</span>"
		return
	if (amt > S.available_shares)
		user << "<span class='danger'>That many shares are not available!</span>"
		return
	var/total = amt * S.current_value
	if (total > b)
		user << "<span class='danger'>Insufficient points.</span>"
		return
	if (!S.buyShares(logged_in, amt))
		user << "<<span class='danger'>Could not complete transaction.</span>"
		return
	user << "<span class='notice'>Bought [amt] shares of [S.name] at [S.current_value] a share for [total] points.</span>"
	stockExchange.add_log(/datum/stock_log/buy, user.name, S.name, amt, S.current_value,  total)

/obj/machinery/computer/stockexchange/proc/do_borrowing_deal(var/datum/borrow/B, var/mob/user)
	if (B.stock.borrow(B, logged_in))
		user << "<span class='notice'>You successfully borrowed [B.share_amount] shares. Deposit: [B.deposit].</span>"
		stockExchange.add_log(/datum/stock_log/borrow, user.name, B.stock.name, B.share_amount, B.deposit)
	else
		user << "<span class='danger'>Could not complete transaction. Check your account balance.</span>"

/obj/machinery/computer/stockexchange/Topic(href, href_list)
	if (..())
		return 1

	if (usr in range(1, src))
		usr.machine = src

	if (href_list["viewhistory"])
		var/datum/stock/S = locate(href_list["viewhistory"])
		if (S)
			S.displayValues(usr)

	if (href_list["logout"])
		logged_in = null

	if (href_list["buyshares"])
		var/datum/stock/S = locate(href_list["buyshares"])
		if (S)
			buy_some_shares(S, usr)

	if (href_list["sellshares"])
		var/datum/stock/S = locate(href_list["sellshares"])
		if (S)
			sell_some_shares(S, usr)

	if (href_list["take"])
		var/datum/borrow/B = locate(href_list["take"])
		if (B && !B.lease_expires)
			do_borrowing_deal(B, usr)

	if (href_list["show_logs"])
		var/dat = "<html><head><title>Stock Transaction Logs</title></head><body><h2>Stock Transaction Logs</h2><div><a href='?src=\ref[src];show_logs=1'>Refresh</a></div><br>"
		for(var/D in stockExchange.logs)
			var/datum/stock_log/L = D
			if(istype(L, /datum/stock_log/buy))
				dat += "[L.time] | <b>[L.user_name]</b> bought <b>[L.stocks]</b> stocks at [L.shareprice] a share for <b>[L.money]</b> total credits in <b>[L.company_name]</b>.<br>"
				continue
			if(istype(L, /datum/stock_log/sell))
				dat += "[L.time] | <b>[L.user_name]</b> sold <b>[L.stocks]</b> stocks at [L.shareprice] a share for <b>[L.money]</b> totalcredits from <b>[L.company_name]</b>.<br>"
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
			var/list/LR = stockExchange.last_read[S]
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
