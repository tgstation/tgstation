#define REM REAGENTS_EFFECT_MULTIPLIER

//Various reagents
//Toxin & acid reagents
//Hydroponics stuff

/datum/chemical
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/chem_holder/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0
	var/value = 1 // The value of this reagent. Basing it off the chemdispenser energy points (ie. 1 point of value = 0.1 points of chemdispenser energy.)It will eventually be used.
	var/color = "#000000" // rgb: 0, 0, 0
	var/alpha = 255 // Not currently used. May eventually be used for gasses and reagent_fillings.
	var/can_synth = 1
	var/metabolization_rate = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/overrides_metab = 0
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/overdosed = 0 // You fucked up and this is now triggering its overdose effects, purge that shit quick.

/datum/chemical/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/datum/chemical/proc/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	if(method == VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = Clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(id, amount)
	return 1

/datum/chemical/proc/reaction_obj(obj/O, volume)
	return

/datum/chemical/proc/reaction_turf(turf/T, volume)
	return

/datum/chemical/proc/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(src.id, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return

// Called when this reagent is removed while inside a mob
/datum/chemical/proc/on_mob_delete(mob/M)
	return

/datum/chemical/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/chemical/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/chemical/proc/on_merge(data)
	return

// trigger is a string or value that can be called to trigger special stuff. Such as trigger 'itouchedadoor'. Leaving it as null causes it to trigger every process tick.
/datum/chemical/proc/on_update(atom/A, trigger)
	return

// Called every time reagent containers process.
/datum/chemical/proc/on_tick(data)
	return

// Called when the reagent container is hit by an explosion
/datum/chemical/proc/on_ex_act(severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/chemical/proc/overdose_process(mob/living/M)
	return

/datum/chemical/proc/overdose_start(mob/living/M)
	M << "<span class='userdanger'>You feel like you took too much of [name]!</span>"
	return

/datum/chemical/proc/addiction_act_stage1(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like some [name] right about now.</span>"
	return

/datum/chemical/proc/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like you need [name]. You just can't get enough.</span>"
	return

/datum/chemical/proc/addiction_act_stage3(mob/living/M)
	if(prob(30))
		M << "<span class='danger'>You have an intense craving for [name].</span>"
	return

/datum/chemical/proc/addiction_act_stage4(mob/living/M)
	if(prob(30))
		M << "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>"
	return

/proc/pretty_string_from_reagents(var/list/reagents)
	//Convert reagent list to a printable string for logging etc
	var/result = "| "
	for (var/datum/reagent/R in reagents)
		result += "[R.name], [R.volume] | "

	return result
