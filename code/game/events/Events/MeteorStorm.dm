/datum/event/meteorstorm

	Announce()
		command_alert("The station is now in a meteor shower", "Meteor Alert")

	Tick()
		if (prob(40))
			meteor_wave()

	Die()
		command_alert("The station has cleared the meteor shower", "Meteor Alert")