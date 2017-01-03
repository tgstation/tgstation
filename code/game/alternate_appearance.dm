/*
	Alternate Appearances! By RemieRichards
	A framework for replacing an atom (and it's overlays) with an override = 1 image, that's less shit!
	Example uses:
		* hallucinating all mobs looking like skeletons
		* people wearing cardborg suits appearing as Standard Cyborgs to the other Silicons
		* !!use your imagination!!

*/


//This datum is built on-the-fly by some of the procs below
//no need to instantiate it
/datum/alternate_appearance
	var/key = ""
	var/image/img
	var/list/viewers = list()
	var/atom/owner = null


/*
	Displays the alternate_appearance
	displayTo - a list of MOBS to show this appearance to
*/
/datum/alternate_appearance/proc/display_to(list/displayTo)
	if(!displayTo || !displayTo.len)
		return
	for(var/m in displayTo)
		var/mob/M = m
		if(!M.viewing_alternate_appearances)
			M.viewing_alternate_appearances = list()
		viewers |= M
		var/list/AAsiblings = M.viewing_alternate_appearances[key]
		if(!AAsiblings)
			AAsiblings = list()
			M.viewing_alternate_appearances[key] = AAsiblings
		AAsiblings |= src
		if(M.client)
			M.client.images |= img

/*
	Hides the alternate_appearance
	hideFrom - optional list of MOBS to hide it from the list's mobs specifically
*/
/datum/alternate_appearance/proc/hide(list/hideFrom)
	var/list/hiding = viewers
	if(hideFrom)
		hiding = hideFrom

	for(var/m in hiding)
		var/mob/M = m
		if(M.client)
			M.client.images -= img
		if(M.viewing_alternate_appearances && M.viewing_alternate_appearances.len)
			var/list/AAsiblings = M.viewing_alternate_appearances[key]
			if(AAsiblings)
				AAsiblings -= src
				if(!AAsiblings.len)
					M.viewing_alternate_appearances -= key
					if(!M.viewing_alternate_appearances.len)
						M.viewing_alternate_appearances = null
		viewers -= M


/*
	Removes the alternate_appearance from its owner's alternate_appearances list, hiding it also
*/
/datum/alternate_appearance/proc/remove()
	hide()
	if(owner && owner.alternate_appearances)
		owner.alternate_appearances -= key
		if(!owner.alternate_appearances.len)
			owner.alternate_appearances = null


/datum/alternate_appearance/Destroy()
	remove()
	return ..()



/atom
	var/list/alternate_appearances //the alternate appearances we own
	var/list/viewing_alternate_appearances //this is an assoc list of lists, the keys being the AA's key
	//inside these lists are the AAs themselves, this is to allow the atom to see multiple of the same type of AA
	//eg: two (or more) people disguised as cardborgs, or two (or more) people disguised as plants

/*
	Builds an alternate_appearance datum for the supplied args, optionally displaying it straight away
	key - the key to the assoc list of key = /datum/alternate_appearances
	img - the image file to be the "alternate appearance"
	WORKS BEST IF:
		* it has override = 1 set
		* the image's loc is the atom that will use the appearance (otherwise... it's not exactly an alt appearance of this atom is it?)
	displayTo - optional list of MOBS to display to immediately

	Example:
	var/image/I = image(icon = 'disguise.dmi', icon_state = "disguise", loc = src)
	I.override = 1
	add_alt_appearance("super_secret_disguise", I, players)

*/
/atom/proc/add_alt_appearance(key, img, list/displayTo = list())
	if(!key || !img)
		return
	if(!alternate_appearances)
		alternate_appearances = list()

	var/datum/alternate_appearance/AA = new()
	AA.img = img
	AA.key = key
	AA.owner = src

	alternate_appearances[key] = AA
	if(displayTo && displayTo.len)
		display_alt_appearance(key, displayTo)


//////////////
// WRAPPERS //
//////////////

/*
	Removes an alternate_appearance from src's alternate_appearances list
	Wrapper for: alternate_appearance/remove()
	key - the key to the assoc list of key = /datum/alternate_appearance
*/
/atom/proc/remove_alt_appearance(key)
	if(alternate_appearances)
		if(alternate_appearances[key])
			var/datum/alternate_appearance/AA = alternate_appearances[key]
			qdel(AA)


/*
	Displays an alternate appearance from src's alternate_appearances list
	Wrapper for: alternate_appearance/display_to()
	key - the key to the assoc list of key = /datum/alternate_appearance
	displayTo - a list of MOBS to show this appearance to
*/
/atom/proc/display_alt_appearance(key, list/displayTo)
	if(!alternate_appearances || !key)
		return
	var/datum/alternate_appearance/AA = alternate_appearances[key]
	if(!AA || !AA.img)
		return
	AA.display_to(displayTo)


/*
	Hides an alternate appearance from src's alternate_appearances list
	Wrapper for: alternate_appearance/hide()
	key - the key to the assoc list of key = /datum/alternate_appearance
	hideFrom - optional list of MOBS to hide it from the list's mobs specifically
*/
/atom/proc/hide_alt_appearance(key, list/hideFrom)
	if(!alternate_appearances || !key)
		return
	var/datum/alternate_appearance/AA = alternate_appearances[key]
	if(!AA)
		return
	AA.hide(hideFrom)


