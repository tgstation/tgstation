var/datum/subsystem/pullrequests/SSpullrequests

/datum/subsystem/pullrequests
	name = "Pull Requests"
	priority = 0
	wait = 120
	can_fire = 1
	var/nextPr
	var/ignore_player_pref = 1
	var/announce_chance = 10

/datum/subsystem/pullrequests/New()
	nextPr = rand(17000, 17500)
	NEW_SS_GLOBAL(SSpullrequests)

/datum/subsystem/pullrequests/fire()
	if(prob(announce_chance))
		announcePr()

/datum/subsystem/pullrequests/proc/announcePr()
	var/isMerge = prob(50)

	var/author = pick( // Everyone with at least 10 PRs, as of March 24, 2016
		543;"phil235", 499;"KorPhaeron", 381;"Incoming5643", 350;"paprka", 345;"Aranclanos",
		286;"Iamgoofball", 277;"Jordie0608", 268;"Giacom", 264;"MrStonedOne", 239;"tkdrg",
		207;"xxalpha", 203;"AnturK", 193;"Cheridan", 189;"RemieRichards", 183;"ChangelingRain",
		173;"optimumtact", 166;"Razharas", 164;"Firecage", 163;"MrPerson", 162;"Miauw62",
		150;"Menshin", 126;"hornygranny", 121;"GunHog", 119;"bgobandit", 111;"neersighted",
		104;"Ikarrus", 103;"Steelpoint", 85;"Shadowlight213", 79;"KazeEspada", 72;"Metacide",
		67;"Buggy123", 65;"Petethegoat", 61;"Malkevin", 59;"PKPenguin321", 59;"duncathan",
		56;"Core0verload", 56;"JJRcop", 55;"Ergovisavi", 53;"pudl", 53;"Perakp",
		51;"WJohn", 50;"fleure", 47;"MMMiracles", 46;"kyrahabattoir", 45;"kingofkosmos",
		42;"LanCartwright", 42;"Dorsisdwarf", 41;"vista-", 38;"CorruptComputer", 37;"lzimann",
		36;"sawu-tg", 36;"TZK13", 33;"TheVekter", 33;"Intigracy", 31;"AndroidSFV",
		31;"ChuckTheSheep", 31;"Rolan7", 29;"AlexanderUlanH", 26;"Mandurrrh", 25;"SconesC",
		25;"balohmatevz", 25;"dannno", 24;"Supermichael777", 24;"Robustin", 24;"Boggart",
		24;"Donkie", 24;"Limeliz", 23;"Kelenius", 22;"bear1ake", 22;"Thunder12345",
		22;"caelaislinn", 22;"Mloc", 22;"bgare89", 21;"Bawhoppen", 21;"YotaXP",
		21;"swankcookie", 19;"lordpidey", 19;"Lobachevskiy", 19;"SuperSayu", 19;"Delimusca",
		19;"spasticVerbalizer", 19;"dumpdavidson", 18;"Fox-McCloud", 18;"ACCount12", 18;"Deantwo",
		18;"adrix89", 17;"octareenroon91", 17;"francinum", 16;"Nienhaus", 15;"CosmicScientist",
		15;"as334", 15;"Neerti", 14;"Strathcona", 14;"Zelacks", 13;"RandomMarine",
		13;"Fayrik", 12;"Jalleo", 12;"Tokiko1", 12;"freerealestate", 12;"CollenN",
		11;"Cuboos", 11;"feemjmeem", 10;"Niknakflak", 10;"Alek2ander", 10;"Cluwnes")

	var/maintainer = !isMerge ? author : pick(
		"Aranclanos", "ChangelingRain", "Cheridan", "duncathan", "Jordie0608",
		"KorPhaeron", "Razharas", "RemieRichards", "tkdrg", "WJohn")

	var/url = "http://bit.ly/18gECvy?[world.timeofday]" // Different URL each time to keep the link blue

	var/number = isMerge ? rand(nextPr - 500, nextPr) : ++nextPr

	var/list/title = list()
	title += pick(20;"", 4;"\[MAP\] ", 1;"\]s\]")

	while(1)
		title += pick("remove ", "removes ", "removed ",
		              "buff ", "buffs ", "buffed ",
		              "nerf ", "nerfs ", "nerfed ",
		              "ports ", "adds ", "added ",
		              "replaces ", "fixes ", "fixed ",
		              "kills ", "reverts ", "addresses ")

		var/list/punchlines = list("water", "organs", "polyacid", "memes", "taser",
		                           "stamina damage", "hardsuits", "exploit", "nuke",
		                           "ponies", "armor", "health", "uplink", "cat",
		                           "talismans", "metagame", "hats", "run speed",
		                           "pacemaker", "PDA", "fanfiction", "herpes")

		if(prob(25))
			title += pick("the [pick("Captain's", "clown's", "HoS's", "janitor's", "changeling's", "AI's", "bloody")] ",
			              "[pick("Pun Pun's", "Poly's", "Goon's", "goof's", "Ian's")] ")
		else
			punchlines += list("Boxstation", "Metastation", "Dreamstation", "Ministation",
			                   "Asteroidstation", "Birdboat", "iamgoofball", "AI", "fire",
			                   "lizards", "plasmamen", "Tajarans", "Vox", "AYYYs", "clown",
			                   "tesla", "singulo", "vore", "Herobrine", "admins", "changeling",
			                   "ninja", "blob", "cyborgs", "player references", "lawsets",
			                   "Asimov", "stuns", "Cogmap2", "wall sprites", "Solarium", "WGW",
			                   "cult", "Nar-Sie", "gangs", "atmos", "plasma", "CO2", "ERP",
			                   "security", "R&D", "solars", "telecomms", "roleplay options",
			                   "OOC", "adminhelp", "pull request announcements", "badmins",
			                   "permabans", "revolution", "lag", "Ridley", "Temmie", "fun")

		if(prob(25))
			title += pick("April Fools ", "meme ", "robust ", "stupid ", "sexy ", "OP ", "temporary ")

		title += pick(punchlines)

		if(prob(10))
			title += " and "
			continue
		else
			break

	// Capitalize first verb.
	title[2] = "[uppertext(copytext(title[2], 1, 2))][copytext(title[2], 2)]"

	if(!isMerge && prob(15))
		var/r = rand(1, 3)
		if(r & 1)
			title += "\[WIP]"
		if(r & 2)
			title += "\[DNM]"
	else if(prob(10))
		title += " \[QUICK MERGE]"
	if(prob(5))
		title += " \[FUCK]"
	if(prob(5))
		title += "\[i ded]"

	title = jointext(title, null)

	for(var/client/C in clients)
		if(ignore_player_pref || (C.prefs && (C.prefs.chat_toggles & CHAT_PULLR)))
			C << "<span class='announce'>PR: Pull Request [isMerge ? "merged" : "opened"] by [maintainer]: <a href='[url]'>#[number] [author] - [title]</a></span>"
