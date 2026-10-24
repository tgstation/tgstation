/datum/quirk/well_connected
	name = "Well Connected"
	desc = "You know a guy, who knows a guy, who can get you a good deal on anything. \
		Privately ordered items from Cargo and even black market items are cheaper for you."
	icon = FA_ICON_MONEY_BILL_TRANSFER
	value = 6
	gain_text = span_notice("You know a guy.")
	lose_text = span_danger("You had a falling out with your contacts.")
	mail_goodies = list(
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey,
		/obj/item/reagent_containers/cup/glass/bottle/wine,
	)

	VAR_PRIVATE/datum/weakref/affected_account

/datum/quirk/well_connected/add_unique(client/client_source)
	var/datum/bank_account/account = quirk_holder.get_bank_account()
	if(isnull(account))
		return

	affected_account = WEAKREF(account)
	account.private_order_cost_modifier *= 0.8
	account.goody_order_cost_modifier *= 0.8
	account.black_market_cost_modifier *= 0.8
	account.crab_17_drain_rate_modifier *= 0.5

/datum/quirk/well_connected/remove()
	var/datum/bank_account/account = affected_account?.resolve()
	if(isnull(account))
		return

	account.private_order_cost_modifier /= 0.8
	account.goody_order_cost_modifier /= 0.8
	account.black_market_cost_modifier /= 0.8
	account.crab_17_drain_rate_modifier /= 0.5
	affected_account = null
