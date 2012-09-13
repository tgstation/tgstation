/client/verb/wiki()
	set name = "wiki"
	set desc = "Visit the wiki."
	set hidden = 1
	if( config.wikiurl )
		if(alert("This will open the wiki in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.wikiurl)
	else
		src << "\red The wiki URL is not set in the server configuration."
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.forumurl )
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		src << "\red The forum URL is not set in the server configuration."
	return

#define RULES_FILE "config/rules.html"
/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1
	src << browse(file(RULES_FILE), "window=rules;size=480x320")
#undef RULES_FILE

/client/verb/a_intent_left()
	set name = "a-intent-left"
	set hidden = 1

	if(ishuman(usr) || istype(usr,/mob/living/carbon/alien/humanoid) || islarva(usr))
		switch(usr.a_intent)
			if("help")
				usr.a_intent = "hurt"
				usr.hud_used.action_intent.icon_state = "intent_hurt"
			if("disarm")
				usr.a_intent = "help"
				usr.hud_used.action_intent.icon_state = "intent_help"
			if("grab")
				usr.a_intent = "disarm"
				usr.hud_used.action_intent.icon_state = "intent_disarm"
			if("hurt")
				usr.a_intent = "grab"
				usr.hud_used.action_intent.icon_state = "intent_grab"
	else if(issilicon(usr))
		if(usr.a_intent == "help")
			usr.a_intent = "hurt"
			usr.hud_used.action_intent.icon_state = "harm"
		else
			usr.a_intent = "help"
			usr.hud_used.action_intent.icon_state = "help"

/client/verb/a_intent_right()
	set name = "a-intent-right"
	set hidden = 1

	if(ishuman(usr) || istype(usr,/mob/living/carbon/alien/humanoid) || islarva(usr))
		switch(usr.a_intent)
			if("help")
				usr.a_intent = "disarm"
				usr.hud_used.action_intent.icon_state = "intent_disarm"
			if("disarm")
				usr.a_intent = "grab"
				usr.hud_used.action_intent.icon_state = "intent_grab"
			if("grab")
				usr.a_intent = "hurt"
				usr.hud_used.action_intent.icon_state = "intent_hurt"
			if("hurt")
				usr.a_intent = "help"
				usr.hud_used.action_intent.icon_state = "intent_help"
	else if(issilicon(usr))
		if(usr.a_intent == "help")
			usr.a_intent = "hurt"
			usr.hud_used.action_intent.icon_state = "harm"
		else
			usr.a_intent = "help"
			usr.hud_used.action_intent.icon_state = "help"


/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)\n
TAB = toggle hotkey-mode\n
a = left\n
s = down\n
d = east\n
w = up\n
q = drop\n
e = equip\n
r = throw\n
t = say\n
x = swap-hand\n
f = cycle-intents-left\n
g = cycle-intents-right\n
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)\n
Ctrl+a = left\n
Ctrl+s = down\n
Ctrl+d = east\n
Ctrl+w = up\n
Ctrl+q = drop\n
Ctrl+e = equip\n
Ctrl+r = throw\n
Ctrl+x = swap-hand\n
Ctrl+f = cycle-intents-left\n
Ctrl+g = cycle-intents-right\n
</font>"}

	var/admin = {"<font color='purple'>
Admin:\n
F5 = toggle-admin-observe (WIP)
F6 = player-panel-new
F7 = admin-pm
F8 = (WIP)
</font>"}

	src << hotkey_mode
	src << other
	if(holder)
		src << admin
