GLOBAL_LIST_EMPTY(rockhill_gates)

/obj/structure/rockhill/gate
	var/base_state
	var/gid
	var/start_open = FALSE
	var/switching = FALSE
	var/list/obj/structure/rockhill/gate_filler/fillers

/obj/structure/rockhill/gate/preopen
	start_open = TRUE

/obj/structure/rockhill/gate/bars/preopen
	start_open = TRUE

/obj/structure/rockhill/gate/Initialize(mapload)
	. = ..()
	for(var/offset in 1 to ROCKHILL_GATE_WIDTH - 1)
		var/turf/beside = locate(x + offset, y, z)
		if(beside)
			LAZYADD(fillers, new /obj/structure/rockhill/gate_filler(beside, src))
	GLOB.rockhill_gates += src
	set_open(start_open)

/obj/structure/rockhill/gate/Destroy()
	GLOB.rockhill_gates -= src
	QDEL_LAZYLIST(fillers)
	return ..()

/obj/structure/rockhill/gate/update_icon_state()
	icon_state = "[base_state][density]"
	return ..()

/obj/structure/rockhill/gate/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[base_state][!density && !switching ? 0 : 1]_part", ABOVE_MOB_LAYER)

/obj/structure/rockhill/gate/proc/set_open(opened)
	set_density(!opened)
	set_opacity(opened ? FALSE : initial(opacity))
	for(var/obj/structure/rockhill/gate_filler/filler as anything in fillers)
		filler.set_density(density)
		filler.set_opacity(opacity)
	update_appearance()

/obj/structure/rockhill/gate/proc/toggle()
	if(density)
		open()
	else
		close()

/obj/structure/rockhill/gate/proc/open()
	if(switching || !density)
		return
	switching = TRUE
	playsound(src, 'modular_redtard/rockhill/sound/misc/gate.ogg', 100, extrarange = 5)
	flick("[base_state]_opening", src)
	addtimer(CALLBACK(src, PROC_REF(finish_open)), 1.5 SECONDS)

/obj/structure/rockhill/gate/proc/finish_open()
	switching = FALSE
	set_open(TRUE)

/obj/structure/rockhill/gate/proc/close()
	if(switching || density)
		return
	switching = TRUE
	update_appearance()
	layer = ABOVE_MOB_LAYER
	playsound(src, 'modular_redtard/rockhill/sound/misc/gate.ogg', 100, extrarange = 5)
	flick("[base_state]_closing", src)
	addtimer(CALLBACK(src, PROC_REF(finish_close)), 1 SECONDS)

/obj/structure/rockhill/gate/proc/finish_close()
	var/list/turf/span = list(loc)
	for(var/obj/structure/rockhill/gate_filler/filler as anything in fillers)
		span += filler.loc
	for(var/turf/under as anything in span)
		for(var/mob/living/victim in under)
			crush(victim)
	layer = initial(layer)
	switching = FALSE
	set_open(FALSE)

/obj/structure/rockhill/gate/proc/crush(mob/living/victim)
	var/zone = victim.body_position == STANDING_UP ? pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM) : BODY_ZONE_HEAD
	var/obj/item/bodypart/part = victim.get_bodypart(zone)
	victim.visible_message(span_boldwarning("[src] comes crashing down on [victim]'s [parse_zone(zone)]!"), span_userdanger("[src] crushes my [parse_zone(zone)]!"))
	victim.emote("scream")
	part?.force_wound_upwards(/datum/wound/blunt/bone/severe)
	victim.apply_damage(90, BRUTE, zone)
	victim.Paralyze(8 SECONDS)

/obj/structure/rockhill/gate_filler
	name = ""
	icon = null
	icon_state = null
	density = TRUE
	opacity = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	can_atmos_pass = ATMOS_PASS_DENSITY
	var/obj/structure/rockhill/gate/gate

/obj/structure/rockhill/gate_filler/Initialize(mapload, obj/structure/rockhill/gate/owner)
	. = ..()
	gate = owner

/obj/structure/rockhill/gate_filler/Destroy()
	if(gate)
		LAZYREMOVE(gate.fillers, src)
		gate = null
	return ..()

/obj/structure/rockhill/gate_filler/can_be_pulled(user, force)
	return FALSE

/obj/structure/rockhill/winch
	var/gid
	var/obj/structure/rockhill/gate/gate

/obj/structure/rockhill/winch/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/rockhill/winch/LateInitialize()
	if(!gid)
		return
	for(var/obj/structure/rockhill/gate/candidate as anything in GLOB.rockhill_gates)
		if(candidate.gid == gid)
			gate = candidate
			RegisterSignal(gate, COMSIG_QDELETING, PROC_REF(gate_gone))
			return

/obj/structure/rockhill/winch/Destroy()
	gate = null
	return ..()

/obj/structure/rockhill/winch/proc/gate_gone(datum/source)
	SIGNAL_HANDLER
	gate = null

/obj/structure/rockhill/winch/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(!gate)
		to_chat(user, span_warning("The chain is not attached to anything."))
		return TRUE
	if(gate.switching || DOING_INTERACTION_WITH_TARGET(user, src))
		return TRUE
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] cranks [src]."))
	playsound(src, 'modular_redtard/rockhill/sound/foley/winch.ogg', 100, extrarange = 3)
	if(do_after(user, crank_time(user), target = src) && gate && !gate.switching)
		gate.toggle()
	return TRUE
