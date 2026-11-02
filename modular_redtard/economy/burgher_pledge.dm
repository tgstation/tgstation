// The Burgher Pledge and the levy on contracts (Ratwood code/controllers/subsystem/rogue/treasury.dm tick_burgher_pledge(),
// code/__DEFINES/banking.dm BURGHER_PLEDGE_*, fund_api.dm apply_tax()): while the Golden Bull of Kingsfield stands, the
// burghers renew every dawn a budget for the common defense, which pays the Crown's commissions (contracts and the
// Steward's petitions) and is never coin in hand; the Crown takes its contract levy from every contract reward.
// Contracts (Б34) draw on the pledge with draw_pledge() and refund_pledge(), and levy their rewards with levy_contract().

/// The burghers' budget for the common defense (Ratwood burgher_pledge_fund, of its own currency: it pays commissions only).
/datum/bank_account/rogue/pledge
	account_holder = "Burgher Pledge"
	fund_label = "the Burghers of the Vale"

/datum/bank_account/rogue/pledge/bank_card_talk(message, force)
	return

/datum/bank_account/rogue
	/// Shares of a mammon of contract levy the subject still owes, until they make a whole coin (Ratwood payer.tax_debt).
	var/contract_levy_debt = 0

/datum/controller/subsystem/rogue_treasury
	/// The Burgher Pledge (Ratwood burgher_pledge_fund).
	var/datum/bank_account/rogue/pledge/burgher_pledge
	var/total_pledge_renewed = 0
	var/total_pledge_spent = 0
	var/total_contract_levy = 0

/// The pledge stands at round start at twice the dawn's renewal (Ratwood BURGHER_PLEDGE_BASE_REFILL × ROUNDSTART_MULTIPLIER).
/datum/controller/subsystem/rogue_treasury/proc/setup_pledge()
	burgher_pledge = new("Burgher Pledge")
	var/seed = round(rogue_value("treasury_pledge_renewal") * rogue_value("treasury_pledge_roundstart_mult"))
	if(mint(burgher_pledge, seed, "Burgher Pledge"))
		total_pledge_renewed += seed

/// What the burghers pledge at a dawn: a base and a share per living subject (Ratwood BURGHER_PLEDGE_BASE_REFILL, _PER_PLAYER).
/datum/controller/subsystem/rogue_treasury/proc/pledge_renewal()
	return round(rogue_value("treasury_pledge_renewal") + length(GLOB.alive_player_list) * rogue_value("treasury_pledge_per_player"))

/// The Guild of Arms' tribute to the pledge while its charter stands (Ratwood GUILD_CHARTER_OF_ARMS_PLEDGE_BONUS).
/datum/controller/subsystem/rogue_treasury/proc/pledge_arms_tribute()
	return decree_active(ROGUE_DECREE_ARMS_CHARTER) ? round(rogue_value("treasury_pledge_arms_tribute")) : 0

/**
 * Ratwood tick_burgher_pledge(), at dawn: while the Golden Bull stands, whatever the pledge holds above twice the dawn's
 * renewal is clawed back, then the burghers renew it, and the Guild of Arms adds its tribute while its charter stands.
 */
/datum/controller/subsystem/rogue_treasury/proc/tick_burgher_pledge()
	if(!burgher_pledge || !decree_active(ROGUE_DECREE_GOLDEN_BULL))
		return
	var/renewal = pledge_renewal()
	var/tribute = pledge_arms_tribute()
	var/ceiling = round((renewal + tribute) * rogue_value("treasury_pledge_clawback"))
	if(burgher_pledge.account_balance > ceiling)
		burn(burgher_pledge, burgher_pledge.account_balance - ceiling, "Burgher Pledge clawback")
	if(mint(burgher_pledge, renewal, "Burgher Pledge replenishment"))
		total_pledge_renewed += renewal
	if(tribute && mint(burgher_pledge, tribute, "Guild of Arms tribute (Charter of Arms)"))
		total_pledge_renewed += tribute

/// Pays a commission out of the pledge (Ratwood burn() of the pledge fund by the contract ledger and petitions). Returns TRUE if paid.
/datum/controller/subsystem/rogue_treasury/proc/draw_pledge(amount, reason)
	amount = round(amount)
	if(!burgher_pledge || amount <= 0 || !burgher_pledge.has_money(amount))
		return FALSE
	if(!burn(burgher_pledge, amount, reason))
		return FALSE
	total_pledge_spent += amount
	return TRUE

/// Returns a commission that fell through to the pledge (Ratwood "Defense commission refund", "Steward petition refund").
/datum/controller/subsystem/rogue_treasury/proc/refund_pledge(amount, reason)
	amount = round(amount)
	if(!burgher_pledge || amount <= 0 || !mint(burgher_pledge, amount, reason))
		return FALSE
	total_pledge_spent -= amount
	return TRUE

/**
 * Ratwood apply_tax() for the contract levy: when a contract reward is paid into the bearer's account, the Crown takes its levy
 * from it, unless a charter exempts the bearer; charters cap the share it may take, outlaws have no cap. Shares of a mammon add
 * up on the account until they make a whole coin; the Concordat tithes the levied sale. Returns the mammons levied.
 */
/datum/controller/subsystem/rogue_treasury/proc/levy_contract(datum/bank_account/rogue/account, base_reward, reason)
	if(!account || base_reward <= 0 || !crown_purse)
		return 0
	var/mob/living/payer = account.owner()
	if(payer && tax_exempt(payer))
		return 0
	var/rate = get_tax_rate(ROGUE_TAX_CONTRACT)
	if(payer && !HAS_TRAIT(payer, TRAIT_OUTLAW))
		var/cap = ROGUE_FINE_RATE_CAP
		for(var/id in decrees)
			var/datum/rogue_decree/decree = decrees[id]
			if(decree.active)
				cap = decree.rate_cap(payer, cap)
		rate = min(rate, cap)
	if(rate <= 0)
		return 0
	account.contract_levy_debt += base_reward * rate
	var/due = floor(account.contract_levy_debt)
	if(due <= 0 || !transfer(account, crown_purse, due, "[ROGUE_TAX_CONTRACT] ([reason])"))
		return 0
	account.contract_levy_debt -= due
	total_contract_levy += due
	apply_concordat_tithe(base_reward, ROGUE_TAX_CONTRACT)
	return due
