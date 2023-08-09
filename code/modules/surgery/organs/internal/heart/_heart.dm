/obj/item/organ/internal/heart
	name = "heart"
	desc = "I feel bad for the heartless bastard who lost this."
	icon_state = "heart-on"
	base_icon_state = "heart"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = 2.5 * STANDARD_ORGAN_DECAY //designed to fail around 6 minutes after death

	low_threshold_passed = "<span class='info'>Prickles of pain appear then die out from within your chest...</span>"
	high_threshold_passed = "<span class='warning'>Something inside your chest hurts, and the pain isn't subsiding. You notice yourself breathing far faster than before.</span>"
	now_fixed = "<span class='info'>Your heart begins to beat again.</span>"
	high_threshold_cleared = "<span class='info'>The pain in your chest has died down, and your breathing becomes more relaxed.</span>"

	// Heart attack code is in code/modules/mob/living/carbon/human/life.dm
	var/beating = TRUE
	attack_verb_continuous = list("beats", "thumps")
	attack_verb_simple = list("beat", "thump")
	var/beat = BEAT_NONE//is this mob having a heatbeat sound played? if so, which?
	var/failed = FALSE //to prevent constantly running failing code
	var/operated = FALSE //whether the heart's been operated on to fix some of its damages

/obj/item/organ/internal/heart/update_icon_state()
	icon_state = "[base_icon_state]-[beating ? "on" : "off"]"
	return ..()

/obj/item/organ/internal/heart/Remove(mob/living/carbon/heartless, special = 0)
	. = ..()
	if(!special)
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 120)

/obj/item/organ/internal/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/internal/heart/attack_self(mob/user)
	..()
	if(!beating)
		user.visible_message("<span class='notice'>[user] squeezes [src] to \
			make it beat again!</span>",span_notice("You squeeze [src] to make it beat again!"))
		Restart()
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 80)

/obj/item/organ/internal/heart/proc/Stop()
	beating = FALSE
	update_appearance()
	return TRUE

/obj/item/organ/internal/heart/proc/Restart()
	beating = TRUE
	update_appearance()
	return TRUE

/obj/item/organ/internal/heart/OnEatFrom(eater, feeder)
	. = ..()
	beating = FALSE
	update_appearance()

/obj/item/organ/internal/heart/on_life(seconds_per_tick, times_fired)
	..()

	// If the owner doesn't need a heart, we don't need to do anything with it.
	if(!owner.needs_heart())
		return

	if(owner.client && beating)
		failed = FALSE
		var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
		var/sound/fastbeat = sound('sound/health/fastbeat.ogg', repeat = TRUE)

		if(owner.health <= owner.crit_threshold && beat != BEAT_SLOW)
			beat = BEAT_SLOW
			owner.playsound_local(get_turf(owner), slowbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			to_chat(owner, span_notice("You feel your heart slow down..."))
		if(beat == BEAT_SLOW && owner.health > owner.crit_threshold)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

		if(owner.has_status_effect(/datum/status_effect/jitter))
			if(owner.health > HEALTH_THRESHOLD_FULLCRIT && (!beat || beat == BEAT_SLOW))
				owner.playsound_local(get_turf(owner), fastbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				beat = BEAT_FAST

		else if(beat == BEAT_FAST)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

	if(organ_flags & ORGAN_FAILING && owner.can_heartattack() && !(HAS_TRAIT(src, TRAIT_STABLEHEART))) //heart broke, stopped beating, death imminent... unless you have veins that pump blood without a heart
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_danger("[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!"), \
				span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
		owner.set_heartattack(TRUE)
		failed = TRUE

/obj/item/organ/internal/heart/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantheart

/obj/item/organ/internal/heart/cursed
	name = "cursed heart"
	desc = "A heart that, when inserted, will force you to pump it manually."
	icon_state = "cursedheart-off"
	base_icon_state = "cursedheart"
	decay_factor = 0
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/add_colour = TRUE //So we're not constantly recreating colour datums
	/// How long between needed pumps; you can pump one second early
	var/pump_delay = 3 SECONDS
	/// How much blood volume you lose every missed pump, this is a flat amount not a percentage!
	var/blood_loss = (BLOOD_VOLUME_NORMAL / 5) // 20% of normal volume, missing five pumps is instant death

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0


/obj/item/organ/internal/heart/cursed/attack(mob/living/carbon/human/accursed, mob/living/carbon/human/user, obj/target)
	if(accursed == user && istype(accursed))
		playsound(user,'sound/effects/singlebeat.ogg',40,TRUE)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		Insert(user)
	else
		return ..()

/// Worker proc that checks logic for if a pump can happen, and applies effects/notifications from doing so
/obj/item/organ/internal/heart/cursed/proc/on_pump(mob/owner)
	var/next_pump = last_pump + pump_delay - (1 SECONDS) // pump a second early
	if(world.time < next_pump)
		to_chat(owner, span_userdanger("Too soon!"))
		return

	last_pump = world.time
	playsound(owner,'sound/effects/singlebeat.ogg', 40, TRUE)
	to_chat(owner, span_notice("Your heart beats."))

	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/accursed = owner

	if(HAS_TRAIT(accursed, TRAIT_NOBLOOD) || !accursed.dna)
		return
	accursed.blood_volume = min(accursed.blood_volume + (blood_loss * 0.5), BLOOD_VOLUME_MAXIMUM)
	accursed.remove_client_colour(/datum/client_colour/cursed_heart_blood)
	add_colour = TRUE
	accursed.adjustBruteLoss(-heal_brute)
	accursed.adjustFireLoss(-heal_burn)
	accursed.adjustOxyLoss(-heal_oxy)

/obj/item/organ/internal/heart/cursed/on_life(seconds_per_tick, times_fired)
	if(!owner.client || !ishuman(owner)) // Let's be fair, if you're not here to pump, you're not here to suffer.
		last_pump = world.time
		return

	if(world.time <= (last_pump + pump_delay))
		return

	var/mob/living/carbon/human/accursed = owner
	if(HAS_TRAIT(accursed, TRAIT_NOBLOOD) || !accursed.dna)
		return

	accursed.blood_volume = max(accursed.blood_volume - blood_loss, 0)
	to_chat(accursed, span_userdanger("You have to keep pumping your blood!"))
	if(add_colour)
		accursed.add_client_colour(/datum/client_colour/cursed_heart_blood) //bloody screen so real
		add_colour = FALSE

/obj/item/organ/internal/heart/cursed/on_insert(mob/living/carbon/accursed)
	. = ..()
	last_pump = world.time // give them time to react
	to_chat(accursed, span_userdanger("Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!"))

/obj/item/organ/internal/heart/cursed/Remove(mob/living/carbon/accursed, special = FALSE)
	. = ..()
	accursed.remove_client_colour(/datum/client_colour/cursed_heart_blood)

/datum/action/item_action/organ_action/cursed_heart
	name = "Pump your blood"
	check_flags = NONE

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/internal/heart/cursed/cursed_heart = target
	if(!istype(cursed_heart))
		CRASH("Cursed heart pump action created on non-cursed heart!")
	cursed_heart.on_pump(owner)

/datum/client_colour/cursed_heart_blood
	priority = 100 //it's an indicator you're dying, so it's very high priority
	colour = "#FF0000"

/obj/item/organ/internal/heart/cybernetic
	name = "basic cybernetic heart"
	desc = "A basic electronic device designed to mimic the functions of an organic human heart."
	icon_state = "heart-c-on"
	base_icon_state = "heart-c"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.75 //This also hits defib timer, so a bit higher than its less important counterparts

	var/dose_available = FALSE
	var/rid = /datum/reagent/medicine/epinephrine
	var/ramount = 10
	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/internal/heart/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	// Some effects are byassed if our owner (should it exist) doesn't need a heart
	var/owner_needs_us = owner?.needs_heart()

	if(owner_needs_us && !COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.set_dizzy_if_lower(20 SECONDS)
		owner.losebreath += 10
		COOLDOWN_START(src, severe_cooldown, 20 SECONDS)

	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_EMP //Starts organ faliure - gonna need replacing soon.
		Stop()
		addtimer(CALLBACK(src, PROC_REF(Restart)), 10 SECONDS)
		if(owner_needs_us)
			owner.visible_message(
				span_danger("[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!"),
				span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"),
			)

/obj/item/organ/internal/heart/cybernetic/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(dose_available && owner.health <= owner.crit_threshold && !owner.reagents.has_reagent(rid))
		used_dose()

/obj/item/organ/internal/heart/cybernetic/proc/used_dose()
	owner.reagents.add_reagent(rid, ramount)
	dose_available = FALSE

/obj/item/organ/internal/heart/cybernetic/tier2
	name = "cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma."
	icon_state = "heart-c-u-on"
	base_icon_state = "heart-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	dose_available = TRUE
	emp_vulnerability = 40

/obj/item/organ/internal/heart/cybernetic/tier3
	name = "upgraded cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma. This upgraded model can regenerate its dose after use."
	icon_state = "heart-c-u2-on"
	base_icon_state = "heart-c-u2"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	dose_available = TRUE
	emp_vulnerability = 20

/obj/item/organ/internal/heart/cybernetic/tier3/used_dose()
	. = ..()
	addtimer(VARSET_CALLBACK(src, dose_available, TRUE), 5 MINUTES)

/obj/item/organ/internal/heart/cybernetic/surplus
	name = "surplus prosthetic heart"
	desc = "A fragile mockery of a human heart that resembles a water pump more than an actual heart. \
		Offers no protection against EMPs."
	icon_state = "heart-c-s-on"
	base_icon_state = "heart-c-s"
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5
	emp_vulnerability = 100

//surplus organs are so awful that they explode when removed, unless failing
/obj/item/organ/internal/heart/cybernetic/surplus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dangerous_surgical_removal)

/obj/item/organ/internal/heart/freedom
	name = "heart of freedom"
	desc = "This heart pumps with the passion to give... something freedom."
	organ_flags = ORGAN_ROBOTIC  //the power of freedom prevents heart attacks
	/// The cooldown until the next time this heart can give the host an adrenaline boost.
	COOLDOWN_DECLARE(adrenaline_cooldown)

/obj/item/organ/internal/heart/freedom/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.health < 5 && COOLDOWN_FINISHED(src, adrenaline_cooldown))
		COOLDOWN_START(src, adrenaline_cooldown, rand(25 SECONDS, 1 MINUTES))
		to_chat(owner, span_userdanger("You feel yourself dying, but you refuse to give up!"))
		owner.heal_overall_damage(brute = 15, burn = 15, required_bodytype = BODYTYPE_ORGANIC)
		if(owner.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)

