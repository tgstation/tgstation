/datum/antagonist/space_dragon
	name = "\improper Space Dragon"
	roundend_category = "space dragons"
	antagpanel_category = ANTAG_GROUP_LEVIATHANS
	job_rank = ROLE_SPACE_DRAGON
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// All space carps created by this antagonist space dragon
	var/list/datum/mind/carp = list()
	/// The innate ability to summon rifts
	var/datum/action/innate/summon_rift/rift_ability
	/// Current time since the the last rift was activated.  If set to -1, does not increment.
	var/riftTimer = 0
	/// Maximum amount of time which can pass without a rift before Space Dragon despawns.
	var/maxRiftTimer = 300
	/// A list of all of the rifts created by Space Dragon.  Used for setting them all to infinite carp spawn when Space Dragon wins, and removing them when Space Dragon dies.
	var/list/obj/structure/carp_rift/rift_list = list()
	/// How many rifts have been successfully charged
	var/rifts_charged = 0
	/// Whether or not Space Dragon has completed their objective, and thus triggered the ending sequence.
	var/objective_complete = FALSE
	/// What mob to spawn from ghosts using this dragon's rifts
	var/minion_to_spawn = /mob/living/basic/carp
	/// What AI mobs to spawn from this dragon's rifts
	var/ai_to_spawn = /mob/living/basic/carp

/datum/antagonist/space_dragon/greet()
	. = ..()
	to_chat(owner, "<b>Through endless time and space we have moved. We do not remember from where we came, we do not know where we will go.  All of space belongs to us.\n\
					It is an empty void, of which our kind was the apex predator, and there was little to rival our claim to this title.\n\
					But now, we find intruders spread out amongst our claim, willing to fight our teeth with magics unimaginable, their dens like lights flickering in the depths of space.\n\
					Today, we will snuff out one of those lights.</b>")
	to_chat(owner, span_boldwarning("You have five minutes to find a safe location to place down the first rift.  If you take longer than five minutes to place a rift, you will be returned from whence you came."))
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))

/datum/antagonist/space_dragon/forge_objectives()
	var/datum/objective/summon_carp/summon = new
	summon.dragon = src
	objectives += summon

/datum/antagonist/space_dragon/on_gain()
	forge_objectives()
	rift_ability = new()
	return ..()

/datum/antagonist/space_dragon/apply_innate_effects(mob/living/mob_override)
	var/mob/living/antag = mob_override || owner.current
	RegisterSignal(antag, COMSIG_LIVING_LIFE, PROC_REF(rift_checks))
	RegisterSignal(antag, COMSIG_LIVING_DEATH, PROC_REF(destroy_rifts))
	antag.faction |= FACTION_CARP
	// Give the ability over if we have one
	rift_ability?.Grant(antag)

/datum/antagonist/space_dragon/remove_innate_effects(mob/living/mob_override)
	var/mob/living/antag = mob_override || owner.current
	UnregisterSignal(antag, COMSIG_LIVING_LIFE)
	UnregisterSignal(antag, COMSIG_LIVING_DEATH)
	antag.faction -= FACTION_CARP
	rift_ability?.Remove(antag)

/datum/antagonist/space_dragon/Destroy()
	rift_list = null
	carp = null
	QDEL_NULL(rift_ability)
	return ..()

/datum/antagonist/space_dragon/get_preview_icon()
	var/icon/icon = icon('icons/mob/nonhuman-player/spacedragon.dmi', "spacedragon")

	icon.Blend(COLOR_STRONG_VIOLET, ICON_MULTIPLY)
	icon.Blend(icon('icons/mob/nonhuman-player/spacedragon.dmi', "overlay_base"), ICON_OVERLAY)

	icon.Crop(10, 9, 54, 53)
	icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/**
 * Checks to see if we need to do anything with the current state of the dragon's rifts.
 *
 * A simple update check which sees if we need to do anything based on the current state of the dragon's rifts.
 *
 */
/datum/antagonist/space_dragon/proc/rift_checks()
	if((rifts_charged == 3 || (SSshuttle.emergency.mode == SHUTTLE_DOCKED && rifts_charged > 0)) && !objective_complete)
		victory()
		return
	if(riftTimer == -1)
		return
	riftTimer = min(riftTimer + 1, maxRiftTimer + 1)
	if(riftTimer == (maxRiftTimer - 60))
		to_chat(owner.current, span_boldwarning("You have a minute left to summon the rift! Get to it!"))
		return
	if(riftTimer >= maxRiftTimer)
		to_chat(owner.current, span_boldwarning("You've failed to summon the rift in a timely manner! You're being pulled back from whence you came!"))
		destroy_rifts()
		SEND_SOUND(owner.current, sound('sound/magic/demon_dies.ogg'))
		owner.current.death(/* gibbed = */ TRUE)
		QDEL_NULL(owner.current)

/**
 * Destroys all of Space Dragon's current rifts.
 *
 * QDeletes all the current rifts after removing their references to other objects.
 * Currently, the only reference they have is to the Dragon which created them, so we clear that before deleting them.
 * Currently used when Space Dragon dies or one of his rifts is destroyed.
 */
/datum/antagonist/space_dragon/proc/destroy_rifts()
	if(objective_complete)
		return
	rifts_charged = 0
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_depression)
	riftTimer = -1
	SEND_SOUND(owner.current, sound('sound/vehicles/rocketlaunch.ogg'))
	for(var/obj/structure/carp_rift/rift as anything in rift_list)
		rift.dragon = null
		rift_list -= rift
		if(!QDELETED(rift))
			QDEL_NULL(rift)

/**
 * Sets up Space Dragon's victory for completing the objectives.
 *
 * Triggers when Space Dragon completes his objective.
 * Calls the shuttle with a coefficient of 3, making it impossible to recall.
 * Sets all of his rifts to allow for infinite sentient carp spawns
 * Also plays appropiate sounds and CENTCOM messages.
 */
/datum/antagonist/space_dragon/proc/victory()
	objective_complete = TRUE
	permanant_empower()
	var/datum/objective/summon_carp/main_objective = locate() in objectives
	if(main_objective)
		main_objective.completed = TRUE
	priority_announce("A large amount of lifeforms have been detected approaching [station_name()] at extreme speeds. \
	Remaining crew are advised to evacuate as soon as possible.", "Central Command Wildlife Observations")
	sound_to_playing_players('sound/creatures/space_dragon_roar.ogg')
	for(var/obj/structure/carp_rift/rift as anything in rift_list)
		rift.carp_stored = 999999
		rift.time_charged = rift.max_charge

/**
 * Gives Space Dragon their the rift speed buff permanantly and fully heals the user.
 *
 * Gives Space Dragon the enraged speed buff from charging rifts permanantly.
 * Only happens in circumstances where Space Dragon completes their objective.
 * Also gives them a full heal.
 */
/datum/antagonist/space_dragon/proc/permanant_empower()
	owner.current.fully_heal()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/**
 * Handles Space Dragon's temporary empowerment after boosting a rift.
 *
 * Empowers and depowers Space Dragon after a successful rift charge.
 * Empowered, Space Dragon regains all his health and becomes temporarily faster for 30 seconds, along with being tinted red.
 */
/datum/antagonist/space_dragon/proc/rift_empower()
	owner.current.fully_heal()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
	addtimer(CALLBACK(src, PROC_REF(rift_depower)), 30 SECONDS)

/**
 * Removes Space Dragon's rift speed buff.
 *
 * Removes Space Dragon's speed buff from charging a rift.  This is only called
 * in rift_empower, which uses a timer to call this after 30 seconds.  Also
 * removes the red glow from Space Dragon which is synonymous with the speed buff.
 */
/datum/antagonist/space_dragon/proc/rift_depower()
	owner.current.remove_filter("anger_glow")
	owner.current.remove_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/datum/objective/summon_carp
	var/datum/antagonist/space_dragon/dragon
	explanation_text = "Summon and protect the rifts to flood the station with carp."

/datum/antagonist/space_dragon/roundend_report()
	var/list/parts = list()
	var/datum/objective/summon_carp/S = locate() in objectives
	if(S.check_completion())
		parts += "<span class='redtext big'>The [name] has succeeded! Station space has been reclaimed by the space carp!</span>"
	parts += printplayer(owner)
	var/objectives_complete = TRUE
	if(objectives.len)
		parts += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(objectives_complete)
		parts += "<span class='greentext big'>The [name] was successful!</span>"
	else
		parts += "<span class='redtext big'>The [name] has failed!</span>"
	if(carp.len)
		parts += "<span class='header'>The [name] was assisted by:</span>"
		parts += printplayerlist(carp)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
