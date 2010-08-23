/obj/item/assembly
	name = "assembly"
	icon = 'assemblies.dmi'
	item_state = "assembly"
	var/status = 0.0
	throwforce = 10
	w_class = 3.0
	throw_speed = 4
	throw_range = 10

/obj/item/assembly/a_i_a
	name = "Health-Analyzer/Igniter/Armor Assembly"
	desc = "A health-analyzer, igniter and armor assembly."
	icon_state = "armor-igniter-analyzer"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/clothing/suit/armor/vest/part3 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/m_i_ptank
	desc = "A very intricate igniter and proximity sensor electrical assembly mounted onto top of a plasma tank."
	name = "Proximity/Igniter/Plasma Tank Assembly"
	icon_state = "prox-igniter-tank0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/prox_ignite
	name = "Proximity/Igniter Assembly"
	desc = "A proximity-activated igniter assembly."
	icon_state = "prox-igniter0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/r_i_ptank
	desc = "A very intricate igniter and signaller electrical assembly mounted onto top of a plasma tank."
	name = "Radio/Igniter/Plasma Tank Assembly"
	icon_state = "radio-igniter-tank"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/anal_ignite
	name = "Health-Analyzer/Igniter Assembly"
	desc = "A health-analyzer igniter assembly."
	icon_state = "timer-igniter0"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"

/obj/item/assembly/time_ignite
	name = "Timer/Igniter Assembly"
	desc = "A timer-activated igniter assembly."
	icon_state = "timer-igniter0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/t_i_ptank
	desc = "A very intricate igniter and timer assembly mounted onto top of a plasma tank."
	name = "Timer/Igniter/Plasma Tank Assembly"
	icon_state = "timer-igniter-tank0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_ignite
	name = "Radio/Igniter Assembly"
	desc = "A radio-activated igniter assembly."
	icon_state = "radio-igniter"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_infra
	name = "Signaller/Infrared Assembly"
	desc = "An infrared-activated radio signaller"
	icon_state = "infrared-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/infra/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_prox
	name = "Signaller/Prox Sensor Assembly"
	desc = "A proximity-activated radio signaller."
	icon_state = "prox-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/prox_sensor/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_time
	name = "Signaller/Timer Assembly"
	desc = "A radio signaller activated by a count-down timer."
	icon_state = "timer-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/timer/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/shock_kit
	name = "Shock Kit"
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/device/radio/electropack/part2 = null
	status = 0.0
	w_class = 5.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/weld_rod
	desc = "A welding torch with metal rods attached to the flame tip."
	name = "Welder/Rods Assembly"
	icon_state = "welder-rods"
	item_state = "welder"
	var/obj/item/weapon/weldingtool/part1 = null
	var/obj/item/weapon/rods/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/assembly/w_r_ignite
	desc = "A welding torch and igniter connected by metal rods."
	name = "Welder/Rods/Igniter Assembly"
	icon_state = "welder-rods-igniter"
	item_state = "welder"
	var/obj/item/weapon/weldingtool/part1 = null
	var/obj/item/weapon/rods/part2 = null
	var/obj/item/device/igniter/part3 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0