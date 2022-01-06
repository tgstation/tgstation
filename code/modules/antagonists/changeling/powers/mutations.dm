/*
	Changeling Mutations! ~By Miauw (ALL OF IT :V)
	Contains:
		Arm Blade
		Space Suit
		Shield
		Armor
		Tentacles
*/


//Parent to shields and blades because muh copypasted code.
/datum/action/changeling/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	dna_cost = -1

	var/silent = FALSE
	var/weapon_type
	var/weapon_name_simple

/datum/action/changeling/weapon/try_to_sting(mob/user, mob/target)
	for(var/obj/item/I in user.held_items)
		if(check_weapon(user, I))
			return
	..(user, target)

/datum/action/changeling/weapon/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.temporarilyRemoveItemFromInventory(hand_item, TRUE) //DROPDEL will delete the item
		if(!silent)
			playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
			user.visible_message(span_warning("With a sickening crunch, [user] reforms [user.p_their()] [weapon_name_simple] into an arm!"), span_notice("We assimilate the [weapon_name_simple] back into our body."), "<span class='italics>You hear organic matter ripping and tearing!</span>")
		user.update_inv_hands()
		return 1

/datum/action/changeling/weapon/sting_action(mob/living/user)
	var/obj/item/held = user.get_active_held_item()
	if(held && !user.dropItemToGround(held))
		to_chat(user, span_warning("[held] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!"))
		return
	..()
	var/limb_regen = 0
	if(user.active_hand_index % 2 == 0) //we regen the arm before changing it into the weapon
		limb_regen = user.regenerate_limb(BODY_ZONE_R_ARM, 1)
	else
		limb_regen = user.regenerate_limb(BODY_ZONE_L_ARM, 1)
	if(limb_regen)
		user.visible_message(span_warning("[user]'s missing arm reforms, making a loud, grotesque sound!"), span_userdanger("Your arm regrows, making a loud, crunchy sound and giving you great pain!"), span_hear("You hear organic matter ripping and tearing!"))
		user.emote("scream")
	var/obj/item/W = new weapon_type(user, silent)
	user.put_in_hands(W)
	if(!silent)
		playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
	return W

/datum/action/changeling/weapon/Remove(mob/user)
	for(var/obj/item/I in user.held_items)
		check_weapon(user, I)
	..()


//Parent to space suits and armor.
/datum/action/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	dna_cost = -1

	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = 0

/datum/action/changeling/suit/try_to_sting(mob/user, mob/target)
	if(check_suit(user))
		return
	var/mob/living/carbon/human/H = user
	..(H, target)

//checks if we already have an organic suit and casts it off.
/datum/action/changeling/suit/proc/check_suit(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!ishuman(user) || !changeling)
		return 1
	var/mob/living/carbon/human/H = user
	if(istype(H.wear_suit, suit_type) || istype(H.head, helmet_type))
		H.visible_message(span_warning("[H] casts off [H.p_their()] [suit_name_simple]!"), span_warning("We cast off our [suit_name_simple]."), span_hear("You hear the organic matter ripping and tearing!"))
		H.temporarilyRemoveItemFromInventory(H.head, TRUE) //The qdel on dropped() takes care of it
		H.temporarilyRemoveItemFromInventory(H.wear_suit, TRUE)
		H.update_inv_wear_suit()
		H.update_inv_head()
		H.update_hair()

		if(blood_on_castoff)
			H.add_splatter_floor()
			playsound(H.loc, 'sound/effects/splat.ogg', 50, TRUE) //So real sounds

		changeling.chem_recharge_slowdown -= recharge_slowdown
		return 1

/datum/action/changeling/suit/Remove(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	check_suit(H)
	..()

/datum/action/changeling/suit/sting_action(mob/living/carbon/human/user)
	if(!user.canUnEquip(user.wear_suit))
		to_chat(user, span_warning("\the [user.wear_suit] is stuck to your body, you cannot grow a [suit_name_simple] over it!"))
		return
	if(!user.canUnEquip(user.head))
		to_chat(user, span_warning("\the [user.head] is stuck on your head, you cannot grow a [helmet_name_simple] over it!"))
		return
	..()
	user.dropItemToGround(user.head)
	user.dropItemToGround(user.wear_suit)

	user.equip_to_slot_if_possible(new suit_type(user), ITEM_SLOT_OCLOTHING, 1, 1, 1)
	user.equip_to_slot_if_possible(new helmet_type(user), ITEM_SLOT_HEAD, 1, 1, 1)

	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chem_recharge_slowdown += recharge_slowdown
	return TRUE


//fancy headers yo
/***************************************\
|***************ARM BLADE***************|
\***************************************/
/datum/action/changeling/weapon/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade. Costs 20 chemicals."
	helptext = "We may retract our armblade in the same manner as we form it. Cannot be used while in lesser form."
	button_icon_state = "armblade"
	chemical_cost = 20
	dna_cost = 2
	req_human = TRUE
	weapon_type = /obj/item/melee/arm_blade
	weapon_name_simple = "blade"

/obj/item/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	wound_bonus = -20
	bare_wound_bonus = 20
	var/can_drop = FALSE
	var/fake = FALSE

/obj/item/melee/arm_blade/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc) && !silent)
		loc.visible_message(span_warning("A grotesque blade forms around [loc.name]\'s arm!"), span_warning("Our arm twists and mutates, transforming it into a deadly blade."), span_hear("You hear organic matter ripping and tearing!"))
	if(synthetic)
		can_drop = TRUE
	AddComponent(/datum/component/butchering, 60, 80)

/obj/item/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower()) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message, power requirement is so this doesn't stop unpowered doors from being pried open if you have access
			return
		if(A.locked)
			to_chat(user, span_warning("The airlock's bolts prevent it from being forced!"))
			return

		if(A.hasPower())
			user.visible_message(span_warning("[user] jams [src] into the airlock and starts prying it open!"), span_warning("We start forcing the [A] open."), \
			span_hear("You hear a metal screeching sound."))
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 100, target = A))
				return
		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message(span_warning("[user] forces the airlock to open with [user.p_their()] [src]!"), span_warning("We force the [A] to open."), \
		span_hear("You hear a metal screeching sound."))
		A.open(2)

/obj/item/melee/arm_blade/dropped(mob/user)
	..()
	if(can_drop)
		new /obj/item/melee/synthetic_arm_blade(get_turf(user))

/***************************************\
|***********COMBAT TENTACLES*************|
\***************************************/

/datum/action/changeling/weapon/tentacle
	name = "Tentacle"
	desc = "We ready a tentacle to grab items or victims with. Costs 10 chemicals."
	helptext = "We can use it once to retrieve a distant item. If used on living creatures, the effect depends on the intent: \
	In our neutral stance will simply drag them closer, Shove will grab whatever they're holding instead of them, in our Combat stance will put the \
	victim in our hold after catching it, and will pull it in and stab it if we're also holding a sharp weapon. Cannot be used while in lesser form."
	button_icon_state = "tentacle"
	chemical_cost = 10
	dna_cost = 2
	req_human = TRUE
	weapon_type = /obj/item/gun/magic/tentacle
	weapon_name_simple = "tentacle"
	silent = TRUE

/obj/item/gun/magic/tentacle
	name = "tentacle"
	desc = "A fleshy tentacle that can stretch out and grab things or people."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL | NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	pinless = TRUE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	fire_delay = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0

/obj/item/gun/magic/tentacle/Initialize(mapload, silent)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		if(!silent)
			loc.visible_message(span_warning("[loc.name]\'s arm starts stretching inhumanly!"), span_warning("Our arm twists and mutates, transforming it into a tentacle."), span_hear("You hear organic matter ripping and tearing!"))
		else
			to_chat(loc, span_notice("You prepare to extend a tentacle."))


/obj/item/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("The [name] is not ready yet."))

/obj/item/gun/magic/tentacle/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/obj/projectile/tentacle/tentacle_shot = chambered.loaded_projectile //Gets the actual projectile we will fire
	tentacle_shot.fire_modifiers = params2list(params)
	. = ..()
	if(charges == 0)
		qdel(src)

/obj/item/gun/magic/tentacle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] coils [src] tightly around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (OXYLOSS)


/obj/item/ammo_casing/magic/tentacle
	name = "tentacle"
	desc = "A tentacle."
	projectile_type = /obj/projectile/tentacle
	caliber = CALIBER_TENTACLE
	icon_state = "tentacle_end"
	firing_effect_type = null
	var/obj/item/gun/magic/tentacle/gun //the item that shot it

/obj/item/ammo_casing/magic/tentacle/Initialize(mapload)
	gun = loc
	. = ..()

/obj/item/ammo_casing/magic/tentacle/Destroy()
	gun = null
	return ..()

/obj/projectile/tentacle
	name = "tentacle"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	var/chain
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it
	///Click params that were used to fire the tentacle shot
	var/list/fire_modifiers

/obj/projectile/tentacle/Initialize(mapload)
	source = loc
	. = ..()

/obj/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle")
	..()

/obj/projectile/tentacle/proc/reset_throw(mob/living/carbon/human/H)
	if(H.throw_mode)
		H.throw_mode_off(THROW_MODE_TOGGLE) //Don't annoy the changeling if he doesn't catch the item

/obj/projectile/tentacle/proc/tentacle_grab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		if(H.get_active_held_item() && !H.get_inactive_held_item())
			H.swap_hand()
		if(H.get_active_held_item())
			return
		C.grabbedby(H)
		C.grippedby(H, instant = TRUE) //instant aggro grab

/obj/projectile/tentacle/proc/tentacle_stab(mob/living/carbon/human/H, mob/living/carbon/C)
	if(H.Adjacent(C))
		for(var/obj/item/I in H.held_items)
			if(I.get_sharpness())
				C.visible_message(span_danger("[H] impales [C] with [H.p_their()] [I.name]!"), span_userdanger("[H] impales you with [H.p_their()] [I.name]!"))
				C.apply_damage(I.force, BRUTE, BODY_ZONE_CHEST)
				H.do_item_attack_animation(C, used_item = I)
				H.add_mob_blood(C)
				playsound(get_turf(H),I.hitsound,75,TRUE)
				return

/obj/projectile/tentacle/on_hit(atom/target, blocked = FALSE)
	var/mob/living/carbon/human/H = firer
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(isitem(target))
		var/obj/item/I = target
		if(!I.anchored)
			to_chat(firer, span_notice("You pull [I] towards yourself."))
			H.throw_mode_on(THROW_MODE_TOGGLE)
			I.throw_at(H, 10, 2)
			. = BULLET_ACT_HIT

	else if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)//avoid double hits
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				var/firer_combat_mode = TRUE
				var/mob/living/living_shooter = firer
				if(istype(living_shooter))
					firer_combat_mode = living_shooter.combat_mode
				if(fire_modifiers && fire_modifiers["right"])
					var/obj/item/I = C.get_active_held_item()
					if(I)
						if(C.dropItemToGround(I))
							C.visible_message(span_danger("[I] is yanked off [C]'s hand by [src]!"),span_userdanger("A tentacle pulls [I] away from you!"))
							on_hit(I) //grab the item as if you had hit it directly with the tentacle
							return BULLET_ACT_HIT
						else
							to_chat(firer, span_warning("You can't seem to pry [I] off [C]'s hands!"))
							return BULLET_ACT_BLOCK
					else
						to_chat(firer, span_danger("[C] has nothing in hand to disarm!"))
						return BULLET_ACT_HIT
				if(firer_combat_mode)
					C.visible_message(span_danger("[L] is thrown towards [H] by a tentacle!"),span_userdanger("A tentacle grabs you and throws you towards [H]!"))
					C.throw_at(get_step_towards(H,C), 8, 2, H, TRUE, TRUE, callback=CALLBACK(src, .proc/tentacle_stab, H, C))
					return BULLET_ACT_HIT
				else
					C.visible_message(span_danger("[L] is grabbed by [H]'s tentacle!"),span_userdanger("A tentacle grabs you and pulls you towards [H]!"))
					C.throw_at(get_step_towards(H,C), 8, 2, H, TRUE, TRUE, callback=CALLBACK(src, .proc/tentacle_grab, H, C))
					return BULLET_ACT_HIT

			else
				L.visible_message(span_danger("[L] is pulled by [H]'s tentacle!"),span_userdanger("A tentacle grabs you and pulls you towards [H]!"))
				L.throw_at(get_step_towards(H,L), 8, 2)
				. = BULLET_ACT_HIT

/obj/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()


/***************************************\
|****************SHIELD*****************|
\***************************************/
/datum/action/changeling/weapon/shield
	name = "Organic Shield"
	desc = "We reform one of our arms into a hard shield. Costs 20 chemicals."
	helptext = "Organic tissue cannot resist damage forever; the shield will break after it is hit too much. The more genomes we absorb, the stronger it is. Cannot be used while in lesser form."
	button_icon_state = "organic_shield"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE

	weapon_type = /obj/item/shield/changeling
	weapon_name_simple = "shield"

/datum/action/changeling/weapon/shield/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling) //So we can read the absorbedcount.
	if(!changeling)
		return

	var/obj/item/shield/changeling/S = ..(user)
	S.remaining_uses = round(changeling.absorbedcount * 3)
	return TRUE

/obj/item/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	item_flags = ABSTRACT | DROPDEL
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "ling_shield"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	block_chance = 50

	var/remaining_uses //Set by the changeling ability.

/obj/item/shield/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!"), span_warning("We inflate our hand into a strong shield."), span_hear("You hear organic matter ripping and tearing!"))

/obj/item/shield/changeling/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.visible_message(span_warning("With a sickening crunch, [H] reforms [H.p_their()] shield into an arm!"), span_notice("We assimilate our shield into our body"), "<span class='italics>You hear organic matter ripping and tearing!</span>")
		qdel(src)
		return 0
	else
		remaining_uses--
		return ..()


/***************************************\
|*********SPACE SUIT + HELMET***********|
\***************************************/
/datum/action/changeling/suit/organic_space_suit
	name = "Organic Space Suit"
	desc = "We grow an organic suit to protect ourselves from space exposure. Costs 20 chemicals."
	helptext = "We must constantly repair our form to make it space-proof, reducing chemical production while we are protected. Cannot be used in lesser form."
	button_icon_state = "organic_suit"
	chemical_cost = 20
	dna_cost = 2
	req_human = TRUE

	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "flesh shell"
	helmet_name_simple = "space helmet"
	recharge_slowdown = 0.25
	blood_on_castoff = 1

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	item_flags = DROPDEL
	clothing_flags = STOPSPRESSUREDAMAGE //Not THICKMATERIAL because it's organic tissue, so if somebody tries to inject something into it, it still ends up in your blood. (also balance but muh fluff)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/oxygen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 90, ACID = 90) //No armor at all.
	actions_types = list()
	cell = null
	show_hud = FALSE

/obj/item/clothing/suit/space/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh rapidly inflates, forming a bloated mass around [loc.p_their()] body!"), span_warning("We inflate our flesh, creating a spaceproof suit!"), span_hear("You hear organic matter ripping and tearing!"))
	START_PROCESSING(SSobj, src)

// seal the cell door
/obj/item/clothing/suit/space/changeling/toggle_spacesuit_cell(mob/user)
	return

/obj/item/clothing/suit/space/changeling/process(delta_time)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent(/datum/reagent/medicine/salbutamol, REAGENTS_METABOLISM * (delta_time / SSMOBS_DT))
		H.adjust_bodytemperature(temperature_setting - H.bodytemperature) // force changelings to normal temp step mode played badly

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	item_flags = DROPDEL
	clothing_flags = STOPSPRESSUREDAMAGE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 90, ACID = 90)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/helmet/space/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

/***************************************\
|*****************ARMOR*****************|
\***************************************/
/datum/action/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage. Costs 20 chemicals."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor is strong against brute force, but does not provide much protection from lasers. Cannot be used in lesser form."
	button_icon_state = "chitinous_armor"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE
	recharge_slowdown = 0.125

	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "armor"
	helmet_name_simple = "helmet"

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin."
	icon_state = "lingarmor"
	item_flags = DROPDEL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 10, BIO = 4, FIRE = 90, ACID = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0

/obj/item/clothing/suit/armor/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!"), span_warning("We harden our flesh, creating a suit of armor!"), span_hear("You hear organic matter ripping and tearing!"))

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	item_flags = DROPDEL
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 10, BIO = 4, FIRE = 90, ACID = 90)
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT

/obj/item/clothing/head/helmet/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
