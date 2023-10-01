//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	icon = 'icons/effects/effects.dmi'
	desc = "It's stringy and sticky."
	anchored = TRUE
	density = FALSE
	max_integrity = 15

/obj/structure/spider/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/spider/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 1.25
			if(BRUTE)
				damage_amount *= 0.25
	. = ..()

/obj/structure/spider/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 350

/obj/structure/spider/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	///Whether or not the web is from the genetics power
	var/genetic = FALSE
	///Whether or not the web is a sealed web
	var/sealed = FALSE
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/attack_hand(mob/user, list/modifiers)
	.= ..()
	if(.)
		return
	if(!HAS_TRAIT(user,TRAIT_WEB_WEAVER))
		return
	loc.balloon_alert_to_viewers("weaving...")
	if(!do_after(user, 2 SECONDS))
		loc.balloon_alert(user, "interrupted!")
		return
	qdel(src)
	var/obj/item/stack/sheet/cloth/woven_cloth = new /obj/item/stack/sheet/cloth
	user.put_in_hands(woven_cloth)

/obj/structure/spider/stickyweb/Initialize(mapload)
	if(!sealed && prob(50))
		icon_state = "stickyweb2"
	. = ..()

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
		if(prob(50))
			loc.balloon_alert(mover, "stuck in web!")
			return FALSE
	else if(isprojectile(mover))
		return prob(30)

/obj/structure/spider/stickyweb/sealed
	name = "sealed web"
	desc = "A solid thick wall of web, airtight enough to block air flow."
	icon_state = "sealedweb"
	sealed = TRUE
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/spider/stickyweb/sealed/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/structure/spider/stickyweb/genetic //for the spider genes in genetics
	genetic = TRUE
	var/mob/living/allowed_mob

/obj/structure/spider/stickyweb/genetic/Initialize(mapload, allowedmob)
	allowed_mob = allowedmob
	. = ..()

/obj/structure/spider/stickyweb/genetic/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..() //this is the normal spider web return aka a spider would make this TRUE
	if(mover == allowed_mob)
		return TRUE
	else if(isliving(mover)) //we change the spider to not be able to go through here
		if(mover.pulledby == allowed_mob)
			return TRUE
		if(prob(50))
			loc.balloon_alert(mover, "stuck in web!")
			return FALSE
	else if(isprojectile(mover))
		return prob(30)

/obj/structure/spider/solid
	name = "solid web"
	icon = 'icons/effects/effects.dmi'
	desc = "A solid wall of web, thick enough to block air flow."
	icon_state = "solidweb"
	can_atmos_pass = ATMOS_PASS_NO
	opacity = TRUE
	density = TRUE
	max_integrity = 90
	plane = GAME_PLANE_UPPER
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/obj/structure/spider/solid/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/structure/spider/passage
	name = "web passage"
	icon = 'icons/effects/effects.dmi'
	desc = "A messy connection of webs blocking the other side, but not solid enough to prevent passage."
	icon_state = "webpassage"
	can_atmos_pass = ATMOS_PASS_NO
	opacity = TRUE
	max_integrity = 60
	alpha = 200
	plane = GAME_PLANE_UPPER
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/obj/structure/spider/passage/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

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

/obj/structure/spider/sticky
	name = "sticky web"
	icon = 'icons/effects/effects.dmi'
	desc = "Extremely soft and sticky silk."
	icon_state = "verystickyweb"
	max_integrity = 20

/obj/structure/spider/sticky/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(HAS_TRAIT(mover, TRAIT_WEB_SURFER))
		return TRUE
	if(!isliving(mover))
		return
	if(!isnull(mover.pulledby) && HAS_TRAIT(mover.pulledby, TRAIT_WEB_SURFER))
		return TRUE
	loc.balloon_alert(mover, "stuck in web!")
	return FALSE

/obj/structure/spider/spikes
	name = "web spikes"
	icon = 'icons/effects/effects.dmi'
	desc = "Silk hardened into small yet deadly spikes."
	icon_state = "webspikes1"
	max_integrity = 40

/obj/structure/spider/spikes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 20, max_damage = 30, flags = CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

/obj/structure/spider/effigy
	name = "web effigy"
	icon = 'icons/effects/effects.dmi'
	desc = "A giant spider! Fortunately, this one is just a statue of hardened webbing."
	icon_state = "webcarcass"
	max_integrity = 125
	density = TRUE
	anchored = FALSE

/obj/structure/spider/effigy/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/temporary_atom, 1 MINUTES)
