SUBSYSTEM_DEF(html_audio)
	name = "HTML Audio"
	init_order = INIT_ORDER_HTMLAUDIO
	flags = SS_NO_FIRE
	var/max_channels = 512 // set this to how many total channels you want
	var/list/channel_assignment = list() // list([atom in the world], [atom in the world], ...) for keeping track of what channels are in use and by what
	var/list/channel_loop_status = list() // list([atom in the world] = TRUE/FALSE, ...) for keeping track of what channels are looping
	var/list/channel_tts_status = list() // list([atom in the world] = TRUE/FALSE, ...) for keeping track of what channels are TTS
	var/list/listeners = list() // list of client listeners to update when audio gets added
	var/list/active_urls = list() // list("url_here", ...), ref'd by active_urls[channel_id]
	var/list/list/channel_requires_LOS_at_start_listeners = list() // list(list(/client, ...)) complicated, used for LOS requirements on hearing speech
	var/list/channel_requires_LOS_at_start = list() // list([atom in the world] = TRUE/FALSE, ...) for keeping track of what channels require LOS at the start
	var/list/listener_handlers = list() // list([atom in the world] = listener_handler)
	var/browse_txt
	var/preview_browse_txt

/datum/controller/subsystem/html_audio/Initialize()
	browse_txt = {"
			<META http-equiv="X-UA-Compatible" content="IE=edge">"}
	for(var/i in 1 to max_channels)
		browse_txt += {"
			<audio id="channel_[i]" volume="0">
			</audio>"}
	browse_txt += {"
			<script>
			function setVolume(volume, element_id)
			{
				var audio_player = document.getElementById(element_id);
				audio_player.volume = parseFloat(volume);
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
	preview_browse_txt = {"
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
	channel_loop_status.len = max_channels
	channel_tts_status.len = max_channels
	active_urls.len = max_channels
	channel_requires_LOS_at_start.len = max_channels
	channel_requires_LOS_at_start_listeners.len = max_channels
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(register_listener))
	return SS_INIT_SUCCESS

/datum/listener_handler

/datum/listener_handler/proc/handle_listener_move(mob/listener, atom/old_loc)
	SIGNAL_HANDLER
	SShtml_audio.update_listener_volume(listener.client)

/datum/listener_handler/proc/deregister_listener_qdel(atom/movable/listener)
	SIGNAL_HANDLER
	UnregisterSignal(src, list(COMSIG_MOVABLE_MOVED))
	SShtml_audio.listener_handlers[listener] = null
	UnregisterSignal(src, list(COMSIG_MOB_LOGOUT))

/datum/listener_handler/proc/unregister_listener_logout(mob/old_listener)
	SIGNAL_HANDLER
	UnregisterSignal(src, list(COMSIG_MOVABLE_MOVED))
	SShtml_audio.listener_handlers[old_listener] = null
	UnregisterSignal(src, list(COMSIG_MOB_LOGOUT))

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
	for(var/i in 1 to max_channels) // New listener, so let's get them up to speed on all the channels.
		if(active_urls[i])
			if(channel_tts_status[i])
				var/use_blips = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_blips)
				var/use_byond_audio = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_byond_audio)
				if(CONFIG_GET(flag/tts_force_html_audio))
					use_byond_audio = FALSE
				if(!use_byond_audio)
					if(use_blips)
						listener << output(list2params(list(active_urls[i]["blips"], "channel_[i]")), "html_audio_player:playAudio")
					else
						listener << output(list2params(list(active_urls[i]["normal"], "channel_[i]")), "html_audio_player:playAudio")
			else
				listener << output(list2params(list(active_urls[i], "channel_[i]")), "html_audio_player:playAudio")
		if(channel_loop_status[i])
			listener << output(list2params(list("true", "channel_[i]")), "html_audio_player:setLooping")
		else
			listener << output(list2params(list("false", "channel_[i]")), "html_audio_player:setLooping")

/datum/controller/subsystem/html_audio/proc/update_listener_volume(client/listener)
	for(var/i in 1 to max_channels)
		var/volume_to_use = 0
		var/distance = get_dist(channel_assignment[i], listener.mob)
		var/turf/speaker_turf = get_turf(channel_assignment[i])
		var/turf/listener_turf = get_turf(listener.mob)
		if(!channel_assignment[i] || distance >= 10 || (channel_requires_LOS_at_start[i] && !(listener in channel_requires_LOS_at_start_listeners[i])) || (channel_tts_status[i] && listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_byond_audio)))
			volume_to_use = 0
		else
			if(channel_tts_status[i])
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
		listener << output(list2params(list(num2text(volume_to_use), "channel_[i]")), "html_audio_player:setVolume")

/datum/controller/subsystem/html_audio/proc/jank_ass_browse_check(checked_person)
	if (!winexists(checked_person, "html_audio_player"))
		checked_person << browse(browse_txt, "window=html_audio_player&file=html_audio_player.htm")
	if (!winexists(checked_person, "html_audio_preview_player"))
		checked_person << browse(browse_txt, "window=html_audio_preview_player&file=html_audio_preview_player.htm")

/datum/controller/subsystem/html_audio/proc/register_player(atom/movable/player, requires_LOS = FALSE)
	var/assigned = FALSE
	for(var/i in 1 to max_channels) // Go through the channels, find the first empty slot and get in there.
		if(isnull(channel_assignment[i]))
			assigned = TRUE
			channel_assignment[i] = player
			if(requires_LOS)
				channel_requires_LOS_at_start[i] = TRUE
			RegisterSignal(player, COMSIG_MOVABLE_MOVED, PROC_REF(handle_player_move))
			RegisterSignal(player, COMSIG_PARENT_QDELETING, PROC_REF(deregister_player_qdel))
			break
	if(!assigned)
		CRASH("YO WE OUT OF FUCKING CHANNELS ABORT ABORT ABORT TOO MANY FUCKING THINGS GOT HTML AUDIO REEL THAT SHIT IN BRO BACK THAT ASS UP")
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)

/datum/controller/subsystem/html_audio/proc/deregister_player_qdel(atom/movable/player)
	SIGNAL_HANDLER
	UnregisterSignal(player, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	deregister_player(player)

/datum/controller/subsystem/html_audio/proc/handle_player_move(atom/movable/player, atom/old_loc)
	SIGNAL_HANDLER
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)

/datum/controller/subsystem/html_audio/proc/deregister_player(atom/movable/player)
	UnregisterSignal(player, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	var/current_channel = channel_assignment.Find(player)
	channel_assignment[current_channel] = null
	active_urls[current_channel] = null
	channel_loop_status[current_channel] = null
	channel_tts_status[current_channel] = null
	channel_requires_LOS_at_start[current_channel] = null
	channel_requires_LOS_at_start_listeners[current_channel] = null
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)

/datum/controller/subsystem/html_audio/proc/play_audio(atom/movable/player, url, blips_url = null)
	stop_looping_audio(player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/our_id = channel_assignment.Find(player)
	if(!our_id)
		CRASH("YO SOME FUCKER JUST TRIED TO PLAY AUDIO WITHOUT REGISTERING, BOO THIS FUCKER")
	if(blips_url)
		active_urls[our_id] = list("normal" = url, "blips" = blips_url)
		channel_tts_status[our_id] = TRUE
	else
		active_urls[our_id] = url
		channel_tts_status[our_id] = null
	channel_requires_LOS_at_start_listeners[our_id] = list() // fresh play, thus fresh listeners who are compatible
	var/list/hearers = list()
	if(channel_requires_LOS_at_start[our_id])
		hearers = get_hearers_in_view(10, player)
		for(var/mob/mob_hearing in hearers)
			if(mob_hearing.client)
				channel_requires_LOS_at_start_listeners[our_id].Add(mob_hearing.client) // the linter can kiss my ass
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)
		if(channel_tts_status[our_id])
			var/use_blips = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_blips)
			var/use_byond_audio = listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_byond_audio)
			if(CONFIG_GET(flag/tts_force_html_audio))
				use_byond_audio = FALSE
			if(!use_byond_audio)
				if(use_blips)
					listener << output(list2params(list(active_urls[our_id]["blips"], "channel_[our_id]")), "html_audio_player:playAudio")
				else
					listener << output(list2params(list(active_urls[our_id]["normal"], "channel_[our_id]")), "html_audio_player:playAudio")
		else
			listener << output(list2params(list(active_urls[our_id], "channel_[our_id]")), "html_audio_player:playAudio")

/datum/controller/subsystem/html_audio/proc/play_preview_audio(client/listener, url)
	jank_ass_browse_check(listener)
	listener << output(list2params(list(url)), "html_audio_preview_player:playAudio")

/datum/controller/subsystem/html_audio/proc/start_looping_audio(atom/movable/player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/our_id = channel_assignment.Find(player)
	if(!our_id)
		CRASH("YO SOME FUCKER JUST TRIED TO LOOP AUDIO WITHOUT REGISTERING, BOO THIS FUCKER")
	channel_loop_status[our_id] = TRUE
	for(var/client/listener in listeners)
		if(!listener)
			continue
		listener << output(list2params(list("true", "channel_[our_id]")), "html_audio_player:setLooping")

/datum/controller/subsystem/html_audio/proc/stop_looping_audio(atom/movable/player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/our_id = channel_assignment.Find(player)
	if(!our_id)
		CRASH("YO SOME FUCKER JUST TRIED TO NOT LOOP AUDIO WITHOUT REGISTERING, BOO THIS FUCKER")
	channel_loop_status[our_id] = FALSE
	for(var/client/listener in listeners)
		if(!listener)
			continue
		listener << output(list2params(list("false", "channel_[our_id]")), "html_audio_player:setLooping")
