#define SOLID 1
#define LIQUID 2
#define GAS 3

#define NORMAL 0
#define FAST 1
#define VERY_FAST 2
#define IGNORE_SLOWDOWN 4

#define REM REAGENTS_EFFECT_MULTIPLIER

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
	var/overdosed = 0 // You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/stun_timer = 0 // How many ticks since you last resisted a stun, tracked by stun-resisting reagents.
	var/stun_threshold = 0 //How many ticks it takes to resist a stun, tracked by stun-resisting chems
	var/stun_resist = 0 //How many ticks of stun does the chem resist, used by stun-resisting chems.
	var/speedboost = NORMAL //Refactor of the terrible old speedboost management system, everything is checked in the check_speedboost proc in the chemistry-holder file. Uses the defines NORMAL, FAST, VERY_FAST and IGNORE_SLOWDOWN.

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	if(method == VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = Clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(id, amount)
	return 1

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
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

/proc/pretty_string_from_reagent_list(var/list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/result = "| "
	for (var/datum/reagent/R in reagent_list)
		result += "[R.name], [R.volume] | "

	return result

/datum/reagent/proc/stun_resist_act(mob/living/M)
	if(stun_timer == (stun_threshold))
		M << "<span class='notice'>You feel the [name] kick in!</span>"
	if(!(M.stunned || M.weakened || M.paralysis))
		stun_timer++
		metabolization_rate = initial(metabolization_rate)
	else
		metabolization_rate = 2 * initial(metabolization_rate)
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R.stun_timer >= R.stun_threshold)
				if(R.stun_timer >= R.stun_threshold + 3)
					R.stun_timer = R.stun_threshold - 1
				else
					R.stun_timer = 0
				M.AdjustParalysis(-R.stun_resist)
				M.AdjustStunned(-R.stun_resist)
				M.AdjustWeakened(-R.stun_resist)
