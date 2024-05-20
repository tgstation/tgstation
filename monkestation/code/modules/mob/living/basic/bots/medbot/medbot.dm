/mob/living/basic/bot/medbot/proc/link_techweb(datum/techweb/techweb)
	if(QDELETED(techweb))
		return FALSE
	if(!QDELETED(linked_techweb))
		UnregisterSignal(linked_techweb, COMSIG_TECHWEB_ADD_DESIGN)
	linked_techweb = techweb
	RegisterSignal(linked_techweb, COMSIG_TECHWEB_ADD_DESIGN, PROC_REF(on_techweb_add_design))
	sync_tech()

/mob/living/basic/bot/medbot/proc/on_techweb_add_design(datum/source, datum/design/design, custom)
	SIGNAL_HANDLER
	if(istype(design, /datum/design/surgery/healing))
		addtimer(CALLBACK(src, PROC_REF(sync_tech)), 2.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE) // signal is called BEFORE design is added, plus avoids spam if multiple are researched in quick succession

/mob/living/basic/bot/medbot/proc/sync_tech()
	if(QDELETED(linked_techweb))
		return FALSE
	var/oldheal_amount = heal_amount
	var/tech_boosters
	for(var/index in linked_techweb.researched_designs)
		var/datum/design/surgery/healing/design = SSresearch.techweb_design_by_id(index)
		if(!istype(design))
			continue
		tech_boosters++
	if(tech_boosters)
		heal_amount = (round(tech_boosters * 0.5, 0.1) * initial(heal_amount)) + initial(heal_amount) //every 2 tend wounds tech gives you an extra 100% healing, adjusting for unique branches (combo is bonus)
		if(oldheal_amount < heal_amount)
			speak("New knowledge found! Surgical efficacy improved to [round(heal_amount/initial(heal_amount)*100)]%!")
	return TRUE
