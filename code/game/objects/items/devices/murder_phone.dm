/obj/item/weapon/device/murder_phone //It's a play on murderbone, geddit? GEDDIT???
	name = "phone"
	desc = "A nondescript phone that looks very old."
	icon = 'icons/obj/device.dmi'
	icon_state = "80s_phone"
	w_class = 2
	var/on_cooldown = 0
	var/spam_prevention = 0
	var/cooldown_time = 1200 //2 minutes
	var/names = list("Alex", "Tony", "Jill", "John", "Angela", "Damian", "Ty", "Wilson", "Becky", "Bernice", "Raphael", "Eve", "Ava", "Ash")
	var/locations = list("the medbay", "the brig", "cargo", "the head of personnel's office", "the bar", "science", "escape", "botany", "the chapel", "engineering", "atmospherics", "arrivals")
	var/goodbyes = list("keep it discreet", "dress to impress", "do it quickly", "ensure people know about it", "wear a nice suit", "wear your mask for the party", "don't get caught")

/obj/item/weapon/device/murder_phone/attack_self(mob/user)
	if(spam_prevention)
		return
	spam_prevention = 1
	user << "<span class='notice'>You hold up \the [src] to your ear...</span>"
	sleep(60)
	if(on_cooldown)
		user << "<span class='notice'>Nothing but dial tone.</span>"
		spam_prevention = 0
		return
	user << "<span class='notice'>The dial tone cuts out and you hear a distant phone ringing.</span>"
	sleep(50) //Messages only show to the user since it's a phone, not a loudspeaker
	user << "\icon [src] <i>Hi, this is [pick(names)] at [pick(locations)]. I need you to deliver a package here. Just bring it down when you're ready. Remember: [pick(goodbyes)]!</i>"
	sleep(10)
	user << "\icon [src] <i><b>...click!</b></i>"
	spam_prevention = 0
	on_cooldown = 1
	sleep(cooldown_time)
	on_cooldown = 0
