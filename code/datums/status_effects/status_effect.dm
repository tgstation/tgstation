//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!

var/global/list/all_status_effects = list() //a list of all status effects, if for some reason you need to remove all of them

/datum/status_effect
	var/id = "effect" //Used for screen alerts.
	var/duration = -1 //How long the status effect lasts in DECISECONDS. Enter -1 for an effect that never ends unless removed through some means.
	var/tick_interval = 10 //How many deciseconds between ticks, approximately. Leave at 10 for every second.
	var/mob/living/owner //The mob affected by the status effect.
	var/unique = TRUE //If there can be multiple status effects of this type on one mob.
	var/alert_type = /obj/screen/alert/status_effect //the alert thrown by the status effect, contains name and description

/datum/status_effect/New(mob/living/new_owner)
	if(new_owner)
		owner = new_owner
	if(owner)
		LAZYADD(owner.status_effects, src)
	all_status_effects += src
	addtimer(CALLBACK(src, .proc/start_ticking), 1) //Give us time to set any variables

/datum/status_effect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		owner.clear_alert(id)
		on_remove()
		LAZYREMOVE(owner.status_effects, src)
	all_status_effects -= src
	return ..()

/datum/status_effect/proc/start_ticking()
	if(!src)
		return
	if(!owner)
		qdel(src)
		return
	on_apply()
	if(duration != -1)
		duration = world.time + initial(duration)
	tick_interval = world.time + initial(tick_interval)
	if(alert_type)
		var/obj/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
	START_PROCESSING(SSfastprocess, src)

/datum/status_effect/process()
	if(!owner)
		qdel(src)
		return
	if(tick_interval < world.time)
		tick()
		tick_interval = world.time + initial(tick_interval)
	if(duration != -1 && duration < world.time)
		qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied.
/datum/status_effect/proc/tick() //Called every tick.
/datum/status_effect/proc/on_remove() //Called whenever the buff expires or is removed.

////////////////
// ALERT HOOK //
////////////////

/obj/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

//////////////////
// HELPER PROCS //
//////////////////

/mob/living/proc/apply_status_effect(effect) //applies a given status effect to this mob, returning the effect if it was successful
	. = FALSE
	var/datum/status_effect/S1 = effect
	LAZYINITLIST(status_effects)
	for(var/datum/status_effect/S in status_effects)
		if(S.id == initial(S1.id) && initial(S1.unique))
			return
	S1 = new effect(src)
	. = S1

/mob/living/proc/remove_status_effect(effect) //removes all of a given status effect from this mob, returning TRUE if at least one was removed
	. = FALSE
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				qdel(S)
				. = TRUE

/mob/living/proc/has_status_effect(effect) //returns the effect if the mob calling the proc owns the given status effect
	. = FALSE
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				return S
