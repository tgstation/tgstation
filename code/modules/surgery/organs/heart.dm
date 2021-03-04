/obj/item/organ/heart
	name = "heart"
	desc = "I feel bad for the heartless bastard who lost this."
	icon_state = "heart-on"
	base_icon_state = "heart"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = 2.5 * STANDARD_ORGAN_DECAY //designed to fail around 6 minutes after death

	low_threshold_passed = "<span class='info'>Prickles of pain appear then die out from within your chest...</span>"
	high_threshold_passed = "<span class='warning'>Something inside your chest hurts, and the pain isn't subsiding. You notice yourself breathing far faster than before.</span>"
	now_fixed = "<span class='info'>Your heart begins to beat again.</span>"
	high_threshold_cleared = "<span class='info'>The pain in your chest has died down, and your breathing becomes more relaxed.</span>"

	// Heart attack code is in code/modules/mob/living/carbon/human/life.dm
	var/beating = 1
	attack_verb_continuous = list("beats", "thumps")
	attack_verb_simple = list("beat", "thump")
	var/beat = BEAT_NONE//is this mob having a heatbeat sound played? if so, which?
	var/failed = FALSE //to prevent constantly running failing code
	var/operated = FALSE //whether the heart's been operated on to fix some of its damages

/obj/item/organ/heart/update_icon_state()
	icon_state = "[base_icon_state]-[beating ? "on" : "off"]"
	return ..()

/obj/item/organ/heart/Remove(mob/living/carbon/M, special = 0)
	..()
	if(!special)
		addtimer(CALLBACK(src, .proc/stop_if_unowned), 120)

/obj/item/organ/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/heart/attack_self(mob/user)
	..()
	if(!beating)
		user.visible_message("<span class='notice'>[user] squeezes [src] to \
			make it beat again!</span>","<span class='notice'>You squeeze [src] to make it beat again!</span>")
		Restart()
		addtimer(CALLBACK(src, .proc/stop_if_unowned), 80)

/obj/item/organ/heart/proc/Stop()
	beating = 0
	update_appearance()
	return 1

/obj/item/organ/heart/proc/Restart()
	beating = 1
	update_appearance()
	return 1

/obj/item/organ/heart/OnEatFrom(eater, feeder)
	. = ..()
	beating = FALSE
	update_appearance()

/obj/item/organ/heart/on_life(delta_time, times_fired)
	..()

	// If the owner doesn't need a heart, we don't need to do anything with it.
	if(!owner.needs_heart())
		return

	if(owner.client && beating)
		failed = FALSE
		var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
		var/sound/fastbeat = sound('sound/health/fastbeat.ogg', repeat = TRUE)
		var/mob/living/carbon/H = owner


		if(H.health <= H.crit_threshold && beat != BEAT_SLOW)
			beat = BEAT_SLOW
			H.playsound_local(get_turf(H), slowbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			to_chat(owner, "<span class='notice'>You feel your heart slow down...</span>")
		if(beat == BEAT_SLOW && H.health > H.crit_threshold)
			H.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

		if(H.jitteriness)
			if(H.health > HEALTH_THRESHOLD_FULLCRIT && (!beat || beat == BEAT_SLOW))
				H.playsound_local(get_turf(H), fastbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				beat = BEAT_FAST
		else if(beat == BEAT_FAST)
			H.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

	if(organ_flags & ORGAN_FAILING) //heart broke, stopped beating, death imminent
		if(owner.stat == CONSCIOUS)
			owner.visible_message("<span class='danger'>[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!</span>", \
				"<span class='userdanger'>You feel a terrible pain in your chest, as if your heart has stopped!</span>")
		owner.set_heartattack(TRUE)
		failed = TRUE

/obj/item/organ/heart/get_availability(datum/species/S)
	return !(NOBLOOD in S.species_traits)

/obj/item/organ/heart/cursed
	name = "cursed heart"
	desc = "A heart that, when inserted, will force you to pump it manually."
	icon_state = "cursedheart-off"
	base_icon_state = "cursedheart"
	decay_factor = 0
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/add_colour = TRUE //So we're not constantly recreating colour datums
	var/pump_delay = 30 //you can pump 1 second early, for lag, but no more (otherwise you could spam heal)
	var/blood_loss = 100 //600 blood is human default, so 5 failures (below 122 blood is where humans die because reasons?)

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0


/obj/item/organ/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		playsound(user,'sound/effects/singlebeat.ogg',40,TRUE)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		Insert(user)
	else
		return ..()

/obj/item/organ/heart/cursed/on_life(delta_time, times_fired)
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client) //While this entire item exists to make people suffer, they can't control disconnects.
			var/mob/living/carbon/human/H = owner
			if(H.dna && !(NOBLOOD in H.dna.species.species_traits))
				H.blood_volume = max(H.blood_volume - blood_loss, 0)
				to_chat(H, "<span class='userdanger'>You have to keep pumping your blood!</span>")
				if(add_colour)
					H.add_client_colour(/datum/client_colour/cursed_heart_blood) //bloody screen so real
					add_colour = FALSE
		else
			last_pump = world.time //lets be extra fair *sigh*

/obj/item/organ/heart/cursed/Insert(mob/living/carbon/M, special = 0)
	..()
	if(owner)
		to_chat(owner, "<span class='userdanger'>Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!</span>")

/obj/item/organ/heart/cursed/Remove(mob/living/carbon/M, special = 0)
	..()
	M.remove_client_colour(/datum/client_colour/cursed_heart_blood)

/datum/action/item_action/organ_action/cursed_heart
	name = "Pump your blood"

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/Trigger()
	. = ..()
	if(. && istype(target, /obj/item/organ/heart/cursed))
		var/obj/item/organ/heart/cursed/cursed_heart = target

		if(world.time < (cursed_heart.last_pump + (cursed_heart.pump_delay-10))) //no spam
			to_chat(owner, "<span class='userdanger'>Too soon!</span>")
			return

		cursed_heart.last_pump = world.time
		playsound(owner,'sound/effects/singlebeat.ogg',40,TRUE)
		to_chat(owner, "<span class='notice'>Your heart beats.</span>")

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			if(H.dna && !(NOBLOOD in H.dna.species.species_traits))
				H.blood_volume = min(H.blood_volume + cursed_heart.blood_loss*0.5, BLOOD_VOLUME_MAXIMUM)
				H.remove_client_colour(/datum/client_colour/cursed_heart_blood)
				cursed_heart.add_colour = TRUE
				H.adjustBruteLoss(-cursed_heart.heal_brute)
				H.adjustFireLoss(-cursed_heart.heal_burn)
				H.adjustOxyLoss(-cursed_heart.heal_oxy)


/datum/client_colour/cursed_heart_blood
	priority = 100 //it's an indicator you're dying, so it's very high priority
	colour = "red"

/obj/item/organ/heart/cybernetic
	name = "basic cybernetic heart"
	desc = "A basic electronic device designed to mimic the functions of an organic human heart."
	icon_state = "heart-c"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.75 //This also hits defib timer, so a bit higher than its less important counterparts

	var/dose_available = FALSE
	var/rid = /datum/reagent/medicine/epinephrine
	var/ramount = 10
	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/heart/cybernetic/tier2
	name = "cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma."
	icon_state = "heart-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	dose_available = TRUE
	emp_vulnerability = 40

/obj/item/organ/heart/cybernetic/tier3
	name = "upgraded cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma. This upgraded model can regenerate its dose after use."
	icon_state = "heart-c-u2"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	dose_available = TRUE
	emp_vulnerability = 20

/obj/item/organ/heart/cybernetic/emp_act(severity)
	. = ..()

	// If the owner doesn't need a heart, we don't need to do anything with it.
	if(!owner.needs_heart())
		return

	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.Dizzy(10)
		owner.losebreath += 10
		COOLDOWN_START(src, severe_cooldown, 20 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.
		Stop()
		owner.visible_message("<span class='danger'>[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!</span>", \
						"<span class='userdanger'>You feel a terrible pain in your chest, as if your heart has stopped!</span>")
		addtimer(CALLBACK(src, .proc/Restart), 10 SECONDS)

/obj/item/organ/heart/cybernetic/on_life(delta_time, times_fired)
	. = ..()
	if(dose_available && owner.health <= owner.crit_threshold && !owner.reagents.has_reagent(rid))
		used_dose()

/obj/item/organ/heart/cybernetic/proc/used_dose()
	owner.reagents.add_reagent(rid, ramount)
	dose_available = FALSE

/obj/item/organ/heart/cybernetic/tier3/used_dose()
	. = ..()
	addtimer(VARSET_CALLBACK(src, dose_available, TRUE), 5 MINUTES)

/obj/item/organ/heart/freedom
	name = "heart of freedom"
	desc = "This heart pumps with the passion to give... something freedom."
	organ_flags = ORGAN_SYNTHETIC //the power of freedom prevents heart attacks
	/// The cooldown until the next time this heart can give the host an adrenaline boost.
	COOLDOWN_DECLARE(adrenaline_cooldown)

/obj/item/organ/heart/freedom/on_life(delta_time, times_fired)
	. = ..()
	if(owner.health < 5 && COOLDOWN_FINISHED(src, adrenaline_cooldown))
		COOLDOWN_START(src, adrenaline_cooldown, rand(25 SECONDS, 1 MINUTES))
		to_chat(owner, "<span class='userdanger'>You feel yourself dying, but you refuse to give up!</span>")
		owner.heal_overall_damage(15, 15, 0, BODYPART_ORGANIC)
		if(owner.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)




/obj/item/organ/heart/ethereal
	name = "Crystal core"
	icon_state = "ethereal_heart" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that functions similarly to a heart for Ethereals. It can revive its owner."

	///Cooldown for the next time we can crystalize
	COOLDOWN_DECLARE(crystalize_cooldown)
	///Timer ID for when we will be crystalized, If not preparing this will be null.
	var/crystalize_timer_id
	///The current crystal the ethereal is in, if any
	var/obj/structure/ethereal_crystal/current_crystal
	///Damage taken during crystalization, resets after it ends
	var/crystalization_process_damage = 0
	///Color of the heart, is set by the species on gain
	var/ethereal_color = "#9c3030"

/obj/item/organ/heart/ethereal/Initialize()
	. = ..()
	add_atom_colour(ethereal_color, FIXED_COLOUR_PRIORITY)


/obj/item/organ/heart/ethereal/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_STATCHANGE, .proc/on_stat_change)
	RegisterSignal(M, COMSIG_LIVING_POST_FULLY_HEAL, .proc/on_owner_fully_heal)
	RegisterSignal(M, COMSIG_PARENT_PREQDELETED, .proc/owner_deleted)

/obj/item/organ/heart/ethereal/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_PARENT_PREQDELETED))
	REMOVE_TRAIT(M, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
	stop_crystalization_process(M)
	QDEL_NULL(current_crystal)
	return ..()

/obj/item/organ/heart/ethereal/update_overlays()
	. = ..()
	var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[icon_state]_shine")
	shine.appearance_flags = RESET_COLOR //No color on this, just pure white
	. += shine


/obj/item/organ/heart/ethereal/proc/on_owner_fully_heal(mob/living/carbon/C, admin_heal)
	SIGNAL_HANDLER

	QDEL_NULL(current_crystal) //Kicks out the ethereal

///Ran when examined while crystalizing, gives info about the amount of time left
/obj/item/organ/heart/ethereal/proc/on_examine(mob/living/carbon/human/examined_human, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!crystalize_timer_id)
		return

	switch(timeleft(crystalize_timer_id))
		if(0 to CRYSTALIZE_STAGE_ENGULFING)
			examine_list += "<span class='warning'>Crystals are almost engulfing [examined_human]! </span>"
		if(CRYSTALIZE_STAGE_ENGULFING to CRYSTALIZE_STAGE_ENCROACHING)
			examine_list += "<span class='notice'>Crystals are starting to cover [examined_human]. </span>"
		if(CRYSTALIZE_STAGE_SMALL to INFINITY)
			examine_list += "<span class='notice'>Some crystals are coming out of [examined_human]. </span>"

///On stat changes, if the victim is no longer dead but they're crystalizing, cancel it, if they become dead, start the crystalizing process if possible
/obj/item/organ/heart/ethereal/proc/on_stat_change(mob/living/victim, new_stat)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		if(crystalize_timer_id)
			stop_crystalization_process(victim)
		return


	if(QDELETED(victim) || victim.suiciding)
		return //lol rip

	if(!COOLDOWN_FINISHED(src, crystalize_cooldown))
		return //lol double rip

	to_chat(victim, "<span class='nicegreen'>Crystals start forming around your dead body.</span>")
	victim.visible_message("<span class='notice'>Crystals start forming around [victim].</span>")
	ADD_TRAIT(victim, TRAIT_CORPSELOCKED, SPECIES_TRAIT)

	crystalize_timer_id = addtimer(CALLBACK(src, .proc/crystalize, victim), CRYSTALIZE_PRE_WAIT_TIME, TIMER_STOPPABLE)

	RegisterSignal(victim, COMSIG_HUMAN_DISARM_HIT, .proc/reset_crystalizing)
	RegisterSignal(victim, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(victim, COMSIG_MOB_APPLY_DAMGE, .proc/on_take_damage)

///Ran when disarmed, prevents the ethereal from reviving
/obj/item/organ/heart/ethereal/proc/reset_crystalizing(mob/living/defender, mob/living/attacker, zone)
	SIGNAL_HANDLER
	to_chat(defender, "<span class='notice'>The crystals on your corpse are gently broken off, and will need some time to recover.</span>")
	defender.visible_message("<span class='notice'>The crystals on [defender] are gently broken off.</span>")
	deltimer(crystalize_timer_id)
	crystalize_timer_id = addtimer(CALLBACK(src, .proc/crystalize, defender), CRYSTALIZE_DISARM_WAIT_TIME, TIMER_STOPPABLE) //Lets us restart the timer on disarm


///Actually spawns the crystal which puts the ethereal in it.
/obj/item/organ/heart/ethereal/proc/crystalize(mob/living/ethereal)
	if(!COOLDOWN_FINISHED(src, crystalize_cooldown) || ethereal.stat != DEAD)
		return //Should probably not happen, but lets be safe.
	COOLDOWN_START(src, crystalize_cooldown, INFINITY) //Prevent cheeky double-healing until we get out, this is against stupid admemery
	current_crystal = new(get_turf(ethereal), src)
	stop_crystalization_process(ethereal, TRUE)

///Stop the crystalization process, unregistering any signals and resetting any variables.
/obj/item/organ/heart/ethereal/proc/stop_crystalization_process(mob/living/ethereal, succesful = FALSE)
	UnregisterSignal(ethereal, COMSIG_HUMAN_DISARM_HIT)
	UnregisterSignal(ethereal, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(ethereal, COMSIG_MOB_APPLY_DAMGE)

	crystalization_process_damage = 0 //Reset damage taken during crystalization

	if(!succesful)
		REMOVE_TRAIT(owner, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
		QDEL_NULL(current_crystal)

	if(crystalize_timer_id)
		deltimer(crystalize_timer_id)
		crystalize_timer_id = null

/obj/item/organ/heart/ethereal/proc/owner_deleted(datum/source)
	SIGNAL_HANDLER

	stop_crystalization_process(owner)
	return

///Lets you stop the process with enough brute damage
/obj/item/organ/heart/ethereal/proc/on_take_damage(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damagetype != BRUTE)
		return

	crystalization_process_damage += damage

	if(crystalization_process_damage < BRUTE_DAMAGE_REQUIRED_TO_STOP_CRYSTALIZATION)
		return

	var/mob/living/carbon/human/ethereal = source

	to_chat(ethereal, "<span class='userwarning'>The crystals on your body have completely broken</span>")
	ethereal.visible_message("<span class='notice'>The crystals on [ethereal] are completely shattered and stopped growing</span>")

	stop_crystalization_process(ethereal)

/obj/structure/ethereal_crystal
	name = "Ethereal Resurrection Crystal"
	desc = "It seems to contain the corpse of an ethereal mending its wounds."
	icon = 'icons/obj/ethereal_crystal.dmi'
	icon_state = "ethereal_crystal"
	damage_deflection = 0
	max_integrity = 100
	resistance_flags = FIRE_PROOF
	density = TRUE
	anchored = TRUE
	///The organ this crystal belongs to
	var/obj/item/organ/heart/ethereal/ethereal_heart
	///Timer for the healing process. Stops if destroyed.
	var/crystal_heal_timer
	///Is the crystal still being built? True by default, gets changed after a timer.
	var/being_built = TRUE

/obj/structure/ethereal_crystal/Initialize(mapload, obj/item/organ/heart/ethereal/ethereal_heart)
	. = ..()
	src.ethereal_heart = ethereal_heart
	ethereal_heart.owner.visible_message("<span class='notice'>The crystals fully encase [ethereal_heart.owner]!</span>")
	to_chat(ethereal_heart.owner, "<span class='notice'>You are encased in a huge crystal!</span>")
	playsound(get_turf(src), 'sound/effects/ethereal_crystalization.ogg', 50)
	ethereal_heart.owner.forceMove(src) //put that ethereal in
	add_atom_colour(ethereal_heart.ethereal_color, FIXED_COLOUR_PRIORITY)
	crystal_heal_timer = addtimer(CALLBACK(src, .proc/heal_ethereal), CRYSTALIZE_HEAL_TIME, TIMER_STOPPABLE)
	set_light(4, 10, ethereal_heart.ethereal_color)
	update_icon()
	flick("ethereal_crystal_forming", src)
	addtimer(CALLBACK(src, .proc/start_crystalization), 1 SECONDS)

/obj/structure/ethereal_crystal/proc/start_crystalization()
	being_built = FALSE
	update_icon()


/obj/structure/ethereal_crystal/obj_destruction(damage_flag)
	playsound(get_turf(ethereal_heart.owner), 'sound/effects/ethereal_revive_fail.ogg', 100)
	return ..()


/obj/structure/ethereal_crystal/Destroy()
	if(!ethereal_heart)
		return ..()
	ethereal_heart.current_crystal = null
	COOLDOWN_START(ethereal_heart, crystalize_cooldown, CRYSTALIZE_COOLDOWN_LENGTH)
	ethereal_heart.owner.forceMove(get_turf(src))
	REMOVE_TRAIT(ethereal_heart.owner, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
	deltimer(crystal_heal_timer)
	visible_message("<span class='notice'>The crystals shatters, causing [ethereal_heart.owner] to fall out</span>")
	return ..()

/obj/structure/ethereal_crystal/update_overlays()
	. = ..()
	if(!being_built)
		var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[icon_state]_shine")
		shine.appearance_flags = RESET_COLOR //No color on this, just pure white
		. += shine

/obj/structure/ethereal_crystal/proc/heal_ethereal()
	ethereal_heart.owner.revive(TRUE, FALSE)
	to_chat(ethereal_heart.owner, "<span class='notice'>You burst out of the crystal with vigour... </span><span class='userdanger'>But at a cost.</span>")
	var/datum/brain_trauma/picked_trauma
	if(prob(10)) //10% chance for a severe trauma
		picked_trauma = pick(subtypesof(/datum/brain_trauma/severe))
	else
		picked_trauma = pick(subtypesof(/datum/brain_trauma/mild))
	ethereal_heart.owner.gain_trauma(picked_trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	playsound(get_turf(ethereal_heart.owner), 'sound/effects/ethereal_revive.ogg', 100)
	qdel(src)
