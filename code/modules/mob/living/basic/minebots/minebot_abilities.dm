
/datum/action/cooldown/mob_cooldown/minedrone
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/cooldown/mob_cooldown/minedrone/Activate()
	owner.set_light_on(!owner.light_on)
	owner.balloon_alert(owner, "lights [owner.light_on ? "on" : "off"]!")

/datum/action/cooldown/mob_cooldown/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/cooldown/mob_cooldown/minedrone/dump_ore/IsAvailable(feedback = TRUE)
	if(locate(/obj/item/stack/ore) in owner.contents)
		return TRUE

	if(feedback)
		owner.balloon_alert(owner, "no ore!")
	return FALSE

/datum/action/cooldown/mob_cooldown/minedrone/dump_ore/Activate()
	var/mob/living/basic/mining_drone/user = owner
	user.drop_ore()

/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	button_icon_state = "meson"

/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision/Activate()
	if(owner.sight & SEE_TURFS)
		owner.clear_sight(SEE_TURFS)
		owner.lighting_cutoff_red += 5
		owner.lighting_cutoff_green += 15
		owner.lighting_cutoff_blue += 5
	else
		owner.add_sight(SEE_TURFS)
		owner.lighting_cutoff_red -= 5
		owner.lighting_cutoff_green -= 15
		owner.lighting_cutoff_blue -= 5

	owner.sync_lighting_plane_cutoff()

	to_chat(owner, span_notice("You toggle your meson vision [(owner.sight & SEE_TURFS) ? "on" : "off"]."))

/datum/action/cooldown/mob_cooldown/missile_launcher
	name = "Launch Missile"
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "84mm-heap"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	desc = "Launch a missile towards the target!"
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE
	///how long before we launch said missile
	var/wind_up_timer = 1 SECONDS

/datum/action/cooldown/mob_cooldown/missile_launcher/IsAvailable(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(lavaland_equipment_pressure_check(get_turf(owner)))
		return TRUE
	if(feedback)
		owner.balloon_alert(owner, "cant be used here!")
	return FALSE

/datum/action/cooldown/mob_cooldown/missile_launcher/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf) || !can_see(owner, target_turf, 7))
		return FALSE
	owner.Shake(duration = wind_up_timer)
	addtimer(CALLBACK(src, PROC_REF(launch_missile), target_turf), wind_up_timer)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/missile_launcher/proc/launch_missile(turf/target_turf)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))
	var/obj/effect/temp_visual/rising_rocket/new_rocket = new(get_turf(owner))
	addtimer(CALLBACK(src, PROC_REF(drop_missile), target_turf), new_rocket.duration)

/datum/action/cooldown/mob_cooldown/missile_launcher/proc/drop_missile(turf/target_turf)
	new /obj/effect/temp_visual/falling_rocket(target_turf)
	var/obj/effect/temp_visual/falling_shadow = new /obj/effect/temp_visual/shadow_telegraph(target_turf)
	animate(falling_shadow, transform = matrix().Scale(0.1, 0.1), time = falling_shadow.duration)

/datum/action/cooldown/mob_cooldown/drop_landmine
	name = "Landmine"
	desc = "Drop a landmine!"
	button_icon = 'icons/obj/weapons/grenade.dmi'
	button_icon_state = "landmine"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/drop_landmine/IsAvailable(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(lavaland_equipment_pressure_check(get_turf(owner)))
		return TRUE
	if(feedback)
		owner.balloon_alert(owner, "cant be used here!")
	return FALSE

/datum/action/cooldown/mob_cooldown/drop_landmine/Activate(atom/target)
	var/turf/my_turf = get_turf(owner)
	if(isgroundlessturf(my_turf))
		return FALSE
	var/obj/effect/mine/minebot/my_mine = new(my_turf)
	my_mine.ignore_list = owner.faction.Copy()
	playsound(my_turf, 'sound/items/weapons/armbomb.ogg', 20)
	StartCooldown()
	return TRUE

/obj/effect/temp_visual/rising_rocket
	name = "Missile"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "84mm-heap"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 2 SECONDS

/obj/effect/temp_visual/rising_rocket/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/items/weapons/minebot_rocket.ogg', 100, FALSE)
	animate(src, pixel_y = base_pixel_y + 500, time = duration, easing = EASE_IN)

/obj/effect/temp_visual/falling_rocket
	name = "Missile"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "84mm-heap"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 0.7 SECONDS
	pixel_y = 60
	///the radius of our explosion
	var/explosion_radius = 2
	///damage of our explosion
	var/explosion_damage = 100

/obj/effect/temp_visual/falling_rocket/Initialize(mapload)
	. = ..()
	transform = transform.Turn(180)
	addtimer(CALLBACK(src, PROC_REF(create_explosion)), duration)
	animate(src, pixel_y = 0, time = duration)

/obj/effect/temp_visual/falling_rocket/proc/create_explosion()
	playsound(src, 'sound/items/weapons/minebot_rocket.ogg', 100, FALSE)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(1, holder = src)
	smoke.start()
	for(var/mob/living/living_target in oview(explosion_radius, src))
		if(living_target.incorporeal_move)
			continue
		living_target.apply_damage(explosion_damage)

/obj/effect/mine/minebot
	name = "Landmine"
	///we dont detonate if any of these people step on us
	var/list/ignore_list = list()
	///the damage we apply to whoever steps on us
	var/damage_to_apply = 50

/obj/effect/mine/minebot/mineEffect(mob/living/victim)
	if(!istype(victim))
		return
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src)
	smoke.start()
	playsound(src, 'sound/effects/explosion/explosion3.ogg', 100)
	victim.apply_damage(damage_to_apply)

/obj/effect/mine/minebot/can_trigger(atom/movable/on_who)
	if(REF(on_who) in ignore_list)
		return FALSE
	if(!isliving(on_who))
		return ..()
	var/mob/living/stepped_mob = on_who
	if(FACTION_NEUTRAL in stepped_mob.faction)
		return FALSE
	return ..()
