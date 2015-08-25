/datum/research_tree
	var/title="Research Tree"
	var/blurb="<b>BUG:</b> This is a stand-in description.  If the coder who implemented this wasn't a hack, they'd make a subtype /datum/research_tree and set the title and blurb properties to be more immersive."

	var/datum/browser/popup
	var/list/usable_unlocks = list()
	var/list/avail_unlocks = list()
	var/list/unlocked = list()
	var/unlocking=0

/datum/research_tree/proc/get_avail_unlocks()
	CRASH("SOME GIT CALLED /datum/research_tree/get_avail_unlocks()! Check for ..() in [type]/get_avail_unlocks()!")
	return list()

// CALL EXTERNALLY ONLY: Sets context.
/datum/research_tree/proc/get(var/id, var/only_usable=0)
	var/list/all_unlocks
	if(only_usable)
		all_unlocks = usable_unlocks
	else
		all_unlocks = avail_unlocks
	var/datum/unlockable/U = locate(all_unlocks[id])
	if(!U)
		return null
	U.set_context(src)
	return U

/datum/research_tree/proc/get_usable_unlocks()
	var/list/usable_unlocks=list()
	for(var/datum/unlockable/U in get_avail_unlocks())
		if(!U.unlocked && U.can_buy(src) && U.check_prerequisites(src))
			usable_unlocks[U.id]="\ref[U]"
		avail_unlocks[U.id]="\ref[U]"

/datum/research_tree/proc/get_thead()
	return "<th>Name</th><th>Cost</th>"

/datum/research_tree/proc/display(var/mob/user)
	var/html = "<h2>[title]</h2>[blurb]"
	html += "<table class=\"prettytable\"><thead>[get_thead()]</thead>"
	usable_unlocks=get_usable_unlocks()
	for(var/id in usable_unlocks)
		var/datum/unlockable/U=usable_unlocks[id]
		html += U.toTableRow(src,user)
	html += "</table>"

	popup = new(user, "researchWindow", title, 320, 200,)
	popup.set_content(html)
	popup.open()


/datum/research_tree/Topic(href, href_list)
	if("unlock" in href_list)
		var/mob/viewer = locate(href_list["user"])
		var/datum/unlockable/unlock = locate(usable_unlocks[href_list["unlock"]])
		if(!unlock)
			return
		unlock.unlock(src)
		display(viewer)