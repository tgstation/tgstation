////////////////////////////////
///// Construction datums //////
////////////////////////////////

#define MAINBOARD	4
#define PERIBOARD	6
#define TARGBOARD	8
#define ARMOR_PLATES	17

/datum/construction/reversible/mecha
	var/base_icon = "ripley"
	var/mainboard = /obj/item/weapon/circuitboard/mecha/ripley/main
	var/peripherals = /obj/item/weapon/circuitboard/mecha/ripley/peripherals

	steps = list(
					//1
					list(Co_DESC="External armor is wrenched.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} external armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfasten{s} the external armor layer.")
					 	),
					//2
					 list(Co_DESC="External armor is installed.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} external armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} external armor layer from {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} removing the external reinforced armor...",
					 		Co_DELAY = 30,)
					 	),
					 //3
					 list(Co_DESC="Internal armor is welded.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/plasteel,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} install{s} external reinforced armor layer to {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} installing the external reinforced armor...",
					 		Co_DELAY = 30),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} cut{s} internal armor layer from {HOLDER}.")
					 	),
					 //4
					 list(Co_DESC="Internal armor is wrenched",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfastens the internal armor layer.")
					 	),
					 //5
					 list(Co_DESC="Internal armor is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} internal armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} internal armor layer from {HOLDER}.")
					 	),
					 //6
					 list(Co_DESC="Peripherals control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/metal,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} install{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the peripherals control module.")
					 	),
					 //7
					 list(Co_DESC="Peripherals control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the peripherals control module."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the peripherals control module from {HOLDER}.")
					 	),
					 //8
					 list(Co_DESC="Central control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the peripherals control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the mainboard.")
					 	),
					 //9
					 list(Co_DESC="Central control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the mainboard."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the central control module from {HOLDER}.")
					 	),
					 //10
					 list(Co_DESC="The wiring is adjusted",
						Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the central control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} disconnect{s} the wiring of {HOLDER}.")
					 	),
					 //11
					 list(Co_DESC="The wiring is added",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wirecutters,
					 		Co_VIS_MSG = "{USER} adjust{s} the wiring of {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} remove{s} the wiring of {HOLDER}.")
					 	),
					 //12
					 list(Co_DESC="The hydraulic systems are active.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
					 		Co_AMOUNT = 10,
					 		Co_VIS_MSG = "{USER} add{s} the wiring to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} deactivate{s} {HOLDER} hydraulic systems.")
					 	),
					 //13
					 list(Co_DESC="The hydraulic systems are connected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} activate{s} {HOLDER} hydraulic systems."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} disconnect{s} {HOLDER} hydraulic systems.")
					 	),
					 //14
					 list(Co_DESC="The hydraulic systems are disconnected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} connect{s} {HOLDER} hydraulic systems.")
					 	)
					)

/datum/construction/reversible/mecha/New()
	..()
	if(src)
		add_board_keys()

/datum/construction/reversible/mecha/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	holder.icon_state = "[base_icon][steps.len - index - diff]"
	return 1

/datum/construction/reversible/mecha/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/proc/add_board_keys()
	var/list/board_step = get_forward_step(steps.len - MAINBOARD)
	board_step[Co_KEY] = mainboard

	board_step = get_forward_step(steps.len - PERIBOARD)
	board_step[Co_KEY] = peripherals

/datum/construction/reversible/mecha/spawn_result(mob/user as mob)
	..()
	feedback_inc("mecha_[base_icon]_created",1)
	return

// custom_actions moved to construction_datum - N3X


/datum/construction/reversible/mecha/ripley
	result = "/obj/mecha/working/ripley"

/datum/construction/reversible/mecha/firefighter
	result = "/obj/mecha/working/ripley/firefighter"
	steps = list(
					//1
					list(Co_DESC="External armor is wrenched.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} external armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfasten{s} the external armor layer.")
					 	),
					//2
					 list(Co_DESC="External armor is installed.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} external armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} external armor layer from {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} removing the external reinforced armor...",
					 		Co_DELAY = 50,)
					 	),
					 //3
					 list(Co_DESC="Internal armor is welded.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/plasteel,
					 		Co_AMOUNT = 10,
					 		Co_VIS_MSG = "{USER} install{s} external reinforced armor layer to {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} installing the external reinforced armor...",
					 		Co_DELAY = 50),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} cut{s} internal armor layer from {HOLDER}.")
					 	),
					 //4
					 list(Co_DESC="Internal armor is wrenched",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfasten{s} the internal armor layer.")
					 	),
					 //5
					 list(Co_DESC="Internal armor is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} internal armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} internal armor layer from {HOLDER}.")
					 	),
					 //6
					 list(Co_DESC="Peripherals control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/metal,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} install{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the peripherals control module.")
					 	),
					 //7
					 list(Co_DESC="Peripherals control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the peripherals control module."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the peripherals control module from {HOLDER}.")
					 	),
					 //8
					 list(Co_DESC="Central control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the peripherals control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the mainboard.")
					 	),
					 //9
					 list(Co_DESC="Central control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the mainboard."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the central control module from {HOLDER}.")
					 	),
					 //10
					 list(Co_DESC="The wiring is adjusted",
						Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the central control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} disconnect{s} the wiring of {HOLDER}.")
					 	),
					 //11
					 list(Co_DESC="The wiring is added",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wirecutters,
					 		Co_VIS_MSG = "{USER} adjust{s} the wiring of {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} remove{s} the wiring of {HOLDER}.")
					 	),
					 //12
					 list(Co_DESC="The hydraulic systems are active.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
					 		Co_AMOUNT = 10,
					 		Co_VIS_MSG = "{USER} add{s} the wiring to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} deactivate{s} {HOLDER} hydraulic systems.")
					 	),
					 //13
					 list(Co_DESC="The hydraulic systems are connected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} activate{s} {HOLDER} hydraulic systems."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} disconnect{s} {HOLDER} hydraulic systems.")
					 	),
					 //14
					 list(Co_DESC="The hydraulic systems are disconnected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} connect{s} {HOLDER} hydraulic systems.")
					 	)
					)


/datum/construction/reversible/mecha/odysseus
	result = "/obj/mecha/medical/odysseus"
	base_icon = "odysseus"

	mainboard = /obj/item/weapon/circuitboard/mecha/odysseus/main
	peripherals = /obj/item/weapon/circuitboard/mecha/odysseus/peripherals

/datum/construction/reversible/mecha/combat
	var/targeting = /obj/item/weapon/circuitboard/mecha/gygax/targeting
	var/armor_plates = /obj/item/mecha_parts/part/gygax_armour

	steps = list(
					//1
					list(Co_DESC="External armor is wrenched.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} armor plates to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfasten{s} the armor plates.")
					 	),
					//2
					 list(Co_DESC="External armor is installed.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} armor plates."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} armor plates from {HOLDER}.",
					 		Co_DELAY = 30,
					 		Co_START_MSG = "{USER} begin{s} removing the armor plates...")
					 	),
					 //3
					 list(Co_DESC="Internal armor is welded.",
					 	Co_NEXTSTEP = list(Co_KEY=null, //set by proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} armor plates to {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} installing the armor plates...",
					 		Co_DELAY = 30),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} cut{s} internal armor layer from {HOLDER}.")
					 	),
					 //4
					 list(Co_DESC="Internal armor is wrenched",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfasten{s} the internal armor layer.")
					 	),
					 //5
					 list(Co_DESC="Internal armor is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} internal armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} internal armor layer from {HOLDER}.")
					 	),
					 //6
					 list(Co_DESC="Advanced capacitor is secured",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/metal,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} install{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the advanced capacitor.")
					 	),
					 //7
					 list(Co_DESC="Advanced capacitor is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the advanced capacitor."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the advanced capacitor from {HOLDER}.")
					 	),
					 //8
					 list(Co_DESC="Advanced scanner module is secured",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/stock_parts/capacitor/adv,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} advanced capacitor to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the Advanced scanner module.")
					 	),
					 //9
					 list(Co_DESC="Advanced scanner module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the advanced scanner module."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the advanced scanner module from {HOLDER}.")
					 	),
					 //10
					 list(Co_DESC="Targeting module is secured",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/stock_parts/scanning_module/adv,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} advanced scanner module to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the targeting module.")
					 	),
					 //11
					 list(Co_DESC="Targeting module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the targeting module."),
					 	Co_BACKSTOP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the targeting module from {HOLDER}.")
					 	),
					 //12
					 list(Co_DESC="Peripherals control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY= null, //set by proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the targeting module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the peripherals control module.")
					 	),
					 //13
					 list(Co_DESC="Peripherals control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the peripherals control module."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the peripherals control module from {HOLDER}.")
					 	),
					 //14
					 list(Co_DESC="Central control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the peripherals control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the mainboard.")
					 	),
					 //15
					 list(Co_DESC="Central control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the mainboard."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the central control module from {HOLDER}.")
					 	),
					 //16
					 list(Co_DESC="The wiring is adjusted",
						Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the central control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} disconnect{s} the wiring of {HOLDER}.")
					 	),
					 //17
					 list(Co_DESC="The wiring is added",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wirecutters,
					 		Co_VIS_MSG = "{USER} adjust{s} the wiring of {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} remove{s} the wiring of {HOLDER}.")
					 	),
					 //18
					 list(Co_DESC="The hydraulic systems are active.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
					 		Co_AMOUNT = 10,
					 		Co_VIS_MSG = "{USER} add{s} the wiring to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} deactivate{s} {HOLDER} hydraulic systems.")
					 	),
					 //19
					 list(Co_DESC="The hydraulic systems are connected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} activate{s} {HOLDER} hydraulic systems."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} disconnect{s} {HOLDER} hydraulic systems.")
					 	),
					 //20
					 list(Co_DESC="The hydraulic systems are disconnected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} connect{s} {HOLDER} hydraulic systems.")
					 	)
					)

/datum/construction/reversible/mecha/combat/add_board_keys()
	var/list/board_step = get_forward_step(steps.len - MAINBOARD)
	board_step[Co_KEY] = mainboard

	board_step = get_forward_step(steps.len - PERIBOARD)
	board_step[Co_KEY] = peripherals

	board_step = get_forward_step(steps.len - TARGBOARD)
	board_step[Co_KEY] = targeting

	if(armor_plates)
		board_step = get_forward_step(steps.len - ARMOR_PLATES)
		board_step[Co_KEY] = armor_plates

/datum/construction/reversible/mecha/combat/gygax
	base_icon = "gygax"
	mainboard = /obj/item/weapon/circuitboard/mecha/gygax/main
	peripherals = /obj/item/weapon/circuitboard/mecha/gygax/peripherals
	targeting = /obj/item/weapon/circuitboard/mecha/gygax/targeting
	armor_plates = /obj/item/mecha_parts/part/gygax_armour
	result = "/obj/mecha/combat/gygax"

/datum/construction/reversible/mecha/combat/durand
	mainboard = /obj/item/weapon/circuitboard/mecha/durand/main
	peripherals = /obj/item/weapon/circuitboard/mecha/durand/peripherals
	targeting = /obj/item/weapon/circuitboard/mecha/durand/targeting
	armor_plates = /obj/item/mecha_parts/part/durand_armour
	result = "/obj/mecha/combat/durand"
	base_icon = "durand"

/datum/construction/reversible/mecha/honker
	base_icon = "honker"
	result = "/obj/mecha/combat/honker"
	steps = list(
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/bikehorn,
					 		Co_VIS_MSG = "{USER} adds the bike horn to {HOLDER}",
					 		Co_AMOUNT = 1),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the clown boots from {HOLDER}.")
					 	),//1
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/clothing/shoes/clown_shoes,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} put{s} clown boots on {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/bikehorn)
					 	),//2
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/bikehorn),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the clown wig and mask from {HOLDER}.")
					 	),//3
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/clothing/mask/gas/clown_hat,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} put{s} clown wig and mask on {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/bikehorn)
					 	),//4
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/bikehorn),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} uninstall{s} the weapon control module.")
					 	),//5
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/circuitboard/mecha/honker/targeting,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the weapon control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/bikehorn)
					 	),//6
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/bikehorn),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} uninstall{s} the peripherals control module.")
					 	),//7
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/circuitboard/mecha/honker/peripherals,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the peripherals control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/bikehorn)
					 	),//8
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/bikehorn),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} uninstall{s} the central control module.")
					 	),//9
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/circuitboard/mecha/honker/main,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the central control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY = /obj/item/weapon/bikehorn)
					 	),//10
					 list(
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/bikehorn)
					 	)//11
					 )

/datum/construction/reversible/mecha/honker/set_desc()
	return

/datum/construction/reversible/mecha/honker/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	if(istype(used_atom, /obj/item/weapon/bikehorn))
		playsound(holder, 'sound/items/bikehorn.ogg', 50, 1)
		user.visible_message("HONK!")

	holder.icon_state = "honker_chassis"
	return 1

/datum/construction/reversible/mecha/honker/add_board_keys()
	return


/datum/construction/reversible/mecha/phazon
	base_icon = "phazon"
	mainboard = /obj/item/weapon/circuitboard/mecha/phazon/main
	peripherals = /obj/item/weapon/circuitboard/mecha/phazon/peripherals
	result = "/obj/mecha/combat/phazon"

	steps = list(
					//1
					list(Co_DESC="External armor is wrenched.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} external armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfasten{s} the external armor layer.")
					 	),
					//2
					 list(Co_DESC="External armor is installed.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} external armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} external armor layer from {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} removing the external reinforced armor...",
					 		Co_DELAY = 30,)
					 	),
					 //3
					 list(Co_DESC="Internal armor is welded.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/plasteel,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} install{s} external reinforced armor layer to {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} installing the external reinforced armor...",
					 		Co_DELAY = 30),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} cut{s} internal armor layer from {HOLDER}.")
					 	),
					 //4
					 list(Co_DESC="Internal armor is wrenched",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/weldingtool,
					 		Co_AMOUNT = 3,
					 		Co_VIS_MSG = "{USER} weld{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} unfastens the internal armor layer.")
					 	),
					 //5
					 list(Co_DESC="Internal armor is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} secure{s} internal armor layer."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} internal armor layer from {HOLDER}.")
					 	),

					 //6
					 list(Co_DESC="Phaze array is secured",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/metal,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} install{s} internal armor layer to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the phaze array.")
					 	),
					 //7
					 list(Co_DESC="Phaze array is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the phaze array."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the phaze array from {HOLDER}.")
					 	),
					 //8
					 list(Co_DESC="Peripherals control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY= /obj/item/mecha_parts/part/phazon_phase_array,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} phaze array to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the peripherals control module.")
					 	),
					 //9
					 list(Co_DESC="Peripherals control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the peripherals control module."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the peripherals control module from {HOLDER}.")
					 	),
					 //10
					 list(Co_DESC="Central control module is secured",
					 	Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the peripherals control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} the mainboard.")
					 	),
					 //11
					 list(Co_DESC="Central control module is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} secure{s} the mainboard."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} remove{s} the central control module from {HOLDER}.")
					 	),
					 //12
					 list(Co_DESC="The wiring is adjusted",
						Co_NEXTSTEP = list(Co_KEY= null, //set by a proc
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the central control module into {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} disconnect{s} the wiring of {HOLDER}.")
					 	),
					 //13
					 list(Co_DESC="The wiring is added",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wirecutters,
					 		Co_VIS_MSG = "{USER} adjust{s} the wiring of {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} remove{s} the wiring of {HOLDER}.")
					 	),
					 //14
					 list(Co_DESC="The hydraulic systems are active.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
					 		Co_AMOUNT = 10,
					 		Co_VIS_MSG = "{USER} add{s} the wiring to {HOLDER}."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} deactivate{s} {HOLDER} hydraulic systems.")
					 	),
					 //15
					 list(Co_DESC="The hydraulic systems are connected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} activate{s} {HOLDER} hydraulic systems."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} disconnect{s} {HOLDER} hydraulic systems.")
					 	),
					 //16
					 list(Co_DESC="The hydraulic systems are disconnected.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/wrench,
					 		Co_VIS_MSG = "{USER} connect{s} {HOLDER} hydraulic systems.")
					 	)
					)