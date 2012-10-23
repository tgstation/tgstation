mob/proc/flash_pain()
	flick("pain",pain)

mob/var/list/pain_stored = list()
mob/var/last_pain_message = ""
mob/var/next_pain_time = 0

// partname is the name of a body part
// amount is a num from 1 to 100
mob/proc/pain(var/partname, var/amount, var/force, var/burning = 0)
	if(stat >= 2) return
	if(world.time < next_pain_time && !force)
		return
	if(amount > 10 && istype(src,/mob/living/carbon/human))
		if(src:paralysis)
			src:paralysis = max(0, src:paralysis-round(amount/10))
	if(amount > 50 && prob(amount / 5))
		src:drop_item()
	var/msg
	if(burning)
		switch(amount)
			if(1 to 10)
				msg = "\red <b>Your [partname] burns.</b>"
			if(11 to 90)
				flash_weak_pain()
				msg = "\red <b><font size=2>Your [partname] burns badly!</font></b>"
			if(91 to 10000)
				flash_pain()
				msg = "\red <b><font size=3>OH GOD! Your [partname] is on fire!</font></b>"
	else
		switch(amount)
			if(1 to 10)
				msg = "<b>Your [partname] hurts.</b>"
			if(11 to 90)
				flash_weak_pain()
				msg = "<b><font size=2>Your [partname] hurts badly.</font></b>"
			if(91 to 10000)
				flash_pain()
				msg = "<b><font size=3>OH GOD! Your [partname] is hurting terribly!</font></b>"
	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		src << msg
	next_pain_time = world.time + (100 - amount)

mob/living/carbon/human/proc/handle_pain()
	// not when sleeping
	if(stat >= 2) return
	if(reagents.has_reagent("tramadol"))
		return
	if(reagents.has_reagent("oxycodone"))
		return
	if(analgesic)
		return
	var/maxdam = 0
	var/datum/organ/external/damaged_organ = null
	for(var/datum/organ/external/E in organs)
		// amputated limbs don't cause pain
		if(E.amputated) continue

		var/dam = E.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)) )
			damaged_organ = E
			maxdam = dam
	if(damaged_organ)
		pain(damaged_organ.display_name, maxdam, 0)
