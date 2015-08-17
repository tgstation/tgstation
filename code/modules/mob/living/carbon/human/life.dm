//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

#define OXYCONCEN_PLASMEN_IGNITION 0.01 //1% is all it takes.
var/global/list/unconscious_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7"),\
	"8" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8"),\
	"9" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9"),\
	"10" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10"))
var/global/list/oxyloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7"))
var/global/list/brutefireloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6"))
var/global/list/organ_damage_overlays = list(
	"l_hand_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_min", "layer" = 21),\
	"l_hand_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_mid", "layer" = 21),\
	"l_hand_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_max", "layer" = 21),\
	"l_hand_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_gone", "layer" = 21),\
	"r_hand_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_min", "layer" = 21),\
	"r_hand_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_mid", "layer" = 21),\
	"r_hand_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_max", "layer" = 21),\
	"r_hand_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_gone", "layer" = 21),\
	"l_arm_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_min", "layer" = 21),\
	"l_arm_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_mid", "layer" = 21),\
	"l_arm_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_max", "layer" = 21),\
	"l_arm_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_gone", "layer" = 21),\
	"r_arm_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_min", "layer" = 21),\
	"r_arm_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_mid", "layer" = 21),\
	"r_arm_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_max", "layer" = 21),\
	"r_arm_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_gone", "layer" = 21),\
	"l_leg_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_min", "layer" = 21),\
	"l_leg_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_mid", "layer" = 21),\
	"l_leg_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_max", "layer" = 21),\
	"l_leg_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_gone", "layer" = 21),\
	"r_leg_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_min", "layer" = 21),\
	"r_leg_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_mid", "layer" = 21),\
	"r_leg_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_max", "layer" = 21),\
	"r_leg_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_gone", "layer" = 21),\
	"r_foot_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_min", "layer" = 21),\
	"r_foot_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_mid", "layer" = 21),\
	"r_foot_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_max", "layer" = 21),\
	"r_foot_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_gone", "layer" = 21),\
	"l_foot_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_min", "layer" = 21),\
	"l_foot_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_mid", "layer" = 21),\
	"l_foot_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_max", "layer" = 21),\
	"l_foot_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_gone", "layer" = 21),\
	"chest_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_min", "layer" = 21),\
	"chest_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_mid", "layer" = 21),\
	"chest_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_max", "layer" = 21),\
	"chest_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_gone", "layer" = 21),\
	"head_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_min", "layer" = 21),\
	"head_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_mid", "layer" = 21),\
	"head_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_max", "layer" = 21),\
	"head_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_gone", "layer" = 21),\
	"groin_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_min", "layer" = 21),\
	"groin_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_mid", "layer" = 21),\
	"groin_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_max", "layer" = 21),\
	"groin_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_gone", "layer" = 21))
/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/prev_gender = null // Debug for plural genders
	var/temperature_alert = 0
	var/in_stasis = 0
	var/do_deferred_species_setup=0
	var/exposedtimenow = 0
	var/firstexposed = 0
	var/cycle = 0
	var/last_processed = ""

// Doing this during species init breaks shit.
/mob/living/carbon/human/proc/DeferredSpeciesSetup()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/carbon/human/proc/DeferredSpeciesSetup() called tick#: [world.time]")
	var/mut_update=0
	if(species.default_mutations.len>0)
		for(var/mutation in species.default_mutations)
			if(!(mutation in mutations))
				mutations.Add(mutation)
				mut_update=1
	if(species.default_blocks.len>0)
		for(var/block in species.default_blocks)
			if(!dna.GetSEState(block))
				dna.SetSEState(block,1)
				mut_update=1
	if(mut_update)
		domutcheck(src,null,MUTCHK_FORCED)
		update_mutations()

/mob/living/carbon/human/Life()

	set invisibility = 0
	//set background = 1

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Starting Life() cycle [cycle]"
		last_processed = "Started"

	if(monkeyizing)
		return
	if(!loc)
		return	//Fixing a null error that occurs when the mob isn't found in the world -- TLE

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully called parent."
		last_processed = "Called Super"

	if(do_deferred_species_setup)
		DeferredSpeciesSetup()
		do_deferred_species_setup=0

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully setup species if necessary."
		last_processed = "Species Setup"

	//Apparently, the person who wrote this code designed it so that blinded
	//get reset each cycle and then get activated later in the code.
	//Very ugly. I dont care. Moving this stuff here so its easy to find it.
	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	//Update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	var/datum/gas_mixture/environment = loc.return_air()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "We have a location and returned air into [environment]"
		last_processed = "Setup Enviroment"
	in_stasis = istype(loc, /obj/structure/closet/body_bag/cryobag) && loc:opened == 0 //Nice runtime operator

	if(in_stasis)
		loc:used++ //Ditto above

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !in_stasis)

		if(air_master.current_cycle % 4 == 2 || failed_last_breath) //First, resolve location and get a breath
			breathe() //Only try to take a breath every 4 ticks, unless suffocating
			last_processed = "Breathe"

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
				last_processed = "Interacted with our container"

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "We tried to breathe OR handled an internal object."
			last_processed = "Handle Breathe"

		if(check_mutations)
			testing("Updating [src.real_name]'s mutations: "+english_list(mutations))
			domutcheck(src,null,MUTCHK_FORCED)
			update_mutations()
			check_mutations = 0

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully checked mutations."
			last_processed = "Check Mutations"

		//Updates the number of stored chemicals for powers
		handle_changeling()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled changeling datum"
			last_processed = "Handle Ling"

		//Mutations and radiation
		handle_mutations_and_radiation()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled mutations and radiation"
			last_processed = "Handle Mut and Rads"

		//Chemicals in the body
		handle_chemicals_in_body()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled internal chemicals"
			last_processed = "Handle Chems"

		//Disabilities
		handle_disabilities()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled disabilities"
			last_processed = "Handle disabilities"

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled organs"
			last_processed = "Handle organs"

		//Random events (vomiting etc)
		handle_random_events()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled random events"
			last_processed = "Handle random events"

		handle_virus_updates()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled virus updates"
			last_processed = "Handle Virus"

		//Stuff in the stomach
		handle_stomach()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled stomach"
			last_processed = "Handle stomach"

		handle_shock()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled shock"
			last_processed = "Handle shock"

		handle_pain()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled pain"
			last_processed = "Handle pain"

		handle_medical_side_effects()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled medical side effects"
			last_processed = "Handle side effects"

		handle_equipment()

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "Successfully handled equipment"
			last_processed = "Handle equip"

	handle_stasis_bag()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled stasis"
		last_processed = "Handle stasis"

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000)) //We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle

		if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
			src << "We have been dead for too long, we stop here."
			last_processed = "DEAD"
		cycle = "DEAD"
		return //We go ahead and process them 5 times for HUD images and other stuff though.

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled enviroment"
		last_processed = "Handle enviroment"

	//Check if we're on fire
	handle_fire()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled fire"
		last_processed = "Handle fire"

	//Status updates, death etc.
	handle_regular_status_updates()	//Optimized a bit

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled regular status updates"
		last_processed = "Handle Regular Status Updates"

	update_canmove()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully updated canmove"
		last_processed = "update canmove"

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully got our visible name"
		last_processed = "get visible name"

	handle_regular_hud_updates()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled hud update"
		last_processed = "Handle HUD"

	pulse = handle_pulse()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled pulse"
		last_processed = "Handle pulse"

	//Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled grabs"
		last_processed = "Handle grabs"

	if(mind && mind.vampire)
		handle_vampire()

	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		src << "Successfully handled vampire"
		last_processed = "Handle vampire"

	if(update_overlays)
		update_overlays = 0
		UpdateDamageIcon()
	cycle++
	..()

//Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
