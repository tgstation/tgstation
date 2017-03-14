/proc/press_gang(num_required)
	var/delay = 300
	message_admin("[key_name(usr)] is running a press gang! Results in [delay / 10] seconds...")

	var/list/generated_actions = list()

	var/list/signups = list()

	for(var/c in clients)
		var/client/C = c
		var/datum/action/pray_for_fun/V = new(signups)
		V.Grant(C.mob)
		generated_actions += V

	sleep(delay)

	for(var/v in generated_actions)
		var/datum/action/pray_for_fun/V = v
		if(!QDELETED(V))
			V.Remove(V.owner)

	var/total_signups = signups.len

	var/list/selected = list()
	var/list/lookups = list()
	while(signups.len || (selected.len < num_required))
		var/mob/M = pick_n_take(signups)
		if(!QDELETED(M))
			selected += M
			lookups += ADMIN_LOOKUP(M)


	message_admins("Press gang complete! [total_signups] signed up, [selected.len] have been chosen: [english_list(lookups)]")
	log_game("A press gang had [total_signups], [selected.len] were chosen: [english_list(selected)]")


/datum/action/pray_for_fun
	name = "Pray for Fun!"

/datum/action/pray_for_fun/IsAvailable()
	return TRUE

/datum/action/pray_for_fun/Trigger()
	if(!..())
		return
	target += owner
	to_chat(owner, "<span class='warning'>You have prayed for fun! Hopefully RNG is on your side...</span>")
	Remove(owner)
