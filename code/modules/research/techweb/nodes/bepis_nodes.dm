// Nodes that are found inside Bepis Disks.

/datum/techweb_node/bepis
	abstract_type = /datum/techweb_node/bepis
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_EXPERIMENTAL

/datum/techweb_node/bepis/light_apps
	display_name = "Illumination Applications"
	description = "Applications of lighting and vision technology not originally thought to be commercially viable."
	unlocked_designs = list(
		/datum/design/bright_helmet,
		/datum/design/rld_mini,
		/datum/design/photon_cannon,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/extreme_office
	display_name = "Advanced Office Applications"
	description = "Some of our smartest lab guys got together on a Friday and improved our office efficiency by 350%. Here's how."
	unlocked_designs = list(
		/datum/design/mauna_mug,
		/datum/design/rolling_table,
		/datum/design/plasticducky,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/spec_eng
	display_name = "Specialized Engineering"
	description = "Conventional wisdom has deemed these engineering products 'technically' safe, but far too dangerous to traditionally condone."
	unlocked_designs = list(
		/datum/design/eng_gloves,
		/datum/design/lavarods,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/bepis/aus_security
	display_name = "Australicus Security Protocols"
	description = "It is said that security in the Australicus sector is tight, so we took some pointers from their equipment. Thankfully, our sector lacks any signs of these, 'dropbears'."
	unlocked_designs = list(
		/datum/design/pin_explorer,
		/datum/design/stun_boomerang,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/bepis/interrogation
	display_name = "Enhanced Interrogation Technology"
	description = "By cross-referencing several declassified documents from past dictatorial regimes, we were able to develop an incredibly effective interrogation device. \
		Ethical concerns about loss of free will do not apply to criminals, according to galactic law."
	unlocked_designs = list(
		/datum/design/board/hypnochair,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/bepis/sticky_advanced
	display_name = "Advanced Sticky Technology"
	description = "Taking a good joke too far? Nonsense!"
	unlocked_designs = list(
		/datum/design/pointy_tape,
		/datum/design/super_sticky_tape,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/tackle_advanced
	display_name = "Advanced Grapple Technology"
	description = "Nanotrasen would like to remind its researching staff that it is never acceptable to \"glomp\" your coworkers, and further \"scientific trials\" on the subject \
		will no longer be accepted in its academic journals."
	unlocked_designs = list(
		/datum/design/tackle_dolphin,
		/datum/design/tackle_rocket,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/bepis/mod_experimental
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits have created these..."
	unlocked_designs = list(
		/datum/design/module/disposal,
		/datum/design/module/joint_torsion,
		/datum/design/module/recycler,
		/datum/design/module/shooting_assistant,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/posisphere
	display_name = "Experimental Spherical Positronic Brain"
	description = "Recent developments on cost-cutting measures have allowed us to cut positronic brain cubes into twice-as-cheap spheres. Unfortunately, it also allows them to move around the lab via rolling maneuvers."
	unlocked_designs = list(
		/datum/design/posisphere,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bepis/donk_shell
	display_name = "Donk Co. Failed Products Schematics"
	description = "We don't want to know why you're filling up your databanks with known failed products from an enemy corporation. That's your choice. I'm just saying, don't come crying to us \
		when it turns out you've downloaded some kind of horrible donk-pocket related malware that steals your Starscape password. Those bastards over at Donk Co. WILL delete your character."
	unlocked_designs = list(
		/datum/design/donkflechette,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)
