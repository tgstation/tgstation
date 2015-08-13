#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


//Various reagents
//Toxin & acid reagents
//Hydroponics stuff

/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0
	var/color = "#000000" // rgb: 0, 0, 0
	var/can_synth = 1
	var/metabolization_rate = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/overrides_metab = 0
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/overdosed = 0 // You fucked up and this is now triggering it's overdose effects, purge that shit quick.

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method=TOUCH, volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	var/datum/reagent/self = src
	src = null

	if(method == TOUCH)
		if(M.reagents)
			var/modifier = Clamp((1 - touch_protection) + rand(-5,5)/100, 0, 1)
			var/amount = round(volume*modifier, 0.1)
			if(amount >= 1)
				M.reagents.add_reagent(self.id, amount)
	return 1

/datum/reagent/proc/reaction_obj(obj/O, volume)
	src = null
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	src = null
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
	if(!istype(M, /mob/living))
		return //Noticed runtime errors from facid trying to damage ghosts, this should fix. --NEO
	holder.remove_reagent(src.id, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return

// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/M)
	return

/datum/reagent/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_update(atom/A)
	return

// Called every time reagent containers process.
/datum/reagent/proc/on_tick(data)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M)
	return

/datum/reagent/proc/overdose_start(mob/living/M)
	M << "<span class='userdanger'>You feel like you took too much of [name]!</span>"
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like some [name] right about now.</span>"
	return

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like you need [name]. You just can't get enough.</span>"
	return

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(prob(30))
		M << "<span class='danger'>You have an intense craving for [name].</span>"
	return

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(prob(30))
		M << "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>"
	return

