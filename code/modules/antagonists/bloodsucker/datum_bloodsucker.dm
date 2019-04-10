

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

	// POWERS
	var/list/obj/effect/proc_holder/spell/powers = list()// Purchased powers
	var/poweron_feed = FALSE			// Am I feeding?
	var/poweron_masquerade = FALSE

	// STATS
	var/regenRate = 0.3					// How many points of Brute do I heal per tick? Note: Fire never changes its rate (0.1)
	var/feedAmount = 15					// Amount of blood drawn from a target per tick.
	var/maxBloodVolume = 600			// Maximum blood a Vamp can hold via feeding. // BLOOD_VOLUME_NORMAL  550 // BLOOD_VOLUME_SAFE 475 //BLOOD_VOLUME_OKAY 336 //BLOOD_VOLUME_BAD 224 // BLOOD_VOLUME_SURVIVE 122

	// TRACKING
	var/foodInGut = 0					// How much food to throw up later. You shouldn't have eaten that.


	// LISTS
	var/static/list/defaultTraits = list (TRAIT_STABLEHEART, TRAIT_NOBREATH, TRAIT_SLEEPIMMUNE, TRAIT_NOCRITDAMAGE, TRAIT_RESISTCOLD, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_NIGHT_VISION, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_COLDBLOODED)
	// REMOVED: TRAIT_NODEATH
	// TO ADD:
	//var/static/list/defaultOrgans = list (/obj/item/organ/heart/vampheart,/obj/item/organ/heart/vampeyes)




/datum/antagonist/bloodsucker/on_gain()

	// Give Powers & Stats
	AssignStarterPowersAndStats()


	// Run Life Function
	LifeTick()

	. = ..()


/datum/antagonist/bloodsucker/on_removal()

	// Clear Powers & Stats
	ClearAllPowersAndStats()

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
							"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious","Inquisitor","Marauder","Horrible","Immortal","Undying","Overlord","Corrupt")
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



/datum/antagonist/bloodsucker/proc/BuyPower(datum/action/bloodsucker/power)//(obj/effect/proc_holder/spell/power)
	powers += power
	power.Grant(owner.current)// owner.AddSpell(power)

/datum/antagonist/bloodsucker/proc/AssignStarterPowersAndStats()

	// Powers
	BuyPower(new /datum/action/bloodsucker/feed)
	BuyPower(new /datum/action/bloodsucker/masquerade)

	// Traits
	for (var/T in defaultTraits)
		owner.current.add_trait(T, "bloodsucker")

	// Stats
	if (ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		var/datum/species/S = H.dna.species
		// Make Changes
		S.brutemod *= 0.5
		S.burnmod += 0.2 // 0.5													//  <--------------------  Start small, but burn mod increases based on blood pool!
		//S.heatmod += 0.5 			// Heat shouldn't affect. Only Fire.
		S.coldmod = 0
		S.stunmod *= 0.8 // 0.5
		S.punchdamagelow += 1       //lowest possible punch damage   0
		S.punchdamagehigh += 1      //highest possible punch damage	 9
		//S.punchstunthreshold = 8	//damage at which punches from this race will stun  9
		S.siemens_coeff *= 0.75 	//base electrocution coefficient  1

	// Physiology
	CheckVampOrgans() // Heart, Eyes


/datum/antagonist/bloodsucker/proc/ClearAllPowersAndStats()

	// Powers
	while(powers.len)
		var/datum/action/bloodsucker/power = pick(powers)
		powers -= power
		power.Remove(owner.current)
		// owner.RemoveSpell(power)

	// Traits
	for (var/T in defaultTraits)
		owner.current.remove_trait(T, "bloodsucker")

	// Stats
	if (ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(H.dna.species.type)

	// Physiology
	owner.current.regenerate_organs()


//datum/antagonist/bloodsucker/proc/LevelUp()




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
//  their weaknesses should grow as well, and not just to fire.


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
//		- Bodyparts and organs regrow in Torpor (except for the Heart and Brain).
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
//		** To rest in a coffin, either SLEEP or CLOSE THE LID while you're in it. You will be given a prompt to sleep until healed. Healing in a coffin costs NO blood!
//

//					P O W E R S
//	* HASTE
//		SPRINT:	A) Hastily speed in a direction faster than the eye can see. B) Spin and dizzy people you pass. C) Chance to knock down people you pass.
//		LUNGE:	Leap toward a location and put your target into an agressive hold.
//
//	* AGILITY
//		CELERITY:	Dodge projectiles and even bullets. Perhaps avoid explosions!
//		REFLEXES	TRAIT_NOSLIPWATER, TRAIT_NOSLIPALL
//
//	* STEALTH
//		CLOAK:  	A) Vanish into the shadows when stationary. B) Moving does not break your current level of invisibility (but stops you from hiding further).
//		DISGUISE:	A) Bear the face and voice of a new person. B) Bear a random outfit of an unknown profession.
//
//	* FEED
//		A) Mute victim while Feeding (and slowly deal Stamina damage) B) Paralyze victim while feeding C) Sleep victim while Feeding
//
//	* MEZMERIZE
//		LOVE:		Target falls in love with you. Being harmed directly causes them harm if they see it?
//		STAY:		Target will do everything they can to stand in the same place.
//		FOLLOW:		Target follows you, spouting random phrases from their history (or maybe Poly's or NPC's vocab?)
//		ATTACK:		Target finds a nearby non-Bloodsucker victim to attack.
//
//	* EXPEL
//		TAINT:		Mark areas with your corrupting blood. Your coffin must remain in an area so marked to gain any benefit. Spiders, roaches, and rats will infest the area, cobwebs grow rapidly, and trespassers are overcome with fear.
//		SERVITUDE:	Your blood binds a mortal to your will. Vassals feel your pain and can locate you anywhere. Your death causes them agony.
//		HEIR:		Raise a moral corpse into a Bloodsucker. The change will take a while, and the body must be brought to a tainted coffin to rise.
//
//	* NIGHTMARE
//		BOGEYMAN:	Terrify those who view you in your death-form, causing them to shake, pale, and drop possessions.
//		HORROR:		Horrified characters cannot speak, shake, and slowly push away from the source.
//

//					F L A W S
//
//	Bestial: Your eyes glow red when hungry
//	Craven:
//

// 					O B J E C T I V E S
//
//
//
//
//	1) GROOM AN HEIR:	Find a person with appropriate traits (hair, blood type, gender) to be turned as a Vampire. Before they rise, they must be properly trained. Raise them to great power after their change.
//
//	2) BIBLIOPHILE:		Research objects of interest, study items looking for clues of ancient secrets, and hunt down the clues to a Vampiric artifact of horrible power.
//
//	3) CRYPT LORD:		Build a terrifying sepulcher to your evil, with servants to lavish upon you in undeath. The trappings of a true crypt lord come at grave cost.
//
//	4) GOURMOND:		Oh, to taste all the delicacies the station has to offer! DRINK ## BLOOD FROM VICTIMS WHO LIVE, EAT ## ORGANS FROM VICTIMS WHO LIVE


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
//			** shadowpeople.dm has rules for healing.
//
// KILLING: It's almost impossible to track who someone has directly killed. But an Admin could be given
//			an easy way to whip a Bloodsucker for cruel behavior, as a RP mechanic but not a punishment.
//			**
//
// HUNGER:  Just keep adjusting mob's nutrition to Blood Hunger level. No need to cancel nutrition from eating.
//			** mob.dm /set_nutrition()
//			** snacks.dm / attack()  <-- Stop food from doing anything?

// ORGANS:  Liver
//			** life.dm /handle_liver()
//
// CORPSE:	Most of these effects likely go away when using "Masquerade" to appear alive.
//			** status_procs.dm /adjust_bodytemperature()
//			** traits.dm /TRAIT_NOBREATH /TRAIT_SLEEPIMMUNE /TRAIT_RESISTCOLD /TRAIT_RADIMMUNE  /TRAIT_VIRUSIMMUNE
//			*  MASQUERADE ON/OFF: /TRAIT_FAKEDEATH (M)
//			* /TRAIT_NIGHT_VISION
//			* /TRAIT_DEATHCOMA <-- This basically makes you immobile. When using status_procs /fakedeath(), make sure to remove Coma unless we're in Torpor!
//			* /TRAIT_NODEATH <--- ???
//			** species  /NOZOMBIE
//			* ADD: TRAIT_COLDBLOODED <-- add to carbon/life.dm /natural_bodytemperature_stabilization()
//
// MASQUERADE	Appear as human!
//				** examine.dm /examine() <-- Change "blood_volume < BLOOD_VOLUME_SAFE" to a new examine
//
// NOSFERATU ** human.add_trait(TRAIT_DISFIGURED, "insert_vamp_datum_here") <-- Makes you UNKNOWN unless your ID says otherwise.
// STEALTH   ** human_helpers.dm /get_visible_name()     ** shadowpeople.dm has rules for Light.
//
// FRENZY	** living.dm /update_mobility() (USED TO be update_canmove)
//
// PREDATOR See other Vamps!
//		    * examine.dm /examine()
//
// WEAKNESSES:	-Poor mood in Chapel or near Chaplain.  -Stamina damage from Bible





// TODO:
//
// Death (fire, heart, brain, head)
// Disable Life: BLOOD
// Body Temp
// Spend blood over time (more if imitating life) (none if sleeping in coffin)
// Auto-Heal (brute to 0, fire to 99) (toxin/o2 always 0)
//
// Hud Icons
// UI Blood Counter
// Examine Name (+Masquerade, only "Dead and lifeless" if not standing?)
//
//
// Turn vamps
// Create vassals
//


// FIX LIST
//


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




