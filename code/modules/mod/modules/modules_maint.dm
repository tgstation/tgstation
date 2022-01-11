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
	playsound(src, 'sound/items/modsuits/springlock.ogg', 75, TRUE)
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
	mod.wearer.visible_message("[src] inside [mod.wearer]'s [mod.name] snaps shut, mutilating the user inside!", span_userdanger("*SNAP*"))
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.apply_damage(500, BRUTE, forced = TRUE, sharpness = SHARP_POINTY, def_zone = BODY_ZONE_CHEST) //boggers, bogchamp, etc
	mod.wearer.death() //just in case, for some reason, they're still alive
	flash_color(mod.wearer, flash_color = "#FF0000", flash_time = 10 SECONDS)

///Rave Visor - Gives you a rainbow visor and plays jukebox music to you.
/obj/item/mod/module/visor/rave
	name = "MOD rave visor module"
	desc = "A Super Cool Awesome Visor (SCAV), intended for modular suits."
	icon_state = "rave_visor"
	complexity = 1
	overlay_state_inactive = "module_rave"
	/// The client colors applied to the wearer.
	var/datum/client_colour/rave_screen
	/// The current element in the rainbow_order list we are on.
	var/rave_number = 1
	/// The track we selected to play.
	var/datum/track/selection
	/// A list of all the songs we can play.
	var/list/songs = list()
	/// A list of the colors the module can take.
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

///Tanner - Tans you with spraytan.
/obj/item/mod/module/tanner
	name = "MOD tanning module"
	desc = "A tanning module for modular suits. Skin cancer functionality has not been ever proven, \
		although who knows with the rumors..."
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
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, TRUE)
	var/datum/reagents/holder = new()
	holder.add_reagent(/datum/reagent/spraytan, 10)
	holder.trans_to(mod.wearer, 10, methods = VAPOR)
	if(prob(5))
		SSradiation.irradiate(mod.wearer)
	drain_power(use_power_cost)

///Balloon Blower - Blows a balloon.
/obj/item/mod/module/balloon
	name = "MOD balloon blower module"
	desc = "A strange module invented years ago by some ingenious mimes. It blows balloons."
	icon_state = "bloon"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN*0.5
	incompatible_modules = list(/obj/item/mod/module/balloon)
	cooldown_time = 15 SECONDS

/obj/item/mod/module/balloon/on_use()
	. = ..()
	if(!.)
		return
	if(!do_after(mod.wearer, 10 SECONDS, target = mod))
		return FALSE
	mod.wearer.adjustOxyLoss(20)
	playsound(src, 'sound/items/modsuits/inflate_bloon.ogg', 50, TRUE)
	var/obj/item/toy/balloon/balloon = new(get_turf(src))
	mod.wearer.put_in_hands(balloon)
	drain_power(use_power_cost)

/// Paper Dispenser - Dispenses (sometimes burning) paper sheets.
/obj/item/mod/module/paper_dispenser
	name = "MOD paper dispenser module"
	desc = "A simple module designed by the bureaucrats of Torch Bay. \
		It dispenses 'warm, clean, and crisp sheets of paper' onto a nearby table. Usually."
	icon_state = "paper_maker"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/paper_dispenser)
	cooldown_time = 5 SECONDS
	/// The total number of sheets created by this MOD. The more sheets, them more likely they set on fire.
	var/num_sheets_dispensed = 0

/obj/item/mod/module/paper_dispenser/on_use()
	. = ..()
	if(!.)
		return
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
		crisp_paper.balloon_alert(mod.wearer, "PC LOAD LETTER!")
		crisp_paper.visible_message(span_warning("[crisp_paper] bursts into flames, it's too crisp!"))
		crisp_paper.fire_act(1000, 100)

	drain_power(use_power_cost)
	num_sheets_dispensed++

///Atrocinator - Flips your gravity.
/obj/item/mod/module/atrocinator
	name = "MOD atrocinator module"
	desc = "A mysterious orb that has mysterious effects when inserted in a MODsuit."
	icon_state = "atrocinator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/atrocinator, /obj/item/mod/module/magboot)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_atrocinator"
	/// How many steps the user has taken since turning the suit on, used for footsteps.
	var/step_count = 0
	/// If you use the module on a planetary turf, you fly up. To the sky.
	var/you_fucked_up = FALSE

/obj/item/mod/module/atrocinator/on_activation()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/effects/curseattack.ogg', 50)
	mod.wearer.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/check_upstairs)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, MOD_TRAIT)
	check_upstairs() //todo at some point flip your screen around

/obj/item/mod/module/atrocinator/on_deactivation()
	if(you_fucked_up)
		to_chat(mod.wearer, span_danger("It's too late."))
		return FALSE
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/effects/curseattack.ogg', 50)
	qdel(mod.wearer.RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY))
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	step_count = 0
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, MOD_TRAIT)
	var/turf/open/openspace/current_turf = get_turf(mod.wearer)
	if(istype(current_turf))
		current_turf.zFall(mod.wearer, falling_from_move = TRUE)

/obj/item/mod/module/atrocinator/proc/check_upstairs()
	SIGNAL_HANDLER

	if(you_fucked_up || mod.wearer.has_gravity() != NEGATIVE_GRAVITY)
		return
	var/turf/open/current_turf = get_turf(mod.wearer)
	var/turf/open/openspace/turf_above = get_step_multiz(mod.wearer, UP)
	if(current_turf && istype(turf_above))
		current_turf.zFall(mod.wearer)
	else if(!turf_above && istype(current_turf) && current_turf.planetary_atmos) //nothing holding you down
		INVOKE_ASYNC(src, .proc/fly_away)
	else if(!(step_count % 2))
		playsound(current_turf, 'sound/items/modsuits/atrocinator_step.ogg', 50)
	step_count++

#define FLY_TIME 5 SECONDS

/obj/item/mod/module/atrocinator/proc/fly_away()
	you_fucked_up = TRUE
	playsound(src, 'sound/effects/whirthunk.ogg', 75)
	to_chat(mod.wearer, span_userdanger("That was stupid."))
	mod.wearer.Stun(FLY_TIME, ignore_canstun = TRUE)
	animate(mod.wearer, FLY_TIME, pixel_y = 256, alpha = 0)
	QDEL_IN(mod.wearer, FLY_TIME)

#undef FLY_TIME
