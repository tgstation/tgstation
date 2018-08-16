/mob/living/simple_animal/hostile/megafauna/dragon
	vore_active = TRUE
	no_vore = FALSE

/mob/living/simple_animal/hostile/megafauna/dragon/Initialize()
	// Create and register 'stomachs'
	var/obj/belly/megafauna/dragon/maw/maw = new(src)
	var/obj/belly/megafauna/dragon/gullet/gullet = new(src)
	var/obj/belly/megafauna/dragon/gut/gut = new(src)
//	for(var/obj/belly/X in list(maw, gullet, gut))
//		vore_organs[X.name] = X
	// Connect 'stomachs' together
	maw.transferlocation = gullet
	gullet.transferlocation = gut
	vore_selected = maw  // NPC eats into maw
	return ..()

/obj/belly/megafauna/dragon
	human_prey_swallow_time = 50 // maybe enough to switch targets if distracted
	nonhuman_prey_swallow_time = 50

/obj/belly/megafauna/dragon/maw
	name = "maw"
	desc = "The maw of the dreaded Ash drake closes around you, engulfing you into a swelteringly hot, disgusting enviroment. The acidic saliva tingles over your form while that tongue pushes you further back...towards the dark gullet beyond."
	vore_verb = "scoop"
	vore_sound = "Stomach Move"
	swallow_time = 20
	escapechance = 25
	// From above, will transfer into gullet
	transferchance = 25
	autotransferchance = 66
	autotransferwait = 200

/obj/belly/megafauna/dragon/gullet
	name = "gullet"
	desc = "A ripple of muscle and arching of the tongue pushes you down like any other food. No choice in the matter, you're simply consumed. The dark ambiance of the outside world is replaced with working, wet flesh. Your only light being what you brought with you."
	swallow_time = 60  // costs extra time to eat directly to here
	escapechance = 5
	vore_sound = "Squish2"
	// From above, will transfer into gut
	transferchance = 25
	autotransferchance = 50
	autotransferwait = 200

/obj/belly/megafauna/dragon/gut
	name = "stomach"
	vore_capacity = 5 //I doubt this many people will actually last in the gut, but...
	vore_sound = "Tauric Swallow"
	desc = "With a rush of burning ichor greeting you, you're introduced to the Drake's stomach. Wrinkled walls greedily grind against you, acidic slimes working into your body as you become fuel and nutriton for a superior predator. All that's left is your body's willingness to resist your destiny."
	digest_mode = DM_DRAGON
	digest_burn = 5
	swallow_time = 100  // costs extra time to eat directly to here
	escapechance = 0