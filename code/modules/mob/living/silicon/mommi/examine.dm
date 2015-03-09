/mob/living/silicon/robot/mommi/examine(mob/user)

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\living\silicon\mommi\examine.dm:10: msg += "<p>It's like a crab, but it has a utility tool on one arm and a crude metal claw on the other.  That, and you doubt it'd survive in an ocean for very long.</p>"
	msg += {"<p>It's like a crab, but it has a utility tool on one arm and a crude metal claw on the other.  That, and you doubt it'd survive in an ocean for very long.</p><span class='warning'>"}
	// END AUTOFIX
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	msg += "</span>"

	if(tool_state)
		var/obj/item/I = tool_state
		msg += "Its utitility claw is gripping \icon[I] [I.gender==PLURAL?"some":"a"] [I.name].\n"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed.\n"

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)	msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)			msg += "<span class='deadsay'>It looks completely unsalvageable.</span>\n"
	msg += "*---------*</span>"

	user << msg
