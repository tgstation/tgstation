/datum/skill/implant_hacking
	name = "Protocol Hijacking"
	title = "Hacker"
	desc = "My knowledge of cybernetic protocols, and how to make them compatible with eachother"
	modifiers = list(SKILL_TIME_MODIFIER = list(-2, -1, 0, 1, 2, 4, 8))
	skill_item_path = /obj/item/clothing/neck/cloak/skill_reward/hacker

/datum/skill/implant_hacking/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("The circuitry is complex, but I'm starting to make sense of it.")
	levelUpMessages[4] = span_nicegreen("I understand how these machines work on a fundamental level.")
	levelUpMessages[6] = span_nicegreen("I know all of the protocols, all of encoding, security and operating software! No digital barrier can now stop me.")


/obj/item/clothing/neck/cloak/skill_reward/hacker
	name = "legendary hacker's cloak"
	desc = "Worn by the most skilled of cybernetic hackers, wearing this proves you were able to conquer protocol, and hack any cybernetic. You are not sure if openly wearing an item of clothing that says 'I'm a master in breaking security protocols' is a good idea."
	icon = 'monkestation/code/modules/cybernetics/icons/cloaks.dmi'
	worn_icon = 'monkestation/code/modules/cybernetics/icons/neck.dmi'
	icon_state = "hackercloak"
	associated_skill_path = /datum/skill/implant_hacking
