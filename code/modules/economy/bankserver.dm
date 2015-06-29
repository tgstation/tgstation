/obj/machinery/bankserver
	name = "banking server"
	desc = "A large server unit that processes the station's transactions."
	
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub" //close enough
	
	power_channel = EQUIP
	idle_power_usage = 100
	
	var/createdtime //when it was created. this is to ensure that people can't just build and destroy bank servers 500 times to easily corrupt all logs.

/obj/machinery/bankserver/New()
	bank.servers += src
	createdtime = world.time
	say("Copying logs from other bank servers... This may take a few minutes.")

/obj/machinery/bankserver/initialize()
	createdtime = 0 //so the roundstart server doesnt need five minutes to wipe the logs if destroyed.

/obj/machinery/bankserver/Destroy()
	bank.servers -= src
	if(!bank.servers.len)
		for(var/datum/bankaccount/acc in bank.accounts)
			acc.logs = list() //If this was the last server, wipe all logs, regardless of time created.
		return

	if(world.time > createdtime + 600) //if the server has existed for more than five minutes.
		var/baseprob = servers.len / (servers.len + 1) * 100
		for(var/datum/bankaccount/acc in bank.accounts)
			for(var/log in acc.logs)
				if(prob(baseprob))
					log = html_encode(Gibberish(html_decode(log), rand(69, 74)))

/obj/machinery/bankserver/proc/can_use()
	if(!((stat & BROKEN) || (stat & NOPOWER)))
		return 0
	return 1
