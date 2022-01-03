//Maint modules for MODsuits


///Springlock Mechanism - allows your modsuit to activate faster, but reagents are very dangerous.
/obj/item/mod/module/springlock
	name = "MOD springlock module"
	desc = "A module that spans the entire size of the MODsuit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up, but was taken out of modern MODsuits because of the springlock's tendency to \"snap\" back \
		into place when exposed to humidity. You know what it's like to have an entire exoskeleton enter you?"
	icon_state = "springlock"
	complexity = 3 // it is inside every part of your suit, so
	incompatible_modules = list(/obj/item/mod/module/springlock)

/obj/item/mod/module/springlock/on_install()
	mod.activation_step_time *= 0.75

/obj/item/mod/module/springlock/on_uninstall()
	mod.activation_step_time /= 0.75

/obj/item/mod/module/springlock/on_suit_activation()
    RegisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS, .proc/on_wearer_exposed)

/obj/item/mod/module/springlock/on_suit_deactivation()
    UnregisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS)

///Signal fired when wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/on_wearer_exposed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	if(!(methods & (VAPOR|PATCH|TOUCH)))
		return //remove non-touch reagent exposure
	to_chat(mod.wearer, span_danger("[src] makes an ominous click sound..."))
	playsound(mod, 'sound/items/modsuits/springlock.ogg')
	addtimer(CALLBACK(src, .proc/snap_shut), rand(3 SECONDS, 5 SECONDS))
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_activate_spring_block)

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/springlock/proc/on_activate_spring_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "springlocks aren't responding...?")
	return MOD_CANCEL_ACTIVATE

///Delayed death proc of the suit after the wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/snap_shut()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	if(!mod.wearer) //while there is a guaranteed user when on_wearer_exposed() fires, that isn't the same case for this proc
		return
	mod.wearer.visible_message("[src] inside [mod.wearer]'s MODsuit snaps shut, mutilating the user inside!", span_userdanger("*SNAP*"))
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.apply_damage(500, BRUTE, sharpness = SHARP_POINTY, wound_bonus = -450) //boggers, bogchamp, etc
	mod.wearer.death() //just in case, for some reason, they're still alive
	flash_color(mod.wearer, flash_color = "#FF0000", flash_time = 10 SECONDS)

///Rave Visor
/obj/item/mod/module/visor/rave
	name = "MOD rave visor module"
	desc = "A Super Cool Awesome Visor (SCAV), intended for modular suits."
	icon_state = "rave_visor"
	complexity = 1
	overlay_state_inactive = "module_rave"
	var/datum/client_colour/rave_screen
	var/rave_number = 1
	var/datum/track/selection
	var/list/songs = list()
	var/static/list/rainbow_order = list(
		"#FF6666",
		"#FFAA66",
		"#FFFF66",
		"#66FF66",
		"#66AAFF",
		"#AA66FF",
		)

/obj/item/mod/module/visor/rave/Initialize(mapload)
	. = ..()
	var/list/tracks = flist("[global.config.directory]/jukebox_music/sounds/")
	for(var/sound in tracks)
		var/datum/track/track = new()
		track.song_path = file("[global.config.directory]/jukebox_music/sounds/[sound]")
		var/list/sound_params = splittext(sound,"+")
		if(length(sound_params) != 3)
			continue
		track.song_name = sound_params[1]
		track.song_length = text2num(sound_params[2])
		track.song_beat = text2num(sound_params[3])
		songs[track.song_name] = track
	if(length(songs))
		var/song_name = pick(songs)
		selection = songs[song_name]

/obj/item/mod/module/visor/rave/on_activation()
	. = ..()
	if(!.)
		return
	rave_screen = mod.wearer.add_client_colour(/datum/client_colour/rave)
	rave_screen.update_colour(rainbow_order[rave_number])
	if(selection)
		mod.wearer.playsound_local(get_turf(src), null, 50, channel = CHANNEL_JUKEBOX, S = sound(selection.song_path), use_reverb = FALSE)

/obj/item/mod/module/visor/rave/on_deactivation()
	. = ..()
	if(!.)
		return
	QDEL_NULL(rave_screen)
	if(selection)
		mod.wearer.stop_sound_channel(CHANNEL_JUKEBOX)

/obj/item/mod/module/visor/rave/generate_worn_overlay(mutable_appearance/standing)
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = active ? rainbow_order[rave_number] : null

/obj/item/mod/module/visor/rave/on_active_process(delta_time)
	rave_number++
	if(rave_number > length(rainbow_order))
		rave_number = 1
	mod.wearer.update_inv_back()
	rave_screen.update_colour(rainbow_order[rave_number])

/obj/item/mod/module/visor/rave/get_configuration()
	. = ..()
	if(length(songs))
		.["selection"] = add_ui_configuration("Song", "list", selection.song_name, songs)

/obj/item/mod/module/visor/rave/configure_edit(key, value)
	switch(key)
		if("selection")
			if(active)
				return
			selection = songs[value]

///Tanner
/obj/item/mod/module/tanner
	name = "MOD tanning module"
	desc = "A tanning module for MODsuits!"
	icon_state = "tanning"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/tanner)
	cooldown_time = 30 SECONDS

/obj/item/mod/module/tanner/on_use()
	. = ..()
	if(!.)
		return
	var/datum/reagents/holder = new()
	holder.add_reagent(/datum/reagent/spraytan, 10)
	holder.trans_to(mod.wearer, 10, methods = VAPOR)

///atrocinator
/obj/item/mod/module/atrocinator
	name = "MOD atrocinator module"
	desc = "A mysterious orb that has mysterious effects when inserted in a MODsuit."
	icon_state = "atrocinator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/atrocinator)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/atrocinator/on_activation()
	. = ..()
	if(!.)
		return
	mod.wearer.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/check_upstairs)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	check_upstairs()

/obj/item/mod/module/atrocinator/on_deactivation()
	. = ..()
	if(!.)
		return
	qdel(mod.wearer.RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY))
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	var/turf/open/openspace/current_turf = get_turf(mod.wearer)
	if(istype(current_turf))
		current_turf.zFall(mod.wearer, falling_from_move = TRUE)

/obj/item/mod/module/atrocinator/proc/check_upstairs()
	var/turf/current_turf = get_turf(mod.wearer)
	var/turf/open/openspace/turf_above = get_step_multiz(mod.wearer, UP)
	if(current_turf && istype(turf_above))
		current_turf.zFall(mod.wearer)
