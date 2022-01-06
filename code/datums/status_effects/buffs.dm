//Largely beneficial effects go here, even if they have drawbacks.

/datum/status_effect/his_grace
	id = "his_grace"
	duration = -1
	tick_interval = 4
	alert_type = /atom/movable/screen/alert/status_effect/his_grace
	var/bloodlust = 0

/atom/movable/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/atom/movable/screen/alert/status_effect/his_grace/MouseEntered(location,control,params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>"
	return ..()

/datum/status_effect/his_grace/on_apply()
	owner.log_message("gained His Grace's stun immunity", LOG_ATTACK)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	for(var/obj/item/his_grace/HG in owner.held_items)
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(STATUS_EFFECT_HISWRATH)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05
	owner.adjustBruteLoss(-grace_heal)
	owner.adjustFireLoss(-grace_heal)
	owner.adjustToxLoss(-grace_heal, TRUE, TRUE)
	owner.adjustOxyLoss(-(grace_heal * 2))
	owner.adjustCloneLoss(-grace_heal)

/datum/status_effect/his_grace/on_remove()
	owner.log_message("lost His Grace's stun immunity", LOG_ATTACK)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"


/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /atom/movable/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, span_notice("Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise..."))
	return ..()


/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(full_heal = TRUE, admin_revive = TRUE)
	owner.visible_message(span_warning("[owner] appears to wake from the dead, having healed all wounds!"), span_notice("You have regenerated."))


/atom/movable/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"

/datum/status_effect/cult_master
	id = "The Cult Master"
	duration = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/alive = TRUE

/datum/status_effect/cult_master/proc/deathrattle()
	if(!QDELETED(GLOB.cult_narsie))
		return //if Nar'Sie is alive, don't even worry about it
	var/area/A = get_area(owner)
	for(var/datum/mind/B as anything in get_antag_minds(/datum/antagonist/cult))
		if(isliving(B.current))
			var/mob/living/M = B.current
			SEND_SOUND(M, sound('sound/hallucinations/veryfar_noise.ogg'))
			to_chat(M, span_cultlarge("The Cult's Master, [owner], has fallen in \the [A]!"))

/datum/status_effect/cult_master/tick()
	if(owner.stat != DEAD && !alive)
		alive = TRUE
		return
	if(owner.stat == DEAD && alive)
		alive = FALSE
		deathrattle()

/datum/status_effect/cult_master/on_remove()
	deathrattle()
	. = ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blooddrunk

/atom/movable/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, BLOODDRUNK_TRAIT)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.physiology.brute_mod *= 0.1
			H.physiology.burn_mod *= 0.1
			H.physiology.tox_mod *= 0.1
			H.physiology.oxy_mod *= 0.1
			H.physiology.clone_mod *= 0.1
			H.physiology.stamina_mod *= 0.1
		owner.log_message("gained blood-drunk stun immunity", LOG_ATTACK)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1, use_reverb = FALSE)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 10
		H.physiology.burn_mod *= 10
		H.physiology.tox_mod *= 10
		H.physiology.oxy_mod *= 10
		H.physiology.clone_mod *= 10
		H.physiology.stamina_mod *= 10
	owner.log_message("lost blood-drunk stun immunity", LOG_ATTACK)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, BLOODDRUNK_TRAIT);
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

/datum/status_effect/sword_spin
	id = "Bastard Sword Spin"
	duration = 50
	tick_interval = 8
	alert_type = null


/datum/status_effect/sword_spin/on_apply()
	owner.visible_message(span_danger("[owner] begins swinging the sword with inhuman strength!"))
	var/oldcolor = owner.color
	owner.color = "#ff0000"
	owner.add_stun_absorption("bloody bastard sword", duration, 2, "doesn't even flinch as the sword's power courses through them!", "You shrug off the stun!", " glowing with a blazing red aura!")
	owner.spin(duration,1)
	animate(owner, color = oldcolor, time = duration, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), duration)
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	return ..()


/datum/status_effect/sword_spin/tick()
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	var/obj/item/slashy
	slashy = owner.get_active_held_item()
	for(var/mob/living/M in orange(1,owner))
		slashy.attack(M, owner)

/datum/status_effect/sword_spin/on_remove()
	owner.visible_message(span_warning("[owner]'s inhuman strength dissipates and the sword's runes grow cold!"))


//Used by changelings to rapidly heal
//Heals 10 brute and oxygen damage every second, and 5 fire
//Being on fire will suppress this healing
/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend

/datum/status_effect/fleshmend/tick()
	if(owner.on_fire)
		linked_alert.icon_state = "fleshmend_fire"
		return
	else
		linked_alert.icon_state = "fleshmend"
	owner.adjustBruteLoss(-10, FALSE)
	owner.adjustFireLoss(-5, FALSE)
	owner.adjustOxyLoss(-10)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	QDEL_LIST(C.all_scars)

/atom/movable/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing. <i>This effect is prevented if we are on fire.</i>"
	icon_state = "fleshmend"

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS

//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocratic_oath
	id = "Hippocratic Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	examine_text = "<span class='notice'>They seem to have an aura of healing and helpfulness about them.</span>"
	alert_type = null

	var/datum/component/aura_healing/aura_healing
	var/hand
	var/deathTick = 0

/datum/status_effect/hippocratic_oath/on_apply()
	var/static/list/organ_healing = list(
		ORGAN_SLOT_BRAIN = 1.4,
	)

	aura_healing = owner.AddComponent( \
		/datum/component/aura_healing, \
		range = 7, \
		brute_heal = 1.4, \
		burn_heal = 1.4, \
		toxin_heal = 1.4, \
		suffocation_heal = 1.4, \
		stamina_heal = 1.4, \
		clone_heal = 0.4, \
		simple_heal = 1.4, \
		organ_healing = organ_healing, \
		healing_color = "#375637", \
	)

	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, HIPPOCRATIC_OATH_TRAIT)
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	return ..()

/datum/status_effect/hippocratic_oath/on_remove()
	QDEL_NULL(aura_healing)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, HIPPOCRATIC_OATH_TRAIT)
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(owner)

/datum/status_effect/hippocratic_oath/tick()
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick += 1
		else
			consume_owner()
	else
		if(iscarbon(owner))
			var/mob/living/carbon/itemUser = owner
			var/obj/item/heldItem = itemUser.get_item_for_held_index(hand)
			if(heldItem == null || heldItem.type != /obj/item/rod_of_asclepius) //Checks to make sure the rod is still in their hand
				var/obj/item/rod_of_asclepius/newRod = new(itemUser.loc)
				newRod.activated()
				if(!itemUser.has_hand_for_held_index(hand))
					//If user does not have the corresponding hand anymore, give them one and return the rod to their hand
					if(((hand % 2) == 0))
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_R_ARM, FALSE, FALSE)
						if(L.attach_limb(itemUser))
							itemUser.put_in_hand(newRod, hand, forced = TRUE)
						else
							qdel(L)
							consume_owner() //we can't regrow, abort abort
							return
					else
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_L_ARM, FALSE, FALSE)
						if(L.attach_limb(itemUser))
							itemUser.put_in_hand(newRod, hand, forced = TRUE)
						else
							qdel(L)
							consume_owner() //see above comment
							return
					to_chat(itemUser, span_notice("Your arm suddenly grows back with the Rod of Asclepius still attached!"))
				else
					//Otherwise get rid of whatever else is in their hand and return the rod to said hand
					itemUser.put_in_hand(newRod, hand, forced = TRUE)
					to_chat(itemUser, span_notice("The Rod of Asclepius suddenly grows back out of your arm!"))
			//Because a servant of medicines stops at nothing to help others, lets keep them on their toes and give them an additional boost.
			if(itemUser.health < itemUser.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(itemUser), "#375637")
			itemUser.adjustBruteLoss(-1.5)
			itemUser.adjustFireLoss(-1.5)
			itemUser.adjustToxLoss(-1.5, forced = TRUE) //Because Slime People are people too
			itemUser.adjustOxyLoss(-1.5)
			itemUser.adjustStaminaLoss(-1.5)
			itemUser.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1.5)
			itemUser.adjustCloneLoss(-0.5) //Becasue apparently clone damage is the bastion of all health

/datum/status_effect/hippocratic_oath/proc/consume_owner()
	owner.visible_message(span_notice("[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty."))
	var/list/chems = list(/datum/reagent/medicine/sal_acid, /datum/reagent/medicine/c2/convermol, /datum/reagent/medicine/oxandrolone)
	var/mob/living/simple_animal/hostile/retaliate/snake/healSnake = new(owner.loc, pick(chems))
	healSnake.name = "Asclepius's Snake"
	healSnake.real_name = "Asclepius's Snake"
	healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
	new /obj/effect/decal/cleanable/ash(owner.loc)
	new /obj/item/rod_of_asclepius(owner.loc)
	qdel(owner)


/datum/status_effect/good_music
	id = "Good Music"
	alert_type = null
	duration = 6 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/good_music/tick()
	if(owner.can_hear())
		owner.dizziness = max(0, owner.dizziness - 2)
		owner.jitteriness = max(0, owner.jitteriness - 2)
		owner.set_confusion(max(0, owner.get_confusion() - 1))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "goodmusic", /datum/mood_event/goodmusic)

/atom/movable/screen/alert/status_effect/regenerative_core
	name = "Regenerative Core Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/regenerative_core

/datum/status_effect/regenerative_core/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)
	owner.adjustBruteLoss(-25)
	owner.adjustFireLoss(-25)
	owner.remove_CC()
	owner.bodytemperature = owner.get_body_temp_normal()
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/humi = owner
		humi.set_coretemperature(humi.get_body_temp_normal())
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)

/datum/status_effect/antimagic
	id = "antimagic"
	duration = 10 SECONDS
	examine_text = "<span class='notice'>They seem to be covered in a dull, grey aura.</span>"

/datum/status_effect/antimagic/on_apply()
	owner.visible_message(span_notice("[owner] is coated with a dull aura!"))
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	//glowing wings overlay
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	return ..()

/datum/status_effect/antimagic/on_remove()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	owner.visible_message(span_warning("[owner]'s dull aura fades away..."))

/datum/status_effect/crucible_soul
	id = "Blessing of Crucible Soul"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	examine_text = "<span class='notice'>They don't seem to be all here.</span>"
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul
	var/turf/location

/datum/status_effect/crucible_soul/on_apply()
	. = ..()
	to_chat(owner,span_notice("You phase through reality, nothing is out of bounds!"))
	owner.alpha = 180
	owner.pass_flags |= PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE
	location = get_turf(owner)

/datum/status_effect/crucible_soul/on_remove()
	to_chat(owner,span_notice("You regain your physicality, returning you to your original location..."))
	owner.alpha = initial(owner.alpha)
	owner.pass_flags &= ~(PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE)
	owner.forceMove(location)
	location = null
	return ..()

/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	alert_type =/atom/movable/screen/alert/status_effect/duskndawn

/datum/status_effect/duskndawn/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, STATUS_EFFECT_TRAIT)
	owner.update_sight()

/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, STATUS_EFFECT_TRAIT)
	owner.update_sight()
	return ..()

/datum/status_effect/marshal
	id = "Blessing of Wounded Soldier"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/marshal

/datum/status_effect/marshal/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)

/datum/status_effect/marshal/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)

/datum/status_effect/marshal/tick()
	. = ..()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbie = owner

	for(var/BP in carbie.bodyparts)
		var/obj/item/bodypart/part = BP
		for(var/W in part.wounds)
			var/datum/wound/wound = W
			var/heal_amt = 0

			switch(wound.severity)
				if(WOUND_SEVERITY_MODERATE)
					heal_amt = 1
				if(WOUND_SEVERITY_SEVERE)
					heal_amt = 3
				if(WOUND_SEVERITY_CRITICAL)
					heal_amt = 6
			if(wound.wound_type == WOUND_BURN)
				carbie.adjustFireLoss(-heal_amt)
			else
				carbie.adjustBruteLoss(-heal_amt)
				carbie.blood_volume += carbie.blood_volume >= BLOOD_VOLUME_NORMAL ? 0 : heal_amt*3


/atom/movable/screen/alert/status_effect/crucible_soul
	name = "Blessing of Crucible Soul"
	desc = "You phased through the reality, you are halfway to your final destination..."
	icon_state = "crucible"

/atom/movable/screen/alert/status_effect/duskndawn
	name = "Blessing of Dusk and Dawn"
	desc = "Many things hide beyond the horizon, with Owl's help i managed to slip past sun's guard and moon's watch."
	icon_state = "duskndawn"

/atom/movable/screen/alert/status_effect/marshal
	name = "Blessing of Wounded Soldier"
	desc = "Some people seek power through redemption, one thing many people don't know is that battle is the ultimate redemption and wounds let you bask in eternal glory."
	icon_state = "wounded_soldier"

/datum/status_effect/lightningorb
	id = "Lightning Orb"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/lightningorb

/datum/status_effect/lightningorb/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/yellow_orb)
	to_chat(owner, span_notice("You feel fast!"))

/datum/status_effect/lightningorb/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/yellow_orb)
	to_chat(owner, span_notice("You slow down."))

/atom/movable/screen/alert/status_effect/lightningorb
	name = "Lightning Orb"
	desc = "The speed surges through you!"
	icon_state = "lightningorb"

/datum/status_effect/mayhem
	id = "Mayhem"
	duration = 2 MINUTES
	/// The chainsaw spawned by the status effect
	var/obj/item/chainsaw/doomslayer/chainsaw

/datum/status_effect/mayhem/on_apply()
	. = ..()
	to_chat(owner, "<span class='reallybig redtext'>RIP AND TEAR</span>")
	SEND_SOUND(owner, sound('sound/hallucinations/veryfar_noise.ogg'))
	new /datum/hallucination/delusion(owner, forced = TRUE, force_kind = "demon", duration = duration, skip_nearby = FALSE)
	chainsaw = new(get_turf(owner))
	owner.log_message("entered a blood frenzy", LOG_ATTACK)
	ADD_TRAIT(chainsaw, TRAIT_NODROP, CHAINSAW_FRENZY_TRAIT)
	owner.drop_all_held_items()
	owner.put_in_hands(chainsaw, forced = TRUE)
	chainsaw.attack_self(owner)
	owner.reagents.add_reagent(/datum/reagent/medicine/adminordrazine,25)
	to_chat(owner, span_warning("KILL, KILL, KILL! YOU HAVE NO ALLIES ANYMORE, KILL THEM ALL!"))
	var/datum/client_colour/colour = owner.add_client_colour(/datum/client_colour/bloodlust)
	QDEL_IN(colour, 1.1 SECONDS)

/datum/status_effect/mayhem/on_remove()
	. = ..()
	to_chat(owner, span_notice("Your bloodlust seeps back into the bog of your subconscious and you regain self control."))
	owner.log_message("exited a blood frenzy", LOG_ATTACK)
	QDEL_NULL(chainsaw)

/datum/status_effect/speed_boost
	id = "speed_boost"
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/speed_boost/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/speed_boost/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost, update = TRUE)
	return ..()

/datum/status_effect/speed_boost/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost, update = TRUE)

/datum/movespeed_modifier/status_speed_boost
	multiplicative_slowdown = -1

///this buff provides a max health buff and a heal.
/datum/status_effect/limited_buff/health_buff
	id = "health_buff"
	alert_type = null
	///This var stores the mobs max health when the buff was first applied, and determines the size of future buffs.database.database.
	var/historic_max_health
	///This var determines how large the health buff will be. health_buff_modifier * historic_max_health * stacks
	var/health_buff_modifier = 0.1 //translate to a 10% buff over historic health per stack
	///This modifier multiplies the healing by the effect.
	var/healing_modifier = 2
	///If the mob has a low max health, we instead use this flat value to increase max health and calculate any heal.
	var/fragile_mob_health_buff = 10

/datum/status_effect/limited_buff/health_buff/on_creation(mob/living/new_owner)
	historic_max_health = new_owner.maxHealth
	. = ..()

/datum/status_effect/limited_buff/health_buff/on_apply()
	. = ..()
	var/health_increase = round(max(fragile_mob_health_buff, historic_max_health * health_buff_modifier))
	owner.maxHealth += health_increase
	owner.balloon_alert_to_viewers("health buffed")
	to_chat(owner, span_nicegreen("You feel healthy, like if your body is little stronger than it was a moment ago."))

	if(isanimal(owner))	//dumb animals have their own proc for healing.
		var/mob/living/simple_animal/healthy_animal = owner
		healthy_animal.adjustHealth(-(health_increase * healing_modifier))
	else
		owner.adjustBruteLoss(-(health_increase * healing_modifier))

/datum/status_effect/limited_buff/health_buff/maxed_out()
	. = ..()
	to_chat(owner, span_warning("You don't feel any healthier."))

