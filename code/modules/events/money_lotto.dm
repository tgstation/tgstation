/datum/event/money_lotto
	endWhen = 301
	announceWhen = 300
	var/winner_name = "John Smith"
	var/winner_sum = 0
	var/deposit_success = 0

/datum/event/money_lotto/start()
	winner_sum = pick(5000, 10000, 50000, 100000, 500000, 1000000, 1500000)
	if(all_money_accounts.len)
		var/datum/money_account/D = pick(all_money_accounts)
		D.money += winner_sum

		var/datum/transaction/T = new()
		T.target_name = "Tau Ceti Daily Grand Slam -Stellar- Lottery"
		T.purpose = "Winner!"
		T.amount = winner_sum
		T.date = current_date_string
		T.time = worldtime2text()
		T.source_terminal = "Biesel TCD Terminal #[rand(111,333)]"
		D.transaction_log.Add(T)
	else
		kill()

/datum/event/money_lotto/announce()
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = "NanoTrasen Editor"
	newMsg.is_admin_message = 1

	newMsg.body = "TC Daily wishes to congratulate <b>[winner_name]</b> for recieving the Tau Ceti Stellar Slam Lottery, and receiving the out of this world sum of [winner_sum] credits!"
	if(!deposit_success)
		newMsg.body += "<br>Unfortunately, we were unable to verify the account details provided, so we were unable to transfer the money. Send a cheque containing the sum of $500 to TCD 'Stellar Slam' office on Biesel Prime containing updated details, and it'll be resent within the month."

	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "Tau Ceti Daily")
			FC.messages += newMsg
			break

	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("Tau Ceti Daily")
