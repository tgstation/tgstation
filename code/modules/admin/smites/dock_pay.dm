/// Docks the target's pay
/datum/smite/dock_pay
	name = "Dock Pay"

/datum/smite/dock_pay/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, "<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return
	var/mob/living/carbon/dude = target
	var/obj/item/card/id/card = dude.get_idcard(TRUE)
	if (!card)
		to_chat(user, "<span class='warning'>[dude] does not have an ID card on!</span>", confidential = TRUE)
		return
	if (!card.registered_account)
		to_chat(user, "<span class='warning'>[dude] does not have an ID card with an account!</span>", confidential = TRUE)
		return
	if (card.registered_account.account_balance == 0)
		to_chat(user,  "<span class='warning'>ID Card lacks any funds. No pay to dock.</span>")
		return
	var/new_cost = input("How much pay are we docking? Current balance: [card.registered_account.account_balance] credits.", "BUDGET CUTS") as num|null
	if (!new_cost)
		return
	if (!(card.registered_account.has_money(new_cost)))
		to_chat(user,  "<span class='warning'>ID Card lacked funds. Emptying account.</span>")
		card.registered_account.bank_card_talk("[new_cost] credits deducted from your account based on performance review.")
		card.registered_account.account_balance = 0
	else
		card.registered_account.account_balance = card.registered_account.account_balance - new_cost
		card.registered_account.bank_card_talk("[new_cost] credits deducted from your account based on performance review.")
	SEND_SOUND(target, 'sound/machines/buzz-sigh.ogg')
