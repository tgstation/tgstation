/obj/item/weapon/storage/utilitybelt
	name = "utility belt"
	desc = "Can hold various tools."
	icon = 'old_or_unused.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list("/obj/item/weapon/crowbar","/obj/item/weapon/screwdriver","/obj/item/weapon/weldingtool","/obj/item/weapon/wirecutters","/obj/item/weapon/wrench","/obj/item/device/multitool","/obj/item/device/flashlight","/obj/item/weapon/cable_coil")
	flags = FPRINT | TABLEPASS | ONBELT

/obj/item/weapon/storage
	icon = 'storage.dmi'
	name = "storage"
	var/list/can_hold = new/list()
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	w_class = 3.0

/obj/item/weapon/storage/backpack
	name = "backpack"
	icon_state = "backpack"
	w_class = 4.0
	flags = 259.0

/obj/item/weapon/storage/pill_bottle
	name = "Pill bottle"
	icon_state = "pill_canister"
	icon = 'chemical.dmi'
	item_state = "contsolid"
	can_hold = list("/obj/item/weapon/reagent_containers/pill")

/obj/item/weapon/storage/box
	name = "Box"
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0

/obj/item/weapon/storage/disk_kit
	name = "Data Disks"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/disk_kit/disks

/obj/item/weapon/storage/disk_kit/disks2

/obj/item/weapon/storage/fcard_kit
	name = "Fingerprint Cards"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/firstaid
	name = "First-Aid"
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
/obj/item/weapon/storage/firstaid/fire
	name = "Fire First Aid"
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/weapon/storage/firstaid/syringes
	name = "Syringes (Biohazard Alert)"
	icon_state = "syringe"

/obj/item/weapon/storage/firstaid/toxin
	name = "Toxin First Aid"
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/weapon/storage/flashbang_kit
	desc = "<FONT color=red><B>WARNING: Do not use without reading these preautions!</B></FONT>\n<B>These devices are extremely dangerous and can cause blindness or deafness if used incorrectly.</B>\nThe chemicals contained in these devices have been tuned for maximal effectiveness and due to\nextreme safety precuaiotn shave been incased in a tamper-proof pack. DO NOT ATTEMPT TO OPEN\nFLASH WARNING: Do not use continually. Excercise extreme care when detonating in closed spaces.\n\tMake attemtps not to detonate withing range of 2 meters of the intended target. It is imperative\n\tthat the targets visit a medical professional after usage. Damage to eyes increases extremely per\n\tuse and according to range. Glasses with flash resistant filters DO NOT always work on high powered\n\tflash devices such as this. <B>EXERCISE CAUTION REGARDLESS OF CIRCUMSTANCES</B>\nSOUND WARNING: Do not use continually. Visit a medical professional if hearing is lost.\n\tThere is a slight chance per use of complete deafness. Exercise caution and restraint.\nSTUN WARNING: If the intended or unintended target is too close to detonation the resulting sound\n\tand flash have been known to cause extreme sensory overload resulting in temporary\n\tincapacitation.\n<B>DO NOT USE CONTINUALLY</B>\nOperating Directions:\n\t1. Pull detonnation pin. <B>ONCE THE PIN IS PULLED THE GRENADE CAN NOT BE DISARMED!</B>\n\t2. Throw grenade. <B>NEVER HOLD A LIVE FLASHBANG</B>\n\t3. The grenade will detonste 10 seconds hafter being primed. <B>EXCERCISE CAUTION</B>\n\t-<B>Never prime another grenade until after the first is detonated</B>\nNote: Usage of this pyrotechnic device without authorization is an extreme offense and can\nresult in severe punishment upwards of <B>10 years in prison per use</B>.\n\nDefault 3 second wait till from prime to detonation. This can be switched with a screwdriver\nto 10 seconds.\n\nCopyright of Nanotrasen Industries- Military Armnaments Division\nThis device was created by Nanotrasen Labs a member of the Expert Advisor Corporation"
	name = "Flashbangs (WARNING)"
	icon_state = "flashbang"
	item_state = "syringe_kit"

/obj/item/weapon/storage/emp_kit
	desc = "A box with 5 emp grenades."
	name = "Emp grenades"
	icon_state = "flashbang"
	item_state = "syringe_kit"

/obj/item/weapon/storage/gl_kit
	name = "Prescription Glasses"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/handcuff_kit
	name = "Spare Handcuffs"
	icon_state = "handcuff"
	item_state = "syringe_kit"

/obj/item/weapon/storage/id_kit
	name = "Spare IDs"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/lglo_kit
	name = "Latex Gloves"
	icon_state = "latex"
	item_state = "syringe_kit"

/obj/item/weapon/storage/injectbox
	name = "DNA-Injectors"
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/stma_kit
	name = "Sterile Masks"
	icon_state = "latex"
	item_state = "syringe_kit"

/obj/item/weapon/storage/trackimp_kit
	name = "Tracking Implant Kit"
	icon_state = "implant"
	item_state = "syringe_kit"


/obj/item/weapon/storage/toolbox
	name = "toolbox"
	icon = 'storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0

/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/bible
	name = "bible"
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/mob/affecting = null

/obj/item/weapon/storage/mousetraps
	name = "Pest-B-Gon Mousetraps"
	desc = "WARNING: Keep out of reach of children."
	icon_state = "mousetraps"
	item_state = "syringe_kit"

/obj/item/weapon/storage/donkpocket_kit
	name = "Donk-Pockets"
	desc = "Remember to fully heat prior to serving.  Product will cool if not eaten within seven minutes."
	icon_state = "donk_kit"
	item_state = "syringe_kit"