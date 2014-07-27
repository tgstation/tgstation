var/global/media_transmitters=list()

///////////////////////
// BROADCASTERS
///////////////////////

/obj/machinery/media/transmitter
	var/media_frequency = 1234 // 123.4 MHz
	var/media_crypto    = null // No crypto keys.

/obj/machinery/media/transmitter/New()
	..()
	connect_frequency()

/obj/machinery/media/transmitter/proc/broadcast(var/url="", var/start_time=0)
	media_url = url
	media_start_time = start_time
	update_music()

/obj/machinery/media/transmitter/proc/connect_frequency()
	var/list/transmitters=list()
	if(media_frequency in media_transmitters)
		transmitters = media_transmitters[media_frequency]
	transmitters.Add(src)
	media_transmitters[media_frequency]=transmitters


/obj/machinery/media/transmitter/update_music()
	//..()
	if(media_frequency in media_receivers)
		for(var/obj/machinery/media/receiver/R in media_receivers[media_frequency])
			if(R.media_crypto == media_crypto)
				R.receive_broadcast(media_url,media_start_time)

/obj/machinery/media/transmitter/proc/disconnect_frequency()
	var/list/transmitters=list()
	if(media_frequency in media_transmitters)
		transmitters = media_transmitters[media_frequency]
	transmitters.Remove(src)
	media_transmitters[media_frequency]=transmitters

	broadcast()
