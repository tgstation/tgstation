//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Renew.

/datum/status_effect/renew //Renewing light knits shut the target's wounds, healing 5 brute/burn per second. Lasts for 5 seconds.
	name = "Renew"
	desc = "Healing light wraps itself around your wounds."
	duration = 5

/datum/status_effect/renew/on_apply()
	owner.visible_message("<span class='notice'>Healing light wraps around [owner]'s body!</span>", "<span class='notice'>Healing light wraps around your body!</span>")
	playsound(owner, 'sound/magic/Staff_Healing.ogg', 50, 1)

/datum/status_effect/renew/tick()
	owner.adjustBruteLoss(-5)
	owner.adjustFireLoss(-5)

/datum/status_effect/renew/on_remove()
	owner.visible_message("<span class='warning'>The healing light around [owner] fades away!</span>", "<span class='warning'>The healing light fades away!</span>")
