

// For all things visual, such as leveling up


// Look up: _vending.dm    		proc/ui_interact()
//			Malf_Modules.dm 	proc/use()

/*
/datum/antagonist/bloodsucker/proc/LevelUpMenu()
	var/list/dat = list()

	dat += "<h3>You have become more ancient.<BR>Direct the path of your blood</h3>"
	dat += "<HR>"

	// Step One: Decide powers you CAN buy.
	for(var/pickedpower in typesof(/datum/action/bloodsucker))
		var/obj/effect/proc_holder/spell/bloodsucker/power = pickedpower
		// NAME
		dat += "<A href='byond://?src=[REF(src)];[module.mod_pick_name]=1'>[power.name]</A>"
		// COST
		dat += "<td align='right'><b>[power.name]&nbsp;</b><a href='byond://?src=[REF(src)];vend=[REF(R)]'>Vend</a></td>"
		dat == "<BR>"

	var/datum/browser/popup = new(owner.current, "bloodsuckerrank", "Bloodsucker Rank Up")
	popup.set_content(dat.Join())
	popup.open()

/datum/antagonist/bloodsucker/Topic(href, href_list)
	if(..())
		return
*/


// From browser.dm:   /datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null)


/*
	var/list/dat = list()
	dat += "<B>Select use of processing time: (currently #[processing_time] left.)</B><BR>"
	dat += "<HR>"
	dat += "<B>Install Module:</B><BR>"
	dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
	for(var/datum/AI_Module/large/module in possible_modules)
		dat += "<A href='byond://?src=[REF(src)];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[REF(src)];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	for(var/datum/AI_Module/small/module in possible_modules)
		dat += "<A href='byond://?src=[REF(src)];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[REF(src)];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	dat += "<HR>"
	if(temp)
		dat += "[temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu")
	popup.set_content(dat.Join())
	popup.open()
*/

/*
	var/dat = ""
	var/datum/bank_account/account
	var/mob/living/carbon/human/H
	var/obj/item/card/id/C
	if(ishuman(user))
		H = user
		C = H.get_idcard(TRUE)

	if(!C)
		dat += "<font color = 'red'><h3>No ID Card detected!</h3></font>"
	else if (!C.registered_account)
		dat += "<font color = 'red'><h3>No account on registered ID card!</h3></font>"
	if(onstation && C && C.registered_account)
		account = C.registered_account
	dat += "<h3>Select an item</h3>"
	dat += "<div class='statusDisplay'>"
	if(!product_records.len)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		var/list/display_records = product_records + coin_records
		if(extended_inventory)
			display_records = product_records + coin_records + hidden_records
		dat += "<table>"
		for (var/datum/data/vending_product/R in display_records)
			var/price_listed = "$[default_price]"
			var/is_hidden = hidden_records.Find(R)
			if(is_hidden && !extended_inventory)
				continue
			if(R.custom_price)
				price_listed = "$[R.custom_price]"
			if(!onstation || account && account.account_job && account.account_job.paycheck_department == payment_department)
				price_listed = "FREE"
			if(coin_records.Find(R) || is_hidden)
				price_listed = "$[R.custom_premium_price ? R.custom_premium_price : extra_price]"
			dat += "<tr><td><img src='data:image/jpeg;base64,[GetIconForProduct(R)]'/></td>"
			dat += "<td style=\"width: 100%\"><b>[sanitize(R.name)]  ([price_listed])</b></td>"
			if(R.amount > 0 && ((C && C.registered_account && onstation) || (!onstation && isliving(user))))
				dat += "<td align='right'><b>[R.amount]&nbsp;</b><a href='byond://?src=[REF(src)];vend=[REF(R)]'>Vend</a></td>"
			else
				dat += "<td align='right'><span class='linkOff'>Not&nbsp;Available</span></td>"
			dat += "</tr>"
		dat += "</table>"
	dat += "</div>"
	if(onstation && C && C.registered_account)
		dat += "<b>Balance: $[account.account_balance]</b>"
	if(istype(src, /obj/machinery/vending/snack))
		dat += "<h3>Chef's Food Selection</h3>"
		dat += "<div class='statusDisplay'>"
		for (var/O in dish_quants)
			if(dish_quants[O] > 0)
				var/N = dish_quants[O]
				dat += "<a href='byond://?src=[REF(src)];dispense=[sanitize(O)]'>Dispense</A> "
				dat += "<B>[capitalize(O)] ($[default_price]): [N]</B><br>"
		dat += "</div>"

	var/datum/browser/popup = new(user, "vending", (name))
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()
*/