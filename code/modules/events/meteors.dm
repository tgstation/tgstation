//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 10
	endWhen			= 60

/datum/event/meteor_wave/setup()
	endWhen = rand(60, 120) + 10 //Goes from one minute to two minutes. Supposed to be a devastating event

/datum/event/meteor_wave/announce()
	command_alert("A meteor storm has been detected on collision course with the station. Seek shelter within the core of the station immediately.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')

/datum/event/meteor_wave/tick()
	meteor_wave(rand(25,50)) //Large waves, panic is mandatory

/datum/event/meteor_wave/end()
	command_alert("The station has cleared the meteor storm.", "Meteor Alert")

//
/datum/event/meteor_shower
	startWhen		= 10
	endWhen 		= 30

/datum/event/meteor_shower/setup()
	endWhen	= rand(30, 60) + 10 //From 30 seconds to one minute

/datum/event/meteor_shower/announce()
	command_alert("The station is about to be hit by a small-intensity meteor storm. Seek shelter within the core of the station immediately", "Meteor Alert")

//meteor showers are lighter and more common,
/datum/event/meteor_shower/tick()
	meteor_wave(rand(10,25)) //Much more clement

/datum/event/meteor_shower/end()
	command_alert("The station has cleared the meteor shower", "Meteor Alert")
