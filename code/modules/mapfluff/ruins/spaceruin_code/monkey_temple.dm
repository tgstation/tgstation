
/obj/item/paper/crumpled/monkey_paw_discovery
	name = "crumpled notes - \"discovery\""
	default_raw_text = {"
		Honestly, when the asteroid crew told me they found a man-made structure inside of a random asteroid,
		I laughed. It's the kind of report that makes you wonder if mining asteroids is worth the space madness apparently included.<br>
		<br>
		Well, I visited the site anyways. And I can tell you, no space madness, there is some kind of temple in there. Creepy shit, too.<br>
		Here's how things are going to go:<br>
		• Most of the mining crew will be split to resume normal operations on... normal asteroids. No more weird shit, okay? You'll know if you're reassigned or not.<br>
		• The rest will continue to excavate the temple until we can get in.<br>
		• We sell everything inside and get filthy rich.<br>
		<br>
		It goes without saying, but keep this under wraps. Everyone, even those on normal operations will get their cut. No higher ups.<br>
		- Chief Prospector Bill Slater
	"}

/obj/item/paper/crumpled/muddy/to_samson
	name = "crumpled notes - \"to Samson\""
	default_raw_text = {"
		Samson,<br>
		<br>
		I'm incredibly happy to see you on the team. It's... kinda amazing to think we'll be working together.<br>
		Boss made some low-hanging jokes about us being twins, but he was totally on board.<br>
		<br>
		...Not that I don't trust you, but let me do the chemistry-intensive side of the job until you get your bearings.
		Everyone's been antsy since we found the ruins, so if you screw up, it's not only my ass, but I'm pretty sure
		he won't go light on the punishment. Don't wanna lose my job because I cronyism'd you a job.
		<br>
		Leon
	"}

/datum/id_trim/monkey_paw
	department_color = COLOR_DARK_MODERATE_ORANGE
	subdepartment_color = COLOR_DARK_MODERATE_ORANGE
	access = list(ACCESS_MINING, ACCESS_MINING_STATION)

/datum/id_trim/monkey_paw/prospector
	assignment = "Prospector"
	trim_state = "trim_detective"

/datum/id_trim/monkey_paw/biomining_engineer
	assignment = "Biomining Engineer"
	trim_state = "trim_chemist"

/datum/id_trim/monkey_paw/chief_prospector
	assignment = "Chief Prospector"
	trim_state = "trim_shaftminer"

/obj/item/card/id/advanced/prospector
	registered_name = "Bridget Stamos"
	trim = /datum/id_trim/monkey_paw/prospector
	registered_age = 25

/obj/item/card/id/advanced/biomining_engineer_one
	registered_name = "Leon Hansley"
	trim = /datum/id_trim/monkey_paw/biomining_engineer
	registered_age = 27

/obj/item/card/id/advanced/biomining_engineer_two
	registered_name = "Samson Hansley"
	trim = /datum/id_trim/monkey_paw/biomining_engineer
	registered_age = 22

/obj/item/card/id/advanced/chief_prospector
	registered_name = "Bill Slater"
	trim = /datum/id_trim/monkey_paw/chief_prospector
	registered_age = 43

/area/ruin/unpowered/monkey_temple
	name = "\improper Monkey Temple"

/area/shuttle/ruin/temple_mining_shuttle
	requires_power = TRUE
	name = "Derelict Asteroid Mining Shuttle"
