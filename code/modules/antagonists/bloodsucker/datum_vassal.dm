#define VASSAL_SCAN_MIN_DISTANCE 5
#define VASSAL_SCAN_MAX_DISTANCE 500
#define VASSAL_SCAN_PING_TIME 20 //2s update time.


/datum/antagonist/bloodsucker/proc/attempt_turn_vassal(mob/living/carbon/C)
	return SSticker.mode.make_vassal(C,owner)

/datum/antagonist/bloodsucker/proc/FreeAllVassals()
	for (var/datum/antagonist/vassal/V in vassals)
		SSticker.mode.remove_vassal(V.owner)



/datum/antagonist/vassal
	name = "Vassal"//WARNING: DO NOT SELECT" // "Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	var/datum/antagonist/bloodsucker/master		// Who made me?
	var/list/datum/action/powers = list()// Purchased powers
	var/list/datum/objective/objectives_given = list()	// For removal if needed.

/datum/antagonist/vassal/can_be_owned(datum/mind/new_owner)
	// If we weren't created by a bloodsucker, then we cannot be a vassal (assigned from antag panel)
	if (!master)
		return FALSE
	return ..()

/datum/antagonist/vassal/on_gain()

	SSticker.mode.vassals |= owner // Add if not already in here (and you might be, if you were picked at round start)

	// Mindslave Add
	if (master)
		var/datum/antagonist/bloodsucker/B = master.owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (B)
			B.vassals |= src
		owner.enslave_mind_to_creator(master.owner.current)

	// Master Pinpointer
	owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

	// Powers
	var/datum/action/bloodsucker/vassal/recuperate/new_Recuperate = new ()
	new_Recuperate.Grant(owner.current)
	powers += new_Recuperate

	// Give Vassal Objective
	var/datum/objective/bloodsucker/vassal/vassal_objective = new
	vassal_objective.owner = owner
	vassal_objective.generate_objective()
	objectives += vassal_objective
	objectives_given += vassal_objective

	// Add Antag HUD
	update_vassal_icons_added(owner.current, "vassal")

	. = ..()

/datum/antagonist/vassal/on_removal()

	SSticker.mode.vassals -= owner // Add if not already in here (and you might be, if you were picked at round start)

	// Mindslave Remove
	if (master && master.owner)
		master.vassals -= src
		if (owner.enslaved_to == master.owner.current)
			owner.enslaved_to = null

	// Master Pinpointer
	owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

	// Powers
	while(powers.len)
		var/datum/action/power = pick(powers)
		powers -= power
		power.Remove(owner.current)

	// Remove Hunter Objectives
	for(var/O in objectives_given)
		objectives -= O
		qdel(O)
	objectives_given = list()


	// Clear Antag HUD
	update_vassal_icons_removed(owner.current)

	. = ..()

/datum/antagonist/vassal/greet()
	to_chat(owner, "<span class='userdanger'>You are now the mortal servant of [master.owner.current], a bloodsucking vampire!</span>")
	to_chat(owner, "<span class='boldannounce'>The power of [master.owner.current.p_their()] immortal blood compells you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.<br>\
			You are not required to obey any other Bloodsucker, for only [master.owner.current] is your master. The laws of Nanotransen do not apply to you now; only your vampiric master's word must be obeyed.<span>")
	// Effects...
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	//owner.store_memory("You became the mortal servant of [master.owner.current], a bloodsucking vampire!")
	antag_memory += "You became the mortal servant of  <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"

	// And to your new Master...
	to_chat(master.owner, "<span class='userdanger'>[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] is now your undying servant!</span>")
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	owner.current.visible_message("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seems calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self.",\
			"<span class='userdanger'><FONT size = 3>With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will.</FONT></span>")
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	// And to your former Master...
	//if (master && master.owner)
	//	to_chat(master.owner, "<span class='userdanger'>You feel the bond with your vassal [owner.current] has somehow been broken!</span>")



/datum/status_effect/agent_pinpointer/vassal_edition
	id = "agent_pinpointer"
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/vassal_edition
	minimum_range = VASSAL_SCAN_MIN_DISTANCE
	tick_interval = VASSAL_SCAN_PING_TIME
	duration = -1 // runs out fast
	range_fuzz_factor = 0

/obj/screen/alert/status_effect/agent_pinpointer/vassal_edition
	name = "Blood Bond"
	desc = "You always know where your master is."
	//icon = 'icons/obj/device.dmi'
	//icon_state = "pinon"

/datum/status_effect/agent_pinpointer/vassal_edition/on_creation(mob/living/new_owner, ...)
	..()

	var/datum/antagonist/vassal/antag_datum = new_owner.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
	scan_target = antag_datum?.master?.owner?.current

/datum/status_effect/agent_pinpointer/vassal_edition/scan_for_target()
	// DO NOTHING. We already have our target, and don't wanna do anything from agent_pinpointer

	//scan_target = null
	//if(owner?.mind)


/datum/antagonist/vassal/proc/update_vassal_icons_added(mob/living/vassal, icontype="vassal")
	var/datum/atom_hud/antag/bloodsucker/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]// ANTAG_HUD_DEVIL
	hud.join_hud(vassal)
	set_antag_hud(vassal, icontype) // Located in icons/mob/hud.dmi
	owner.current.hud_list[ANTAG_HUD].icon = image('icons/Fulpicons/fulphud.dmi', owner.current, "bloodsucker")	// FULP ADDITION! Check prepare_huds in mob.dm to see why.

/datum/antagonist/vassal/proc/update_vassal_icons_removed(mob/living/vassal)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]//ANTAG_HUD_BLOODSUCKER]
	hud.leave_hud(vassal)
	set_antag_hud(vassal, null)



//Displayed at the start of roundend_category section, default to roundend_category header
/datum/antagonist/vassal/roundend_report_header()
	return 	"<span class='header'>Loyal to their bloodsucking masters, the Vassals were:</span><br><br>"























