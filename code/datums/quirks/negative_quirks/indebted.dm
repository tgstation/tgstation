/datum/quirk/indebted
	name = "Indebted"
	desc = "Bad life decisions, medical bills, student loans, whatever it may be, you've incurred quite the debt. A portion of all you receive will go towards extinguishing it."
	icon = FA_ICON_DOLLAR
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_HIDE_FROM_SCAN
	value = -2
	medical_record_text = "Alas, the patient struggled to scrape together enough money to pay the checkup bill."
	hardcore_value = 2

/datum/quirk/indebted/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!human_holder.account_id)
		return
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[human_holder.account_id]"]
	var/debt = PAYCHECK_CREW * rand(275, 325)
	account.account_debt += debt
	RegisterSignal(account, COMSIG_BANK_ACCOUNT_DEBT_PAID, PROC_REF(on_debt_paid))
	to_chat(client_source.mob, span_warning("You remember, you've a hefty, [debt] credits debt to pay..."))

///Once the debt is extinguished, award an achievement and a pin for actually taking care of it.
/datum/quirk/indebted/proc/on_debt_paid(datum/bank_account/source)
	SIGNAL_HANDLER
	if(source.account_debt)
		return
	UnregisterSignal(source, COMSIG_BANK_ACCOUNT_DEBT_PAID)
	///The debt was extinguished while the quirk holder was logged out, so let's kindly award it once they come back.
	if(!quirk_holder.client)
		RegisterSignal(quirk_holder, COMSIG_MOB_LOGIN, PROC_REF(award_on_login))
	else
		quirk_holder.client.give_award(/datum/award/achievement/misc/debt_extinguished, quirk_holder)
	podspawn(list(
		"target" = get_turf(quirk_holder),
		"style" = /datum/pod_style/advanced,
		"spawn" = /obj/item/clothing/accessory/debt_payer_pin,
	))

/datum/quirk/indebted/proc/award_on_login(mob/source)
	SIGNAL_HANDLER
	quirk_holder.client.give_award(/datum/award/achievement/misc/debt_extinguished, quirk_holder)
	UnregisterSignal(source, COMSIG_MOB_LOGIN)
