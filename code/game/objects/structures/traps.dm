/obj/structure/trap
	name = "IT'S A TRAP"
	desc = "Stepping on me is a guaranteed bad day."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "trap"
	density = FALSE
	anchored = TRUE
	alpha = 30 //initially quite hidden when not "recharging"
	var/flare_message = "<span class='warning'>the trap flares brightly!</span>"
	var/last_trigger = 0
	var/time_between_triggers = 1 MINUTES
	var/charges = INFINITY
	var/antimagic_flags = MAGIC_RESISTANCE

	var/list/static/ignore_typecache
	var/list/mob/immune_minds = list()

	var/sparks = TRUE
	var/datum/effect_system/spark_spread/spark_system

/obj/structure/trap/Initialize(mapload)
	. = ..()
	flare_message = "<span class='warning'>[src] flares brightly!</span>"
	spark_system = new
	spark_system.set_up(4,1,src)
	spark_system.attach(src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(!ignore_typecache)
		ignore_typecache = typecacheof(list(
			/obj/effect,
			/mob/dead,
		))

/obj/structure/trap/Destroy()
	qdel(spark_system)
	spark_system = null
	. = ..()

/obj/structure/trap/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	if(user.mind && (user.mind in immune_minds))
		return
	if(get_dist(user, src) <= 1)
		. += span_notice("You reveal [src]!")
		flare()

/obj/structure/trap/proc/flare()
	// Makes the trap visible, and starts the cooldown until it's
	// able to be triggered again.
	visible_message(flare_message)
	if(sparks)
		spark_system.start()
	alpha = 200
	last_trigger = world.time
	charges--
	if(charges <= 0)
		animate(src, alpha = 0, time = 1 SECONDS)
		QDEL_IN(src, 1 SECONDS)
	else
		animate(src, alpha = initial(alpha), time = time_between_triggers)

/obj/structure/trap/proc/on_entered(datum/source, atom/movable/victim)
	SIGNAL_HANDLER
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(victim, ignore_typecache))
		return
	if(ismob(victim))
		var/mob/mob_victim = victim
		if(mob_victim.mind in immune_minds)
			return
		if(mob_victim.can_block_magic(antimagic_flags))
			flare()
			return
	if(charges <= 0)
		return
	flare()
	if(isliving(victim))
		trap_effect(victim)

/obj/structure/trap/proc/trap_effect(mob/living/victim)
	return

/obj/structure/trap/stun
	name = "shock trap"
	desc = "A trap that will shock and render you immobile. You'd better avoid it."
	icon_state = "trap-shock"
	var/stun_time = 10 SECONDS

/obj/structure/trap/stun/trap_effect(mob/living/victim)
	victim.electrocute_act(30, src, flags = SHOCK_NOGLOVES) // electrocute act does a message.
	victim.Paralyze(stun_time)

/obj/structure/trap/stun/hunter
	name = "bounty trap"
	desc = "A trap that only goes off when a fugitive steps on it, announcing the location and stunning the target. You'd better avoid it."
	icon = 'icons/obj/weapons/restraints.dmi'
	icon_state = "bounty_trap_on"
	stun_time = 20 SECONDS
	sparks = FALSE //the item version gives them off to prevent runtimes (see Destroy())
	antimagic_flags = NONE
	var/obj/item/bountytrap/stored_item
	var/caught = FALSE

/obj/structure/trap/stun/hunter/Initialize(mapload)
	. = ..()
	time_between_triggers = 1 SECONDS
	flare_message = "<span class='warning'>[src] snaps shut!</span>"

/obj/structure/trap/stun/hunter/Destroy()
	if(!QDELETED(stored_item))
		qdel(stored_item)
	stored_item = null
	return ..()

/obj/structure/trap/stun/hunter/on_entered(datum/source, atom/movable/victim)
	if(isliving(victim))
		var/mob/living/living_victim = victim
		if(!living_victim.mind?.has_antag_datum(/datum/antagonist/fugitive))
			return
	caught = TRUE
	. = ..()

/obj/structure/trap/stun/hunter/flare()
	..()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	stored_item.forceMove(get_turf(src))
	forceMove(stored_item)
	if(caught)
		stored_item.announce_fugitive()
		caught = FALSE

/obj/item/bountytrap
	name = "bounty trap"
	desc = "A trap that only goes off when a fugitive steps on it, announcing the location and stunning the target. It's currently inactive."
	icon = 'icons/obj/weapons/restraints.dmi'
	icon_state = "bounty_trap_off"
	var/obj/structure/trap/stun/hunter/stored_trap
	var/obj/item/radio/radio
	var/datum/effect_system/spark_spread/spark_system

/obj/item/bountytrap/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	spark_system = new
	spark_system.set_up(4,1,src)
	spark_system.attach(src)
	name = "[name] #[rand(1, 999)]"
	stored_trap = new(src)
	stored_trap.name = name
	stored_trap.stored_item = src

/obj/item/bountytrap/proc/announce_fugitive()
	spark_system.start()
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	radio.talk_into(src, "Fugitive has triggered this trap in the [get_area_name(src)]!", RADIO_CHANNEL_COMMON)

/obj/item/bountytrap/attack_self(mob/living/user)
	var/turf/target_turf = get_turf(src)
	if(!user || !user.transferItemToLoc(src, target_turf))//visibly unequips
		return
	to_chat(user, span_notice("You set up [src]. Examine while close to disarm it."))
	stored_trap.forceMove(target_turf)//moves trap to ground
	forceMove(stored_trap)//moves item into trap

/obj/item/bountytrap/Destroy()
	if(!QDELETED(stored_trap))
		qdel(stored_trap)
	stored_trap = null
	QDEL_NULL(radio)
	QDEL_NULL(spark_system)
	. = ..()

/obj/structure/trap/fire
	name = "flame trap"
	desc = "A trap that will set you ablaze. You'd better avoid it."
	icon_state = "trap-fire"

/obj/structure/trap/fire/trap_effect(mob/living/victim)
	to_chat(victim, span_danger("<B>Spontaneous combustion!</B>"))
	victim.Paralyze(2 SECONDS)
	new /obj/effect/hotspot(get_turf(src))

/obj/structure/trap/chill
	name = "frost trap"
	desc = "A trap that will chill you to the bone. You'd better avoid it."
	icon_state = "trap-frost"

/obj/structure/trap/chill/trap_effect(mob/living/victim)
	if(HAS_TRAIT(victim, TRAIT_RESISTCOLD))
		return
	to_chat(victim, span_bolddanger("You're frozen solid!"))
	victim.Paralyze(2 SECONDS)
	victim.adjust_bodytemperature(-300)
	victim.apply_status_effect(/datum/status_effect/freon)


/obj/structure/trap/damage
	name = "earth trap"
	desc = "A trap that will summon a small earthquake, just for you. You'd better avoid it."
	icon_state = "trap-earth"


/obj/structure/trap/damage/trap_effect(mob/living/victim)
	to_chat(victim, span_bolddanger("The ground quakes beneath your feet!"))
	victim.Paralyze(10 SECONDS)
	victim.adjustBruteLoss(35)
	var/obj/structure/flora/rock/style_random/giant_rock = new(get_turf(src))
	QDEL_IN(giant_rock, 20 SECONDS)


/obj/structure/trap/ward
	name = "divine ward"
	desc = "A divine barrier, It looks like you could destroy it with enough effort, or wait for it to dissipate..."
	icon_state = "ward"
	density = TRUE
	time_between_triggers = 2 MINUTES

/obj/structure/trap/ward/Initialize(mapload)
	. = ..()
	QDEL_IN(src, time_between_triggers)

/obj/structure/trap/cult
	name = "unholy trap"
	desc = "A trap that rings with unholy energy. You think you hear... chittering?"
	icon_state = "trap-cult"

/obj/structure/trap/cult/trap_effect(mob/living/victim)
	to_chat(victim, span_bolddanger("With a crack, the hostile constructs come out of hiding, stunning you!"))
	victim.electrocute_act(10, src, flags = SHOCK_NOGLOVES) // electrocute act does a message.
	victim.Paralyze(2 SECONDS)
	new /mob/living/basic/construct/proteon/hostile(loc)
	new /mob/living/basic/construct/proteon/hostile(loc)
	QDEL_IN(src, 3 SECONDS)
