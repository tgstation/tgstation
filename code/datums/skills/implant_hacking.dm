/datum/skill/implant_hacking
	name = "Protocol Hijacking"
	title = "Hacker"
	desc = "My knowledge of cybernetic protocols, and how to make them compatible with eachother"
	modifiers = list(SKILL_TIME_MODIFIER = list(-2, -1, 0, 1, 2, 4, 8))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/hacker

/datum/skill/implant_hacking/New()
	. = ..()
	levelUpMessages[1] = "<span class='nicegreen'>The circuitry is complex, but I'm starting to make sense of it.</span>"
	levelUpMessages[4] = "<span class='nicegreen'>I understand how these machines work on a fundamental level.</span>"
	levelUpMessages[6] = "<span class='nicegreen'>I know all of the protocols, all of encoding, security and operating software! No digital barrier can now stop me.</span>"
