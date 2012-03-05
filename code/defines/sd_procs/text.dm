/* Text procs
	These procs manipulate text strings.

	sd_findlast(maintext as text, searchtext as text)
		Returns the location of the last instance of searchtext in
		maintext. sd_findlast is not case sensitive.

	sd_findLast(maintext as text, searchtext as text)
		Returns the location of the last instance of searchtext in
		maintext. sd_findLast is case sensitive.

	sd_htmlremove(T as text)
		Returns the text string with all potential html tags (anything
		between < and >) removed.

	sd_replacetext(maintext as text, oldtext as text, newtext as text)
		Replaces all instances of oldtext within maintext with newtext.
		sd_replacetext is not case sensitive.

	sd_replaceText(maintext as text, oldtext as text, newtext as text)
		Replaces all instances of oldtext within maintext with newtext.
		sd_replaceText is case sensitive.
*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/
proc
	sd_findlast(maintext as text, searchtext as text)
	/* Returns the location of the last instance of searchtext in
		maintext. sd_findlast is not case sensitive. */
		var/loc = 0
		var/looking = findtext(maintext, searchtext)
		while(looking)
			loc = looking
			looking = findtext(maintext, searchtext, looking + 1)
		return loc

	sd_findLast(maintext as text, searchtext as text)
	/* Returns the location of the last instance of searchtext in
		maintext. sd_findLast is case sensitive. */
		var/loc = 0
		var/looking = findText(maintext, searchtext)
		while(looking)
			loc = looking
			looking = findText(maintext, searchtext, looking + 1)
		return loc


	sd_htmlremove(T as text)
	/* Returns the text string with all potential html tags (anything
		between < and >) removed. */
		T = sd_replacetext(T, "&nbsp;","")
		var/open = findtext(T,"<")
		while(open)
			var/close = findtext(T,">",open)
			if(close)
				if(close<lentext(T))
					T = copytext(T,1,open)+copytext(T,close+1)
				else
					T = copytext(T,1,open)
				open = findtext(T,"<")
			else
				open = 0
		return T

	sd_replacetext(maintext as text, oldtext as text, newtext as text)
	/* Replaces all instances of oldtext within maintext with newtext.
		sd_replacetext is not case sensitive. See sd_replaceText for a
		case sensitive version. */
		var/F = findtext(maintext, oldtext)
		var/length = length(newtext)
		while(F)
			var/newmessage = copytext(maintext,1,F) + newtext + copytext(maintext,F+lentext(oldtext))
			maintext = newmessage
			F = findtext(maintext, oldtext, F + length)
		return maintext

	sd_replaceText(maintext as text, oldtext as text, newtext as text)
	/* Replaces all instances of oldtext within maintext with newtext.
		sd_replaceText is case sensitive. See sd_replacetext for a
		non-case sensitive version. */
		var/F = findText(maintext, oldtext)
		var/length = length(newtext)
		while(F)
			var/newmessage = copytext(maintext,1,F) + newtext + copytext(maintext,F+lentext(oldtext))
			maintext = newmessage
			F = findText(maintext, oldtext, F + length)
		return maintext
