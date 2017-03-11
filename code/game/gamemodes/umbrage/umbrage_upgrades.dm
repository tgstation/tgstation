//Passive upgrades that can be bought with lucidity. Some can be purchased repeatedly to stack benefits.
/datum/umbrage_upgrade
	var/name = "umbrage umbrage"
	var/desc = "This shouldn't exist."
	var/lucidity_cost = -1 //Lucidity required to buy the upgrade. Set this to -1 to prevent purchase.
	var/mob/living/owner //The owner of the upgrade

/datum/umbrage_upgrade/Destroy()
	Forget()
	return ..()

/datum/umbrage_upgrade/proc/GiveUpgrade(mob/living/L) //Gives an upgrade to the selected umbrage.
	owner = L
	return Acquire()

/datum/umbrage_upgrade/proc/Acquire() //Things that happen when we gain the upgrade
	return

/datum/umbrage_upgrade/proc/Forget() //Things that happen when we lose the upgrade (should never call but hey)
	return

//Opwnxqnj Sigils: Increases resistance to light burn by 50%.
/datum/umbrage_upgrade/light_burn
	name = "Opwnxqnj Sigils"
	desc = "Empowers the sigils traced on your body, decreasing light burn damage by 50%."
	lucidity_cost = 1
