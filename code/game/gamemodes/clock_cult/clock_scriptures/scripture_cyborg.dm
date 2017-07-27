/////////////////
// CYBORG ONLY //
/////////////////

//Linked Vanguard: grants Vanguard to the invoker and a target
/datum/clockwork_scripture/ranged_ability/linked_vanguard
	name = "Linked Vanguard"
	invocations = list("Shield us...", "...from darkness!")
	channel_time = 30
	primary_component = VANGUARD_COGWHEEL
	quickbind_desc = "Allows you to grant a Servant and yourself stun immunity, as the Vanguard scripture.<br><b>Click your slab to disable.</b>"
	slab_overlay = "vanguard"
	ranged_type = /obj/effect/proc_holder/slab/vanguard
	ranged_message = "<span class='inathneq_small'><i>You charge the clockwork slab with defensive strength.</i>\n\
	<b>Left-click a fellow Servant or yourself to grant Vanguard!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 50

/datum/clockwork_scripture/ranged_ability/linked_vanguard/check_special_requirements()
	if(!GLOB.ratvar_awakens && islist(invoker.stun_absorption) && invoker.stun_absorption["vanguard"] && invoker.stun_absorption["vanguard"]["end_time"] > world.time)
		to_chat(invoker, "<span class='warning'>You are already shielded by a Vanguard!</span>")
		return FALSE
	return TRUE

/datum/clockwork_scripture/ranged_ability/linked_vanguard/scripture_effects()
	if(GLOB.ratvar_awakens) //hey, ratvar's up! give everybody stun immunity.
		for(var/mob/living/L in view(7, get_turf(invoker)))
			if(L.stat != DEAD && is_servant_of_ratvar(L))
				L.apply_status_effect(STATUS_EFFECT_VANGUARD)
			CHECK_TICK
		return TRUE
	return ..()

//Judicial Marker: places a judicial marker at a target location
/datum/clockwork_scripture/ranged_ability/judicial_marker
	name = "Judicial Marker"
	invocations = list("May heathens...", "...kneel under our force!")
	channel_time = 30
	primary_component = BELLIGERENT_EYE
	quickbind_desc = "Allows you to place a Judicial Marker to knock down and damage non-Servants in an area.<br><b>Click your slab to disable.</b>"
	slab_overlay = "judicial"
	ranged_type = /obj/effect/proc_holder/slab/judicial
	ranged_message = "<span class='neovgre_small'><i>You charge the clockwork slab with judicial force.</i>\n\
	<b>Left-click a target to place a Judicial Marker!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 50
