/client/proc/request_more_opfor()
	set category = "Admin.Fun"
	set name = "Request OPFOR"
	set desc = "Request players sign up for opfor if they have antag on."

	var/asked = 0
	for(var/mob/living/carbon/human/human in GLOB.alive_player_list)
		to_chat(human, examine_block(span_greentext("The admins are looking for OPFOR players, if you're interested, sign up in the OOC tab!")))
		asked++
	message_admins("[ADMIN_LOOKUP(usr)] has requested more OPFOR players! (Asked: [asked] players)")

/client/proc/view_opfors()
	set name = "View OPFORs"
	set category = "Admin.Game"
	if(holder)
		var/list/dat = list("<html>")
		dat += SSopposing_force.get_check_antag_listing()
		dat += "</html>"
		usr << browse(dat.Join(), "window=roundstatus;size=500x500")
		log_admin("[key_name(usr)] viewed OPFORs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "View OPFORs")
