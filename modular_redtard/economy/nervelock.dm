/**
 * NERVELOCK (Ratwood code/modules/roguetown/roguemachine/ATM.dm and atm_tgui.dm): the realm's bank in the wall. The first touch
 * bites the finger and opens the subject's account; after that it takes coins into the account and pays the account out in the
 * coin the subject asks for, twenty coins at most. Outlaws are refused. Loans, guild funds and the poll tax live in loans.dm,
 * funds.dm and poll_tax.dm; Ratwood's Covetous Crown drill is not ported.
 */
/obj/structure/roguemachine/atm
	/// Where the machine stands, for the Crown's reports (map edit).
	var/location_tag

/obj/structure/roguemachine/atm/examine(mob/user)
	. = ..()
	. += span_smallnotice("Crown levies - Import: [round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * 100, 1)]%.")
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(account)
		. += span_smallnotice("My account holds [account.account_balance] mammons.")

/// A hand on the machine opens the account's window; the first touch opens the account instead (Ratwood attack_hand()).
/obj/structure/roguemachine/atm/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_OUTLAW))
		to_chat(user, span_warning("The machine rejects you, sensing your status as an outlaw in these lands."))
		return TRUE
	if(SSrogue_treasury.get_account(user))
		return ..()
	to_chat(user, span_warning("The machine bites my finger."))
	icon_state = "atm-b"
	flash_color(user, flash_color = "#C80000", flash_time = 1 SECONDS)
	playsound(user, 'modular_redtard/rockhill/sound/combat/hits/bladed/genstab (1).ogg', 100, FALSE, -1)
	var/datum/job/roguetown/job = user.mind?.assigned_role
	if(SSrogue_treasury.open_account(user, 0, istype(job) ? job.rogue_estate_income : 0))
		addtimer(CALLBACK(src, PROC_REF(announce_new_account)), 0.5 SECONDS)
	return TRUE

/obj/structure/roguemachine/atm/proc/announce_new_account()
	say("New account created.")
	playsound(src, ROGUE_SOUND_MACHINE_TALK, 100, FALSE, -1)

/// Coins go into the account (Ratwood generate_money_account()).
/obj/structure/roguemachine/atm/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/roguecoin) || user.combat_mode)
		return NONE
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account)
		say("No account found. Submit your fingers for inspection.")
		return ITEM_INTERACT_BLOCKING
	if(!rogue_coin_accepted(tool))
		return ITEM_INTERACT_BLOCKING
	var/value = tool.get_real_price()
	qdel(tool)
	SSrogue_treasury.mint(account, value, "NERVELOCK deposit by [user.real_name]")
	playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
	SStgui.update_uis(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/roguemachine/atm/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueNervelock", name)
		ui.open()

/obj/structure/roguemachine/atm/ui_data(mob/user)
	var/list/data = list()
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	data["holder"] = account?.account_holder
	data["balance"] = account?.account_balance || 0
	data["wage"] = account ? (SSrogue_treasury.daily_payments[account.job_title()] || 0) : 0
	data["estate"] = account?.estate_income || 0
	data["tariff"] = round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * 100, 1)
	data["ledger"] = rogue_ledger(account)
	return data

/obj/structure/roguemachine/atm/ui_static_data(mob/user)
	var/list/data = list()
	var/list/coins = list()
	for(var/kind in GLOB.rogue_coin_kinds)
		var/obj/item/roguecoin/coin_type = GLOB.rogue_coin_kinds[kind]
		coins += list(list("kind" = kind, "name" = initial(coin_type.plural_name), "value" = rogue_coin_value(kind)))
	data["coins"] = coins
	data["max_coins"] = ROGUE_WITHDRAW_COINS_MAX
	return data

/obj/structure/roguemachine/atm/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || action != "withdraw")
		return
	var/mob/living/user = ui.user
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	var/kind = params["kind"]
	var/count = round(text2num("[params["count"]]"))
	if(!account || !(kind in GLOB.rogue_coin_kinds) || !count || count < 1)
		return TRUE
	if(count > ROGUE_WITHDRAW_COINS_MAX)
		to_chat(user, span_warning("Maximum [ROGUE_WITHDRAW_COINS_MAX] coins per withdrawal."))
		refuse()
		return TRUE
	var/total = count * rogue_coin_value(kind)
	if(!SSrogue_treasury.burn(account, total, "NERVELOCK withdraw by [user.real_name]"))
		to_chat(user, span_warning("My balance is insufficient."))
		refuse()
		return TRUE
	rogue_coins_out(total, user, kind, src)
	return TRUE
