//Redefining objective New and Destroy to avoid editing TG original files.

/datum/objective/New(text)
	GLOB.objectives += src
	..()

/datum/objective/Destroy()
	GLOB.objectives -= src
	return ..()
