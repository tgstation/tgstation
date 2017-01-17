/////////////////
// CYBORG ONLY //
/////////////////

//Linked Vanguard: grants Vanguard to the invoker and a target
/datum/clockwork_scripture/ranged_ability/linked_vanguard
	name = "Linked Vanguard"
	invocations = list("Shield us...", "...from darkness!")
	channel_time = 40
	required_components = list(VANGUARD_COGWHEEL = 1)
	primary_component = VANGUARD_COGWHEEL
	quickbind_desc = "Allows you to grant a Servant and yourself stun immunity, as the Vanguard scripture.<br><b>Click your slab to disable.</b>"
	slab_icon = "vanguard"
	ranged_type = /obj/effect/proc_holder/slab/vanguard
	ranged_message = "<span class='inathneq_small'><i>You charge the clockwork slab with defensive strength.</i>\n\
	<b>Left-click a fellow Servant or yourself to grant Vanguard!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 50

/datum/clockwork_scripture/ranged_ability/linked_vanguard/check_special_requirements()
	if(islist(invoker.stun_absorption) && invoker.stun_absorption["vanguard"] && invoker.stun_absorption["vanguard"]["end_time"] > world.time)
		invoker << "<span class='warning'>You are already shielded by a Vanguard!</span>"
		return FALSE
	return TRUE

//Judicial Marker: places a judicial marker at a target location
/datum/clockwork_scripture/ranged_ability/judicial_marker
	name = "Judicial Marker"
	invocations = list("May heathens...", "...kneel under our force!")
	channel_time = 40
	required_components = list(BELLIGERENT_EYE = 1)
	primary_component = BELLIGERENT_EYE
	quickbind_desc = "Allows you to place a Judicial Marker to stun and damage a target location.<br><b>Click your slab to disable.</b>"
	slab_icon = "judicial"
	ranged_type = /obj/effect/proc_holder/slab/judicial
	ranged_message = "<span class='neovgre_small'><i>You charge the clockwork slab with judicial force.</i>\n\
	<b>Left-click a target to place a Judicial Marker!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 50
