//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "extensive damage to the brain's language center"
	gain_text = "<span class='warning'>You forget how to speak!</span>"
	lose_text = "<span class='notice'>You suddenly remember how to speak.</span>"

/datum/brain_trauma/severe/mute/on_gain()
	owner.disabilities |= MUTE
	..()

//no fiddling with genetics to get out of this one
/datum/brain_trauma/severe/mute/on_life()
	if(!(owner.disabilities & MUTE))
		on_gain()
	..()

/datum/brain_trauma/severe/mute/on_lose()
	owner.disabilities &= ~MUTE
	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "extensive damage to the brain's frontal lobe"
	gain_text = "<span class='warning'>You can't see!</span>"
	lose_text = "<span class='notice'>Your vision returns.</span>"

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind()
	..()

//no fiddling with genetics to get out of this one
/datum/brain_trauma/severe/blindness/on_life()
	if(!(owner.disabilities & BLIND))
		on_gain()
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind()
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control its motor functions."
	scan_desc = "cerebral paralysis"
	gain_text = "<span class='warning'>You can't feel your body anymore!</span>"
	lose_text = "<span class='notice'>You can feel your limbs again!</span>"

/datum/brain_trauma/severe/paralysis/on_life()
	owner.Knockdown(200, ignore_canknockdown = TRUE)
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.SetKnockdown(0)
	..()