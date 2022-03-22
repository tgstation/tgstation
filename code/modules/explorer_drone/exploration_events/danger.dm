/// Danger event - unskippable, if you have appriopriate tool you can mitigate damage.
/datum/exploration_event/simple/danger
	root_abstract_type = /datum/exploration_event/simple/danger
	description = "You encounter a giant error."
	var/required_tool = EXODRONE_TOOL_LASER
	var/has_tool_action_text = "Fight"
	var/no_tool_action_text = "Endure"
	var/has_tool_description = ""
	var/no_tool_description = ""
	var/avoid_log = "Escaped unharmed from danger."
	var/damage = 30
	skippable = FALSE

/datum/exploration_event/simple/danger/get_description(obj/item/exodrone/drone)
	. = ..()
	var/list/desc_parts = list(.)
	desc_parts += can_escape_danger(drone) ? has_tool_description : no_tool_description
	return desc_parts.Join("\n")

/datum/exploration_event/simple/danger/get_action_text(obj/item/exodrone/drone)
	return can_escape_danger(drone) ? has_tool_action_text : no_tool_action_text

/datum/exploration_event/simple/danger/proc/can_escape_danger(obj/item/exodrone/drone)
	return !required_tool || drone.has_tool(required_tool)

/datum/exploration_event/simple/danger/fire(obj/item/exodrone/drone)
	if(can_escape_danger(drone))
		drone.drone_log(avoid_log)
	else
		drone.damage(damage)
	end(drone)

/// Danger events
/datum/exploration_event/simple/danger/carp
	name = "space carp attack"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	blacklisted_site_traits = list(EXPLORATION_SITE_CIVILIZED)
	deep_scan_description = "You detect damage patterns to the site hinting at a presence of space carp."
	description = "You are ambushed by a solitary space carp!"
	has_tool_action_text = "Fight"
	no_tool_action_text = "Escape!"
	has_tool_description = "You charge your laser to fend it off."
	no_tool_description = "Unfortunately you have no weaponry so the only option is flight."
	avoid_log = "Defeated a space carp."

/// They get everywhere
/datum/exploration_event/simple/danger/carp/surface_variety
	required_site_traits = list(EXPLORATION_SITE_SURFACE)

/datum/exploration_event/simple/danger/assistant
	name = "assistant attack"
	required_site_traits = list(EXPLORATION_SITE_STATION)
	deep_scan_description = "Detected mask usage coefficent suggests a sizeable crowd of undersirables on the site."
	description = "You encounter a shaggy creature dressed in gray! It's a deranged assistant!"
	has_tool_action_text = "Fight"
	no_tool_action_text = "Escape!"
	has_tool_description = "You charge your laser to fend it off."
	no_tool_description = "Unfortunately you have no weaponry so the only option is flight."
	avoid_log = "Defeated an assistant."

/datum/exploration_event/simple/danger/collapse
	name = "collapse"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	deep_scan_description = "The architecture of the site is unstable, caution advised."
	description = "A damaged ceiling gives up as you search an unexplored passage! You're trapped by the debris."
	has_tool_action_text = "Dig out"
	no_tool_action_text = "Squeeze."
	has_tool_description = "You can use your drill to get out."
	no_tool_description = "You'll have to scrape a few parts to get out without any tools."
	avoid_log = "Dug out of collapsed passage."

/datum/exploration_event/simple/danger/loose_wires
	name = "loose wires"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Damaged wiring detected on site."
	description = "You hear a loud snap behind you! A stack of sparking high-voltage wires is blocking you way out."
	has_tool_action_text = "Disable power"
	no_tool_action_text = "Get fried."
	has_tool_description = "You can try to use your multitool to shut down power to escape."
	no_tool_description = "You'll have to risk frying your electronics getting out."
	avoid_log = "Escaped loose wire."

/datum/exploration_event/simple/danger/cosmic_rays
	name = "cosmic ray burst"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Site is exposed to space radiation. Using self-diagnostic multiool attachment advised."
	description = "Drone feed suddenly goes haywire! It seems that the drone got hit by extremely rare cosmic ray burst! You'll have to wait for signal to be restored."
	has_tool_description = "Multitool extension self-diagnostic attachement should deal with most of the damage automatically."
	no_tool_description = "Nothing more to be done than wait and asses the damage."
	has_tool_action_text = "Wait"
	no_tool_action_text = "Wait"
	avoid_log = "Prevented cosmic ray damage with multitool"

/datum/exploration_event/simple/danger/alien_sentry
	name = "alien security measure"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	deep_scan_description = "Automated security measures of unknown origin detected on site."
	description = "A dangerous looking machine slides out the floor and start flashing strange glyphs while emitting high-pitched sound."
	has_tool_description = "Your translator recognizes the glyphs as security hail and suggests identyfing yourself as guest."
	no_tool_description = "The machine start shooting soon after."
	has_tool_action_text = "Identify yourself"
	no_tool_action_text = "Escape"
	avoid_log = "Avoided alien security"

/datum/exploration_event/simple/danger/beast
	name = "alien encounter"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	blacklisted_site_traits = list(EXPLORATION_SITE_CIVILIZED)
	required_tool = EXODRONE_TOOL_LASER
	deep_scan_description = "Dangerous fauna detected on site."
	description = "You encounter BEAST. It prepares to strike."
	has_tool_action_text = "Fight"
	no_tool_action_text = "Escape"
	has_tool_description = "You ready your laser."
	no_tool_description = "Time to run."
	avoid_log = "Defeated BEAST"

/datum/exploration_event/simple/danger/beast/New()
	. = ..()
	var/beast_name = pick_list(EXODRONE_FILE,"alien_fauna")
	description = replacetext(description,"BEAST",beast_name)
	avoid_log = replacetext(avoid_log,"BEAST",beast_name)

/datum/exploration_event/simple/danger/rad
	name = "irradiated section"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Sections of the vessel are irradiated."
	description = "You enter a nondescript ship section."
	has_tool_action_text = "Detour"
	no_tool_action_text = "Escape and mitigate damage."
	has_tool_description = "Your multitool suddenly screams in warning! Section ahead is irradiated, you'll have to go around"
	no_tool_description = "Suddenly the drone reports significant damage, it seems this section was heavily irradiated."
	avoid_log = "Avoided irradiated section"
