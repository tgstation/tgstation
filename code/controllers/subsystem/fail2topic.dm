SUBSYSTEM_DEF(fail2topic)
	name = "Fail2Topic"
	init_order = INIT_ORDER_FAIL2TOPIC
	flags = SS_BACKGROUND
	runlevels = ALL

	var/list/rate_limiting = list()
	var/list/fail_counts = list()
	var/list/active_bans = list()

	var/rate_limit
	var/max_fails
	var/rule_name
	var/enabled = FALSE

/datum/controller/subsystem/fail2topic/Initialize(timeofday)
	rate_limit = CONFIG_GET(number/fail2topic_rate_limit)
	max_fails = CONFIG_GET(number/fail2topic_max_fails)
	rule_name = CONFIG_GET(string/fail2topic_rule_name)
	enabled = CONFIG_GET(flag/fail2topic_enabled)

	DropFirewallRule() // Clear the old bans if any still remain

	if (world.system_type == UNIX && enabled)
		enabled = FALSE
		subsystem_log("DISABLED - UNIX systems are not supported.")
	if(!enabled)
		flags |= SS_NO_FIRE
		can_fire = FALSE

	return ..()

/datum/controller/subsystem/fail2topic/fire()
	while (rate_limiting.len)
		var/ip = rate_limiting[1]
		var/last_attempt = rate_limiting[ip]

		if (world.time - last_attempt > rate_limit)
			rate_limiting -= ip
			fail_counts -= ip

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/fail2topic/Shutdown()
	DropFirewallRule()

/datum/controller/subsystem/fail2topic/proc/IsRateLimited(ip)
	var/last_attempt = rate_limiting[ip]

	var/static/datum/config_entry/keyed_list/topic_rate_limit_whitelist/cached_whitelist_entry
	if(!istype(cached_whitelist_entry))
		cached_whitelist_entry = CONFIG_GET(keyed_list/topic_rate_limit_whitelist)

	if(istype(cached_whitelist_entry))
		if(cached_whitelist_entry.config_entry_value[ip])
			return FALSE

	if (active_bans[ip])
		return TRUE

	rate_limiting[ip] = world.time

	if (isnull(last_attempt))
		return FALSE

	if (world.time - last_attempt > rate_limit)
		fail_counts -= ip
		return FALSE
	else
		var/failures = fail_counts[ip]

		if (isnull(failures))
			fail_counts[ip] = 1
			return TRUE
		else if (failures > max_fails)
			BanFromFirewall(ip)
			return TRUE
		else
			fail_counts[ip] = failures + 1
			return TRUE

/datum/controller/subsystem/fail2topic/proc/BanFromFirewall(ip)
	if (!enabled)
		return

	active_bans[ip] = world.time
	fail_counts -= ip
	rate_limiting -= ip

	. = shell("netsh advfirewall firewall add rule name=\"[rule_name]\" dir=in interface=any action=block remoteip=[ip]")

	if (.)
		subsystem_log("Failed to ban [ip]. Exit code: [.].")
	else if (isnull(.))
		subsystem_log("Failed to invoke shell to ban [ip].")
	else
		subsystem_log("Banned [ip].")

/datum/controller/subsystem/fail2topic/proc/DropFirewallRule()
	if (!enabled)
		return

	active_bans = list()

	. = shell("netsh advfirewall firewall delete rule name=\"[rule_name]\"")

	if (.)
		subsystem_log("Failed to drop firewall rule. Exit code: [.].")
	else if (isnull(.))
		subsystem_log("Failed to invoke shell for firewall rule drop.")
	else
		subsystem_log("Firewall rule dropped.")
