
// THESE ARE NOW IN bloodsucker_defines.dm
// ......
//#define ANTAG_DATUM_BLOODSUCKER			/datum/antagonist/bloodsucker
//#define ANTAG_HUD_BLOODSUCKER	50
//#define BLOODSUCKER_FRENZY_TIME	50		// How long the vamp stays in frenzy.
//#define BLOODSUCKER_STARVE_VOLUME	50	// Amount of blood, below which a Vamp is at risk of frenzy.
//#define BLOODSUCKER_BLOOD_TO_TURN	50	// Amount of blood in your stomach (not blood_volume) needed to be turned into a Vampire.


/datum/antagonist/bloodsucker
	name = "Bloodsucker"
	//datum/mind/owner						//Mind that owns this datum
	//silent = FALSE							//Silent will prevent the gain/lose texts to show
	//can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	//list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	//delete_on_mind_deletion = TRUE

	var/vamptitle						// My Dracula title
	var/vampname						// My Dracula name
	var/vampreputation					// My "Surname" or description of my deeds

	var/list/objectives_given = list()	// For removal if needed.
	var/bloodTakenLifetime = 0			// Total blood ever fed from humans.
	var/vampsMade = 0					// Total bloodsuckers created from victims.
	//var/list/datum/mind/vassals2 = list()// Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()// Vassals under my control. Periodically remove the dead ones.
	var/datum/mind/creator				// Who made me? For both Vassals AND Bloodsuckers (though Master Vamps won't have one)
	var/list/obj/effect/decal/cleanable/blood/vampblood/desecrateBlood = list()	// All the blood I've spilled with Expel Blood to desecrate for an objective.
	//var/list/
	var/obj/structure/closet/coffin/coffin	// Where I lay my head is home.
	// Powers
	var/list/obj/effect/proc_holder/spell/bloodsucker/powers = list()// Purchased powers
//	var/mob/living/carbon/feedTarget								// Who am I feeding from?
	//var/humanDisguise												// Am I currently faking as a human?
	var/poweron_feed = 0				// Am I feeding?
	var/poweron_humandisguise = 0		// Am I masquerading?

	// Values
	var/regenLimbCounter				// Regenerating limbs happens over time.
	var/regenRate = 0.5					// How many points of Brute do I heal per tick? Note: Fire never changes its rate (0.1)
	var/feedAmount = 15					// Amount of blood drawn from a target per tick.
	var/maxBloodVolume = 600			// Maximum blood a Vamp can hold via feeding.
	var/badfood	= 0						// When eating human food or drink, keep track of how much we've had so we can purge it at once.
	var/frenzy_state=0					// 0 = fine. 1 = in a dangerous state. 2 = Actually in frenzy!
	var/frenzy_buffer=0					// When I come out of frenzy, I can't go back in for a bit.

//Proc called when the datum is given to a mind.
/datum/antagonist/bloodsucker/on_gain()

	SSticker.mode.bloodsuckers |= owner // Add if not already in here (and you might be, if you were picked at round start)

	SelectFirstName(owner.current.gender)
	SelectTitle(owner.current.gender, creator ? 1 : 0) // If I have a creator, then set as Fledgling.

	//spawn(20) // Wait two seconds so all starting Bloodsuckers are assigned before creating their objectives. Don't want them targetting each other for Embrace objectives.
	owner.store_memory("Although you were born a mortal, in un-death you earned the name [ReturnFullName(owner.current, 1)].")

	// Give Powers & Stats
	AssignStarterPowersAndStats()

	// Add Objectives
	forge_bloodsucker_objectives()

	// Add Antag HUD
	update_bloodsucker_icons_added(owner.current, "bloodsucker")

	// Run Life Functions
	handle_life()
	return ..() // Do base stuff: greet(), etc.

/datum/antagonist/bloodsucker/on_removal()

	SSticker.mode.bloodsuckers -= owner

	// Free Vassals
	FreeAllVassals()

	// Clear Powers & Stats
	ClearAllPowersAndStats()

	// Clear Objectives
	clear_bloodsucker_objectives()

	// Clear Antag HUD
	update_bloodsucker_icons_removed(owner.current)

	return ..() // Do base stuff.


/datum/antagonist/bloodsucker/greet()
	var/fullname = ReturnFullName(owner.current, 1)
	to_chat(owner, "<span class='userdanger'>You are [fullname], a bloodsucking vampire!</span>")
	owner.announce_objectives()
	to_chat(owner, "<span class='boldannounce'>You regenerate your health slowly, you're weak to fire, and you depend on blood to survive. Allow your stolen blood to run too low, and you may find yourself at \
	risk of Frenzy!<span>")
	to_chat(owner, "<span class='boldannounce'>Other Bloodsuckers are not necessarily your friends, but your survival may depend on cooperation. Betray them at your own discretion and peril.<span>")

	owner.current.playsound_local(null, 'sound/ambience/antag/BloodsuckerAlert.ogg', 100, FALSE, pressure_affected = FALSE)


/datum/antagonist/bloodsucker/farewell()
	owner.current.visible_message("[owner.current]'s skin flushes with color, their eyes growing glossier. They look...alive.",\
			"<span class='userdanger'><FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You are alive once more!</FONT></span>")
	// Refill with Blood
	owner.current.blood_volume = max(owner.current.blood_volume,BLOOD_VOLUME_SAFE)







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
		vampreputation = pick("Butcher","Blood Fiend","Crimson","Red","Black","Terror","Nightman","Feared","Ravenous","Fiend","Malevolent","Wicked","Ancient","Plaguebringer","Sinister","Forgotten","Wretched","Baleful", \
							"Inqisitor","Harvester","Reviled","Robust","Betrayer","Destructor","Damned","Accursed","Terrible","Vicious","Profane","Vile","Depraved","Foul","Slayer","Manslayer","Sovereign","Slaughterer", \
							"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious","Inquisitor","Marauder","Horrible")
		if (gender == MALE)
			vamptitle = pick ("Count","Baron","Viscount","Prince","Duke","Tzar","Dreadlord","Lord","Master")
			if (prob(10)) // Gender override
				vampreputation = pick("King of the Damned", "Blood King", "Emperor of Blades", "Sinlord", "God-King")
		else
			vamptitle = pick ("Countess","Baroness","Viscountess","Princess","Duchess","Tzarina","Dreadlady","Lady","Mistress")
			if (prob(10)) // Gender override
				vampreputation = pick("Queen of the Damned", "Blood Queen", "Empress of Blades", "Sinlady", "God-Queen")
	// Titles [Fledgling]
	else
		vamptitle = null
		vampreputation = pick ("Crude","Callow","Unlearned","Neophyte","Novice","Unseasoned","Fledgling","Young","Neonate","Scrapling","Untested","Newly Reisen","Born")//,"Fresh")

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





// Create Objectives
/datum/antagonist/bloodsucker/proc/forge_bloodsucker_objectives() // Fledgling vampires can have different objectives.

			// ROUND ONE: CREWMATE OBJECTIVES //
	// Coffin [REQUIRED]
	// 1a) Embrace Target
	// 1b) Embrace Total
	// 2a) Desecrate
	// 2b) Heart Thief
	// Survive [REQUIRED]


	// Coffin Objective:		Create a Lair
	var/datum/objective/bloodsucker/coffin/coffin_objective = new
	coffin_objective.owner = owner
	coffin_objective.generate_objective()
	add_objective(coffin_objective)

	if (prob(10))
		if (prob(50))
			// Embrace Target Objective:		Turn [Specific Person]into a vampire
			var/datum/objective/bloodsucker/embracetarget/embracetarget_objective = new
			embracetarget_objective.owner = owner
			embracetarget_objective.generate_objective()
			// Keep or Remove Objective?
			if (embracetarget_objective.explanation_text == "Free Objective")
				qdel(embracetarget_objective)
				embracetarget_objective = null
			else
				add_objective(embracetarget_objective)
		else
			// Embrace Quantity Objective:		Turn [X People] into vampires
			//if (!embracetarget_objective || embracetarget_objective == null)
			var/datum/objective/bloodsucker/embrace/embrace_objective = new
			embrace_objective.owner = owner
			embrace_objective.generate_objective()
			add_objective(embrace_objective)

			// ROUND ONE: STEALTH OBJECTIVES //

	// Desecrate Objective:		Spill your blood in a location.
	if (prob(50))
		var/datum/objective/bloodsucker/desecrate/desecrate_objective = new
		desecrate_objective.owner = owner
		desecrate_objective.generate_objective()
		add_objective(desecrate_objective)
	else
		// Heart Thief Objective:		Steal a quantity of hearts.
		var/datum/objective/bloodsucker/heartthief/heartthief_objective = new
		heartthief_objective.owner = owner
		heartthief_objective.generate_objective()
		add_objective(heartthief_objective)

	// Knowledge:				Learn from Dire Tomes hidden in the station.

	// Survive
	var/datum/objective/bloodsucker/survive/survive_objective = new
	survive_objective.owner = owner
	survive_objective.generate_objective()
	add_objective(survive_objective)


/datum/antagonist/bloodsucker/proc/add_objective(var/datum/objective/O)
	owner.objectives += O
	objectives_given += O


/datum/antagonist/bloodsucker/proc/clear_bloodsucker_objectives()
	for(var/O in objectives_given)
		owner.objectives -= O
		qdel(O)
	objectives_given = list() // Traitors had this, so I added it. Not sure why.












/datum/antagonist/bloodsucker/proc/BuyPower(obj/effect/proc_holder/spell/power)
	powers += power
	owner.AddSpell(power)


datum/antagonist/bloodsucker/proc/AssignStarterPowersAndStats()

	// Blood Counter
	add_hud()

	// Powers
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/feed)
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/expelblood)
	//BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/humandisguise)
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/veil)
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/torpidsleep)
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/brawn)
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/haste)
	BuyPower(new /obj/effect/proc_holder/spell/bloodsucker/recover)

	// Language
	owner.current.grant_language(/datum/language/vampiric)
	//var/obj/item/organ/tongue/T = owner.current.getorganslot(ORGAN_SLOT_TONGUE) // Learn to PRONOUNCE Vampire language. Other folks can UNDERSTAND it, but only Bloodsuckers speak it.
		// Populate New List
	//var/list/languages_possible/newList = list() // Borrowed structure from tongue.dm
	//newList += /datum/language/vampiric
	//for(var/datum/language/L in T.languages_possible)
	//	newList += L 		// Take existing language & apply to new list.
	//T.languages_possible = typecacheof(newList) 	// Apply


	// Give Clown a crazy-person power


	// Clear Addictions
	owner.current.reagents.addiction_list = list() // Start over from scratch. Lucky you! At least you're not addicted to blood anymore (if you were)

	// Stats
	if (ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		var/datum/species/S = H.dna.species
		// Make Changes
		S.brutemod *= 0.5
		S.burnmod += 0.5
		S.coldmod = 0
		S.heatmod += 0.5
		S.stunmod *= 0.5
		S.punchdamagelow += 2       //lowest possible punch damage   0
		S.punchdamagehigh += 2      //highest possible punch damage	 9
		S.punchstunthreshold = 8	//damage at which punches from this race will stun  9
		S.siemens_coeff *= 0.5 		//base electrocution coefficient  1

		// Traits
		S.species_traits |= NOZOMBIE
		S.species_traits |= RADIMMUNE
		S.species_traits |= NOHUNGER
		S.species_traits |= NOBREATH
		S.species_traits |= DRINKSBLOOD
		S.species_traits |= VIRUSIMMUNE
		S.species_traits |= RESISTCOLD
		S.species_traits |= NOCRITDAMAGE // No damage from being in critical condition.
		S.species_traits |= RESISTPRESSURE

	// Disabilities
	owner.current.disabilities = 0
	//owner.current.disabilities |= NOCLONE

	// Update Health
	owner.current.setMaxHealth(150)

	// Other Cool Stuff
	var/obj/item/organ/eyes/E = owner.current.getorganslot(ORGAN_SLOT_EYES)
	E.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	E.see_in_dark = 8
	E.flash_protect = -1
	E.sight_flags |= SEE_TURFS // Taken from augmented_eyesight.dm
	owner.current.update_sight()

	// Loyalty
	owner.unconvertable = TRUE

datum/antagonist/bloodsucker/proc/ClearAllPowersAndStats()

	// Blood Counter
	remove_hud()

	// Powers
	while(powers.len)
		var/obj/effect/proc_holder/spell/power = pick(powers)
		powers -= power
		owner.RemoveSpell(power)

	// Language
	owner.current.remove_language(/datum/language/vampiric)
	//var/obj/item/organ/tongue/T = owner.current.getorganslot(ORGAN_SLOT_TONGUE)					// TODO: Create vampire tongue that can pronounce this language. tongue.dm's list of languages is a shared STATIC
	//T.languages_possible = T.languages_possible_base // RESET Tongue's language to default.

	// Stats
	if (ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(H.dna.species.type)
		/*
		var/datum/species/S = H.dna.species
		// Restore Originals
		S.brutemod = initial(S.brutemod)
		S.burnmod = initial(S.burnmod)
		S.coldmod = initial(S.coldmod)
		S.heatmod = initial(S.heatmod)
		S.stunmod = initial(S.stunmod)
		S.punchdamagelow = initial(S.punchdamagelow)
		S.punchdamagehigh = initial(S.punchdamagehigh)
		S.punchstunthreshold = initial(S.punchstunthreshold)
		S.siemens_coeff = initial(S.siemens_coeff)
		*/

	// Disabilities
	//owner.current.disabilities = initial(owner.current.disabilities) // Using FULL HEAL gets rid of this anyway, so don't bother. Vamps can be cloned. Who cares.

	// Update Health
	owner.current.setMaxHealth(100)

	// Goodbye Cool Stuff
	var/obj/item/organ/eyes/E = owner.current.getorganslot(ORGAN_SLOT_EYES)
	E.lighting_alpha = initial(E.lighting_alpha)
	E.see_in_dark = initial(E.lighting_alpha)
	E.flash_protect = initial(E.flash_protect)
	E.sight_flags ^= SEE_TURFS  // Taken from augmented_eyesight.dm
	owner.current.update_sight()

	// Loyalty
	owner.unconvertable = FALSE



/////////////////////////////////////

		// HUD! //


/datum/antagonist/bloodsucker/proc/update_bloodsucker_icons_added(mob/living/bloodsucker, icontype="bloodsucker")
	var/datum/atom_hud/antag/bloodsucker/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]// ANTAG_HUD_DEVIL
	hud.join_hud(bloodsucker)
	set_antag_hud(bloodsucker, icontype) // Located in icons/mob/hud.dmi

/datum/antagonist/bloodsucker/proc/update_bloodsucker_icons_removed(mob/living/bloodsucker)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]//ANTAG_HUD_BLOODSUCKER]
	hud.leave_hud(bloodsucker)
	set_antag_hud(bloodsucker, null)


// NOTE: Gang members can only see their own kind. Perhaps we can have Vassals do the same thing with their master ONLY, and vice versa?
/datum/atom_hud/antag/bloodsucker  // from hud.dm in /datums/   Also see data_huds.dm + antag_hud.dm
	// For Reference:
	//var/list/atom/hudatoms = list() //list of all atoms which display this hud			AKA Every living person goes into the MEDICAL HUD. They just can't see it.
	//var/list/mob/hudusers = list() //list with all mobs who can see the hud				AKA anyone who can SEE the hud.
	//var/list/hud_icons = list() //these will be the indexes for the atom's hud_list


/datum/atom_hud/antag/bloodsucker/proc/add_hud_to_BACKUP_NOT_USED(mob/M) // This is for REFERENCE NOTES only.
	..()
	return
	// Taken DIRECTLY from datums/hud.dm until we can learn how to integrate this method a little more easily.
	if(!M)
		return
	if (!hudusers[M])
		hudusers[M] = 1 // This adds M (the vassal) to the list of people who SEE the hud. This should stay this way, because he IS technically on the list.
		for(var/atom/A in hudatoms)
			add_to_single_hud(M, A) // This adds A to M's hud. That means add_to_single_hud() is where we actually make our changes.
	else
		hudusers[M]++

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


				/////////////////////////////////////


		// BLOOD COUNTER ! //

/datum/hud
	var/obj/screen/bloodsucker/blood_counter/blood_display


/datum/antagonist/bloodsucker/proc/add_hud()
	return /*
	// No Hud? Or already have blood display? Get out.
	if (!owner.current.hud_used || owner.current.hud_used.blood_display)
		return
	// Set up the Hud: Create a Blood Display
	owner.current.hud_used.blood_display = new /obj/screen/bloodsucker/blood_counter
	owner.current.hud_used.infodisplay += owner.current.hud_used.blood_display
	// MAYBE we just have to use this: owner.current.hud_used.show_hud()  to get it to display??
	update_hud()
	// NOTE: Most every other antag hud is created from the _onclick/hud folder. If this fails, we may want to move this stuff up there.
	// NOTE: /datum/hud/Destroy() sets all these Huds to NULL again. Keep that in mind.
	to_chat(owner, "<span class='warning'>DEBUG: add_hud() CREATED HUD: [owner.current.hud_used.blood_display]   </span>")
	*/
/datum/antagonist/bloodsucker/proc/remove_hud()
	// No Hud? Get out.
	if (!owner.current.hud_used)
		return
	owner.current.hud_used.blood_display.invisibility = INVISIBILITY_ABSTRACT
	/*
		// No Hud? Or have no blood display? Get out.
	if (!owner.current.hud_used || !owner.current.hud_used.blood_display)
		return
	// Remove
	owner.current.hud_used.infodisplay -= owner.current.hud_used.blood_display
	qdel(owner.current.hud_used.blood_display)
	owner.current.hud_used.blood_display = null
	*/

/datum/antagonist/bloodsucker/proc/update_hud()
	// No Hud? Get out.
	if (!owner.current.hud_used || !owner.current.hud_used.blood_display)
		return
	// Update Counter
	owner.current.hud_used.blood_display.update_counter(owner.current.blood_volume)

#define ui_blood_display "WEST:6,CENTER-1:15"


/obj/screen/bloodsucker
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/bloodsucker/blood_counter		// NOTE: Look up /obj/screen/devil/soul_counter  in _onclick / hud / human.dm
	icon = 'icons/Fulpstation/fulpicons.dmi'//'icons/mob/screen_gen.dmi'
	name = "Blood Consumed"
	icon_state = "blood_display"//"power_display"
	screen_loc = ui_blood_display

/obj/screen/bloodsucker/blood_counter/proc/update_counter(blood)
	invisibility = 0 // Make Visible
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#FF0000'>[round(blood,1)]</font></div>"

/obj/screen/bloodsucker/blood_counter/proc/clear()
	invisibility = INVISIBILITY_ABSTRACT
















//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//																		VASSALS

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/antagonist/bloodsucker/proc/FreeAllVassals()
	for (var/datum/antagonist/vassal/V in vassals)
		SSticker.mode.remove_vassal(V.owner)








/datum/antagonist/vassal
	var/datum/antagonist/bloodsucker/master // Whom do I obey?

/datum/antagonist/bloodsucker/proc/attempt_turn_vassal(mob/living/carbon/C)
	SSticker.mode.make_vassal(C,owner)

//Proc called when the datum is given to a mind.
/datum/antagonist/vassal/on_gain()

	SSticker.mode.vassals |= owner

	// Assign Master
	var/datum/antagonist/bloodsucker/B = master.owner.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (B)
		B.vassals |= src
	owner.enslave_mind_to_creator(master.owner.current)

	// Add Antag HUD
	update_vassal_icons_added(owner.current, "vassal")

	return ..() // Do base stuff: greet(), etc.

/datum/antagonist/vassal/on_removal()

	// Clear Antag HUD
	update_vassal_icons_removed(owner.current)

	if (master)
		master.vassals -= src
		if (owner.enslaved_to == master.owner)
			owner.enslaved_to = null

	SSticker.mode.vassals -= owner

	return ..() // Do base stuff.


/datum/antagonist/vassal/greet()
	to_chat(src, "<span class='userdanger'>You are now the mortal servant of [master.owner.current], a bloodsucking vampire!</span>")
	to_chat(src, "<span class='boldannounce'>The power of [master.owner.current.p_their()] immortal blood compells you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.<br>\
			You are not required to obey any other Bloodsucker, as only [master.owner.current] is your master. The laws of Nanotransen do not apply to you now; only your vampiric master's word must be obeyed.<span>")
	// Effects...
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.store_memory("You became the mortal servant of [master.owner.current], a bloodsucking vampire!")
	// And to your new Master...
	to_chat(master.owner, "<span class='userdanger'>[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] is now your undying servant!</span>")
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	owner.current.visible_message("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seems calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self.",\
			"<span class='userdanger'><FONT size = 3>With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will.</FONT></span>")
	// Effects...
	owner.store_memory("Your Bloodsucker master has lost their control over you!")
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	// And to your former Master...
	//if (master && master.owner)
	//	to_chat(master.owner, "<span class='userdanger'>You feel the bond with your vassal [owner.current] has somehow been broken!</span>")



/datum/antagonist/vassal/proc/update_vassal_icons_added(mob/living/bloodsucker, icontype="vassal")
	var/datum/atom_hud/antag/bloodsucker/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]// ANTAG_HUD_DEVIL
	hud.join_hud(bloodsucker)
	set_antag_hud(bloodsucker, icontype) // Located in icons/mob/hud.dmi

/datum/antagonist/vassal/proc/update_vassal_icons_removed(mob/living/bloodsucker)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]//ANTAG_HUD_BLOODSUCKER]
	hud.leave_hud(bloodsucker)
	set_antag_hud(bloodsucker, null)

