/*
Tooltips v1.0 - 19/10/15
Developed by Wire (#goonstation on irc.synirc.net)
- Initial release

Configuration:
- Set control to the correct skin element (remember to actually place the skin element)
- Set file to the correct path for the .html file (remember to actually place the html file)
- Attach the datum to the user client on login, e.g.
	/client/New()
		src.tooltips = new /datum/tooltip(src)

Usage:
- Define mouse event procs on your (probably HUD) object and simply call the show and hide procs respectively:
	/obj/screen/hud
		MouseEntered(location, control, params)
			usr.client.tooltip.show(params, title = src.name, content = src.desc)

		MouseExited()
			usr.client.tooltip.hide()

Customization:
- Theming can be done by passing the theme var to show() and using css in the html file to change the look
- For your convenience some pre-made themes are included

Notes:
- You may have noticed 90% of the work is done via javascript on the client. Gotta save those cycles man.
- This is entirely untested in any other codebase besides goonstation so I have no idea if it will port nicely. Good luck!
*/


/datum/tooltip
	var
		client/owner
		control = "mainwindow.tooltip"
		file = 'code/modules/tooltip/tooltip.html'
		showing = 0
		queueHide = 0


	New(client/C)
		if (C)
			src.owner = C
			src.owner << browse(src.file, "window=[src.control]")

		..()


	proc/show(params = null, title = null, content = null, theme = "default")
		if (!params || (!title && !content) || !src.owner) return 0
		src.showing = 1

		//Format contents
		if (title && content)
			title = "<h1>[title]</h1>"
			content = "<p>[content]</p>"
		else if (title && !content)
			title = "<p>[title]</p>"
		else if (!title && content)
			content = "<p>[content]</p>"

		//Send stuff to the tooltip
		src.owner << output(list2params(list(src.control, params, src.owner.view, "[title][content]", theme)), "[src.control]:tooltip.update")

		//DEBUG
		world << "SHOW() DEBUG"
		world << "Tooltip Owner View: [src.owner.view]"
		world << "Params: [params]"


		//If a hide() was hit while we were showing, run hide() again to avoid stuck tooltips
		src.showing = 0
		if (src.queueHide)
			src.hide()

		return 1


	proc/hide()
		if (src.queueHide)
			spawn(1)
				winshow(src.owner, src.control, 0)
		else
			winshow(src.owner, src.control, 0)

		src.queueHide = src.showing ? 1 : 0

		return 1



/client/var/datum/tooltip/tooltip
/client/New()
	..()
	tooltip = new /datum/tooltip(src)


/obj/screen/movable/action_button/MouseEntered(location,control,params)
	usr.client.tooltip.show(params,title = name, content = desc)


/obj/screen/movable/action_button/MouseExited()
	usr.client.tooltip.hide()


/mob/MouseEntered(location,control,params)
	usr.client.tooltip.show(params,title = name, content = desc)

/mob/MouseExited()
	usr.client.tooltip.hide()