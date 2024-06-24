//Posters//

//Custom Posters Below//
/obj/structure/sign/poster/contraband/syndicate_medical
	name = "Syndicate Medical"
	desc = "This poster celebrates the complete successful revival of an hour-dead, six person mining team by Syndicate Operatives. Written in the corner is a simple message, 'Stay Winning.'"
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_syndiemed"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndicate_medical, 32)

/obj/structure/sign/poster/contraband/crocin_pool
	name = "SWIM"
	desc = "This poster dramatically states; 'SWIM'. It seems to be advertising the use of Crocin.. 'recreationally', in the home, work, and, most ominously, 'the pool'. A 'MamoTramsem' logo is in the corner."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_crocin"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/crocin_pool, 32)

/obj/structure/sign/poster/contraband/icebox_moment
	name = "As above, so below"
	desc = "This poster seems to be instill that a 'Head of Security's Office being overtop a syndicate installation is only fitting. As above.. so below.'"
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_abovebelow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/icebox_moment, 32)

/obj/structure/sign/poster/contraband/shipstation
	name = "Flight Services - Enlist"
	desc = "This poster depicts the long deprecated 'Ship' class 'station' in it's hayday. Surprisingly, the poster seems to be Nanotrasen official; though with how hush they've been on the topic..." //A disaster as big as Ship deserves a scandalous coverup.
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_shipstation"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/shipstation, 32)

/obj/structure/sign/poster/contraband/dancing_honk
	name = "DANCE"
	desc = "This poster depicts a 'HONK' class mech ontop of a stage, next to a pole."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_honkdance"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/dancing_honk, 32)

/obj/structure/sign/poster/contraband/operative_duffy
	name = "CASH REWARD"
	desc = "This poster depicts a gas mask, with details on how to 'forward information' on the whereabouts of whoever it means... though it doesn't specify to who."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_duffy"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/operative_duffy, 32)

/obj/structure/sign/poster/contraband/ultra
	name = "ULTRA"
	desc = "This poster has one word on it, 'ULTRA'; it depicts a smiling pill next to a beaker. Ominous."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_ultra"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ultra, 32)

/obj/structure/sign/poster/contraband/secborg_vale
	name = "Defaced Valeborg Advertisement"
	desc = "This poster originally sought to advertise the sleek utility of the valeborg - but it seems to have been long since defaced. One word lies on top; 'RUN.' - Perhaps fitting, considering the security model shown."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_valeborg"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/secborg_vale, 32)

/obj/structure/sign/poster/contraband/killingjoke // I like Batman :)))
	name = "You don't have to be crazy to work here - but it sure helps!"
	desc = "A poster boldly stating that being insane abord Nanotrasen stations isn't required. But it doesn't hurt to have!"
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "poster_sr_killingjoke"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/killingjoke, 32)

/obj/structure/sign/poster/contraband/nri_text
	name = "NRI declaration of sovereignity"
	desc = "This poster references the translated copy of Novaya Rossiyskaya Imperiya's declaration of sovereignity."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "nri_texto"

/obj/structure/sign/poster/contraband/nri_text/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("The First Congress of People's Senators of the NRI...")]"
	. += "\t[span_info("...Testifying respect for the sovereign rights of all peoples belonging to the...")]"
	. += "\t[span_info("...Solemnly proclaims the State sovereignty of the Novaya Rossiyskaya Imperiya over its entire territory and declares its determination to create a monarchic State governed by the rule of law...")]"
	. += "\t[span_info("...This Declaration is the basis for the development of a new Constitution of the NRI, the conclusion of the Imperial Treaty and the improvement of royal legislation.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri_text, 32)

/obj/structure/sign/poster/contraband/nri_rations
	name = "NRI military rations advertisement"
	desc = "This poster presumably is an advertisement for military rations produced by a certain private company as a part of the Defense Collegia's state order. This admiral's right hand man sure does look excited."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "nri_rations"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri_rations, 32)

/obj/structure/sign/poster/contraband/nri_voskhod
	name = "VOSKHOD combat armor advertisement"
	desc = "A poster showcasing recently developed VOSKHOD combat armor currently in use by NRI's troops and infantry across the border. The word 'DRIP' is written top to bottom on the left side, presumably boasting about the suit's superior design."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "nri_voskhod"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri_voskhod, 32)

/obj/structure/sign/poster/contraband/nri_pistol
	name = "Szabo-Ivanek service pistol technical poster"
	desc = "This poster seems to be a technical documentation for Szabo-Ivanek service pistol in use by most of the NRI's state police and military institutions. Sadly, it's all written in Pan-Slavic."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "nri_pistol"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri_pistol, 32)

/obj/structure/sign/poster/contraband/nri_engineer
	name = "Build, Now"
	desc = "This poster shows you an imperial combat engineer staring somewhere to the left of the viewer. The words 'Build, Now' are written on top and bottom of the poster."
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "nri_engineer"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri_engineer, 32)

/obj/structure/sign/poster/contraband/nri_radar
	name = "Imperial navy enlistment poster"
	desc = "Enlist with the imperial navy today! See the galaxy, shoot solarians, get PTSD!"
	icon = 'monkestation/code/modules/blueshift/icons/posters/contraband.dmi'
	icon_state = "nri_radar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri_radar, 32)
