/datum/event/spaceninja

	Announce()

		if((world.time/10)>=3600 && toggle_space_ninja && !sent_ninja_to_station)//If an hour has passed, relatively speaking. Also, if ninjas are allowed to spawn and if there is not already a ninja for the round.
			space_ninja_arrival()//Handled in space_ninja.dm. Doesn't announce arrival, all sneaky-like.