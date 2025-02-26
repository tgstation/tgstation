//Maint modules for MODsuits

///Springlock Mechanism - allows your modsuit to activate faster, but reagents are very dangerous.
/obj/item/mod/module/springlock
	name = "MOD springlock module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up, but was taken out of modern suits because of the springlock's tendency to \"snap\" back \
		into place when exposed to humidity. You know what it's like to have an entire exoskeleton enter you?"
	icon_state = "springlock"
	complexity = 3 // it is inside every part of your suit, so
	incompatible_modules = list(/obj/item/mod/module/springlock)
	var/set_off = FALSE
	var/static/list/gas_connections = list(
		COMSIG_TURF_EXPOSE = PROC_REF(on_wearer_exposed_gas),
	)
	var/step_change = 0.5

/obj/item/mod/module/springlock/on_install()
	mod.activation_step_time *= step_change

/obj/item/mod/module/springlock/on_uninstall(deleting = FALSE)
	mod.activation_step_time /= step_change

/obj/item/mod/module/springlock/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_wearer_exposed))
	AddComponent(/datum/component/connect_loc_behalf, mod.wearer, gas_connections)

/obj/item/mod/module/springlock/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS)
	qdel(GetComponent(/datum/component/connect_loc_behalf))

///Registers the signal COMSIG_MOD_ACTIVATE and calls the proc snap_shut() after a timer
/obj/item/mod/module/springlock/proc/snap_signal()
	if (set_off || mod.wearer.stat == DEAD)
		return

	var/found_part = FALSE
	for (var/obj/item/part as anything in mod.get_parts())
		// Don't snap if no parts besides the MOD itself are active
		if (part.loc != mod && mod.get_part_datum(part)?.sealed)
			found_part = TRUE
			break

	if (!found_part)
		return

	to_chat(mod.wearer, span_danger("[src] makes an ominous click sound..."))
	playsound(src, 'sound/items/modsuit/springlock.ogg', 75, TRUE)
	addtimer(CALLBACK(src, PROC_REF(snap_shut)), rand(3 SECONDS, 5 SECONDS))
	RegisterSignals(mod, list(COMSIG_MOD_ACTIVATE, COMSIG_MOD_PART_RETRACTING), PROC_REF(on_activate_spring_block))
	set_off = TRUE

///Calls snap_signal() when exposed to a reagent via VAPOR, PATCH or TOUCH
/obj/item/mod/module/springlock/proc/on_wearer_exposed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER

	if(!(methods & (VAPOR|PATCH|TOUCH)))
		return //remove non-touch reagent exposure
	snap_signal()

///Calls snap_signal() when exposed to water vapor
/obj/item/mod/module/springlock/proc/on_wearer_exposed_gas()
	SIGNAL_HANDLER

	var/turf/wearer_turf = get_turf(src)
	var/datum/gas_mixture/air = wearer_turf.return_air()
	if(!(air.gases[/datum/gas/water_vapor] && (air.gases[/datum/gas/water_vapor][MOLES]) >= 5))
		return //return if there aren't more than 5 Moles of Water Vapor in the air
	snap_signal()

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/springlock/proc/on_activate_spring_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "springlocks aren't responding...?")
	return MOD_CANCEL_ACTIVATE

///Delayed death proc of the suit after the wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/snap_shut()
	UnregisterSignal(mod, list(COMSIG_MOD_ACTIVATE, COMSIG_MOD_PART_RETRACTING))
	if(!mod.wearer) //while there is a guaranteed user when on_wearer_exposed() fires, that isn't the same case for this proc
		return
	mod.wearer.visible_message("[src] inside [mod.wearer]'s [mod.name] snaps shut, mutilating the user inside!", span_userdanger("*SNAP*"))
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.client?.give_award(/datum/award/achievement/misc/springlock, mod.wearer)

	mod.wearer.get_bodypart(BODY_ZONE_CHEST)?.receive_damage(200, forced = TRUE, sharpness = SHARP_POINTY) // Chest always gets hit, from the back piece you're wearing
	for (var/obj/item/part as anything in mod.get_parts())
		if (part.loc == mod || !mod.get_part_datum(part)?.sealed)
			continue

		for (var/obj/item/bodypart/bodypart as anything in mod.wearer.get_damageable_bodyparts())
			if (part.body_parts_covered & bodypart.body_part) // can hit chest again
				bodypart.receive_damage(100, forced = TRUE, sharpness = SHARP_POINTY) //boggers, bogchamp, etc

	if(!HAS_TRAIT(mod.wearer, TRAIT_NODEATH))
		mod.wearer.investigate_log("has been killed by [src].", INVESTIGATE_DEATHS)
		mod.wearer.death() //just in case, for some reason, they're still alive
	flash_color(mod.wearer, flash_color = "#FF0000", flash_time = 10 SECONDS)
	set_off = FALSE

///Rave Visor - Gives you a rainbow visor and plays jukebox music to you.
/obj/item/mod/module/visor/rave
	name = "MOD rave visor module"
	desc = "A Super Cool Awesome Visor (SCAV), intended for modular suits."
	icon_state = "rave_visor"
	complexity = 1
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// The client colors applied to the wearer.
	var/datum/client_colour/rave_screen
	/// The current element in the rainbow_order list we are on.
	var/rave_number = 1
	/// A list of the colors the module can take.
	var/static/list/rainbow_order = list(
		list(1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(1,0,0,0, 0,0.5,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(1,0,0,0, 0,1,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(0,0,0,0, 0,1,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(0,0,0,0, 0,0.5,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0),
		list(1,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0),
	)
	/// What actually plays music to us
	var/datum/jukebox/single_mob/music_player

/obj/item/mod/module/visor/rave/Initialize(mapload)
	. = ..()
	music_player = new(src)
	music_player.sound_loops = TRUE

/obj/item/mod/module/visor/rave/Destroy()
	QDEL_NULL(music_player)
	QDEL_NULL(rave_screen)
	return ..()

/obj/item/mod/module/visor/rave/on_activation()
	rave_screen = mod.wearer.add_client_colour(/datum/client_colour/rave)
	rave_screen.update_colour(rainbow_order[rave_number])
	music_player.start_music(mod.wearer)

/obj/item/mod/module/visor/rave/on_deactivation(display_message = TRUE, deleting = FALSE)
	QDEL_NULL(rave_screen)
	if(isnull(music_player.active_song_sound))
		return

	music_player.unlisten_all()
	if(deleting)
		return
	SEND_SOUND(mod.wearer, sound('sound/machines/terminal/terminal_off.ogg', volume = 50, channel = CHANNEL_JUKEBOX))

/obj/item/mod/module/visor/rave/generate_worn_overlay(mutable_appearance/standing)
	var/mutable_appearance/visor_overlay = mod.get_visor_overlay(standing)
	visor_overlay.appearance_flags |= RESET_COLOR
	if (!isnull(music_player.active_song_sound))
		visor_overlay.color = rainbow_order[rave_number]
	return list(visor_overlay)

/obj/item/mod/module/visor/rave/on_active_process(seconds_per_tick)
	rave_number++
	if(rave_number > length(rainbow_order))
		rave_number = 1
	mod.wearer.update_clothing(mod.slot_flags)
	rave_screen.update_colour(rainbow_order[rave_number])

/obj/item/mod/module/visor/rave/get_configuration()
	. = ..()
	if(length(music_player.songs))
		.["selection"] = add_ui_configuration("Song", "list", music_player.selection.song_name, music_player.songs)

/obj/item/mod/module/visor/rave/configure_edit(key, value)
	switch(key)
		if("selection")
			if(!isnull(music_player.active_song_sound))
				return

			var/datum/track/new_song = music_player.songs[value]
			if(QDELETED(src) || !istype(new_song, /datum/track))
				return

			music_player.selection = new_song

///Tanner - Tans you with spraytan.
/obj/item/mod/module/tanner
	name = "MOD tanning module"
	desc = "A tanning module for modular suits. Skin cancer functionality has not been ever proven, \
		although who knows with the rumors..."
	icon_state = "tanning"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/tanner)
	cooldown_time = 30 SECONDS
	required_slots = list(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)

/obj/item/mod/module/tanner/on_use()
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, TRUE)
	var/datum/reagents/holder = new()
	holder.add_reagent(/datum/reagent/spraytan, 10)
	holder.trans_to(mod.wearer, 10, methods = VAPOR)
	if(prob(5))
		SSradiation.irradiate(mod.wearer)
	drain_power(use_energy_cost)

///Balloon Blower - Blows a balloon.
/obj/item/mod/module/balloon
	name = "MOD balloon blower module"
	desc = "A strange module invented years ago by some ingenious mimes. It blows balloons."
	icon_state = "bloon"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/balloon)
	cooldown_time = 15 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	var/balloon_path = /obj/item/toy/balloon
	var/blowing_time = 10 SECONDS
	var/oxygen_damage = 20

/obj/item/mod/module/balloon/on_use()
	if(!do_after(mod.wearer, blowing_time, target = mod))
		return FALSE
	mod.wearer.adjustOxyLoss(oxygen_damage)
	playsound(src, 'sound/items/modsuit/inflate_bloon.ogg', 50, TRUE)
	var/obj/item/balloon = new balloon_path(get_turf(src))
	mod.wearer.put_in_hands(balloon)
	drain_power(use_energy_cost)

///Paper Dispenser - Dispenses (sometimes burning) paper sheets.
/obj/item/mod/module/paper_dispenser
	name = "MOD paper dispenser module"
	desc = "A simple module designed by the bureaucrats of Torch Bay. \
		It dispenses 'warm, clean, and crisp sheets of paper' onto a nearby table. Usually."
	icon_state = "paper_maker"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/paper_dispenser)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// The total number of sheets created by this MOD. The more sheets, them more likely they set on fire.
	var/num_sheets_dispensed = 0

/obj/item/mod/module/paper_dispenser/on_use()
	if(!do_after(mod.wearer, 1 SECONDS, target = mod))
		return FALSE

	var/obj/item/paper/crisp_paper = new(get_turf(src))
	crisp_paper.desc = "It's crisp and warm to the touch. Must be fresh."

	var/obj/structure/table/nearby_table = locate() in range(1, mod.wearer)
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "dispensed paper[nearby_table ? " onto table":""]")

	mod.wearer.put_in_hands(crisp_paper)
	if(nearby_table)
		mod.wearer.transferItemToLoc(crisp_paper, nearby_table.drop_location(), silent = FALSE)

	// Up to a 30% chance to set the sheet on fire, +2% per sheet made
	if(prob(min(num_sheets_dispensed * 2, 30)))
		if(crisp_paper in mod.wearer.held_items)
			mod.wearer.dropItemToGround(crisp_paper, force = TRUE)
		crisp_paper.balloon_alert(mod.wearer, UNLINT("PC LOAD LETTER!"))
		crisp_paper.visible_message(span_warning("[crisp_paper] bursts into flames, it's too crisp!"))
		crisp_paper.fire_act(1000, 100)

	drain_power(use_energy_cost)
	num_sheets_dispensed++


///Stamper - Extends a stamp that can switch between accept/deny modes.
/obj/item/mod/module/stamp
	name = "MOD stamper module"
	desc = "A module installed into the wrist of the suit, this functions as a high-power stamp, \
		able to switch between accept and deny modes."
	icon_state = "stamp"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/stamp/mod
	incompatible_modules = list(/obj/item/mod/module/stamp)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/stamp/mod
	name = "MOD electronic stamp"
	desc = "A high-power stamp, able to switch between accept and deny mode when used."

/obj/item/stamp/mod/attack_self(mob/user, modifiers)
	. = ..()
	if(icon_state == "stamp-ok")
		icon_state = "stamp-deny"
	else
		icon_state = "stamp-ok"
	balloon_alert(user, "switched mode")

///Atrocinator - Flips your gravity.
/obj/item/mod/module/atrocinator
	name = "MOD atrocinator module"
	desc = "A mysterious orb that has mysterious effects when inserted in a MODsuit."
	icon_state = "atrocinator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/atrocinator, /obj/item/mod/module/magboot, /obj/item/mod/module/anomaly_locked/antigrav)
	overlay_state_inactive = "module_atrocinator"
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// How many steps the user has taken since turning the suit on, used for footsteps.
	var/step_count = 0
	/// If you use the module on a planetary turf, you fly up. To the sky.
	var/you_fucked_up = FALSE

/obj/item/mod/module/atrocinator/on_activation()
	playsound(src, 'sound/effects/curse/curseattack.ogg', 50)
	mod.wearer.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_upstairs))
	RegisterSignal(mod.wearer, COMSIG_MOB_SAY, PROC_REF(on_talk))
	ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))
	passtable_on(mod.wearer, REF(src))
	check_upstairs() //todo at some point flip your screen around

/obj/item/mod/module/atrocinator/deactivate(display_message = TRUE, deleting = FALSE)
	if(you_fucked_up && !deleting)
		to_chat(mod.wearer, span_danger("It's too late."))
		return FALSE
	return ..()

/obj/item/mod/module/atrocinator/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/effects/curse/curseattack.ogg', 50)
	qdel(mod.wearer.RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY))
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(mod.wearer, COMSIG_MOB_SAY)
	step_count = 0
	REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))
	passtable_off(mod.wearer, REF(src))
	var/turf/open/openspace/current_turf = get_turf(mod.wearer)
	if(istype(current_turf))
		current_turf.zFall(mod.wearer, falling_from_move = TRUE)

/obj/item/mod/module/atrocinator/proc/check_upstairs(atom/movable/source, atom/oldloc, direction, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if(you_fucked_up || mod.wearer.has_gravity() > NEGATIVE_GRAVITY)
		return

	var/turf/open/current_turf = get_turf(mod.wearer)
	var/turf/open/openspace/turf_above = get_step_multiz(mod.wearer, UP)
	if(current_turf && istype(turf_above))
		current_turf.zFall(mod.wearer)
		return

	else if(!turf_above && istype(current_turf) && current_turf.planetary_atmos) //nothing holding you down
		INVOKE_ASYNC(src, PROC_REF(fly_away))
		return

	if (forced || (SSlag_switch.measures[DISABLE_FOOTSTEPS] && !(HAS_TRAIT(source, TRAIT_BYPASS_MEASURES))))
		return

	if(!(step_count % 2))
		playsound(current_turf, 'sound/items/modsuit/atrocinator_step.ogg', 50)
	step_count++

#define FLY_TIME (5 SECONDS)

/obj/item/mod/module/atrocinator/proc/fly_away()
	you_fucked_up = TRUE
	playsound(src, 'sound/effects/whirthunk.ogg', 75)
	to_chat(mod.wearer, span_userdanger("That was stupid."))
	investigate_log("has flown off into space due to the [src].", INVESTIGATE_DEATHS)
	mod.wearer.Stun(FLY_TIME, ignore_canstun = TRUE)
	animate(mod.wearer, FLY_TIME, pixel_z = 256, alpha = 0)
	QDEL_IN(mod.wearer, FLY_TIME)

#undef FLY_TIME

/obj/item/mod/module/atrocinator/proc/on_talk(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= "upside_down"

/obj/item/mod/module/recycler/donk/safe
	name = "MOD foam dart recycler module"
	desc = "A mod module that collects and repackages fired foam darts into half-sized ammo boxes. \
		Activate on a nearby turf or storage to unload stored ammo boxes."
	icon_state = "donk_safe_recycler"
	overlay_state_inactive = "module_donk_safe_recycler"
	overlay_state_active = "module_donk_safe_recycler"
	complexity = 1
	efficiency = 1
	allowed_item_types = list(/obj/item/ammo_casing/foam_dart)
	ammobox_type = /obj/item/ammo_box/foambox/mini
	required_amount = SMALL_MATERIAL_AMOUNT*2.5
