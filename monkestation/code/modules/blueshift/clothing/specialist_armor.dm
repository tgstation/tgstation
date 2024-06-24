// Sacrificial armor has massive bullet protection, but gets damaged by being shot, thus, is sacrificing itself to protect the wearer
/datum/armor/armor_sf_sacrificial
	melee = ARMOR_LEVEL_WEAK
	bullet = ARMOR_LEVEL_INSANE // When the level IV plates stop the bullet but not the energy transfer
	laser = ARMOR_LEVEL_TINY
	energy = ARMOR_LEVEL_TINY
	bomb = ARMOR_LEVEL_MID
	fire = ARMOR_LEVEL_MID
	acid = ARMOR_LEVEL_WEAK
	wound = WOUND_ARMOR_HIGH

/obj/item/clothing/suit/armor/sf_sacrificial
	name = "'Val' sacrificial ballistic vest"
	desc = "A hefty vest with a unique pattern of hexes on its outward faces. \
		As the 'sacrificial' name might imply, this vest has extremely high bullet protection \
		in exchange for allowing itself to be destroyed by impacts. It'll protect you from hell, \
		but only for so long."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "hexagon"
	worn_icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor_worn.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	armor_type = /datum/armor/armor_sf_sacrificial
	max_integrity = 200
	limb_integrity = 200
	repairable_by = null // No being cheeky and keeping a pile of repair materials in your bag to fix it either
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/armor/sf_sacrificial/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/clothing_damaged_by_bullets)

/obj/item/clothing/suit/armor/sf_sacrificial/examine_more(mob/user)
	. = ..()

	. += "An extreme solution to an extreme problem. While many galactic armors have some semblance of self-repairing tech \
		in them to prevent the armor becoming useless after being shot enough, it does have its limits. Those limits tend to be \
		that the self-repairing, while handy, take the place of what could have simply been more armor. For a small market, \
		one that doesn't care if their armor lasts more than one gunfight, there exists a niche for armors such as the 'Val'. \
		Passing up self-repair for nigh-immunity to bullets, the right tool for a certain job, if you can find whatever that job may be."

	return .

/obj/item/clothing/head/helmet/sf_sacrificial
	name = "'Val' sacrificial ballistic helmet"
	desc = "A large, almost always ill-fitting helmet painted in a tacticool black. \
		As the 'sacrificial' name might imply, this helmet has extremely high bullet protection \
		in exchange for allowing itself to be destroyed by impacts. It'll protect you from hell, \
		but only for so long."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "bulletproof"
	worn_icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor_worn.dmi'
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/armor_sf_sacrificial
	max_integrity = 200
	limb_integrity = 200
	repairable_by = null // No being cheeky and keeping a pile of repair materials in your bag to fix it either
	dog_fashion = null
	flags_inv = null
	resistance_flags = FIRE_PROOF
	/// Holds the faceshield for quick reference
	var/obj/item/sacrificial_face_shield/face_shield

/obj/item/clothing/head/helmet/sf_sacrificial/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/clothing_damaged_by_bullets)

/obj/item/clothing/head/helmet/sf_sacrificial/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(!(istype(attacking_item, /obj/item/sacrificial_face_shield)))
		return

	add_face_shield(user, attacking_item)

/obj/item/clothing/head/helmet/sf_sacrificial/Destroy()
	QDEL_NULL(face_shield)
	return ..()

/obj/item/clothing/head/helmet/sf_sacrificial/AltClick(mob/user)
	remove_face_shield(user)
	return

/// Attached the passed face shield to the helmet.
/obj/item/clothing/head/helmet/sf_sacrificial/proc/add_face_shield(mob/living/carbon/human/user, obj/shield_in_question, on_spawn)
	if(face_shield)
		return
	if(!user?.transferItemToLoc(shield_in_question, src) && !on_spawn)
		return

	if(on_spawn)
		shield_in_question = new /obj/item/sacrificial_face_shield(src)

	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF

	playsound(src, 'sound/items/modsuit/magnetic_harness.ogg', 50, TRUE)
	face_shield = shield_in_question

	icon_state = "bulletproof_glass"
	worn_icon_state = icon_state
	update_appearance()

/// Removes the face shield from the helmet, breaking it into a glass shard decal if that's wanted, too.
/obj/item/clothing/head/helmet/sf_sacrificial/proc/remove_face_shield(mob/living/carbon/human/user, break_it)
	if(!face_shield)
		return

	flags_inv = initial(flags_inv)
	flags_cover = initial(flags_cover)

	if(break_it)
		playsound(src, SFX_SHATTER, 70, TRUE)
		new /obj/effect/decal/cleanable/glass(drop_location(src))
		qdel(face_shield)
		face_shield = null // just to be safe
	else
		user.put_in_hands(face_shield)
		playsound(src, 'sound/items/modsuit/magnetic_harness.ogg', 50, TRUE)
		face_shield = null

	icon_state = initial(icon_state)
	worn_icon_state = icon_state // Against just to be safe
	update_appearance()

/obj/item/clothing/head/helmet/sf_sacrificial/take_damage_zone(def_zone, damage_amount, damage_type, armour_penetration)
	. = ..()

	if((damage_amount > 20) && face_shield)
		remove_face_shield(break_it = TRUE)

/obj/item/clothing/head/helmet/sf_sacrificial/examine(mob/user)
	. = ..()
	if(face_shield)
		. += span_notice("The <b>face shield</b> can be removed with <b>Right-Click</b>.")
	else
		. += span_notice("A <b>face shield</b> can be attached to it.")

	return .

/obj/item/clothing/head/helmet/sf_sacrificial/examine_more(mob/user)
	. = ..()

	. += "An extreme solution to an extreme problem. While many galactic armors have some semblance of self-repairing tech \
		in them to prevent the armor becoming useless after being shot enough, it does have its limits. Those limits tend to be \
		that the self-repairing, while handy, take the place of what could have simply been more armor. For a small market, \
		one that doesn't care if their armor lasts more than one gunfight, there exists a niche for armors such as the 'Val'. \
		Passing up self-repair for nigh-immunity to bullets, the right tool for a certain job, if you can find whatever that job may be."

	return .

/obj/item/clothing/head/helmet/sf_sacrificial/spawns_with_shield

/obj/item/clothing/head/helmet/sf_sacrificial/spawns_with_shield/Initialize(mapload)
	. = ..()
	add_face_shield(on_spawn = TRUE)

/obj/item/sacrificial_face_shield
	name = "'Val' ballistic add-on face plate"
	desc = "A thick piece of glass with mounting points for slotting onto a 'Val' sacrificial ballistic helmet. \
		While it does not make the helmet any stronger, it does protect your face much like a riot helmet would."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "face_shield"
	w_class = WEIGHT_CLASS_NORMAL

// The peacekeeper armors and helmets will be less effective at stopping bullet damage than bulletproof vests, but stronger against wounds especially, and some other damage types
/datum/armor/armor_sf_peacekeeper
	melee = ARMOR_LEVEL_WEAK
	bullet = ARMOR_LEVEL_MID
	laser = ARMOR_LEVEL_TINY
	energy = ARMOR_LEVEL_TINY
	bomb = ARMOR_LEVEL_WEAK
	fire = ARMOR_LEVEL_MID
	acid = ARMOR_LEVEL_WEAK
	wound = WOUND_ARMOR_HIGH

/obj/item/clothing/suit/armor/sf_peacekeeper
	name = "'Touvou' peacekeeper armor vest"
	desc = "A bright blue vest, proudly bearing 'SF' in white on its front and back. Dense fabric with a thin layer of rolled metal \
		will protect you from bullets best, a few blunt blows, and the wounds they cause. Lasers will burn more or less straight through it."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "soft_peacekeeper"
	worn_icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor_worn.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	armor_type = /datum/armor/armor_sf_peacekeeper
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/sf_peacekeeper/examine_more(mob/user)
	. = ..()

	. += "A common SolFed designed armor vest for a common cause, not having your innards become outards. \
		While heavier armors certainly exist, the 'Touvou' is relatively cheap for the protection you do get, \
		and many soldiers and officers around the galaxy will tell you the convenience of a mostly soft body armor. \
		Not for any of the protection, but for the relative comfort, especially in areas where you don't need to care \
		much if you're able to stop an anti materiel round with your chest. Likely due to all those factors, \
		it is a common sight on SolFed peacekeepers around the galaxy, alongside other misfits and corporate baddies \
		across the galaxy."

	return .

/obj/item/clothing/suit/armor/sf_peacekeeper/debranded
	name = "'Touvou' soft armor vest"
	desc = "A bright white vest, notably missing an 'SF' marking on either its front or back. Dense fabric with a thin layer of rolled metal \
		will protect you from bullets best, a few blunt blows, and the wounds they cause. Lasers will burn more or less straight through it."
	icon_state = "soft_civilian"

/obj/item/clothing/head/helmet/sf_peacekeeper
	name = "'Kastrol' peacekeeper helmet"
	desc = "A large, almost always ill-fitting helmet painted in bright blue. It proudly bears the emblems of SolFed on its sides. \
		It will protect from bullets best, with some protection against blunt blows, but falters easily in the presence of lasers."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "helmet_peacekeeper"
	worn_icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor_worn.dmi'
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/armor_sf_peacekeeper
	dog_fashion = null
	flags_inv = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/sf_peacekeeper/examine_more(mob/user)
	. = ..()

	. += "A common SolFed designed ballistic helmet for a common cause, keeping your brain inside your head. \
		While heavier helmets certainly exist, the 'Kastrol' is relatively cheap for the protection you do get, \
		and many soldiers don't mind it much due to its large over-head size bypassing a lot of the fitting issues \
		some more advanced or more protective helmets might have. \
		Especially in areas where you don't need to care \
		much if you're able to stop an anti materiel round with your forehead, it does the job just fine. \
		Likely due to all those factors, \
		it is a common sight on SolFed peacekeepers around the galaxy, alongside other misfits and corporate baddies \
		across the galaxy."

	return .

/obj/item/clothing/head/helmet/sf_peacekeeper/debranded
	name = "'Kastrol' ballistic helmet"
	desc = "A large, almost always ill-fitting helmet painted a dull grey. This one seems to lack any special markings. \
		It will protect from bullets best, with some protection against blunt blows, but falters easily in the presence of lasers."
	icon_state = "helmet_grey"

// Hardened vests negate any and all projectile armor penetration, in exchange for having mid af bullet armor
/datum/armor/armor_sf_hardened
	melee = ARMOR_LEVEL_WEAK
	bullet = ARMOR_LEVEL_MID
	laser = ARMOR_LEVEL_WEAK
	energy = ARMOR_LEVEL_TINY
	bomb = ARMOR_LEVEL_WEAK
	fire = ARMOR_LEVEL_MID
	acid = ARMOR_LEVEL_WEAK
	wound = WOUND_ARMOR_WEAK

/obj/item/clothing/suit/armor/sf_hardened
	name = "'Muur' hardened armor vest"
	desc = "A large white breastplate, and a semi-flexible mail of dense panels that cover the torso. \
		While not so incredible at directly stopping bullets, the vest is uniquely suited to cause bullets \
		to lose much of their armor penetrating energy before any damage can be done."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "hardened_standard"
	worn_icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor_worn.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	armor_type = /datum/armor/armor_sf_hardened
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/armor/sf_hardened/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	. = ..()

	if(istype(hitby, /obj/projectile))
		var/obj/projectile/incoming_projectile = hitby
		incoming_projectile.armour_penetration = 0
		playsound(owner, SFX_RICOCHET, BLOCK_SOUND_VOLUME, vary = TRUE)

/obj/item/clothing/suit/armor/sf_hardened/examine_more(mob/user)
	. = ..()

	. += "What do you do in an age where armor penetration technology keeps getting better and better, \
		and you're quite fond of not being a corpse? The 'Muur' type armor was a pretty successful attempt at an answer \
		to the question. Using some advanced materials, micro-scale projectile dampener fields, and a whole \
		host of other technologies that some poor SolFed procurement general had to talked to death about, \
		it offers a unique advantage over many armor piercing bullets. Why stop the bullet from piercing the armor \
		with more armor, when you could simply force the bullet to penetrate less and get away with less protection? \
		Some people would rather the bullet just be stopped, of course, but when you have to make choices, many choose \
		this one."

	return .

/obj/item/clothing/suit/armor/sf_hardened/emt
	name = "'Archangel' hardened armor vest"
	desc = "A large white breastplate with a lone red stripe, and a semi-flexible mail of dense panels that cover the torso. \
		While not so incredible at directly stopping bullets, the vest is uniquely suited to cause bullets \
		to lose much of their armor penetrating energy before any damage can be done."
	icon_state = "hardened_emt"

/obj/item/clothing/head/helmet/toggleable/sf_hardened
	name = "'Muur' enclosed helmet"
	desc = "A thick-fronted helmet with extendable visor for whole face protection. The materials and geometry of the helmet \
		combine in such a way that bullets lose much of their armor penetrating energy before any damage can be done, rather than penetrate into it."
	icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor.dmi'
	icon_state = "enclosed_standard"
	worn_icon = 'monkestation/code/modules/blueshift/icons/specialist_armor/armor_worn.dmi'
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/armor_sf_hardened
	toggle_message = "You extend the visor on"
	alt_toggle_message = "You retract the visor on"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	visor_flags_cover = HEADCOVERSEYES
	dog_fashion = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/toggleable/sf_hardened/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	. = ..()

	if(istype(hitby, /obj/projectile))
		var/obj/projectile/incoming_projectile = hitby
		incoming_projectile.armour_penetration = 0
		playsound(src, SFX_RICOCHET, BLOCK_SOUND_VOLUME, vary = TRUE)

/obj/item/clothing/head/helmet/toggleable/sf_hardened/examine_more(mob/user)
	. = ..()

	. += "What do you do in an age where armor penetration technology keeps getting better and better, \
		and you're quite fond of not being a corpse? The 'Muur' type armor was a pretty successful attempt at an answer \
		to the question. Using some advanced materials, micro-scale projectile dampener fields, and a whole \
		host of other technologies that some poor SolFed procurement general had to talked to death about, \
		it offers a unique advantage over many armor piercing bullets. Why stop the bullet from piercing the armor \
		with more armor, when you could simply force the bullet to penetrate less and get away with less protection? \
		Some people would rather the bullet just be stopped, of course, but when you have to make choices, many choose \
		this one."

	return .

/obj/item/clothing/head/helmet/toggleable/sf_hardened/emt
	name = "'Archangel' enclosed helmet"
	desc = "A thick-fronted helmet with extendable visor for whole face protection. The materials and geometry of the helmet \
		combine in such a way that bullets lose much of their armor penetrating energy before any damage can be done, rather than penetrate into it. \
		This one has a red stripe down the front."
	icon_state = "enclosed_emt"
