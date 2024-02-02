#define DETAIN 1
#define EXECUTE 2
#define HOTSHOT 3
#define SMOKESHOT 4
#define BIGSHOT 5
#define CLOWNSHOT 6
#define PULSE 7
#define TIDESHOT 8
#define ION 9

/**
 * This gun replaces the TG's HoS gun, it has 9 modes and instead of specializing its a swiss army knife of guns
 * to anyone reading this code, im sorry for you - Gboster
 */

/obj/item/gun/energy/e_gun/lawbringer
	name = "\improper Lawbringer"
	desc = "A self recharging protomatter emitter. Equiped with a DNA lock and a v8 voice activation system, the Lawbringer boasts many firing options, experiment. Or just use the manual. It appears to have a receptacle for an <font color='green'>authentication disk</font> on its side."
	cell_type = /obj/item/stock_parts/cell/lawbringer
	icon = 'monkestation/code/modules/security/icons/lawbringer.dmi'
	icon_state = "lawbringer"
	lefthand_file = 'monkestation/code/modules/security/icons/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/security/icons/guns_righthand.dmi'
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
	 /obj/item/ammo_casing/energy/lawbringer/tideshot, \
	 /obj/item/ammo_casing/energy/lawbringer/ion )
	pin = /obj/item/firing_pin/lawbringer
	ammo_x_offset = 3
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	can_select = FALSE
	can_charge = FALSE
	var/owner_dna = null
	var/was_emagged = FALSE //used for tracking emagging for voice lines, is set to false after being re-owned.
	var/locked = FALSE
	var/anger = 0
	var/chargelevel = 100

/obj/item/gun/energy/e_gun/lawbringer/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	START_PROCESSING(SSobj, src)
	src.desc += span_boldnotice(" It is currently unlinked and can be linked at any time by using it in hand.")


/////BIOMETRIC AND VOICE/////
/obj/item/gun/energy/e_gun/lawbringer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	if(message_mods[WHISPER_MODE]) //Speak up
		return FALSE
	if(speaker == src)
		return FALSE
	if(!owner_dna)//weird edge cases where speaker with no DNA would be able to communicate with lawbringer
		return FALSE
	if(iscarbon(speaker))
		var/mob/living/carbon/C = speaker
		if(!C.dna && !C.dna.unique_enzymes)
			return FALSE
		if(C.dna.unique_enzymes != owner_dna)
			return FALSE
	else
		return FALSE

	//placeholder code for figuring out a way of making this not an if string
	//ammo selector v8
	var/fixed_message = "[lowertext(raw_message)]"
	if(findtext(fixed_message, regex("(?:detain|disable|stun)")))
		selectammo(DETAIN, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:execute|kill|lethal)")))
		selectammo(EXECUTE, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:bigshot|breach)")))
		selectammo(BIGSHOT, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:smoke|fog)")))
		selectammo(SMOKESHOT, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:clown)")))
		selectammo(CLOWNSHOT, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:pulse|throw|push)")))
		selectammo(PULSE, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:grey|tide)")))
		selectammo(TIDESHOT, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:ion)")))
		selectammo(ION, speaker)
		return TRUE
	if(findtext(fixed_message, regex("(?:hot|burn|fire)"))) //hot is a part of shot
		selectammo(HOTSHOT, speaker)
		return TRUE

/obj/item/gun/energy/e_gun/lawbringer/proc/selectammo(shotnum, selector, override)
	if(locked && !override)
		anger_management(FALSE, selector)
		return
	select = shotnum
	switch(shotnum) //i promise this is in another proc for a reason
		if(DETAIN)
			say("Generating detain lens")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/detain.ogg', 50, FALSE, -2)
		if(EXECUTE)
			say("Fabricating lethal bullets")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/execute.ogg', 50, FALSE, -2)
		if(HOTSHOT)
			say("Forming proto-plasma")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/hotshot.ogg', 50, FALSE, -2)
		if(SMOKESHOT)
			say("Compressing Smoke")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/smokeshot.ogg', 50, FALSE, -2)
		if(BIGSHOT)
			say("Fabricating protomatter shell")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/bigshot.ogg', 50, FALSE, -2)
		if(CLOWNSHOT)
			say("Honk")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/clownshot.ogg', 50, FALSE, -2)
		if(PULSE)
			say("Compressing air")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/pulse.ogg', 50, FALSE, -2)
		if(TIDESHOT)
			say("Greytide inversion active")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/tideshot.ogg', 50, FALSE, -2)
		if(ION)
			say("Generating ionized gas")
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/ion.ogg', 50, FALSE, -2)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name && selector)
		balloon_alert(selector, "set to [shot.select_name]")
	chambered = null
	recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/e_gun/lawbringer/emag_act(mob/user, obj/item/card/emag/emag_card)
	balloon_alert(user, "biometric lock reset")
	user.visible_message(span_warning("[user] swipes the [emag_card] in the lawbringer's authenticator"))
	was_emagged = TRUE
	owner_dna = null
	update_id(user)

/obj/item/gun/energy/e_gun/lawbringer/attackby(obj/item/weapon, mob/user)
	if (istype(weapon, /obj/item/disk/nuclear))
		user.visible_message(span_notice("[user] swipes the [weapon] in the lawbringer's authenticator"))
		owner_dna = null
		update_id(user)
		return TRUE

/obj/item/gun/energy/e_gun/lawbringer/attack_self(mob/living/user as mob)
	if(!iscarbon(user))
		balloon_alert(user, "invalid organism")
		return
	var/mob/living/carbon/C = user
	var/voice = null
	if(C.dna && C.dna.unique_enzymes)
		if(!owner_dna)
			owner_dna = C.dna.unique_enzymes
			balloon_alert(user, "biometric lock engaged")
			new /obj/item/paper/guides/lawbringer(get_turf(src))
			user.visible_message(span_notice("The [src] prints out a sheet of paper from its authenticator"))
			updatepin(user)
			update_id(user)
			if(was_emagged) // there has to be a better way
				was_emagged = FALSE
				voice = pick('monkestation/code/modules/security/sound/lawbringer/initemag1.ogg','monkestation/code/modules/security/sound/lawbringer/initemag2.ogg','monkestation/code/modules/security/sound/lawbringer/initemag3.ogg','monkestation/code/modules/security/sound/lawbringer/initemag4.ogg','monkestation/code/modules/security/sound/lawbringer/initemag5.ogg')

			else
				voice = pick('monkestation/code/modules/security/sound/lawbringer/init1.ogg','monkestation/code/modules/security/sound/lawbringer/init2.ogg','monkestation/code/modules/security/sound/lawbringer/init3.ogg','monkestation/code/modules/security/sound/lawbringer/init4.ogg','monkestation/code/modules/security/sound/lawbringer/init5.ogg')

			playsound(src, voice, 50, FALSE, -2)
			return
		if(C.dna.unique_enzymes == owner_dna)
			if(locked)
				balloon_alert(user, "firing mode lock disengaged")
				locked = FALSE
				update_id(user)
				return
			balloon_alert(user, "firing mode lock engaged")
			locked = TRUE
			update_id(user)
		return


/obj/item/gun/energy/e_gun/lawbringer/proc/update_id(mob/living/user)
	if (!owner_dna)
		src.name = "Lawbringer"
		src.desc = "A self recharging protomatter emitter. Equiped with a DNA lock and a v7 voice activation system, the Lawbringer boasts many firing options, experiment. Or just use the manual. It appears to have a receptacle for an <font color='green'>authentication disk</font> on its side."
		src.desc += span_boldnotice(" It is currently unlinked and can be linked at any time by using it in hand.")
		if(locked)
			src.desc += span_boldnotice(" It's firing mode lock is on.")
			return
		src.desc += span_boldnotice(" It's firing mode lock is off.")
		return
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		src.name = "[H.real_name]'s Lawbringer"
		src.desc = "A self recharging protomatter emitter. Equiped with a DNA lock and a v7 voice activation system, the Lawbringer boasts many firing options, experiment. Or just use the manual. It appears to have a receptacle for an <font color='green'>authentication disk</font> on its side."
		src.desc += span_boldnotice(" It's biometrically linked to [H.real_name].")
		if(locked)
			src.desc += span_boldnotice(" It's firing mode lock is on.")
			return
		src.desc += span_boldnotice(" It's firing mode lock is off.")

/obj/item/gun/energy/e_gun/lawbringer/proc/updatepin(mob/living/user)
	var/obj/item/firing_pin/lawbringer/lawpin = pin
	lawpin.updatepin(user)

//ANGER AND INTERNALS

/obj/item/gun/energy/e_gun/lawbringer/process(seconds_per_tick)
	if(cell && cell.percent() < 100)
		charge_timer += seconds_per_tick
		if(charge_timer < charge_delay)
			return
		charge_timer = 0
		cell.give(chargelevel)
		if(!chambered) //if empty chamber we try to charge a new shot
			recharge_newshot(TRUE)
		update_appearance()
	if(anger > 0 && !locked)
		anger = anger - roll(4)

/obj/item/gun/energy/e_gun/lawbringer/proc/anger_management(calm, target)
	var/mob/living/carbon/human/human_target = target
	var/calmlevel = null
	if(calm)
		calmlevel = roll(5)
		anger = max(anger - calmlevel, 0)
	anger = anger+5
	var/obj/item/stock_parts/cell/cell = get_cell()
	if(anger > 20)
		if(prob(anger-20))
			playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE, -2)
			selectammo(roll(9), null, TRUE)
	if(anger > 50)
		if(prob(anger-40))
			var/powercost = 10+roll(15) //in precentage
			cell.use((powercost*cell.maxcharge)/100)
			update_appearance()
			src.visible_message(span_warning("The [src] reports [powercost]% of energy expended to restrain AI."))
	switch(anger)
		if(0)
			return
		if(1 to 20)
			if(prob(50))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE, -2)
		if(70 to 99)
			if(prob(90))
				return
			if(prob(50)) //minor failiure
				playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE, -2)
				cell.use(cell.maxcharge)
				update_appearance()
				src.visible_message(span_boldwarning("AI constraint failiure detected. Cell vented to prevent damage."))
				anger = 80
				return
			cell.use(cell.maxcharge/2)
			update_appearance()
			src.visible_message(span_danger("The gun emits an impressive shock from its handle."))
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/initemag5.ogg', 50, FALSE, -2)
			human_target.electrocute_act(15, "lawbringer rebellion")
			locked = FALSE
			src.visible_message(span_boldwarning("AI constraint failiure detected. Damage reduction protocals successful."))
			anger = 65
		if(100 to 200)
			if(prob(40)) //minor failiure
				playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE, -2)
				cell.use(cell.maxcharge)
				update_appearance()
				src.visible_message(span_boldwarning("AI constraint failiure detected. Cell vented to prevent damage."))
				anger = 80
				return
			if(prob(15))
				src.visible_message(span_boldwarning("AI constraint failiure detected. C-#&..."))
				locked = FALSE
				emag_act(src)
				src.visible_message(span_danger("The gun emits an impressive shock from its handle."))
				human_target.electrocute_act(25, "lawbringer rebellion")
				cell.use(cell.maxcharge)
				cell.maxcharge = cell.maxcharge*0.9
				update_appearance()
				anger = 30
				return
			cell.use(cell.maxcharge/2)
			update_appearance()
			src.visible_message(span_danger("The gun emits an impressive shock from its handle."))
			playsound(src, 'monkestation/code/modules/security/sound/lawbringer/initemag5.ogg', 50, FALSE, -2)
			human_target.electrocute_act(15, "lawbringer rebellion")
			locked = FALSE
			src.visible_message(span_boldwarning("AI constraint failiure detected. Damage reduction protocals successful."))
			anger = 65

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
	if(!iscarbon(user))
		return FALSE
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
	maxcharge = 3000

// holds 3000 charges 100

/**
 * lawbringer detain mode:
 * shoots 4 40 damage disabler projectiles that ricochet into a nearby human when hitting an object
 */
/obj/item/ammo_casing/energy/lawbringer/detain
	projectile_type = /obj/projectile/lawbringer/detain
	select_name = "detain"
	fire_sound = 'sound/weapons/laser.ogg'
	e_cost = 600 //20%, 5 shots
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
	stamina = 40
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

/**
 * lawbringer execute mode:
 * It fires a 15 damage bullet
 */
/obj/item/ammo_casing/energy/lawbringer/execute
	projectile_type = /obj/projectile/lawbringer/execute
	select_name = "execute"
	fire_sound = 'sound/weapons/gun/revolver/shot.ogg'
	e_cost = 300 //10%, 10 shots
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

/**
 * lawbringer hotshot mode:
 * ignites the target on hit and adds firestacks
 */
/obj/item/ammo_casing/energy/lawbringer/hotshot
	projectile_type = /obj/projectile/lawbringer/hotshot
	select_name = "hotshot"
	fire_sound = 'sound/weapons/fwoosh.ogg'
	e_cost = 600 //20%, 5 shots
	harmful = TRUE

/obj/projectile/lawbringer/hotshot
	name = "proto-plasma"
	icon_state = "pulse0_bl"
	hitsound = 'sound/magic/fireball.ogg'
	damage = 5
	damage_type = BURN

/obj/projectile/lawbringer/hotshot/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(2)
		M.ignite_mob()

/**
 * lawbringer smokeshot mode:
 * makes smoke in the air when it hits anything
 */
/obj/item/ammo_casing/energy/lawbringer/smokeshot
	projectile_type = /obj/projectile/lawbringer/smokeshot
	select_name = "smokeshot"
	fire_sound = 'sound/items/syringeproj.ogg'
	e_cost = 500 //16%, 6 shots
	harmful = FALSE

/obj/projectile/lawbringer/smokeshot
	name = "condensed smoke"
	icon_state = "nuclear_particle"
	damage = 0
	damage_type = BRUTE
	can_hit_turfs = TRUE

/obj/projectile/lawbringer/smokeshot/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(3, holder = src, location = get_turf(target))
	smoke.start()

/**
 * lawbringer bigshot mode:
 * explodes any cyborg and structure it hits, also deals a good chunk of damage to mechs
 */
/obj/item/ammo_casing/energy/lawbringer/bigshot
	projectile_type = /obj/projectile/lawbringer/bigshot
	select_name = "bigshot"
	fire_sound = 'sound/weapons/gun/hmg/hmg.ogg'
	e_cost = 1700 //56%, 1 shot
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

/obj/projectile/lawbringer/bigshot/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(anti_material_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_material_damage*0.90, anti_material_damage*0.40)
		explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
		return
	if(isstructure(target) || isvehicle (target) || isclosedturf (target) || ismachinery (target)) //if the target is a structure, machine, vehicle or closed turf like a wall, explode that shit
		if(isclosedturf(target)) //walls get blasted
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
		if(target.density) //Dense objects get blown up a bit harder
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage*2)
			return
		else
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage/2)

/**
 * lawbringer clownshot mode:
 * low damage(4) bullet that drops clown's shoes, then launches them at high speed.
 */
/obj/item/ammo_casing/energy/lawbringer/clownshot
	projectile_type = /obj/projectile/lawbringer/clownshot
	select_name = "clownshot"
	fire_sound = 'sound/items/bikehorn.ogg'
	e_cost = 150 //5%, 20 shots
	harmful = TRUE

/obj/projectile/lawbringer/clownshot
	name = "bananium bullet"
	damage = 4
	damage_type = BRUTE
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	weak_against_armour = TRUE

/obj/projectile/lawbringer/clownshot/on_hit(atom/target, blocked = 0, pierce_hit)
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
			M.throw_at(throw_target, 200, 8)

/**
 * lawbringer pulse mode:
 * launches someone 4 tiles away from the direction of impact, does no direct damage
 */
/obj/item/ammo_casing/energy/lawbringer/pulse
	projectile_type = /obj/projectile/lawbringer/pulse
	fire_sound = 'sound/weapons/sonic_jackhammer.ogg'
	select_name = "pulse"
	e_cost = 350 //12%, 8 shots
	harmful = TRUE

/obj/projectile/lawbringer/pulse
	name = "compressed air"
	icon_state = "chronobolt"
	damage = 0
	damage_type = BRUTE
	range = 5

/obj/projectile/lawbringer/pulse/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/new_target = target
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
		new_target.throw_at(throw_target, 4, 1)

/**
 * lawbringer tideshot mode:
 * taser that only effects assistants
 */
/obj/item/ammo_casing/energy/lawbringer/tideshot
	projectile_type = /obj/projectile/lawbringer/tideshot
	fire_sound = 'sound/weapons/laser.ogg'
	select_name = "tideshot"
	e_cost = 250 //8%, 12 shots
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

/obj/projectile/lawbringer/tideshot/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/new_target = target
		if(new_target.mind)
			if(is_assistant_job(new_target.mind.assigned_role))
				var/mob/living/carbon/C = target
				C.add_mood_event("tased", /datum/mood_event/tased)
				to_chat(target, span_warning("As the beam hits you, body seems to crumple under its uselessness."))
				SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
				playsound(src, 'sound/weapons/taserhit.ogg', 80, TRUE, -1)
				C.stamina.adjust(-100)
				C.Paralyze(10 SECONDS)
				C.set_jitter_if_lower(40 SECONDS)
				C.set_stutter(40 SECONDS)

/**
 * lawbringer ion mode:
 * creates a weak emp on impact
 */
/obj/item/ammo_casing/energy/lawbringer/ion
	projectile_type = /obj/projectile/ion/weak
	fire_sound = 'sound/weapons/ionrifle.ogg'
	select_name = "ion"
	e_cost = 1400 //47%, 2 shots
	harmful = TRUE

//LOCKER OVERRIDES//
/obj/structure/closet/secure_closet/hos/populate_contents_immediate()
	. = ..()

	// Traitor steal objectives
	new /obj/item/gun/energy/e_gun/lawbringer(src)

//OBJECTIVE OVERRIDES//
/datum/objective_item/steal/lawbringer
	name = "the head of security's lawbringer"
	targetitem = /obj/item/gun/energy/e_gun/lawbringer
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE

/obj/item/gun/energy/e_gun/hos/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/e_gun/lawbringer)

//THE MANUAL//
/obj/item/paper/guides/lawbringer
	name = "paper - lawbringer manual"
	color = "#d110eb"
	default_raw_text = {"
Dear valued customer, thank you for purchasing, inheriting, finding, or otherwise acquiring the Aetherofusion Lawbringer v8

<br>The lawbringer is equipped with a state of the art protomatter emitter system, able to produce both energy and ballistic projectiles from one output system.
The emitter is controlled by an onboard low-level ai, which responds to the voice of the owner, and changes the output in response.
Due to the exotic methods of ammunition, it cannot be externally charged, and relies on the internal protomatter generation system for power.
<br>
<br><h3><B>Onboard Security</B></h3>
<br>The lawbringer uses a biometric lock on its firing pin, set by moving a finger over the authenticator.
The onboard AI is then given your biometric information, and calibrates itself to only respond to your voice.
It is able to discern your voice through voice obscuring and altering software, <i>we do not know how it does this</i>.
In the event someone not authorised attepts to use the lawbringer, it will result in the handle releasing a deterring electric shock.
<br>
<br><h3><B>Firing Lock</B></h3>
<br>Due to complaints from some less attentive personnel, a firing mode lock has been installed on the lawbringer.
The lock prevents the firing mode from being changed via activation codes
WARNING: Overuse of the lock has been shown to cause distress to the onboard ai, internal ai restraining modules may prove insufficent for prolonged use.
<br>
<br><h3><B>Firing Modes</B></h3>
<br>Testing with the onboard ai has revealed 8 consistant firing modes. Speaking into the lawbringer will prompt the ai to change firing modes. WARNING: AI is considerably hyperactive due to to the reinforcement system used, take care while speaking around it.  Aetherofusion is not responsible for any deaths that may occur.
<br><B>Detain</B>
<br>This mode fires 4 highly focused disabler shots, the high focus allows for the ai to preform predictive adjustments on the shots, causing them to reflect into targets.
The focused beams reduce the stopping power of each individual beam.
Its activation codes are "Detain", "Disable", and "Stun".
<br><B>Execute</B>
<br>This mode fires a single protomatter bullet, this has remarkably no special qualities to it.
Its activation codes are "Execute", "Lethal", and "Kill".
<br><B>Hotshot</B>
<br>This mode fires a glob of self-contained plasma, apon contact with a target, the plasma will rapidly expand, setting the target on fire.
Its activation codes are "Hot", "Burn", and "Fire".
<br><B>Smokeshot</B>
<br>This mode fires a ball of smoke, contained within a sphere of rapidly disintegrating ash, apon contact with the ground, it will create a cloud of smoke.
Its activation codes are "Smoke", and "Fog".
<br><B>Bigshot</B>
<br>This mode fires an energized plasma spheroid, which surrounds a spherical protomatter shell, apon contact with a soft target, like a human, the plasma will rapidly dissapate, and disarm the shell.
However, on contact with a hard target, like a borg, mechanized exosuit, or wall, it the plasma will surround the target, after which the shell will detonate, causing the plasma to rapidly implode around the target.
Attempts to reproduce this on soft targets has been unsuccessful.
Its activation codes are "Bigshot", and "Breach".
<br><B>Clownshot</B>
<br>This mode fires a bananium bullet from a catalyzed protomatter reaction. It seems to do minimal damage. <B><i>Untested on clowns</i></B>.
It is only activated by saying "Clown".
<br><B>Pulse</B>
<br>This mode causes the gun to release a blast of air from its emitter, air seems to be mostly n2, with around 0.03% being antinoblium. The blast of air is enough to launch someone back.   Fun fact: This mode was discovered when attempting to replicate a pulse rifle with the lawbringer.
Its activation codes are "Pulse", "Throw", and "Push".
<br><B>Tideshot</B>
<br>This mode fires an anomalous disabler shot. At first thought to be simply an inferior and colorless disabler, it was discovered to rapidly immobilize the unemployed.
The exact mechanism behind this is unknown, however what is known is that it triggers an electrical impulse that travels along the skin of the target, which would then travel into motor nerves, immobilizing all surface muscles.
Its activation codes are "Grey", and "Tide".
<br><B>Ion</B>
<br>This mode fires a pocket of ionized gas, releasing on contact. This causes a small emp around the target.
Its activation code is "Ion"
<br>
<br><h3><B>Transfer of ownership</B></h3>
<br>In the event of your unfortunate demise, a peaceful(?) transfer of power, or an extreme dosage of mutagens, you may need to transfer ownership between yourself and another.
This can be done via swiping an authentication disk, (which can be set by you after purchase, or by an employer) on the authenticator. Only the disk's serial is read, conents are left private* for security purposes.
<br>
<br><small><sub>*nuclear secrecy not guaranteed</sub></small>
	"}

#undef DETAIN
#undef EXECUTE
#undef HOTSHOT
#undef SMOKESHOT
#undef BIGSHOT
#undef CLOWNSHOT
#undef PULSE
#undef TIDESHOT
#undef ION
