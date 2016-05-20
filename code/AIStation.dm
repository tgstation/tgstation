/datum/socket_talk
	New()
		..()
		call("DLLSocket.dll","establish_connection")("127.0.0.1","1301")

	proc
		send_raw(message)
			call("DLLSocket.dll","establish_connection")("127.0.0.1","1301")
			return call("DLLSocket.dll","send_message")(message)
		receive_raw()
			call("DLLSocket.dll","establish_connection")("127.0.0.1","1301")
			return call("DLLSocket.dll","recv_message")()


//var/global/datum/socket_talk/socket_talk = new()

/proc/send_message(var/message)
	world.Export("127.0.0.1:1301?[message]")
	//return socket_talk.send_raw(message)
