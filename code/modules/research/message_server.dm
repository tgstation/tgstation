/datum/data_pda_msg
	var/recipient = "Unspecified" //name of the person
	var/sender = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message

/datum/data_pda_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "")
	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message

/datum/data_rc_msg
	var/rec_dpt = "Unspecified" //name of the person
	var/send_dpt = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "",var/param_stamp = "",var/param_id_auth = "",var/param_priority)
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(1)
				priority = "Normal"
			if(2)
				priority = "High"
			if(3)
				priority = "Extreme"
			else
				priority = "Undetermined"

/obj/machinery/message_server
	icon = 'stationobjs.dmi'
	icon_state = "server"
	name = "Messaging Server"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()

/obj/machinery/message_server/proc/send_pda_message(var/recipient = "",var/sender = "",var/message = "")
	pda_msgs += new/datum/data_pda_msg(recipient,sender,message)

/obj/machinery/message_server/proc/send_rc_message(var/recipient = "",var/sender = "",var/message = "",var/stamp = "", var/id_auth = "", var/priority = 1)
	rc_msgs += new/datum/data_rc_msg(recipient,sender,message,stamp,id_auth)

/obj/machinery/message_server/attack_hand(user as mob)
	user << "\blue There seem to be some parts missing from this server. They should arrive on the station in a few days, give or take a few CentCom delays."



/obj/machinery/blackbox_recorder
	icon = 'stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/messages = list()
	var/messages_admin = list()

	var/msg_common = list()
	var/msg_science = list()
	var/msg_command = list()
	var/msg_medical = list()
	var/msg_engineering = list()
	var/msg_security = list()
	var/msg_deathsquad = list()
	var/msg_syndicate = list()
	var/msg_mining = list()
	var/msg_cargo = list()