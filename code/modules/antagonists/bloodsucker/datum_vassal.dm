#define VASSAL_SCAN_MIN_DISTANCE 5
#define VASSAL_SCAN_MAX_DISTANCE 500
#define VASSAL_SCAN_PING_TIME 20 //2s update time.

#define HUNTER_SCAN_MIN_DISTANCE 8
#define HUNTER_SCAN_MAX_DISTANCE 35
#define HUNTER_SCAN_PING_TIME 20 //5s update time.


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


























////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




/datum/antagonist/vamphunter
	name = "Hunter"//WARNING: DO NOT SELECT" // "Vassal"
	roundend_category = "hunters"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	var/list/datum/action/powers = list()// Purchased powers
	var/list/datum/objective/objectives_given = list()	// For removal if needed.
	var/datum/martial_art/my_kungfu // Hunters know a lil kung fu.

/datum/antagonist/vamphunter/on_gain()

	SSticker.mode.vamphunters |= owner // Add if not already in here (and you might be, if you were picked at round start)

	// Hunter Pinpointer
	//owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer/hunter_edition)

	// Give Hunter Power
	var/datum/action/P = new /datum/action/bloodsucker/trackvamp
	P.Grant(owner.current)

	// Give Hunter Martial Arts
	//if (rand(1,3) == 1)
	//	var/datum/martial_art/pick_type = pick (/datum/martial_art/cqc, /datum/martial_art/krav_maga, /datum/martial_art/cqc, /datum/martial_art/krav_maga, /datum/martial_art/wrestling)  // /datum/martial_art/boxing  <--- doesn't include grabbing, so don't use!
	//	my_kungfu = new pick_type //pick (/datum/martial_art/boxing, /datum/martial_art/cqc) // ick_type
	//	my_kungfu.teach(owner.current, 0)

	// Give Hunter Objective
	var/datum/objective/bloodsucker/vamphunter/vamphunter_objective = new
	vamphunter_objective.owner = owner
	vamphunter_objective.generate_objective()
	objectives += vamphunter_objective
	objectives_given += vamphunter_objective

	. = ..()

/datum/antagonist/vamphunter/on_removal()

	SSticker.mode.vamphunters -= owner // Add if not already in here (and you might be, if you were picked at round start)

	// Master Pinpointer
	//owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/hunter_edition)

	// Take Hunter Power
	if (owner.current)
		for (var/datum/action/bloodsucker/P in owner.current.actions)
			P.Remove(owner.current)

	// Take Hunter Martial Arts
	my_kungfu.remove(owner.current)

	// Remove Hunter Objectives
	for(var/O in objectives_given)
		objectives -= O
		qdel(O)
	objectives_given = list()

	. = ..()

/datum/antagonist/vamphunter/greet()
	to_chat(owner, "<span class='userdanger'>You are a fearless Vampire Hunter!</span>")
	to_chat(owner, "<span class='boldannounce'>You know there's at least one filthy Bloodsucker on the station. It's your job to root them out, destroy their nests, and save the crew.<span>")
	antag_memory += "You remember your training: Bloodsuckers are weak to fire, or a stake to the heart. Removing their head or heart will also destroy them permanently.<br>"
	antag_memory += "You remember your training: Wooden stakes can be made from planks, and your recipes list has ways of making them stronger.<br>"
	if (my_kungfu != null)
		to_chat(owner, "<span class='announce'>Hunter Tip: Use your [my_kungfu.name] techniques to give you an advantage over the enemy.</span><br>")
		antag_memory += "You remember your training: You are skilled in the [my_kungfu.name] style of combat.<br>"
	owner.current.playsound_local(null, 'sound/weapons/sawclose.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vamphunter/farewell()
	to_chat(owner, "<span class='userdanger'>Your hunt has ended: you are no longer a vampire hunter!</span>")


// TAKEN FROM:  /datum/action/changeling/pheromone_receptors    // pheromone_receptors.dm      for a version of tracking that Changelings have!

/datum/status_effect/agent_pinpointer/hunter_edition
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/hunter_edition
	minimum_range = HUNTER_SCAN_MIN_DISTANCE
	tick_interval = HUNTER_SCAN_PING_TIME
	duration = 160 // Lasts 10s
	range_fuzz_factor = 5//PINPOINTER_EXTRA_RANDOM_RANGE

/obj/screen/alert/status_effect/agent_pinpointer/hunter_edition
	name = "Vampire Tracking"
	desc = "You always know where the monsters is."


/datum/status_effect/agent_pinpointer/hunter_edition/on_creation(mob/living/new_owner, ...)
	..()

	// Pick target
	var/turf/my_loc = get_turf(owner)
	var/list/mob/living/carbon/vamps = list()
	// Track Bloodsuckers in Game Mode
	for(var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (!M.current || M.current == owner || !get_turf(M.current) || !get_turf(new_owner))
			continue
		var/datum/antagonist/bloodsucker/antag_datum = M.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if(!istype(antag_datum))
			continue
		var/their_loc = get_turf(M.current)
		var/distance = get_dist_euclidian(my_loc, their_loc)
		if (distance < HUNTER_SCAN_MAX_DISTANCE)
			vamps[M.current] = (HUNTER_SCAN_MAX_DISTANCE ** 2) - (distance ** 2)
	// Found one!
	if(vamps.len)
		scan_target = pickweight(vamps) //Point at a 'random' vamp, biasing heavily towards closer ones.
		to_chat(owner, "<span class='warning'>You detect signs of Bloodsuckers to the <b>[dir2text(get_dir(my_loc,get_turf(scan_target)))]!</b></span>")
	// Will yield a "?"
	else
		to_chat(owner, "<span class='notice'>There are no bloodsuckers nearby.</span>")
	// Force Point-To Immediately
	point_to_target()

/datum/status_effect/agent_pinpointer/hunter_edition/scan_for_target()
	// Lose target? Done. Otherwise, scan for target's current position.
	if (!scan_target && owner)
		owner.remove_status_effect(/datum/status_effect/agent_pinpointer/hunter_edition)

	// NOTE: Do NOT run ..(), or else we'll remove our target.


/datum/status_effect/agent_pinpointer/hunter_edition/Destroy()
	if (scan_target)
		to_chat(owner, "<span class='notice'>You've lost the trail.</span>")
	..()


/datum/status_effect/agent_pinpointer/tick()






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/datum/action/bloodsucker/trackvamp/
	name = "Track Bloodsucker"//"Cellular Emporium"
	desc = "Take a moment to look for clues of any nearby Bloodsuckers.<br>These creatures are slippery, and often look like the crew."
	button_icon = 'icons/Fulpicons/fulpicons.dmi'	//This is the file for the BACKGROUND icon
	background_icon_state = "vamp_power_off"		//And this is the state for the background icon
	icon_icon = 'icons/Fulpicons/fulpicons.dmi'		//This is the file for the ACTION icon
	button_icon_state = "power_hunter" 				//And this is the state for the action icon

	// Action-Related
	amToggle = FALSE
	cooldown = 200 // 10 ticks, 1 second.
	bloodcost = 0



/datum/action/bloodsucker/trackvamp/ActivatePower()

	var/mob/living/user = owner

	to_chat(user, "<span class='notice'>You look around, scanning your environment and discerning signs of those filthy, wretched bloodsuckers.</span>")

	if (!do_mob(user,owner,80))
		return

	// Add Power
	user.apply_status_effect(/datum/status_effect/agent_pinpointer/hunter_edition)

	// NOTE: DON'T DEACTIVATE!
	//DeactivatePower()
















////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// From martial.dm

/*
/datum/martial_art/hunter
	name = "Hunter-Fu"
	id = "MARTIALART_HUNTER" //ID, used by mind/has_martialart
	//streak = ""
	//max_streak_length = 6
	//current_target
	//datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	//deflection_chance = 0 //Chance to deflect projectiles
	//reroute_deflection = FALSE //Delete the bullet, or actually deflect it in some direction?
	//block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	//restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	//help_verb
	//no_guns = FALSE
	//allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts

/datum/martial_art/hunter/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/hunter/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/hunter/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/hunter/can_use(mob/living/carbon/human/H)
	return TRUE


/datum/martial_art/hunter/add_to_streak(element,mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
		restraining = 0
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak,2)
	return


/datum/martial_art/hunter/basic_hit(mob/living/carbon/human/A,mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)
*/