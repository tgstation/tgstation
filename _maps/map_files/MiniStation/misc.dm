// Override global variables here!

var/datum/map_config/MiniStation = new()

/datum/map_config/New()
	..()
	accessable_z_levels = list("1" = 20, "4" = 40, "5" = 40) // Restrict the map to the non-empty z levels, which were all combined in MiniStation

// Enable all headsets by default in MiniStation, we don't worry about spam here.
// Also both heads are in charge of everything, give them all department channels.

/obj/item/device/encryptionkey/heads/New()
	..()
	// Give all channels and turn everything on
	channels = list("Command" = 1, "Security" = 1, "Engineering" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1)

/obj/item/weapon/paper/generator
	name = "paper - 'generator instructions'"
	info = "<h2>How to setup the Thermo-Generator</h2><ol>	<li>To the top right is a room full of canisters; to the bottom there is a room full of pipes. Connect C02 canisters to the pipe room's top connector ports, the cansisters will help act as a buffer so only remove them when refilling the gas..</li>	<li>Connect 3 plasma and 2 oxygen canisters to the bottom ports of the pipe room.</li>	<li>Turn on all the pumps and valves in the room except for the one connected to the yellow pipe and red pipe, no adjustments to the pump strength needed.</li>	<li>Look into the camera monitor to see the burn chamber. When it is full of plasma, press the igniter button.</li>	<li>Setup the SMES cells in the North West of Engineering and set an input of half the max; and an output that is half the input.</li></ol>Well done, you should have a functioning generator generating power. If the generator stops working, and there is enough gas and it's hot and cold, it might mean there is too much pressure and you need to turn on the pump that is connected to the red and yellow pipes to release the pressure. Make sure you don't take out too much pressure though.<br>You optimize the generator you must work out how much power your station is using and lowering the circulation pumps enough so that the generator doesn't create excess power, and it will allow the generator to powering the station for a longer duration, without having to replace the canisters. "