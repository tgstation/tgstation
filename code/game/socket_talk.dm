// Module used for fast interprocess communication between BYOND and other processes

/datum/socket_talk
	var
		enabled = 0
		dll = "./DLLSocket.so"
	New()
		..()
		src.enabled = config.socket_talk

		if(enabled)
			call(dll,"establish_connection")("127.0.0.1","8019")

	proc
		send_raw(message)
			if(enabled)
				return call(dll,"send_message")(message)
		receive_raw()
			if(enabled)
				return call(dll,"recv_message")()
		send_log(var/log, var/message)
			return send_raw("type=log&log=[log]&message=[message]")
		send_keepalive()
			return send_raw("type=keepalive")
		set_ticker_state(var/state)
			return send_raw("type=ticker_state&message=[state]")


var/global/datum/socket_talk/socket_talk
