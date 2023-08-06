#define DETAIN 1
#define EXECUTE 2
#define HOTSHOT 3
#define SMOKESHOT 4
#define BIGSHOT 5
#define CLOWNSHOT 6
#define PULSE 7
#define TIDESHOT 8

/obj/item/gun/energy/e_gun/lawbringer
	name = "\improper Lawbringer"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	cell_type = /obj/item/stock_parts/cell/lawbringer
	icon_state = "hoslaser" //placeholder
	w_class = WEIGHT_CLASS_NORMAL
	verb_say = "states"
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/lawbringer/detain, \
	 /obj/item/ammo_casing/energy/lawbringer/execute, \
	 /obj/item/ammo_casing/energy/lawbringer/hotshot, \
	 /obj/item/ammo_casing/energy/lawbringer/smokeshot, \
	 /obj/item/ammo_casing/energy/lawbringer/bigshot, \
	 /obj/item/ammo_casing/energy/lawbringer/clownshot, \
	 /obj/item/ammo_casing/energy/lawbringer/pulse, \
	 /obj/item/ammo_casing/energy/lawbringer/tideshot)
	pin = /obj/item/firing_pin/lawbringer
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	selfcharge = 1
	can_select = FALSE
	can_charge = FALSE
	var/owner_dna = null

/obj/item/gun/energy/e_gun/lawbringer/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)


/////BIOMETRIC AND VOICE/////
/obj/item/gun/energy/e_gun/lawbringer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	if(message_mods[WHISPER_MODE]) //Speak up
		return FALSE
	if(speaker == src)
		return FALSE
	switch(raw_message) //this is non-functional and extremly non-preformant, find replacement ASAP
		if(findtext(raw_message, "detain"),findtext(raw_message, "disable"))
			selectammo(DETAIN)
		if(findtext(raw_message, "execute"),findtext(raw_message, "kill"))
			selectammo(EXECUTE)
		if(findtext(raw_message, "hotshot"),findtext(raw_message, "burn"))
			selectammo(HOTSHOT)
		if(findtext(raw_message, "smokeshot"),findtext(raw_message, "smoke"))
			selectammo(SMOKESHOT)
		if(findtext(raw_message, "bigshot"),findtext(raw_message, "breach"))
			selectammo(BIGSHOT)
		if(findtext(raw_message, "clownshot"),findtext(raw_message, "clown"))
			selectammo(CLOWNSHOT)
		if(findtext(raw_message, "pulse"),findtext(raw_message, "throw"))
			selectammo(PULSE)
		if(findtext(raw_message, "tideshot"),findtext(raw_message, "grey"))
			selectammo(TIDESHOT)

/obj/item/gun/energy/e_gun/lawbringer/proc/selectammo(shotnum)
	var/obj/item/ammo_casing/energy/shot = ammo_type[shotnum]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	chambered = null
	recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/e_gun/lawbringer/emag_act(mob/user, obj/item/card/emag/emag_card)
	balloon_alert(user, "biometric lock reset")
	owner_dna = null

/obj/item/gun/energy/e_gun/lawbringer/attack_self(mob/living/user as mob)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	if(C.dna && C.dna.unique_enzymes)
		if(!owner_dna)
			owner_dna = C.dna.unique_enzymes
			balloon_alert(user, "biometric lock engaged")
			updatepin(user)
			nametag(user)
		return


/obj/item/gun/energy/e_gun/lawbringer/proc/nametag(mob/living/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		src.name = "[H.real_name]'s Lawbringer"
		src.desc += " It's biometrically linked to [H.real_name]."

/obj/item/gun/energy/e_gun/lawbringer/proc/updatepin(mob/living/user)
	var/obj/item/firing_pin/lawbringer/lawpin = pin
	lawpin.updatepin(user)

/obj/item/firing_pin/lawbringer
	name = "Lawbringer firing pin"
	desc = "The integrated firing pin of the Lawbringer. You probably shouldn't be seeing this."
	icon_state = "firing_pin_dna"
	fail_message = "dna check failed!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //although i do find the idea of blowing up the hos gun enough to brick it funny, this probably shouldn't happen
	pin_removable = FALSE
	var/owner_dna = null

/obj/item/firing_pin/lawbringer/proc/updatepin(mob/living/user)
	if(!iscarbon(user))//should probably never happen
		return
	var/mob/living/carbon/C = user
	owner_dna = C.dna.unique_enzymes

/obj/item/firing_pin/lawbringer/pin_auth(mob/living/carbon/user)
	if(user && user.dna && user.dna.unique_enzymes)
		if(user.dna.unique_enzymes == owner_dna)
			return TRUE
	return FALSE

/obj/item/firing_pin/lawbringer/auth_fail(mob/living/carbon/user)
	to_chat(user, span_danger("The gun emits a deterring shock from its handle."))
	var/mob/living/carbon/human/human_user = user
	human_user.electrocute_act(10, "lawbringer deterrant") //mister electric kill this man

/////PROJECTILES AND AMMO/////
/obj/item/stock_parts/cell/lawbringer
	name = "Lawbringer power cell"
	maxcharge = 3000 //300

/*
PART 1:
The ammo+projectiles+cell [DONE][MOSTLY]
PART 2:
Voice stuff and biometrics
PART 3:
Sprites
PART 4:
Mapping it in
PART 5:
In situ balance testing

IDEAS:
After 25 minutes of the owner being dead, it desychs from owner

*/

// 6000:100 = 300:5    all energy values multiplied by 20
// recharge rate was insufficent, multiply all values by 10 instead of 20

/obj/item/ammo_casing/energy/lawbringer/detain
	projectile_type = /obj/projectile/lawbringer/detain
	select_name = "detain"
	fire_sound = 'sound/weapons/laser.ogg'
	e_cost = 600 //50 + 10
	pellets = 4
	variance = 50
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
	//armor_flag = ENERGY //commented out until i can figure out a way for this to not block out ricochet
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
	e_cost = 300 //30
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
	e_cost = 600 //60
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
	e_cost = 500 //50
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
	e_cost = 1700 //170
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
	e_cost = 150 //15
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
	e_cost = 350 //35
	harmful = TRUE

/obj/projectile/lawbringer/pulse
	name = "compressed air"
	icon_state = "chronobolt"
	damage = 0
	damage_type = BRUTE

/obj/projectile/lawbringer/pulse/on_hit(mob/living/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
		target.throw_at(throw_target, 4, 1)


/obj/item/ammo_casing/energy/lawbringer/tideshot
	projectile_type = /obj/projectile/lawbringer/tideshot
	fire_sound = 'sound/weapons/laser.ogg'
	select_name = "tideshot"
	e_cost = 250 //25
	harmful = FALSE

/obj/projectile/lawbringer/tideshot
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
				to_chat(target, span_warning("As the beam hits you, body seems to crumple under its uselessness."))
				SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
				playsound(src, 'sound/weapons/taserhit.ogg', 80, TRUE, -1)
				C.stamina.adjust(-100)
				C.Paralyze(10 SECONDS)
				C.set_jitter_if_lower(40 SECONDS)
				C.set_stutter(40 SECONDS)

#undef DETAIN
#undef EXECUTE
#undef HOTSHOT
#undef SMOKESHOT
#undef BIGSHOT
#undef CLOWNSHOT
#undef PULSE
#undef TIDESHOT
