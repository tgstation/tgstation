///Abuzer Mech, uzayda şimşek makkuin gibi gidiyo.
/obj/vehicle/sealed/mecha/voyager/decouverte
	desc = "A Voyager class exploration mech, combines quantum physics and bluespace technology to achieve immense speeds in vaccum. Not advised to use in the station. R&D recommends using an exosuit drill when searching for ruins in space."
	name = "\improper Decouverte"
	base_icon_state = "decouverte"
	allow_diagonal_movement = TRUE
	max_temperature = 65000
	max_integrity = 350
	lights_power = 7
	armor = list(MELEE = 40, BULLET = 40, LASER = 20, ENERGY = 30, BOMB = 60, BIO = 0, FIRE = 100, ACID = 100) //Uzaydaki "etkenlerden"(daha görmeden ateş eden syndicate gemisi taretleri, revolverlı npc'ler) tek yememesi için orta seviye zırh.
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters/exploration),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	wreckage = /obj/structure/mecha_wreckage/decouverte
	mech_type = EXOSUIT_MODULE_DECOUVERTE
	enter_delay = 7 		//Sürücülerimizin uzayda meche girmeye çalışırken boğulmasını istemeyiz
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | OMNIDIRECTIONAL_ATTACKS
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)

	/// Mechin uzaydaki hızı. Daha düşük sayı = daha hızlı.
	var/bas_gaza = 0.5
	/// Mechin normal basınçtaki hızı
	var/bas_frene = 4



/obj/vehicle/sealed/mecha/voyager/decouverte/Move()
	. = ..()
	update_pressure()

/obj/vehicle/sealed/mecha/voyager/decouverte/proc/diagonal_movement_2x()  //Mechler köşelere hareket ederken 2 adımlık süreyle gidiyor, bu uzayda hızlı hızlı uçarken sinir bozucu oluyordu.

	if(moving_diagonally)
		movedelay = (bas_gaza / 2)
	else
		movedelay = bas_gaza


// Hızlı mı yavaş mı gidecek check procu.

/obj/vehicle/sealed/mecha/voyager/decouverte/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(space_equipment_pressure_check(T))
		diagonal_movement_2x()			//Sadece uzaydayken çağrılması için bunun altında. Umarım checklerde sıkıntı yaratmaz.
		stepsound = 'sound/machines/clockcult/ocularwarden-dot1.ogg'	//Ses her stepte tekrarlandığı için kısa, jetpackimsi ve kullanılmayan bir ses gerekiyordu, o ses bu.
		turnsound = 'sound/machines/clockcult/ocularwarden-dot2.ogg'
		step_energy_drain = 1								 //Uzayda çok mesafe kat edileceği için step başı enerji harcaması düşük olmalı.
		icon_state = "decouverte-flight"

	else
		movedelay = bas_frene
		stepsound = 'sound/mecha/powerloader_step.ogg'  //5 ay önce tgmc den getirmişler sesleri hmmmmmmm.
		turnsound = 'sound/mecha/powerloader_turn2.ogg'
		step_energy_drain = 15 							//İstasyonda çok yakıyor.
		icon_state = "decouverte"
