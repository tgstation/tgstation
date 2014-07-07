/datum/mutations
	var/list/mutation_list = list()
	var/list/disability_list = list()
	var/list/condition_list = list()
	var/mob/holder = null

/datum/mutations/New(var/mob/holder)
	src.holder = holder

/datum/mutations/proc/add_mutation(var/mut, var/message=null, var/silent=0) // return 0 = already had; return 1 = given succesfully
	if (mut in mutation_list)
		return 0
	mutation_list.Add(mut)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(mut)
				if (TK)
					holder << "<span class='notice'>You feel smarter.</span>"
				if (COLD_RESISTANCE)
					holder << "<span class='notice'>Your body feels warm.</span>"
				if (XRAY)
					holder << "<span class='notice'>The walls suddenly disappear.</span>"
				if (HULK)
					holder << "<span class='notice'>Your muscles hurt.</span>"
				if (LASER)
					holder << "<span class='notice'>You feel pressure building behind your eyes.</span>"
				if (HEAL)
					holder << "<span class='notice'>You feel a pleasant warmth pulse throughout your body.</span>"
		//X-ray needs extra edits
		if (mut == XRAY)
			holder.sight |= SEE_MOBS|SEE_OBJS|SEE_TURFS
			holder.see_in_dark = 8
			holder.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		holder.update_mutations()

/datum/mutations/proc/has_mutation(var/mut)
	if (mut in mutation_list)
		return 1
	return 0

/datum/mutations/proc/remove_mutation(var/mut, var/message = null, var/silent=0)
	if (!(mut in mutation_list))
		return 0
	mutation_list.Remove(mut)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(mut)
				if (TK)
					holder << "<span class='danger'>You feel like you forget something.</span>"
				if (COLD_RESISTANCE)
					holder << "<span class='danger'>You feel a shiver go down your body.</span>"
				if (XRAY)
					holder << "<span class='danger'>Your vision suddenly gets foggy.</span>"
				if (HULK)
					holder << "<span class='danger'>You suddenly feel very weak.</span>"
				if (LASER)
					holder << "<span class='danger'>You feel your eyes relax.</span>"
				if (HEAL)
					holder << "<span class='danger'>You feel a cold pulse throughout your body.</span>"
		holder.update_mutations()

/datum/mutations/proc/clear_mutations()
	for (var/i in mutation_list)
		remove_mutation(i)

/datum/mutations/proc/add_disability(var/dis, var/message=null, var/silent=0)
	if (dis in disability_list)
		return 0
	disability_list.Add(dis)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(dis)
				if (CLUMSY)
					holder << "<span class='danger'>You feel lightheaded.</span>"
				if (NEARSIGHTED)
					holder << "<span class='danger'>Your eyes feel strange.</span>"
				if (EPILEPSY)
					holder << "<span class='danger'>You get a headache.</span>"
				if (COUGHING)
					holder << "<span class='danger'>You start coughing.</span>"
				if (TOURETTES)
					holder << "<span class='danger'>You twitch.</span>"
				if (NERVOUS)
					holder << "<span class='danger'>You feel nervous.</span>"
				if (BLIND)
					holder << "<span class='danger'>You can't seem to see anything.</span>"
				if (MUTE)
					holder << "<span class='danger'>You can't seem to say anything.</span>"
				if (DEAF)
					holder << "<span class='danger'>You can't seem to hear anything.</span>"
		if (dis == DEAF)
			holder.ear_deaf = 1
		holder.update_mutations()

/datum/mutations/proc/has_disability(var/dis)
	if (dis in disability_list)
		return 1
	return 0

/datum/mutations/proc/remove_disability(var/dis, var/message = null, var/silent=0)
	if (!(dis in disability_list))
		return 0
	disability_list.Remove(dis)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(dis)
				if (CLUMSY)
					holder << "<span class='notice'>You feel concentrated.</span>"
				if (NEARSIGHTED)
					holder << "<span class='notice'>Your eyes feel better.</span>"
				if (EPILEPSY)
					holder << "<span class='notice'>Your headache passes.</span>"
				if (COUGHING)
					holder << "<span class='notice'>You stop coughing.</span>"
				if (TOURETTES)
					holder << "<span class='notice'>You stop twitching.</span>"
				if (NERVOUS)
					holder << "<span class='notice'>You feel calmer.</span>"
				if (BLIND)
					holder << "<span class='notice'>You can see again.</span>"
				if (MUTE)
					holder << "<span class='notice'>You can talk again.</span>"
				if (DEAF)
					holder << "<span class='notice'>You can hear again.</span>"
		holder.update_mutations()

/datum/mutations/proc/clear_disabilities()
	for (var/i in disability_list)
		remove_disability(i)

/datum/mutations/proc/add_condition(var/con, var/message=null, var/silent=0)
	if (con in condition_list)
		return 0
	condition_list.Add(con)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(con) // Yeah, only one option, keeping switch in case more get added
				if (FAT)
					holder << "<span class='danger'>You suddenly feel blubbery!</span>"
		holder.update_mutations()

/datum/mutations/proc/has_condition(var/con)
	if (con in condition_list)
		return 1
	return 0

/datum/mutations/proc/remove_condition(var/con, var/message = null, var/silent=0)
	if (!(con in condition_list))
		return 0
	condition_list.Remove(con)
	if (holder)
		if (message)
			holder << message
		else if (!silent)
			switch(con)
				if (FAT)
					holder << "<span class='notice'>You feel fit again!</span>"
		holder.update_mutations()

/datum/mutations/proc/clear_conditions()
	for (var/i in condition_list)
		remove_condition(i)