/datum/animate_argument
	var/name
	var/description
	var/list/arg_types

/datum/animate_argument/object
	name = "Object"
	description = "The atom, image, or client to animate; omit to add another step to the same sequence as the last animate() call."
	arg_types = list( /atom, /image, /client )

/datum/animate_argument/var_list
	name = "var_list"
	description = "An associative list of vars to change."
	arg_types = list( /list )

/datum/animate_argument/appearance
	name = "appearance"
	description = "New appearance to use instead of multiple var changes."
	arg_types = list( /mutable_appearance )

/datum/animate_argument/time
	name = "time"
	description = "Time of this step, in 1/10s."
	arg_types = list( "number" )

/datum/animate_argument/loop
	name = "loop"
	description = "Number of times to run this sequence, or -1 to loop forever."
	arg_types = list( "number" )

/datum/animate_argument/easing
	name = "easing"
	description = "The \"curve\" followed by this animation step."
	arg_types = list( /datum/animate_easing, /datum/animate_easing_flag )

/datum/animate_argument/flags
	name = "flags"
	description = "Flags that impact how the animation acts."
	arg_types = list( /datum/animate_flag )

/datum/animate_argument/delay
	name = "delay"
	description = "Delay time for starting the first step in a sequence (may be negative)."
	arg_types = list( "number" )

/datum/animate_argument/tag
	name = "a_tag"
	description = "Optional name for a new animation sequence. The true parameter is \"tag\" however is a_tag for this editor to prevent issues."
	arg_types = list( "string" )

/datum/animate_argument/command
	name = "command"
	description = "Optional client command to run at the end of this step."
	arg_types = list( "string" )
