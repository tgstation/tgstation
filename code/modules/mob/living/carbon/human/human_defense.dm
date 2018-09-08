/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(def_zone))
		return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += checkarmor(BP, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor.getRating(d_type)
	protection += physiology.armor.getRating(d_type)
	return protection

/mob/living/carbon/human/on_hit(obj/item/projectile/P)
	if(dna && dna.species)
		dna.species.on_hit(P, src)


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(dna && dna.species)
		var/spec_return = dna.species.bullet_act(P, src)
		if(spec_return)
			return spec_return

	if(mind)
		if(mind.martial_art && !incapacitated(FALSE, TRUE) && mind.martial_art.can_use(src) && mind.martial_art.deflection_chance) //Some martial arts users can deflect projectiles!
			if(prob(mind.martial_art.deflection_chance))
				if(!lying && dna && !dna.check_mutation(HULK)) //But only if they're not lying down, and hulks can't do it
					if(mind.martial_art.deflection_chance >= 100) //if they can NEVER be hit, lets clue sec in ;)
						visible_message("<span class='danger'>[src] deflects the projectile; [p_they()] can't be hit with ranged weapons!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
					else
						visible_message("<span class='danger'>[src] deflects the projectile!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
					playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
					return 0

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		if(P.is_reflectable)
			if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
								"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
				// Find a turf near or on the original location to bounce to
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/curloc = get_turf(src)

					// redirect the projectile
					P.original = locate(new_x, new_y, P.z)
					P.starting = curloc
					P.firer = src
					P.yo = new_y - curloc.y
					P.xo = new_x - curloc.x
					var/new_angle_s = P.Angle + rand(120,240)
					while(new_angle_s > 180)	// Translate to regular projectile degrees
						new_angle_s -= 360
					P.setAngle(new_angle_s)

				return -1 // complete projectile permutation

		if(check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armour_penetration))
			P.on_hit(src, 100, def_zone)
			return 2

	return (..(P , def_zone))

/mob/living/carbon/human/proc/check_reflect(def_zone) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance of the object
	if(wear_suit)
		if(wear_suit.IsReflect(def_zone) == 1)
			return 1
	for(var/obj/item/I in held_items)
		if(I.IsReflect(def_zone) == 1)
			return 1
	return 0

/mob/living/carbon/human/proc/check_shields(atom/AM, var/damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	var/block_chance_modifier = round(damage / -3)

	for(var/obj/item/I in held_items)
		if(!istype(I, /obj/item/clothing))
			var/final_block_chance = I.block_chance - (CLAMP((armour_penetration-I.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
			if(I.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
				return 1
	if(wear_suit)
		var/final_block_chance = wear_suit.block_chance - (CLAMP((armour_penetration-wear_suit.armour_penetration)/2,0,100)) + block_chance_modifier
		if(wear_suit.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(w_uniform)
		var/final_block_chance = w_uniform.block_chance - (CLAMP((armour_penetration-w_uniform.armour_penetration)/2,0,100)) + block_chance_modifier
		if(w_uniform.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return 1
	return 0

/mob/living/carbon/human/proc/check_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
			return TRUE
	return FALSE

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE)
	if(dna && dna.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at yourself to trigger hit reactions
			return ..()
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
	else if(I)
		if(I.throw_speed >= EMBED_THROWSPEED_THRESHOLD)
			if(can_embed(I))
				if(prob(I.embedding.embed_chance) && !has_trait(TRAIT_PIERCEIMMUNE))
					throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
					var/obj/item/bodypart/L = pick(bodyparts)
					L.embedded_objects |= I
					I.add_mob_blood(src)//it embedded itself in you, of course it's bloody!
					I.forceMove(src)
					L.receive_damage(I.w_class*I.embedding.embedded_impact_pain_multiplier)
					visible_message("<span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>","<span class='userdanger'>[I] embeds itself in your [L.name]!</span>")
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
					hitpush = FALSE
					skipcatch = TRUE //can't catch the now embedded item

	return ..()

/mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message = 0)
	if(user == src && pulling && !pulling.anchored && grab_state >= GRAB_AGGRESSIVE && (has_trait(TRAIT_FAT)) && ismonkey(pulling))
		devour_mob(pulling)
	else
		..()

/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	..()


/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	if(!I || !user)
		return 0

	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.zone_selected)) //stabbing yourself always hits the right target
	else
		affecting = get_bodypart(ran_zone(user.zone_selected))
	var/target_area = parse_zone(check_zone(user.zone_selected)) //our intended target

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, target_area)

	// the attacked_by code varies among species
	return dna.species.spec_attacked_by(I, user, affecting, a_intent, src)


/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		var/hulk_verb = pick("smash","pummel")
		if(check_shields(user, 15, "the [hulk_verb]ing"))
			return
		..(user, 1)
		playsound(loc, user.dna.species.attack_sound, 25, 1, -1)
		var/message = "[user] has [hulk_verb]ed [src]!"
		visible_message("<span class='danger'>[message]</span>", \
								"<span class='userdanger'>[message]</span>")
		adjustBruteLoss(15)
		return 1

/mob/living/carbon/human/attack_hand(mob/user)
	if(..())	//to allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src)

/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M)
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	if(M.a_intent == INTENT_HELP)
		..() //shaking
		return 0

	if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stunned instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
					"<span class='userdanger'>[M] disarmed [src]!</span>")
		else if(!M.client || prob(5)) // only natural monkeys get to stun reliably, (they only do it occasionaly)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			Knockdown(100)
			log_combat(M, src, "tackled")
			visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
				"<span class='userdanger'>[M] has tackled down [src]!</span>")

	if(M.limb_destroyer)
		dismembering_strike(M, affecting.body_zone)

	if(can_inject(M, 1, affecting))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			if(check_shields(M, damage, "the [M.name]"))
				return 0
			if(stat != DEAD)
				apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"))
		return 1

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(M, 0, "the M.name"))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == INTENT_HARM)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = prob(90) ? 20 : 0
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
					"<span class='userdanger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, "melee","","",10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")
			log_combat(M, src, "attacked")
			if(!dismembering_strike(M, M.zone_selected)) //Dismemberment successful
				return 1
			apply_damage(damage, BRUTE, affecting, armor_block)

		if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stun instead.
			var/obj/item/I = get_active_held_item()
			if(I && dropItemToGround(I))
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
						"<span class='userdanger'>[M] disarmed [src]!</span>")
			else
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Knockdown(100)
				log_combat(M, src, "tackled")
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
					"<span class='userdanger'>[M] has tackled down [src]!</span>")


/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)

	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(check_shields(L, damage, "the [L.name]"))
			return 0
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(M, damage, "the [M.name]", MELEE_ATTACK, M.armour_penetration))
			return FALSE
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor = run_armor_check(affecting, "melee", armour_penetration = M.armour_penetration)
		apply_damage(damage, M.melee_damage_type, affecting, armor)


/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 25)
		if(M.is_adult)
			damage = rand(10, 35)

		if(check_shields(M, damage, "the [M.name]"))
			return 0

		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return 1

		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)

	if(M.occupant.a_intent == INTENT_HARM)
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/bodypart/temp = get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(temp)
			var/update = 0
			var/dmg = rand(M.force/2, M.force)
			switch(M.damtype)
				if("brute")
					if(M.force > 20)
						Unconscious(20)
					update |= temp.receive_damage(dmg, 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
				if("fire")
					update |= temp.receive_damage(0, dmg)
					playsound(src, 'sound/items/welder.ogg', 50, 1)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			if(update)
				update_damage_overlays()
			updatehealth()

		visible_message("<span class='danger'>[M.name] has hit [src]!</span>", \
								"<span class='userdanger'>[M.name] has hit [src]!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")

	else
		..()


/mob/living/carbon/human/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if (!severity)
		return
	var/b_loss = 0
	var/f_loss = 0
	var/bomb_armor = getarmor(null, "bomb")

	switch (severity)
		if (1)
			if(prob(bomb_armor))
				b_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, "bomb")
			else
				for(var/I in contents)
					var/atom/A = I
					A.ex_act(severity)
				gib()
				return

		if (2)
			b_loss = 60
			f_loss = 60
			if(bomb_armor)
				b_loss = 30*(2 - round(bomb_armor*0.01, 0.05))
				f_loss = b_loss
			damage_clothes(200 - bomb_armor, BRUTE, "bomb")
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30, 120)
			if (prob(max(70 - (bomb_armor * 0.5), 0)))
				Unconscious(200)

		if(3)
			b_loss = 30
			if(bomb_armor)
				b_loss = 15*(2 - round(bomb_armor*0.01, 0.05))
			damage_clothes(max(50 - bomb_armor, 0), BRUTE, "bomb")
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			if (prob(max(50 - (bomb_armor * 0.5), 0)))
				Unconscious(160)

	take_overall_damage(b_loss,f_loss)

	//attempt to dismember bodyparts
	if(severity <= 2 || !bomb_armor)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && !prob(getarmor(BP, "bomb")) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break


/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))


//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, override = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	if(tesla_shock)
		var/total_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			if(G.siemens_coefficient <= 0)
				total_coeff -= 0.5
		if(wear_suit)
			var/obj/item/clothing/suit/S = wear_suit
			if(S.siemens_coefficient <= 0)
				total_coeff -= 0.95
			else if(S.siemens_coefficient == (-1))
				total_coeff -= 1
		siemens_coeff = total_coeff
		if(flags_1 & TESLA_IGNORE_1)
			siemens_coeff = 0
	else if(!safety)
		var/gloves_siemens_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			gloves_siemens_coeff = G.siemens_coefficient
		siemens_coeff = gloves_siemens_coeff
	if(undergoing_cardiac_arrest() && !illusion)
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
			heart.beating = TRUE
			if(stat == CONSCIOUS)
				to_chat(src, "<span class='notice'>You feel your heart beating again!</span>")
	siemens_coeff *= physiology.siemens_coeff
	. = ..(shock_damage,source,siemens_coeff,safety,override,tesla_shock, illusion, stun)
	if(.)
		electrocution_animation(40)


/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/informed = FALSE
	for(var/obj/item/bodypart/L in src.bodyparts)
		if(L.status == BODYPART_ROBOTIC)
			if(!informed)
				to_chat(src, "<span class='userdanger'>You feel a sharp pain as your robotic limbs overload.</span>")
				informed = TRUE
			switch(severity)
				if(1)
					L.receive_damage(0,10)
					Stun(200)
				if(2)
					L.receive_damage(0,5)
					Stun(100)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit)
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume*0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_neck()
				update_inv_head()
			else
				to_chat(src, "<span class='notice'>Your [head_clothes.name] protects your head and face from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(ears)
				inventory_items_to_kill += ears

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [chest_clothes.name] protects your body from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [arm_clothes.name] protects your arms and hands from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [leg_clothes.name] protects your legs and feet from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/bodypart/affecting in damaged)
		affecting.receive_damage(acidity, 2*acidity)

		if(affecting.name == BODY_ZONE_HEAD)
			if(prob(min(acidpwr*acid_volume/10, 90))) //Applies disfigurement
				affecting.receive_damage(acidity, 2*acidity)
				emote("scream")
				facial_hair_style = "Shaved"
				hair_style = "Bald"
				update_hair()
				add_trait(TRAIT_DISFIGURED, TRAIT_GENERIC)

		update_damage_overlays()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/I in inventory_items_to_kill)
		I.acid_act(acidpwr, acid_volume)
	return 1

/mob/living/carbon/human/singularity_act()
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-300, 300)
	investigate_log("([key_name(src)]) has been consumed by the singularity.", INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(health >= 0)
		if(src == M)
			visible_message("[src] examines [p_them()]self.", \
				"<span class='notice'>You check yourself for injuries.</span>")

			var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			for(var/X in bodyparts)
				var/obj/item/bodypart/LB = X
				missing -= LB.body_zone
				if(LB.is_pseudopart) //don't show injury text for fake bodyparts; ie chainsaw arms or synthetic armblades
					continue
				var/limb_max_damage = LB.max_damage
				var/status = ""
				var/brutedamage = LB.brute_dam
				var/burndamage = LB.burn_dam
				if(hallucination)
					if(prob(30))
						brutedamage += rand(30,40)
					if(prob(30))
						burndamage += rand(30,40)

				if(has_trait(TRAIT_SELF_AWARE))
					status = "[brutedamage] brute damage and [burndamage] burn damage"
					if(!brutedamage && !burndamage)
						status = "no damage"

				else
					if(brutedamage > 0)
						status = LB.light_brute_msg
					if(brutedamage > (limb_max_damage*0.4))
						status = LB.medium_brute_msg
					if(brutedamage > (limb_max_damage*0.8))
						status = LB.heavy_brute_msg
					if(brutedamage > 0 && burndamage > 0)
						status += " and "

					if(burndamage > (limb_max_damage*0.8))
						status += LB.heavy_burn_msg
					else if(burndamage > (limb_max_damage*0.2))
						status += LB.medium_burn_msg
					else if(burndamage > 0)
						status += LB.light_burn_msg

					if(status == "")
						status = "OK"
				var/no_damage
				if(status == "OK" || status == "no damage")
					no_damage = TRUE
				to_chat(src, "\t <span class='[no_damage ? "notice" : "warning"]'>Your [LB.name] [has_trait(TRAIT_SELF_AWARE) ? "has" : "is"] [status].</span>")

				for(var/obj/item/I in LB.embedded_objects)
					to_chat(src, "\t <a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] embedded in your [LB.name]!</a>")

			for(var/t in missing)
				to_chat(src, "<span class='boldannounce'>Your [parse_zone(t)] is missing!</span>")

			if(bleed_rate)
				to_chat(src, "<span class='danger'>You are bleeding!</span>")
			if(getStaminaLoss())
				if(getStaminaLoss() > 30)
					to_chat(src, "<span class='info'>You're completely exhausted.</span>")
				else
					to_chat(src, "<span class='info'>You feel fatigued.</span>")
			if(has_trait(TRAIT_SELF_AWARE))
				if(toxloss)
					if(toxloss > 10)
						to_chat(src, "<span class='danger'>You feel sick.</span>")
					else if(toxloss > 20)
						to_chat(src, "<span class='danger'>You feel nauseated.</span>")
					else if(toxloss > 40)
						to_chat(src, "<span class='danger'>You feel very unwell!</span>")
				if(oxyloss)
					if(oxyloss > 10)
						to_chat(src, "<span class='danger'>You feel lightheaded.</span>")
					else if(oxyloss > 20)
						to_chat(src, "<span class='danger'>Your thinking is clouded and distant.</span>")
					else if(oxyloss > 30)
						to_chat(src, "<span class='danger'>You're choking!</span>")

			switch(nutrition)
				if(NUTRITION_LEVEL_FULL to INFINITY)
					to_chat(src, "<span class='info'>You're completely stuffed!</span>")
				if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
					to_chat(src, "<span class='info'>You're well fed!</span>")
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					to_chat(src, "<span class='info'>You're not hungry.</span>")
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					to_chat(src, "<span class='info'>You could use a bite to eat.</span>")
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					to_chat(src, "<span class='info'>You feel quite hungry.</span>")
				if(0 to NUTRITION_LEVEL_STARVING)
					to_chat(src, "<span class='danger'>You're starving!</span>")

			if(roundstart_quirks.len)
				to_chat(src, "<span class='notice'>You have these quirks: [get_trait_string()].</span>")
		else
			if(wear_suit)
				wear_suit.add_fingerprint(M)
			else if(w_uniform)
				w_uniform.add_fingerprint(M)

			..()


/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	var/list/torn_items = list()

	//HEAD//
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	//CHEST//
	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			torn_items += chest_clothes

	//ARMS & HANDS//
	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit
		if(arm_clothes)
			torn_items |= arm_clothes

	//LEGS & FEET//
	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
			leg_clothes = wear_suit
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)
