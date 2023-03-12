SUBSYSTEM_DEF(html_audio)
	name = "HTML Audio"
	init_order = INIT_ORDER_HTMLAUDIO
	flags = SS_NO_FIRE
	/// Number of channels available. Basically, the amount of different sound files that can all be playing at once.
	var/max_channels = 256
	/// Active url, in the form of an assoc list: url = channel_id
	var/list/active_urls = list()
	/// Browser data that handles audio channels
	var/browse_txt
	/// Current channel that is available. Increments by 1 every time it is read from.
	var/current_channel_id = 1

/datum/controller/subsystem/html_audio/Initialize()
	// Ideally, channels should be created and removed when sounds are played,
	// but this'll work for now.
	browse_txt = {"
			<META http-equiv="X-UA-Compatible" content="IE=edge">"}
	for(var/i in 1 to max_channels)
		browse_txt += {"
			<audio id="channel_[i]" volume="1">
			</audio>"}
	browse_txt += {"
			<script>
			function setVolume(volume, element_id)
			{
				var audio_player = document.getElementById(element_id);
				if(audio_player) {
					audio_player.volume = parseFloat(volume);
				}
			}
			function playAudio(url, element_id)
			{
				var audio_player = document.getElementById(element_id);
				if(!audio_player) {
					return;
				}
				audio_player.pause();
				audio_player.src = url;
				audio_player.load();
				audio_player.play();
			}
			</script>
	"}
	active_urls.len = max_channels
	RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(setup_client))
	for(var/client/player in GLOB.clients)
		setup_client(SSdcs, player)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/html_audio/proc/setup_client(datum/source, client/player)
	SIGNAL_HANDLER
	player << browse(browse_txt, "window=html_audio_player&file=html_audio_player.htm")

/// Plays a sound file for a client on a channel using a text_url.
/datum/controller/subsystem/html_audio/proc/play_sound_for_client(client/player, text_url, channel)
	player << output(list2params(list(text_url, "channel_[channel]")), "html_audio_player:playAudio")

/datum/controller/subsystem/html_audio/proc/get_next_channel()
	var/last_channel = current_channel_id
	if(current_channel_id >= max_channels)
		current_channel_id = 1
		return last_channel
	current_channel_id++
	return last_channel

/datum/controller/subsystem/html_audio/proc/play_audio(url, list/players_to_play_for)
	var/url_channel_id = get_next_channel()
	active_urls[url] = url_channel_id

	for(var/client/listener as anything in players_to_play_for)
		if(QDELETED(listener))
			continue
		if(ismob(listener))
			var/mob/listener_mob = listener
			listener = listener_mob.client
		play_sound_for_client(listener, url, url_channel_id)
