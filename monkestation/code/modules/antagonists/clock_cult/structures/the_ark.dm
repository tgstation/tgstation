GLOBAL_DATUM(clock_ark, /obj/structure/destructible/clockwork/the_ark) //set to be equal to the ark on creation if none
GLOBAL_VAR_INIT(ratvar_risen, FALSE)

#define ARK_READY_PERIOD 300 SECONDS //how long until the cult is annouced after they reach max members, 5 minutes
#define ARK_GRACE_PERIOD 210 SECONDS //how long until the portals open after the cult is annouced, 3 minutes 30 seconds
#define ARK_ASSAULT_PERIOD 600 //how long the crew has to destroy the ark after the assault begins, 10 minutes
/obj/structure/destructible/clockwork/the_ark
	name = "\improper Ark of the Clockwork Justiciar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	clockwork_desc = "Nezbere's magnum opus: a hulking clockwork machine capable of combining bluespace and steam power to summon Ratvar. Once activated, \
	its instability will cause one-way bluespace rifts to open across the station to the City of Cogs, so be prepared to defend it at all costs."
	max_integrity = 1000
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	immune_to_servant_attacks = TRUE
	layer = BELOW_MOB_LAYER
	can_rotate = FALSE
	break_message = null
	break_sound = null
	debris = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

	///current charge state of the ark
	var/current_state = ARK_STATE_BASE
	///tracker for how long until rat'var is summoned in ARK_STATE_ACTIVE/ARK_STATE_SUMMONING
	var/charging_for = 0

/obj/structure/destructible/clockwork/the_ark/Initialize(mapload)
	. = ..()
	if(!GLOB.clock_ark)
		GLOB.clock_ark = src
	SSpoints_of_interest.make_point_of_interest(src)

/obj/structure/destructible/clockwork/the_ark/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user) || isobserver(user))
		switch(current_state)
			if(ARK_STATE_CHARGING)
				. += span_brass("The ark has started charging, the crew will soon know our glory!")
			if(ARK_STATE_ACTIVE)
				. += span_brass("The ark is opening, [charging_for ? "defend it until ratvar arrives in [ARK_ASSAULT_PERIOD - charging_for] seconds." : "prepare to defend it!"]")
			if(ARK_STATE_SUMMONING)
				. += span_brass("Ratvar has nearly arrived, it will only be [ARK_ASSAULT_PERIOD - charging_for] more seconds!")

/obj/structure/destructible/clockwork/the_ark/Destroy()
	if(GLOB.clock_ark == src)
		GLOB.clock_ark = null
	if(GLOB.ratvar_risen)
		return ..()
	STOP_PROCESSING(SSprocessing, src)
	send_clock_message(null, span_bigbrass("The Ark has been destroyed, Reebe is becoming unstable!"))
	for(var/mob/living/current_mob in GLOB.player_list)
		if(!on_reebe(current_mob))
			continue
		if(IS_CLOCK(current_mob))
			to_chat(current_mob, span_reallybig(span_ratvar("Your mind is distorted by the distant sound of a thousand screams. [span_reallybig("<i>YOU HAVE FAILED TO PROTECT MY ARK. \
																  YOU WILL BE TRAPPED HERE WITH ME TO SUFFER FOREVER...</i>")]")))
			continue
		current_mob.SetSleeping(5 SECONDS)
		to_chat(current_mob, span_ratvar("Your mind is distorted by the distant sound of a thousand screams before suddenly everything falls silent."))
		to_chat(current_mob, span_hypnophrase("The only thing you remember is suddenly feeling hard ground beneath you and the safety of home."))
		current_mob.forceMove(find_safe_turf())

	if(GLOB.narsie_breaching_rune)
		if(istype(GLOB.narsie_breaching_rune, /obj/effect/rune/narsie))
			new /obj/narsie(get_turf(GLOB.narsie_breaching_rune))
		else
			new /obj/narsie(get_safe_random_station_turf())

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(explode_reebe))
	return ..()

/obj/structure/destructible/clockwork/the_ark/deconstruct(disassembled = TRUE)
	if(current_state >= ARK_STATE_FINAL)
		return
	ASYNC
		if(!(flags_1 & NODECONSTRUCT_1))
			if(!disassembled)
				current_state = ARK_STATE_FINAL
				resistance_flags |= INDESTRUCTIBLE
				visible_message(span_userdanger("[src] begins to pulse uncontrollably... you might want to run!"))
				sound_to_playing_players('sound/effects/clockcult_gateway_disrupted.ogg', 50)
				sleep(2.5 SECONDS)
				sound_to_playing_players('sound/machines/clockcult/ark_deathrattle.ogg', 50)
				sleep(2.7 SECONDS)
				explosion(src, 1, 3, 8, 8)
				sound_to_playing_players('sound/effects/explosion_distant.ogg', 50)
				for(var/obj/effect/portal/clockcult/portal in GLOB.portals)
					qdel(portal)
				SSshuttle.clearHostileEnvironment(src)
				SSsecurity_level.set_level(2)
		qdel(src)

/obj/structure/destructible/clockwork/the_ark/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(!.)
		return
	send_clock_message(null, span_bigbrass("The ark is taking damage!"), sent_sound = 'monkestation/sound/machines/clockcult/ark_damage.ogg')
	flick("clockwork_gateway_damaged", src)
	playsound(src, 'monkestation/sound/machines/clockcult/ark_damage.ogg', 75, FALSE)

/obj/structure/destructible/clockwork/the_ark/process(seconds_per_tick)
	if(current_state >= ARK_STATE_FINAL)
		return

	if(current_state >= ARK_STATE_CHARGING)
		charging_for = min(charging_for + seconds_per_tick, ARK_ASSAULT_PERIOD)

	if(charging_for >= ARK_ASSAULT_PERIOD)
		summon_ratvar()
		return

	if(current_state < ARK_STATE_SUMMONING && charging_for >= (ARK_ASSAULT_PERIOD * 0.5))
		current_state = ARK_STATE_SUMMONING
		icon_state = "clockwork_gateway_closing"
		sound_to_playing_players('monkestation/sound/effects/clockcult_gateway_closing.ogg', 30, TRUE)

	if(current_state >= ARK_STATE_SUMMONING && SPT_PROB(4, seconds_per_tick))
		send_to_playing_players(span_warning("[pick(list("You feel the fabric of reality twist and bend.", \
											  "Your mind buzzes with fear.", \
											  "You hear otherworldly screams from all around you.", \
											  "You feel reality shudder for a moment...", \
											  "You feel time and space distorting around you..."))]"))

/obj/structure/destructible/clockwork/the_ark/proc/prepare_ark()
	if(current_state > ARK_STATE_BASE)
		return
	current_state = ARK_STATE_CHARGING
	SSshuttle.registerHostileEnvironment(src)
	icon_state = "clockwork_gateway_charging"
	send_clock_message(null, span_bigbrass("The Ark's many cogs suddenly whir to life, steam gushing out of its many crevices; it will open in 5 minutes!"), \
					   sent_sound = 'sound/magic/clockwork/scripture_tier_up.ogg')
	addtimer(CALLBACK(src, PROC_REF(open_gateway)), ARK_READY_PERIOD)

/obj/structure/destructible/clockwork/the_ark/proc/open_gateway()
	if(current_state >= ARK_STATE_ACTIVE)
		return
	current_state = ARK_STATE_ACTIVE
	SSshuttle.registerHostileEnvironment(src)
	icon_state = "clockwork_gateway_active"
	send_clock_message(null, span_bigbrass("The Ark has been activated, you will be transported soon! Dont forget to gather weapons with your \"Clockwork Armaments\" scripture."), \
					   sent_sound = 'sound/magic/clockwork/ark_activation_sequence.ogg')
	addtimer(CALLBACK(src, PROC_REF(announce_gateway)), 27 SECONDS)

/obj/structure/destructible/clockwork/the_ark/proc/announce_gateway()
	send_clock_message(null, span_ratvar("DESTROY THE HERETICS."), sent_sound = 'monkestation/sound/machines/clockcult/ark_recall.ogg')

	sleep(3 SECONDS)

	for(var/datum/mind/servant_mind in GLOB.main_clock_cult.members)
		var/mob/living/servant_mob = servant_mind.current
		if(!servant_mob || QDELETED(servant_mob))
			continue
		if(GLOB.abscond_markers)
			try_servant_warp(servant_mob, get_turf(pick(GLOB.abscond_markers)))
		if(ishuman(servant_mob))
			var/datum/antagonist/clock_cultist/servant_antag = servant_mind.has_antag_datum(/datum/antagonist/clock_cultist)
			if(servant_antag)
				servant_antag.forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
				servant_mob.add_overlay(servant_antag.forbearance)

	sound_to_playing_players('sound/magic/clockwork/invoke_general.ogg', 50)
	SSsecurity_level.set_level(3)
	addtimer(CALLBACK(src, PROC_REF(begin_assault)), ARK_GRACE_PERIOD)

	priority_announce("Massive [Gibberish("bluespace", 100)] anomaly detected on all frequencies. All crew are directed to \
	@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. the anomalies and destroy their source to prevent further damage to corporate property. This is \
	not a drill. Estimated time of appearance: [ARK_GRACE_PERIOD/10] seconds. Use this time to prepare for an attack on [station_name()]." \
	,"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')

	sound_to_playing_players('monkestation/sound/effects/clockcult_gateway_charging.ogg', 10, TRUE)
	log_game("The clock cult has begun opening the Ark of the Clockwork Justiciar.")

/obj/structure/destructible/clockwork/the_ark/proc/begin_assault()
	START_PROCESSING(SSprocessing, src)
	priority_announce("Space-time anomalies detected near the station. Source determined to be a temporal \
		energy pulse emanating from J1523-215. All crew are to enter [text2ratvar("prep#re %o di%")]\
		and destroy the [text2ratvar("I'd like to see you try")], which has been determined to be the source of the \
		pulse to prevent mass damage to Nanotrasen property.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)

	log_game("The opening of the Ark of the Clockwork Justiciar has caused portals to open around the station.")
	for(var/i in 1 to 100)
		new /obj/effect/portal/clockcult(get_random_station_turf())
		sleep(1)

/obj/structure/destructible/clockwork/the_ark/proc/summon_ratvar()
	if(current_state >= ARK_STATE_FINAL)
		return
	current_state = ARK_STATE_FINAL
	STOP_PROCESSING(SSprocessing, src)
	resistance_flags |= INDESTRUCTIBLE
	send_clock_message(null, span_bigbrass("Ratvar approaches, you shall be eternally rewarded for your servitude!"), msg_ghosts = FALSE)
	send_to_playing_players(span_warning("You feel time slow down."))
	GLOB.ratvar_risen = TRUE
	sound_to_playing_players('monkestation/sound/effects/ratvar_rises.ogg', 100)

	if(GLOB.main_clock_cult)
		for(var/datum/mind/current_mind in GLOB.main_clock_cult.members)
			var/mob/living/newgod = current_mind.current
			if(!newgod)
				continue
			newgod.status_flags |= GODMODE
	else
		stack_trace("Clockwork ark calling summon_ratvar() with no set main_clock_cult.")

	for(var/mob/living/checked_mob as anything in GLOB.player_list)
		if(on_reebe(checked_mob)) //doing an addtimer to insure these run on time as the ark will be getting qdeled at this time
			addtimer(CALLBACK(null, GLOBAL_PROC_REF(try_servant_warp), checked_mob, get_safe_random_station_turf()), 12.8 SECONDS)

	var/original_matrix = matrix()
	animate(src, transform = original_matrix * 1.5, alpha = 255, time = 125)
	sleep(3 SECONDS)
	send_to_playing_players(span_warning("You see cracks forming in space around you."))
	sleep(3 SECONDS)
	send_to_playing_players(span_warning("You are deafened by the sound of a million screams."))
	sleep(5.5 SECONDS)
	send_to_playing_players(span_userdanger("THE JUSTICAR IS HERE."))
	sleep(1 SECONDS)
	transform = original_matrix
	animate(src, transform = original_matrix * 3, alpha = 0, time = 5)
	QDEL_IN(src, 4)
	sleep(3)
	new /obj/ratvar(get_random_station_turf())

/proc/explode_reebe()
	var/list/reebe_area_list = get_area_turfs(/area/ruin/powered/reebe/city)
	if(reebe_area_list.len)
		for(var/i in 1 to 30)
			explosion(pick(reebe_area_list), 0, 2, 4, 4, FALSE)
			sleep(5)
	if(GLOB.abscond_markers.len)
		explosion(pick(GLOB.abscond_markers), 50, 40, 30, 30, FALSE, TRUE)
	SSticker.force_ending = TRUE

#undef ARK_READY_PERIOD
#undef ARK_GRACE_PERIOD
#undef ARK_ASSAULT_PERIOD

/obj/effect/rune/narsie/Destroy(force)
	if(src == GLOB.narsie_breaching_rune)
		GLOB.narsie_breaching_rune = TRUE //we still want to summon even if destroyed
	return ..()
