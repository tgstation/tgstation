/*
Slimecrossing Weapons
	Weapons added by the slimecrossing system.
	Collected here for clarity.
*/

//Boneblade - Burning Green
/obj/item/melee/arm_blade/slime
	name = "slimy boneblade"
	desc = "What remains of the bones in your arm. Incredibly sharp, and painful for both you and your opponents."
	force = 15
	force_string = "painful"

/obj/item/melee/arm_blade/slime/attack(mob/living/L, mob/user)
	. = ..()
	if(prob(20))
		user.emote("scream")

//Rainbow knife - Burning Rainbow
/obj/item/knife/rainbowknife
	name = "rainbow knife"
	desc = "A strange, transparent knife which constantly shifts color. It hums slightly when moved."
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "rainbowknife"
	inhand_icon_state = "rainbowknife"
	force = 15
	throwforce = 15
	damtype = BRUTE

/obj/item/knife/rainbowknife/afterattack(atom/target, mob/user, params)
	if(isliving(target))
		damtype = pick(BRUTE, BURN, TOX, OXY)
	switch(damtype)
		if(BRUTE)
			hitsound = 'sound/items/weapons/bladeslice.ogg'
			attack_verb_continuous = string_list(list("slashes", "slices", "cuts"))
			attack_verb_simple = string_list(list("slash", "slice", "cut"))
		if(BURN)
			hitsound = 'sound/items/weapons/sear.ogg'
			attack_verb_continuous = string_list(list("burns", "singes", "heats"))
			attack_verb_simple = string_list(list("burn", "singe", "heat"))
		if(TOX)
			hitsound = 'sound/items/weapons/pierce.ogg'
			attack_verb_continuous = string_list(list("poisons", "doses", "toxifies"))
			attack_verb_simple = string_list(list("poison", "dose", "toxify"))
		if(OXY)
			hitsound = 'sound/effects/space_wind.ogg'
			attack_verb_continuous = string_list(list("suffocates", "winds", "vacuums"))
			attack_verb_simple = string_list(list("suffocate", "wind", "vacuum"))

//Adamantine shield - Chilling Adamantine
/obj/item/shield/adamantineshield
	name = "adamantine shield"
	desc = "A gigantic shield made of solid adamantium."
	icon = 'icons/obj/weapons/shields.dmi'
	icon_state = "adamshield"
	inhand_icon_state = "adamshield"
	w_class = WEIGHT_CLASS_HUGE
	armor_type = /datum/armor/shield_adamantineshield
	slot_flags = ITEM_SLOT_BACK
	block_chance = 75
	force = 0
	throw_range = 1 //How far do you think you're gonna throw a solid crystalline shield...?
	throw_speed = 2
	attack_verb_continuous = list("bashes", "pounds", "slams")
	attack_verb_simple = list("bash", "pound", "slam")
	item_flags = SLOWS_WHILE_IN_HAND
	breakable_by_damage = FALSE
	shield_bash_sound = 'sound/effects/glass/glassknock.ogg'

/datum/armor/shield_adamantineshield
	melee = 50
	bullet = 50
	laser = 50
	bomb = 30
	fire = 80
	acid = 70

/obj/item/shield/adamantineshield/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_wielded=15)

//Bloodchiller - Chilling Green
/obj/item/gun/magic/bloodchill
	name = "blood chiller"
	desc = "A horrifying weapon made of your own bone and blood vessels. It shoots slowing globules of your own blood. Ech."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "bloodgun"
	inhand_icon_state = "bloodgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	antimagic_flags = NONE
	force = 5
	max_charges = 1 //Recharging costs blood.
	recharge_rate = 1
	ammo_type = /obj/item/ammo_casing/magic/bloodchill
	fire_sound = 'sound/effects/blob/attackblob.ogg'

/obj/item/gun/magic/bloodchill/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/magic/bloodchill/process(seconds_per_tick)
	charge_timer += seconds_per_tick
	if(charge_timer < recharge_rate || charges >= max_charges)
		return FALSE
	charge_timer = 0
	var/mob/living/M = loc
	if(istype(M) && M.blood_volume >= 20)
		charges++
		M.blood_volume -= 20
	if(charges == 1)
		recharge_newshot()
	return TRUE

/obj/item/ammo_casing/magic/bloodchill
	projectile_type = /obj/projectile/magic/bloodchill

/obj/projectile/magic/bloodchill
	name = "blood ball"
	icon_state = "pulse0_bl"
	hitsound = 'sound/effects/splat.ogg'

/obj/projectile/magic/bloodchill/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		target.apply_status_effect(/datum/status_effect/bloodchill)
