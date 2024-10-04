/// Machine has been broken - handles signals and reverting sprites
/obj/machinery/netpod/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	sever_connection()


/// Checks the integrity, alerts occupants
/obj/machinery/netpod/proc/on_damage_taken(datum/source, damage_amount)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	var/total = max_integrity - damage_amount
	var/integrity = (atom_integrity / total) * 100
	if(integrity > 50)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_INTEGRITY)


/// Puts points on the current occupant's card account
/obj/machinery/netpod/proc/on_domain_complete(datum/source, atom/movable/crate, reward_points)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	var/mob/living/player = occupant

	if(trapped)
		var/obj/machinery/quantum_server/our_server = server_ref?.resolve()
		if(!isnull(our_server))
			our_server.radio.talk_into(our_server, "[player] has completed their sentence in [our_server.generated_domain.name].", our_server.radio_channel_to_use)
		if(payout_account && !isnull(payout_account))
			payout_account.adjust_money(reward_points * 100, "Torment Nexus Payout")
			payout_account.bank_card_talk("[player] has completed their sentence in [our_server.generated_domain.name], account now holds [payout_account.account_balance] cr.")
			payout_account = null

	var/datum/bank_account/account = player.get_bank_account()
	if(isnull(account))
		return

	account.bitrunning_points += reward_points * 100



/// The domain has been fully purged, so we should double check our avatar is deleted
/obj/machinery/netpod/proc/on_domain_scrubbed(datum/source)
	SIGNAL_HANDLER

	var/mob/avatar = avatar_ref?.resolve()
	if(isnull(avatar))
		return
	payout_account = null
	QDEL_NULL(avatar)


/// Boots out anyone in the machine && opens it
/obj/machinery/netpod/proc/on_power_loss(datum/source)
	SIGNAL_HANDLER

	if(state_open)
		return

	if(isnull(occupant) || !connected)
		connected = FALSE
		open_machine()
		return

	sever_connection()


