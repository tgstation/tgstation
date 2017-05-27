/datum/antagonist/iaa

/datum/antagonist/iaa/apply_innate_effects()
	.=..() //in case the base is used in future
	if(owner&&owner.current)
		give_pinpointer(owner.current)

/datum/antagonist/iaa/remove_innate_effects()
	.=..()
	if(owner&&owner.current)
		owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer)
		

