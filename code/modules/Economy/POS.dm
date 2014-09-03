/************************
* Point Of Sale
*
* Takes cash or credit.
*************************/

/line_item
	parent_type = /datum

	var/name = ""
	var/price = 0 // Per unit
	var/units = 0

var/global/current_pos_id = 1
var/global/pos_sales = 0

var/const/RECEIPT_HEADER = {"<html>
	<head>
		<style type="text/css">
			html {
				font-family: monospace;
			}

			table {
				margin: auto;
				margin-top: 1em;
				border-collapse: collapse;
			}
			th, td {
				padding: 1px;
				margin: 0;
			}
			td,
			tr.first th {
				border-left: 1px solid #ccc;
			}
			tr.first th.first {
				border-left: none;
			}
			tr.even td,
			tr.even th {
				background: #f0f0f0;
			}
			tr.calculated {
				font-style: italic;
			}
			tr.calculated td {
				border-top: 1px solid #000;
				border-left: 1px solid #ccc;
				background: #fefefe;
			}
			tr.total {
				font-weight: bold
			}
			tr.total td {
				border-top: 1px solid #000;
				background: #dfdfdf;
			}

		</style>
	</head>
	<body>
"}
var/const/POS_HEADER = {"<html>
	<head>
		<style type="text/css">
			* {
				font-family: sans-serif;
				font-size: small;
			}

			table {
				margin: auto;
				margin-top: 1em;
				border-collapse: collapse;
			}
			th, td {
				padding: 1px;
				margin: 0;
			}
			td,
			tr.first th {
				border-left: 1px solid #ccc;
			}
			tr.first th.first {
				border-left: none;
			}
			tr.even td,
			tr.even th {
				background: #f0f0f0;
			}
			tr.calculated {
				font-style: italic;
			}
			tr.calculated td {
				border-top: 1px solid #000;
				border-left: 1px solid #ccc;
				background: #fefefe;
			}
			tr.total {
				font-weight: bold
			}
			tr.total td {
				border-top: 1px solid #000;
				background: #dfdfdf;
			}

		</style>
	</head>
	<body>
"}

#define POS_TAX_RATE 0.10 // 10%

#define POS_SCREEN_LOGIN    0
#define POS_SCREEN_ORDER    1
#define POS_SCREEN_FINALIZE 2
#define POS_SCREEN_PRODUCTS 3
#define POS_SCREEN_IMPORT   4
#define POS_SCREEN_EXPORT   5
#define POS_SCREEN_SETTINGS 6
/obj/machinery/pos
	icon = 'icons/obj/machines/pos.dmi'
	icon_state = "pos"
	density = 0
	name = "point of sale"
	desc = "Also known as a cash register, or, more commonly, \"robbery magnet\"."

	var/id = 0
	var/sales = 0
	var/department
	var/mob/logged_in
	var/datum/money_account/linked_account

	var/credits_held = 0
	var/credits_needed = 0

	var/list/products = list() // name = /line_item
	var/list/line_items = list() // # = /line_item

	var/screen=POS_SCREEN_LOGIN

/obj/machinery/pos/New()
	..()
	id = current_pos_id++
	if(department)
		linked_account = department_accounts[department]
	else
		linked_account = station_account
	update_icon()

/obj/machinery/pos/proc/AddToOrder(var/name, var/units)
	if(!(name in products))
		return 0
	var/line_item/LI = products[name]
	var/line_item/LIC = new
	LIC.name=LI.name
	LIC.price=LI.price
	LIC.units=units
	line_items.Add(LIC)

/obj/machinery/pos/proc/RemoveFromOrder(var/order_id)
	line_items.Cut(order_id,order_id+1)

/obj/machinery/pos/proc/NewOrder()
	line_items.Cut()

/obj/machinery/pos/proc/PrintReceipt(var/order_id)
	var/receipt = {"[RECEIPT_HEADER]<div>POINT OF SALE #[id]<br />
			Paying to: [linked_account.owner_name]<br />
			Cashier: [logged_in]<br />"}

	receipt += areaMaster.name
	receipt += "</div>"
	receipt += {"<br />
		<div>[worldtime2text()], [current_date_string]</div>
		<table>
			<tr class=\"first\">
				<th class=\"first\">Item</th>
				<th>Amount</th>
				<th>Unit Price</th>
				<th>Line Total</th>
			</tr>"}
	var/subtotal=0
	for(var/i=1;i<=line_items.len;i++)
		var/line_item/LI = line_items[i]
		var/linetotal=LI.units*LI.price
		receipt += "<tr class=\"[(i%2)?"even":"odd"]\"><th>[LI.name]</th><td>[LI.units]</td><td>$[num2septext(LI.price)]</td><td>$[num2septext(linetotal)]</td></tr>"
		subtotal += linetotal
	var/taxes = POS_TAX_RATE*subtotal
	receipt += {"
		<tr class="calculated">
			<th colspan="3">SUBTOTAL</th><td>$[num2septext(subtotal)]</td>
		</tr>
		<tr>
			<th colspan="3">TAXES</th><td>$[num2septext(taxes)]</td>
		</tr>"}
	receipt += {"
		<tr class="calculated total">
			<th colspan="3">TOTAL</th><td>$[num2septext(taxes+subtotal)]</th>
		</tr>"}
	receipt += "</table></body></html>"

	var/obj/item/weapon/paper/P = new(loc)
	P.name="Receipt #[id]-[++sales]"
	P.info=receipt

	P = new(loc)
	P.name="Receipt #[id]-[sales] (Cashier Copy)"
	P.info=receipt


/obj/machinery/pos/proc/LoginScreen()
	return "<center><b>Please swipe ID to log in.</b></center>"

/obj/machinery/pos/proc/OrderScreen()
	var/receipt = {"<fieldset>
		<legend>POS Info</legend>
			POINT OF SALE #[id]<br />
			Paying to: [linked_account.owner_name]<br />
			Cashier: [logged_in]<br />"}

	receipt += areaMaster.name
	receipt += "</fieldset>"
	receipt += {"<fieldset><legend>Order Data</legend>
		<form action="?src=\ref[src]" method="get">
		<input type="hidden" name="src" value="\ref[src]" />
		<table>
			<tr class=\"first\">
				<th class=\"first\">Item</th>
				<th>Amount</th>
				<th>Unit Price</th>
				<th>Line Total</th>
				<th>...</th>
			</tr>"}
	var/subtotal=0
	if(line_items.len>0)
		for(var/i=1;i<=line_items.len;i++)
			var/line_item/LI = line_items[i]
			var/linetotal=LI.units*LI.price
			receipt += {"<tr class=\"[(i%2)?"even":"odd"]\">
				<th>[LI.name]</th>
				<td><a href="?src=\ref[src];setunits=[i]">[LI.units]</a></td>
				<td>$[num2septext(LI.price)]</td>
				<td>$[num2septext(linetotal)]</td>
				<td><a href="?src=\ref[src];removefromorder=[i]" style="color:red;">&times;</a></td>
			</tr>"}
			subtotal += linetotal
	var/taxes = POS_TAX_RATE*subtotal
	var/presets = "<i>(No presets available)</i>"
	if(products.len>0)
		presets = {"<select name="preset">""}
		for(var/pid in products)
			var/line_item/product = products[pid]
			presets += {"<option value="[pid]">[product.name]</option>"}
		presets += "</select>"
	receipt += {"
		<tr>
			<td class="first">[presets]</td>
			<td><input type="textbox" name="units" value="1.0" /> units</td>
			<td colspan="2"><input type="submit" name="act" value="Add to Order" /></td>
		</tr>
		<tr class="calculated">
			<th colspan="3">SUBTOTAL</th><td>$[num2septext(subtotal)]</td>
		</tr>
		<tr>
			<th colspan="3">TAXES</th><td>$[num2septext(taxes)]</td>
		</tr>"}
	receipt += {"
		<tr class="calculated total">
			<th colspan="3">TOTAL</th><td>$[num2septext(taxes+subtotal)]</th>
		</tr>"}
	receipt += {"</table>
		<input type="submit" name="act" value="Finalize Sale" />
		<input type="submit" name="act" value="Reset" />
		</form>
	</fieldset>"}
	return receipt

/obj/machinery/pos/proc/ProductsScreen()
	var/dat={"<fieldset><legend>Product List</legend>
		<form action="?src=\ref[src]" method="get">
		<input type="hidden" name="src" value="\ref[src]" />
		<table>
			<tr class=\"first\">
				<th class=\"first\">Item</th>
				<th>Unit Price</th>
				<th># Sold</th>
				<th>...</th>
			</tr>"}
	for(var/i in products)
		var/line_item/LI = products[i]
		dat += {"<tr class=\"[(i%2)?"even":"odd"]\">
			<th><a href="?src=\ref[src];setpname=[i]">[LI.name]</a></th>
			<td><a href="?src=\ref[src];setprice=[i]">$[num2septext(LI.price)]</a></td>
			<td>[LI.units]</td>
			<td><a href="?src=\ref[src];rmproduct=[i]" style="color:red;">&times;</a></td>
		</tr>"}
	dat += {"</table>
		<b>New Product:</b><br />
		<label for="name">Name:</label> <input type="textbox" name="name" value=""/><br />
		<label for="name">Price:</label> $<input type="textbox" name="price" value="0.00" /><br />
		<input type="submit" name="act" value="Add Product" /><br />
		<a href="?src=\ref[src];screen=[POS_SCREEN_IMPORT]">Import</a> | <a href="?src=\ref[src];screen=[POS_SCREEN_EXPORT]">Export</a>
		</form>
		</fieldset>"}
	return dat

/obj/machinery/pos/proc/ExportScreen()
	var/dat={"<fieldset><legend>Export Products as CSV</legend>
		<textarea>"}
	for(var/i in products)
		var/line_item/LI = products[i]
		dat += "[LI.name],[LI.price]\n"
	dat += {"</textarea>
		<a href="?src=\ref[src];screen=[POS_SCREEN_PRODUCTS]">OK</a>
		</fieldset>"}
	return dat

/obj/machinery/pos/proc/ImportScreen()
	var/dat={"<fieldset>
		<legend>Import Products as CSV</legend>
		<form action="?src=\ref[src]" method="get">
			<input type="hidden" name="src" value="\ref[src]" />
			<textarea name="csv"></textarea>
			<p>Data must be in the form of a CSV, with no headers or quotation marks.</p>
			<p>First column must be product names, second must be prices as an unformatted number (####.##)</p>
			<p>Deviations from this format will result in your import being rejected.</p>
			<input type="submit" name="act" value="Add Products" />
		</form>
		</fieldset>"}
	return dat

/obj/machinery/pos/proc/FinalizeScreen()
	return "<center><b>Waiting for Credit</b><br /><a href=\"?src=\ref[src];act=Reset\">Cancel</a></center>"

/obj/machinery/pos/proc/SettingsScreen()
	var/dat={"<form action="?src=\ref[src]" method="get">
		<input type="hidden" name="src" value="\ref[src]" />
		<fieldset>
			<legend>Account Settings</legend>
			<div>
				<b>Payable Account:</b> <input type="textbox" name="payableto" value="[linked_account.account_number]" />
			</div>
		</fieldset>
		<fieldset>
			<legend>Locality Settings</legend>
			<div>
				<b>Tax Rate:</b> <input type="textbox" name="taxes" value="[POS_TAX_RATE*100]" disabled="disabled" />% (LOCKED)
			</div>
		</fieldset>
		<input type="submit" name="act" value="Save Settings" />
		</form>"}
	return dat

/obj/machinery/pos/update_icon()
	overlays = 0
	if(stat & (NOPOWER|BROKEN)) return
	if(logged_in)
		overlays += "pos-working"
	else
		overlays += "pos-standby"

/obj/machinery/pos/attack_robot(var/mob/user)
	if(isMoMMI(user))
		return attack_hand(user)
	return ..()

/obj/machinery/pos/attack_hand(var/mob/user)
	user.set_machine(src)
	var/logindata=""
	if(logged_in)
		logindata={"<a href="?src=\ref[src];logout=1">[logged_in.name]</a>"}
	var/dat = POS_HEADER + {"
	<div class="navbar">
		[worldtime2text()], [current_date_string]<br />
		[logindata]
		<a href="?src=\ref[src];screen=[POS_SCREEN_ORDER]">Order</a> |
		<a href="?src=\ref[src];screen=[POS_SCREEN_PRODUCTS]">Products</a> |
		<a href="?src=\ref[src];screen=[POS_SCREEN_SETTINGS]">Settings</a>
	</div>"}
	switch(screen)
		if(POS_SCREEN_LOGIN)    dat += LoginScreen()
		if(POS_SCREEN_ORDER)    dat += OrderScreen()
		if(POS_SCREEN_FINALIZE) dat += FinalizeScreen()
		if(POS_SCREEN_PRODUCTS) dat += ProductsScreen()
		if(POS_SCREEN_EXPORT)   dat += ExportScreen()
		if(POS_SCREEN_IMPORT)   dat += ImportScreen()
		if(POS_SCREEN_SETTINGS) dat += SettingsScreen()

	dat += "</body></html>"
	// END AUTOFIX
	user << browse(dat, "window=pos")
	onclose(user, "pos")
	return

/obj/machinery/pos/proc/say(var/text)
	src.visible_message("\icon[src] <span class=\"notice\"><b>[name]</b> states, \"[text]\"</span>")

/obj/machinery/pos/Topic(var/href, var/list/href_list)
	if(..(href,href_list)) return
	if("logout" in href_list)
		if(alert(src, "You sure you want to log out?", "Confirm", "Yes", "No")!="Yes") return
		logged_in=null
		screen=POS_SCREEN_LOGIN
		update_icon()
		src.attack_hand(usr)
		return
	if(usr != logged_in)
		usr << "\red [logged_in.name] is already logged in.  You cannot use this machine until they log out."
		return
	if("act" in href_list)
		switch(href_list["act"])
			if("Reset")
				NewOrder()
				screen=POS_SCREEN_ORDER
			if("Finalize Sale")
				var/subtotal=0
				if(line_items.len>0)
					for(var/i=1;i<=line_items.len;i++)
						var/line_item/LI = line_items[i]
						subtotal += LI.units*LI.price
				var/taxes = POS_TAX_RATE*subtotal
				credits_needed=taxes+subtotal
				say("Your total is $[num2septext(credits_needed)].  Please insert credit chips or swipe your ID.")
				screen=POS_SCREEN_FINALIZE
			if("Add Product")
				var/line_item/LI = new
				LI.name=sanitize(href_list["name"])
				LI.price=text2num(href_list["price"])
				products["[products.len+1]"]=LI
			if("Add to Order")
				AddToOrder(href_list["preset"],text2num(href_list["units"]))
			if("Add Products")
				for(var/list/line in text2list(href_list["csv"],"\n"))
					var/list/cells = text2list(line,",")
					if(cells.len<2)
						usr << "\red The CSV must have at least two columns: Product Name, followed by Price (as a number)."
						src.attack_hand(usr)
						return
					var/line_item/LI = new
					LI.name=sanitize(cells[1])
					LI.price=text2num(cells[2])
					products["[products.len+1]"]=LI
			if("Export Products")
				screen=POS_SCREEN_EXPORT
			if("Import Products")
				screen=POS_SCREEN_IMPORT
			if("Save Settings")
				var/datum/money_account/new_linked_account = get_money_account(text2num(href_list["payableto"]),z)
				if(!new_linked_account)
					usr << "\red Unable to link new account."
				else
					linked_account = new_linked_account
				screen=POS_SCREEN_SETTINGS
	else if("screen" in href_list)
		screen=text2num(href_list["screen"])
	else if("rmproduct" in href_list)
		products.Remove(href_list["rmproduct"])
	else if("removefromorder" in href_list)
		RemoveFromOrder(text2num(href_list["removefromorder"]))
	else if("setunits" in href_list)
		var/lid = text2num(href_list["setunits"])
		var/newunits = input(usr,"Enter the units sold.") as num
		if(!newunits) return
		var/line_item/LI = line_items[lid]
		LI.units = newunits
		line_items[lid]=LI
	else if("setpname" in href_list)
		var/newtext = sanitize(input(usr,"Enter the product's name."))
		if(!newtext) return
		var/pid = href_list["setpname"]
		var/line_item/LI = products[pid]
		LI.name = newtext
		products[pid]=LI
	else if("setprice" in href_list)
		var/newprice = input(usr,"Enter the product's price.") as num
		if(!newprice) return
		var/pid = href_list["setprice"]
		var/line_item/LI = products[pid]
		LI.price = newprice
		products[pid]=LI
	src.attack_hand(usr)

/obj/machinery/pos/attackby(var/atom/movable/A, var/mob/user)
	if(istype(A,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = A
		if(!logged_in)
			user.visible_message("\blue The machine beeps, and logs you in","You hear a beep.")
			logged_in = user
			screen=POS_SCREEN_ORDER
			update_icon()
			src.attack_hand(user) //why'd you use usr nexis, why
			return
		else
			if(!linked_account)
				visible_message("\red The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.","You hear a buzz.")
				flick(src,"pos-error")
				return
			if(screen!=POS_SCREEN_FINALIZE)
				visible_message("\blue The machine buzzes.","\red You hear a buzz.")
				flick(src,"pos-error")
				return
			var/datum/money_account/acct = get_card_account(I)
			if(!acct)
				visible_message("\red The machine buzzes, and flashes \"NO ACCOUNT\" on the screen.","You hear a buzz.")
				flick(src,"pos-error")
				return
			if(credits_needed > acct.money)
				visible_message("\red The machine buzzes, and flashes \"NOT ENOUGH FUNDS\" on the screen.","You hear a buzz.")
				flick(src,"pos-error")
				return
			visible_message("\blue The machine beeps, and begins printing a receipt","You hear a beep.")
			PrintReceipt()
			NewOrder()
			acct.charge(credits_needed,linked_account,"Purchase at POS #[id].")
			credits_needed=0
			screen=POS_SCREEN_ORDER
	else if(istype(A,/obj/item/weapon/spacecash))
		if(!linked_account)
			visible_message("\red The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.","You hear a buzz.")
			flick(src,"pos-error")
			return
		if(!logged_in || screen!=POS_SCREEN_FINALIZE)
			visible_message("\blue The machine buzzes.","\red You hear a buzz.")
			flick(src,"pos-error")
			return
		var/obj/item/weapon/spacecash/C=A
		credits_held += C.worth*C.amount
		if(credits_held >= credits_needed)
			visible_message("\blue The machine beeps, and begins printing a receipt","You hear a beep and the sound of paper being shredded.")
			PrintReceipt()
			NewOrder()
			credits_held -= credits_needed
			credits_needed=0
			screen=POS_SCREEN_ORDER
			if(credits_held)
				var/obj/item/weapon/storage/box/B = new(loc)
				dispense_cash(credits_held,B)
				B.name="change"
				B.desc="A box of change."
			credits_held=0
	..()