//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 10
	endWhen			= 60

/datum/event/meteor_wave/setup()
	endWhen = rand(10,20)*3

/datum/event/meteor_wave/announce()
	command_alert("Meteors have been detected on collision course with the station. Seek shelter within the core of the station.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')

/datum/event/meteor_wave/tick()
	meteor_wave(rand(20,50)) //Step it up

/datum/event/meteor_wave/end()
	command_alert("The station has cleared the meteor storm.", "Meteor Alert")

//
/datum/event/meteor_shower
	startWhen		= 10
	endWhen 		= 30

/datum/event/meteor_shower/setup()
	endWhen	= rand(5,10)*3

/datum/event/meteor_shower/announce()
	command_alert("The station is now in a meteor shower.", "Meteor Alert")

//meteor showers are lighter and more common,
/datum/event/meteor_shower/tick()
	meteor_wave(rand(5,30))

/datum/event/meteor_shower/end()
	command_alert("The station has cleared the meteor shower", "Meteor Alert")
