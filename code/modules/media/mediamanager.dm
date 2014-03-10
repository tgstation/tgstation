/**********************
 * AWW SHIT IT'S TIME FOR RADIO
 *
 * Concept stolen from D2K5
 *
 * Rewritten (except for player HTML) by N3X15
 ***********************/

// Open up WMP and play musique.
// TODO: Convert to VLC for cross-platform and ogg support. - N3X
var/const/PLAYER_HTML={"
	<OBJECT id='player' CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' type='application/x-oleobject'></OBJECT>
	<script>
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume) {
	var player = document.getElementById('player');
	player.URL = url;
	player.Controls.currentPosition = time;
	player.Settings.volume = volume;
}
	</script>"}

// Hook into the events we desire.
/hook_handler/soundmanager
	// Set up player on login
	proc/OnLogin(var/list/args)
		var/client/C = args["client"]
		C.media = new /datum/media_manager(C)
		C.media.open()

	// Update when moving between areas.
	proc/OnMobAreaChange(var/list/args)
		var/mob/M = args["mob"]

		M.update_music()

/mob/proc/update_music()
	if (client)
		if(client.media)
			client.media.update_music()

/area
	// One media source per area.
	var/obj/machinery/media/media_source = null

/datum/media_manager
	var/url = ""
	var/start_time = 0
	var/volume = 100

	var/client/owner

	New(var/mob/holder)
		src.owner=holder

	// Actually pop open the player in the background.
	proc/open()
		owner << browse(PLAYER_HTML, "window=rpane.hosttracker")
		send_update()

	// Tell the player to play something via JS.
	proc/send_update()
		owner << output(list2params(list(url, (world.timeofday - start_time) / 10, volume)), "rpane.hosttracker:SetMusic")

	// Scan for media sources and use them.
	proc/update_music()
		var/targetURL = ""
		var/targetStartTime = 0
		var/targetVolume = 100

		if (owner)
			var/area/A = get_area()
			var/obj/machinery/media/M = A.media_source
			if(M.playing)
				targetURL = M.media_url
				targetStartTime = M.media_start_time

		if (url != targetURL || abs(targetStartTime - start_time) > 1 || targetVolume != volume)
			url = targetURL
			start_time = targetStartTime
			volume = targetVolume

			send_update()