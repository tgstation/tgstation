
/datum/team/vampireclan
	name = "Clan" // Teravanni,


/datum/antagonist/bloodsucker
	name = ""//WARNING: DO NOT SELECT" // "Bloodsucker"
	roundend_category = "bloodsuckers"
	antagpanel_category = "Bloodsucker (UNFINISHED)"
	job_rank = ROLE_BLOODSUCKER
				// New Vars
	// NAME
	var/vampname						// My Dracula name
	var/vamptitle						// My Dracula title
	var/vampreputation					// My "Surname" or description of my deeds
	// CLAN
	var/datum/team/vampireclan/clan




/datum/antagonist/bloodsucker/on_gain()
	. = ..()


/datum/antagonist/bloodsucker/on_removal()
	. = ..()



/datum/antagonist/bloodsucker/greet()
	var/fullname = ReturnFullName(owner.current, 1)
	to_chat(owner, "<span class='userdanger'>You are [fullname], a bloodsucking vampire!</span>")
	owner.announce_objectives()
	//to_chat(owner, "<span class='boldannounce'>You regenerate your health slowly, you're weak to fire, and you depend on blood to survive. Allow your stolen blood to run too low, and you may find yourself at \
	risk of Frenzy!<span>")
	//to_chat(owner, "<span class='boldannounce'>As an immortal, your power is linked to your age. The older you grow, the more abilities you will have access to.<span>")
	//to_chat(owner, "<span class='boldannounce'>Other Bloodsuckers are not necessarily your friends, but your survival may depend on cooperation. Betray them at your own discretion and peril.<span>")

	owner.current.playsound_local(null, 'sound/Fulpsounds/BloodsuckerAlert.ogg', 100, FALSE, pressure_affected = FALSE)


/datum/antagonist/bloodsucker/farewell()
	owner.current.visible_message("[owner.current]'s skin flushes with color, their eyes growing glossier. They look...alive.",\
			"<span class='userdanger'><FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You live once more!</FONT></span>")
	// Refill with Blood
	owner.current.blood_volume = max(owner.current.blood_volume,BLOOD_VOLUME_SAFE)




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/antagonist/bloodsucker/proc/SelectFirstName(gender=MALE)
	// Names (EVERYONE gets one))
	if (gender == MALE)
		vampname = pick("Desmond","Rudolph","Dracul","Vlad","Pyotr","Gregor","Cristian","Christoff","Marcu","Andrei","Constantin","Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel","Vasile","Octavian","Sorin", \
						"Sveyn","Aurel","Alexe","Iustin","Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
						"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius",  // Latin
						"Melanthus","Teuthras","Orchamus","Amyntor","Axion",  // Greek
						"Thoth","Thutmose") // Egyptian

	else
		vampname = pick("Islana","Tyrra","Greganna","Pytra","Hilda","Andra","Crina","Viorela","Viorica","Anemona","Camelia","Narcisa","Sorina","Alessia","Sophia","Gladda","Arcana","Morgan","Lasarra","Ioana","Elena", \
						"Alina","Rodica","Teodora","Denisa","Mihaela","Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
						"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa",  // Latin
						"Alcestis","Damaris","Elisavet","Khthonia","Teodora",  // Greek
						"Nefret") // Egyptian

/datum/antagonist/bloodsucker/proc/SelectTitle(gender=MALE, am_fledgling = 0)
	// Titles [Master]
	if (!am_fledgling)
		if (gender == MALE)
			vamptitle = pick ("Count","Baron","Viscount","Prince","Duke","Tzar","Dreadlord","Lord","Master")
		else
			vamptitle = pick ("Countess","Baroness","Viscountess","Princess","Duchess","Tzarina","Dreadlady","Lady","Mistress")
	// Titles [Fledgling]
	else
		vamptitle = null

/datum/antagonist/bloodsucker/proc/SelectReputation(gender=MALE, am_fledgling = 0)
	// Reputations [Master]
	if (!am_fledgling)
		vampreputation = pick("Butcher","Blood Fiend","Crimson","Red","Black","Terror","Nightman","Feared","Ravenous","Fiend","Malevolent","Wicked","Ancient","Plaguebringer","Sinister","Forgotten","Wretched","Baleful", \
							"Inqisitor","Harvester","Reviled","Robust","Betrayer","Destructor","Damned","Accursed","Terrible","Vicious","Profane","Vile","Depraved","Foul","Slayer","Manslayer","Sovereign","Slaughterer", \
							"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious","Inquisitor","Marauder","Horrible","Immortal","Undying")
		if (gender == MALE)
			if (prob(10)) // Gender override
				vampreputation = pick("King of the Damned", "Blood King", "Emperor of Blades", "Sinlord", "God-King")
		else
			if (prob(10)) // Gender override
				vampreputation = pick("Queen of the Damned", "Blood Queen", "Empress of Blades", "Sinlady", "God-Queen")
	// Reputations [Fledgling]
	else
		vampreputation = pick ("Crude","Callow","Unlearned","Neophyte","Novice","Unseasoned","Fledgling","Young","Neonate","Scrapling","Untested","Unproven","Newly Reisen","Born","Scavenger")//,"Fresh")


/datum/antagonist/bloodsucker/proc/AmFledgling()
	return !vamptitle

/datum/antagonist/bloodsucker/proc/ReturnFullName(mob/living/carbon/owner, var/include_rep=0)

	var/fullname
	// Name First
	fullname = (vampname ? vampname : owner.name)
	// Title
	if (vamptitle)
		fullname = vamptitle + " " + fullname
	// Rep
	if (include_rep && vampreputation)
		fullname = fullname + " the " + vampreputation

	return fullname




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//This handles the application of antag huds/special abilities
/datum/antagonist/bloodsucker/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	return

//Assign default team and creates one for one of a kind team antagonists
/datum/antagonist/bloodsucker/create_team(datum/team/team)
	return



// Create Objectives
/datum/antagonist/bloodsucker/proc/forge_bloodsucker_objectives() // Fledgling vampires can have different objectives.

			// ROUND ONE: CREWMATE OBJECTIVES //
	// Coffin [REQUIRED]
	// 1a) Embrace Target
	// 1b) Embrace Total
	// 2a) Desecrate
	// 2b) Heart Thief
	// Survive [REQUIRED]

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = owner
	kill_objective.find_target()
	objectives += kill_objective



//  		2019 Breakdown of Bloodsuckers:

//					G A M E P L A Y
//
//	Bloodsuckers should be inherrently powerful: they never stay dead, and they can hide in plain sight
//  better than any other antagonist aboard the station.
//
//	However, only elder Bloodsuckers are the powerful creatures of legend. Ranking up as a Bloodsucker
//  should impart slight strength and health benefits, as well as powers that can grow over time. But
//  their weaknesses should grow as well, and not just to fire. Flaws should


//					A B I L I T I E S
//
// 	* Bloodsuckers can FEIGN LIFE + DEATH.
//		Feigning LIFE:
//			- Warms up the body
//			- Creates a heartbeat
//			- Fake blood amount (550)
//		Feign DEATH:
//			- When lying down or sitting, you appear "dead and lifeless"

//	* Bloodsuckers REGENERATE
//		- Brute damage heals rather rapidly. Burn damage heals slowly.
//		- Healing is reduced when hungry or starved.
//		- Burn does not heal when starved. A starved vampire remains "dead" until burns can heal.
//		- Bodyparts and organs regrow in Torpor (except for the Heart and
//
//	* Bloodsuckers are IMMORTAL
//		- Brute damage cannot destroy them (and it caps very low, so they don't stack too much)
//		- Burn damage can only kill them at very high amounts.
//		- Removing the head kills the vamp forever.
//		- Removing the heart kills the vamp until replaced.
//
//	* Bloodsuckers are DEAD
//		- They do not breathe.
//		- Cold affects them less.
//		- They are immune to disease (but can spread it)
//		- Food is useless and cause sickness.
//		- Nothing can heal the vamp other than his own blood.
//
//	* Bloodsuckers are PREDATORS
//		- They detect life/heartbeats nearby.
//		- They know other predators instantly (Vamps, Werewolves, and alien types) regardless of disguise.
//
//
//
// 	* Bloodsuckers enter Torpor when DEAD or RESTING in coffin
//		- Torpid vampires regenerate their health. Coffins negate cost and speed up the process.
//		** To rest in a coffin, either SLEEP or CLOSE THE LID while you're in it. You will automatically sleep until healed.
//

//					P O W E R S
//	* HASTE
//		SPRINT:	Hastily speed in a direction faster than the eye can see.
//		LUNGE:	Leap toward a location and put your target into an agressive hold.
//
//	* STEALTH
//		CLOAK:  	Vanish into the shadows, eventually even moving while hidden.
//		DISGUISE:	Bear the name, and eventually the features, of another.
//


//					F L A W S
//
//	Bestial: Your eyes glow red when hungry
//	Craven:
//


//			Vassals
//
// - Loyal to (and In Love With) Master
// - Master can speak to, summon, or punish his Vassals, even while asleep or torpid.
// - Master may have as many Vassals as Rank
// - Vassals see their Master's speech emboldened!






// 			Dev Notes
//
// HEALING: Maybe Vamps metabolize specially? Like, they slowly drip their own blood into their system?
//			- Give Vamps their own metabolization proc, perhaps?
//
// KILLING: It's almost impossible to track who someone has directly killed. But an Admin could be given
//			an easy way to whip a Bloodsucker for cruel behavior, as a RP mechanic but not a punishment.




/////////////////////////////////////

		// HUD! //
/*
/datum/antagonist/bloodsucker/proc/update_bloodsucker_icons_added(datum/mind/m)
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]
	vamphud.join_hud(owner.current)
	set_antag_hud(owner.current, "bloodsucker") // Located in icons/mob/hud.dmi

/datum/antagonist/bloodsucker/proc/update_bloodsucker_icons_removed(datum/mind/m)
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]//ANTAG_HUD_BLOODSUCKER]
	vamphud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/atom_hud/antag/bloodsucker  // from hud.dm in /datums/   Also see data_huds.dm + antag_hud.dm


/datum/atom_hud/antag/bloodsucker/add_to_single_hud(mob/M, atom/A)
	if (!check_valid_hud_user(M,A)) 	// FULP: This checks if the Mob is a Vassal, and if the Atom is his master OR on his team.
		return
	..()

/datum/atom_hud/antag/bloodsucker/proc/check_valid_hud_user(mob/M, atom/A) // Remember: A is being added to M's hud. Because M's hud is a /antag/vassal hud, this means M is the vassal here.
	// GOAL: Vassals see their Master and his other Vassals.
	// GOAL: Vassals can BE seen by their Bloodsucker and his other Vassals.
	// GOAL: Bloodsuckers can see each other.
	if (!M || !A || !ismob(A) || !M.mind)// || !A.mind)
		return 0
	var/mob/A_mob = A
	if (!A_mob.mind)
		return 0

	// Find Datums: Bloodsucker
	var/datum/antagonist/bloodsucker/atom_B = A_mob.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	var/datum/antagonist/bloodsucker/mob_B = M.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// Check 1) Are we both Bloodsuckers?
	if (atom_B && mob_B)
		return 1

	// Find Datums: Vassal
	var/datum/antagonist/vassal/atom_V = A_mob.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
	var/datum/antagonist/vassal/mob_V = M.mind.has_antag_datum(ANTAG_DATUM_VASSAL)

	// Check 2) If they are a BLOODSUCKER, then are they my Master?
	if (mob_V && atom_B == mob_V.master)
		return 1 // SUCCESS!

	// Check 3) If I am a BLOODSUCKER, then are they my Vassal?
	if (mob_B && atom_V && (atom_V in mob_B.vassals))
		return 1 // SUCCESS!

	// Check 4) If we are both VASSAL, then do we have the same master?
	if (atom_V && mob_V && atom_V.master == mob_V.master)
		return 1 // SUCCESS!

	return 0

*/




