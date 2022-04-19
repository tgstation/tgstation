#define DUMPTIME 3000

/datum/bank_account
	///Name listed on the account, reflected on the ID card.
	var/account_holder = "Rusty Venture"
	///How many credits are currently held in the bank account.
	var/account_balance = 0
	///If there are things effecting how much income a player will get, it's reflected here 1 is standard for humans.
	var/payday_modifier
	///The job datum of the account owner.
	var/datum/job/account_job
	///List of the physical ID card objects that are associated with this bank_account
	var/list/bank_cards = list()
	///Should this ID be added to the global list of accounts? If true, will be subject to station-bound economy effects as well as income.
	var/add_to_accounts = TRUE
	///The Unique ID number code associated with the owner's bank account, assigned at round start.
	var/account_id
	///Is there a CRAB 17 on the station draining funds? Prevents manual fund transfer. pink levels are rising
	var/being_dumped = FALSE
	///Reference to the current civilian bounty that the account is working on.
	var/datum/bounty/civilian_bounty
	///If player is currently picking a civilian bounty to do, these options are held here to prevent soft-resetting through the UI.
	var/list/datum/bounty/bounties
	///Can this account be replaced? Set to true for default IDs not recognized by the station.
	var/replaceable = FALSE
	///Cooldown timer on replacing a civilain bounty. Bounties can only be replaced once every 5 minutes.
	COOLDOWN_DECLARE(bounty_timer)

/datum/bank_account/New(newname, job, modifier = 1, player_account = TRUE)
	account_holder = newname
	account_job = job
	payday_modifier = modifier
	add_to_accounts = player_account
	setup_unique_account_id()

/datum/bank_account/Destroy()
	if(add_to_accounts)
		SSeconomy.bank_accounts_by_id -= "[account_id]"
	return ..()

/**
 * Proc guarantees the account_id possesses a unique number.
 * If it doesn't, it tries to find a unique alternative.
 * It then adds it to the `SSeconomy.bank_accounts_by_id` global list.
 */
/datum/bank_account/proc/setup_unique_account_id()
	if (!add_to_accounts)
		return
	if(account_id && !SSeconomy.bank_accounts_by_id["[account_id]"])
		SSeconomy.bank_accounts_by_id["[account_id]"] = src
		return //Already unique
	for(var/i in 1 to 1000)
		account_id = rand(111111, 999999)
		if(!SSeconomy.bank_accounts_by_id["[account_id]"])
			break
	if(SSeconomy.bank_accounts_by_id["[account_id]"])
		stack_trace("Unable to find a unique account ID, substituting currently existing account of id [account_id].")
	SSeconomy.bank_accounts_by_id["[account_id]"] = src

/datum/bank_account/vv_edit_var(var_name, var_value) // just so you don't have to do it manually
	var/old_id = account_id
	. = ..()
	switch(var_name)
		if(NAMEOF(src, account_id))
			if(add_to_accounts)
				SSeconomy.bank_accounts_by_id -= "[old_id]"
				setup_unique_account_id()
		if(NAMEOF(src, add_to_accounts))
			if(add_to_accounts)
				setup_unique_account_id()
			else
				SSeconomy.bank_accounts_by_id -= "[account_id]"

/**
 * Sets the bank_account to behave as though a CRAB-17 event is happening.
 */
/datum/bank_account/proc/dumpeet()
	being_dumped = TRUE

/**
 * Performs the math component of adjusting a bank account balance.
 */
/datum/bank_account/proc/_adjust_money(amt)
	account_balance += amt
	if(account_balance < 0)
		account_balance = 0

/**
 * Returns TRUE if a bank account has more than or equal to the amount, amt.
 * Otherwise returns false.
 */
/datum/bank_account/proc/has_money(amt)
	return account_balance >= amt

/**
 * Adjusts the balance of a bank_account as well as sanitizes the numerical input.
 */
/datum/bank_account/proc/adjust_money(amt)
	if((amt < 0 && has_money(-amt)) || amt > 0)
		_adjust_money(amt)
		return TRUE
	return FALSE

/**
 * Performs a transfer of credits to the bank_account datum from another bank account.
 * *datum/bank_account/from: The bank account that is sending the credits to this bank_account datum.
 * *amount: the quantity of credits that are being moved between bank_account datums.
 */
/datum/bank_account/proc/transfer_money(datum/bank_account/from, amount)
	if(from.has_money(amount))
		adjust_money(amount)
		SSblackbox.record_feedback("amount", "credits_transferred", amount)
		log_econ("[amount] credits were transferred from [from.account_holder]'s account to [src.account_holder]")
		from.adjust_money(-amount)
		return TRUE
	return FALSE

/**
 * This proc handles passive income gain for players, using their job's paycheck value.
 * Funds are taken from the parent department account to hand out to players. This can result in payment brown-outs if too many people are in one department.
 */
/datum/bank_account/proc/payday(amt_of_paychecks, free = FALSE)
	if(!account_job)
		return
	var/money_to_transfer = round(account_job.paycheck * payday_modifier * amt_of_paychecks)
	if(amt_of_paychecks == 1)
		money_to_transfer = clamp(money_to_transfer, 0, PAYCHECK_CREW) //We want to limit single, passive paychecks to regular crew income.
	if(free)
		adjust_money(money_to_transfer)
		SSblackbox.record_feedback("amount", "free_income", money_to_transfer)
		SSeconomy.station_target += money_to_transfer
		log_econ("[money_to_transfer] credits were given to [src.account_holder]'s account from income.")
	else
		var/datum/bank_account/D = SSeconomy.get_dep_account(account_job.paycheck_department)
		if(D)
			if(!transfer_money(D, money_to_transfer))
				bank_card_talk("ERROR: Payday aborted, departmental funds insufficient.")
				return FALSE
			else
				bank_card_talk("Payday processed, account now holds [account_balance] cr.")
				return TRUE
	bank_card_talk("ERROR: Payday aborted, unable to contact departmental account.")
	return FALSE

/**
 * This sends a local chat message to the owner of a bank account, on all ID cards registered to the bank_account.
 * If not held, sends out a message to all nearby players.
 */
/datum/bank_account/proc/bank_card_talk(message, force)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		var/icon_source = A
		if(istype(A, /obj/item/card/id))
			var/obj/item/card/id/id_card = A
			icon_source = id_card.get_cached_flat_icon()
		var/mob/card_holder = recursive_loc_check(A, /mob)
		if(ismob(card_holder)) //If on a mob
			if(!card_holder.client || (!(card_holder.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
				return

			if(card_holder.can_hear())
				card_holder.playsound_local(get_turf(card_holder), 'sound/machines/twobeep_high.ogg', 50, TRUE)
				to_chat(card_holder, "[icon2html(icon_source, card_holder)] [span_notice("[message]")]")
		else if(isturf(A.loc)) //If on the ground
			var/turf/T = A.loc
			for(var/mob/M in hearers(1,T))
				if(!M.client || (!(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
					continue
				if(M.can_hear())
					M.playsound_local(T, 'sound/machines/twobeep_high.ogg', 50, TRUE)
					to_chat(M, "[icon2html(icon_source, M)] [span_notice("[message]")]")
		else
			var/atom/sound_atom
			for(var/mob/M in A.loc) //If inside a container with other mobs (e.g. locker)
				if(!M.client || (!(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
					continue
				if(!sound_atom)
					sound_atom = A.drop_location() //in case we're inside a bodybag in a crate or something. doing this here to only process it if there's a valid mob who can hear the sound.
				if(M.can_hear())
					M.playsound_local(get_turf(sound_atom), 'sound/machines/twobeep_high.ogg', 50, TRUE)
					to_chat(M, "[icon2html(icon_source, M)] [span_notice("[message]")]")

/**
 * Returns a string with the civilian bounty's description on it.
 */
/datum/bank_account/proc/bounty_text()
	if(!civilian_bounty)
		return FALSE
	return civilian_bounty.description


/**
 * Returns the required item count, or required chemical units required to submit a bounty.
 */
/datum/bank_account/proc/bounty_num()
	if(!civilian_bounty)
		return FALSE
	if(istype(civilian_bounty, /datum/bounty/item))
		var/datum/bounty/item/item = civilian_bounty
		return "[item.shipped_count]/[item.required_count]"
	if(istype(civilian_bounty, /datum/bounty/reagent))
		var/datum/bounty/reagent/chemical = civilian_bounty
		return "[chemical.shipped_volume]/[chemical.required_volume] u"
	if(istype(civilian_bounty, /datum/bounty/virus))
		return "At least 1u"

/**
 * Produces the value of the account's civilian bounty reward, if able.
 */
/datum/bank_account/proc/bounty_value()
	if(!civilian_bounty)
		return FALSE
	return civilian_bounty.reward

/**
 * Performs house-cleaning on variables when a civilian bounty is replaced, or, when a bounty is claimed.
 */
/datum/bank_account/proc/reset_bounty()
	civilian_bounty = null
	COOLDOWN_RESET(src, bounty_timer)

/datum/bank_account/department
	account_holder = "Guild Credit Agency"
	var/department_id = "REPLACE_ME"
	add_to_accounts = FALSE

/datum/bank_account/department/New(dep_id, budget, player_account = FALSE)
	department_id = dep_id
	account_balance = budget
	account_holder = SSeconomy.department_accounts[dep_id]
	SSeconomy.generated_accounts += src

/datum/bank_account/remote // Bank account not belonging to the local station
	add_to_accounts = FALSE

#undef DUMPTIME
