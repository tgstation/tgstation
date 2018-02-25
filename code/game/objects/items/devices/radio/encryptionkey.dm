/obj/item/device/encryptionkey
	name = "standard encryption key"
	var/standard_description = "An encryption key for a radio headset."
	var/available_channels = "Has no special codes in it. WHY DOES IT EXIST? ASK NANOTRASEN."
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	w_class = WEIGHT_CLASS_TINY
	var/translate_binary = FALSE
	var/syndie = FALSE
	var/independent = FALSE
	var/list/channels = list()

/obj/item/device/encryptionkey/Initialize()
 	. = ..()	//I'm assuming this is right and necessary
	desc = standard_description + " " + available_channels

/obj/item/device/encryptionkey/syndicate
	name = "syndicate encryption key"
	available_channels = "To access the syndicate channel, use :t."
	icon_state = "syn_cypherkey"
	channels = list("Syndicate" = 1)
	syndie = 1//Signifies that it de-crypts Syndicate transmissions

/obj/item/device/encryptionkey/binary
	name = "binary translator key"
	available_channels = "To access the binary channel, use :b."
	icon_state = "bin_cypherkey"
	translate_binary = TRUE

/obj/item/device/encryptionkey/headset_sec
	name = "security radio encryption key"
	available_channels = "To access the security channel, use :s."
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1)

/obj/item/device/encryptionkey/headset_eng
	name = "engineering radio encryption key"
	available_channels = "To access the engineering channel, use :e."
	icon_state = "eng_cypherkey"
	channels = list("Engineering" = 1)

/obj/item/device/encryptionkey/headset_rob
	name = "robotics radio encryption key"
	available_channels = "To access the engineering channel, use :e. For research, use :n."
	icon_state = "rob_cypherkey"
	channels = list("Science" = 1, "Engineering" = 1)

/obj/item/device/encryptionkey/headset_med
	name = "medical radio encryption key"
	available_channels = "To access the medical channel, use :m."
	icon_state = "med_cypherkey"
	channels = list("Medical" = 1)

/obj/item/device/encryptionkey/headset_sci
	name = "science radio encryption key"
	available_channels = "To access the science channel, use :n."
	icon_state = "sci_cypherkey"
	channels = list("Science" = 1)

/obj/item/device/encryptionkey/headset_medsci
	name = "medical research radio encryption key"
	available_channels = "To access the medical channel, use :m. For science, use :n."
	icon_state = "medsci_cypherkey"
	channels = list("Science" = 1, "Medical" = 1)

/obj/item/device/encryptionkey/headset_com
	name = "command radio encryption key"
	if(CONFIG_GET(flag/command_channel))	//uses the default channel description otherwise
		available_channels = "To access the command channel, use :c."
		channels = list("Command" = 1)
	icon_state = "com_cypherkey"

/obj/item/device/encryptionkey/heads/captain
	name = "\proper the captain's encryption key"
	if(CONFIG_GET(flag/command_channel))
		available_channels = "Channels are as follows: :c - command, :s - security, :e - engineering, :u - supply, :v - service, :m - medical, :n - science."
		channels = list("Command" = 1, "Security" = 1, "Engineering" = 0, "Science" = 0, "Medical" = 0, "Supply" = 0, "Service" = 0)
	else
		available_channels = "Channels are as follows: :s - security, :e - engineering, :u - supply, :v - service, :m - medical, :n - science."
		channels = list("Security" = 1, "Engineering" = 0, "Science" = 0, "Medical" = 0, "Supply" = 0, "Service" = 0)
	icon_state = "cap_cypherkey"

/obj/item/device/encryptionkey/heads/rd
	name = "\proper the research director's encryption key"
	if(CONFIG_GET(flag/command_channel))
		available_channels = "To access the science channel, use :n. For command, use :c."
		channels = list("Science" = 1, "Command" = 1)
	else
		available_channels = "To access the science channel, use :n."
		channels = list("Science" = 1)
	icon_state = "rd_cypherkey"

/obj/item/device/encryptionkey/heads/hos
	name = "\proper the head of security's encryption key"
	if(CONFIG_GET(flag/command_channel))
		available_channels = "To access the security channel, use :s. For command, use :c."
		channels = list("Security" = 1, "Command" = 1)
	else
		available_channels = "To access the security channel, use :s."
		channels = list("Security" = 1)
	icon_state = "hos_cypherkey"

/obj/item/device/encryptionkey/heads/ce
	name = "\proper the chief engineer's encryption key"
	if(CONFIG_GET(flag/command_channel))
		available_channels = "To access the engineering channel, use :e. For command, use :c."
		channels = list("Engineering" = 1, "Command" = 1)
	else
		available_channels = "To access the engineering channel, use :e."
		channels = list("Engineering" = 1)
	icon_state = "ce_cypherkey"

/obj/item/device/encryptionkey/heads/cmo
	name = "\proper the chief medical officer's encryption key"
	if(CONFIG_GET(flag/command_channel))
		available_channels = "To access the medical channel, use :m. For command, use :c."
		channels = list("Medical" = 1, "Command" = 1)
	else
		available_channels = "To access the medical channel, use :m."
		channels = list("Medical" = 1)
	icon_state = "cmo_cypherkey"

/obj/item/device/encryptionkey/heads/hop
	name = "\proper the head of personnel's encryption key"
	if(CONFIG_GET(flag/command_channel))
		available_channels = "Channels are as follows: :u - supply, :v - service, :c - command."
		channels = list("Supply" = 1, "Service" = 1, "Command" = 1)
	else
		available_channels = "Channels are as follows: :u - supply, :v - service."
		channels = list("Supply" = 1, "Service" = 1)
	icon_state = "hop_cypherkey"

/obj/item/device/encryptionkey/headset_cargo
	name = "supply radio encryption key"
	available_channels = "To access the supply channel, use :u."
	icon_state = "cargo_cypherkey"
	channels = list("Supply" = 1)

/obj/item/device/encryptionkey/headset_mining
	name = "mining radio encryption key"
	available_channels = "To access the supply channel, use :u. For science, use :n."
	icon_state = "cargo_cypherkey"
	channels = list("Supply" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_service
	name = "service radio encryption key"
	available_channels = "To access the service channel, use :v."
	icon_state = "srv_cypherkey"
	channels = list("Service" = 1)

/obj/item/device/encryptionkey/headset_cent
	name = "\improper CentCom radio encryption key"
	available_channels = "To access the CentCom channel, use :y."
	icon_state = "cent_cypherkey"
	independent = TRUE
	channels = list("CentCom" = 1)

/obj/item/device/encryptionkey/ai //ported from NT, this goes 'inside' the AI.
	if(CONFIG_GET(flag/command_channel))
		channels = list("Command" = 1, "Security" = 1, "Engineering" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1, "AI Private" = 1)
	else
		channels = list("Security" = 1, "Engineering" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1, "AI Private" = 1)

/obj/item/device/encryptionkey/secbot
	channels = list("AI Private"=1,"Security"=1)
