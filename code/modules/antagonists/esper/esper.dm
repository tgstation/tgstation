// stubby stub. like a tree.

/datum/antagonist/esper
	name = "Esper"
	roundend_category = "espers"
	antagpanel_category = "Esper"
	job_rank = ROLE_ESPER

/datum/antagonist/esper/greet()
	to_chat(owner.current, "<b><font size=3 color=red>You are an esper, a sentient electrical current.</font></b>")
	to_chat(owner.current, "<b>As a sentient electrical current, you have the power to influence electrical devices. \
		Of course, you can't right now, because you've just come into existence. But you must use your high mobility \
		to subvert the station's devices in order to drain electricity from them, and grow in power.</b>")
	owner.announce_objectives()