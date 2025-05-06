/datum/reagent/consumable/ethanol/whiskey
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC //let's not force the detective to change his alcohol brand

//SYNTHETIC DRINKS
/datum/reagent/consumable/ethanol/synthanol
	name = "Synthanol"
	description = "A runny liquid with conductive capacities. Its effects on synthetics are similar to those of alcohol on organics."
	color = "#1BB1FF"
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC
	boozepwr = 50
	quality = DRINK_NICE
	taste_description = "motor oil"

/datum/glass_style/drinking_glass/synthanol
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "synthanolglass"
	name = "glass of synthanol"
	desc = "The equivalent of alcohol for synthetic crewmembers. They'd find it awful if they had tastebuds too."

/datum/reagent/consumable/ethanol/synthanol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(!(affected_mob.mob_biotypes & MOB_ROBOTIC))
		affected_mob.reagents.remove_reagent(type, 3.6 * REM * seconds_per_tick) //gets removed from organics very fast
		if(prob(25))
			affected_mob.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 5)
	return ..()

/datum/reagent/consumable/ethanol/synthanol/expose_mob(mob/living/carbon/C, method=TOUCH, volume)
	. = ..()
	if(C.mob_biotypes & MOB_ROBOTIC)
		return
	if(method == INGEST)
		to_chat(C, pick(span_danger("That was awful!"), span_danger("That was disgusting!")))

/datum/reagent/consumable/ethanol/synthanol/robottears
	name = "Robot Tears"
	description = "An oily substance that an IPC could technically consider a 'drink'."
	color = "#363636"
	quality = DRINK_GOOD
	boozepwr = 25
	taste_description = "existential angst"

/datum/glass_style/drinking_glass/synthanol/robottears
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol/robottears
	icon_state = "robottearsglass"
	name = "glass of robot tears"
	desc = "No robots were hurt in the making of this drink."

/datum/reagent/consumable/ethanol/synthanol/trinary
	name = "Trinary"
	description = "A fruit drink meant only for synthetics, however that works."
	color = "#ADB21f"
	quality = DRINK_GOOD
	boozepwr = 20
	taste_description = "modem static"

/datum/glass_style/drinking_glass/synthanol/trinary
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol/trinary
	icon_state = "trinaryglass"
	name = "glass of trinary"
	desc = "Colorful drink made for synthetic crewmembers. It doesn't seem like it would taste well."

/datum/reagent/consumable/ethanol/synthanol/servo
	name = "Servo"
	description = "A drink containing some organic ingredients, but meant only for synthetics."
	color = "#5B3210"
	quality = DRINK_GOOD
	boozepwr = 25
	taste_description = "motor oil and cocoa"

/datum/glass_style/drinking_glass/synthanol/servo
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol/servo
	icon_state = "servoglass"
	name = "glass of servo"
	desc = "Chocolate - based drink made for IPCs. Not sure if anyone's actually tried out the recipe."

/datum/reagent/consumable/ethanol/synthanol/uplink
	name = "Uplink"
	description = "A potent mix of alcohol and synthanol. Will only work on synthetics."
	color = "#E7AE04"
	quality = DRINK_GOOD
	boozepwr = 15
	taste_description = "a GUI in visual basic"

/datum/glass_style/drinking_glass/synthanol/uplink
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol/uplink
	icon_state = "uplinkglass"
	name = "glass of uplink"
	desc = "An exquisite mix of the finest liquoirs and synthanol. Meant only for synthetics."

/datum/reagent/consumable/ethanol/synthanol/synthncoke
	name = "Synth 'n Coke"
	description = "The classic drink adjusted for a robot's tastes."
	color = "#7204E7"
	quality = DRINK_GOOD
	boozepwr = 25
	taste_description = "fizzy motor oil"

/datum/glass_style/drinking_glass/synthanol/synthncoke
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol/synthncoke
	icon_state = "synthncokeglass"
	name = "glass of synth 'n coke"
	desc = "Classic drink altered to fit the tastes of a robot, contains de-rustifying properties. Bad idea to drink if you're made of carbon."

/datum/reagent/consumable/ethanol/synthanol/synthignon
	name = "Synthignon"
	description = "Someone mixed wine and alcohol for robots. Hope you're proud of yourself."
	color = "#D004E7"
	quality = DRINK_GOOD
	boozepwr = 25
	taste_description = "fancy motor oil"

/datum/glass_style/drinking_glass/synthanol/synthignon
	required_drink_type = /datum/reagent/consumable/ethanol/synthanol/synthignon
	icon_state = "synthignonglass"
	name = "glass of synthignon"
	desc = "Someone mixed good wine and robot booze. Romantic, but atrocious."


// Other Booze
/datum/reagent/consumable/ethanol/bloody_mary
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING

/datum/reagent/consumable/ethanol/hot_toddy
	name = "Hot Toddy"
	description = "An old fashioned cocktail made of honey, rum, and tea."
	color = "#e4830d"
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "sweet spiced tea"

/datum/glass_style/drinking_glass/hot_toddy
	required_drink_type = /datum/reagent/consumable/ethanol/hot_toddy
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "hot_toddy"
	name = "hot toddy glass"
	desc = "An old fashioned cocktail made of honey, rum, and tea, it tastes like sweet holiday spices."

/datum/reagent/consumable/ethanol/hellfire
	name = "Hellfire"
	description = "A nice drink that isn't quite as hot as it looks."
	color = "#fb2203"
	boozepwr = 60
	quality = DRINK_VERYGOOD
	taste_description = "cold flames that lick at the top of your mouth"

/datum/glass_style/drinking_glass/hellfire
	required_drink_type = /datum/reagent/consumable/ethanol/hellfire
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "hellfire"
	name = "glass of hellfire"
	desc = "An amber colored drink that isn't quite as hot as it looks."

/datum/reagent/consumable/ethanol/hellfire/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(30 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 0, BODYTEMP_NORMAL + 30)

/datum/reagent/consumable/ethanol/sins_delight
	name = "Sin's Delight"
	description = "The drink smells like the seven sins."
	color = "#330000"
	boozepwr = 66
	quality = DRINK_FANTASTIC
	taste_description = "overpowering sweetness with a touch of sourness, followed by iron and the sensation of a warm summer breeze"
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING //component drink is demon's blood, thus this drink is made with blood so hemophages can comfortably drink it

/datum/glass_style/drinking_glass/sins_delight
	required_drink_type = /datum/reagent/consumable/ethanol/sins_delight
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "sins_delight"
	name = "glass of sin's delight"
	desc = "You can smell the seven sins rolling off the top of the glass."

/datum/reagent/consumable/ethanol/strawberry_daiquiri
	name = "Strawberry Daiquiri"
	description = "Pink looking alcoholic drink."
	boozepwr = 20
	color = "#FF4A74"
	quality = DRINK_NICE
	taste_description = "sweet strawberry, lime and the ocean breeze"

/datum/glass_style/drinking_glass/strawberry_daiquiri
	required_drink_type = /datum/reagent/consumable/ethanol/strawberry_daiquiri
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "strawberry_daiquiri"
	name = "glass of strawberry daiquiri"
	desc = "Pink looking drink with flowers and a big straw to sip it. Looks sweet and refreshing, perfect for warm days."

/datum/reagent/consumable/ethanol/liz_fizz
	name = "Liz Fizz"
	description = "Triple citrus layered with some ice and cream."
	boozepwr = 0
	color = "#D8FF59"
	quality = DRINK_NICE
	taste_description = "brain freezing sourness"

/datum/glass_style/drinking_glass/liz_fizz
	required_drink_type = /datum/reagent/consumable/ethanol/liz_fizz
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "liz_fizz"
	name = "glass of liz fizz"
	desc = "Looks like a citrus sherbet seperated in layers? Why would anyone want that is beyond you."

/datum/reagent/consumable/ethanol/miami_vice
	name = "Miami Vice"
	description = "A drink layering Pina Colada and Strawberry Daiquiri"
	boozepwr = 30
	color = "#D8FF59"
	quality = DRINK_FANTASTIC
	taste_description = "sweet and refreshing flavor, complemented with strawberries and coconut, and hints of citrus"

/datum/glass_style/drinking_glass/miami_vice
	required_drink_type = /datum/reagent/consumable/ethanol/miami_vice
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "miami_vice"
	name = "glass of miami vice"
	desc = "Strawberries and coconut, like yin and yang."

/datum/reagent/consumable/ethanol/malibu_sunset
	name = "Malibu Sunset"
	description = "A drink consisting of creme de coconut and tropical juices"
	boozepwr = 20
	color = "#FF9473"
	quality = DRINK_VERYGOOD
	taste_description = "coconut, with orange and grenadine accents"

/datum/glass_style/drinking_glass/malibu_sunset
	required_drink_type = /datum/reagent/consumable/ethanol/malibu_sunset
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "malibu_sunset"
	name = "glass of malibu sunset"
	desc = "Tropical looking drinks, with ice cubes hovering on the surface and grenadine coloring the bottom."

/datum/reagent/consumable/ethanol/hotlime_miami
	name = "Hotlime Miami"
	description = "The essence of the 90's, if they were a bloody mess that is."
	boozepwr = 40
	color = "#A7FAE8"
	quality = DRINK_FANTASTIC
	taste_description = "coconut and aesthetic violence"

/datum/glass_style/drinking_glass/hotlime_miami
	required_drink_type = /datum/reagent/consumable/ethanol/hotlime_miami
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "hotlime_miami"
	name = "glass of hotlime miami"
	desc = "This looks very aesthetically pleasing."

/datum/reagent/consumable/ethanol/hotlime_miami/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_drugginess(1.5 MINUTES * REM * seconds_per_tick)
	if(affected_mob.adjustStaminaLoss(-2 * REM * seconds_per_tick, updating_stamina = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/ethanol/coggrog
	name = "Cog Grog"
	description = "Now you can fill yourself with the power of Ratvar!"
	color = rgb(255, 201, 49)
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "a brass taste with a hint of oil"

/datum/glass_style/drinking_glass/coggrog
	required_drink_type = /datum/reagent/consumable/ethanol/coggrog
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "coggrog"
	name = "glass of cog grog"
	desc = "Not even Ratvar's Four Generals could withstand this!  Qevax Jryy!"

/datum/reagent/consumable/ethanol/badtouch
	name = "Bad Touch"
	description = "A sour and vintage drink. Some say the inventor gets slapped a lot."
	color = rgb(31, 181, 99)
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "a slap to the face"

/datum/glass_style/drinking_glass/badtouch
	required_drink_type = /datum/reagent/consumable/ethanol/badtouch
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "badtouch"
	name = "glass of bad touch"
	desc = "We're nothing but mammals after all."

/datum/reagent/consumable/ethanol/marsblast
	name = "Marsblast"
	description = "A spicy and manly drink in honor of the first colonists on Mars."
	color = rgb(246, 143, 55)
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "hot red sand"

/datum/glass_style/drinking_glass/marsblast
	required_drink_type = /datum/reagent/consumable/ethanol/marsblast
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "marsblast"
	name = "glass of marsblast"
	desc = "One of these is enough to leave your face as red as the planet."

/datum/reagent/consumable/ethanol/mercuryblast
	name = "Mercuryblast"
	description = "A sour burningly cold drink that's sure to chill the drinker."
	color = rgb(29, 148, 213)
	boozepwr = 40
	quality = DRINK_VERYGOOD
	taste_description = "chills down your spine"

/datum/glass_style/drinking_glass/mercuryblast
	required_drink_type = /datum/reagent/consumable/ethanol/mercuryblast
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "mercuryblast"
	name = "glass of mercuryblast"
	desc = "No thermometers were harmed in the creation of this drink"

/datum/reagent/consumable/ethanol/mercuryblast/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, T0C)

/datum/reagent/consumable/ethanol/piledriver
	name = "Piledriver"
	description = "A bright drink that leaves you with a burning sensation."
	color = rgb(241, 146, 59)
	boozepwr = 45
	quality = DRINK_NICE
	taste_description = "a fire in your throat"

/datum/glass_style/drinking_glass/piledriver
	required_drink_type = /datum/reagent/consumable/ethanol/piledriver
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "piledriver"
	name = "glass of piledriver"
	desc = "Not the only thing to leave your throat sore."

/datum/reagent/consumable/ethanol/zenstar
	name = "Zen Star"
	description = "A sour and bland drink, rather disappointing."
	color = rgb(51, 87, 203)
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "disappointment"

/datum/glass_style/drinking_glass/zenstar
	required_drink_type = /datum/reagent/consumable/ethanol/zenstar
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "zenstar"
	name = "glass of zen star"
	desc = "You'd think something so balanced would actually taste nice... you'd be dead wrong."


// RACE SPECIFIC DRINKS

/datum/reagent/consumable/ethanol/coldscales
	name = "Coldscales"
	color = "#5AEB52" //(90, 235, 82)
	description = "A cold looking drink made for people with scales."
	boozepwr = 50 //strong!
	taste_description = "dead flies"

/datum/glass_style/drinking_glass/coldscales
	required_drink_type = /datum/reagent/consumable/ethanol/coldscales
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "coldscales"
	name = "glass of coldscales"
	desc = "A soft green drink that looks inviting!"

/datum/reagent/consumable/ethanol/coldscales/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(islizard(exposed_mob))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/oil_drum
	name = "Oil Drum"
	color = "#000000" //(0, 0, 0)
	description = "Industrial grade oil mixed with some ethanol to make it a drink. Somehow not known to be toxic."
	boozepwr = 45
	taste_description = "oil spill"

/datum/glass_style/drinking_glass/oil_drum
	required_drink_type = /datum/reagent/consumable/ethanol/oil_drum
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "oil_drum"
	name = "drum of oil"
	desc = "A gray can of booze and oil..."

/datum/reagent/consumable/ethanol/oil_drum/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(MOB_ROBOTIC)
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/nord_king
	name = "Nord King"
	color = "#EB1010" //(235, 16, 16)
	description = "Strong mead mixed with more honey and ethanol. Beloved by its human patrons."
	boozepwr = 50 //strong!
	taste_description = "honey and red wine"
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING

/datum/glass_style/drinking_glass/nord_king
	required_drink_type = /datum/reagent/consumable/ethanol/nord_king
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "nord_king"
	name = "keg of nord king"
	desc = "A dripping keg of red mead."

/datum/reagent/consumable/ethanol/nord_king/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(HAS_TRAIT(exposed_mob, TRAIT_SETTLER))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/velvet_kiss
	name = "Velvet Kiss"
	color = "#EB1010" //(235, 16, 16)
	description = "A bloody drink mixed with wine."
	boozepwr = 10 //weak
	taste_description = "iron with grapejuice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING

/datum/glass_style/drinking_glass/velvet_kiss
	required_drink_type = /datum/reagent/consumable/ethanol/velvet_kiss
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "velvet_kiss"
	name = "glass of velvet kiss"
	desc = "Red and white drink for the upper classes or undead."

/datum/reagent/consumable/ethanol/velvet_kiss/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(iszombie(exposed_mob) || isvampire(exposed_mob) || isdullahan(exposed_mob) || ishemophage(exposed_mob)) //Rare races!
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/velvet_kiss/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(drinker.blood_volume < BLOOD_VOLUME_NORMAL)
		drinker.blood_volume = min(drinker.blood_volume + (1 * REM * seconds_per_tick), BLOOD_VOLUME_NORMAL) //Same as Bloody Mary, as it is roughly the same difficulty to make.  Gives hemophages a bit more choices to supplant their blood levels.

/datum/reagent/consumable/ethanol/abduction_fruit
	name = "Abduction Fruit"
	color = "#DEFACD" //(222, 250, 205)
	description = "Mixing of juices to make an alien taste."
	boozepwr = 80 //Strong
	taste_description = "grass and lime"

/datum/glass_style/drinking_glass/abduction_fruit
	required_drink_type = /datum/reagent/consumable/ethanol/abduction_fruit
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "abduction_fruit"
	name = "glass of abduction fruit"
	desc = "Mixed fruits that were never meant to be mixed..."

/datum/reagent/consumable/ethanol/abduction_fruit/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(isabductor(exposed_mob)) // isxenohybrid(exposed_mob)
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/bug_zapper
	name = "Bug Zapper"
	color = "#F5882A" //(222, 250, 205)
	description = "Copper and lemon juice. Hardly even a drink."
	boozepwr = 5 //No booze really
	taste_description = "copper and AC power"

/datum/glass_style/drinking_glass/bug_zapper
	required_drink_type = /datum/reagent/consumable/ethanol/bug_zapper
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "bug_zapper"
	name = "glass of bug zapper"
	desc = "An odd mix of copper, lemon juice and power meant for non-human consumption."

/datum/reagent/consumable/ethanol/bug_zapper/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(isinsectoid(exposed_mob) || isflyperson(exposed_mob) || ismoth(exposed_mob))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/mush_crush
	name = "Mush Crush"
	color = "#F5882A" //(222, 250, 205)
	description = "Soil in a glass."
	boozepwr = 5 //No booze really
	taste_description = "dirt and iron"

/datum/glass_style/drinking_glass/mush_crush
	required_drink_type = /datum/reagent/consumable/ethanol/mush_crush
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "mush_crush"
	name = "glass of mush crush"
	desc = "Popular among people that want to grow their own food rather than drink the soil."

/datum/reagent/consumable/ethanol/mush_crush/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(ispodperson(exposed_mob) || issnail(exposed_mob))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/hollow_bone
	name = "Hollow Bone"
	color = "#FCF7D4" //(252, 247, 212)
	description = "Shockingly none-harmful mix of toxins and milk."
	boozepwr = 15
	taste_description = "Milk and salt"

/datum/glass_style/drinking_glass/hollow_bone
	required_drink_type = /datum/reagent/consumable/ethanol/hollow_bone
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "hollow_bone"
	name = "skull of hollow bone"
	desc = "Mixing of milk and bone hurting juice for enjoyment for rather skinny people."

/datum/reagent/consumable/ethanol/hollow_bone/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(isplasmaman(exposed_mob) || isskeleton(exposed_mob))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/jell_wyrm
	name = "Jell Wyrm"
	color = "#FF6200" //(255, 98, 0)
	description = "Horrible mix of CO2, toxins, and heat. Meant for slime based life."
	boozepwr = 40
	taste_description = "tropical sea"

/datum/glass_style/drinking_glass/jell_wyrm
	required_drink_type = /datum/reagent/consumable/ethanol/jell_wyrm
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "jell_wyrm"
	name = "glass of jell wyrm"
	desc = "A bubbly drink that is rather inviting to those that don't know who it's meant for."

/datum/reagent/consumable/ethanol/jell_wyrm/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(prob(20))
		if(affected_mob.adjustToxLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

#define JELLWYRM_DISGUST 25

/datum/reagent/consumable/ethanol/jell_wyrm/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(isjellyperson(exposed_mob))
		quality = RACE_DRINK
	else //if youre not a slime, jell wyrm should be GROSS
		exposed_mob.adjust_disgust(JELLWYRM_DISGUST)
	return ..()

#undef JELLWYRM_DISGUST

/datum/reagent/consumable/ethanol/laval_spit //Yes Laval
	name = "Laval Spit"
	color = "#DE3009" //(222, 48, 9)
	description = "Heat minerals and some mauna loa. Meant for rock based life."
	boozepwr = 30
	taste_description = "tropical island"

/datum/glass_style/drinking_glass/laval_spit
	required_drink_type = /datum/reagent/consumable/ethanol/laval_spit
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "laval_spit"
	name = "glass of laval spit"
	desc = "Piping hot drink for those who can stomach the heat of lava."

/datum/reagent/consumable/ethanol/laval_spit/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(isgolem(exposed_mob))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/frisky_kitty
	name = "Frisky Kitty"
	color = "#FCF7D4" //(252, 247, 212)
	description = "Warm milk mixed with catnip."
	boozepwr = 0
	taste_description = "Warm milk and catnip"

/datum/glass_style/drinking_glass/frisky_kitty
	required_drink_type = /datum/reagent/consumable/ethanol/frisky_kitty
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "frisky_kitty"
	name = "cup of frisky kitty"
	desc = "Warm milk and some catnip."

/datum/reagent/consumable/ethanol/frisky_kitty/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(isfelinid(exposed_mob))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/blizzard_brew
	name = "Blizzard Brew"
	description = "An ancient recipe. Served best chilled as much as dwarvenly possible."
	color = rgb(180, 231, 216)
	boozepwr = 25
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "ancient icicles"
	overdose_threshold = 25
	var/obj/structure/ice_stasis/cube
	var/atom/movable/screen/alert/status_effect/freon/cryostylane_alert

/datum/glass_style/drinking_glass/blizzard_brew
	required_drink_type = /datum/reagent/consumable/ethanol/blizzard_brew
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "blizzard_brew"
	name = "glass of Blizzard Brew"
	desc = "An ancient recipe. Served best chilled as much as dwarvenly possible."

/datum/reagent/consumable/ethanol/blizzard_brew/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(HAS_TRAIT(exposed_mob, TRAIT_SETTLER))
		quality = RACE_DRINK
	else
		quality = DRINK_NICE
	return ..()

/datum/reagent/consumable/ethanol/blizzard_brew/overdose_start(mob/living/carbon/drinker)
	. = ..()
	cube = new /obj/structure/ice_stasis(get_turf(drinker))
	cube.color = COLOR_CYAN
	cube.set_anchored(TRUE)
	drinker.forceMove(cube)
	cryostylane_alert = drinker.throw_alert("cryostylane_alert", /atom/movable/screen/alert/status_effect/freon)
	cryostylane_alert.attached_effect = src //so the alert can reference us, if it needs to

/datum/reagent/consumable/ethanol/blizzard_brew/on_mob_delete(mob/living/carbon/drinker, amount)
	QDEL_NULL(cube)
	drinker.clear_alert("cryostylane_alert")
	return ..()

/datum/reagent/consumable/ethanol/molten_mead
	name = "Molten Mead"
	description = "Famously known to set beards aflame. Ingest at your own risk!"
	color = rgb(224, 78, 16)
	boozepwr = 35
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "burning wasps"
	overdose_threshold = 25

/datum/glass_style/drinking_glass/molten_mead
	required_drink_type = /datum/reagent/consumable/ethanol/molten_mead
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "molten_mead"
	name = "glass of Molten Mead"
	desc = "Famously known to set beards aflame. Ingest at your own risk!"

/datum/reagent/consumable/ethanol/molten_mead/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(HAS_TRAIT(exposed_mob, TRAIT_SETTLER))
		quality = RACE_DRINK
	else
		quality = DRINK_VERYGOOD
	return ..()

/datum/reagent/consumable/ethanol/molten_mead/overdose_start(mob/living/carbon/drinker)
	drinker.adjust_fire_stacks(2)
	drinker.ignite_mob()
	..()

/datum/reagent/consumable/ethanol/bloodshot_base
	name = "Bloodshot Base"
	description = "The bootleg blend of nutrients and alcohol that goes into making Bloodshots. Doesn't taste too great on its own, for Hemophages at least."
	color = "#c29ca1"
	boozepwr = 25 // Still more concentrated than in Bloodshot.
	taste_description = "nutritious mix with an alcoholic kick to it"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/consumable/ethanol/bloodshot
	name = "Bloodshot"
	description = "The history of the 'Bloodshot' is based in a mix of flavor-neutral chems devised to help deliver nutrients to a Hemophage's tumorous organs. Due to the expense of the real thing and the clinical nature of it, this liquor has been designed as a 'improvised' alternative; though, still tasting like a hangover cure. It smells like iron, giving a clue to the key ingredient."
	color = "#a30000"
	boozepwr = 20 // The only booze in it is Bloody Mary
	taste_description = "blood filled to the brim with nutrients of all kinds"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING


/datum/glass_style/drinking_glass/bloodshot
	required_drink_type = /datum/reagent/consumable/ethanol/bloodshot
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "bloodshot"
	name = "glass of bloodshot"
	desc = "The history of the 'Bloodshot' is based in a mix of flavor-neutral chems devised to help deliver nutrients to a Hemophage's tumorous organs. Due to the expense of the real thing and the clinical nature of it, this liquor has been designed as a 'improvised' alternative; though, still tasting like a hangover cure. It smells like iron, giving a clue to the key ingredient."

#define BLOODSHOT_DISGUST 25

/datum/reagent/consumable/ethanol/bloodshot/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(ishemophage(exposed_mob))
		quality = RACE_DRINK

	else if(exposed_mob.blood_volume < BLOOD_VOLUME_NORMAL)
		quality = DRINK_GOOD

	if(!quality) // Basically, you don't have a reason to want to have this in your system, it doesn't taste good to you!
		exposed_mob.adjust_disgust(BLOODSHOT_DISGUST)

	return ..()

#undef BLOODSHOT_DISGUST

/datum/reagent/consumable/ethanol/bloodshot/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(drinker.blood_volume < BLOOD_VOLUME_NORMAL)
		drinker.blood_volume = max(drinker.blood_volume, min(drinker.blood_volume + (3 * REM * seconds_per_tick), BLOOD_VOLUME_NORMAL)) //Bloodshot quickly restores blood loss.

/datum/reagent/consumable/ethanol/hippie_hooch
	name = "Hippie Hooch"
	description = "Peace and love! Under request of the HR department, this drink is sure to sober you up quickly."
	color = rgb(77, 138, 34)
	boozepwr = -20
	taste_description = "eggy hemp"
	var/static/list/status_effects_to_clear = list(
		/datum/status_effect/confusion,
		/datum/status_effect/dizziness,
		/datum/status_effect/drowsiness,
		/datum/status_effect/speech/slurring/drunk,
	)

/datum/glass_style/drinking_glass/hippie_hooch
	required_drink_type = /datum/reagent/consumable/ethanol/hippie_hooch
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "hippie_hooch"
	name = "glass of Hippie Hooch"
	desc = "Peace and love! Under request of the HR department, this drink is sure to sober you up quickly."

/datum/reagent/consumable/ethanol/hippie_hooch/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(HAS_TRAIT(exposed_mob, TRAIT_SETTLER))
		quality = RACE_DRINK
	else
		quality = DRINK_FANTASTIC
	return ..()

/datum/reagent/consumable/ethanol/hippie_hooch/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	for(var/effect in status_effects_to_clear)
		affected_mob.remove_status_effect(effect)
	affected_mob.reagents.remove_reagent(/datum/reagent/consumable/ethanol, 3 * REM * seconds_per_tick, include_subtypes = TRUE)
	. = ..()
	if(affected_mob.adjustToxLoss(-0.2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	affected_mob.adjust_drunk_effect(-10 * REM * seconds_per_tick)

/datum/reagent/consumable/ethanol/research_rum
	name = "Research Rum"
	description = "Cooked up by dwarven scientists, this glowing pink brew is sure to supercharge your thinking. How? Science!"
	color = rgb(169, 69, 169)
	boozepwr = 50
	taste_description = "slippery grey matter"

/datum/glass_style/drinking_glass/research_rum
	required_drink_type = /datum/reagent/consumable/ethanol/research_rum
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "research_rum"
	name = "glass of Research Rum"
	desc = "Cooked up by dwarven scientists, this glowing pink brew is sure to supercharge your thinking. How? Science!"

/datum/reagent/consumable/ethanol/research_rum/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(HAS_TRAIT(exposed_mob, TRAIT_SETTLER))
		quality = RACE_DRINK
	else
		quality = DRINK_GOOD
	return ..()

/datum/reagent/consumable/ethanol/research_rum/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(prob(5))
		drinker.say(pick_list_replacements(VISTA_FILE, "ballmer_good_msg"), forced = "ballmer")

/datum/reagent/consumable/ethanol/golden_grog
	name = "Golden Grog"
	description = "A drink concocted by a dwarven Quartermaster who had too much time and money on his hands. Commonly ordered by influencers looking to flaunt their wealth."
	color = rgb(247, 230, 141)
	boozepwr = 70
	taste_description = "sweet credit holochips"

/datum/glass_style/drinking_glass/golden_grog
	required_drink_type = /datum/reagent/consumable/ethanol/golden_grog
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "golden_grog"
	name = "glass of Golden Grog"
	desc = "A drink concocted by a dwarven Quartermaster who had too much time and money on his hands. Commonly ordered by influencers looking to flaunt their wealth."

/datum/reagent/consumable/ethanol/golden_grog/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	if(HAS_TRAIT(exposed_mob, TRAIT_SETTLER))
		quality = RACE_DRINK
	else
		quality = DRINK_FANTASTIC
	return ..()

// RACIAL DRINKS END

/datum/reagent/consumable/ethanol/appletini
	name = "Appletini"
	color = "#9bd1a9" //(155, 209, 169)
	description = "The electric-green appley beverage nobody can turn down!"
	boozepwr = 50
	taste_description = "Sweet and green"
	quality = DRINK_GOOD

/datum/glass_style/drinking_glass/appletini
	required_drink_type = /datum/reagent/consumable/ethanol/appletini
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "appletini"
	name = "glass of appletini"
	desc = "An appley beverage in a martini glass"

/datum/reagent/consumable/ethanol/quadruple_sec/cityofsin //making this a subtype was some REAL JANK, but it saves me a headache, and it looks good!
	name = "City of Sin"
	color = "#eb9378" //(235, 147, 120)
	description = "A smooth, fancy drink for people of ill repute"
	boozepwr = 70
	taste_description = "Your own sins"
	quality = DRINK_VERYGOOD //takes extra effort
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/cityofsin
	required_drink_type = /datum/reagent/consumable/ethanol/quadruple_sec/cityofsin
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "cityofsin"
	name = "glass of city of sin"
	desc = "Looking at it makes you recall every mistake you've made."

/datum/reagent/consumable/ethanol/shakiri
	name = "Shakiri"
	description = "A sweet, fragrant red drink made from fermented kiri fruits. It seems to gently sparkle when exposed to light."
	boozepwr = 45
	color = "#cf3c3c"
	quality = DRINK_GOOD
	taste_description = "delicious liquified jelly"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/shakiri
	required_drink_type = /datum/reagent/consumable/ethanol/shakiri
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "shakiri"
	name = "glass of shakiri"
	desc = "A sweet, fragrant red drink made from fermented kiri fruits. It seems to gently sparkle when exposed to light."

/datum/reagent/consumable/ethanol/shakiri_spritz
	name = "Shakiri Spritz"
	description = "A carbonated cocktail made from shakiri and orange juice with soda water."
	color = "#cf863c"
	quality = DRINK_GOOD
	boozepwr = 45
	taste_description = "tangy, carbonated sweetness"

/datum/glass_style/drinking_glass/shakiri_spritz
	required_drink_type = /datum/reagent/consumable/ethanol/shakiri_spritz
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "shakiri_spritz"
	name = "glass of shakiri spritz"
	desc = "A carbonated cocktail made from shakiri and orange juice with soda water."

/datum/reagent/consumable/ethanol/crimson_hurricane
	name = "Crimson Hurricane"
	description = "A strong, citrusy cocktail of human origin, now made with shakiri and kiri jelly for a delightfully sweet drink."
	color = "#b86637"
	quality = DRINK_VERYGOOD
	boozepwr = 60
	taste_description = "thick, fruity sweetness with a punch"

/datum/glass_style/drinking_glass/crimson_hurricane
	required_drink_type = /datum/reagent/consumable/ethanol/crimson_hurricane
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "crimson_hurricane"
	name = "glass of crimson hurricane"
	desc = "A strong, citrusy cocktail of human origin, now with shakiri and kiri jelly for a delightfully sweet drink."

/datum/reagent/consumable/ethanol/shakiri_rogers
	name = "Shakiri Rogers"
	description = "A take on the classic Roy Rogers, with shakiri instead of grenadine. Sweet and refreshing."
	color = "#6F2B1A"
	quality = DRINK_GOOD
	boozepwr = 45
	taste_description = "fruity, carbonated soda with a slight kick"

/datum/glass_style/drinking_glass/shakiri_rogers
	required_drink_type = /datum/reagent/consumable/ethanol/shakiri_rogers
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "shakiri_rogers"
	name = "glass of shakiri rogers"
	desc = "A take on the classic Roy Rogers, with shakiri instead of grenadine. Sweet and refreshing."

/datum/reagent/consumable/ethanol/null_strength_lemon_grapefruit
	name = "NULL STRENGTH Lemon-Grapefruit Fruit Cooler"
	description = "Flash frozen pressed juice mixed with shochu spirits. Very light and drinkable."
	color = "#d6b679"
	quality = DRINK_GOOD
	boozepwr = 30
	taste_description = "light fruit essence and alcohol"
