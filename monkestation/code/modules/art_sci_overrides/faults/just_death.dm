/datum/artifact_fault/death
	name = "Instant Death Fault"
	trigger_chance = 0.25 //You are so unlucky if this procs
	visible_message = "blows someone up with mind."

/datum/artifact_fault/death/on_trigger(datum/component/artifact/component)
	var/list/mobs = list()
	var/mob/living/carbon/human

	var/center_turf = get_turf(component.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/carbon/mob in range(rand(3, 4), center_turf))
		mobs += mob
	human = pick(mobs)
	if(!human)
		return
	component.holder.Beam(human, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	human.death(FALSE)
