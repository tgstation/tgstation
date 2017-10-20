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

/datum/brain_trauma/severe/paralysis/on_lose()
	owner.SetKnockdown(0)
	..()

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	scan_desc = "traumatic narcolepsy"
	gain_text = "<span class='warning'>You have a constant feeling of drowsiness...</span>"
	lose_text = "<span class='notice'>You feel awake and aware again.</span>"

/datum/brain_trauma/severe/narcolepsy/on_life()
	..()
	if(owner.IsSleeping())
		return
	var/sleep_chance = 1
	if(owner.m_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(owner.drowsyness)
		sleep_chance += 3
	if(prob(sleep_chance))
		to_chat(owner, "<span class='warning'>You fall asleep.</span>")
		owner.Sleeping(60)
	else if(!owner.drowsyness && prob(sleep_chance * 2))
		to_chat(owner, "<span class='warning'>You feel tired...</span>")
		owner.drowsyness += 10

GLOBAL_LIST_EMPTY(agnosiac_mobs)

/datum/brain_trauma/severe/agnosia
	name = "Agnosia"
	desc = "Patient cannot tell people apart."
	scan_desc = "chronic agnosia"
	gain_text = "<span class='warning'>You can't remember anyone's face...</span>"
	lose_text = "<span class='notice'>You suddenly remember who everyone is.</span>"

/datum/brain_trauma/severe/agnosia/on_gain()
	..()
	owner.disabilities |= AGNOSIA
	GLOB.agnosiac_mobs += owner
	for(var/datum/atom_hud/alternate_appearance/basic/agnosia/AA in GLOB.active_agnosia_appearances)
		AA.onNewMob(owner)

/datum/brain_trauma/severe/agnosia/on_lose()
	..()
	GLOB.agnosiac_mobs -= owner
	for(var/datum/atom_hud/alternate_appearance/basic/agnosia/AA in GLOB.active_agnosia_appearances)
		AA.remove_hud_from(owner)
	owner.disabilities &= ~AGNOSIA