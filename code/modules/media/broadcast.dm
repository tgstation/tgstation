// frequency => list(listeners)
var/global/media_receivers=list()
var/global/media_broadcasters=list()


///////////////////////
// RECEIVERS
///////////////////////

/obj/machinery/media/receiver
	var/media_frequency=123.4
	var/media_crypto = null

/obj/machinery/media/receiver/New()
	..()
	connect_frequency()

/obj/machinery/media/receiver/proc/receive_broadcast(var/url, var/start_time)
	media_url = url
	media_start_time = start_time
	update_music()

/obj/machinery/media/receiver/proc/connect_frequency()
	var/list/receivers=list()
	if(media_frequency in media_receivers)
		receivers = media_receivers[media_frequency]
	receivers.Add(src)
	media_receivers[media_frequency]=receivers

	if(media_frequency in media_broadcasters)
		var/obj/machinery/media/broadcaster/B = pick(media_broadcasters[media_frequency])
		receive_broadcast(B.media_url,B.media_start_time)

/obj/machinery/media/receiver/proc/disconnect_frequency()
	var/list/receivers=list()
	if(media_frequency in media_receivers)
		receivers = media_receivers[media_frequency]
	receivers.Remove(src)
	media_receivers[media_frequency]=receivers

	media_url=""
	media_start_time=0

	update_music()

///////////////////////
// BROADCASTERS
///////////////////////

/obj/machinery/media/broadcaster
	var/media_frequency=123.4
	var/media_crypto = null

/obj/machinery/media/broadcaster/New()
	..()
	connect_frequency()

/obj/machinery/media/broadcaster/proc/broadcast(var/url, var/start_time)
	media_url = url
	media_start_time = start_time
	update_music()

/obj/machinery/media/broadcaster/proc/connect_frequency()
	var/list/broadcasters=list()
	if(media_frequency in media_broadcasters)
		broadcasters = media_receivers[media_frequency]
	broadcasters.Add(src)
	media_broadcasters[media_frequency]=broadcasters


/obj/machinery/media/broadcaster/update_music()
	..()
	if(media_frequency in media_receivers)
		var/obj/machinery/media/receiver/R = pick(media_receivers[media_frequency])
		R.receive_broadcast(media_url,media_start_time)

/obj/machinery/media/broadcaster/proc/disconnect_frequency()
	var/list/broadcasters=list()
	if(media_frequency in media_broadcasters)
		broadcasters = media_receivers[media_frequency]
	broadcasters.Remove(src)
	media_broadcasters[media_frequency]=broadcasters

	media_url=""
	media_start_time=0

	update_music()
