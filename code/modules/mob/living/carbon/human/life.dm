//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//#define DEBUG_LIFE
//#define PROFILE_LIFE

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

#ifdef PROFILE_LIFE
	var/list/profile_life_data=list()
	var/profile_life_starttime=0
#endif

// Doing this during species init breaks shit.
/mob/living/carbon/human/proc/DeferredSpeciesSetup()
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


/mob/living/carbon/human/proc/debug_life(var/stage,var/chat_message)
#ifdef DEBUG_LIFE
	#warning "DEBUG_LIFE enabled in [__FILE__]!"
	if(client && client.prefs.toggles & CHAT_DEBUGLOGS)
		to_chat(src, chat_message)
		last_processed = stage
#endif

/mob/living/carbon/human/proc/profile_life_start()
#ifdef PROFILE_LIFE
	profile_life_starttime=world.timeofday
#endif
	return

/mob/living/carbon/human/proc/profile_life_end(var/procname)
#ifdef PROFILE_LIFE
	// [count, time spent]
	if(!(procname in profile_life_data))
		profile_life_data[procname]=list(0,0)
	var/datablock=profile_life_data[procname]
	datablock[1]=datablock[1]+1
	datablock[2]=datablock[2]+(world.timeofday-profile_life_starttime)
	profile_life_data[procname]=datablock
#endif
	return

#ifdef PROFILE_LIFE
/mob/living/carbon/human/verb/profile_life_report()
	set category = "Debug"
	set name = "Life() Profile Report"

	fdel("profile_life.csv")
	var/f=file("profile_life.csv")
	to_chat(f, "proc,calls,time,time/call")
	for(var/procname in profile_life_data)
		var/data=profile_life_data[procname]
		to_chat(f, "[procname],[data[1]],[data[2]],[data[2]/data[1]]")
	to_chat(usr, "Wrote to profile_life.csv.")
#endif

/mob/living/carbon/human/Life()

	set invisibility = 0
	//set background = 1
	if(timestopped) return 0 //under effects of time magick

#ifdef PROFILE_LIFE
	debug_life("Started", "Starting Life() cycle [cycle]")
#endif
	if(monkeyizing)
		return
	if(!loc)
		return	//Fixing a null error that occurs when the mob isn't found in the world -- TLE
#ifdef PROFILE_LIFE
	debug_life("Called Super", "Successfully called parent.")
#endif
	if(do_deferred_species_setup)
		DeferredSpeciesSetup()
		do_deferred_species_setup=0
#ifdef PROFILE_LIFE
	debug_life("Species Setup", "Successfully setup species if necessary.")
#endif
	//Apparently, the person who wrote this code designed it so that blinded
	//get reset each cycle and then get activated later in the code.
	//Very ugly. I dont care. Moving this stuff here so its easy to find it.
	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	//Update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	var/datum/gas_mixture/environment = loc.return_air()
#ifdef PROFILE_LIFE
	debug_life("Setup Environment", "We have a location and returned air into [environment]")
#endif
	in_stasis = istype(loc, /obj/structure/closet/body_bag/cryobag) && loc:opened == 0 //Nice runtime operator

	if(in_stasis)
		loc:used++ //Ditto above

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !in_stasis)

		if(air_master.current_cycle % 4 == 2 || failed_last_breath) //First, resolve location and get a breath
#ifdef PROFILE_LIFE
			profile_life_start()
#endif
			breathe() //Only try to take a breath every 4 ticks, unless suffocating
#ifdef PROFILE_LIFE
			profile_life_end("breathe")
#endif
			last_processed = "Breathe"

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
				last_processed = "Interacted with our container"
#ifdef PROFILE_LIFE
		debug_life("Handle Breath", "We tried to breathe OR handled an internal object.")
#endif
		if(check_mutations)
			testing("Updating [src.real_name]'s mutations: "+english_list(mutations))
			domutcheck(src,null,MUTCHK_FORCED)
#ifdef PROFILE_LIFE
			profile_life_start()
#endif
			update_mutations()
#ifdef PROFILE_LIFE
			profile_life_end("update_mutations")
#endif
			check_mutations = 0
#ifdef PROFILE_LIFE
		debug_life("Check Mutations", "Successfully checked mutations.")
#endif
		//Updates the number of stored chemicals for powers
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_changeling()
#ifdef PROFILE_LIFE
		profile_life_end("handle_changeling")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle Ling", "Successfully handled changeling datum")
#endif
		//Mutations and radiation
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_mutations_and_radiation()
#ifdef PROFILE_LIFE
		profile_life_end("handle_body_temperature")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle Mut and Rads", "Successfully handled mutations and radiation")
#endif
		//Chemicals in the body
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_chemicals_in_body()
#ifdef PROFILE_LIFE
		profile_life_end("handle_chemicals_in_body")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle Chems", "Successfully handled internal chemicals")
#endif
		//Disabilities
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_disabilities()
#ifdef PROFILE_LIFE
		profile_life_end("handle_disabilities")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle disabilities", "Successfully handled disabilities")
#endif
		//??? debug_life("Handle organs", "Successfully handled organs")

		//Random events (vomiting etc)
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_random_events()
#ifdef PROFILE_LIFE
		profile_life_end("handle_random_events")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle random events", "Successfully handled random events")
#endif
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_virus_updates()
#ifdef PROFILE_LIFE
		profile_life_end("handle_virus_updates")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle Virus", "Successfully handled virus updates")
#endif
		//Stuff in the stomach
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_stomach()
#ifdef PROFILE_LIFE
		profile_life_end("handle_stomach")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle stomach", "Successfully handled stomach")
#endif
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_shock()
#ifdef PROFILE_LIFE
		profile_life_end("handle_shock")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle shock", "Successfully handled shock")
#endif
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_pain()
#ifdef PROFILE_LIFE
		debug_life("Handle pain", "Successfully handled pain")
#endif
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_medical_side_effects()
#ifdef PROFILE_LIFE
		profile_life_end("handle_medical_side_effects")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle side effects", "Successfully handled medical side effects")
#endif
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_equipment()
#ifdef PROFILE_LIFE
		profile_life_end("handle_equipment")
#endif
#ifdef PROFILE_LIFE
		debug_life("Handle equip", "Successfully handled equipment")
#endif
#ifdef PROFILE_LIFE
	profile_life_start()
#endif
	handle_stasis_bag()
#ifdef PROFILE_LIFE
	profile_life_end("handle_stasis_bag")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle stasis", "Successfully handled stasis")
#endif
	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000)) //We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
#ifdef PROFILE_LIFE
		debug_life("DEAD", "We have been dead for too long, we stop here.")
#endif
		cycle = "DEAD"
		return //We go ahead and process them 5 times for HUD images and other stuff though.
#ifdef PROFILE_LIFE
	//Handle temperature/pressure differences between body and environment
	profile_life_start()
#endif
	handle_environment(environment)
#ifdef PROFILE_LIFE
	profile_life_end("handle_environment")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle enviroment", "Successfully handled enviroment")
#endif
#ifdef PROFILE_LIFE
	//Check if we're on fire
	profile_life_start()
#endif
	handle_fire()
#ifdef PROFILE_LIFE
	profile_life_end("handle_fire")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle fire", "Successfully handled fire")
#endif
#ifdef PROFILE_LIFE
	//Status updates, death etc.
	profile_life_start()
#endif
	handle_regular_status_updates()	//Optimized a bit
#ifdef PROFILE_LIFE
	profile_life_end("handle_regular_status_updates")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle Regular Status Updates", "Successfully handled regular status updates")
#endif
#ifdef PROFILE_LIFE
	profile_life_start()
#endif
	update_canmove()
#ifdef PROFILE_LIFE
	profile_life_end("handle_canmove")
#endif
#ifdef PROFILE_LIFE
	debug_life("update canmove", "Successfully updated canmove")
#endif

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
#ifdef PROFILE_LIFE
	debug_life("get visible name", "Successfully got our visible name")
#endif
#ifdef PROFILE_LIFE
	profile_life_start()
#endif
	handle_regular_hud_updates()
#ifdef PROFILE_LIFE
	profile_life_end("handle_regular_hud_updates")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle HUD", "Successfully handled hud update")
#endif



#ifdef PROFILE_LIFE
	profile_life_start()
#endif
	pulse = handle_pulse()
#ifdef PROFILE_LIFE
	profile_life_end("handle_pulse")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle pulse", "Successfully handled pulse")
#endif




#ifdef PROFILE_LIFE
	//Grabbing
	profile_life_start()
#endif
	for(var/obj/item/weapon/grab/G in src)
		G.process()
#ifdef PROFILE_LIFE
	profile_life_end("\[grabs\]")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle grabs", "Successfully handled grabs")
#endif
	if(mind && mind.vampire)
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		handle_vampire()
#ifdef PROFILE_LIFE
		profile_life_end("handle_vampire")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle vampire", "Successfully handled vampire")
#endif
#ifdef PROFILE_LIFE
	profile_life_start()
#endif
	handle_alpha()
#ifdef PROFILE_LIFE
	profile_life_end("handle_alpha")
#endif
#ifdef PROFILE_LIFE
	debug_life("Handle alpha", "Successfully handled alpha")
#endif
	if(update_overlays)
		update_overlays = 0
#ifdef PROFILE_LIFE
		profile_life_start()
#endif
		UpdateDamageIcon()
#ifdef PROFILE_LIFE
		profile_life_end("UpdateDamageIcon")
#endif
	cycle++
	..()

//Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
