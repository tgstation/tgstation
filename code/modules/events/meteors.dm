//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 10
	endWhen			= 30

/datum/event/meteor_wave/setup()
	endWhen = rand(30, 60) + 10 //Goes from one minute to two minutes. Supposed to be a devastating event

/datum/event/meteor_wave/announce()
	command_alert("A meteor storm has been detected on collision course with the station. Seek shelter within the core of the station immediately.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')

/datum/event/meteor_wave/tick()
	meteor_wave(rand(25,50), max_size=2) //Large waves, panic is mandatory

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
	meteor_wave(rand(10,25), max_size=1) //Much more clement

/datum/event/meteor_shower/end()
	command_alert("The station has cleared the meteor shower", "Meteor Alert")

var/global/list/thing_storm_types = list(
	"meaty gore storm" = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
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

	var/storm_name=null

/datum/event/thing_storm/setup()
	endWhen	= rand(30, 60) + 10 //From 30 seconds to one minute
	var/list/possible_names=list()
	for(var/storm_id in thing_storm_types)
		possible_names += storm_id
	storm_name=pick(possible_names)

/datum/event/thing_storm/announce()
	command_alert("The station is about to be hit by a small-intensity meteor storm. Seek shelter within the core of the station immediately", "Meteor Alert")

//meteor showers are lighter and more common,
/datum/event/thing_storm/tick()
	meteor_wave(rand(10,25), types=thing_storm_types[storm_name]) //Much more clement

/datum/event/thing_storm/end()
	command_alert("The station has cleared the [storm_name].", "Meteor Alert")
