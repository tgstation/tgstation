/**
 * Component that makes basic mobs' melee attacks steal money from the target's ID card.
 * Plundered money is stored and dropped on death or removal of the component.
 */
/datum/component/plundering_attacks
	/// How many credits do we steal per attack?
	var/plunder_amount = 25
	/// How much plunder do we have stored?
	var/plunder_stored = 0


/datum/component/plundering_attacks/Initialize(
	plunder_amount = 25,
)
	. = ..()
	if(!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.plunder_amount = plunder_amount

/datum/component/plundering_attacks/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(attempt_plunder))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(drop_plunder))

/datum/component/plundering_attacks/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_POST_ATTACKINGTARGET, COMSIG_LIVING_DEATH))
	drop_plunder()

/datum/component/plundering_attacks/proc/attempt_plunder(mob/living/attacker, mob/living/carbon/human/target, success)
	SIGNAL_HANDLER
	if(!istype(target) || !success)
		return
	var/obj/item/card/id/id_card = target.wear_id?.GetID()
	if(isnull(id_card))
		return
	var/datum/bank_account/account_to_rob = id_card.registered_account
	if(isnull(account_to_rob) || account_to_rob.account_balance == 0)
		return

	var/amount_to_steal = plunder_amount
	if(account_to_rob.account_balance < plunder_amount) //If there isn't enough, just take what's left
		amount_to_steal = account_to_rob.account_balance
	plunder_stored += amount_to_steal
	account_to_rob.adjust_money(-amount_to_steal)
	account_to_rob.bank_card_talk("Transaction confirmed! Transferred [amount_to_steal] credits to \<NULL_ACCOUNT\>!")

/datum/component/plundering_attacks/proc/drop_plunder()
	SIGNAL_HANDLER
	if(plunder_stored == 0)
		return
	new /obj/item/holochip(get_turf(parent), plunder_stored)
	plunder_stored = 0
