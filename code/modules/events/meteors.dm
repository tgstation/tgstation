//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 10
	endWhen			= 60

/datum/event/meteor_wave/setup()
	endWhen = rand(20,30)*3 //Goes from two minutes to three minutes. Supposed to be a devastating event

/datum/event/meteor_wave/announce()
	command_alert("A meteor storm been detected on collision course with the station. Seek shelter within the core of the station immediately.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')

/datum/event/meteor_wave/tick()
	meteor_wave(rand(25,75)) //Large waves, panic is mandatory

/datum/event/meteor_wave/end()
	command_alert("The station has cleared the meteor storm.", "Meteor Alert")

//
/datum/event/meteor_shower
	startWhen		= 10
	endWhen 		= 30

/datum/event/meteor_shower/setup()
	endWhen	= rand(10,25)*3

/datum/event/meteor_shower/announce()
	command_alert("The station is about to be hit by a small-intensity meteor storm.", "Meteor Alert")

//meteor showers are lighter and more common,
/datum/event/meteor_shower/tick()
	meteor_wave(rand(5,25)) //Much more clement

/datum/event/meteor_shower/end()
	command_alert("The station has cleared the meteor shower", "Meteor Alert")
