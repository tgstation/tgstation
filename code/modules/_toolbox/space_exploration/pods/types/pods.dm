/*
* Large Pod (2x2)
*/

/obj/pod/large
	size = list(2, 2)
	icon_state = "pod_civ"
	icon = 'icons/oldschool/spacepods/pod-2-2.dmi'

	pre_equipped/

		GetArmor()
			return new /obj/item/pod_attachment/armor/light(src)

		GetEngine()
			return new /obj/item/pod_attachment/engine/plasma(src)

		GetAdditionalAttachments()
			return list(new /obj/item/pod_attachment/shield/plasma(src), new /obj/item/pod_attachment/cargo/small(src))

	light/
		name = "light pod"

		GetSeats()
			return 1

	gold/
		name = "golden pod"
		icon_state = "pod_gold"
		move_cooldown = 1.5

		GetArmor()
			return new /obj/item/pod_attachment/armor/gold(src)

		GetSeats()
			return 1

	heavy/
		name = "heavy pod"
		icon_state = "pod_mil"
		health = 300

		GetArmor()
			return new /obj/item/pod_attachment/armor/heavy(src)

		GetSeats()
			return 1

	syndicate/
		name = "syndicate pod"
		icon_state = "pod_synd"
		health = 300

		GetArmor()
			return new /obj/item/pod_attachment/armor/heavy(src)

		GetAdditionalAttachments()
			return list(new /obj/item/pod_attachment/cargo/large(src), new /obj/item/pod_attachment/shield/plasma(src))

		GetPowercell()
			return new /obj/item/stock_parts/cell/super(src)

		GetSeats()
			return 2

	industrial/
		name = "industrial pod"
		icon_state = "pod_industrial"
		health = 350
		move_cooldown = 3

		GetAdditionalAttachments()
			return list(new /obj/item/pod_attachment/cargo/industrial(src))

		GetArmor()
			return new /obj/item/pod_attachment/armor/industrial(src)

		GetSeats()
			return 1

	prototype/
		name = "prototype pod"
		icon_state = "pod_black"
		health = 400

		GetArmor()
			return new /obj/item/pod_attachment/armor/prototype(src)

		GetSeats()
			return 2

	precursor/
		name = "precursor pod"
		icon_state = "pod_pre"
		health = 450

		GetArmor()
			return new /obj/item/pod_attachment/armor/precursor(src)

		GetSeats()
			return 2

/*
* Small Pods (miniputts, 1x1)
*/

/obj/pod/small
	name = "miniputt"
	health = 100
	move_cooldown = 1.8

	GetSeats()
		return 0

	pre_equipped/

		GetArmor()
			return new /obj/item/pod_attachment/armor/light(src)

		GetEngine()
			new /obj/item/pod_attachment/engine/plasma(src)

		GetAdditionalAttachments()
			return list(new /obj/item/pod_attachment/shield/plasma(src), new /obj/item/pod_attachment/cargo/small(src))

	light/
		name = "light miniputt"
		icon_state = "miniputt"
		health = 100

	gold/
		name = "golden miniputt"
		icon_state = "putt_gold"
		move_cooldown = 1.3
		health = 100

		GetArmor()
			return new /obj/item/pod_attachment/armor/gold(src)

	heavy/
		name = "heavy miniputt"
		icon_state = "nanoputt"
		health = 150

		GetArmor()
			return new /obj/item/pod_attachment/armor/heavy(src)

	syndicate/
		name = "syndicate miniputt"
		icon_state = "syndiputt"
		health = 150

		GetArmor()
			return new /obj/item/pod_attachment/armor/heavy(src)

		GetAdditionalAttachments()
			return list(new /obj/item/pod_attachment/cargo/large(src), new /obj/item/pod_attachment/shield/plasma(src))

		GetPowercell()
			return new /obj/item/stock_parts/cell/super(src)

	industrial/
		name = "industrial miniputt"
		icon_state = "indyputt"
		health = 200

		GetArmor()
			return new /obj/item/pod_attachment/armor/industrial(src)

	prototype/
		name = "prototype miniputt"
		icon_state = "putt_black"
		health = 300

		GetArmor()
			return new /obj/item/pod_attachment/armor/prototype(src)

	precursor/
		name = "precursor miniputt"
		icon_state = "putt_pre"
		health = 350

		GetArmor()
			return new /obj/item/pod_attachment/armor/precursor(src)
