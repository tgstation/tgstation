//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/MapRender()
	set name = "MapRender"
	set desc = "Shows a high scale rendering of the current map in your browser."
	set hidden = 1

	if(alert("This will open the map render(s) in your browser. Are you sure?",,"Yes","No")=="No")
		return
	if(map)
		switch(map.nameShort)
			if("meta")
				src << link("http://ss13.nexisonline.net/img/map-renders/metaclub/")
			if("deff")
				src << link("http://ss13.nexisonline.net/img/map-renders/defficiency/")
			if("box")
				src << link("http://ss13.nexisonline.net/img/map-renders/tgstation/")
			else
				src << "<span class='warning'>No map render for [map.nameLong], bug nexis about it!</span>"
	return

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

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tt = say
\tx = swap-hand
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin
</font>"}

	src << hotkey_mode
	src << other
	if(holder)
		src << admin

// Needed to circumvent a bug where .winset does not work when used on the window.on-size event in skins.
// Used by /datum/html_interface/nanotrasen (code/modules/html_interface/nanotrasen/nanotrasen.dm)
/client/verb/_swinset(var/x as text)
	set name = ".swinset"
	set hidden = 1
	winset(src, null, x)


//adv. hotkey mode verbs & vars

/client/verb/hotkey_toggle()//toggles hotkey mode between on and off, respects selected type
	set name = ".Toggle hotkey mode"

	hotkeyon = !hotkeyon//toggle the var

	var/hotkeys = hotkeylist[hotkeytype]//get the list containing the hotkey names
	var/hotkeyname = hotkeys[hotkeyon ? "on" : "off"]//get the name of the hotkey, to not clutter winset() to much

	winset(usr, "mainwindow", "macro=[hotkeyname]")//change the hotkey
	usr << (hotkeyon ? "Hotkey mode enabled." : "Hotkey mode disabled.")//feedback to the user

	if(hotkeyon)//using an if statement because I don't want to clutter winset() with ? operators
		winset(usr, "mainwindow.hotkey_toggle", "is-checked=true")//checks the button
		winset(usr, "mapwindow.map", "focus=true")//sets mapwindow focus
	else
		winset(usr, "mainwindow.hotkey_toggle", "is-checked=false")//unchecks the button
		winset(usr, "mainwindow.input", "focus=true")//sets focus

/client/verb/hotkey_mode()//asks user for the hotkey type and changes the macro accordingly
	set name = "Set hotkey mode"
	set category = "Preferences"

	hotkeytype = input("Choose hotkey mode", "Hotkey mode") as null|anything in hotkeylist//ask the user for the hotkey type

	var/hotkeys = hotkeylist[hotkeytype]//get the list containing the hotkey names
	var/hotkeyname = hotkeys[hotkeyon ? "on" : "off"]//get the name of the hotkey, to not clutter winset() to much

	winset(usr, "mainwindow", "macro=[hotkeyname]")//change the hotkey
	usr << "Hotkey mode changed to [hotkeytype]."

/client/var/hotkeytype = "QWERTY" //what set of hotkeys is in use(defaulting to QWERTY because I can't be bothered to ake this save on SQL)
/client/var/hotkeyon = 0 //is the hotkey on?

/client/var/hotkeylist = list( //list defining hotkey types, look at lists in place for structure if adding any if the future
		"QWERTY" = list(
			"on" = "hotkeymode",
			"off" = "macro"),
		"AZERTY" = list(
			"on" = "AZERTYon",
			"off" = "AZERTYoff")
	)