DATASYSTEM_DEF(security)
	name = "Security"

	/// Standard CentCom fine for non-antagonist criminals.
	var/fine = -500
	/// List of criminals apprehended.
	var/list/datum/weakref/criminals_apprehended = list()
	/// Last criminal bounty
	var/last_bounty = 0
	/// Labor camp teleport zones
	var/list/labor_camp_warps = list()
	/// Total points accumulated by the security department.
	var/total_points = 0
	/// Non-antagonist criminals apprehended.
	var/warcrimes = 0


/// Adds a weakref of the criminal to the list and awards points if the criminal is an antagonist.
/datum/system/security/proc/add_new_criminal(mob/living/baddie)
	criminals_apprehended += WEAKREF(baddie)

	var/datum/bank_account/sec_account = SSeconomy.get_dep_account(ACCOUNT_SEC)

	if(!baddie.mind?.has_antag_datum(/datum/antagonist))
		warcrimes++
		last_bounty = fine
		sec_account.adjust_money(fine, "CentCom Fine")
		return FALSE

	var/amount = rand(500, 1200)
	last_bounty = amount
	total_points += amount
	sec_account.adjust_money(amount, "Criminal Bounty")

	return TRUE
