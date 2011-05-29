/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1
	//	All admins should be authenticated, but... what if?
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(!src.mob)
		return
	if(src.mob.muted)
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("[key_name(src)] : [msg]")

	if (!msg)
		return

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>ADMIN([src.stealth ? pick("BADMIN", "hornygranny", "TLF", "scaredforshadows") : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in world)
		if(M.stat == 2 || (M.client && M.client.holder))
			M.show_message(rendered, 2)