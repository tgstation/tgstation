/* sd_Alert library
	by Shadowdarke (shadowdarke@byond.com)

	sd_Alert() is a powerful and flexible alternative to the built in BYOND
	alert() proc. sd_Alert offers timed popups, unlimited buttons, custom
	appearance, and even the option to popup without stealing keyboard focus
	from the map or command line.

	Please see demo.dm for detailed examples.

FORMAT
	sd_Alert(who, message, title, buttons, default, duration, unfocus, \
		size, table, style, tag, select, flags)

ARGUMENTS
	who			- the client or mob to display the alert to.
	message		- text message to display
	title		- title of the alert box
	buttons		- list of buttons
					Default Value: list("Ok")
	default		- default button selestion
					Default Value: the first button in the list
	duration	- the number of ticks before this alert expires. If not
					set, the alert lasts until a button is clicked.
					Default Value: 0 (unlimited)
	unfocus		- if this value is set, the popup will not steal keyboard
					focus from the map or command line.
					Default Value: 1 (do not take focus)
	size		- size of the popup window in px
					Default Value: "300x200"
	table		- optional parameters for the HTML table in the alert
					Default Value: "width=100% height=100%" (fill the window)
	style		- optional style sheet information
	tag			- lets you specify a certain tag for this sd_Alert so you may manipulate it
					externally. (i.e. force the alert to close, change options and redisplay,
					reuse the same window, etc.)
	select		- if set, the buttons will be replaced with a selection box with a number of
					lines displayed equal to this value.
					Default value: 0 (use buttons)
	flags		- optional flags effecting the alert display. These flags may be ORed (|)
					together for multiple effects.
						SD_ALERT_SCROLL			= display a scrollbar
						SD_ALERT_SELECT_MULTI	= forces selection box display (instead of
													buttons) allows the user to select multiple
													choices.
						SD_ALERT_LINKS			= display each choice as a plain text link.
													Any selection box style overrides this flag.
						SD_ALERT_NOVALIDATE		= don't validate responses
					Default value: SD_ALERT_SCROLL
						(button display with scroll bar, validate responses)
RETURNS
	The text of the selected button, or null if the alert duration expired
	without a button click.

Version 1 changes (from version 0):
* Added the tag, select, and flags arguments, thanks to several suggestions from Foomer.
* Split the sd_Alert/Alert() proc into New(), Display(), and Response() to allow more
	customization by developers. Primarily developers would want to use Display() to change
	the display of active tagged windows

*/


#define SD_ALERT_SCROLL			1
#define SD_ALERT_SELECT_MULTI	2
#define SD_ALERT_LINKS			4
#define SD_ALERT_NOVALIDATE		8

proc/sd_Alert(client/who, message, title, buttons = list("Ok"),\
	default, duration = 0, unfocus = 1, size = "300x200", \
	table = "width=100% height=100%", style, tag, select, flags = SD_ALERT_SCROLL)

	if(ismob(who))
		var/mob/M = who
		who = M.client
	if(!istype(who)) CRASH("sd_Alert: Invalid target:[who] (\ref[who])")

	var/sd_alert/T = locate(tag)
	if(T)
		if(istype(T)) del(T)
		else CRASH("sd_Alert: tag \"[tag]\" is already in use by datum '[T]' (type: [T.type])")
	T = new(who, tag)
	if(duration)
		spawn(duration)
			if(T) del(T)
			return
	T.Display(message,title,buttons,default,unfocus,size,table,style,select,flags)
	. = T.Response()

sd_alert
	var
		client/target
		response
		list/validation

	Del()
		target << browse(null,"window=\ref[src]")
		..()

	New(who, tag)
		..()
		target = who
		src.tag = tag

	Topic(href,params[])
		if(usr.client != target) return
		response = params["clk"]

	proc/Display(message,title,list/buttons,default,unfocus,size,table,style,select,flags)
		if(unfocus) spawn() target << browse(null,null)
		if(istext(buttons)) buttons = list(buttons)
		if(!default) default = buttons[1]
		if(!(flags & SD_ALERT_NOVALIDATE)) validation = buttons.Copy()

		var/html = {"<head><title>[title]</title>[style]<script>\
		function c(x) {document.location.href='BYOND://?src=\ref[src];'+x;}\
		</script></head><body onLoad="fcs.focus();"\
		[(flags&SD_ALERT_SCROLL)?"":" scroll=no"]><table [table]><tr>\
		<td>[message]</td></tr><tr><th>"}

		if(select || (flags & SD_ALERT_SELECT_MULTI))	// select style choices
			html += {"<FORM ID=fcs ACTION='BYOND://?' METHOD=GET>\
				<INPUT TYPE=HIDDEN NAME=src VALUE='\ref[src]'>
				<SELECT NAME=clk SIZE=[select]\
				[(flags & SD_ALERT_SELECT_MULTI)?" MULTIPLE":""]>"}
			for(var/b in buttons)
				html += "<OPTION[(b == default)?" SELECTED":""]>\
					[html_encode(b)]</OPTION>"
			html += "</SELECT><BR><INPUT TYPE=SUBMIT VALUE=Submit></FORM>"
		else if(flags & SD_ALERT_LINKS)		// text link style
			for(var/b in buttons)
				var/list/L = list()
				L["clk"] = b
				var/html_string=list2params(L)
				var/focus
				if(b == default) focus = " ID=fcs"
				html += "<A[focus] href=# onClick=\"c('[html_string]')\">[html_encode(b)]</A>\
					<BR>"
		else	// button style choices
			for(var/b in buttons)
				var/list/L = list()
				L["clk"] = b
				var/html_string=list2params(L)
				var/focus
				if(b == default) focus = " ID=fcs"
				html += "<INPUT[focus] TYPE=button VALUE='[html_encode(b)]' \
					onClick=\"c('[html_string]')\"> "

		html += "</th></tr></table></body>"

		target << browse(html,"window=\ref[src];size=[size];can_close=0")

	proc/Response()
		var/validated
		while(!validated)
			while(target && !response)	// wait for a response
				sleep(2)

			if(response && validation)
				if(istype(response, /list))
					var/list/L = response - validation
					if(L.len) response = null
					else validated = 1
				else if(response in validation) validated = 1
				else response=null
			else validated = 1
		spawn(2) del(src)
		return response
