/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bp = def_zone
			if(bp)
				return check_armor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
		if(affecting)
			return check_armor(affecting, type)
		//If a specific bodypart is targeted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += check_armor(BP, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/check_armor(obj/item/bodypart/def_zone, damage_type)
	if(!damage_type)
		return 0
	var/protection = 100
	var/list/covering_clothing = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/obj/item/clothing/clothing_item in covering_clothing)
		if(clothing_item.body_parts_covered & def_zone.body_part)
			protection *= (100 - min(clothing_item.get_armor_rating(damage_type), 100)) * 0.01
	protection *= (100 - min(physiology.armor.get_rating(damage_type), 100)) * 0.01
	return 100 - protection

///Get all the clothing on a specific body part
/mob/living/carbon/human/proc/get_clothing_on_part(obj/item/bodypart/def_zone)
	var/list/covering_part = list()
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				covering_part += C
	return covering_part

/mob/living/carbon/human/bullet_act(obj/projectile/bullet, def_zone, piercing_hit = FALSE)
	if(bullet.firer == src && bullet.original == src) //can't block or reflect when shooting yourself
		return ..()

	if(bullet.reflectable)
		if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
			visible_message(
				span_danger("\The [bullet] gets reflected by [src]!"),
				span_userdanger("\The [bullet] gets reflected by [src]!"),
			)
			// Finds and plays the block_sound of item which reflected
			for(var/obj/item/held_item in held_items)
				if(held_item.IsReflect(def_zone))
					playsound(src, held_item.block_sound, BLOCK_SOUND_VOLUME, TRUE)
			// Find a turf near or on the original location to bounce to
			if(!isturf(loc)) //Open canopy mech (ripley) check. if we're inside something and still got hit
				return loc.projectile_hit(bullet, def_zone, piercing_hit)
			bullet.reflect(src)
			return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

	if(check_block(bullet, bullet.damage, "\the [bullet]", PROJECTILE_ATTACK, bullet.armour_penetration, bullet.damage_type))
		bullet.on_hit(src, 100, def_zone, piercing_hit)
		return BULLET_ACT_HIT

	return ..()

///Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance of the object
/mob/living/carbon/human/proc/check_reflect(def_zone)
	if(wear_suit)
		if(wear_suit.IsReflect(def_zone))
			return TRUE
	if(head)
		if(head.IsReflect(def_zone))
			return TRUE
	for(var/obj/item/I in held_items)
		if(I.IsReflect(def_zone))
			return TRUE
	return FALSE

/mob/living/carbon/human/check_block(atom/hit_by, damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0, damage_type = BRUTE)
	. = ..()
	if(. == SUCCESSFUL_BLOCK)
		return SUCCESSFUL_BLOCK

	var/block_chance_modifier = round(damage / -3)
	for(var/obj/item/worn_thing in get_equipped_items(INCLUDE_HELD))
		// Things that are supposed to be worn, being held = cannot block
		if(isclothing(worn_thing))
			if(worn_thing in held_items)
				continue
		// Things that are supposed to be held, being worn = cannot block
		else if(!(worn_thing in held_items))
			continue

		var/final_block_chance = worn_thing.block_chance - (clamp((armour_penetration - worn_thing.armour_penetration) / 2, 0, 100)) + block_chance_modifier
		if(worn_thing.hit_reaction(src, hit_by, attack_text, final_block_chance, damage, attack_type, damage_type))
			return SUCCESSFUL_BLOCK

	return FAILED_BLOCK

/mob/living/carbon/human/grippedby(mob/living/carbon/user, instant = FALSE)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	..()

/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	var/hulk_verb = pick("smash","pummel")
	if(check_block(user, 15, "the [hulk_verb]ing", attack_type = UNARMED_ATTACK))
		return
	var/obj/item/bodypart/arm/active_arm = user.get_active_hand()
	playsound(loc, active_arm.unarmed_attack_sound, 25, TRUE, -1)
	visible_message(span_danger("[user] [hulk_verb]ed [src]!"), \
					span_userdanger("[user] [hulk_verb]ed [src]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
	to_chat(user, span_danger("You [hulk_verb] [src]!"))
	apply_damage(15, BRUTE, wound_bonus=10)

/mob/living/carbon/human/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src, null, modifiers)

/mob/living/carbon/human/proc/disarm_precollide(datum/source, mob/living/shover, mob/living/target, obj/item/weapon)
	SIGNAL_HANDLER
	return COMSIG_LIVING_ACT_SOLID

/mob/living/carbon/human/proc/disarm_collision(datum/source, mob/living/shover, mob/living/target, shove_flags, obj/item/weapon)
	SIGNAL_HANDLER
	if(src == target || LAZYFIND(target.buckled_mobs, src) || !iscarbon(target))
		return
	if(!(shove_flags & SHOVE_KNOCKDOWN_BLOCKED))
		target.Knockdown(SHOVE_KNOCKDOWN_HUMAN, daze_amount = 3 SECONDS)
	if(!HAS_TRAIT(src, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED))
		Knockdown(SHOVE_KNOCKDOWN_COLLATERAL, daze_amount = 3 SECONDS)
	target.visible_message(span_danger("[shover] shoves [target.name] into [name]!"),
		span_userdanger("You're shoved into [name] by [shover]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_danger("You shove [target.name] into [name]!"))
	log_combat(shover, target, "shoved", addition = "into [name][weapon ? " with [weapon]" : ""]")
	return COMSIG_LIVING_SHOVE_HANDLED

/mob/living/carbon/human/attack_paw(mob/living/carbon/human/user, list/modifiers)
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(dam_zone))

	if(LAZYACCESS(modifiers, RIGHT_CLICK)) //Always drop item in hand, if no item, get stunned instead.
		var/obj/item/I = get_active_held_item()
		if(I && !(I.item_flags & ABSTRACT) && dropItemToGround(I))
			playsound(loc, 'sound/items/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] disarmed [src]!"), \
							span_userdanger("[user] disarmed you!"), span_hear("You hear aggressive shuffling!"), null, user)
			to_chat(user, span_danger("You disarm [src]!"))
		else if(!user.client || prob(5)) // only natural monkeys get to stun reliably, (they only do it occasionaly)
			playsound(loc, 'sound/items/weapons/pierce.ogg', 25, TRUE, -1)
			if (src.IsKnockdown() && !src.IsParalyzed())
				Paralyze(40)
				log_combat(user, src, "pinned")
				visible_message(span_danger("[user] pins [src] down!"), \
								span_userdanger("[user] pins you down!"), span_hear("You hear shuffling and a muffled groan!"), null, user)
				to_chat(user, span_danger("You pin [src] down!"))
			else
				Knockdown(30)
				log_combat(user, src, "tackled")
				visible_message(span_danger("[user] tackles [src] down!"), \
								span_userdanger("[user] tackles you down!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), null, user)
				to_chat(user, span_danger("You tackle [src] down!"))
		return TRUE

	if(!user.combat_mode)
		..() //shaking
		return FALSE

	if(user.limb_destroyer)
		dismembering_strike(user, affecting.body_zone)

	if(try_inject(user, affecting, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/obj/item/bodypart/head/monkey_mouth = user.get_bodypart(BODY_ZONE_HEAD)
			var/damage = HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER) ? monkey_mouth.unarmed_damage_high : rand(monkey_mouth.unarmed_damage_low, monkey_mouth.unarmed_damage_high)
			if(!damage)
				return FALSE
			if(check_block(user, damage, "\the [user]", attack_type = UNARMED_ATTACK))
				return FALSE
			apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, MELEE))
		return TRUE

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(!.)
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK)) //Always drop item in hand if there is one. If there's no item, shove the target. If the target is incapacitated, slam them into the ground to stun them.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/items/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] disarms [src]!"), \
							span_userdanger("[user] disarms you!"), span_hear("You hear aggressive shuffling!"), null, user)
			to_chat(user, span_danger("You disarm [src]!"))
		else if(!HAS_TRAIT(src, TRAIT_INCAPACITATED))
			playsound(loc, 'sound/items/weapons/pierce.ogg', 25, TRUE, -1)
			var/shovetarget = get_edge_target_turf(user, get_dir(user, get_step_away(src, user)))
			adjustStaminaLoss(35)
			throw_at(shovetarget, 4, 2, user, force = MOVE_FORCE_OVERPOWERING)
			log_combat(user, src, "shoved")
			visible_message(span_danger("[user] tackles [src] down!"), \
							span_userdanger("[user] shoves you with great force!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), null, user)
			to_chat(user, span_danger("You shove [src] with great force!"))
		else
			Paralyze(5 SECONDS)
			playsound(loc, 'sound/items/weapons/punch3.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] slams [src] into the floor!"), \
							span_userdanger("[user] slams you into the ground!"), span_hear("You hear something slam loudly onto the floor!"), null, user)
			to_chat(user, span_danger("You slam [src] into the floor beneath you!"))
			log_combat(user, src, "slammed into the ground")
		return TRUE

	if(user.combat_mode)
		if (w_uniform)
			w_uniform.add_fingerprint(user)
		var/damage = prob(90) ? rand(user.melee_damage_lower, user.melee_damage_upper) : 0
		if(!damage)
			playsound(loc, 'sound/items/weapons/slashmiss.ogg', 50, TRUE, -1)
			visible_message(span_danger("[user] lunges at [src]!"), \
							span_userdanger("[user] lunges at you!"), span_hear("You hear a swoosh!"), null, user)
			to_chat(user, span_danger("You lunge at [src]!"))
			return FALSE
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(user.zone_selected))
		var/armor_block = run_armor_check(affecting, MELEE,"","",10)

		playsound(loc, 'sound/items/weapons/slice.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user] slashes at [src]!"), \
						span_userdanger("[user] slashes at you!"), span_hear("You hear a sickening sound of a slice!"), null, user)
		to_chat(user, span_danger("You slash at [src]!"))
		if(dismembering_strike(user, user.zone_selected)) //Dismemberment successful
			apply_damage(damage, BRUTE, affecting, armor_block)
		log_combat(user, src, "attacked")
		return TRUE

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/worm, list/modifiers)
	. = ..()
	if(!.)
		return //successful larva bite.
	var/damage = rand(worm.melee_damage_lower, worm.melee_damage_upper)
	if(!damage)
		return
	if(check_block(worm, damage, "\the [worm]", attack_type = UNARMED_ATTACK))
		return FALSE
	if(stat != DEAD)
		worm.amount_grown = min(worm.amount_grown + damage, worm.max_grown)
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(worm.zone_selected))
		var/armor_block = run_armor_check(affecting, MELEE)
		apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/ex_act(severity, target, origin)
	if(HAS_TRAIT(src, TRAIT_BOMBIMMUNE))
		return FALSE

	. = ..()
	if (!. || !severity || QDELETED(src))
		return FALSE
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = getarmor(null, BOMB)

//200 max knockdown for EXPLODE_HEAVY
//160 max knockdown for EXPLODE_LIGHT

	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD) //gibs the mob if their bomb armor is lower than EXPLODE_GIB_THRESHOLD
				for(var/thing in contents)
					switch(severity)
						if(EXPLODE_DEVASTATE)
							SSexplosions.high_mov_atom += thing
						if(EXPLODE_HEAVY)
							SSexplosions.med_mov_atom += thing
						if(EXPLODE_LIGHT)
							SSexplosions.low_mov_atom += thing
				investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
				gib(DROP_ALL_REMAINS)
				return TRUE
			else
				brute_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, BOMB)

		if (EXPLODE_HEAVY)
			brute_loss = 60
			burn_loss = 60
			if(bomb_armor)
				brute_loss = 30*(2 - round(bomb_armor*0.01, 0.05))
				burn_loss = brute_loss //damage gets reduced from 120 to up to 60 combined brute+burn
			damage_clothes(200 - bomb_armor, BRUTE, BOMB)
			if (ears && !HAS_TRAIT_FROM_ONLY(src, TRAIT_DEAF, EAR_DAMAGE))
				ears.adjustEarDamage(30, 120)
			Unconscious(20) //short amount of time for follow up attacks against elusive enemies like wizards
			Knockdown(200 - (bomb_armor * 1.6)) //between ~4 and ~20 seconds of knockdown depending on bomb armor

		if(EXPLODE_LIGHT)
			brute_loss = 30
			if(bomb_armor)
				brute_loss = 15*(2 - round(bomb_armor*0.01, 0.05))
			damage_clothes(max(50 - bomb_armor, 0), BRUTE, BOMB)
			if (ears && !HAS_TRAIT_FROM_ONLY(src, TRAIT_DEAF, EAR_DAMAGE))
				ears.adjustEarDamage(15,60)
			Knockdown(160 - (bomb_armor * 1.6)) //100 bomb armor will prevent knockdown altogether

	take_overall_damage(brute_loss,burn_loss)

	//attempt to dismember bodyparts
	if(severity >= EXPLODE_HEAVY || !bomb_armor)
		var/max_limb_loss = 0
		var/probability = 0
		switch(severity)
			if(EXPLODE_NONE)
				max_limb_loss = 1
				probability = 20
			if(EXPLODE_LIGHT)
				max_limb_loss = 2
				probability = 30
			if(EXPLODE_HEAVY)
				max_limb_loss = 3
				probability = 40
			if(EXPLODE_DEVASTATE)
				max_limb_loss = 4
				probability = 50
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(probability) && !prob(getarmor(BP, BOMB)) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.receive_damage(INFINITY, wound_bonus = CANT_WOUND) //Capped by proc
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break

	return TRUE


/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message(span_userdanger("The blob attacks you!"))
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, MELEE))


///Calculates the siemens coeff based on clothing and species, can also restart hearts.
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 20 SECONDS, stutter_time = 4 SECONDS, stun_duration = 4 SECONDS)
	//Calculates the siemens coeff based on clothing. Completely ignores the arguments
	if(flags & SHOCK_TESLA) //I hate this entire block. This gets the siemens_coeff for tesla shocks
		if(gloves && gloves.siemens_coefficient <= 0)
			siemens_coeff -= 0.5
		if(wear_suit)
			if(wear_suit.siemens_coefficient == -1)
				siemens_coeff -= 1
			else if(wear_suit.siemens_coefficient <= 0)
				siemens_coeff -= 0.95
		siemens_coeff = max(siemens_coeff, 0)
	if(flags & SHOCK_NOGLOVES) //This gets the siemens_coeff for all non tesla shocks
		if(wear_suit)
			siemens_coeff *= wear_suit.siemens_coefficient
	else if(gloves)
		siemens_coeff *= gloves.siemens_coefficient

	siemens_coeff *= physiology.siemens_coeff
	siemens_coeff *= dna.species.siemens_coeff
	. = ..()
	//Don't go further if the shock was blocked/too weak.
	if(!.)
		return
	if(!(flags & SHOCK_ILLUSION))
		if(shock_damage * siemens_coeff >= 5)
			force_say()
		//Note we both check that the user is in cardiac arrest and can actually heartattack
		//If they can't, they're missing their heart and this would runtime
		if(undergoing_cardiac_arrest() && can_heartattack() && (shock_damage * siemens_coeff >= 1) && prob(25))
			var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
			if(heart.Restart() && stat == CONSCIOUS)
				to_chat(src, span_notice("You feel your heart beating again!"))
	if (!(flags & SHOCK_NO_HUMAN_ANIM))
		electrocution_animation(4 SECONDS)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
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
				update_worn_glasses()
				update_worn_mask()
				update_worn_neck()
				update_worn_head()
			else
				to_chat(src, span_notice("Your [head_clothes.name] protects your head and face from the acid!"))
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
				update_worn_undersuit()
				update_worn_oversuit()
			else
				to_chat(src, span_notice("Your [chest_clothes.name] protects your body from the acid!"))
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
				update_worn_gloves()
				update_worn_undersuit()
				update_worn_oversuit()
			else
				to_chat(src, span_notice("Your [arm_clothes.name] protects your arms and hands from the acid!"))
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
				update_worn_shoes()
				update_worn_undersuit()
				update_worn_oversuit()
			else
				to_chat(src, span_notice("Your [leg_clothes.name] protects your legs and feet from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/bodypart/affecting in damaged)
		var/damage_mod = 1
		if(affecting.body_zone == BODY_ZONE_HEAD && prob(min(acidpwr * acid_volume * 0.1, 90))) //Applies disfigurement
			damage_mod = 2
			emote("scream")
			set_facial_hairstyle("Shaved", update = FALSE)
			set_hairstyle("Bald") //This calls update_body_parts()
			ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

		apply_damage(acidity * damage_mod, BRUTE, affecting)
		apply_damage(acidity * damage_mod * 2, BURN, affecting)

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/inventory_item in inventory_items_to_kill)
		inventory_item.acid_act(acidpwr, acid_volume)
	return TRUE

///Overrides the point value that the mob is worth
/mob/living/carbon/human/singularity_act()
	. = 20
	switch(mind?.assigned_role.type)
		if(/datum/job/chief_engineer, /datum/job/station_engineer)
			. = 100
		if(/datum/job/clown)
			. = rand(-1000, 1000)
	..() //Called afterwards because getting the mind after getting gibbed is sketchy

/mob/living/carbon/human/help_shake_act(mob/living/carbon/helper, force_friendly)
	if(!istype(helper))
		return

	if(wear_suit)
		wear_suit.add_fingerprint(helper)
	else if(w_uniform)
		w_uniform.add_fingerprint(helper)

	return ..()

/mob/living/carbon/human/check_self_for_injuries()
	if(stat >= UNCONSCIOUS)
		return
	var/list/combined_msg = list()

	visible_message(span_notice("[src] examines [p_them()]self."))

	combined_msg += span_notice("<b>You check yourself for injuries.</b>")

	var/list/missing = get_all_limbs()

	for(var/obj/item/bodypart/body_part as anything in bodyparts)
		missing -= body_part.body_zone
		if(body_part.bodypart_flags & BODYPART_PSEUDOPART) //don't show injury text for fake bodyparts; ie chainsaw arms or synthetic armblades
			continue

		var/bodypart_report = body_part.check_for_injuries(src)
		if(bodypart_report)
			combined_msg += "[span_notice("&rdsh;")] [bodypart_report]"

	for(var/t in missing)
		combined_msg += span_boldannounce("&rdsh; Your [parse_zone(t)] is missing!")

	var/tox = getToxLoss() + (disgust / 5) + (HAS_TRAIT(src, TRAIT_SELF_AWARE) ? 0 : (rand(-3, 0) * 5))
	switch(tox)
		if(10 to 20)
			combined_msg += span_danger("You feel sick.")
		if(20 to 40)
			combined_msg += span_danger("You feel nauseated.")
		if(40 to INFINITY)
			combined_msg += span_danger("You feel very unwell!")

	var/oxy = getOxyLoss() + (losebreath * 4) + (blood_volume < BLOOD_VOLUME_NORMAL ? ((BLOOD_VOLUME_NORMAL - blood_volume) * 0.1) : 0) + (HAS_TRAIT(src, TRAIT_SELF_AWARE) ? 0 : (rand(-3, 0) * 5))
	switch(oxy)
		if(10 to 20)
			combined_msg += span_danger("You feel lightheaded.")
		if(20 to 40)
			combined_msg += losebreath ? span_danger("You're choking!") : span_danger("Your thinking is clouded and distant.")
		if(40 to INFINITY)
			combined_msg += span_danger("You feel like you're about to pass out!")

	if(getStaminaLoss())
		if(getStaminaLoss() > 30)
			combined_msg += span_info("You're completely exhausted.")
		else
			combined_msg += span_info("You feel fatigued.")

	to_chat(src, boxed_message(combined_msg.Join("<br>")))

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

/**
 * Used by fire code to damage worn items.
 *
 * Arguments:
 * - seconds_per_tick
 * - times_fired
 * - stacks: Current amount of firestacks
 *
 */

/mob/living/carbon/human/proc/burn_clothing(seconds_per_tick, stacks)
	var/list/burning_items = list()
	var/covered = check_covered_slots()
	//HEAD//

	if(glasses && !(covered & ITEM_SLOT_EYES))
		burning_items += glasses
	if(wear_mask && !(covered & ITEM_SLOT_MASK))
		burning_items += wear_mask
	if(wear_neck && !(covered & ITEM_SLOT_NECK))
		burning_items += wear_neck
	if(ears && !(covered & ITEM_SLOT_EARS))
		burning_items += ears
	if(head)
		burning_items += head

	//CHEST//
	if(w_uniform && !(covered & ITEM_SLOT_ICLOTHING))
		burning_items += w_uniform
	if(wear_suit)
		burning_items += wear_suit

	//ARMS & HANDS//
	var/obj/item/clothing/arm_clothes = null
	if(gloves && !(covered & ITEM_SLOT_GLOVES))
		arm_clothes = gloves
	else if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
		arm_clothes = wear_suit
	else if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
		arm_clothes = w_uniform
	if(arm_clothes)
		burning_items |= arm_clothes

	//LEGS & FEET//
	var/obj/item/clothing/leg_clothes = null
	if(shoes && !(covered & ITEM_SLOT_FEET))
		leg_clothes = shoes
	else if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
		leg_clothes = wear_suit
	else if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
		leg_clothes = w_uniform
	if(leg_clothes)
		burning_items |= leg_clothes

	if (!gloves || (!(gloves.resistance_flags & FIRE_PROOF) && (gloves.resistance_flags & FLAMMABLE)))
		for(var/obj/item/burnable_item in held_items)
			burning_items |= burnable_item

	for(var/obj/item/burning in burning_items)
		burning.fire_act((stacks * 25 * seconds_per_tick)) //damage taken is reduced to 2% of this value by fire_act()

/mob/living/carbon/human/on_fire_stack(seconds_per_tick, datum/status_effect/fire_handler/fire_stacks/fire_handler)
	SEND_SIGNAL(src, COMSIG_HUMAN_BURNING)
	burn_clothing(seconds_per_tick, fire_handler.stacks)
	var/no_protection = FALSE
	if (HAS_TRAIT(src, TRAIT_IGNORE_FIRE_PROTECTION))
		no_protection = TRUE
	fire_handler.harm_human(seconds_per_tick, no_protection)
