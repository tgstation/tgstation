

			// BANES //

//	These are basically small weaknesses that affect your character in certain circumstances.
// As a rule, they should be specific as to when they happen, or have only some certain
// drawback.

// (core ideas)
// SENSITIVE: 	You are slightly blinded by bright lights.
// DARKFRIEND: 	Your automatic healing is at a crawl when in bright light.
// TRADITIONAL:	Every five minutes spent outside a coffin lowers your rate of automatic healing.
// CONSUMED:	Every five minutes spent outside a coffin increases the rate at which you consume blood.
// GOURMAND:	Animals and blood bags offer you no nourishment when feeding.
// DEATHMASK:	You no longer fake having a heartbeat, and always show up as pale when examined.
// BESTIAL:		When your blood is low, you will twitch involuntarily.

// (alternate ideas)
// STERILE:		There is a high chance that turning corpses to Bloodsuckers will fail, and further attempts on them by you are impossible.
// FERAL:		You're a threat to Vampire-kind: New Bloodsuckers may have an Objective to destroy you.
// UNHOLY:		The Chapel, the Bible, and Holy Water set you on fire.
// PARANOID:	Only your own claimed coffin counts for healing and banes.


// 	ON LEVEL-UP:
// Burn Damage increases
// Regen Rate increases
// Max Punch Damage increase
// Reset Level Timer
// Select Bane


// How to Burn Vamps:
//		C.adjustFireLoss(20)
//		C.adjust_fire_stacks(6)
//		C.IgniteMob()


/datum/antagonist/bloodsucker/proc/AssignRandomBane()
	return