/datum/element/embed
	element_flags = ELEMENT_DETACH
	var/list/active_embeds = list()
	id_arg_index = 2

	var/embed_chance
	var/fall_chance
	var/pain_chance
	var/pain_mult //The coefficient of multiplication for the damage this item does while embedded (this*w_class)
	var/fall_pain_mult //The coefficient of multiplication for the damage this item does when falling out of a limb (this*w_class)
	var/impact_pain_mult //The coefficient of multiplication for the damage this item does when first embedded (this*w_class)
	var/rip_pain_mult //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
	var/rip_time //A time in ticks, multiplied by the w_class.
	var/ignore_throwspeed_threshold //if we don't give a damn about EMBED_THROWSPEED_THRESHOLD
	var/jostle_chance //Chance to cause pain every time the victim moves (1/2 chance if they're walking or crawling)
	var/jostle_pain_mult //The coefficient of multiplication for the damage when jostle damage is applied (this*w_class)
	var/pain_stam_pct //Percentage of all pain damage dealt as stamina instead of brute (none by default)

	var/harmless = FALSE

/datum/element/embed/New()
	. = ..()
	START_PROCESSING(SSdcs, src)

/datum/element/embed/Attach(datum/target,
	embed_chance,
    fall_chance,
    pain_chance,
    pain_mult,
    fall_pain_mult,
    impact_pain_mult,
    rip_pain_mult,
    rip_time,
    ignore_throwspeed_threshold,
	jostle_chance,
	jostle_pain_mult,
	pain_stam_pct)

	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.embed_chance = (!isnull(embed_chance) ? embed_chance : EMBED_CHANCE)
	src.fall_chance = (!isnull(fall_chance) ? fall_chance : EMBEDDED_ITEM_FALLOUT)
	src.pain_chance = (!isnull(pain_chance) ? pain_chance : EMBEDDED_PAIN_CHANCE)
	src.pain_mult = (!isnull(pain_mult) ? pain_mult : EMBEDDED_PAIN_MULTIPLIER)
	src.fall_pain_mult = (!isnull(fall_pain_mult) ? fall_pain_mult : EMBEDDED_FALL_PAIN_MULTIPLIER)
	src.impact_pain_mult = (!isnull(impact_pain_mult) ? impact_pain_mult : EMBEDDED_IMPACT_PAIN_MULTIPLIER)
	src.rip_pain_mult = (!isnull(rip_pain_mult) ? rip_pain_mult : EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER)
	src.rip_time = (!isnull(rip_time) ? rip_time : EMBEDDED_UNSAFE_REMOVAL_TIME)
	src.ignore_throwspeed_threshold = (!isnull(ignore_throwspeed_threshold) ? ignore_throwspeed_threshold : FALSE)
	src.jostle_chance = (!isnull(jostle_chance) ? jostle_chance : EMBEDDED_JOSTLE_CHANCE)
	src.jostle_pain_mult = (!isnull(jostle_pain_mult) ? jostle_pain_mult : EMBEDDED_JOSTLE_PAIN_MULTIPLIER)
	src.pain_stam_pct = (!isnull(pain_stam_pct) ? pain_stam_pct : EMBEDDED_PAIN_STAM_PCT)

	harmless = (pain_mult == 0 && jostle_pain_mult == 0)


	RegisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE, .proc/embed_check)
	RegisterSignal(target, COMSIG_ITEM_EMBED_REMOVING_RIP, .proc/rip_out)
	RegisterSignal(target, COMSIG_ITEM_EMBED_REMOVE_SURGERY, .proc/safe_remove)

/datum/element/embed/Detach(obj/item/target)
	. = ..()

	if(target in active_embeds)
		active_embeds -= target

	UnregisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE)
	UnregisterSignal(target, COMSIG_ITEM_EMBED_REMOVING_RIP)
	UnregisterSignal(target, COMSIG_ITEM_EMBED_REMOVE_SURGERY)

/datum/element/embed/proc/jostle_check(mob/living/carbon/human/victim)
	for(var/obj/item/bodypart/L in victim.bodyparts)
		for(var/obj/item/weapon in L.embedded_objects)

			if(!harmless)
				var/chance = jostle_chance
				if(victim.m_intent == MOVE_INTENT_WALK || victim.lying)
					chance *= 0.5

				if(prob(chance))
					var/damage = weapon.w_class * jostle_pain_mult
					L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
					to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [L.name] jostles and stings!</span>")

/datum/element/embed/proc/embed_check(obj/item/weapon, mob/living/carbon/human/victim, hit_zone, datum/thrownthing/throwingdatum)
	if(!istype(victim))
		return

	if(((throwingdatum ? throwingdatum.speed : weapon.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || ignore_throwspeed_threshold)
		if(prob(embed_chance) && !HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))

			var/obj/item/bodypart/L = pick(victim.bodyparts)
			weapon.embedded_in = L // on the inside... on the inside...
			L.embedded_objects |= weapon
			weapon.forceMove(victim)
			active_embeds += weapon

			if(weapon.is_embed_harmless())
				victim.visible_message("<span class='danger'>[weapon] sticks to [victim]'s [L.name]!</span>","<span class='userdanger'>[weapon] sticks to your [L.name]!</span>")
			else
				victim.visible_message("<span class='danger'>[weapon] embeds itself in [victim]'s [L.name]!</span>","<span class='userdanger'>[weapon] embeds itself in your [L.name]!</span>")
				victim.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
				playsound(victim,'sound/weapons/bladeslice.ogg', 40)
				weapon.add_mob_blood(victim)//it embedded itself in you, of course it's bloody!

				var/damage = weapon.w_class * impact_pain_mult
				L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)

				SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
				RegisterSignal(victim, COMSIG_MOVABLE_MOVED, .proc/jostle_check)

			return TRUE

/datum/element/embed/proc/fall_out(obj/item/weapon, mob/living/carbon/human/victim)
	var/obj/item/bodypart/L = weapon.embedded_in

	if(harmless)
		victim.visible_message("<span class='danger'>[weapon] falls off of [victim.name]'s [L.name]!</span>","<span class='userdanger'>[weapon] falls off of your [L.name]!</span>")
	else
		var/damage = weapon.w_class * fall_pain_mult
		L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		victim.visible_message("<span class='danger'>[weapon] falls out of [victim.name]'s [L.name]!</span>","<span class='userdanger'>[weapon] falls out of your [L.name]!</span>")

	safe_remove(weapon, victim, L)
	weapon.forceMove(victim.drop_location())

/datum/element/embed/proc/rip_out(obj/item/weapon, mob/living/carbon/human/victim, obj/item/bodypart/L)
	var/time_taken = rip_time * weapon.w_class

	victim.visible_message("<span class='warning'>[victim] attempts to remove [weapon] from [victim.p_their()] [L.name].</span>","<span class='notice'>You attempt to remove [weapon] from your [L.name]... (It will take [DisplayTimeText(time_taken)].)</span>")
	if(do_after(victim, time_taken, needhand = 1, target = victim))
		if(!weapon || !L || weapon.loc != victim || !(weapon in L.embedded_objects))
			active_embeds -= weapon
			if(!victim.has_embedded_objects())
				UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
			return

		if(weapon.is_embed_harmless())
			victim.visible_message("<span class='notice'>[victim] successfully unsticks [weapon] from [victim.p_their()] [L.name]!</span>", "<span class='notice'>You successfully unstick [weapon] from your [L.name].</span>")
		else
			var/damage = weapon.w_class * rip_pain_mult
			L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage) //It hurts to rip it out, get surgery you dingus.
			victim.emote("scream")
			victim.visible_message("<span class='notice'>[victim] successfully rips [weapon] out of [victim.p_their()] [L.name]!</span>", "<span class='notice'>You successfully remove [weapon] from your [L.name].</span>")

		safe_remove(weapon, victim, L)
		victim.put_in_hands(weapon)

/datum/element/embed/proc/safe_remove(obj/item/weapon, mob/living/carbon/human/victim, obj/item/bodypart/L)
	L.embedded_objects -= weapon
	weapon.embedded_in = null
	weapon.forceMove(get_turf(victim))
	active_embeds -= weapon

	if(!victim.has_embedded_objects())
		victim.clear_alert("embeddedobject")
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "embedded")

/datum/element/embed/process()
	for(var/obj/item/weapon in active_embeds)
		var/obj/item/bodypart/L = weapon.embedded_in
		var/mob/living/carbon/human/victim = L.owner

		if(!victim || !L) // in case the victim and/or their limbs exploded (say, due to a sticky bomb)
			active_embeds -= weapon
			if(victim && !victim.has_embedded_objects())
				UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
			weapon.embedded_in = null
			weapon.forceMove(get_turf(weapon))
			continue

		if(victim.stat == DEAD)
			continue

		if(!harmless && prob(pain_chance))
			var/damage = weapon.w_class * pain_mult
			L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
			to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [L.name] hurts!</span>")

		if(prob(fall_chance))
			fall_out(weapon, victim)
