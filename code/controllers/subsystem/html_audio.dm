SUBSYSTEM_DEF(html_audio)
	name = "HTML Audio"
	init_order = INIT_ORDER_HTMLAUDIO
	flags = SS_NO_FIRE
	var/max_channels = 256 // set this to how many total channels you want
	var/list/channel_assignment = list() // list([atom in the world], [atom in the world], ...) for keeping track of what channels are in use and by what
	var/list/channel_loop_status = list() // list([atom in the world] = TRUE/FALSE, ...) for keeping track of what channels are looping
	var/list/listeners = list() // list of client listeners to update when audio gets added
	var/list/active_urls = list() // list("url_here", ...), ref'd by active_urls[channel_id]
	var/list/channel_requires_LOS_at_start_listeners = list() // list(list(/client, ...)) complicated, used for LOS requirements on hearing speech
	var/list/channel_requires_LOS_at_start = list() // list([atom in the world] = TRUE/FALSE, ...) for keeping track of what channels require LOS at the start
	var/browse_txt

/datum/controller/subsystem/html_audio/Initialize()
	// TODO: rewrite this shit lmfao
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
	channel_assignment.len = max_channels
	channel_loop_status.len = max_channels
	active_urls.len = max_channels
	channel_requires_LOS_at_start.len = max_channels
	channel_requires_LOS_at_start_listeners.len = max_channels
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(register_listener))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/html_audio/proc/register_listener(datum/source, mob/new_login)
	list_clear_nulls(listeners)
	var/client/listener = new_login.client
	if(!listeners.Find(listener))
		listeners += listener
		listener << browse(browse_txt, "window=html_audio_player&file=html_audio_player.htm")
	RegisterSignal(listener.mob, COMSIG_MOVABLE_MOVED, PROC_REF(handle_listener_move)) // calls update_listener_volume
	RegisterSignal(listener.mob, COMSIG_MOB_LOGOUT, PROC_REF(unregister_listener_logout))
	update_listener_volume(listener)
	for(var/i in 1 to max_channels) // New listener, so let's get them up to speed on all the channels.
		if(active_urls[i])
			listener << output(list2params(list(active_urls[i], "channel_[i]")), "html_audio_player:playAudio")
		if(channel_loop_status[i])
			listener << output(list2params(list("true", "channel_[i]")), "html_audio_player:setLooping")
		else
			listener << output(list2params(list("false", "channel_[i]")), "html_audio_player:setLooping")

/datum/controller/subsystem/html_audio/proc/update_listener_volume(client/listener)
	for(var/i in 1 to max_channels)
		var/volume_to_use = 0
		var/distance = get_dist(channel_assignment[i], listener.mob)
		if(!channel_assignment[i] || distance >= 10 || (channel_requires_LOS_at_start[i] && !(listener in channel_requires_LOS_at_start_listeners[i])) || !listener.prefs.read_preference(/datum/preference/toggle/sound_tts_use_html_audio))
			volume_to_use = 0
		else
			volume_to_use = (1-(1/10*distance))**2
		listener << output(list2params(list(num2text(volume_to_use), "channel_[i]")), "html_audio_player:setVolume")

/datum/controller/subsystem/html_audio/proc/handle_listener_move(mob/listener, atom/old_loc)
	SIGNAL_HANDLER
	update_listener_volume(listener.client)

/datum/controller/subsystem/html_audio/proc/unregister_listener_logout(mob/old_listener)
	SIGNAL_HANDLER
	UnregisterSignal(old_listener, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_LOGOUT))

/datum/controller/subsystem/html_audio/proc/jank_ass_browse_check(checked_person)
	if (!winexists(checked_person, "html_audio_player"))
		checked_person << browse(browse_txt, "window=html_audio_player&file=html_audio_player.htm")

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
	var/current_channel = channel_assignment.Find(player)
	channel_assignment[current_channel] = null
	active_urls[current_channel] = null
	channel_loop_status[current_channel] = null
	channel_requires_LOS_at_start[current_channel] = null
	channel_requires_LOS_at_start_listeners[current_channel] = null
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)

/datum/controller/subsystem/html_audio/proc/play_audio(atom/movable/player, url)
	stop_looping_audio(player)
	list_clear_nulls(listeners) // clients be like *poof* mid proc
	var/our_id = channel_assignment.Find(player)
	if(!our_id)
		CRASH("YO SOME FUCKER JUST TRIED TO PLAY AUDIO WITHOUT REGISTERING, BOO THIS FUCKER")
	active_urls[our_id] = url
	channel_requires_LOS_at_start_listeners[our_id] = list() // fresh play, thus fresh listeners who are compatible
	var/list/hearers = list()
	if(channel_requires_LOS_at_start[our_id])
		hearers = get_hearers_in_view(10, player)
		for(var/mob/mob_hearing in hearers)
			if(mob_hearing.client)
				channel_requires_LOS_at_start_listeners[our_id].Add(mob_hearing.client)
	for(var/client/listener in listeners)
		if(!listener)
			continue
		update_listener_volume(listener)
		listener << output(list2params(list(url, "channel_[our_id]")), "html_audio_player:playAudio")

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
