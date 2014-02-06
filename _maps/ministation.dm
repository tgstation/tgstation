/*
MiniStation FAQ - Mod Created By Giacom


What is it?

A mod of tgstation 13 that is modified for low population servers; with simplified jobs, maps, duties and command structure.

How do I run it?

Simply tick this file, and only this file in the _maps folder, then compile and you will be running MiniStation.

Who is the target audience?

Server hosters who want to host a server for a player count of around 5 to 20 people.

What about the map?

The map has been created from the ground up with population size in mind.

What about the jobs?

Many jobs have been combined or just plainly cut out. These are the remaining jobs with their duties next to them.

 * Captain - Make sure your station is running.
 * HoP - You're second in command, protect the Captain and be his right hand man.
 * Cargo Tech x3 - Running cargo bay and mining minerals for the station.
 * Bartender - Keeping the bar, serving drinks and food. Hire the unemployeed to grow food for you, or do it yourself.
 * Janitor - Cleans the station, removes litter and empty trash bins to be recycled by the crusher.
 * Station Engineer x4 - Keeping the power running and fixing station damage.
 * Security Officer x4 - Protecting the crewmembers and serving space law.
 * Detective - Using forensic science to help security officers catch criminals.
 * Scientist x4 - Research and development of new technologies and create bombs.
 * Medical Doctor x4 - Healing the crew, performing surgeries and cloning dead crew.
 * Chemist - Creating useful chemicals for the crew to use.
 * Clown - Create laughter and boost the morale of the crew. Honk!
 * Assistant xInfinity - Not in charge at all.

There will be 26 job slots (not including Assistant) available on MiniStation; the HoP can add more from his ID computer.
There is a more simplified command system, with the Captain being the big boss and the HoP being second in command.
The heads will have control over all departments and jobs.

What else has changed?

Changes to the uplinks were made to discourage murderboning, the rest is the same.

*/

#if !defined(MAP_FILE)

        #include "map_files\MiniStation\MiniStation.dmm"

        #define MAP_FILE "MiniStation.dmm"
        #define MAP_NAME "MiniStation"

		#if !defined(MAP_OVERRIDE_FILES)
				#define MAP_OVERRIDE_FILES
				#include "map_files\MiniStation\misc.dm"
		        #include "map_files\MiniStation\supplypacks.dm"
		        #include "map_files\MiniStation\telecomms.dm"
		        #include "map_files\MiniStation\uplink_item.dm"
		        #include "map_files\MiniStation\job\jobs.dm"
		        #include "map_files\MiniStation\job\removed.dm"
		#endif

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring ministation.

#endif