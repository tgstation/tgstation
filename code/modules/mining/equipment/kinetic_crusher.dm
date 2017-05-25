/*********************Mining Hammer****************/
/obj/item/weapon/twohanded/required/mining_hammer
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_hammer1"
	item_state = "mining_hammer1"
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than an combination of various mining tools cobbled together, forming a high-tech club. \
	While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna.\
	\n<span class='info'>Mark a mob with the destabilizing force, then hit them in melee to activate it for extra damage. Extra damage if backstabbed in this fashion. \
	This weapon is only particularly effective against large creatures.</span>"
	force = 20 //As much as a bone spear, but this is significantly more annoying to carry around due to requiring the use of both hands at all times
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 20 //It's never not wielded so these are the same
	force_wielded = 20
	throwforce = 5
	throw_speed = 4
	luminosity = 4
	armour_penetration = 10
	materials = list(MAT_METAL=1150, MAT_GLASS=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("smashed", "crushed", "cleaved", "chopped", "pulped")
	sharpness = IS_SHARP
	var/charged = TRUE
	var/charge_time = 14

/obj/item/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	nodamage = TRUE
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	flag = "bomb"
	range = 6
	log_override = TRUE
	var/obj/item/weapon/twohanded/required/mining_hammer/hammer_synced

/obj/item/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/item/projectile/destabilizer/on_hit(atom/target, blocked = 0)
	if(isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.apply_status_effect(STATUS_EFFECT_CRUSHERMARK)
		CM.hammer_synced = hammer_synced
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.gets_drilled(firer)
	..()

/obj/item/weapon/twohanded/required/mining_hammer/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/item/projectile/destabilizer/D = new /obj/item/projectile/destabilizer(proj_turf)
		D.preparePixelProjectile(target, get_turf(target), user)
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = FALSE
		icon_state = "mining_hammer1_uncharged"
		addtimer(CALLBACK(src, .proc/Recharge), charge_time)
		return
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK))
			return
		new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
		var/backstab_dir = get_dir(user, L)
		var/def_check = L.getarmor(type = "bomb")
		if((user.dir & backstab_dir) && (L.dir & backstab_dir))
			L.apply_damage(80, BRUTE, blocked = def_check)
			playsound(user, 'sound/weapons/Kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong
		else
			L.apply_damage(50, BRUTE, blocked = def_check)

/obj/item/weapon/twohanded/required/mining_hammer/proc/Recharge()
	if(!charged)
		charged = TRUE
		icon_state = "mining_hammer1"
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
