#define SPIDER_WEB_TINT	"web_colour_tint"

/obj/structure/spider
	name = "web"
	icon = 'icons/effects/web.dmi'
	desc = "It's stringy and sticky."
	anchored = TRUE
	density = FALSE
	max_integrity = 15

/obj/structure/spider/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/spider/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 1.25
			if(BRUTE)
				damage_amount *= 0.25
	return ..()

/obj/structure/spider/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 350

/obj/structure/spider/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	plane = FLOOR_PLANE
	layer = MID_TURF_LAYER
	icon = 'icons/obj/smooth_structures/stickyweb.dmi'
	base_icon_state = "stickyweb"
	icon_state = "stickyweb-0"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SPIDER_WEB
	canSmoothWith = SMOOTH_GROUP_SPIDER_WEB + SMOOTH_GROUP_WALLS
	///Whether or not the web is from the genetics power
	var/genetic = FALSE
	///Whether or not the web is a sealed web
	var/sealed = FALSE
	///Do we need to offset this based on a sprite frill?
	var/has_frill = TRUE
	/// Chance that someone will get stuck when trying to cross this tile
	var/stuck_chance = 50
	/// Chance that a bullet will hit this instead of flying through it
	var/projectile_stuck_chance = 30

/obj/structure/spider/stickyweb/Initialize(mapload)
	// Offset on init so that they look nice in the map editor
	if (has_frill)
		pixel_x = -9
		pixel_y = -9
	return ..()

/obj/structure/spider/stickyweb/attack_hand(mob/user, list/modifiers)
	.= ..()
	if(.)
		return
	if(!HAS_TRAIT(user, TRAIT_WEB_WEAVER))
		return
	loc.balloon_alert_to_viewers("weaving...")
	if(!do_after(user, 2 SECONDS))
		loc.balloon_alert(user, "interrupted!")
		return
	qdel(src)
	var/obj/item/stack/sheet/cloth/woven_cloth = new /obj/item/stack/sheet/cloth
	user.put_in_hands(woven_cloth)

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(genetic)
		return
	if(sealed)
		return FALSE
	if(isliving(mover))
		if(HAS_TRAIT(mover, TRAIT_WEB_SURFER))
			return TRUE
		if(mover.pulledby && HAS_TRAIT(mover.pulledby, TRAIT_WEB_SURFER))
			return TRUE
		if(prob(stuck_chance))
			stuck_react(mover)
			return FALSE
		return .
	if(isprojectile(mover))
		return prob(projectile_stuck_chance)
	return .

/// Show some feedback when you can't pass through something
/obj/structure/spider/stickyweb/proc/stuck_react(atom/movable/stuck_guy)
	loc.balloon_alert(stuck_guy, "stuck in web!")
	stuck_guy.Shake(duration = 0.1 SECONDS)

/// Web made by geneticists, needs special handling to allow them to pass through their own webs
/obj/structure/spider/stickyweb/genetic
	genetic = TRUE
	desc = "It's stringy, sticky, and came out of your coworker."
	/// Mob with special permission to cross this web
	var/mob/living/allowed_mob

/obj/structure/spider/stickyweb/genetic/Initialize(mapload, allowedmob)
	. = ..()
	// Tint it purple so that spiders don't get confused about why they can't cross this one
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ffaaf8ff", "size" = 0.1))

/obj/structure/spider/stickyweb/genetic/Initialize(mapload, allowedmob)
	allowed_mob = allowedmob
	return ..()

/obj/structure/spider/stickyweb/genetic/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == allowed_mob)
		return TRUE
	else if(isliving(mover)) //we change the spider to not be able to go through here
		if(mover.pulledby == allowed_mob)
			return TRUE
		if(prob(50))
			stuck_react(mover)
			return FALSE
	else if(isprojectile(mover))
		return prob(30)
	return .

/// Web with a 100% chance to intercept movement
/obj/structure/spider/stickyweb/very_sticky
	max_integrity = 20
	desc = "Extremely sticky silk, you're not easily getting through there."
	stuck_chance = 100
	projectile_stuck_chance = 100

/obj/structure/spider/stickyweb/very_sticky/Initialize(mapload)
	. = ..()
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ffffaaff", "size" = 0.1))

/obj/structure/spider/stickyweb/very_sticky/update_overlays()
	. = ..()
	var/mutable_appearance/web_overlay = mutable_appearance(icon = 'icons/effects/web.dmi', icon_state = "sticky_overlay", layer = layer + 1)
	web_overlay.pixel_x -= pixel_x
	web_overlay.pixel_y -= pixel_y
	. += web_overlay


/// Web 'wall'
/obj/structure/spider/stickyweb/sealed
	name = "sealed web"
	desc = "A solid wall of web, dense enough to block air flow."
	icon = 'icons/obj/smooth_structures/webwall.dmi'
	base_icon_state = "webwall"
	icon_state = "webwall-0"
	smoothing_groups = SMOOTH_GROUP_SPIDER_WEB_WALL
	canSmoothWith = SMOOTH_GROUP_SPIDER_WEB_WALL
	plane = GAME_PLANE
	layer = OBJ_LAYER
	sealed = TRUE
	has_frill = FALSE
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/spider/stickyweb/sealed/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

/// Walls which reflects lasers
/obj/structure/spider/stickyweb/sealed/reflector
	name = "reflective silk screen"
	desc = "Hardened webbing treated with special chemicals which cause it to repel projectiles."
	icon = 'icons/obj/smooth_structures/webwall_reflector.dmi'
	base_icon_state = "webwall_reflector"
	icon_state = "webwall_reflector-0"
	smoothing_groups = SMOOTH_GROUP_SPIDER_WEB_WALL_MIRROR
	canSmoothWith = SMOOTH_GROUP_SPIDER_WEB_WALL_MIRROR
	max_integrity = 30
	opacity = TRUE
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD
	receive_ricochet_chance_mod = INFINITY

/// Opaque and durable web 'wall'
/obj/structure/spider/stickyweb/sealed/tough
	name = "hardened web"
	desc = "Webbing hardened through a chemical process into a durable barrier."
	icon = 'icons/obj/smooth_structures/webwall_dark.dmi'
	base_icon_state = "webwall_dark"
	icon_state = "webwall_dark-0"
	smoothing_groups = SMOOTH_GROUP_SPIDER_WEB_WALL_TOUGH
	canSmoothWith = SMOOTH_GROUP_SPIDER_WEB_WALL_TOUGH
	opacity = TRUE
	max_integrity = 90
	layer = ABOVE_MOB_LAYER
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/// Web 'door', blocks atmos but not movement
/obj/structure/spider/passage
	name = "web passage"
	desc = "An opaque curtain of web which seals in air but doesn't impede passage."
	icon = 'icons/obj/smooth_structures/stickyweb_rotated.dmi'
	base_icon_state = "stickyweb_rotated"
	icon_state = "stickyweb_rotated-0"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SPIDER_WEB_ROOF
	canSmoothWith = SMOOTH_GROUP_SPIDER_WEB_ROOF + SMOOTH_GROUP_WALLS
	can_atmos_pass = ATMOS_PASS_NO
	opacity = TRUE
	max_integrity = 60
	alpha = 200
	layer = ABOVE_MOB_LAYER
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/obj/structure/spider/passage/Initialize(mapload)
	. = ..()
	pixel_x = -9
	pixel_y = -9
	air_update_turf(TRUE, TRUE)
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ffffffff", "alpha" = 0.8, "size" = 0.1))

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	icon_state = pick("cocoon1","cocoon2","cocoon3")
	. = ..()

/obj/structure/spider/cocoon/container_resist_act(mob/living/user)
	var/breakout_time = 600
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, span_notice("You struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)"))
	visible_message(span_notice("You see something struggling and writhing in \the [src]!"))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message(span_warning("\The [src] splits open."))
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()

/// Web caltrops
/obj/structure/spider/spikes
	name = "web spikes"
	desc = "Silk hardened into small yet deadly spikes."
	plane = FLOOR_PLANE
	layer = MID_TURF_LAYER
	icon = 'icons/obj/smooth_structures/stickyweb_spikes.dmi'
	base_icon_state = "stickyweb_spikes"
	icon_state = "stickyweb_spikes-0"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SPIDER_WEB
	canSmoothWith = SMOOTH_GROUP_SPIDER_WEB + SMOOTH_GROUP_WALLS
	max_integrity = 40

/obj/structure/spider/spikes/Initialize(mapload)
	. = ..()
	pixel_x = -9
	pixel_y = -9
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ac0000ff", "size" = 0.1))
	AddComponent(/datum/component/caltrop, min_damage = 20, max_damage = 30, flags = CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

/obj/structure/spider/effigy
	name = "web effigy"
	desc = "A giant spider! Fortunately, this one is just a statue of hardened webbing."
	icon_state = "effigy"
	max_integrity = 125
	density = TRUE
	anchored = FALSE

/obj/structure/spider/effigy/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/temporary_atom, 1 MINUTES)

#undef SPIDER_WEB_TINT
