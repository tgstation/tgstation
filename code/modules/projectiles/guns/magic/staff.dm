/obj/item/gun/magic/staff
	slot_flags = ITEM_SLOT_BACK
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	item_flags = NEEDS_PERMIT | NO_MAT_REDEMPTION

/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	fire_sound = 'sound/magic/staff_animation.ogg'
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"

/obj/item/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

/obj/item/gun/magic/staff/healing/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	fire_sound = 'sound/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	var/allowed_projectile_types = list(/obj/item/projectile/magic/change, /obj/item/projectile/magic/animate, /obj/item/projectile/magic/resurrection,
	/obj/item/projectile/magic/death, /obj/item/projectile/magic/teleport, /obj/item/projectile/magic/door, /obj/item/projectile/magic/aoe/fireball,
	/obj/item/projectile/magic/spellblade, /obj/item/projectile/magic/arcane_barrage, /obj/item/projectile/magic/locker)

/obj/item/gun/magic/staff/chaos/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	chambered.projectile_type = pick(allowed_projectile_types)
	. = ..()

/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	fire_sound = 'sound/magic/staff_door.ogg'
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1

/obj/item/gun/magic/staff/honk
	name = "staff of the honkmother"
	desc = "Honk."
	fire_sound = 'sound/items/airhorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/honk
	icon_state = "honker"
	item_state = "honker"
	max_charges = 4
	recharge_rate = 8

/obj/item/gun/magic/staff/spellblade
	name = "spellblade"
	desc = "A deadly combination of laziness and boodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 20
	armour_penetration = 75
	block_chance = 50
	sharpness = IS_SHARP
	max_charges = 4

/obj/item/gun/magic/staff/spellblade/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 15, 125, 0, hitsound)

/obj/item/gun/magic/staff/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/obj/item/gun/magic/staff/locker
	name = "staff of the locker"
	desc = "An artefact that expells encapsulating bolts, for incapacitating thy enemy."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/locker
	icon_state = "locker"
	item_state = "locker"
	max_charges = 6
	recharge_rate = 4

/obj/item/gun/magic/staff/flying
	name = "staff of flying"
	desc = "An artefact that spits bolts of graceful magic that can make something fly."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/flying
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/grounding
	name = "staff of grounding"
	desc = "An artefact that spits bolts of dense magic that hates flying things."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/grounding
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/bounty
	name = "staff of bounty"
	desc = "An artefact that spits bolts of latent magic that can provide some delayed rewards to the bloodshed."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/bounty
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/antimagic
	name = "staff of antimagic"
	desc = "An artefact that spits bolts of paradoxical magic that magically prevents magic."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/antimagic
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/sapping
	name = "staff of sapping"
	desc = "An artefact that spits bolts of depressed magic that makes you feel pretty bad."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/sapping
	icon_state = "staffofchange"
	item_state = "staffofchange"


//ADMIN ONLY FROM HERE ON OUT//

/obj/item/gun/magic/staff/law
	name = "staff of the law"
	desc = "An artefact that spits bolts of vindicative magic that detains criminal scum."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/law
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/awakening
	name = "staff of awakening"
	desc = "An artefact that spits bolts of unlocking magic that can make someone realize their inner powers."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/awakening
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/gib
	name = "staff of gravitokinetics"
	desc = "An artefact that spits bolts of active magic that explodes victims."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/gib
	icon_state = "staffofchange"
	item_state = "staffofchange"
