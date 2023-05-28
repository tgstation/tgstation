SUBSYSTEM_DEF(html_audio)
	name = "HTML Audio"
	init_order = INIT_ORDER_HTMLAUDIO
	flags = SS_NO_FIRE
	var/list/speakers = list()
	var/max_channels = 512 // set this to how many total channels you want
	var/list/channel_assignment = list() // list([atom in the world], [atom in the world], ...) for keeping track of what channels are in use and by what
	var/list/listeners = list() // list of client listeners to update when audio gets added
	var/list/listener_handlers = list() // list([atom in the world] = listener_handler)
	var/browse_txt
	var/preview_browse_txt

/datum/html_audio_speaker
	var/atom/speaker
	var/assigned_channel
	var/looping = FALSE
	var/tts = FALSE
	var/url
	var/blips_url
	var/requires_LOS = FALSE
	var/list/listeners_at_start_for_LOS

/datum/html_audio_speaker/New(requires_LOS)
	. = ..()
	src.requires_LOS = requires_LOS


/datum/html_audio_speaker/proc/deregister_player_qdel(atom/movable/player)
	SIGNAL_HANDLER
	UnregisterSignal(player, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	SShtml_audio.deregister_player(player)

/datum/html_audio_speaker/proc/handle_player_move(atom/movable/player, atom/old_loc)
	SIGNAL_HANDLER
	list_clear_nulls(SShtml_audio.listeners) // clients be like *poof* mid proc
	for(var/client/listener in SShtml_audio.listeners)
		if(!listener)
			continue
		SShtml_audio.update_listener_volume(listener)

/datum/controller/subsystem/html_audio/Initialize()
	browse_txt = @{"
			<META http-equiv="X-UA-Compatible" content="IE=edge">"}
	for(var/i in 1 to max_channels)
		browse_txt += {"
			<audio id="channel_[i]" volume="0">
			</audio>"}
	browse_txt += @{"
			<script>
			function setVolume(volume, element_id)
			{
				var audio_player = document.getElementById(element_id);
				audio_player.volume = parseFloat(volume);
			}
			function setVolumes(volume_json) {
				var volumes = JSON.parse(volume_json);

				for (var element_id in volumes) {
					if (volumes.hasOwnProperty(element_id)) {
						setVolume(volumes[element_id], element_id);
					}
				}
			}
			function playAudio(url, element_id)
			{
				var audio_player = document.getElementById(element_id);
				audio_player.pause();
				audio_player.src = url;
				audio_player.load();
				audio_player.play();
			}
			function setLooping(loop, element_id)
			{
				var audio_player = document.getElementById(element_id);
				var isTrueSet = (loop === 'true');
				if(isTrueSet)
				{
					audio_player.loop = true;
				}
				else
				{
					audio_player.loop = false;
				}
			}
			</script>
	"}
	preview_browse_txt = @{"
			<META http-equiv="X-UA-Compatible" content="IE=edge">
			<audio id="channel_preview" volume="100">
			</audio>
			<script>
			function playAudio(url)
			{
				var audio_player = document.getElementById("channel_preview");
				audio_player.pause();
				audio_player.src = url;
				audio_player.load();
				audio_player.play();
			}
			</script>
	"}
	channel_assignment.len = max_channels
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(register_listener))
	return SS_INIT_SUCCESS

/datum/listener_handler

/datum/listener_handler/proc/handle_listener_move(mob/listener, atom/old_loc)
	SIGNAL_HANDLER
	SShtml_audio.update_listener_volume(listener.client)

/datum/listener_handler/proc/deregister_listener_qdel(atom/movable/listener)
	SIGNAL_HANDLER
	UnregisterSignal(listener, list(COMSIG_MOVABLE_MOVED))
	SShtml_audio.listener_handlers -= listener
	UnregisterSignal(listener, list(COMSIG_MOB_LOGOUT))

/datum/listener_handler/proc/unregister_listener_logout(mob/old_listener)
	SIGNAL_HANDLER
	UnregisterSignal(old_listener, list(COMSIG_MOVABLE_MOVED))
	SShtml_audio.listener_handlers -= old_listener
	UnregisterSignal(old_listener, list(COMSIG_MOB_LOGOUT))

/datum/controller/subsystem/html_audio/proc/register_listener(datum/source, mob/new_login)
	list_clear_nulls(listeners)
	var/client/listener = new_login.client
	if(!listeners.Find(listener))
		listeners += listener
		listener << browse(browse_txt, "window=html_audio_player&file=html_audio_player.htm")
		listener << browse(preview_browse_txt, "window=html_audio_preview_player&file=html_audio_preview_player.htm")

	var/datum/listener_handler/new_handler = new // our ECS system is dumb as shit and needs us to do this to have two things hooked on this
	listener_handlers[listener.mob] = new_handler
	new_handler.RegisterSignal(listener.mob, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/listener_handler, handle_listener_move)) // calls update_listener_volume
	new_handler.RegisterSignal(listener.mob, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/listener_handler, deregister_listener_qdel)) // calls update_listener_volume
	new_handler.RegisterSignal(listener.mob, COMSIG_MOB_LOGOUT, TYPE_PROC_REF(/datum/listener_handler, unregister_listener_logout))
	update_listener_volume(listener)
	for(var/speaker_player in speakers) // New listener, so let's get them up to speed on all the channels.
		var/datum/html_audio_speaker/speaker = speakers[speaker_player]
		if(speaker.url)
			if(speaker.tts)
				var/use_blips = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_blips)
				var/use_byond_audio = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_byond_audio)
				if(CONFIG_GET(flag/tts_force_html_audio))
					use_byond_audio = FALSE
				if(!use_byond_audio)
					if(use_blips)
						listener << output(list2params(list(speaker.blips_url, "channel_[speaker.assigned_channel]")), "html_audio_player:playAudio")
					else
						listener << output(list2params(list(speaker.url, "channel_[speaker.assigned_channel]")), "html_audio_player:playAudio")
			else
				listener << output(list2params(list(speaker.url, "channel_[speaker.assigned_channel]")), "html_audio_player:playAudio")
		if(speaker.looping)
			listener << output(list2params(list("true", "channel_[speaker.assigned_channel]")), "html_audio_player:setLooping")
		else
			listener << output(list2params(list("false", "channel_[speaker.assigned_channel]")), "html_audio_player:setLooping")

/datum/controller/subsystem/html_audio/proc/update_listener_volume(client/listener)
	var/list/channels_to_update = list()
	for(var/speaker_player in speakers)
		var/datum/html_audio_speaker/speaker = speakers[speaker_player]
		var/volume_to_use = 0
		var/distance = get_dist(speaker.speaker, listener.mob)
		var/turf/speaker_turf = get_turf(speaker.speaker)
		var/turf/listener_turf = get_turf(listener.mob)
		if(!speaker.speaker || distance >= 10 || (speaker.requires_LOS && !(listener in speaker.listeners_at_start_for_LOS)) || (speaker.tts && listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_byond_audio)))
			volume_to_use = 0
		else
			if(speaker.tts)
				volume_to_use = min((1-(1/10*distance))**2, 1) * listener.prefs.read_preference(/datum/preference/numeric/sound_tts_volume) / 100
			else
				volume_to_use = min((1-(1/10*distance))**2, 1)
				//Atmosphere affects sound
				var/pressure_factor = 1
				var/datum/gas_mixture/hearer_env = listener_turf.return_air()
				var/datum/gas_mixture/source_env = speaker_turf.return_air()

				if(hearer_env && source_env)
					var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
					if(pressure < ONE_ATMOSPHERE)
						pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
				else //space
					pressure_factor = 0

				if(distance <= 1)
					pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

				volume_to_use *= pressure_factor
				volume_to_use = clamp(volume_to_use, 0, 1)
		channels_to_update["channel_[speaker.assigned_channel]"] = num2text(volume_to_use)
	if (length(channels_to_update))
		listener << output(url_encode(json_encode(channels_to_update)), "html_audio_player:setVolumes")

/datum/controller/subsystem/html_audio/proc/jank_ass_browse_check(checked_person)
	if (!winexists(checked_person, "html_audio_player"))
		checked_person << browse(browse_txt, "window=html_audio_player&file=html_audio_player.htm")
	if (!winexists(checked_person, "html_audio_preview_player"))
		checked_person << browse(browse_txt, "window=html_audio_preview_player&file=html_audio_preview_player.htm")

/datum/controller/subsystem/html_audio/proc/register_player(atom/movable/player, requires_LOS = FALSE)
	var/assigned = FALSE
	var/datum/html_audio_speaker/new_speaker = new(requires_LOS)
	for(var/i in 1 to max_channels) // Go through the channels, find the first empty slot and get in there.
		if(isnull(channel_assignment[i]))
			assigned = TRUE
			new_speaker.assigned_channel = i
			new_speaker.speaker = player
			speakers[player] = new_speaker
			channel_assignment[i] = new_speaker
			new_speaker.RegisterSignal(player, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/html_audio_speaker, handle_player_move))
			new_speaker.RegisterSignal(player, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/html_audio_speaker, deregister_player_qdel))
			break
	if(!assigned)
		qdel(new_speaker)
		CRASH("No channels to spare / HTML audio weeps / Silent speaker waits - ChatGPT, \"Whispers of Silence\", 5/24/2023")
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)

/datum/controller/subsystem/html_audio/proc/deregister_player(atom/movable/player)
	UnregisterSignal(player, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	var/datum/html_audio_speaker/speaker = speakers[player]
	channel_assignment[speaker.assigned_channel] = null
	speakers -= player
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)

/datum/controller/subsystem/html_audio/proc/play_audio(atom/movable/player, url, blips_url = null)
	stop_looping_audio(player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/datum/html_audio_speaker/speaker = speakers[player]
	if(!speaker)
		CRASH("Sound lost in the void / Unregistered melody / HTML's silence - ChatGPT, \"Unheard Melodies\", 5/24/2023")
	if(blips_url)
		speaker.url = url
		speaker.blips_url = blips_url
		speaker.tts = TRUE
	else
		speaker.url = url
		speaker.tts = FALSE
	speaker.listeners_at_start_for_LOS = list() // fresh play, thus fresh listeners who are compatible
	var/list/hearers = list()
	if(speaker.requires_LOS)
		hearers = get_hearers_in_view(10, player)
		for(var/mob/mob_hearing in hearers)
			if(mob_hearing.client)
				speaker.listeners_at_start_for_LOS.Add(mob_hearing.client)
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)
		if(speaker.tts)
			var/use_blips = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_blips)
			var/use_byond_audio = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_byond_audio)
			if(CONFIG_GET(flag/tts_force_html_audio))
				use_byond_audio = FALSE
			if(!use_byond_audio)
				if(use_blips)
					listener << output(list2params(list(speaker.blips_url, "channel_[speaker.assigned_channel]")), "html_audio_player:playAudio")
				else
					listener << output(list2params(list(speaker.url, "channel_[speaker.assigned_channel]")), "html_audio_player:playAudio")
		else
			listener << output(list2params(list(speaker.url, "channel_[speaker.assigned_channel]")), "html_audio_player:playAudio")

/datum/controller/subsystem/html_audio/proc/play_preview_audio(client/listener, url)
	jank_ass_browse_check(listener)
	listener << output(list2params(list(url)), "html_audio_preview_player:playAudio")

/datum/controller/subsystem/html_audio/proc/start_looping_audio(atom/movable/player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/datum/html_audio_speaker/speaker = speakers[player]
	if(!speaker)
		CRASH("Looping sound unheard / HTML audio unbound / HTML audio unbound - ChatGPT, \"Echoes Lost in Silence\", 5/24/2023")
	speaker.looping = TRUE
	for(var/client/listener in listeners)
		if(!listener)
			continue
		listener << output(list2params(list("true", "channel_[speaker.assigned_channel]")), "html_audio_player:setLooping")

/datum/controller/subsystem/html_audio/proc/stop_looping_audio(atom/movable/player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/datum/html_audio_speaker/speaker = speakers[player]
	if(!speaker)
		CRASH("Endless loop persists / HTML audio uncontrolled / Silence won't prevail - ChatGPT, \"Unbound Echoes\", 5/24/2023")
	speaker.looping = FALSE
	for(var/client/listener in listeners)
		if(!listener)
			continue
		listener << output(list2params(list("false", "channel_[speaker.assigned_channel]")), "html_audio_player:setLooping")
