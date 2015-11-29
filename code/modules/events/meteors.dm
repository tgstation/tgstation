/*
 * All meteor random events are in here
 * Right now we have small and medium. Apocalyptic huge would be button mashing, at least for now
 */

//Meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 0 //Note : Meteor waves have a delay before striking now
	endWhen			= 30

/datum/event/meteor_wave/setup()
	endWhen = rand(45, 90) //More drawn out than the shower, but not too powerful. Supposed to be a devastating event

/datum/event/meteor_wave/announce()
	command_alert("A meteor storm has been detected on collision course with the station. Seek shelter within the core of the station immediately.", "Meteor Alert")
	to_chat(world, sound('sound/AI/meteors.ogg'))

//One to three waves. So 10 to 60. Note that it used to be (20, 50) per wave with two to three waves
/datum/event/meteor_wave/tick()
	meteor_wave(rand(10, 15), max_size = 2) //Large waves, panic is mandatory

/datum/event/meteor_wave/end()
	command_alert("The station has cleared the meteor storm.", "Meteor Alert")

//One to two vawes
/datum/event/meteor_shower
	startWhen		= 0
	endWhen 		= 30

/datum/event/meteor_shower/setup()
	endWhen	= rand(30, 60) //From thirty seconds to one minute

/datum/event/meteor_shower/announce()
	command_alert("The station is about to be hit by a small-intensity meteor storm. Seek shelter within the core of the station immediately", "Meteor Alert")

//Meteor showers are lighter and more common
//Usually a single wave, rarely two, so anywhere from 5 to 20 small meteors
/datum/event/meteor_shower/tick()
	meteor_wave(rand(5, 10), max_size = 1) //Much more clement

/datum/event/meteor_shower/end()
	command_alert("The station has cleared the meteor shower", "Meteor Alert")

var/global/list/thing_storm_types = list(
	"meaty gore storm" = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		/obj/item/weapon/organ/head,
		/obj/item/weapon/organ/r_arm,
		/obj/item/weapon/organ/l_arm,
		/obj/item/weapon/organ/r_leg,
		/obj/item/weapon/organ/l_leg,
		/obj/item/weapon/organ/r_hand,
		/obj/item/weapon/organ/l_hand,
		/obj/item/weapon/organ/r_foot,
		/obj/item/weapon/organ/l_foot,
	),
	"sausage party" = list(
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
	),
)

/datum/event/thing_storm
	startWhen		= 10
	endWhen 		= 30

	var/storm_name = null

/datum/event/thing_storm/setup()
	endWhen	= rand(30, 60) + 10 //From 30 seconds to one minute
	var/list/possible_names=list()
	for(var/storm_id in thing_storm_types)
		possible_names += storm_id
	storm_name=pick(possible_names)

/datum/event/thing_storm/announce()
	command_alert("The station is about to be hit by a small-intensity meteor storm. Seek shelter within the core of the station immediately", "Meteor Alert")

//Meteor showers are lighter and more common
//Since this isn't rocks of pure pain and explosion, we have more, anywhere from 10 to 40 items
/datum/event/thing_storm/tick()
	meteor_wave(rand(10, 20), types = thing_storm_types[storm_name]) //Much more clement

/datum/event/thing_storm/end()
	command_alert("The station has cleared the [storm_name].", "Meteor Alert")
