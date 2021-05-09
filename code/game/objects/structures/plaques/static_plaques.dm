//These are static plaques, they are made of gold and start engraved with a title and description.

/obj/structure/plaque/static_plaque
	engraved = TRUE

/obj/structure/plaque/static_plaque/atmos
	name = "\improper FEA Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."

/obj/structure/plaque/static_plaque/thunderdome
	name = "Thunderdome Plaque"
	desc = "This plaque commemorates those who have fallen in glorious combat.  For all the charred, dizzy, and beaten men who have died in its hands."

/obj/structure/plaque/static_plaque/golden
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/plaque/static_plaque/golden/captain
	name = "The Most Robust Captain Award for Robustness"

//Commission plaques, to give a little backstory to the stations. Commission dates are date of merge (or best approximation, in the case of Meta) + 540 years to convert to SS13 dates.

/obj/structure/plaque/static_plaque/golden/commission
	name = "Commission Plaque"
	desc = "Spinward Sector Station SS-13\n'Runtime' Class Outpost\nCommissioned 11/03/2556\n'Dedicated to the Pioneers'"
	icon_state = "commission_nt"

//Current stations

/obj/structure/plaque/static_plaque/golden/commission/icebox
	desc = "Spinward Sector Station SS-13\n'Box' Class Outpost (Revivion 2.2: 'Icebox')\nCommissioned 05/22/2560\n'Cold Reliable'"

/obj/structure/plaque/static_plaque/golden/commission/meta
	desc = "Spinward Sector Station SS-13\n'Meta' Class Outpost\nCommissioned 08/11/2553\n'Theseus' Station'"

/obj/structure/plaque/static_plaque/golden/commission/delta
	desc = "Spinward Sector Station SS-13\n'Delta' Class Outpost\nCommissioned 12/17/2556\n'Efficiency Through Redundancy'"

/obj/structure/plaque/static_plaque/golden/commission/kilo
	desc = "Spinward Sector Station SS-13\n'Kilo' Class Outpost\nCommissioned 11/13/2559\n'Forever Different'"

/obj/structure/plaque/static_plaque/golden/commission/tram
	desc = "Spinward Sector Station SS-13\n'Tram' Class Outpost\nCommissioned 03/11/2561\n'Making Moves'"

//Removed stations

/obj/structure/plaque/static_plaque/golden/commission/asteroid
	desc = "Spinward Sector Station SS-12\n'Asteroid' Class Outpost\nCommissioned 10/13/2555\nDecommissioned 06/19/2556\n'A Meteoric Success'"

/obj/structure/plaque/static_plaque/golden/commission/birdboat
	desc = "Spinward Sector Station SS-03\n'Birdboat' Class Outpost\nCommissioned 09/17/2555\nDecommissioned 02/09/2557\n'Rocking the Boat'"

/obj/structure/plaque/static_plaque/golden/commission/box
	desc = "Spinward Sector Station SS-01\n'Box' Class Outpost\nCommissioned 11/15/2550\nDecommissioned 07/06/2560\n'Old Faithful'"

/obj/structure/plaque/static_plaque/golden/commission/pubby
	desc = "Spinward Sector Station SS-06\n'Pubby' Class Outpost\nCommissioned 10/19/2556\nDecommissioned 12/25/2560\n'No Law But Ours'"

/obj/structure/plaque/static_plaque/golden/commission/cere
	desc = "Spinward Sector Station SS-10\n'Cere' Class Outpost\nCommissioned 03/29/2557\nDecommissioned 08/26/2557\n'Take a Hike'"

/obj/structure/plaque/static_plaque/golden/commission/disc
	desc = "Spinward Sector Station SS-05\n'Disc' Class Outpost\nCommissioned 09/21/2555\nDecommissioned 01/31/2556\n'Sleep Tight'"

/obj/structure/plaque/static_plaque/golden/commission/donut
	desc = "Spinward Sector Station SS-11\n'Donut' Class Outpost\nCommissioned 12/16/2558\nDecommissioned 04/28/2560\n'Hail the Lord'"

/obj/structure/plaque/static_plaque/golden/commission/dream
	desc = "Spinward Sector Station SS-04\n'Dream' Class Outpost\nCommissioned 08/11/2555\nDecommissioned 12/22/2556\n'Aiming High'"

/obj/structure/plaque/static_plaque/golden/commission/efficiency
	desc = "Spinward Sector Station SS-07\n'Efficiency' Class Outpost\nCommissioned 01/28/2556\nDecommissioned 12/20/2556\n'Work Smarter, Not Harder'"

/obj/structure/plaque/static_plaque/golden/commission/mini
	desc = "Spinward Sector Station SS-08\n'Mini' Class Outpost\nCommissioned 01/29/2554\nDecommissioned 12/27/2556\n'The Littlest Station'"

/obj/structure/plaque/static_plaque/golden/commission/omega
	desc = "Spinward Sector Station SS-09\n'Omega' Class Outpost\nCommissioned 12/27/2556\nDecommissioned 09/20/2558\n'Tiny Take Two'"

// Other Stations

//Space Station 13, Developer Class Outpost, Station Commissioned 25.12.2391, For the Glory of the Workers of the Third Soviet Union
/obj/structure/plaque/static_plaque/golden/commission/ks13
	desc = "космическая-станция-13\nфорпост класса разработчика\nстанция сдана 25.12.2391\nво славу тружеников третьего советского союза"
	icon_state = "commission_commie"

//These are plaques that aren't made of metal, so we'll just consider them signs. Those are made of plastic (default) or wood, not gold.
//See: code>game>objects>structures>signs>_signs.dm

/obj/structure/sign/plaques/kiddie
	name = "\improper AI developers plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be disabled. Beneath the image, someone has scratched the word \"PACKETS\"."
	icon_state = "kiddieplaque"

/obj/structure/sign/plaques/kiddie/badger
	name = "\improper Remembrance Plaque"
	desc = "A plaque commemorating the fallen, may they rest in peace, forever asleep amongst the stars. Someone has drawn a picture of a crying badger at the bottom."

/obj/structure/sign/plaques/kiddie/library
	name = "\improper Library Rules Sign"
	desc = "A long list of rules to be followed when in the library, extolling the virtues of being quiet at all times and threatening those who would dare eat hot food inside."

/obj/structure/sign/plaques/kiddie/perfect_man
	name = "\improper 'Perfect Man' sign"
	desc = "A guide to the exhibit, explaining how recent developments in mindshield implant and cloning technologies by Nanotrasen Corporation have led to the development and the effective immortality of the 'perfect man', the loyal Nanotrasen Employee."

/obj/structure/sign/plaques/kiddie/perfect_drone
	name = "\improper 'Perfect Drone' sign"
	desc = "A guide to the drone shell dispenser, detailing the constructive and destructive applications of modern repair drones, as well as the development of the incorruptible cyborg servants of tomorrow, available today."

/obj/structure/sign/plaques/deempisi
	name = "\improper Mr. Deempisi portrait"
	desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
	icon_state = "monkey_painting"
	custom_materials = list(/datum/material/wood = 2000) //The same as /obj/structure/sign/picture_frame
