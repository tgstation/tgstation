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
	name = "Hydroponics Tray"
	contains = list(/obj/machinery/hydroponics/unattached)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "hydropnics tray crate"

// Misc

/obj/item/weapon/paper/generator
	name = "paper - 'generator instructions'"
	info = "<h2>How to setup the Thermo-Generator</h2><ol>	<li>To the top right is a room full of canisters; to the bottom there is a room full of pipes. Connect C02 canisters to the pipe room's top connector ports, the cansisters will help act as a buffer so only remove them when refilling the gas..</li>	<li>Connect 3 plasma and 2 oxygen canisters to the bottom ports of the pipe room.</li>	<li>Turn on all the pumps and valves in the room except for the one connected to the yellow pipe and red pipe, no adjustments to the pump strength needed.</li>	<li>Look into the camera monitor to see the burn chamber. When it is full of plasma, press the igniter button.</li>	<li>Setup the SMES cells in the North West of Engineering and set an input of half the max; and an output that is half the input.</li></ol>Well done, you should have a functioning generator generating power. If the generator stops working, and there is enough gas and it's hot and cold, it might mean there is too much pressure and you need to turn on the pump that is connected to the red and yellow pipes to release the pressure. Make sure you don't take out too much pressure though.<br>You optimize the generator you must work out how much power your station is using and lowering the circulation pumps enough so that the generator doesn't create excess power, and it will allow the generator to powering the station for a longer duration, without having to replace the canisters. "