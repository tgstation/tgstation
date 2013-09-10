/var/global/account_hack_attempted = 0

/datum/event/money_hacker
	endWhen = 10000
	var/time_duration = 0
	var/time_start = 0
	var/datum/money_account/affected_account
	var/obj/machinery/account_database/affected_db

/datum/event/money_hacker/setup()
	if(all_money_accounts.len)
		for(var/obj/machinery/account_database/DB in world)
			if( DB.z == 1 && !(DB.stat&NOPOWER) && DB.activated )
				affected_db = DB
				break
	if(affected_db)
		affected_account = pick(all_money_accounts)
	else
		kill()
		return

	time_start = world.time
	time_duration = rand(3000, 18000)
	endWhen = time_duration * 10	//a big enough buffer so that we should timeout before we run out of ticks
	account_hack_attempted = 1

/datum/event/money_hacker/start()
	return

/datum/event/money_hacker/announce()
	var/message = "A brute force hack has been detected (in progress since [worldtime2text()]). The target of the attack is: Financial account #[affected_account.account_number], \
	without intervention this attack will succeed in [time_duration / 600] minutes. Required intervention: complete shutdown of affected accounts databases until the attack has ceased. \
	Notifications will be sent as updates occur.<br>"
	var/my_department = "[station_name()] firewall subroutines"
	var/sending = message + "<font color='blue'><b>Message dispatched by [my_department].</b></font>"

	var/pass = 0
	for(var/obj/machinery/message_server/MS in world)
		if(!MS.active) continue
		// /obj/machinery/message_server/proc/send_rc_message(var/recipient = "",var/sender = "",var/message = "",var/stamp = "", var/id_auth = "", var/priority = 1)
		MS.send_rc_message("Engineering/Security/Bridge", my_department, message, "", "", 2)
		pass = 1

	if(pass)
		var/keyed_dpt1 = ckey("Engineering")
		var/keyed_dpt2 = ckey("Security")
		var/keyed_dpt3 = ckey("Bridge")
		for (var/obj/machinery/requests_console/Console in allConsoles)
			var/keyed_department = ckey(Console.department)
			if(keyed_department == keyed_dpt1 || keyed_department == keyed_dpt2 || keyed_department == keyed_dpt3)
				if(Console.newmessagepriority < 2)
					Console.newmessagepriority = 2
					Console.icon_state = "req_comp2"
				if(!Console.silent)
					playsound(Console.loc, 'sound/machines/twobeep.ogg', 50, 1)
					for (var/mob/O in hearers(5, Console.loc))
						O.show_message(text("\icon[Console] *The Requests Console beeps: 'PRIORITY Alert in [my_department]'"))
				Console.messages += "<B><FONT color='red'>High Priority message from [my_department]</FONT></B><BR>[sending]"

/datum/event/money_hacker/tick()
	if(world.time > time_start + time_duration)
		var/message
		if(affected_account && affected_db && affected_db.activated && !(affected_db.stat & (NOPOWER|BROKEN)) )
			//hacker wins
			message = "The hack attempt has succeeded."

			//subtract the money
			var/lost = affected_account.money * 0.8 + (rand(2,4) - 2) / 10
			affected_account.money -= lost

			//create a taunting log entry
			var/datum/transaction/T = new()
			T.target_name = pick("","yo brotha from anotha motha","el Presidente","chieF smackDowN")
			T.purpose = pick("Ne$ ---ount fu%ds init*&lisat@*n","PAY BACK YOUR MUM","Funds withdrawal","pWnAgE","l33t hax","liberationez")
			T.amount = pick("","([rand(0,99999)])","alla money","9001$","HOLLA HOLLA GET DOLLA","([lost])")
			var/date1 = "31 December, 1999"
			var/date2 = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [rand(1000,3000)]"
			T.date = pick("", current_date_string, date1, date2)
			var/time1 = rand(0, 99999999)
			var/time2 = "[round(time1 / 36000)+12]:[(time1 / 600 % 60) < 10 ? add_zero(time1 / 600 % 60, 1) : time1 / 600 % 60]"
			T.time = pick("", worldtime2text(), time2)
			T.source_terminal = pick("","[pick("Biesel","New Gibson")] GalaxyNet Terminal #[rand(111,999)]","your mums place","nantrasen high CommanD")

			affected_account.transaction_log.Add(T)

		else
			//crew wins
			message = "The attack has ceased, the affected databases can now be brought online."

		var/my_department = "[station_name()] firewall subroutines"
		var/sending = message + "<font color='blue'><b>Message dispatched by [my_department].</b></font>"

		var/pass = 0
		for(var/obj/machinery/message_server/MS in world)
			if(!MS.active) continue
			// /obj/machinery/message_server/proc/send_rc_message(var/recipient = "",var/sender = "",var/message = "",var/stamp = "", var/id_auth = "", var/priority = 1)
			MS.send_rc_message("Engineering/Security/Bridge", my_department, message, "", "", 2)
			pass = 1

		if(pass)
			var/keyed_dpt1 = ckey("Engineering")
			var/keyed_dpt2 = ckey("Security")
			var/keyed_dpt3 = ckey("Bridge")
			for (var/obj/machinery/requests_console/Console in allConsoles)
				var/keyed_department = ckey(Console.department)
				if(keyed_department == keyed_dpt1 || keyed_department == keyed_dpt2 || keyed_department == keyed_dpt3)
					if(Console.newmessagepriority < 2)
						Console.newmessagepriority = 2
						Console.icon_state = "req_comp2"
					if(!Console.silent)
						playsound(Console.loc, 'sound/machines/twobeep.ogg', 50, 1)
						for (var/mob/O in hearers(5, Console.loc))
							O.show_message(text("\icon[Console] *The Requests Console beeps: 'PRIORITY Alert in [my_department]'"))
					Console.messages += "<B><FONT color='red'>High Priority message from [my_department]</FONT></B><BR>[sending]"

		kill()

//shouldn't ever hit this, but this is here just in case
/datum/event/money_hacker/end()
	if(affected_account && affected_db)
		endWhen += time_duration
