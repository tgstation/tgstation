//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!
var/list/status_effects = list() //All status effects affecting literally anyone
/datum/status_effect
	var/name = "Curse of Mundanity"
	var/desc = "You don't feel any different..."
	var/duration = -1 //How long the status effect lasts in SECONDS. Enter -1 for an effect that never ends unless removed through some means.
	var/tick_interval = 1 //How many seconds between ticks. Leave at 1 for every second.
	var/mob/living/owner //The mob affected by the status effect.
	var/cosmetic = FALSE //If the status effect only exists for flavor.

/datum/status_effect/New()
	..()
	spawn(1) //Give us time to set any variables
		start_ticking()

/datum/status_effect/proc/start_ticking()
	on_apply()
	while(TRUE) //please don't kill me :c
		sleep(10)
		if(duration != -1)
			duration--
		tick_interval--
		if(!tick_interval)
			tick()
			tick_interval = initial(tick_interval)
		if(!duration && duration != -1)
			cancel_effect()
			break

/datum/status_effect/proc/cancel_effect()
	STOP_PROCESSING(SSobj, src)
	on_remove()
	qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied.
/datum/status_effect/proc/tick() //Called every tick.
/datum/status_effect/proc/on_remove() //Called whenever the buff expires or is removed.

//////////////////
// HELPER PROCS //
//////////////////

/mob/living/proc/apply_status_effect(effect)
	var/datum/status_effect/S = new effect
	S.owner = src

/mob/living/proc/remove_status_effect(effect)
	for(var/datum/status_effect/S in status_effects)
		if(S.owner == src && S.type == effect)
			S.cancel_effect()
