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
	dna_cost = CHANGELING_POWER_UNOBTAINABLE

	var/silent = FALSE
	var/weapon_type
	var/weapon_name_simple

/datum/action/changeling/weapon/Grant(mob/granted_to)
	. = ..()
	if (!owner || !req_human)
		return
	RegisterSignal(granted_to, COMSIG_HUMAN_MONKEYIZE, PROC_REF(became_monkey))

/datum/action/changeling/weapon/Remove(mob/remove_from)
	UnregisterSignal(remove_from, COMSIG_HUMAN_MONKEYIZE)
	unequip_held(remove_from)
	return ..()

/// Remove weapons if we become a monkey
/datum/action/changeling/weapon/proc/became_monkey(mob/source)
	SIGNAL_HANDLER
	unequip_held(source)

/// Removes weapon if it exists, returns true if we removed something
/datum/action/changeling/weapon/proc/unequip_held(mob/user)
	var/found_weapon = FALSE
	for(var/obj/item/held in user.held_items)
		found_weapon = check_weapon(user, held) || found_weapon
	return found_weapon

/datum/action/changeling/weapon/try_to_sting(mob/user, mob/target)
	if (unequip_held(user))
		return
	..(user, target)

/datum/action/changeling/weapon/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.temporarilyRemoveItemFromInventory(hand_item, TRUE) //DROPDEL will delete the item
		if(!silent)
			playsound(user, 'sound/effects/blob/blobattack.ogg', 30, TRUE)
			user.visible_message(span_warning("With a sickening crunch, [user] reforms [user.p_their()] [weapon_name_simple] into an arm!"), span_notice("We assimilate the [weapon_name_simple] back into our body."), span_italics("You hear organic matter ripping and tearing!"))
		user.update_held_items()
		return TRUE

/datum/action/changeling/weapon/sting_action(mob/living/carbon/user)
	var/obj/item/held = user.get_active_held_item()
	if(held && !user.dropItemToGround(held))
		user.balloon_alert(user, "hand occupied!")
		return
	if(!istype(user))
		user.balloon_alert(user, "wrong shape!")
		return
	..()
	var/limb_regen = 0
	if(HAS_TRAIT_FROM_ONLY(user, TRAIT_PARALYSIS_L_ARM, CHANGELING_TRAIT) || HAS_TRAIT_FROM_ONLY(user, TRAIT_PARALYSIS_R_ARM, CHANGELING_TRAIT))
		user.balloon_alert(user, "not enough muscle!") // no cheesing repuprosed glands
		return
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
		playsound(user, 'sound/effects/blob/blobattack.ogg', 30, TRUE)
	return W


//Parent to space suits and armor.
/datum/action/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	dna_cost = CHANGELING_POWER_UNOBTAINABLE

	var/helmet_type = null
	var/suit_type = null
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = 0

/datum/action/changeling/suit/Grant(mob/granted_to)
	. = ..()
	if (!owner || !req_human)
		return
	RegisterSignal(granted_to, COMSIG_HUMAN_MONKEYIZE, PROC_REF(became_monkey))

/datum/action/changeling/suit/Remove(mob/remove_from)
	UnregisterSignal(remove_from, COMSIG_HUMAN_MONKEYIZE)
	check_suit(remove_from)
	return ..()

/// Remove suit if we become a monkey
/datum/action/changeling/suit/proc/became_monkey()
	SIGNAL_HANDLER
	check_suit(owner)

/datum/action/changeling/suit/try_to_sting(mob/user, mob/target)
	if(check_suit(user))
		return
	var/mob/living/carbon/human/H = user
	..(H, target)

//checks if we already have an organic suit and casts it off.
/datum/action/changeling/suit/proc/check_suit(mob/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!ishuman(user) || !changeling)
		return 1
	var/mob/living/carbon/human/H = user

	if(istype(H.wear_suit, suit_type) || istype(H.head, helmet_type))
		var/name_to_use = (isnull(suit_type) ? helmet_name_simple : suit_name_simple)
		H.visible_message(span_warning("[H] casts off [H.p_their()] [name_to_use]!"), span_warning("We cast off our [name_to_use]."), span_hear("You hear the organic matter ripping and tearing!"))
		if(!isnull(helmet_type))
			H.temporarilyRemoveItemFromInventory(H.head, TRUE) //The qdel on dropped() takes care of it
		if(!isnull(suit_type))
			H.temporarilyRemoveItemFromInventory(H.wear_suit, TRUE)
		H.update_worn_oversuit()
		H.update_worn_head()
		H.update_body_parts()

		if(blood_on_castoff)
			H.add_splatter_floor()
			playsound(H.loc, 'sound/effects/splat.ogg', 50, TRUE) //So real sounds

		changeling.chem_recharge_slowdown -= recharge_slowdown
		return 1

/datum/action/changeling/suit/sting_action(mob/living/carbon/human/user)
	if(!user.canUnEquip(user.wear_suit) && !isnull(suit_type))
		user.balloon_alert(user, "body occupied!")
		return
	if(!user.canUnEquip(user.head) && !isnull(helmet_type))
		user.balloon_alert(user, "head occupied!")
		return
	..()
	if(!isnull(suit_type))
		user.dropItemToGround(user.wear_suit)
		user.equip_to_slot_if_possible(new suit_type(user), ITEM_SLOT_OCLOTHING, 1, 1, 1)
	if(!isnull(helmet_type))
		user.dropItemToGround(user.head)
		user.equip_to_slot_if_possible(new helmet_type(user), ITEM_SLOT_HEAD, 1, 1, 1)

	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
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
	icon = 'icons/obj/weapons/changeling_items.dmi'
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
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	wound_bonus = 10
	bare_wound_bonus = 10
	armour_penetration = 35
	var/can_drop = FALSE
	var/fake = FALSE

/obj/item/melee/arm_blade/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc) && !silent)
		loc.visible_message(span_warning("A grotesque blade forms around [loc.name]\'s arm!"), span_warning("Our arm twists and mutates, transforming it into a deadly blade."), span_hear("You hear organic matter ripping and tearing!"))
	if(synthetic)
		can_drop = TRUE
	AddComponent(/datum/component/butchering, \
	speed = 6 SECONDS, \
	effectiveness = 80, \
	)

/obj/item/melee/arm_blade/afterattack(atom/target, mob/user, click_parameters)
	if(istype(target, /obj/structure/table))
		var/obj/smash = target
		smash.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/computer))
		target.attack_alien(user) //muh copypasta

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/opening = target

		if((!opening.requiresID() || opening.allowed(user)) && opening.hasPower()) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message, power requirement is so this doesn't stop unpowered doors from being pried open if you have access
			return
		if(opening.locked)
			opening.balloon_alert(user, "bolted!")
			return

		if(opening.hasPower())
			user.visible_message(span_warning("[user] jams [src] into the airlock and starts prying it open!"), span_warning("We start forcing the [opening] open."), \
			span_hear("You hear a metal screeching sound."))
			playsound(opening, 'sound/machines/airlock/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 10 SECONDS, target = opening))
				return
		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message(span_warning("[user] forces the airlock to open with [user.p_their()] [src]!"), span_warning("We force the [opening] to open."), \
		span_hear("You hear a metal screeching sound."))
		opening.open(BYPASS_DOOR_CHECKS)

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
	helptext = "We can use it once to retrieve a distant item. If used on living creatures, the effect depends on our combat mode: \
	In our neutral stance, we will simply drag them closer; if we try to shove, we will grab whatever they're holding in their active hand instead of them; \
	in our combat stance, we will put the victim in our hold after catching them, and we will pull them in and stab them if we're also holding a sharp weapon. \
	Cannot be used while in lesser form."
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
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL | NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	antimagic_flags = NONE
	pinless = TRUE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	fire_delay = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	can_hold_up = FALSE

/obj/item/gun/magic/tentacle/Initialize(mapload, silent)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		if(!silent)
			loc.visible_message(span_warning("[loc.name]\'s arm starts stretching inhumanly!"), span_warning("Our arm twists and mutates, transforming it into a tentacle."), span_hear("You hear organic matter ripping and tearing!"))
		else
			to_chat(loc, span_notice("You prepare to extend a tentacle."))


/obj/item/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user.balloon_alert(user, "not ready!")

/obj/item/gun/magic/tentacle/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/obj/projectile/tentacle/tentacle_shot = chambered.loaded_projectile //Gets the actual projectile we will fire
	tentacle_shot.fire_modifiers = params2list(params)
	. = ..()
	if(charges == 0)
		qdel(src)

/obj/item/gun/magic/tentacle/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] coils [src] tightly around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/ammo_casing/magic/tentacle
	name = "tentacle"
	desc = "A tentacle."
	projectile_type = /obj/projectile/tentacle
	caliber = CALIBER_TENTACLE
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
	hitsound = 'sound/items/weapons/shove.ogg'
	var/chain
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it
	///Click params that were used to fire the tentacle shot
	var/list/fire_modifiers

/obj/projectile/tentacle/Initialize(mapload)
	source = loc
	. = ..()

/obj/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", emissive = FALSE)
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
		for(var/obj/item/I in H.held_items)
			if(I.get_sharpness())
				C.visible_message(span_danger("[H] impales [C] with [H.p_their()] [I.name]!"), span_userdanger("[H] impales you with [H.p_their()] [I.name]!"))
				C.apply_damage(I.force, BRUTE, BODY_ZONE_CHEST, attacking_item = I)
				H.do_item_attack_animation(C, used_item = I)
				H.add_mob_blood(C)
				playsound(get_turf(H),I.hitsound,75,TRUE)
				return

/obj/projectile/tentacle/on_hit(atom/movable/target, blocked = 0, pierce_hit)
	if(!isliving(firer) || !ismovable(target))
		return ..()

	if(blocked >= 100)
		return BULLET_ACT_BLOCK

	var/mob/living/ling = firer
	if(isitem(target) && iscarbon(ling))
		var/obj/item/catching = target
		if(catching.anchored)
			return BULLET_ACT_BLOCK

		var/mob/living/carbon/carbon_ling = ling
		to_chat(carbon_ling, span_notice("You pull [catching] towards yourself."))
		carbon_ling.throw_mode_on(THROW_MODE_TOGGLE)
		catching.throw_at(
			target = carbon_ling,
			range = 10,
			speed = 2,
			thrower = carbon_ling,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(reset_throw), carbon_ling),
			gentle = TRUE,
		)
		return BULLET_ACT_HIT

	. = ..()
	if(. != BULLET_ACT_HIT)
		return .
	var/mob/living/victim = target
	if(!isliving(victim) || target.anchored || victim.throwing)
		return BULLET_ACT_BLOCK

	if(!iscarbon(victim) || !ishuman(ling) || !ling.combat_mode)
		victim.visible_message(
			span_danger("[victim] is grabbed by [ling]'s [src]]!"),
			span_userdanger("\A [src] grabs you and pulls you towards [ling]!"),
		)
		victim.throw_at(
			target = get_step_towards(ling, victim),
			range = 8,
			speed = 2,
			thrower = ling,
			diagonals_first = TRUE,
			gentle = TRUE,
		)
		return BULLET_ACT_HIT

	if(LAZYACCESS(fire_modifiers, RIGHT_CLICK))
		var/obj/item/stealing = victim.get_active_held_item()
		if(!isnull(stealing))
			if(victim.dropItemToGround(stealing))
				victim.visible_message(
					span_danger("[stealing] is yanked off [victim]'s hand by [src]!"),
					span_userdanger("\A [src] pulls [stealing] away from you!"),
				)
				return on_hit(stealing) //grab the item as if you had hit it directly with the tentacle

			to_chat(ling, span_warning("You can't seem to pry [stealing] off [victim]'s hands!"))
			return BULLET_ACT_BLOCK

		to_chat(ling, span_danger("[victim] has nothing in hand to disarm!"))
		return BULLET_ACT_HIT

	if(ling.combat_mode)
		victim.visible_message(
			span_danger("[victim] is thrown towards [ling] by \a [src]!"),
			span_userdanger("\A [src] grabs you and throws you towards [ling]!"),
		)
		victim.throw_at(
			target = get_step_towards(ling, victim),
			range  = 8,
			speed = 2,
			thrower = ling,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(tentacle_grab), ling, victim),
			gentle = TRUE,
		)

	return BULLET_ACT_HIT

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
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user) //So we can read the absorbed_count.
	if(!changeling)
		return

	var/obj/item/shield/changeling/S = ..(user)
	S.remaining_uses = round(changeling.absorbed_count * 3)
	return TRUE

/obj/item/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	item_flags = ABSTRACT | DROPDEL
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "ling_shield"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	block_chance = 50
	is_bashable = FALSE

	var/remaining_uses //Set by the changeling ability.

/obj/item/shield/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!"), span_warning("We inflate our hand into a strong shield."), span_hear("You hear organic matter ripping and tearing!"))

/obj/item/shield/changeling/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.visible_message(span_warning("With a sickening crunch, [H] reforms [H.p_their()] shield into an arm!"), span_notice("We assimilate our shield into our body"), span_italics("You hear organic matter ripping and tearing!"))
		qdel(src)
		return 0
	else
		remaining_uses--
		return ..()

/***************************************\
|*****************ARMOR*****************|
\***************************************/
/datum/action/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage. Costs 20 chemicals."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor provides decent protection against brute force and energy weapons. Cannot be used in lesser form."
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
	inhand_icon_state = null
	item_flags = DROPDEL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor_type = /datum/armor/armor_changeling
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0

/datum/armor/armor_changeling
	melee = 40
	bullet = 40
	laser = 40
	energy = 50
	bomb = 10
	bio = 10
	fire = 90
	acid = 90

/obj/item/clothing/suit/armor/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!"), span_warning("We harden our flesh, creating a suit of armor!"), span_hear("You hear organic matter ripping and tearing!"))

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	inhand_icon_state = null
	item_flags = DROPDEL
	armor_type = /datum/armor/helmet_changeling
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT

/datum/armor/helmet_changeling
	melee = 40
	bullet = 40
	laser = 40
	energy = 50
	bomb = 10
	bio = 10
	fire = 90
	acid = 90

/obj/item/clothing/head/helmet/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

/datum/action/changeling/suit/hive_head
	name = "Hive Head"
	desc = "We coat our head in a waxy outing coating similar to a bee hive which can be used to manufacture bees to attack our enemies. Costs 15 chemicals."
	helptext = "While the hive head does not provide much in the ways of armor, it does allow the user to send bees out to attack targets. Reagents can poured inside the hive to cause all bees released to inject said reagents."
	button_icon_state = "hive_head"
	chemical_cost = 15
	dna_cost = 2
	req_human = FALSE
	blood_on_castoff = TRUE

	helmet_type = /obj/item/clothing/head/helmet/changeling_hivehead
	helmet_name_simple = "hive head"

/obj/item/clothing/head/helmet/changeling_hivehead
	name = "hive head"
	desc = "A strange, waxy outer coating covering your head. Gives you tinnitus."
	icon_state = "hivehead"
	inhand_icon_state = null
	flash_protect = FLASH_PROTECTION_FLASH
	item_flags = DROPDEL
	armor_type = /datum/armor/changeling_hivehead
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/cooldown/hivehead_spawn_minions)
	///Does this hive head hold reagents?
	var/holds_reagents = TRUE

/obj/item/clothing/head/helmet/changeling_hivehead/Initialize(mapload)
	. = ..()
	if(holds_reagents)
		create_reagents(50, REFILLABLE)

/datum/armor/changeling_hivehead
	melee = 10
	bullet = 10
	laser = 10
	energy = 10
	bio = 50

/obj/item/clothing/head/helmet/changeling_hivehead/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

/obj/item/clothing/head/helmet/changeling_hivehead/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/organ/monster_core/regenerative_core/legion) || !holds_reagents)
		return
	visible_message(span_boldwarning("As [user] shoves [attacking_item] into [src], [src] begins to mutate."))
	var/mob/living/carbon/wearer = loc
	playsound(wearer, 'sound/effects/blob/attackblob.ogg', 60, TRUE)
	wearer.temporarilyRemoveItemFromInventory(wearer.head, TRUE)
	wearer.equip_to_slot_if_possible(new /obj/item/clothing/head/helmet/changeling_hivehead/legion(wearer), ITEM_SLOT_HEAD, 1, 1, 1)
	qdel(attacking_item)


/datum/action/cooldown/hivehead_spawn_minions
	name = "Release Bees"
	desc = "Release a group of bees to attack all other lifeforms."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	button_icon = 'icons/mob/simple/bees.dmi'
	button_icon_state = "queen_item"
	cooldown_time = 30 SECONDS
	///The mob we're going to spawn
	var/spawn_type = /mob/living/basic/bee/timed/short
	///How many are we going to spawn
	var/spawn_count = 6

/datum/action/cooldown/hivehead_spawn_minions/PreActivate(atom/target)
	if(owner.movement_type & VENTCRAWLING)
		owner.balloon_alert(owner, "unavailable here")
		return
	return ..()

/datum/action/cooldown/hivehead_spawn_minions/Activate(atom/target)
	. = ..()
	do_tell()
	var/spawns = spawn_count
	if(owner.stat >= HARD_CRIT)
		spawns = 1
	for(var/i in 1 to spawns)
		var/mob/living/basic/summoned_minion = new spawn_type(get_turf(owner))
		summoned_minion.faction = list("[REF(owner)]")
		minion_additional_changes(summoned_minion)

///Our tell that we're using this ability. Usually a sound and a visible message.area
/datum/action/cooldown/hivehead_spawn_minions/proc/do_tell()
	owner.visible_message(span_warning("[owner]'s head begins to buzz as bees begin to pour out!"), span_warning("We release the bees."), span_hear("You hear a loud buzzing sound!"))
	playsound(owner, 'sound/mobs/non-humanoids/bee/bee_swarm.ogg', 60, TRUE)

///Stuff we want to do to our minions. This is in its own proc so subtypes can override this behaviour.
/datum/action/cooldown/hivehead_spawn_minions/proc/minion_additional_changes(mob/living/basic/minion)
	var/mob/living/basic/bee/summoned_bee = minion
	var/mob/living/carbon/wearer = owner
	if(istype(summoned_bee) && length(wearer.head.reagents.reagent_list))
		summoned_bee.assign_reagent(pick(wearer.head.reagents.reagent_list))

/obj/item/clothing/head/helmet/changeling_hivehead/legion
	name = "legion hive head"
	desc = "A strange, boney coating covering your head with a fleshy inside. Surprisingly comfortable."
	icon_state = "hivehead_legion"
	actions_types = list(/datum/action/cooldown/hivehead_spawn_minions/legion)
	holds_reagents = FALSE

/datum/action/cooldown/hivehead_spawn_minions/legion
	name = "Release Legion"
	desc = "Release a group of legion to attack all other lifeforms."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	cooldown_time = 15 SECONDS
	spawn_type = /mob/living/basic/legion_brood
	spawn_count = 4

/datum/action/cooldown/hivehead_spawn_minions/legion/do_tell()
	owner.visible_message(span_warning("[owner]'s head begins to shake as legion begin to pour out!"), span_warning("We release the legion."), span_hear("You hear a loud squishing sound!"))
	playsound(owner, 'sound/effects/blob/attackblob.ogg', 60, TRUE)

/datum/action/cooldown/hivehead_spawn_minions/legion/minion_additional_changes(mob/living/basic/minion)
	var/mob/living/basic/legion_brood/brood = minion
	if (istype(brood))
		brood.assign_creator(owner, FALSE)
