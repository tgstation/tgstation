#define ALCOHOL_THRESHOLD_MODIFIER 0.05 //Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_RATE 0.005 //The rate at which alcohol affects you

////////////// I don't know who made this header before I refactored alcohols but I'm going to fucking strangle them because it was so ugly, holy Christ
// ALCOHOLS //
//////////////

/datum/reagent/consumable/ethanol
	name = "Ethanol"
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	color = "#404030" // rgb: 64, 64, 48
	nutriment_factor = 0
	taste_description = "alcohol"
	var/boozepwr = 65 //Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning

/*
Boozepwr Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - heavy toxin damage, passing out
91-100: Dangerously toxic - swift death
*/

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
			H.drunkenness = max((H.drunkenness + (sqrt(volume) * boozepwr * ALCOHOL_RATE)), 0) //Volume, power, and server alcohol rate effect how quickly one gets drunk
	return ..() || .

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "<span class='notice'>[paperaffected]'s ink washes away.</span>")
	if(istype(O,/obj/item/weapon/book))
		if(reac_volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			to_chat(usr, "<span class='notice'>Through thorough application, you wash away [affectedbook]'s writing.</span>")
		else
			to_chat(usr, "<span class='warning'>The ink smears, but doesn't wash away!</span>")
	return

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!isliving(M))
		return

	if(method in list(TOUCH, VAPOR, PATCH))
		M.adjust_fire_stacks(reac_volume / 15)

		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/power_multiplier = boozepwr / 65 // Weak alcohol has less sterilizing power

			for(var/s in C.surgeries)
				var/datum/surgery/S = s
				S.success_multiplier = max(0.10*power_multiplier, S.success_multiplier)
				// +10% success propability on each step, useful while operating in less-than-perfect conditions
	return ..()

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. Still popular today."
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "piss water"
	glass_name = "glass of beer"
	glass_desc = "A freezing pint of beer."

/datum/reagent/consumable/ethanol/beer/green
	name = "Green Beer"
	id = "greenbeer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is dyed a festive green."
	color = "#A8E61D"
	taste_description = "green piss water"
	glass_icon_state = "greenbeerglass"
	glass_name = "glass of green beer"
	glass_desc = "A freezing pint of green beer. Festive."

/datum/reagent/consumable/ethanol/beer/green/on_mob_life(mob/living/M)
	if(M.color != color)
		M.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)
	return ..()

/datum/reagent/consumable/ethanol/beer/green/on_mob_delete(mob/living/M)
	M.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45
	glass_icon_state = "kahluaglass"
	glass_name = "glass of RR Coffee Liquor"
	glass_desc = "DAMN, THIS THING LOOKS ROBUST!"
	shot_glass_icon_state = "shotglasscream"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-2, 0)
	M.Jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 75
	taste_description = "molasses"
	glass_icon_state = "whiskeyglass"
	glass_name = "glass of whiskey"
	glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 80
	taste_description = "jitters and death"
	glass_icon_state = "thirteen_loko_glass"
	glass_name = "glass of Thirteen Loko"
	glass_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."


/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/M)
	M.drowsyness = max(0,M.drowsyness-7)
	M.AdjustSleeping(-2)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8" // rgb: 0, 100, 200
	boozepwr = 65
	taste_description = "grain alcohol"
	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of vodka"
	glass_desc = "The glass contain wodka. Xynta."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/M)
	M.radiation = max(M.radiation-2,0)
	return ..()

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 15
	taste_description = "desperation and lactate"
	glass_icon_state = "glass_brown"
	glass_name = "glass of bilk"
	glass_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."

/datum/reagent/consumable/ethanol/bilk/on_mob_life(mob/living/M)
	if(M.getBruteLoss() && prob(10))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	boozepwr = 10
	taste_description = "dryness"
	glass_icon_state = "threemileislandglass"
	glass_name = "Three Mile Island Ice Tea"
	glass_desc = "A glass of this is sure to prevent a meltdown."

/datum/reagent/consumable/ethanol/threemileisland/on_mob_life(mob/living/M)
	M.set_drugginess(50)
	return ..()

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45
	taste_description = "an alcoholic christmas tree"
	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of gin"
	glass_desc = "A crystal clear glass of Griffeater gin."

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Yohoho and all that."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 60
	taste_description = "spiked butterscotch"
	glass_icon_state = "rumglass"
	glass_name = "glass of rum"
	glass_desc = "Now you want to Pray for a pirate suit, don't you?"
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	id = "tequila"
	description = "A strong and mildly flavoured, Mexican produced spirit. Feeling thirsty, hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 70
	taste_description = "paint stripper"
	glass_icon_state = "tequilaglass"
	glass_name = "glass of tequila"
	glass_desc = "Now all that's missing is the weird colored shades!"
	shot_glass_icon_state = "shotglassgold"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	boozepwr = 45
	taste_description = "dry alcohol"
	glass_icon_state = "vermouthglass"
	glass_name = "glass of vermouth"
	glass_desc = "You wonder why you're even drinking this straight."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "A premium alcoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 35
	taste_description = "bitter sweetness"
	glass_icon_state = "wineglass"
	glass_name = "glass of wine"
	glass_desc = "A very classy looking drink."
	shot_glass_icon_state = "shotglassred"

/datum/reagent/consumable/ethanol/lizardwine
	name = "Lizard wine"
	id = "lizardwine"
	description = "An alcoholic beverage from Space China, made by infusing lizard tails in ethanol."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 45
	taste_description = "scaley sweetness"

/datum/reagent/consumable/ethanol/grappa
	name = "Grappa"
	id = "grappa"
	description = "A fine Italian brandy, for when regular wine just isn't alcoholic enough for you."
	color = "#F8EBF1"
	boozepwr = 45
	taste_description = "classy bitter sweetness"
	glass_icon_state = "grappa"
	glass_name = "glass of grappa"
	glass_desc = "A fine drink originally made to prevent waste by using the leftovers from winemaking."

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	boozepwr = 75
	taste_description = "angry and irish"
	glass_icon_state = "cognacglass"
	glass_name = "glass of cognac"
	glass_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "A powerful alcoholic drink. Rumored to cause hallucinations but does not."
	color = rgb(10, 206, 0)
	boozepwr = 80 //Very strong even by default
	taste_description = "death and licorice"
	glass_icon_state = "absinthe"
	glass_name = "glass of absinthe"
	glass_desc = "It's as strong as it smells."
	shot_glass_icon_state = "shotglassgreen"

/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	if(prob(10))
		M.hallucination += 4 //Reference to the urban myth
	..()

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alcohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 100
	taste_description = "pure resignation"
	glass_icon_state = "glass_brown2"
	glass_name = "Hooch"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."


/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alcoholic beverage made with malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 65
	taste_description = "hearty barley ale"
	glass_icon_state = "aleglass"
	glass_name = "glass of ale"
	glass_desc = "A freezing pint of delicious Ale."

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 25
	taste_description = "burning cinnamon"
	glass_icon_state = "goldschlagerglass"
	glass_name = "glass of Goldschlager"
	glass_desc = "100% proof that teen girls will drink anything with gold in it."
	shot_glass_icon_state = "shotglassgold"

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	boozepwr = 60
	taste_description = "metallic and expensive"
	glass_icon_state = "patronglass"
	glass_name = "glass of patron"
	glass_desc = "Drinking patron in the bar, with all the subpar ladies."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25
	taste_description = "mild and tart"
	glass_icon_state = "gintonicglass"
	glass_name = "Gin and Tonic"
	glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolucion."
	color = "#3E1B00" // rgb: 62, 27, 0
	boozepwr = 50
	taste_description = "cola"
	glass_icon_state = "cubalibreglass"
	glass_name = "Cuba Libre"
	glass_desc = "A classic mix of rum and cola."

/datum/reagent/consumable/ethanol/cuba_libre/on_mob_life(mob/living/M)
	if(M.mind && M.mind.special_role in list("Revolutionary", "Head Revolutionary")) //Cuba Libre, the traditional drink of revolutions! Heals revolutionaries.
		M.adjustBruteLoss(-1, 0)
		M.adjustFireLoss(-1, 0)
		M.adjustToxLoss(-1, 0)
		M.adjustOxyLoss(-5, 0)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	boozepwr = 70
	taste_description = "cola"
	glass_icon_state = "whiskeycolaglass"
	glass_name = "Whiskey Cola"
	glass_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 60
	taste_description = "dry class"
	glass_icon_state = "martiniglass"
	glass_name = "Classic Martini"
	glass_desc = "Damn, the bartender even stirred it, not shook it."

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 65
	taste_description = "shaken, not stirred"
	glass_icon_state = "martiniglass"
	glass_name = "Vodka martini"
	glass_desc ="A bastardisation of the classic martini. Still great."

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	boozepwr = 50
	taste_description = "bitter cream"
	glass_icon_state = "whiterussianglass"
	glass_name = "White Russian"
	glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	boozepwr = 55
	taste_description = "oranges"
	glass_icon_state = "screwdriverglass"
	glass_name = "Screwdriver"
	glass_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_life(mob/living/M)
	if(M.mind && M.mind.assigned_role in list("Station Engineer", "Atmospheric Technician", "Chief Engineer")) //Engineers lose radiation poisoning at a massive rate.
		M.radiation = max(M.radiation - 25, 0)
	return ..()

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	boozepwr = 45
	taste_description = "sweet 'n creamy"
	glass_icon_state = "booger"
	glass_name = "Booger"
	glass_desc = "Ewww..."

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 55
	taste_description = "tomatoes with a hint of lime"
	glass_icon_state = "bloodymaryglass"
	glass_name = "Bloody Mary"
	glass_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "It's just as effective as Dutch-Courage!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 80
	taste_description = "alcoholic bravery"
	glass_icon_state = "bravebullglass"
	glass_name = "Brave Bull"
	glass_desc = "Tequila and Coffee liqueur, brought together in a mouthwatering mixture. Drink up."

/datum/reagent/consumable/ethanol/brave_bull/on_mob_life(mob/living/M)
	if(M.maxHealth == initial(M.maxHealth)) //Brave Bull makes you sturdier, and thus capable of withstanding a tiny bit more punishment.
		M.maxHealth += 5
		M.health += 5
	return ..()

/datum/reagent/consumable/ethanol/brave_bull/on_mob_delete(mob/living/M)
	if(M.maxHealth != initial(M.maxHealth))
		M.maxHealth = initial(M.maxHealth)

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	id = "tequilasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	color = "#FFE48C" // rgb: 255, 228, 140
	boozepwr = 45
	taste_description = "oranges"
	glass_icon_state = "tequilasunriseglass"
	glass_name = "tequila Sunrise"
	glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25
	taste_description = "spicy toxins"
	glass_icon_state = "toxinsspecialglass"
	glass_name = "Toxins Special"
	glass_desc = "Whoah, this thing is on FIRE!"
	shot_glass_icon_state = "toxinsspecialglass"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Drink this and prepare for the LAW."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 90 //THE FIST OF THE LAW IS STRONG AND HARD
	metabolization_rate = 0.8
	taste_description = "JUSTICE"
	glass_icon_state = "beepskysmashglass"
	glass_name = "Beepsky Smash"
	glass_desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/M)
	M.Stun(2, 0)
	return ..()

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish?"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 70
	taste_description = "creamy alcohol"
	glass_icon_state = "irishcreamglass"
	glass_name = "Irish Cream"
	glass_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 100 //For the manly only
	taste_description = "hair on your chest and your chin"
	glass_icon_state = "manlydorfglass"
	glass_name = "The Manly Dorf"
	glass_desc = "A manly concoction made from Ale and Beer. Intended for true men only."

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35
	taste_description = "a mixture of cola and alcohol"
	glass_icon_state = "longislandicedteaglass"
	glass_name = "Long Island Iced Tea"
	glass_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."


/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 95
	taste_description = "bitterness"
	glass_icon_state = "glass_clear"
	glass_name = "Moonshine"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 85
	taste_description = "angry and irish"
	glass_icon_state = "b52glass"
	glass_name = "B-52"
	glass_desc = "Kahlua, Irish Cream, and cognac. You will get bombed."
	shot_glass_icon_state = "b52glass"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35
	taste_description = "giving up on the day"
	glass_icon_state = "irishcoffeeglass"
	glass_name = "Irish Coffee"
	glass_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	boozepwr = 35
	taste_description = "dry and salty"
	glass_icon_state = "margaritaglass"
	glass_name = "Margarita"
	glass_desc = "On the rocks with salt on the rim. Arriba~!"

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	boozepwr = 70
	taste_description = "bitterness"
	glass_icon_state = "blackrussianglass"
	glass_name = "Black Russian"
	glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."


/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 30
	taste_description = "mild dryness"
	glass_icon_state = "manhattanglass"
	glass_name = "Manhattan"
	glass_desc = "The Detective's undercover drink of choice. He never could stomach gin..."


/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45
	taste_description = "death, the destroyer of worlds"
	glass_icon_state = "proj_manhattanglass"
	glass_name = "Manhattan Project"
	glass_desc = "A scientist's drink of choice, for thinking how to blow up the station."


/datum/reagent/consumable/ethanol/manhattan_proj/on_mob_life(mob/living/M)
	M.set_drugginess(30)
	return ..()

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "For the more refined griffon."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 70
	taste_description = "soda"
	glass_icon_state = "whiskeysodaglass2"
	glass_name = "Whiskey Soda"
	glass_desc = "Ultimate refreshment."

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "The ultimate refreshment. Not what it sounds like."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35
	taste_description = "Jack Frost's piss"
	glass_icon_state = "antifreeze"
	glass_name = "Anti-freeze"
	glass_desc = "The ultimate refreshment."

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/M)
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45
	taste_description = "creamy berries"
	glass_icon_state = "b&p"
	glass_name = "Barefoot"
	glass_desc = "Barefoot and pregnant."

/datum/reagent/consumable/ethanol/barefoot/on_mob_life(mob/living/M)
	if(ishuman(M)) //Barefoot causes the imbiber to quickly regenerate brute trauma if they're not wearing shoes.
		var/mob/living/carbon/human/H = M
		if(!H.shoes)
			H.adjustBruteLoss(-3, 0)
			. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment."
	color = "#FFFFFF" // rgb: 255, 255, 255
	boozepwr = 35
	taste_description = "refreshing cold"
	glass_icon_state = "snowwhite"
	glass_name = "Snow White"
	glass_desc = "A cold refreshment."

/datum/reagent/consumable/ethanol/demonsblood //Prevents the imbiber from being dragged into a pool of blood by a slaughter demon.
	name = "Demon's Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	boozepwr = 75
	taste_description = "sweet tasting iron"
	glass_icon_state = "demonsblood"
	glass_name = "Demons Blood"
	glass_desc = "Just looking at this thing makes the hair at the back of your neck stand up."

/datum/reagent/consumable/ethanol/devilskiss //If eaten by a slaughter demon, the demon will regret it.
	name = "Devil's Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	boozepwr = 70
	taste_description = "bitter iron"
	glass_icon_state = "devilskiss"
	glass_name = "Devils Kiss"
	glass_desc = "Creepy time!"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't Russian enough."
	color = "#0064C8" // rgb: 0, 100, 200
	boozepwr = 70
	taste_description = "tart bitterness"
	glass_icon_state = "vodkatonicglass"
	glass_name = "Vodka and Tonic"
	glass_desc = "For when a gin and tonic isn't Russian enough."


/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45
	taste_description = "dry, tart lemons"
	glass_icon_state = "ginfizzglass"
	glass_name = "Gin Fizz"
	glass_desc = "Refreshingly lemony, deliciously dry."


/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama Mama"
	id = "bahama_mama"
	description = "Tropical cocktail."
	color = "#FF7F3B" // rgb: 255, 127, 59
	boozepwr = 35
	taste_description = "lime and orange"
	glass_icon_state = "bahama_mama"
	glass_name = "Bahama Mama"
	glass_desc = "Tropical cocktail."

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 35
	taste_description = "concentrated matter"
	glass_icon_state = "singulo"
	glass_name = "Singulo"
	glass_desc = "A blue-space beverage."

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 70
	taste_description = "hot and spice"
	glass_icon_state = "sbitenglass"
	glass_name = "Sbiten"
	glass_desc = "A spicy mix of Vodka and Spice. Very hot."

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/M)
	if (M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking drink! Even though it has a strange red color."
	color = "#C73C00" // rgb: 199, 60, 0
	boozepwr = 51 //Red drinks are stronger
	taste_description = "sweet and salty alcohol"
	glass_icon_state = "red_meadglass"
	glass_name = "Red Mead"
	glass_desc = "A True Viking's Beverage, though its color is strange."

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Viking drink, though a cheap one."
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 50
	taste_description = "sweet, sweet alcohol"
	glass_icon_state = "meadglass"
	glass_name = "Mead"
	glass_desc = "A Viking's Beverage, though a cheap one."

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 15
	taste_description = "refreshingly cold"
	glass_icon_state = "iced_beerglass"
	glass_name = "Iced Beer"
	glass_desc = "A beer so frosty, the air around it freezes."

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/M)
	if(M.bodytemperature > 270)
		M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, Nanotrasen approves!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1 //Basically nothing
	taste_description = "a poor excuse for alcohol"
	glass_icon_state = "grogglass"
	glass_name = "Grog"
	glass_desc = "A fine and cepa drink for Space."


/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35
	taste_description = "sweet 'n creamy"
	glass_icon_state = "aloe"
	glass_name = "Aloe"
	glass_desc = "Very, very, very good."

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strangely named drink."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 40
	taste_description = "lemons"
	glass_icon_state = "andalusia"
	glass_name = "Andalusia"
	glass_desc = "A nice, strangely named drink."

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies. Not as sweet as those made from your enemies."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45
	taste_description = "bitter yet free"
	glass_icon_state = "alliescocktail"
	glass_name = "Allies cocktail"
	glass_desc = "A drink made from your allies."

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	color = "#365000" // rgb: 54, 80, 0
	boozepwr = 80
	taste_description = "stomach acid"
	glass_icon_state = "acidspitglass"
	glass_name = "Acid Spit"
	glass_desc = "A drink from Nanotrasen. Made from live aliens."

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the Nanotrasen Gun-Club!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35
	taste_description = "dark and metallic"
	glass_icon_state = "amasecglass"
	glass_name = "Amasec"
	glass_desc = "Always handy before COMBAT!!!"

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 95
	taste_description = "your brain coming out your nose"
	glass_icon_state = "changelingsting"
	glass_name = "Changeling Sting"
	glass_desc = "A stingy drink."

/datum/reagent/consumable/ethanol/changelingsting/on_mob_life(mob/living/M)
	if(M.mind && M.mind.changeling) //Changeling Sting assists in the recharging of changeling chemicals.
		M.mind.changeling.chem_charges += metabolization_rate
		M.mind.changeling.chem_charges = Clamp(M.mind.changeling.chem_charges, 0, M.mind.changeling.chem_storage)
	return ..()

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 25
	taste_description = "delicious anger"
	glass_icon_state = "irishcarbomb"
	glass_name = "Irish Car Bomb"
	glass_desc = "An Irish car bomb."

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "Tastes like terrorism!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 90
	taste_description = "purified antagonism"
	glass_icon_state = "syndicatebomb"
	glass_name = "Syndicate Bomb"
	glass_desc = "A syndicate bomb."

/datum/reagent/consumable/ethanol/syndicatebomb/on_mob_life(mob/living/M)
	if(prob(5))
		playsound(get_turf(M), 'sound/effects/explosionfar.ogg', 100, 1)
	return ..()

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is, it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 35
	taste_description = "tartness and bananas"
	glass_icon_state = "erikasurprise"
	glass_name = "Erika Surprise"
	glass_desc = "The surprise is, it's green!"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 65
	taste_description = "a beach"
	glass_icon_state = "driestmartiniglass"
	glass_name = "Driest Martini"
	glass_desc = "Only for the experienced. You think you see sand floating in the glass."

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFF91" // rgb: 255, 255, 140
	boozepwr = 60
	taste_description = "a bad joke"
	glass_icon_state = "bananahonkglass"
	glass_name = "Banana Honk"
	glass_desc = "A drink from Clown Heaven."

/datum/reagent/consumable/ethanol/bananahonk/on_mob_life(mob/living/M)
	if((ishuman(M) && M.job in list("Clown") ) || ismonkey(M))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 59 //Proof that clowns are better than mimes right here
	taste_description = "a pencil eraser"
	glass_icon_state = "silencerglass"
	glass_name = "Silencer"
	glass_desc = "A drink from Mime Heaven."

/datum/reagent/consumable/ethanol/silencer/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Mime"))
		M.heal_bodypart_damage(1,1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	id = "drunkenblumpkin"
	description = "A weird mix of whiskey and blumpkin juice."
	color = "#1EA0FF" // rgb: 102, 67, 0
	boozepwr = 50
	taste_description = "molasses and a mouthful of pool water"
	glass_icon_state = "drunkenblumpkin"
	glass_name = "Drunken Blumpkin"
	glass_desc = "A drink for the drunks."

/datum/reagent/consumable/ethanol/whiskey_sour //Requested since we had whiskey cola and soda but not sour.
	name = "Whiskey Sour"
	id = "whiskey_sour"
	description = "Lemon juice/whiskey/sugar mixture. Moderate alcohol content."
	color = rgb(255, 201, 49)
	boozepwr = 35
	taste_description = "sour lemons"
	glass_icon_state = "whiskey_sour"
	glass_name = "Whiskey Sour"
	glass_desc = "Lemon juice mixed with whiskey and a dash of sugar. Surprisingly satisfying."

/datum/reagent/consumable/ethanol/hcider
	name = "Hard Cider"
	id = "hcider"
	description = "Apple juice, for adults."
	color = "#CD6839"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "apples"
	glass_icon_state = "whiskeyglass"
	glass_name = "Hard Cider"
	glass_desc = "Tastes like autumn."
	shot_glass_icon_state = "shotglassbrown"


/datum/reagent/consumable/ethanol/fetching_fizz //A reference to one of my favorite games of all time. Pulls nearby ores to the imbiber!
	name = "Fetching Fizz"
	id = "fetching_fizz"
	description = "Whiskey sour/iron/uranium mixture resulting in a highly magnetic slurry. Mild alcohol content." //Requires no alcohol to make but has alcohol anyway because ~magic~
	color = rgb(255, 91, 15)
	boozepwr = 10
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	taste_description = "charged metal" // the same as teslium, honk honk.
	glass_icon_state = "fetching_fizz"
	glass_name = "Fetching Fizz"
	glass_desc = "Induces magnetism in the imbiber. Started as a barroom prank but evolved to become popular with miners and scrappers. Metallic aftertaste."


/datum/reagent/consumable/ethanol/fetching_fizz/on_mob_life(mob/living/M)
	for(var/obj/item/weapon/ore/O in orange(3, M))
		step_towards(O, get_turf(M))
	return ..()

//Another reference. Heals those in critical condition extremely quickly.
/datum/reagent/consumable/ethanol/hearty_punch
	name = "Hearty Punch"
	id = "hearty_punch"
	description = "Brave bull/syndicate bomb/absinthe mixture resulting in an energizing beverage. Mild alcohol content."
	color = rgb(140, 0, 0)
	boozepwr = 10
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	taste_description = "bravado in the face of disaster"
	glass_icon_state = "hearty_punch"
	glass_name = "Hearty Punch"
	glass_desc = "Aromatic beverage served piping hot. According to folk tales it can almost wake the dead."

/datum/reagent/consumable/ethanol/hearty_punch/on_mob_life(mob/living/M)
	if(M.stat == UNCONSCIOUS && M.health <= 0)
		M.adjustBruteLoss(-7, 0)
		M.adjustFireLoss(-7, 0)
		M.adjustToxLoss(-7, 0)
		M.adjustOxyLoss(-7, 0)
		M.adjustCloneLoss(-7, 0)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	id = "bacchus_blessing"
	description = "Unidentifiable mixture. Unmeasurably high alcohol content."
	color = rgb(51, 19, 3) //Sickly brown
	boozepwr = 300 //I warned you
	taste_description = "a wall of bricks"
	glass_icon_state = "glass_brown2"
	glass_name = "Bacchus' Blessing"
	glass_desc = "You didn't think it was possible for a liquid to be so utterly revolting. Are you sure about this...?"



/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	boozepwr = 0 //custom drunk effect
	taste_description = "da bomb"
	glass_icon_state = "atomicbombglass"
	glass_name = "Atomic Bomb"
	glass_desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."

/datum/reagent/consumable/ethanol/atomicbomb/on_mob_life(mob/living/M)
	M.set_drugginess(50)
	M.confused = max(M.confused+2,0)
	M.Dizzy(10)
	if (!M.slurring)
		M.slurring = 1
	M.slurring += 3
	switch(current_cycle)
		if(51 to 200)
			M.Sleeping(5, 0)
			. = 1
		if(201 to INFINITY)
			M.AdjustSleeping(2, 0)
			M.adjustToxLoss(2, 0)
			. = 1
	..()

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 0 //custom drunk effect
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"
	glass_icon_state = "gargleblasterglass"
	glass_name = "Pan-Galactic Gargle Blaster"
	glass_desc = "Like having your brain smashed out by a slice of lemon wrapped around a large gold brick."

/datum/reagent/consumable/ethanol/gargle_blaster/on_mob_life(mob/living/M)
	M.dizziness +=6
	switch(current_cycle)
		if(15 to 45)
			if(!M.slurring)
				M.slurring = 1
			M.slurring += 3
		if(45 to 55)
			if(prob(50))
				M.confused = max(M.confused+3,0)
		if(55 to 200)
			M.set_drugginess(55)
		if(200 to INFINITY)
			M.adjustToxLoss(2, 0)
			. = 1
	..()

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	boozepwr = 0 //custom drunk effect
	taste_description = "a numbing sensation"
	glass_icon_state = "neurotoxinglass"
	glass_name = "Neurotoxin"
	glass_desc = "A drink that is guaranteed to knock you silly."

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/carbon/M)
	M.Weaken(3, 1, 0)
	M.dizziness +=6
	switch(current_cycle)
		if(15 to 45)
			if(!M.slurring)
				M.slurring = 1
			M.slurring += 3
		if(45 to 55)
			if(prob(50))
				M.confused = max(M.confused+3,0)
		if(55 to 200)
			M.set_drugginess(55)
		if(200 to INFINITY)
			M.adjustToxLoss(2, 0)
	..()
	. = 1

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 0
	boozepwr = 0 //custom drunk effect
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "giving peace a chance"
	glass_icon_state = "hippiesdelightglass"
	glass_name = "Hippie's Delight"
	glass_desc = "A drink enjoyed by people during the 1960's."

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/M)
	if (!M.slurring)
		M.slurring = 1
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(10)
			M.set_drugginess(30)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(20)
			M.Dizzy(20)
			M.set_drugginess(45)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if (10 to 200)
			M.Jitter(40)
			M.Dizzy(40)
			M.set_drugginess(60)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
		if(200 to INFINITY)
			M.Jitter(60)
			M.Dizzy(60)
			M.set_drugginess(75)
			if(prob(40))
				M.emote(pick("twitch","giggle"))
			if(prob(30))
				M.adjustToxLoss(2, 0)
				. = 1
	..()

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	id = "eggnog"
	description = "For enjoying the most wonderful time of the year."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 1
	taste_description = "custard and alcohol"
	glass_icon_state = "glass_yellow"
	glass_name = "Eggnog"
	glass_desc = "For enjoying the most wonderful time of the year."
