/obj/item/gun/energy/e_gun/lawbringer
	name = "\improper Lawbringer"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	cell_type = /obj/item/stock_parts/cell/lawbringer
	icon_state = "hoslaser" //placeholder
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/lawbringer/detain, \
	 /obj/item/ammo_casing/energy/lawbringer/execute, \
	 /obj/item/ammo_casing/energy/lawbringer/hotshot, \
	 /obj/item/ammo_casing/energy/lawbringer/smokeshot, \
	 /obj/item/ammo_casing/energy/lawbringer/bigshot, \
	 /obj/item/ammo_casing/energy/lawbringer/clownshot, \
	 /obj/item/ammo_casing/energy/lawbringer/pulse)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	selfcharge = 1
	//can_select = FALSE
	can_charge = FALSE
	//var/owner_prints = null

/*/obj/item/gun/energy/e_gun/lawbringer/attack_self(mob/living/user as mob)
	return
*/

/obj/item/stock_parts/cell/lawbringer
	name = "Lawbringer power cell"
	maxcharge = 6000 //300

/obj/item/ammo_casing/energy/lawbringer/detain //placeholder
	projectile_type = /obj/projectile/beam/disabler
	select_name = "detain"
	e_cost = 50
	pellets = 3
	variance = 15
	harmful = FALSE

/*
PART 1:
The ammo+projectiles+cell
PART 2:
Voice stuff
PART 3:
Sprites
*/

// 6000:100 = 300:5    all energy values multiplied by 20
/*
/obj/item/ammo_casing/energy/lawbringer/execute
	projectile_type = /obj/projectile/lawbringer/execute
	//revolver sound
	select_name = "execute"
	e_cost = 600 //30
	harmful = TRUE

/obj/projectile/lawbringer/execute
	name = "protomatter bullet"
	sharpness = SHARP_POINTY
	armor_flag = BULLET
	hitsound_wall = SFX_RICOCHET
	damage = 20
	wound_bonus = -5
*/

/obj/item/ammo_casing/energy/lawbringer/hotshot
	projectile_type = /obj/projectile/lawbringer/hotshot
	select_name = "hotshot"
	e_cost = 1200 //60
	harmful = TRUE

/obj/projectile/lawbringer/hotshot
	name = "proto-plasma"
	//TODO: Projectile noise and sprite
	damage = 5
	damage_type = BRUN
/obj/projectile/lawbringer/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(2)
		M.ignite_mob()

/obj/item/ammo_casing/energy/lawbringer/smokeshot
	projectile_type = /obj/projectile/lawbringer/smokeshot
	//grenade launcher sound
	select_name = "smokeshot"
	e_cost = 1000 //50
	harmful = FALSE

/obj/projectile/lawbringer/smokeshot
	name = "condensed smoke"
	//TODO: Projectile noise and sprite
	damage = 0
	damage_type = BRUTE

/obj/projectile/lawbringer/bigshot/on_hit(atom/target, blocked = FALSE)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(4, holder = src, location = target.loc)
	smoke.start()

/obj/item/ammo_casing/energy/lawbringer/bigshot
	projectile_type = /obj/projectile/lawbringer/bigshot
	//some loud noise
	select_name = "bigshot"
	e_cost = 3400 //170
	harmful = TRUE

/obj/projectile/lawbringer/bigshot
	name = "protomatter shell"
	damage = 25
	damage_type = BRUTE
	firesound = 'sound/weapons/gun/hmg/hmg.ogg'
	speed = 1
	pixel_speed_multiplier = 0.5
	eyeblur = 5
	knockdown = 1
	wound_bonus = -5
	var/anti_material_damage = 75
	//calls light explosion proc on non-carbons.
/obj/projectile/lawbringer/bigshot/on_hit(atom/target, blocked = FALSE)
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(anti_material_damage)
	if(issilicon(target)) //if the target is a borg, just give them one of these to make it loud, most of the damage is in the projectile itself
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_material_damage*0.90, anti_material_damage*0.40)
		explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
		return
	if(isstructure(target) || isvehicle (target) || isclosedturf (target) || ismachinery (target)) //if the target is a structure, machine, vehicle or closed turf like a wall, explode that shit
		if(target.density) //Dense objects get blown up a bit harder
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
		else
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)

/*
/obj/item/ammo_casing/energy/lawbringer/clownshot
	projectile_type = /obj/projectile/lawbringer/clownshot
	//honk sound
	select_name = "clownshot"
	e_cost = 300 //15
	harmful = TRUE

/obj/projectile/lawbringer/clownshot
	name = "bannanium bullet"
	damage = 4
	damage_type = BRUTE
	//something that drops the shoes, makes a visible alert to the crew, plays the loud honk sound, then launches the clown, if it hits someone with the clumsy gene.

/obj/projectile/lawbringer/clownshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle)) //put this behind some clown check
		target.throw_at(throw_target, 200, 8) //put this behind some clown check
*/

/obj/item/ammo_casing/energy/lawbringer/pulse
	projectile_type = /obj/projectile/lawbringer/pulse
	select_name = "pulse"
	e_cost = 700 //35
	harmful = TRUE

/obj/projectile/lawbringer/pulse
	name = "compressed air"
	//TODO: Projectile noise and sprite
	damage = 0
	damage_type = BRUTE

/obj/projectile/lawbringer/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
		target.throw_at(throw_target, 5, 2)

/*
/obj/item/ammo_casing/energy/lawbringer/tideshot
	projectile_type = /obj/projectile/lawbringer/tideshot
	//revolver sound
	select_name = "tideshot"
	e_cost = 6000 //30
	harmful = TRUE

/obj/projectile/lawbringer/tideshot //just make it stun the shit out of staffies
	name = "protomatter bullet"
	damage = 20
	wound_bonus = -5
*/
