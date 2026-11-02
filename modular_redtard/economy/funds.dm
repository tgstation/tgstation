// The coffers of the realm's institutions (Ratwood code/modules/roguetown/roguemachine/vaultbank.dm, the JAWBANK, and the
// Institutional tab of atm_tgui.dm): the Crown's Purse, the Church, the merchants' company, the bathhouse and the tavern each keep
// a fund behind a JAWBANK. Its officers draw coin from it, write loans and indentures on it and enrol agents with patronage
// writs; anyone may feed it coins, and anyone may strike coins loose from it with a blunt weapon while it holds enough. The
// tavern's and the bathhouse's stalls bank their takings in their funds, and at the JAWBANKs of the Church and the bathhouse
// the Bishop or the Bathmaster sets the Ordinance of the Baths (economy/fund_income.dm; Ratwood does it at a NERVELOCK).

/datum/controller/subsystem/rogue_treasury
	/// The JAWBANK of each institution, by fund id.
	var/list/jawbanks = list()
	/// Agents enrolled by patronage writs: fund id -> weakrefs to their bodies (Ratwood merchant_agents, church_agents, bathhouse_agents).
	var/list/patrons = list()
	/// Mammons a bathhouse attendant and an agent of the bathhouse may draw from its fund each day; the Bathmaster sets them.
	var/bathhouse_worker_limit = 0
	var/bathhouse_agent_limit = 0
	/// The Bathmaster stopped all draws of her attendants, of her agents.
	var/bathhouse_workers_suspended = FALSE
	var/bathhouse_agents_suspended = FALSE
	/// What each attendant or agent drew from the bathhouse fund since dawn, by real name (Ratwood bathhouse_withdrawals).
	var/list/bathhouse_drawn = list()

/datum/controller/subsystem/rogue_treasury/proc/setup_funds()
	bathhouse_worker_limit = round(ROGUE_BATHHOUSE_WORKER_LIMIT)
	bathhouse_agent_limit = round(ROGUE_BATHHOUSE_AGENT_LIMIT)
	for(var/fund_id in list(ROGUE_FUND_CHURCH, ROGUE_FUND_MERCHANT, ROGUE_FUND_BATHHOUSE))
		patrons[fund_id] = list()

/// Redraws every JAWBANK, empty or full.
/datum/controller/subsystem/rogue_treasury/proc/update_jawbanks()
	for(var/fund_id in jawbanks)
		var/obj/structure/roguemachine/vaultbank/jawbank = jawbanks[fund_id]
		jawbank.update_appearance()

/// The institution's officer: draws freely, writes loans, indentures and patronage, seals indentures it borrows (Ratwood can_issue_loan()).
/datum/controller/subsystem/rogue_treasury/proc/fund_can_lend(mob/user, fund_id)
	var/title = user?.mind?.assigned_role?.title
	switch(fund_id)
		if(ROGUE_FUND_CROWN)
			return rogue_fiscal_authority(user)
		if(ROGUE_FUND_CHURCH)
			return title in list(JOB_ROCKHILL_BISHOP, JOB_ROCKHILL_MARTYR)
		if(ROGUE_FUND_MERCHANT)
			return title == JOB_ROCKHILL_MERCHANT
		if(ROGUE_FUND_BATHHOUSE)
			return title == JOB_ROCKHILL_BATHMASTER
	return FALSE

/// Who that officer is, for refusals (Ratwood get_authority_label()).
/datum/controller/subsystem/rogue_treasury/proc/fund_authority_label(fund_id)
	switch(fund_id)
		if(ROGUE_FUND_CROWN)
			return "the Steward, Clerk or [JOB_ROCKHILL_GRAND_DUKE]"
		if(ROGUE_FUND_CHURCH)
			return "the Bishop or Martyr"
		if(ROGUE_FUND_MERCHANT)
			return "the Merchant"
		if(ROGUE_FUND_BATHHOUSE)
			return "the Bathmaster"
		if(ROGUE_FUND_TAVERN)
			return "the Innkeeper"
	return "nobody"

/// The tavern neither lends nor borrows by indenture (Ratwood supports_loans).
/datum/controller/subsystem/rogue_treasury/proc/fund_lends(fund_id)
	return fund_id != ROGUE_FUND_TAVERN

/// A bathhouse attendant or an agent of the bathhouse: may draw within the Bathmaster's daily limit.
/datum/controller/subsystem/rogue_treasury/proc/bathhouse_capped(mob/living/user)
	return user?.mind?.assigned_role?.title == JOB_ROCKHILL_BATHHOUSE_ATTENDANT || HAS_TRAIT(user, TRAIT_AGENT_BATHHOUSE)

/// What a bathhouse attendant or agent may still draw today (Ratwood get_withdraw_remaining()); attendants and agents have separate limits.
/datum/controller/subsystem/rogue_treasury/proc/bathhouse_remaining(mob/living/user)
	var/worker = user.mind?.assigned_role?.title == JOB_ROCKHILL_BATHHOUSE_ATTENDANT
	if(worker ? bathhouse_workers_suspended : bathhouse_agents_suspended)
		return 0
	return max(0, (worker ? bathhouse_worker_limit : bathhouse_agent_limit) - (bathhouse_drawn[user.real_name] || 0))

/// May read the fund's balance, ledger and loans (Ratwood can_view()).
/datum/controller/subsystem/rogue_treasury/proc/fund_can_view(mob/living/user, fund_id)
	if(fund_can_lend(user, fund_id))
		return TRUE
	switch(fund_id)
		if(ROGUE_FUND_BATHHOUSE)
			return bathhouse_capped(user)
		if(ROGUE_FUND_TAVERN)
			return user?.mind?.assigned_role?.title in list(JOB_ROCKHILL_INNKEEPER, JOB_ROCKHILL_TAPSTER)
	return FALSE

/// The most the user may draw from the fund now (Ratwood can_withdraw()): the Church keeps a reserve for charity, less what it has out in loans.
/datum/controller/subsystem/rogue_treasury/proc/fund_withdraw_limit(mob/living/user, fund_id)
	var/datum/bank_account/rogue/fund = funds[fund_id]
	if(!fund)
		return 0
	switch(fund_id)
		if(ROGUE_FUND_CHURCH)
			if(!fund_can_lend(user, fund_id))
				return 0
			return max(0, fund.account_balance - max(0, ROGUE_CHURCH_RESERVE - outstanding_principal(fund)))
		if(ROGUE_FUND_BATHHOUSE)
			if(fund_can_lend(user, fund_id))
				return fund.account_balance
			return bathhouse_capped(user) ? min(fund.account_balance, bathhouse_remaining(user)) : 0
		if(ROGUE_FUND_TAVERN)
			return user?.mind?.assigned_role?.title == JOB_ROCKHILL_INNKEEPER ? fund.account_balance : 0
	return fund_can_lend(user, fund_id) ? fund.account_balance : 0

/// The rule of drawing from the fund, shown to those who may read it (Ratwood get_withdraw_rule_text()).
/datum/controller/subsystem/rogue_treasury/proc/fund_withdraw_rule(fund_id)
	switch(fund_id)
		if(ROGUE_FUND_CHURCH)
			return "The Church mandates that loans is to be given to the poor, downtrodden, and malumites. [ROGUE_CHURCH_RESERVE]m must remain reserved for charity, less the principal currently in circulation."
		if(ROGUE_FUND_BATHHOUSE)
			var/text = "Workers of the Bathhouse may draw up to [bathhouse_worker_limit]m per dae from these coffers; its agents up to [bathhouse_agent_limit]m. The Bathmaster's hand is unbound."
			if(bathhouse_workers_suspended)
				text += " Payments to workers stand suspended."
			if(bathhouse_agents_suspended)
				text += " Payments to agents stand suspended."
			return text
	return ""

/// Interest rates an institution may write loans at, percent per dawn (Ratwood allowed_rates()); only the Church lends without interest.
/datum/controller/subsystem/rogue_treasury/proc/fund_loan_rates(fund_id)
	if(fund_id == ROGUE_FUND_CHURCH)
		return list(0, 10, 15, 20, 25, 50)
	return list(10, 15, 20, 25, 50)

/// The trait a patronage writ of the institution grants, if it grants agency.
/datum/controller/subsystem/rogue_treasury/proc/patron_trait(fund_id)
	switch(fund_id)
		if(ROGUE_FUND_CHURCH)
			return TRAIT_AGENT_CHURCH
		if(ROGUE_FUND_MERCHANT)
			return TRAIT_AGENT_MERCHANT
		if(ROGUE_FUND_BATHHOUSE)
			return TRAIT_AGENT_BATHHOUSE
	return null

/// How many agents the institution may keep (Ratwood PATRON_CAP_*).
/datum/controller/subsystem/rogue_treasury/proc/patron_cap(fund_id)
	switch(fund_id)
		if(ROGUE_FUND_CHURCH)
			return round(ROGUE_PATRON_CAP_CHURCH)
		if(ROGUE_FUND_MERCHANT)
			return round(ROGUE_PATRON_CAP_MERCHANT)
		if(ROGUE_FUND_BATHHOUSE)
			return round(ROGUE_PATRON_CAP_BATHHOUSE)
	return 0

/// The institution's agents still alive to the roll: gone bodies and those who lost the trait are struck off (Ratwood prune_patron_roster()).
/datum/controller/subsystem/rogue_treasury/proc/patron_roster(fund_id)
	var/list/roster = patrons[fund_id]
	if(!roster)
		return null
	var/trait = patron_trait(fund_id)
	for(var/datum/weakref/entry as anything in roster.Copy())
		var/mob/living/agent = entry.resolve()
		if(QDELETED(agent) || !HAS_TRAIT(agent, trait))
			roster -= entry
	return roster

/// Strikes an agent off the roll and takes their agency (Ratwood revoke_patron()).
/datum/controller/subsystem/rogue_treasury/proc/revoke_patron(fund_id, agent_ref, mob/user)
	var/list/roster = patron_roster(fund_id)
	for(var/datum/weakref/entry as anything in roster)
		var/mob/living/agent = entry.resolve()
		if(REF(agent) != agent_ref)
			continue
		roster -= entry
		REMOVE_TRAIT(agent, patron_trait(fund_id), ROGUE_TREASURY_TRAIT)
		if(fund_id == ROGUE_FUND_MERCHANT)
			REMOVE_TRAIT(agent, TRAIT_RESIDENT, ROGUE_TREASURY_TRAIT)
		var/datum/bank_account/rogue/fund = funds[fund_id]
		to_chat(agent, span_warning("Your patronage to [fund.fund_label] has been revoked."))
		log_game("PATRONAGE REVOKED: [key_name(user)] revoked [key_name(agent)] from [fund.fund_label].")
		return TRUE
	return FALSE

/**
 * JAWBANK (Ratwood vaultbank.dm): the biomechanical coffers of an institution. It shows its fund to those who may read it and
 * opens the institution's business to its officers; it takes coins from anyone, and a blunt blow knocks coins loose while it
 * holds more than its floor, every tenth blow a lump sum that the institution's people hear about.
 * The Covetous Crown drill of the Freefolk is not ported.
 */
/obj/structure/roguemachine/vaultbank
	resistance_flags = INDESTRUCTIBLE
	/// Institution whose fund it keeps (Ratwood get_fund_id()).
	var/fund_id = ROGUE_FUND_CROWN
	/// Roles told when a lump sum is knocked loose (Ratwood alert_jobs).
	var/list/alert_roles = list(JOB_ROCKHILL_GRAND_DUKE, JOB_ROCKHILL_STEWARD, JOB_ROCKHILL_CLERK)
	var/alert_location = "the Vault"
	/// Blows that spilled coin since the last lump sum.
	var/hits_since_lump = 0
	COOLDOWN_DECLARE(patronage_cooldown)

/obj/structure/roguemachine/vaultbank/Initialize(mapload)
	. = ..()
	SSrogue_treasury.jawbanks[fund_id] = src
	update_appearance()

/obj/structure/roguemachine/vaultbank/Destroy()
	if(SSrogue_treasury.jawbanks[fund_id] == src)
		SSrogue_treasury.jawbanks -= fund_id
	return ..()

/obj/structure/roguemachine/vaultbank/proc/linked_fund()
	return SSrogue_treasury.get_fund(fund_id)

/obj/structure/roguemachine/vaultbank/update_icon_state()
	var/datum/bank_account/rogue/fund = linked_fund()
	icon_state = fund?.account_balance ? initial(icon_state) : "[initial(icon_state)]_empty"
	return ..()

/// Below this balance no blow knocks coins loose (Ratwood bash_floor).
/obj/structure/roguemachine/vaultbank/proc/bash_floor()
	return ROGUE_CROWN_BASH_FLOOR

/// The lump sum every tenth blow spills (Ratwood lump_payout).
/obj/structure/roguemachine/vaultbank/proc/lump_payout()
	return ROGUE_CROWN_LUMP

/obj/structure/roguemachine/vaultbank/examine(mob/user)
	. = ..()
	var/datum/bank_account/rogue/fund = linked_fund()
	if(!fund)
		return
	if(Adjacent(user))
		. += span_notice("[fund.account_holder] currently sits at: [fund.account_balance] mammon.")
	else
		. += span_notice("[fund.account_holder]'s balance is sealed from afar. Step closer to count the coin.")
	. += span_info("Only [SSrogue_treasury.fund_authority_label(fund_id)] may draw from it or draft writs of loan on it.")
	. += span_info("Strike it with a blunt weapon to throttle coins loose.")

/obj/structure/roguemachine/vaultbank/interact(mob/user)
	if(!ishuman(user) || !linked_fund())
		return FALSE
	return ..()

/obj/structure/roguemachine/vaultbank/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || !istype(tool, /obj/item/roguecoin))
		return NONE
	var/datum/bank_account/rogue/fund = linked_fund()
	if(!fund || !rogue_coin_accepted(tool))
		return ITEM_INTERACT_BLOCKING
	var/value = tool.get_real_price()
	qdel(tool)
	SSrogue_treasury.mint(fund, value, "JAWBANK deposit by [user.real_name]")
	user.visible_message(span_notice("[user] inserts [value] mammon into [src]."))
	playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
	update_appearance()
	SStgui.update_uis(src)
	if(prob(50))
		say(pick(GLOB.rogue_jawbank_fed_lines))
		playsound(src, ROGUE_SOUND_MACHINE_TALK, 100, FALSE, -1)
	return ITEM_INTERACT_SUCCESS

/obj/structure/roguemachine/vaultbank/attacked_by(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(ishuman(user) && blunt_blow(attacking_item, user))
		knock_coins_loose(attacking_item, user)

/// A blow of a blunt or smashing weapon (Ratwood: d_type BCLASS_BLUNT).
/obj/structure/roguemachine/vaultbank/proc/blunt_blow(obj/item/weapon, mob/living/carbon/human/user)
	if(weapon.force < 1)
		return FALSE
	var/datum/intent/intent = user.rogue_strike_intent(weapon)
	if(intent)
		return intent.blade_class in list(BCLASS_BLUNT, BCLASS_SMASH)
	return !weapon.get_sharpness()

/// The blow spills coins by its force while the fund is above its floor; every tenth blow a lump sum (Ratwood attackby()).
/obj/structure/roguemachine/vaultbank/proc/knock_coins_loose(obj/item/weapon, mob/living/user)
	var/datum/bank_account/rogue/fund = linked_fund()
	if(!fund)
		return
	addtimer(CALLBACK(src, PROC_REF(forget_blows)), ROGUE_BASH_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)
	var/bashable = round(fund.account_balance - bash_floor())
	if(bashable <= 0)
		playsound(src, ROGUE_SOUND_MACHINE_NO, 70, TRUE)
		say("YOU'VE TAKEN ENOUGH.")
		return
	var/extorted = clamp(round(weapon.force * rand(60, 140) / 100), 1, bashable)
	spill(fund, extorted, "Vaultbank knock-loose")
	visible_message(span_danger("[src] coughed up [extorted] mammon!"))
	log_game("JAWBANK: [key_name(user)] knocked [extorted]m loose from [fund.account_holder]")
	if(prob(50))
		say(pick(GLOB.rogue_jawbank_hit_lines))
		playsound(src, ROGUE_SOUND_SEAL, 100, FALSE, -1)
	hits_since_lump++
	if(hits_since_lump < ROGUE_BASH_LUMP_HITS)
		return
	hits_since_lump = 0
	bashable = round(fund.account_balance - bash_floor())
	if(bashable <= 0)
		return
	var/lump = min(round(lump_payout()), bashable)
	spill(fund, lump, "Vaultbank knock-loose lump-sum")
	visible_message(span_notice("[src] just spat up a total of [lump] mammon - <b>A lump sum!</b>"))
	if(prob(50))
		say(pick(GLOB.rogue_jawbank_anguish_lines))
		playsound(src, ROGUE_SOUND_JAWBANK_ANGUISH, 100, FALSE, -1)
	alert_officers("Someone knocked a lump-sum loose from [src] at [alert_location]!")

/// Coins burst out of the coffers onto the floor, loud enough to be heard down the street.
/obj/structure/roguemachine/vaultbank/proc/spill(datum/bank_account/rogue/fund, amount, reason)
	if(!SSrogue_treasury.burn(fund, amount, reason))
		return
	rogue_coins_out(amount, null, null, src)
	playsound(src, ROGUE_SOUND_JAWBANK_HIT, 70, TRUE, 7)
	audible_message(span_warning("A loud clattering of coins spilling onto stone echoes."), hearing_distance = 14)
	update_appearance()
	SStgui.update_uis(src)

/obj/structure/roguemachine/vaultbank/proc/forget_blows()
	hits_since_lump = 0

/// Tells the institution's people (Ratwood send_ooc_note() to alert_jobs).
/obj/structure/roguemachine/vaultbank/proc/alert_officers(message)
	for(var/mob/living/carbon/human/officer as anything in GLOB.human_list)
		if(officer.stat != DEAD && officer.client && (officer.mind?.assigned_role?.title in alert_roles))
			to_chat(officer, span_boldwarning(message))

/obj/structure/roguemachine/vaultbank/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueJawbank", name)
		ui.open()

/obj/structure/roguemachine/vaultbank/ui_data(mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/fund = linked_fund()
	var/can_view = treasury.fund_can_view(user, fund_id)
	var/can_lend = treasury.fund_can_lend(user, fund_id)
	var/list/data = list()
	data["holder"] = fund.account_holder
	data["label"] = fund.fund_label
	data["authority"] = treasury.fund_authority_label(fund_id)
	data["can_view"] = can_view
	data["can_lend"] = can_lend && treasury.fund_lends(fund_id)
	data["withdraw_limit"] = treasury.fund_withdraw_limit(user, fund_id)
	data["day"] = ROGUE_TREASURY_DAY
	data["last_loan_day"] = ROGUE_LOAN_LAST_DAY
	if(fund_id == ROGUE_FUND_CHURCH || fund_id == ROGUE_FUND_BATHHOUSE)
		data["ordinance"] = list(
			"active" = treasury.bathhouse_ordinance,
			"can_set" = treasury.can_set_ordinance(user),
			"cooldown" = round(max(0, treasury.ordinance_next_toggle - world.time) / (1 SECONDS)),
			"tithe" = treasury.total_bathhouse_tithe,
		)
	if(!can_view)
		return data
	data["balance"] = fund.account_balance
	data["rule"] = treasury.fund_withdraw_rule(fund_id)
	data["ledger"] = rogue_ledger(fund)
	data["outstanding"] = treasury.outstanding_principal(fund)
	var/list/loans = list()
	for(var/datum/rogue_loan/loan as anything in treasury.loans)
		if(loan.lender == fund || loan.borrower_fund == fund)
			loans += list(loan.ui_entry())
	data["loans"] = loans
	var/datum/rogue_loan/indenture = treasury.indenture_of(fund)
	data["indenture"] = indenture?.ui_entry()
	if(can_lend && treasury.fund_lends(fund_id))
		data["rates"] = treasury.fund_loan_rates(fund_id)
		data["limits"] = list(
			"personal_min" = ROGUE_LOAN_PERSONAL_MIN,
			"personal_max" = ROGUE_LOAN_PERSONAL_MAX,
			"indenture_min" = ROGUE_INDENTURE_MIN,
			"indenture_max" = ROGUE_INDENTURE_MAX,
			"term_max" = ROGUE_LOAN_TERM_MAX,
		)
		var/list/targets = list()
		for(var/target_id in treasury.funds)
			var/datum/bank_account/rogue/target = treasury.funds[target_id]
			if(target_id != fund_id && treasury.fund_lends(target_id))
				targets += list(list("id" = target_id, "label" = target.fund_label))
		data["targets"] = targets
	var/trait = treasury.patron_trait(fund_id)
	if(trait && can_lend)
		var/list/agents = list()
		for(var/datum/weakref/entry as anything in treasury.patron_roster(fund_id))
			var/mob/living/agent = entry.resolve()
			agents += list(list("ref" = REF(agent), "name" = agent.real_name, "job" = agent.mind?.assigned_role?.title))
		data["patronage"] = list(
			"agents" = agents,
			"cap" = treasury.patron_cap(fund_id),
			"cooldown" = round(COOLDOWN_TIMELEFT(src, patronage_cooldown) / (1 SECONDS)),
			"explanation" = patronage_explanation(),
		)
	if(fund_id == ROGUE_FUND_BATHHOUSE)
		data["bathhouse"] = list(
			"master" = can_lend,
			"worker_limit" = treasury.bathhouse_worker_limit,
			"agent_limit" = treasury.bathhouse_agent_limit,
			"workers_suspended" = treasury.bathhouse_workers_suspended,
			"agents_suspended" = treasury.bathhouse_agents_suspended,
			"remaining" = can_lend ? null : treasury.bathhouse_remaining(user),
		)
	return data

/// What a patronage writ of this institution makes its bearer (Ratwood get_patron_explanation()).
/obj/structure/roguemachine/vaultbank/proc/patronage_explanation()
	return ""

/obj/structure/roguemachine/vaultbank/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = ui.user
	if(!istype(user))
		return TRUE
	switch(action)
		if("withdraw")
			withdraw_coins(user, text2num("[params["amount"]]"))
		if("deposit")
			deposit_from_account(user, text2num("[params["amount"]]"))
		if("draft_loan")
			draft_loan(user, params)
		if("draft_indenture")
			draft_loan(user, params, "[params["target"]]")
		if("repay_indenture")
			repay_indenture(user, text2num("[params["amount"]]"))
		if("draft_patronage")
			draft_patronage(user)
		if("revoke_patron")
			if(SSrogue_treasury.fund_can_lend(user, fund_id))
				SSrogue_treasury.revoke_patron(fund_id, "[params["ref"]]", user)
		if("bath_limit", "bath_suspend")
			set_bathhouse_terms(user, action, "[params["group"]]", text2num("[params["amount"]]"))
		if("ordinance")
			if(fund_id == ROGUE_FUND_CHURCH || fund_id == ROGUE_FUND_BATHHOUSE)
				SSrogue_treasury.toggle_ordinance(user)
	update_appearance()
	return TRUE

/// Coin out of the fund to the user, within what they may draw (Ratwood disburse()).
/obj/structure/roguemachine/vaultbank/proc/withdraw_coins(mob/living/carbon/human/user, amount)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/fund = linked_fund()
	amount = round(amount)
	if(!amount || amount <= 0)
		return
	if(amount > treasury.fund_withdraw_limit(user, fund_id))
		refuse("[fund.account_holder] withholds that sum.")
		return
	if(!treasury.burn(fund, amount, "JAWBANK withdrawal by [user.real_name]"))
		return
	if(fund_id == ROGUE_FUND_BATHHOUSE && !treasury.fund_can_lend(user, fund_id))
		treasury.bathhouse_drawn[user.real_name] = (treasury.bathhouse_drawn[user.real_name] || 0) + amount
	rogue_coins_out(amount, user, null, src)
	say("[amount]m drawn by [user.real_name].")
	log_game("JAWBANK WITHDRAW: [key_name(user)] drew [amount]m from [fund.account_holder].")

/// Coin from the user's NERVELOCK account into the bathhouse fund, for its people (Ratwood deposit_to_fund()).
/obj/structure/roguemachine/vaultbank/proc/deposit_from_account(mob/living/carbon/human/user, amount)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/fund = linked_fund()
	var/datum/bank_account/rogue/account = treasury.get_account(user)
	amount = round(amount)
	if(fund_id != ROGUE_FUND_BATHHOUSE || !treasury.fund_can_view(user, fund_id) || !account || !amount || amount <= 0)
		return
	if(!treasury.transfer(account, fund, amount, "Bathhouse deposit by [user.real_name]"))
		refuse("Your account cannot cover a deposit of [amount]m.")
		return
	playsound(src, ROGUE_SOUND_COIN_INSERT, 60, FALSE, -1)
	say("[amount]m rendered unto the Bathhouse by [user.real_name].")

/**
 * Writes a loan writ, or an indenture to another institution when given a target, signed by the officer (Ratwood
 * draft_personal_loan(), draft_indenture()). No new writs after the last lending day; the fund must cover the principal.
 */
/obj/structure/roguemachine/vaultbank/proc/draft_loan(mob/living/carbon/human/user, list/params, target_id)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/fund = linked_fund()
	if(!treasury.fund_lends(fund_id) || !treasury.fund_can_lend(user, fund_id))
		return
	if(ROGUE_TREASURY_DAY > ROGUE_LOAN_LAST_DAY)
		refuse("No new loans may be drawn after day [ROGUE_LOAN_LAST_DAY].")
		return
	var/amount = round(text2num("[params["amount"]]"))
	var/term = round(text2num("[params["term"]]"))
	var/rate_percent = round(text2num("[params["rate"]]"))
	var/datum/bank_account/rogue/target
	if(target_id)
		target = treasury.funds[target_id]
		if(!target || target_id == fund_id || !treasury.fund_lends(target_id))
			to_chat(user, span_warning("Choose a valid target institution."))
			return
		if(!amount || amount < ROGUE_INDENTURE_MIN || amount > ROGUE_INDENTURE_MAX)
			to_chat(user, span_warning("An indenture must name between [ROGUE_INDENTURE_MIN] and [ROGUE_INDENTURE_MAX] mammon."))
			return
	else if(!amount || amount < ROGUE_LOAN_PERSONAL_MIN || amount > ROGUE_LOAN_PERSONAL_MAX)
		to_chat(user, span_warning("A personal loan must name between [ROGUE_LOAN_PERSONAL_MIN] and [ROGUE_LOAN_PERSONAL_MAX] mammon."))
		return
	if(!term || term < 1 || term > ROGUE_LOAN_TERM_MAX)
		to_chat(user, span_warning("Term must be between 1 and [ROGUE_LOAN_TERM_MAX] days."))
		return
	if(isnull(rate_percent) || !(rate_percent in treasury.fund_loan_rates(fund_id)))
		to_chat(user, span_warning("Interest must be one of the listed rates."))
		return
	if(!fund.has_money(amount))
		refuse("[fund.account_holder] cannot cover [target ? "an indenture" : "a loan"] of [amount]m at this time.")
		return
	var/obj/item/rogue_loan_writ/writ
	if(target)
		var/obj/item/rogue_loan_writ/indenture/indenture = new(get_turf(user))
		indenture.borrower_id = target_id
		writ = indenture
	else
		writ = new(get_turf(user))
	writ.draft(fund_id, user.real_name, amount, term, rate_percent / 100)
	playsound(user, ROGUE_SOUND_COIN_DISPENSE, 60, FALSE, -1)
	if(user.put_in_hands(writ))
		to_chat(user, span_notice("A [writ.name] for [amount]m, signed in my name, slips into my hand."))
	else
		to_chat(user, span_notice("A [writ.name] for [amount]m, signed in my name, materialises at my feet."))
	log_game("LOAN WRIT: [key_name(user)] drafted [amount]m from [fund.account_holder][target ? " to [target.account_holder]" : ""] over [term]d at [rate_percent]%/day.")

/// The officer pays the institution's indenture early from its fund (Ratwood handle_repay_indenture()).
/obj/structure/roguemachine/vaultbank/proc/repay_indenture(mob/living/carbon/human/user, amount)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/rogue_loan/indenture = treasury.indenture_of(linked_fund())
	if(!indenture || !treasury.fund_can_lend(user, fund_id))
		return
	var/paid = treasury.repay_loan(indenture, amount)
	if(!paid)
		refuse("[indenture.debtor_name]'s coffers are too thin to make a payment.")
		return
	playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
	say(indenture in treasury.loans ? "[paid]m transferred. [indenture.remaining_due()]m remains on the indenture." : "Indenture repaid in full. [paid]m transferred to [indenture.lender.fund_label].")

/// The officer signs a patronage writ for someone else to claim (Ratwood draft_patronage_writ()).
/obj/structure/roguemachine/vaultbank/proc/draft_patronage(mob/living/carbon/human/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/writ_type = patronage_writ_type()
	if(!writ_type || !treasury.fund_can_lend(user, fund_id))
		return
	if(!COOLDOWN_FINISHED(src, patronage_cooldown))
		to_chat(user, span_warning("The seal is still warm. Wait [round(COOLDOWN_TIMELEFT(src, patronage_cooldown) / (1 SECONDS))]s before drafting another."))
		return
	if(length(treasury.patron_roster(fund_id)) >= treasury.patron_cap(fund_id))
		to_chat(user, span_warning("The roll is full - strike a name first."))
		return
	var/obj/item/rogue_patronage_writ/writ = new writ_type(get_turf(user))
	writ.issuer_name = user.real_name
	QDEL_IN(writ, ROGUE_WRIT_LIFETIME)
	COOLDOWN_START(src, patronage_cooldown, ROGUE_PATRON_WRIT_COOLDOWN)
	playsound(user, ROGUE_SOUND_COIN_DISPENSE, 60, FALSE, -1)
	if(user.put_in_hands(writ))
		to_chat(user, span_notice("A [writ.name], signed in my name, slips into my hand."))
	else
		to_chat(user, span_notice("A [writ.name], signed in my name, materialises at my feet."))
	log_game("PATRONAGE WRIT: [key_name(user)] drafted [writ.name].")

/obj/structure/roguemachine/vaultbank/proc/patronage_writ_type()
	return null

/// The Bathmaster sets the daily limits of her attendants and agents, or stops their draws (Ratwood handle_set_bathhouse_limit()).
/obj/structure/roguemachine/vaultbank/proc/set_bathhouse_terms(mob/living/carbon/human/user, action, group, amount)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	if(fund_id != ROGUE_FUND_BATHHOUSE || !treasury.fund_can_lend(user, fund_id) || !(group in list("worker", "agent")))
		return
	var/workers = group == "worker"
	if(action == "bath_suspend")
		if(workers)
			treasury.bathhouse_workers_suspended = !treasury.bathhouse_workers_suspended
		else
			treasury.bathhouse_agents_suspended = !treasury.bathhouse_agents_suspended
		var/suspended = workers ? treasury.bathhouse_workers_suspended : treasury.bathhouse_agents_suspended
		say("Payments to Bathhouse [group]s [suspended ? "suspended" : "resumed"].")
		log_game("BATHHOUSE SUSPENSION: [key_name(user)] [suspended ? "suspended" : "resumed"] [group] withdrawals.")
	else
		amount = round(amount)
		if(isnull(amount) || amount < 0)
			return
		amount = min(amount, ROGUE_TRANSFER_MAX)
		if(workers)
			treasury.bathhouse_worker_limit = amount
		else
			treasury.bathhouse_agent_limit = amount
		say("[workers ? "Workers" : "Agents"] of the Bathhouse may now draw up to [amount]m per dae.")
		log_game("BATHHOUSE LIMIT: [key_name(user)] set the [group] daily withdrawal limit to [amount]m.")
	playsound(src, ROGUE_SOUND_BEEP, 60, FALSE, -1)

/obj/structure/roguemachine/vaultbank/church
	fund_id = ROGUE_FUND_CHURCH
	alert_roles = list(JOB_ROCKHILL_BISHOP, JOB_ROCKHILL_MARTYR, JOB_ROCKHILL_ACOLYTE)
	alert_location = "the Church"

/obj/structure/roguemachine/vaultbank/church/bash_floor()
	return ROGUE_FUND_BASH_FLOOR

/obj/structure/roguemachine/vaultbank/church/lump_payout()
	return ROGUE_FUND_LUMP

/obj/structure/roguemachine/vaultbank/church/patronage_writ_type()
	return /obj/item/rogue_patronage_writ/benefactor

/obj/structure/roguemachine/vaultbank/church/patronage_explanation()
	return "Granting a person the status of Benefactor of the Church places them under the Clergy's roll, marking them a friend of the faith in the eyes of Crown and Church alike: they pay the poll tax as clergy, the Concordat shields them, and they know the Church's defaulters by sight. - the Office of the Stewardry"

/obj/structure/roguemachine/vaultbank/merchant
	fund_id = ROGUE_FUND_MERCHANT
	alert_roles = list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
	alert_location = "the Merchant's quarter"

/obj/structure/roguemachine/vaultbank/merchant/bash_floor()
	return ROGUE_FUND_BASH_FLOOR

/obj/structure/roguemachine/vaultbank/merchant/lump_payout()
	return ROGUE_FUND_LUMP

/obj/structure/roguemachine/vaultbank/merchant/patronage_writ_type()
	return /obj/item/rogue_patronage_writ/charter

/obj/structure/roguemachine/vaultbank/merchant/patronage_explanation()
	return "Granting a person the status of Agent of the Ferentian Trading Company confers Burgher standing and residency upon them, and they may read the names of those who owe debt to the Company. Go forth, in Malum's name, and let them collect what is rightfully owed. - the Office of the Stewardry"

/obj/structure/roguemachine/vaultbank/bathhouse
	fund_id = ROGUE_FUND_BATHHOUSE
	alert_roles = list(JOB_ROCKHILL_BATHMASTER, JOB_ROCKHILL_BATHHOUSE_ATTENDANT)
	alert_location = "the Bathhouse"

/obj/structure/roguemachine/vaultbank/bathhouse/bash_floor()
	return ROGUE_FUND_BASH_FLOOR

/obj/structure/roguemachine/vaultbank/bathhouse/lump_payout()
	return ROGUE_FUND_LUMP

/obj/structure/roguemachine/vaultbank/bathhouse/patronage_writ_type()
	return /obj/item/rogue_patronage_writ/token

/obj/structure/roguemachine/vaultbank/bathhouse/patronage_explanation()
	return "Granting a person the status of Agent of the Bathhouse marks them a trusted hand of the stews. They may read the coffers of the Bathhouse, draw from them within your limit, and know those who owe debt to the Bathhouse.\n\nYou may be tempted to extend this status to the wretched and the outlawed. It is a powerful option, and will indebt them to you - but should they ever be spotted bearing the mark of the Bathhouse, Church and Crown alike may condemn you for collaborating with them. A lawed intermediary is, as a rule, the safer option. - the Office of the Stewardry"

/obj/structure/roguemachine/vaultbank/innkeeper
	fund_id = ROGUE_FUND_TAVERN
	alert_roles = list(JOB_ROCKHILL_INNKEEPER, JOB_ROCKHILL_TAPSTER)
	alert_location = "the Tavern"

/obj/structure/roguemachine/vaultbank/innkeeper/bash_floor()
	return ROGUE_TAVERN_BASH_FLOOR

/obj/structure/roguemachine/vaultbank/innkeeper/lump_payout()
	return ROGUE_TAVERN_LUMP

/// What a JAWBANK says when fed (Ratwood feedme()).
GLOBAL_LIST_INIT(rogue_jawbank_fed_lines, list(
	"MORE. MORE. MORE.",
	"I WILL KEEP IT SAFE.",
	"I WILL TREASURE THAT.",
	"MORE FOR THE DUCHY. MORE FOR ME.",
	"TENS, HUNDREDS, THOUSANDS.",
	"THERE IS NO SAFER PLACE FOR IT.",
	"I'M AROUND YOUR BEST INTEREST.",
	"IT WILL NEVER BE ENOUGH.",
	"ANOTHER HANDFUL. ANOTHER ZENNY.",
	"A LITTLE RICHER. NONE THE POORER.",
	"EARNINGS SAVED. EARNINGS GIVEN.",
	"YOUR TREASURED TREASURY. ALWAYS SAFE WITH ME.",
))

/// What a JAWBANK says when struck (Ratwood whine()).
GLOBAL_LIST_INIT(rogue_jawbank_hit_lines, list(
	"YOU SWING LIKE A PAUPER.",
	"I AM TELLING THE NERVEMASTER.",
	"THEY'LL HEAR YOU.",
	"STOP THAT.",
	"THAT IS THE DUCHY'S COIN.",
	"YOU LOWLYFE.",
	"THAT'S NOT YOURS.",
	"THIS ISN'T A PROPER WITHDRAWAL.",
	"I AM INSURED FOR THIS. ARE YOU?",
	"YOU WON'T BREAK THIS BANK.",
	"KEEP TRYING.",
	"QUIT IT.",
))

/// What a JAWBANK groans when it spills a lump sum (Ratwood anguish()).
GLOBAL_LIST_INIT(rogue_jawbank_anguish_lines, list(
	"NO MORE OF THIS.",
	"GIVE IT UP.",
	"THE TREASURY REMAINS.",
	"I STAY PUT.",
	"CEASE.",
	"LEAVE.",
	"GO AWAY.",
	"THEFT.",
	"BE SMARTER THAN THIS.",
	"YOU'RE A FOOL.",
	"WHEN DOES THIS END?",
	"NOT YOUR COIN.",
))

/**
 * A patronage writ (Ratwood code/modules/banking/patronage_writ.dm, port of Azure Peak #7000): signed at a JAWBANK by an
 * institution's officer, claimed in hand by someone else, it enrols the bearer as the institution's agent while the roll has room.
 */
/obj/item/rogue_patronage_writ
	name = "patronage writ"
	desc = "A signed writ of patronage."
	icon = 'modular_redtard/rockhill/icons/roguetown/items/misc.dmi'
	icon_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throwforce = 0
	resistance_flags = FLAMMABLE
	var/issuer_name
	/// Institution whose agent the bearer becomes.
	var/fund_id

/obj/item/rogue_patronage_writ/examine(mob/user)
	. = ..()
	var/datum/bank_account/rogue/fund = SSrogue_treasury.get_fund(fund_id)
	. += span_info("Signed by [issuer_name || "an unknown hand"], [ROCKHILL_CALENDAR_EPOCH_YEAR]. Use in hand to claim agency of [fund?.fund_label].")

/obj/item/rogue_patronage_writ/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !ishuman(user))
		return
	claim(user)
	return TRUE

/obj/item/rogue_patronage_writ/proc/claim(mob/living/carbon/human/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/fund = treasury.get_fund(fund_id)
	var/trait = treasury.patron_trait(fund_id)
	var/list/roster = treasury.patron_roster(fund_id)
	if(!fund || !trait || isnull(roster))
		to_chat(user, span_warning("The writ names no patronage to grant."))
		return
	if(issuer_name && issuer_name == user.real_name)
		to_chat(user, span_warning("I cannot grant patronage to myself - the writ must pass through another's hand."))
		return
	if(HAS_TRAIT(user, trait))
		to_chat(user, span_warning("I'm already on this roll."))
		return
	if(length(roster) >= treasury.patron_cap(fund_id))
		to_chat(user, span_warning("[fund.fund_label]'s roll is full."))
		return
	ADD_TRAIT(user, trait, ROGUE_TREASURY_TRAIT)
	if(fund_id == ROGUE_FUND_MERCHANT)
		ADD_TRAIT(user, TRAIT_RESIDENT, ROGUE_TREASURY_TRAIT)
	roster += WEAKREF(user)
	user.visible_message(span_notice("[user] signs the roll."), span_notice("I'm an agent of [fund.fund_label]."))
	playsound(user, ROGUE_SOUND_SEAL, 60, FALSE, -1)
	log_game("PATRONAGE GRANTED: [key_name(user)] enrolled as [trait].")
	qdel(src)

/obj/item/rogue_patronage_writ/charter
	name = "writ of charter"
	desc = "A writ of the Ferentian Trading Company. Claim it for chartered agency."
	fund_id = ROGUE_FUND_MERCHANT

/obj/item/rogue_patronage_writ/token
	name = "token of the Bathhouse"
	desc = "A sealed token of the Bathhouse. Claim it for agency."
	fund_id = ROGUE_FUND_BATHHOUSE

/obj/item/rogue_patronage_writ/benefactor
	name = "letter of benefaction"
	desc = "A sealed letter of the Church, conferring the rank of Benefactor upon its bearer."
	fund_id = ROGUE_FUND_CHURCH
