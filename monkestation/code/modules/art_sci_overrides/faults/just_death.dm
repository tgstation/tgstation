/datum/artifact_fault/death
	name = "Instant Death"
	trigger_chance = 1
	visible_message = "blows someone up with mind."


/datum/artifact_fault/death/on_trigger(datum/component/artifact/component)
	var/list/mobs = list()
	var/mob/living/carbon/human
	for(var/mob/living/carbon/mob in range(rand(3, 4), component.holder))
		mobs += mob
	human = pick(mobs)
	if(!human)
		return
	component.holder.Beam(human, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	human.death(FALSE)
