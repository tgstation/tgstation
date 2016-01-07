/datum/supply_packs/engineering/oxygen
	name = "Oxygen Canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "oxygen canister crate"

/datum/supply_packs/engineering/toxins
	name = "Toxins Canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/toxins)
	cost = 30
	containertype = /obj/structure/largecrate
	containername = "toxins canister crate"

/datum/supply_packs/engineering/nitrogen
	name = "Nitrogen Canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "nitrogen canister crate"

/datum/supply_packs/engineering/carbon_dio
	name = "Carbon Dioxide Canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	cost = 35
	containertype = /obj/structure/largecrate
	containername = "carbon dioxide canister crate"


/obj/machinery/hydroponics/unattached
	anchored = 0

/datum/supply_packs/organic/hydroponics/hydro_tray
	name = "Hydroponics Tray Kit"
	contains = list(/obj/item/weapon/circuitboard/hydroponics,
                   /obj/item/weapon/stock_parts/matter_bin,
                   /obj/item/weapon/stock_parts/matter_bin,
                   /obj/item/weapon/stock_parts/manipulator,
                   /obj/item/weapon/stock_parts/console_screen)
	cost = 10
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics kit"