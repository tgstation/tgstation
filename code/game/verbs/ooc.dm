
var/global/normal_ooc_colour = "#002eb8"

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	if(!mob)	return
	if(IsGuestKey(key))
		src << "Guests may not use OOC."
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	if(!(prefs.toggles & CHAT_OOC))
		src << "\red You have OOC muted."
		return

	if(!holder)
		if(!ooc_allowed)
			src << "\red OOC is globally muted"
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			usr << "\red OOC for dead mobs has been turned off."
			return
		if(prefs.muted & MUTE_OOC)
			src << "\red You cannot use OOC (muted)."
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			src << "<B>Advertising other servers is not allowed.</B>"
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc("[mob.name]/[key] : [msg]")

	var/display_colour = normal_ooc_colour
	if(holder && !holder.fakekey)
		display_colour = "#0099cc"	//light blue
		if(holder.rights & R_MOD && !(holder.rights & R_ADMIN))
			display_colour = "#184880"	//dark blue
		else if(holder.rights & R_ADMIN)
			if(config.allow_admin_ooccolor)
				display_colour = src.prefs.ooccolor
			else
				display_colour = "#b82e00"	//orange

	for(var/client/C in clients)
		if(C.prefs.toggles & CHAT_OOC)
			var/display_name = src.key
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			C << "<font color='[display_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>"

			/*
			if(holder)
				if(!holder.fakekey || C.holder)
					if(holder.rights & R_ADMIN)
						C << "<font color=[config.allow_admin_ooccolor ? src.prefs.ooccolor :"#b82e00" ]><b><span class='prefix'>OOC:</span> <EM>[key][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>"
					else if(holder.rights & R_MOD)
						C << "<font color=#184880><b><span class='prefix'>OOC:</span> <EM>[src.key][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>"
					else
						C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[src.key]:</EM> <span class='message'>[msg]</span></span></font>"

				else
					C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : src.key]:</EM> <span class='message'>[msg]</span></span></font>"
			else
				C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[src.key]:</EM> <span class='message'>[msg]</span></span></font>"
			*/

/client/proc/set_ooc(newColor as color)
	set name = "Set Player OOC Colour"
	set desc = "Set to yellow for eye burning goodness."
	set category = "Fun"
	normal_ooc_colour = newColor
