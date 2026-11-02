/**
 * PURITY (Ratwood code/modules/roguetown/roguemachine/drugmachine.dm): the bathhouse's vice machine. Coins go in, dust, zigs,
 * lipstick and wine come out, each with the Crown's import tariff on top unless the Bathmaster stopped paying it. Every few
 * minutes a cut of what was spent (a tenth, a quarter once bought up, a half after that) gathers in the machine's secret
 * purse, which the Bathmaster banks less the Crown's duty or takes as untraced coin. The Nightmaster's key locks it. While the
 * Ordinance of the Baths holds, the tariff and the duty go to the Church with its tithe (collect_bathhouse_tariff()).
 */

/// The cut tiers the Bathmaster buys up (Ratwood DRUGRADE_MONEYA, DRUGRADE_MONEYB).
#define PURITY_CUT_BASE 0
#define PURITY_CUT_A 1
#define PURITY_CUT_B 2

/// Ratwood's wares of the PURITY: item path, least and most price, name on the shelf. Wares not ported yet are skipped.
GLOBAL_LIST_INIT(rogue_purity_wares, list(
	list("/obj/item/reagent_containers/powder/spice", 41, 55, "chuckledust"),
	list("/obj/item/reagent_containers/powder/ozium", 6, 15, "ozium"),
	list("/obj/item/reagent_containers/powder/moondust", 13, 25, "moondust"),
	list("/obj/item/clothing/mask/cigarette/rollie/cannabis", 12, 18, "swampweed zig"),
	list("/obj/item/clothing/mask/cigarette/rollie/mentha", 6, 11, "mentha zig"),
	list("/obj/item/clothing/mask/cigarette/rollie/nicotine", 5, 10, "zig"),
	list("/obj/item/storage/fancy/shhig", 40, 60, "Shhig brand premium zigs"),
	list("/obj/item/alch/transisdust", 80, 120, "sui dust"),
	list("/obj/item/portable_hookah", 90, 130, "portable hookah"),
	list("/obj/item/azure_lipstick", 33, 50, "red lipstick"),
	list("/obj/item/azure_lipstick/jade", 33, 50, "jade lipstick"),
	list("/obj/item/azure_lipstick/purple", 33, 50, "purple lipstick"),
	list("/obj/item/azure_lipstick/black", 33, 50, "black lipstick"),
	list("/obj/item/quiver/zigs", 5, 10, "zigbox, empty"),
	list("/obj/item/reagent_containers/glass/bottle/alchemical/fermented_crab", 50, 70, "fermented crab"),
	list("/obj/item/reagent_containers/glass/bottle/rogue/emberwine", 100, 140, "unlabeled emberwine"),
))

/obj/structure/roguemachine/drugmachine
	var/locked = FALSE
	var/lockid = "nightman"
	var/motto = "PURITY - In the name of pleasure."
	/// Ware path -> list("PRICE" = base price, "NAME" = shelf name), priced once per round.
	var/list/wares = list()
	/// The Bathmaster stopped paying the Crown's tariff (Ratwood DRUGRADE_NOTAX).
	var/dodging_tax = FALSE
	/// PURITY_CUT_*: how much of the takings the Bathmaster's secret purse gets.
	var/cut_tier = PURITY_CUT_BASE
	/// Base prices paid since the last cut was taken (Ratwood recent_payments).
	var/recent_payments = 0
	/// The Bathmaster's secret purse (Ratwood secret_budget).
	var/secret_budget = 0
	/// When the next cut is taken.
	var/next_cut = 0
	var/tariff_paid = 0
	var/tariff_dodged = 0

/obj/structure/roguemachine/drugmachine/Initialize(mapload)
	. = ..()
	for(var/list/entry as anything in GLOB.rogue_purity_wares)
		var/ware_type = text2path(entry[1])
		if(ware_type)
			wares[ware_type] = list("PRICE" = rand(entry[2], entry[3]), "NAME" = entry[4])
	schedule_cut()
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/structure/roguemachine/drugmachine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/roguemachine/drugmachine/update_overlays()
	. = ..()
	set_light(1, 1, "#1b7bf1")
	. += mutable_appearance(icon, "vendor-drug")

/obj/structure/roguemachine/drugmachine/examine(mob/user)
	. = ..()
	. += span_info("Insert coins and buy what you came for. The Nightmaster's key locks it.")

/obj/structure/roguemachine/drugmachine/proc/schedule_cut()
	next_cut = world.time + rand(rogue_value("machines_purity_cut_period_min"), rogue_value("machines_purity_cut_period_max"))

/// The share of the takings the secret purse gets at this tier (Ratwood 10%, 25%, 50%).
/obj/structure/roguemachine/drugmachine/proc/cut_share()
	switch(cut_tier)
		if(PURITY_CUT_A)
			return rogue_value("machines_purity_cut_a")
		if(PURITY_CUT_B)
			return rogue_value("machines_purity_cut_b")
	return rogue_value("machines_purity_cut_base")

/// Ratwood process(): every six to eight minutes the cut of what was spent goes to the secret purse.
/obj/structure/roguemachine/drugmachine/process(seconds_per_tick)
	if(world.time < next_cut)
		return
	schedule_cut()
	if(recent_payments <= 0)
		return
	var/cut = recent_payments * cut_share()
	recent_payments = 0
	secret_budget += cut
	for(var/datum/bank_account/rogue/account as anything in SSrogue_treasury.accounts)
		if(account.job_title() == JOB_ROCKHILL_BATHMASTER)
			account.bank_card_talk("Income from PURITY: [cut]m")
	SStgui.update_uis(src)

/obj/structure/roguemachine/drugmachine/proc/is_proprietor(mob/user)
	return user?.mind?.assigned_role?.title == JOB_ROCKHILL_BATHMASTER

/obj/structure/roguemachine/drugmachine/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		if(!rockhill_key_fits(tool, lockid))
			to_chat(user, span_warning("Wrong key."))
			return ITEM_INTERACT_BLOCKING
		locked = !locked
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		if(locked)
			SStgui.close_uis(src)
		else
			ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		if(take_coins(tool, user))
			playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/roguemachine/drugmachine/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	if(locked)
		to_chat(user, span_warning("It's locked. Of course."))
		return TRUE
	return ..()

/obj/structure/roguemachine/drugmachine/ui_interact(mob/user, datum/tgui/ui)
	if(locked)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		ui = new(user, src, "RoguePurity", name)
		ui.open()

/obj/structure/roguemachine/drugmachine/proc/tariff_on(base)
	return dodging_tax ? 0 : floor(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * base)

/obj/structure/roguemachine/drugmachine/ui_data(mob/user)
	var/list/data = list()
	var/rate = SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT)
	data["motto"] = motto
	data["budget"] = budget
	data["is_proprietor"] = is_proprietor(user)
	data["dodging"] = dodging_tax
	data["tariff_rate_pct"] = round(rate * 100)
	data["tariff_paid"] = tariff_paid
	data["tariff_evaded"] = tariff_dodged
	data["cut_pct"] = round(cut_share() * 100)
	data["cut_tier"] = cut_tier
	data["recent_payments"] = recent_payments
	data["secret_budget"] = floor(secret_budget)
	data["upgrade_a_cost"] = rogue_value("machines_purity_cut_a_cost")
	data["upgrade_b_cost"] = rogue_value("machines_purity_cut_b_cost")
	var/cut = floor(secret_budget)
	data["withdraw_tax"] = floor(cut * rate)
	data["withdraw_net"] = cut - floor(cut * rate)
	var/list/items = list()
	for(var/ware_type in wares)
		var/list/ware = wares[ware_type]
		items += list(list(
			"ref" = "[ware_type]",
			"name" = ware["NAME"],
			"price_base" = ware["PRICE"],
			"price_tariff" = tariff_on(ware["PRICE"]),
		))
	data["items"] = items
	return data

/obj/structure/roguemachine/drugmachine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || locked)
		return
	var/mob/living/user = ui.user
	switch(action)
		if("change")
			return_change(user)
			return TRUE
		if("buy")
			var/ware_type = text2path(params["ref"])
			if(ware_type && wares[ware_type])
				buy(ware_type, user)
			return TRUE
		if("toggle_tax")
			if(!is_proprietor(user))
				return TRUE
			dodging_tax = !dodging_tax
			playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
			return TRUE
		if("unlock_cut")
			if(is_proprietor(user))
				unlock_cut(params["level"] == "b" ? PURITY_CUT_B : PURITY_CUT_A)
			return TRUE
		if("withdraw_cut")
			if(is_proprietor(user))
				withdraw_cut(user, params["mode"] == "bank")
			return TRUE

/// Ratwood "buy": the price and the tariff come from the budget; the tariff goes to the Crown's Purse unless dodged.
/obj/structure/roguemachine/drugmachine/proc/buy(ware_type, mob/living/user)
	var/base = wares[ware_type]["PRICE"]
	var/full_tariff = floor(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * base)
	var/price = base + (dodging_tax ? 0 : full_tariff)
	if(budget < price)
		say("Not enough!")
		return FALSE
	budget -= price
	recent_payments += base
	if(dodging_tax)
		tariff_dodged += full_tariff
	else
		SSrogue_treasury.collect_bathhouse_tariff(full_tariff, base, name)
		tariff_paid += full_tariff
	playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
	var/obj/item/ware = new ware_type(get_turf(src))
	user.put_in_hands(ware)
	return TRUE

/// The Bathmaster buys a bigger cut from the budget, the quarter first (Ratwood unlock_cut).
/obj/structure/roguemachine/drugmachine/proc/unlock_cut(tier)
	if(tier != cut_tier + 1)
		return
	var/cost = rogue_value(tier == PURITY_CUT_B ? "machines_purity_cut_b_cost" : "machines_purity_cut_a_cost")
	if(budget < cost)
		say("Ask again when you're serious.")
		playsound(src, ROGUE_SOUND_MACHINE_TALK, 100, FALSE, -1)
		return
	budget -= cost
	cut_tier = tier
	playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)

/**
 * Ratwood withdraw_cut: banked, the cut goes to the Bathmaster's account less the Crown's import duty; taken as coin, it leaves
 * untraced and the duty is dodged.
 */
/obj/structure/roguemachine/drugmachine/proc/withdraw_cut(mob/living/user, to_bank)
	var/cut = floor(secret_budget)
	if(cut < 1)
		say("There is no mammon to move, Master.")
		return
	var/duty = floor(cut * SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT))
	if(!to_bank)
		secret_budget -= cut
		rogue_coins_out(cut, user, null, src)
		tariff_dodged += duty
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		return
	var/deposit = cut - duty
	if(deposit < 1)
		say("The duty would swallow your whole cut, Master. Take it in coin instead.")
		return
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account || !SSrogue_treasury.mint(account, deposit, "PURITY cut"))
		say("I could not put your cut in your account, Master. My apologies.")
		return
	secret_budget -= cut
	var/datum/bank_account/rogue/dues = SSrogue_treasury.collect_bathhouse_tariff(duty, cut, name)
	tariff_paid += duty
	say("[deposit]m to your account, Master. The [dues == SSrogue_treasury.crown_purse ? "Crown" : "Church"] keeps [duty]m.")
	playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)

#undef PURITY_CUT_BASE
#undef PURITY_CUT_A
#undef PURITY_CUT_B
