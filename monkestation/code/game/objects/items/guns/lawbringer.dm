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
	 /obj/item/ammo_casing/energy/lawbringer/pulse, \
	 /obj/item/ammo_casing/energy/lawbringer/tideshot)
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

/*
PART 1:
The ammo+projectiles+cell
PART 2:
Voice stuff
PART 3:
Sprites
PART 4:
Mapping it in
PART 5:
In situ balance testing
*/

// 6000:100 = 300:5    all energy values multiplied by 20
// recharge rate was insufficent, multiply all values by 10 instead of 20

/obj/item/ammo_casing/energy/lawbringer/detain
	projectile_type = /obj/projectile/lawbringer/detain
	select_name = "detain"
	fire_sound = 'sound/weapons/laser.ogg'
	e_cost = 1000 //50
	pellets = 5
	variance = 20
	harmful = FALSE

/obj/projectile/lawbringer/detain
	name = "hyperfocused disabler beam"
	icon_state = "gauss_silenced"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	light_system = MOVABLE_LIGHT
	damage = 0
	damage_type = STAMINA
	stamina = 20
	paralyze_timer = 5 SECONDS
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	ricochets_max = 4
	ricochet_chance = 140
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 7
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 1
	ricochet_shoots_firer = FALSE //something something biometrics
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	reflectable = REFLECT_NORMAL
	light_system = MOVABLE_LIGHT
	light_outer_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_BLUE

/obj/item/ammo_casing/energy/lawbringer/execute
	projectile_type = /obj/projectile/lawbringer/execute
	select_name = "execute"
	fire_sound = 'sound/weapons/gun/pistol/shot_suppressed.ogg'
	e_cost = 600 //30
	harmful = TRUE

/obj/projectile/lawbringer/execute
	name = "protomatter bullet"
	sharpness = SHARP_POINTY
	armor_flag = BULLET
	hitsound_wall = SFX_RICOCHET
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	damage = 20
	wound_bonus = -5
	wound_falloff_tile = -5

/obj/item/ammo_casing/energy/lawbringer/hotshot
	projectile_type = /obj/projectile/lawbringer/hotshot
	select_name = "hotshot"
	fire_sound = 'sound/weapons/fwoosh.ogg'
	e_cost = 1200 //60
	harmful = TRUE

/obj/projectile/lawbringer/hotshot
	name = "proto-plasma"
	icon_state = "pulse0_bl"
	hitsound = 'sound/magic/fireball.ogg'
	damage = 5
	damage_type = BURN

/obj/projectile/lawbringer/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(2)
		M.ignite_mob()

/obj/item/ammo_casing/energy/lawbringer/smokeshot
	projectile_type = /obj/projectile/lawbringer/smokeshot
	select_name = "smokeshot"
	fire_sound = 'sound/items/syringeproj.ogg'
	e_cost = 1000 //50
	harmful = FALSE

/obj/projectile/lawbringer/smokeshot
	name = "condensed smoke"
	icon_state = "nuclear_particle"
	damage = 0
	damage_type = BRUTE
	can_hit_turfs = TRUE

/obj/projectile/lawbringer/smokeshot/on_hit(atom/target, blocked = FALSE)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(3, holder = src, location = get_turf(target))
	smoke.start()

/obj/item/ammo_casing/energy/lawbringer/bigshot
	projectile_type = /obj/projectile/lawbringer/bigshot
	select_name = "bigshot"
	fire_sound = 'sound/weapons/gun/hmg/hmg.ogg'
	e_cost = 3400 //170
	harmful = TRUE

/obj/projectile/lawbringer/bigshot
	name = "protomatter shell"
	damage = 25
	damage_type = BRUTE
	icon_state = "blastwave"
	speed = 1
	pixel_speed_multiplier = 0.5
	eyeblur = 10
	jitter = 10 SECONDS
	knockdown = 1
	wound_bonus = -5
	var/anti_material_damage = 75

/obj/projectile/lawbringer/bigshot/on_hit(atom/target, blocked = FALSE)
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(anti_material_damage)
	if(issilicon(target))
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

/obj/item/ammo_casing/energy/lawbringer/clownshot
	projectile_type = /obj/projectile/lawbringer/clownshot
	select_name = "clownshot"
	fire_sound = 'sound/items/bikehorn.ogg'
	e_cost = 300 //15
	harmful = TRUE

/obj/projectile/lawbringer/clownshot
	name = "bannanium bullet"
	damage = 4
	damage_type = BRUTE
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	weak_against_armour = TRUE

/obj/projectile/lawbringer/clownshot/on_hit(mob/living/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(M.dna && M.dna.check_mutation(/datum/mutation/human/clumsy))
			if (M.shoes)
				var/obj/item/clothing/shoes/item_to_strip = M.shoes
				M.dropItemToGround(item_to_strip)
				to_chat(target, span_reallybig(span_clown("Your blasted right off your shoes!!")))
				M.visible_message(span_warning("[M] is is sent rocketing off their shoes!"))
			playsound(src, 'sound/items/airhorn.ogg', 100, TRUE, -1)
			var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
			target.throw_at(throw_target, 200, 8)


/obj/item/ammo_casing/energy/lawbringer/pulse
	projectile_type = /obj/projectile/lawbringer/pulse
	fire_sound = 'sound/weapons/sonic_jackhammer.ogg'
	select_name = "pulse"
	e_cost = 700 //35
	harmful = TRUE

/obj/projectile/lawbringer/pulse
	name = "compressed air"
	//TODO: Projectile sprite
	damage = 0
	damage_type = BRUTE

/obj/projectile/lawbringer/pulse/on_hit(mob/living/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
		target.throw_at(throw_target, 5, 1)


/obj/item/ammo_casing/energy/lawbringer/tideshot
	projectile_type = /obj/projectile/lawbringer/tideshot
	fire_sound = 'sound/weapons/laser.ogg'
	select_name = "tideshot"
	e_cost = 600 //30
	harmful = TRUE

/obj/projectile/lawbringer/tideshot //just make it stun the shit out of staffies
	name = "grey disabler beam"
	icon_state = "greyscale_bolt"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = STAMINA
	stamina = 20 // not for use on the employed
	paralyze_timer = 5 SECONDS
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	reflectable = REFLECT_NORMAL
	light_system = MOVABLE_LIGHT
	light_outer_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_HALOGEN

/obj/projectile/lawbringer/tideshot/on_hit(mob/living/target, blocked = FALSE)
	if(ishuman(target))
		if(target.mind)
			if(is_assistant_job(target.mind.assigned_role))
				var/mob/living/carbon/C = target
				C.add_mood_event("tased", /datum/mood_event/tased)
				SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)

