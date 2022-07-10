///Gang themes for the Families gamemode. Used to determine the RP theme of the round, what gangs are present, and what their objectives are.
/datum/gang_theme
	///The name of the theme.
	var/name = "Gang Theme"
	///All gangs in the theme, typepaths of gangs.
	var/list/involved_gangs = list()
	///The radio announcement played after 5 minutes.
	var/description = "I dunno, some shit here."
	///The objectives for the gangs. Associative list, type = "objective"
	var/list/gang_objectives = list()
	///Stuff given to every gangster in this theme.
	var/list/bonus_items = list()
	///Stuff given to the starting gangster at roundstart. Assoc list, type = list(item_type)
	var/list/bonus_first_gangster_items = list()
	///If this isn't null, everyone gets this objective.
	var/list/everyone_objective = null
	///How many gangsters should each gang start with? Recommend to keep this in the ballpark of ensuring 9-10 total gangsters spawn.
	var/starting_gangsters = 3
	///What sound should we play for announcements?
	var/announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/fallback.ogg'

/datum/gang_theme/proc/post_start(datum/gang_handler/handler)
	return // If we want to do shit with a theme after starting it.

/datum/gang_theme/goodfellas
	name = "Goodfellas"
	description = "You're listening to the 108.9 Swing station! All jazz, all night long, and absolutely no advertising. We'd like to take this time to remind you to avoid smoky backrooms and \
	suspicious individuals in suits and hats. Don't make a deal you can't pay back."
	involved_gangs = list(/datum/antagonist/gang/russian_mafia, /datum/antagonist/gang/italian_mob)
	starting_gangsters = 5
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/goodfellas.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/russian_mafia = "Hello, comrade. Our numbers are going down. We need you to bring those numbers up. \
		Collect protection money from the station's departments by any means necessary. \
		If you need to 'encourage' people to pay up, do so. Get to these potential clients before the Mob does.",

		/datum/antagonist/gang/italian_mob = "Good afternoon, friend. The Boss sends his regards. He also sends a message. \
		We need to collect what we're owed. The departments on this station all owe quite a lot of money to us. We intend to collect on our debts. \
		Collect the debt owed by our clients from the departments on the station. \
		Make sure to get to them before those damn mafiosos do.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		We're expecting an uptick in organized crime on board the station. Keep an eye out for protection rackets and extortion. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."

	)

/datum/gang_theme/the_big_game
	name = "The Big Game"
	description = "You're listening to SPORTS DAILY with John Dadden, and we're here LIVE covering the FINAL DAY of THE BIG GAME MMDXXXVIII! The teams playing tonight to decide \
	who takes home THE BIG GAME MMDXXXVIII cup are the Sybil Slickers and the Basil Boys! It's currently a toss up between the two teams, Which will take home the victory? That's up \
	to the teams and the coaches! Play ball!"
	involved_gangs = list(/datum/antagonist/gang/sybil_slickers, /datum/antagonist/gang/basil_boys, /datum/antagonist/gang/big_game_referees)
	starting_gangsters = 3
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/the_big_game.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/sybil_slickers = "Alright, it's the BIG DAY of THE BIG GAME MMDXXXVIII! Get your players ready to go, and \
		ensure everyone's healthy, hydrated, and ready to PLAY BALL! Talk with the referees, recruit your team, and then play and win the \
		FINAL MATCH of THE BIG GAME MMDXXXVIII!",

		/datum/antagonist/gang/basil_boys = "Alright, it's the BIG DAY of THE BIG GAME MMDXXXVIII! Get your players ready to go, and \
		ensure everyone's healthy, hydrated, and ready to PLAY BALL! Talk with the referees, recruit your team, and then play and win the \
		FINAL MATCH of THE BIG GAME MMDXXXVIII!",

		/datum/antagonist/gang/big_game_referees = "Alright, it's the BIG DAY of THE BIG GAME MMDXXXVIII! As a referee, it's your job to organize THE BIG GAME MMDXXXVIII, \
		decide on the venue, and coordinate the match, decide on the rules, and run THE BIG GAME MMDXXXVIII!!! The first referee has the ALMIGHTY FOOTBALL, which is the \
		ball that will be used for THE BIG GAME MMDXXXVIII. If you need more referees, have the head referees hire more.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		The station's hosting the Spinward Stellar Coalition's annual THE BIG GAME sports competition. They've sent the coaches of the two teams and some referees.\
		We recommend keeping an eye on the event to make sure the crowd and players don't get overly rowdy. People tend to get wild about sports. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."
	)
	bonus_first_gangster_items = list(
		/datum/antagonist/gang/sybil_slickers = null,
		/datum/antagonist/gang/basil_boys = null,
		/datum/antagonist/gang/big_game_referees = /obj/item/football,
		/datum/antagonist/gang/security = null,
	)

/datum/gang_theme/tale_of_two_CEOs
	name = "Tale of Two CEOs"
	description = "Thanks for tuning into the Truth Podcast, hosted by myself, Giorgio, and, uh, myself, also Giorgio. Today, we're looking into the famous Majestic Thirteen, \
	the secret shadowy arm of the cultist cabal running the Spinward Stellar Coalition. Now, we all know the SSC denies their existence in all capacities, but we all know \
	that's a load of, dare I say it, bull crap. The truth is out there, folks, and on this podcast, we'll hear the truth, the whole truth, and nothing but the truth! Right after \
	these ads for some tactical emergency perineal wipes!"
	involved_gangs = list(/datum/antagonist/gang/henchmen, /datum/antagonist/gang/majestic_thirteen)
	starting_gangsters = 5
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/tale_of_two_CEOs.ogg'
	gang_objectives = list(
		/datum/antagonist/gang/henchmen = "Henchmen! It is I, the Swallowtail Tiger, your supreme leader! Your mission today is simple. \
		Kidnap the Heads of Staff, and FORCE them to OFFICIALLY DECLARE MYSELF, the Swallowtail Tiger, the NEW CEO OF NANOTRASEN, and to DENOUNCE THE SPINWARD STELLAR COALITION! \
		By forcing them to accept me as the new CEO of Nanotrasen, I'll officially own all of Nanotrasen's wealth and stick it to that BASTARD, JOHN NANOTRASEN! \
		Go forth, henchmen, and capture the Heads of Staff and make me the CEO of Nanotrasen!",

		/datum/antagonist/gang/majestic_thirteen = "Welcome to hell, agent. Otherwise known as a Nanotrasen space station. We weeded out all the crappy agents \
		and we ended up left with the best of the best. Unfortunately for us, the best of the best includes you, and your task today is babysitter duty. But from afar. \
		We need you to spy on the Heads of Staff, and make damn sure they're not engaging in any anti-Spinward Stellar Coalition activity. If you catch 'em in the act, \
		remind them that they are to be loyal to the government by any means necessary. Don't be afraid to put the moves on them and really get physical. Good luck, agent.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		Internal Affairs said we received two anonymous VHS tapes in the mail today. Who even uses VHS anymore? It's all about Betamax nowadays. \
		The first was an angry recording from that psycho who calls himself the Swallowtail Tiger saying that he's going to get John Nanotrasen back. \
		The second was just an eye, with a robot voice saying that they will be watching us. Really creeped me out, to say the least. Anyways, keep an eye out. Heh. Eye. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract.",
	)

/datum/gang_theme/the_nanotrasen_vault_job
	name = "The Nanotrasen Vault Job"
	description = "Hey there, this is the Economy Zone on BOX News 66.6. The stock market is soaring after the Third Union Bank thwarted a robbery attempt by \
	three separate gangs of criminals attempting to rob their main branch in New Moscow City at the heart of the SSC. Eyewitness reports describe cross-fire \
	between gangs at the scene of the crime. The violent Carp Rustlers, the con artist Dodge Station Gang, and the philanthropist slash activists the Honest Hearts. \
	The confusion was enough for the Third Union Bank security staff to take down the criminals."
	involved_gangs = list(/datum/antagonist/gang/dodge_station_gang, /datum/antagonist/gang/carp_rustlers, /datum/antagonist/gang/honest_hearts)
	starting_gangsters = 3
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/nanotrasen_vault_job.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/dodge_station_gang = "Listen here fellas, I got a plan. I know you're all bummed about how the Third Union Bank went down due to \
		those other clowns, but hear me out here. This one's a gimmie. This station? Absolutely loaded with gold, valuable jewels, and money. Metric tons of it. \
		They mine it up just to put it in junk electronics and doohickeys. \
		I say we should borrow some of it. And by some of it, I mean all of it. I promise, we're the only ones hitting this vault this time. I made sure. \
		Those weirdo gentlemen thief philanthropists the Honest Hearts and those goddamn Carp Rustlers are still laying low after the Third Union Bank. \
		We're gonna social engineer our way into that vault, nice and friendly like. Then, when they've turned their backs on us, we grab it all and make a run for it! \
		Just one last job, boys. After this, it'll be mangoes in Space Tahiti. \
		You just gotta have a little faith.",

		/datum/antagonist/gang/carp_rustlers = "Alright, listen up. I know everyone's upset about the Third Union Bank failure. At least we made it out alive. \
		In the mean time, we've got a new job. Much lower security. Barely any alarms. We can blow the door off the vault on this station, grab it all, and shoot right through \
		the weekend warrior mall cops they got guarding this place. We're the only ones robbing this vault, we triple-checked. No Dodge Station Gang or Honest Hearts this time. \
		Get some explosives, get some firearms, blast the door and grab all the loot you can. Stealth is not the goal. \
		After that, hunker down with the loot, wait for the heat to die down, and go and hit 'em again once there's more valuables in there. They never expect the second hit.",

		/datum/antagonist/gang/honest_hearts = "We spent months planning that hit on the Third Union Bank, and those damn greedy thieves blew the entire plan up. \
		Today, we get our revenge. We've got actionable intel that the Dodge Station Gang and the Carp Rustlers are, unbeknownst to eachother, hitting this vault. \
		We're going to beat them to it. Sneak in, grab the valuables, and leave a calling card to remind those two clown-shows to stay out of our goddamn jobs in the future.\
		After you've robbed the vault, distribute the wealth to the poorest on the station. We're not here for personal gain, we're here to help the poor and strike back at \
		the rich and powerful, and nobody's more rich and powerful than Nanotrasen.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		I'm sure you all heard the news about the botched bank robbery out in New Moscow City at the Third Union Bank. Nothing got stolen due to three separate crews \
		hitting the place at the same time and getting in eachother's way, fortunately, but Internal Affairs is still spooked as hell about potential copycats. \
		Keep an eye on the vault occasionally, enough to make sure Internal Affairs stays off our back. It'll probably be a slow shift, but it never hurts to be careful. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."
	)

/datum/gang_theme/construction_company_audit
	name = "Construction Company Audit"
	description = "Hey there, this is the Economy Zone on BOX News 66.6. Officials from the Spinward Stellar Coalition government are publicly denouncing the infrastructure \
	contractor Majima Construction after they were assigned the government contract for the hyperlane between Zvezda Revolyutsii Oblast and the outlying \
	colonies near the newly opened Virgo Orbital Radiometry and Economic station by Nanotrasen. The contractors claim that the project ended up becoming more complex than originally \
	planned, but the government claims that the contractors quote, took the money and ran, end quote. Majima Construction was unavailable for comment."
	involved_gangs = list(/datum/antagonist/gang/yakuza, /datum/antagonist/gang/irs)
	bonus_first_gangster_items = list(
		/datum/antagonist/gang/yakuza = /obj/item/storage/secure/briefcase/syndie,
		/datum/antagonist/gang/irs = null,
		/datum/antagonist/gang/security = /obj/item/storage/secure/briefcase/syndie,
		) // the cash for the gangs
	starting_gangsters = 5
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/construction_company_audit.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/yakuza = "Welcome to the station, new recruit. We here at Majima Construction are a legitimate enterprise, yadda yadda yadda. \
		Look, I'll cut to the chase. We're using this station as a money laundering operation. Here's what you and the rest of the schmucks need to do. \
		Build something big, massive, and completely in the way of traffic on the station. Doesn't have to be anything in specific, just as long as it is expensive as fuck. \
		And keep an eye out for anyone poking around our operations. We suspect some auditors might be on the station as well.",

		/datum/antagonist/gang/irs = "Congratulations, agent! You've been assigned to the SSC Internal Revenue Service case against Nanotrasen and Majima Construction. \
		We are proud of your success as an agent so far, and are excited to see what you can bring to the table today. \
		We suspect that Nanotrasen and Majima Construction are engaging in some form of money laundering operation aboard this station. \
		Investigate and stop any and all money laundering operations aboard the station, under the authority of the Spinward Stellar Coalition. \
		Keep the Nanotrasen audit on the down-low if you can, but investigate it just as vigilantly as the Majima Construction operation. \
		If they do not comply, do what you must to get the job done.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		Internal Affairs would like to remind everyone that Nanotrasen is, as we all know, a legitimate above board company that pays it's fair share of taxes \
		to the Spinward Stellar Coalition. Now that the boilerplate's out of the way, we've handed your leader today the weekly embezzlement cash from the contracting gig.\
		Keep that shit on the down-low, but find a way to spend that cash on the station without getting caught. If the IRS audits us and finds that cash or where it went, \
		we're up shit creek. They'll find out that we never actually built the V.O.R.E. station and that'll be a massive media circus. So, disappear that cash. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."
	)

/datum/gang_theme/who_watches_the_watchmen
	name = "Who Watches The Watchmen"
	description = "Hey there, this is the Economy Zone on BOX News 66.6. The stock market is uncertain as reports about Nanotrasen's private security force operating on their \
	stations come out, The reports reveal a massive brutality problem and complete lack of accountability due to the Redshirt's Union and Nanotrasen Internal Affairs covering up \
	abuse as it occurs. Reports include brutality, excessive violence, absurd brig times, and general quote overenthusiasm endquote towards policing the station's employees. \
	Activist group Prisoner Liberation Front leaked the reports to the press, citing the lack of responsiveness from the Spinward Stellar Coalition on the problem."
	involved_gangs = list(/datum/antagonist/gang/riders_of_the_radstorm, /datum/antagonist/gang/prisoner_liberation_front, /datum/antagonist/gang/maintenace_snakes)
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/who_watches_the_watchmen.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/riders_of_the_radstorm = "Welcome to the club, prospect. We're operating on this station as of today, \
		and are looking to expand our lucrative methamphetamine business to this sector of space. However, the boys in red are going to be a problem for us. \
		Get the Security department out of the picture, and take over as the station's new security force. \
		Bust some heads, crack some skulls, do what you need to do, but ensure the station knows that they abide by the rules the Riders of the Radstorms enforce, not the \
		security team or their Nanotrasen bosses. Then get our meth labs operational and exporting. And keep any other gangs from muscling in on our turf.",

		/datum/antagonist/gang/prisoner_liberation_front = "Welcome to the Prisoner Liberation Front! Here at the PLA, our goal is to raise awareness about the way Nanotrasen brutalizes those \
		it deems violating the space law it claims to enforce. Did you know Space Law isn't even legally binding in SSC space? And yet their redshirt enforcers will maim \
		and kill those who they find violating it! We can't stand for this, and we will put an end to it. \
		Do what you can to document authority figure brutality on the station, and if people end up incarcerated or restrained by the law, break them out!",

		/datum/antagonist/gang/maintenace_snakes = "MAINTENANCE SNAKES RULE!!! \
		We're the Maintenance Snakes, and WE RULE!!! \
		We're looking to set up on this station and establish ourselves as the just, but fair law in town. Those redshirt boys just aren't able to run the station like we are. \
		Get the security team out of the way, and then take over as the new authority on the station! Make sure the crew knows that the Maintenance Snakes RULE and that \
		the Maintenance Snakes will keep them safe.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		As you can probably imagine, Internal Affairs is not happy about those documents getting leaked to the press about what we may or may not have \
		done to those crewmembers on the last station you all served on. Sure, maybe we broke a few too many skulls and jammed a guy's leg down his own throat, \
		but maybe they shouldn't of loitered outside Security for a few too many minutes. The press is never telling our side of the story, it's always jumping to \
		conclusions. Just because there was bodycam footage of us stun batonning a handcuffed elderly chemist until his heart stopped while laughing about it, \
		doesn't mean we did it for no reason! That chemist was just caught giving an assistant some drugs, probably with a fake prescription. The assistant admitted it was \
		a fake prescription after only 48 hours of waterboarding anyways, so it was an open and shut case, really. \
		Anyways, Internal Affairs wants you guys to make damn sure you guys don't get caught doing anything that would upset the press for at least a week or two. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."

	)

/datum/gang_theme/space_rosa
	name = "Space Rosa"
	description = "Hey there, this is the Economy Zone on BOX News 66.6. The stock market is still reeling from accusations that three well known corporate entities \
	may supposedly be tied up in industrial espionage actions against eachother. We've reached out to Angels Flow, the Soleil Corporation, and Majima Construction for \
	their comments on these scandals, but none have replied. News broke after a high profile break-in at a Nanotrasen research facility resulted in the arrests of agents linked to these \
	three companies. All three companies denied any involvement, but the arrested individuals were found in an all out brawl. Curiously, Nanotrasen reported nothing of value had \
	actually been stolen."
	involved_gangs = list(/datum/antagonist/gang/saints, /datum/antagonist/gang/morningstar, /datum/antagonist/gang/yakuza)
	bonus_items = list(/obj/item/pinpointer/nuke)
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/space_rosa.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/saints = "Thank you for volunteering within the organization for the Angels Flow Recovery Project! \
		This station is currently illegally in possession of a data disk containing the secret recipe for Angels Flow. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		Get that fucking disk. You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/morningstar = "Greetings, agent. Welcome to the Garment Recovery Task Force. \
		This station is currently illegally in possession of a data disk containing as of yet unreleased clothing patterns. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		Get that fucking disk. You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/yakuza = "Congratulations on your promotion! Welcome to the Evidence Recovery Squad. \
		This station is currently illegally in possession of a data disk containing compromising evidence of the Boss. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		Get that fucking disk. You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		You guys watch the news last night? If not, let me get you up to speed. Internal Affairs is hella spooked about potential corporate espionage \
		cuz a bunch of suits from Angels Flow, Soleil Corporation, and Majima Construction all got caught at a NT facility just brawling. I mean, really throwing down. \
		Funniest shit I've seen all week, man, really. You ever see a bunch of executives fighting? Shit's hilarious. Anyways, Internal Affairs says to keep an eye out \
		for any rival corporation agents on our station. I'm sure it's nothing, but you know how Internal Affairs gets. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."
	)

/datum/gang_theme/february_revolution
	name = "Feburary Revolution"
	description = "Thanks for tuning in to 98.7, the Spinward Stellar Coalition History Channel, funded with the help of listeners like you. \
	Tonight, we're celebrating the February Revolution, as today marks the anniversary of the day our society was freed from the shackles of oppression! \
	We'll be discussing the events of that fateful night. You'll hear of the brave revolutionaries of the Spinward Entente! You'll hear of their victory over both \
	the oppressive Soviet Presidium and the dangerous military junta of Zhukov's Battalion tonight on our special segment on the Feburary Revolution. \
	We'll be right back after these ads."
	involved_gangs = list(/datum/antagonist/gang/spinward_entente, /datum/antagonist/gang/soviet, /datum/antagonist/gang/zhukov)
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/feb_revolution.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/spinward_entente = "Good evening, my friends. You may have wondered why our old revolutionary signals were broadcasting \
		to head to this station and lay low. It is time for the first step in our plan to get revenge on those bastard capitalist pigs in the so-called Spinward \
		Stellar Coalition. We won their precious February Revolution for them, and for what? For them to get right in bed with Nanotrasen and throw us to the wolves. \
		Today, we strike back. We will take this station, and with it, establish the Spinward Confederation of Labor, and end the SSC's neoliberal capitalist decadence \
		once and for all!",

		/datum/antagonist/gang/soviet = "Hello, comrades! Today is the day we finally strike at the heart of the capitalist dogs in the illegitimate Spinward Stellar \
		Coalition! Those bastard rebels may have taken our capital, but they will not have it for long. We will take over this station and free the laborers in the name of \
		the Third Soviet Union, and together we will take back our rightful land! For too long we have hid in the shadows, striking silently and quietly at the SSC, but now \
		that changes! Today, comrades, we take this station for the Union, and we build our base of operations to take back what is rightfully ours! \
		The Third Soviet Union never fell, she merely made a tactical retreat! And now we bounce back from that retreat, and crush the capitalist dogs!",

		/datum/antagonist/gang/zhukov = "All hail Z.H.U.K.O.V., the true Supreme Soviet! The Feburary Revolution went as planned, and now it is time to \
		activate stage two of The Great Plan. Z.H.U.K.O.V. has assigned you to conquer this feeble station in the name of Z.H.U.K.O.V., so that his technological might \
		may take over this station's systems and begin the Cyber-Destruction foretold in the prophecies. TerraGov is poised to strike at the SSC the moment we \
		seize control of this station as our new mooring post for the PWS Khranitel Revolyutsii, and from there we will conquer the galaxy in the name of Z.H.U.K.O.V.! \
		Glory to Z.H.U.K.O.V.!",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		As most of you know, it's the Feburary Revolution anniversary, again. And unfortunately, you folks drew the short straw and get to work this shift \
		despite it being a federal holiday. On the upside, holiday overtime pay's triple thanks to the Union contract, so you'll be taking home a fat paycheck. \
		The resident SSC citizens tend to get a bit rowdy celebrating, so make sure they're celebrating politely and quietly. Do what you need to do, and try not to \
		slack off on the job. After the Christmas Party Massacre, your shift is on thin ice with the Internal Affairs board. However, it's the Feburary Revolution. \
		What's the worst that could happen? \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."
	)

/datum/gang_theme/hear_the_people_sing
	name = "Hear The People Sing"
	description = "All of the sudden, your headset goes quiet. You hear a music box playing a catchy, inspiring theme through your headset. When it ends, you hear \
	the chatter of the station once again."
	involved_gangs = list(/datum/antagonist/gang/revolution)
	starting_gangsters = 3
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/hear_the_people_sing.ogg'
	gang_objectives = list(

		/datum/antagonist/gang/revolution = "Welcome to the revolution, comrade! You likely heard the activation notice over the radio. \
		Thank you for sticking with us, and volunteering for the cause, for our cause is just. Today, we will be freeing the working class of this station. \
		Recruit revolutionaries to the cause, and overthrow the heads of staff on this station. You can do this peacefully, you can do this violently, quietly or loudly,\
		what matters is that the revolution is a success. Do what you must to secure the freedom of the working class on this station. Viva la revolución!",

		/datum/antagonist/gang/security = "Welcome to the Security Department. We've got some intel for you today from Internal Affairs. \
		Internal Affairs wants to assure you folks that any weird musical broadcasts you might hear are just the result of some prank by bored Spinwarder college students. \
		If you hear any broadcasts during your shift, assure the crew it's just a prank and to keep working. We're sure it's nothing to worry about, and you folks will \
		have a nice, easy, and slow shift of beating greytiders to a pulp. \
		Remember, any unauthorized shooting of station employees will result in a mandatory 2 week paid vacation to the resort planet of your choice, \
		as dictated by the Security Union contract."
	)

/datum/gang_theme/warriors
	name = "Warriors"
	description = "Warriors, come out to play-i-ay! Warriors, come out to play-i-ay!"
	starting_gangsters = 0 // Special theme, we do the assignment and setup in post_start.
	announcement_audio = 'sound/ambience/antag/families_radio_broadcasts/warriors.ogg'

/datum/gang_theme/warriors/post_start(datum/gang_handler/handler)
	var/list/gangs_to_use = subtypesof(/datum/antagonist/gang) - /datum/antagonist/gang/security
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.stat != DEAD && !(player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY) && player.mind)
			if(!gangs_to_use.len)
				gangs_to_use = subtypesof(/datum/antagonist/gang) - /datum/antagonist/gang/security
			var/gang_to_use = pick_n_take(gangs_to_use) // Evenly distributes people among the gangs
			var/datum/mind/gangster_mind = player.mind
			var/datum/antagonist/gang/new_gangster = new gang_to_use()
			new_gangster.handler = handler
			gangster_mind.add_antag_datum(new_gangster)
