/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(!src.mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		src << "\red You cannot send DSAY messages (muted)."
		return

	if (src.handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("[key_name(src)] : [msg]")

	if (!msg)
		return

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>ADMIN([src.holder.fakekey ? pick("BADMIN", "Fun Police", "Conspiracy", "ERP BLOCKER", "Button Masher", "MissPhaeron", "Turdicide", "hornigranny", "TLC", "scaredofshowers", "SXSI", "HerpEs", "Nerdrak", "Dickarrus", "Wario90900", "Deurpyn", "Fatbeaver", "Arrowage", "Intigaycy", "Hosin Hitter", "Cheridumb", "Petethegoatse", "HotelHabboLover", "Giacunt", "Muskrats", "FickleInspector", "Tankbutt", "Ulisex", "Scrotemis", "Sillnazi", "Stillachair", "cbdsm", "Un_Professional", "Doopenis", "Calasrear", "Quackink ",  "ANyan:3", "Slieve", "Pali-en269", "Teamcreep", "Agoatsie", "Zoomerdik", "LewdMechanic", "NemoPanFried", "LameMontgommery", "EndGameOver", "LocalDingus", "ThoughtlessNaps", "Sewage", "hbgay6969", "Cockdtbent", "Iranclanos", "Liarwhine", "Vagyina", "Nohrape", "Dumboner69", "Gaymarr", "Jesusfraud") : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in player_list)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat == DEAD || (M.client && M.client.holder && (M.client.prefs.toggles & CHAT_DEAD))) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			M.show_message(rendered, 2)

	feedback_add_details("admin_verb","D") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!