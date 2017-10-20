//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Patient occasionally and uncontrollably channels an eldritch god when speaking."
	scan_desc = "godwoken syndrome"
	gain_text = "<span class='notice'>You feel a higher power inside your mind...</span>"
	lose_text = "<span class='notice'>The divinity leaves your head, no longer interested.</span>"
	var/next_speech = 0

/datum/brain_trauma/special/godwoken/on_say(message)
	if(world.time > next_speech && prob(10))
		playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)
		var/cooldown = voice_of_god(message, owner, list("colossus","yell"), 2)
		cooldown *= 0.33
		next_speech = world.time + cooldown
		return ""
	else
		return message