/*

	This component is made to be added to a mob, perhaps granted by an implant or brain trauma.

	There are 3 operating modes currently:

		1. Block Jobs: Provide a list of job titles for the argument, if someone is wearing an ID with a job on that list, or failing that has their face unobscured and is registered with a blocked job, they will be blocked
		2. Block Poor: Provide a minimum credit value for the argument, if someone is wearing an ID with an account that has less than that amount, or failing that has their face unobscured and has a registered account with less
			than that value, they will be blocked. Not sure if I should block those without a linked account, probably won't. Maybe let it scan their inventory to see if they have cash in their bag or pockets?
		3. Block All: Everything gets blocked! Mostly debug for now

*/

#define BLOCK_JOBS	0
#define BLOCK_POOR 	1
#define BLOCK_ALL 	2

#define REFRESH_EVERY	5 SECONDS

/datum/component/blocker
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/list/block_list = list()
	var/list/image/staticOverlays = list()

	var/min_cash = 100
	var/list/blocked_jobs = list("Assistant")
	var/mode = BLOCK_JOBS
	var/last_update = 0


/datum/component/blocker/Initialize(block_mode, arg)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	mode = block_mode

	switch(mode)
		if(BLOCK_JOBS)
			if(!islist(arg))
				return COMPONENT_INCOMPATIBLE
			blocked_jobs = arg
		if(BLOCK_POOR)
			min_cash = arg

	START_PROCESSING(SSdcs, src)

/datum/component/blocker/Destroy(force, silent)
	return ..()

/datum/component/blocker/RegisterWithParent()

/datum/component/blocker/UnregisterFromParent()

/// This proc registers signals to override examining blocked entities so we won't be able to tell what they are, and is undone by clear_blocklist()
/datum/component/blocker/proc/block_examines()
	for(var/mob/living/L in block_list)
		RegisterSignal(L, COMSIG_PARENT_EXAMINE, .proc/block_examine)
		RegisterSignal(L, COMSIG_ATOM_GET_EXAMINE_NAME, .proc/block_examine_name)

/// This proc will block examine text to hide what the target actually is
/datum/component/blocker/proc/block_examine(datum/source, mob/user, list/examine_list)
	if(user == parent)
		examine_list = list("</span class='notice'>You can't make out anything behind all the static!</span>")
		return examine_list

/datum/component/blocker/proc/block_examine_name(datum/source, mob/user, list/override)
	if(user == parent)
		override[EXAMINE_POSITION_BEFORE] = " \[BLOCKED\] " // todo: actually have it overwrite the name
		return COMPONENT_EXNAME_CHANGED

/// Clear out the static overlays, unhook the examine block signals, and
/datum/component/blocker/proc/clear_blocklist()
	var/mob/living/P = parent
	if(P && P.client)
		for(var/image/static in staticOverlays)
			P.client.images.Remove(static)

	staticOverlays = list()

	for(var/mob/living/L in block_list)
		UnregisterSignal(L, COMSIG_PARENT_EXAMINE)
		UnregisterSignal(L, COMSIG_ATOM_GET_EXAMINE_NAME)

	block_list = list()

/// Based on the mode and args we have set, generate block_list so we know who we don't want to see
/datum/component/blocker/proc/generate_blocklist()
	last_update = world.time

	for(var/mob/living/simple_animal/pet/dog/corgi/C in GLOB.mob_list)
		block_list += C

	switch(mode)

		if(BLOCK_JOBS)
			for(var/mob/living/carbon/human/H in GLOB.human_list)
				if(H.wear_id)
					var/obj/item/card/id/id_card = H.wear_id.GetID()
					testing(id_card.assignment)
					if(id_card.assignment in blocked_jobs)
						block_list += H
						continue
				else // if they don't have an ID, check their face and (through the power of space wifi) compare it to the station data core to see if they're registered as a blocked job
					var/shown_name = H.get_face_name()
					if(shown_name && GLOB.data_core)
						var/datum/data/record/R = find_record("name", shown_name, GLOB.data_core)
						if(R && (R.fields["rank"]) && (R.fields["rank"] in blocked_jobs))
							block_list += H
							continue

		else if(BLOCK_POOR) // ~can't hear broke!~
			for(var/mob/living/carbon/human/H in GLOB.human_list)
				if(H.wear_id) // first check if the card they're wearing has enough cash
					var/obj/item/card/id/id_card = H.wear_id.GetID()
					if(id_card.registered_account && !id_card.registered_account.has_money(min_cash))
						block_list += H
						continue
				else // if they don't have an ID, check their face and (through the power of space wifi) audit their bank account to make sure they've got funds
					var/shown_name = H.get_face_name()
					if(shown_name && SSeconomy.bank_accounts)
						for(var/datum/bank_account/B in SSeconomy.bank_accounts)
							if(B && B.account_holder == H && !B.has_money(min_cash))
								block_list += H
								continue

/// Create the static overlays on the things we're blocking out
/datum/component/blocker/proc/set_static_overlays()
	for(var/mob/living/L in block_list)
		var/image/staticOverlay
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			staticOverlay = image(icon('icons/effects/effects.dmi', "static"), loc = H)
		else
			staticOverlay = image(getStaticIcon(new/icon(L.icon,L.icon_state)), loc = L)
		staticOverlay.override = 1
		staticOverlays |= staticOverlay
		var/mob/M = parent
		M.client.images |= staticOverlay

/datum/component/blocker/process()
	var/mob/living/M = parent
	if(!M || !M.client)
		return

	if(last_update + REFRESH_EVERY < world.time)
		last_update = world.time
		clear_blocklist()
		generate_blocklist()
		set_static_overlays()
		block_examines()

		testing("Blocked:")
		for(var/i in block_list)
			testing(i)
		testing("--------")

#undef BLOCK_JOBS
#undef BLOCK_POOR
#undef BLOCK_ALL

#undef REFRESH_EVERY
