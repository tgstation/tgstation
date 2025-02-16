/obj/item/sensor_device/command_bodyguard
	name = "command bodyguard's handheld monitor"
	desc = "A unique model of handheld crew monitor that seems to have been customized for Executive Protection purposes."
	icon = 'modular_doppler/modular_jobs/command_bodyguard/icons/device.dmi'
	icon_state = "scanner"

/obj/item/sensor_device/command_bodyguard/attack_self(mob/user)
	GLOB.bodyguard_crewmonitor.show(user,src)
