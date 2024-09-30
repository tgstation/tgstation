//code & items for the hauntedtradingpost.dmm ruin
//CONTAINS: [Lore Papers],[Outpost ID Cards],[Gimmick Treasure],[Hazards & Traps],[Custom Turrets]

// [Lore Papers]
// clues to traps that exist in the ruin or just insights into the backstory of the place
/obj/item/paper/fluff/ruins/hauntedtradingpost/warning
	name = "Last Warning"
	default_raw_text = "Next person who breaks a vending machine fucking around with those fucking toy guns gets fired on the spot. Try me. I am SICK of this shit.<BR><BR>Signed, Your Fucking Boss (Who Can Fucking Fire Your Ass)"

/obj/item/paper/fluff/ruins/hauntedtradingpost/warning/turrets
	name = "Warning! Important! Read this!"
	default_raw_text = "Foam darts do not go in the defence turrets! Live ammo only!"

/obj/item/paper/fluff/ruins/hauntedtradingpost/brainstorming
	name = "Notes"
	default_raw_text = "Branding: Pizza In Your Pocket (check focus groups)<BR><BR>Tomato Mozzerella Basil<BR>etc<BR><BR>Spider 17-02667 Store 31-00314<BR><BR>18,000 approx BSD<BR><BR>common allergens - ?<BR><BR><BR>6127"

/obj/item/paper/fluff/ruins/hauntedtradingpost/brainstorming/eureka
	default_raw_text = "Got some ingredients from the moth trading fleet and used some of our discretionary budget to hire some factory space. Prototypes are going down well with both public and employees. If we can get central to fund mass production we'll be seeing a 18% permanant increase in regional profit according to AI. This fits the local brunch market *perfectly*."

/obj/item/paper/fluff/ruins/hauntedtradingpost/brainstorming/eureka2
	default_raw_text = "Early experiments with a fully carb-free recipe going well. Taste tests are all positive, just need a way to reduce costs."

/obj/item/paper/fluff/ruins/hauntedtradingpost/brainstorming/eureka3
	default_raw_text = "PROJECT BIG DONK<BR>RnD has a few prototypes prepared.<BR>Testing will be complete by the end of the week."

/obj/item/paper/fluff/ruins/hauntedtradingpost/rpgclub
	name = "RPG Club"
	default_raw_text = "RPG Club is every Thursday from 20:00 to 01:00 AM. Entry to the break room is strictly by invitation only during that period of time. <BR> <BR> We apologise for any inconvenience."

/obj/item/paper/fluff/ruins/hauntedtradingpost/rpgrules
	name = "GM Notes"
	default_raw_text = "Session 4 NPCS <BR> Shadow Warriors <BR> S  A  T  C  H <BR> 40 65 40 15 10 <BR><BR>Shadow Clan Underlord <BR> S  A  T  C  H <BR> 40 65 40 15 10 <BR>Note: Gets shadow magic.<BR><BR><BR>Dire Corgi <BR> S  A  T  C  H <BR> 60 25 65 25 12 <BR><BR>If they beat this let them roll on loot table 4 twice but if it's 65-70 or 15-30 make it magic boots instead."

/obj/item/paper/fluff/ruins/hauntedtradingpost/curatorsnote
	name = "For Adventurers"
	default_raw_text = "The food court and the stalls are safe, everywhere else isn't. There's safes in the stalls and I didn't have a way to open them so if you can get whatever's inside, good for you. The employees area can be entered by tailing the bots, but security systems are active back there. I got shot by a turret taking a look, and when I stitched myself up and tried the other door I walked into a booby trap and nearly lost an arm.<BR><BR>If you're investigating this signal - BEWARE.<BR>For the record, I decided nothing in there's worth the risk. If you're braver than me, good luck.<BR>Signed, Curator P."

/obj/item/paper/fluff/ruins/hauntedtradingpost/officememo
	name = "Memo"
	default_raw_text = "The AI-Guided Defense System Will Stay Active Indefinitely To Protect Company Property. Please Ensure All Personal Items Are Removed From The Premises, As They Will Be Impossible To Recover If Forgotten. <BR><BR> Donk Co. Takes No Responsibility For Lost Personal Property Or Affects."

/obj/item/paper/fluff/ruins/hauntedtradingpost/receipt
	name = "Old Receipt"
	desc = "A ratty old sales receipt printed on cheap thermal paper."
	default_raw_text = "DONK CO OUTLET 6013<BR>YOUR SERVER TODAY WAS: COLM<BR><BR>2x DONKPOCKETPIZBOX    400<BR>1x CRYPTOGRAPHICSEQ    800<BR>2x CRYPTOGRAPHICTOY    200<BR>1x DONKPOCKETPLUSHY    120<BR><BR>TOTAL VALUE            1520<BR><BR>PAYMENT: CASH"
	icon_state = "paperslip"

/obj/item/paper/fluff/ruins/hauntedtradingpost/receipt/alternate
	default_raw_text = "DONK CO OUTLET 6013<BR>YOUR SERVER TODAY WAS: VLAD<BR><BR>1x DONKPOCKETBERBOX    200<BR>1x GORLEXMODSUITRED    1400<BR>1x MODSUITMICROWAVE    200<BR><BR>TOTAL VALUE            1800<BR><BR>PAYMENT: CASH"

/obj/item/paper/fluff/ruins/hauntedtradingpost/receipt/alternate_alt
	default_raw_text = "DONK CO OUTLET 6013<BR>YOUR SERVER TODAY WAS: COLM<BR><BR>10xDONKPOCKETORGBOX   2000<BR>4x GORLEXMODSUITRED    9600<BR>4x MODSUITMICROWAVE    800<BR><BR>TOTAL VALUE           13400<BR><BR>PAYMENT: CARD"

/obj/item/paper/fluff/ruins/hauntedtradingpost/nomodsuits
	name = "Notice"
	desc = "A bunch of words have been written on this slip of paper. Truly, this is the future."
	default_raw_text = "We are SOLD OUT of modsuits."
	icon_state = "paperslip"

/obj/item/paper/fluff/ruins/hauntedtradingpost/oldnote
	name = "Old Note"
	default_raw_text = "Remember to check all the ammo before it's fed into the turrets. If the wrong caliber is loaded, the turrets will malfunction.<BR>We use 9mm ammunition ONLY."

/obj/item/paper/fluff/ruins/hauntedtradingpost/oldnote/aiclue
	name = "Old Handwritten Note"
	default_raw_text = "All the appliances are now hooked up to the AI. If there's any problems, report it to the Cybersun rep (Mr Satung)."

// [Outpost ID Cards]
//ID cards for the space ruin
/obj/item/card/id/away/donk
	name = "\improper Donk Co. ID Card"
	desc = "A plastic card that identifies its bearer as an employee of Donk Co. There are electronic chips embedded to communicate with airlocks and other machines. It does not have a name attached."
	icon_state = "card_donk"
	trim = /datum/id_trim/away/hauntedtradingpost

/obj/item/card/id/away/donk/boss
	desc = "A plastic card that identifies its bearer as a senior employee of Donk Co. There are electronic chips embedded to communicate with airlocks and other machines. It does not have a name attached."
	icon_state = "card_donkboss"
	trim = /datum/id_trim/away/hauntedtradingpost/boss

// [Gimmick Treasure]
// loot & weird items that should only exist in hauntedtradingpost.dmm
//aquarium with two donkfish in it
/obj/structure/aquarium/donkfish
	name = "office aquarium"
	desc = "A home for captive fish. This one has 'DONK CO' engraved on the glass."

/obj/structure/aquarium/donkfish/Initialize(mapload)
	. = ..()
	new /obj/item/aquarium_prop/rocks(src)
	new /obj/item/aquarium_prop/seaweed(src)
	new /obj/item/fish/donkfish(src)
	new /obj/item/fish/donkfish(src)
	create_reagents(20, SEALED_CONTAINER)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 20)

//gimmick ketchup bottle for healing minor injuries
/obj/item/reagent_containers/condiment/donksauce
	name = "\improper Donk Co. Secret Sauce"
	desc = "The famous ketchup with a highly classified recipe."
	list_reagents = list(
		/datum/reagent/consumable/ketchup = 25,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/consumable/astrotame = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/bungojuice = 1,
		/datum/reagent/consumable/curry_powder = 1,
		/datum/reagent/consumable/soymilk = 1,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/consumable/vitfro = 1,
	)
	icon_state = "ketchup"
	fill_icon_thresholds = null

// [Hazards & Traps]
//cyborg holobarriers that die when the boss dies, how exciting
#define SELFDESTRUCT_QUEUE "hauntedtradingpost_sd" //make sure it matches the AI cores ID
/obj/structure/holosign/barrier/cyborg/cybersun_ai_shield
	desc = "A fragile holographic energy field projected by an AI core. It keeps unwanted humanoids at safe distance."

/obj/structure/holosign/barrier/cyborg/cybersun_ai_shield/Initialize(mapload)
	. = ..()
	if(mapload) //shouldnt queue when we arent even part of a ruin, probably admin shitspawned
		SSqueuelinks.add_to_queue(src, SELFDESTRUCT_QUEUE)

//smes that produces power, until the boss dies then it self destructs and you gotta make your own power
/obj/machinery/power/smes/magical/cybersun
	name = "cybersun-brand power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. It looks like any other SMES unit, except this one says 'Cybersun' on it."
	//is this being used as part of the haunted trading post ruin? if true, will self destruct when boss dies
	var/donk_ai_slave = FALSE

/obj/machinery/power/smes/magical/cybersun/Initialize(mapload)
	. = ..()
	if(donk_ai_slave)
		SSqueuelinks.add_to_queue(src, SELFDESTRUCT_QUEUE)

//this is a trigger for traps involving doors and shutters
//doors get closed and bolted, shutters get cycled open/closed
/obj/machinery/button/door/invisible_tripwire
	name = "Sonic Tripwire"
	desc = "An invisible trigger for shutters and doors. Triggers when someone steps on the tile."
	max_integrity = 50
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	//is this being used as part of the haunted trading post ruin? if true, will self destruct when boss dies
	var/donk_ai_slave = FALSE
	//can the trap trigger more than once?
	var/multiuse = FALSE
	//(if multiuse) how many times the trap can trigger. 0 or lower is infinite
	var/uses_remaining = 0
	//if true, the trap will unbolt all doors it bolted and cycle shutters a second time after a delay
	var/resets_self = FALSE
	//time before resets_self kicks in
	var/reset_timer = 1.8 SECONDS
	//when multiple tripwires are in the same suicide pact, they will all die when any of them die
	var/suicide_pact = FALSE
	//id of the suicide pact this tripwire is in
	var/suicide_pact_id

/obj/machinery/button/door/invisible_tripwire/Initialize(mapload)
	. = ..()
	if(donk_ai_slave)
		SSqueuelinks.add_to_queue(src, SELFDESTRUCT_QUEUE)
	if(suicide_pact && suicide_pact_id != null)
		SSqueuelinks.add_to_queue(src, suicide_pact_id)
		. = INITIALIZE_HINT_LATELOAD
	var/static/list/loc_connections = list(
	COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/button/door/invisible_tripwire/post_machine_initialize()
	. = ..()
	if(!suicide_pact || isnull(SSqueuelinks.queues[suicide_pact_id]))
		return // we got beat to it
	SSqueuelinks.pop_link(suicide_pact_id)

/obj/machinery/button/door/invisible_tripwire/MatchedLinks(id, list/partners)
	if(id != suicide_pact_id)
		return
	for(var/partner in partners)
		RegisterSignal(partner, COMSIG_PUZZLE_COMPLETED, TYPE_PROC_REF(/datum, selfdelete))

/obj/machinery/button/door/invisible_tripwire/proc/on_entered(atom/source, atom/movable/victim)
	SIGNAL_HANDLER
	if(!isliving(victim))
		return
	var/mob/living/target = victim
	if(target.stat != DEAD && target.mob_size == MOB_SIZE_HUMAN && target.mob_biotypes != MOB_ROBOTIC)
		tripwire_triggered(target)
		if(multiuse && uses_remaining < 1)
			uses_remaining--
		if(resets_self)
			addtimer(CALLBACK(src, PROC_REF(tripwire_triggered), victim), reset_timer)

/obj/machinery/button/door/invisible_tripwire/proc/tripwire_triggered(atom/victim)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, interact), victim)
	if(multiuse && uses_remaining != 1)
		return
	if(suicide_pact && suicide_pact_id)
		SEND_SIGNAL(src, COMSIG_PUZZLE_COMPLETED)
	qdel(src)

//door button that destroys itself when it is pressed
/obj/machinery/button/door/selfdestructs
	icon_state= "button-warning"
	skin = "-warning"

/obj/machinery/button/door/selfdestructs/attempt_press(mob/user)
	. = ..()
	do_sparks(rand(1,3), src)
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	qdel(src)

//trap that gloms onto the first machine it finds on its tile, and lives inside it
//then it zaps everyone who gets close. disarm by dissassembling the machine, or running out its charges
/obj/effect/overloader_trap
	name = "overloader trap"
	desc = "A trap that overloads machines to electrify people who walk nearby."
	alpha = 70
	max_integrity = 50
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/effects.dmi'
	icon_state = "empdisable"
	//trap wont damage mobs in its faction
	faction = list(ROLE_SYNDICATE)
	invisibility = INVISIBILITY_ABSTRACT
	plane = ABOVE_GAME_PLANE
	//datum we use to trigger when someones close
	var/datum/proximity_monitor/proximity_monitor
	// how close someone has to be to set the trap off
	var/trigger_range = 1
	// max range the trap can zap someone
	var/shock_range = 1
	/// damage from getting zapped by this trap
	var/shock_damage = 35
	// length of time target spends stunned
	var/stun_duration = 1.5 SECONDS
	// length of time targets spend jittery
	var/jitter_time = 5 SECONDS
	// length of time targets stutter
	var/stutter_time = 2 SECONDS
	//is this being used as part of the haunted trading post ruin? if true, will self destruct when boss dies
	var/donk_ai_slave = FALSE
	// machine that the trap inhabits
	var/obj/structure/host_machine
	// turf that the trap is on
	var/turf/my_turf
	//how long until trap zaps everything, after it detects something
	var/trigger_delay = 0.7 SECONDS
	COOLDOWN_DECLARE(trigger_cooldown)
	//time until trap can be triggered again
	var/trigger_cooldown_duration = 4 SECONDS
	//max amount of times the trap can trigger
	var/uses_remaining = 4
	//amount of damage the trap does to the machine its on, when its triggered
	//this can kill the machine and if it does, the trap effectively disarms itself
	//so acts as a soft cap of sorts on number of trap activations
	var/machine_overload_damage = 80 //machine integrity is usually 200 or 300

/obj/effect/overloader_trap/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 0)
	proximity_monitor?.set_range(trigger_range)
	my_turf = get_turf(src)
	host_machine = locate(/obj/machinery) in loc
	if(donk_ai_slave)
		SSqueuelinks.add_to_queue(src, SELFDESTRUCT_QUEUE)

/obj/effect/overloader_trap/proc/check_faction(mob/target)
	for(var/faction1 in faction)
		if(faction1 in target.faction)
			return TRUE
	return FALSE

/obj/effect/overloader_trap/HasProximity(mob/living)
	if(!locate(host_machine) in loc) //muh machine's gone, delete myself because im disarmed
		qdel(src)
		return
	if(!COOLDOWN_FINISHED(src, trigger_cooldown)) //do nothing if we're on cooldown
		return
	if(uses_remaining == 0) //deletes trap if it triggers when it has no uses left. should only happen if var edited but lets just be safe
		qdel(src)
		return
	if (!isliving(living)) //ensure the guy triggering us is alive
		return
	if (living.stat && check_faction(living)) //and make sure it ain't someone on our team
		return
	COOLDOWN_START(src, trigger_cooldown, 4 SECONDS)
	trap_alerted()

/obj/effect/overloader_trap/proc/trap_alerted()
	if(host_machine in loc)
		visible_message(span_boldwarning("Sparks fly from [host_machine] as it shakes vigorously!"))
		do_sparks(number = 3, source = host_machine)
		host_machine.Shake(2, 1, trigger_delay)
		addtimer(CALLBACK(src, PROC_REF(trap_effect)), trigger_delay)
	//if someone breaks or moves the machine before the trap goes off, this should fail to do anything

/obj/effect/overloader_trap/proc/trap_effect()
	for(var/mob/living/living_mob in range(shock_range, src))
		if(faction_check_atom(living_mob))
			continue
		to_chat(living_mob, span_warning("You are struck by an arc of electricity!"))
		src.Beam(living_mob, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
		living_mob.electrocute_act(shock_damage, host_machine, 1, SHOCK_NOGLOVES, stun_duration, jitter_time, stutter_time)
	for(var/obj/item/food/deadmouse in range(shock_range, src))
		src.Beam(deadmouse, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	do_sparks(number = 1, source = host_machine)
	host_machine.take_damage(machine_overload_damage, sound_effect = FALSE)
	uses_remaining--
	if(uses_remaining <= 0)
		qdel(src)

// [Custom Turrets]
//these are the non-mob defenders of the hauntedtradingpost.dmm ruin
//they are controlled with a syndicate ID and are hostile to anything non-syndicate by default

//donk turret - 9mm
/obj/machinery/porta_turret/syndicate/donk
	//Medium speed, medium damage, fragile. Does brute damage.
	name = "\improper Donk Co. Defense Turret"
	icon_state = "donk_lethal"
	max_integrity = 120
	base_icon_state = "donk"
	stun_projectile = /obj/projectile/bullet/foam_dart/riot
	lethal_projectile = /obj/projectile/bullet/c9mm/blunttip
	lethal_projectile_sound = 'sound/items/weapons/gun/pistol/shot.ogg'
	stun_projectile_sound = 'sound/items/weapons/gun/pistol/shot.ogg'
	desc = "A ballistic machine gun auto-turret with Donk Co. branding. It uses 9mm rounds."
	armor_type = /datum/armor/donk_turret
	scan_range = 6
	shot_delay = 10

/datum/armor/donk_turret
	melee = 20
	bullet = 20
	laser = 40
	energy = 40
	bomb = 20
	fire = 50
	acid = 100

/obj/projectile/bullet/c9mm/blunttip
	wound_bonus = -40 //this will still cause bleeding wounds, but less often.

//cybersun turret - plasma beam
/obj/machinery/porta_turret/syndicate/energy/cybersun
	//Slow speed, high damage. Does burn damage.
	name = "\improper Cybersun Plasma Auto-turret"
	icon_state = "red_lethal"
	base_icon_state = "red"
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/items/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/laser/cybersun
	lethal_projectile_sound = 'sound/items/weapons/lasercannonfire.ogg'
	desc = "An energy gun auto-turret with Cybersun branding. It fires high-energy plasma beams that do a lot of damage, but it can be fairly slow."
	armor_type = /datum/armor/syndicate_shuttle
	scan_range = 6
	shot_delay = 50
	always_up = FALSE
	has_cover = TRUE

/obj/projectile/beam/laser/cybersun
	name = "plasma beam"
	desc = "A big red plasma beam, currently in flight."
	icon_state = "lava"
	light_color = COLOR_DARK_RED
	damage = 30
	wound_bonus = -50

#undef SELFDESTRUCT_QUEUE
