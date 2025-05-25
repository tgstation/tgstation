DEFINE_INSTANT_VERB(/client, update_ping, ".update_ping", "", FALSE, "", time as num)
	var/ping = pingfromtime(time)
	lastping = ping
	if (!avgping)
		avgping = ping
	else
		avgping = MC_AVERAGE_SLOW(avgping, ping)

/client/proc/pingfromtime(time)
	return ((world.time+world.tick_lag*TICK_USAGE_REAL/100)-time)*100

DEFINE_INSTANT_VERB(/client, display_ping, ".display_ping", "", FALSE, "", time as num)
	to_chat(src, span_notice("Round trip ping took [round(pingfromtime(time),1)]ms"))

DEFINE_VERB(/client, ping, "Ping", "", FALSE, "OOC")
	winset(src, null, "command=.display_ping+[world.time+world.tick_lag*TICK_USAGE_REAL/100]")
