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

/datum/research_tree/proc/load_usable_unlocks()
	usable_unlocks=list()
	avail_unlocks=list()
	for(var/datum/unlockable/U in get_avail_unlocks())
		if(!U.id) continue
		U.set_context(src)
		if(!U.unlocked && U.can_buy(src) && U.check_prerequisites(src))
			usable_unlocks[U.id]="\ref[U]"
		avail_unlocks[U.id]="\ref[U]"

/datum/research_tree/proc/start_table()
	return "<table class=\"prettytable\"><thead><th>Name</th><th>Cost</th><th>Time</th></thead>"

/datum/research_tree/proc/end_table()
	return "</table>"

/datum/research_tree/proc/display(var/mob/user)
	testing("Entering display...")
	var/html = "<h2>[title]</h2><p>[blurb]</p>"
	html += start_table()
	load_usable_unlocks()
	for(var/id in usable_unlocks)
		var/datum/unlockable/U=locate(usable_unlocks[id])
		U.set_context(src)
		html += U.toTableRow(src,user)
	html += end_table()

	popup = new /datum/browser/clean(user, "\ref[src]_research", "Research Tree", 300, 300)
	popup.set_content(html)
	popup.open()

/datum/research_tree/proc/close(var/mob/user)
	user << browse(null,"window=\ref[src]_research")

/datum/research_tree/Topic(href, href_list)
	if("unlock" in href_list)
		var/mob/viewer = locate(href_list["user"])
		var/datum/unlockable/unlock = locate(usable_unlocks[href_list["unlock"]])
		if(!unlock)
			return
		unlock.set_context(src)
		unlock.unlock(src)
		display(viewer)