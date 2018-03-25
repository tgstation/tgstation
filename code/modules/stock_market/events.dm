#define TIME_MULTIPLIER 0.7 // so I can speed up/slow down shit

/datum/stockEvent
	var/name = "event"
	var/next_phase = 0
	var/datum/stock/company = null
	var/current_title = "A company holding a pangalactic conference in the Seattle Conference Center, Seattle, Earth"
	var/current_desc = "We will continue to monitor their stocks as the situation unfolds."
	var/phase_id = 0
	var/hidden = 0
	var/finished = 0
	var/last_change = 0

/datum/stockEvent/process()
	if (finished)
		return
	if (world.time > next_phase)
		transition()

/datum/stockEvent/proc/transition()
	return

/datum/stockEvent/proc/spacetime(var/ticks)
	var/seconds = round(ticks / 10)
	var/minutes = round(seconds / 60)
	seconds -= minutes * 60
	return "[minutes] minute(s) and [seconds] second(s)"

/datum/stockEvent/product
	name = "product"
	var/product_name = ""
	var/datum/article/product_article = null
	var/effect = 0

/datum/stockEvent/product/New(var/datum/stock/S)
	company = S
	var/mins = rand(5*TIME_MULTIPLIER,20*TIME_MULTIPLIER)
	next_phase = mins * (600*TIME_MULTIPLIER) + world.time
	current_title = "Product demo"
	current_desc = S.industry.detokenize("[S.name] will unveil a new product on an upcoming %industrial% conference held at spacetime [spacetime(next_phase)]")
	S.addEvent(src)


/datum/stockEvent/product/transition()
	last_change = world.time
	switch (phase_id)
		if (0)
			next_phase = world.time + rand(300*TIME_MULTIPLIER, 600*TIME_MULTIPLIER) * (10*TIME_MULTIPLIER)
			product_name = company.industry.generateProductName(company.name)
			current_title = "Product release: [product_name]"
			current_desc = "[company.name] unveiled their newest product, [product_name], at a conference. Product release is expected to happen at spacetime [spacetime(next_phase)]."
			var/datum/article/A = company.industry.generateInCharacterProductArticle(product_name, company)
			product_article = A
			effect = A.opinion + rand(-1, 1)
			company.affectPublicOpinion(effect)
			phase_id = 1
		if (1)
			finished = 1
			hidden = 1
			company.addArticle(product_article)
			effect += product_article.opinion * 5
			company.affectPublicOpinion(effect)
			phase_id = 2
			company.generateEvent(type)

/datum/stockEvent/bankruptcy
	name = "bankruptcy"
	var/effect = 0
	var/bailout_millions = 0

/datum/stockEvent/bankruptcy/New(var/datum/stock/S)
	hidden = 1
	company = S
	var/mins = rand(9*TIME_MULTIPLIER,60*TIME_MULTIPLIER)
	bailout_millions = rand(70, 190)
	next_phase = mins * 300*TIME_MULTIPLIER + world.time
	current_title = ""
	current_desc = ""
	S.addEvent(src)

/datum/stockEvent/bankruptcy/transition()
	switch (phase_id)
		if (0)
			next_phase = world.time + rand(300*TIME_MULTIPLIER, 600*TIME_MULTIPLIER) * (10*TIME_MULTIPLIER)
			var/datum/article/A = generateBankruptcyArticle()
			if (!A.opinion)
				effect = rand(5) * (prob(50) ? -1 : 1)
			else
				effect = prob(25) ? -A.opinion * rand(8) : A.opinion * rand(4)
			company.addArticle(A)
			company.affectPublicOpinion(rand(-6, -3))
			hidden = 0
			current_title = "Bailout pending due to bankruptcy"
			current_desc = "The government prepared a press release, which will occur at spacetime [spacetime(next_phase)]."
			phase_id = 1
		if (1)
			next_phase = world.time + rand(300*TIME_MULTIPLIER, 600*TIME_MULTIPLIER) * (10*TIME_MULTIPLIER)
			finished = 1
			if (effect <= -5 && prob(10))
				current_title = "[company.name]: Complete crash"
				current_desc = "The company had gone bankrupt, was not bailed out and could not recover. No further stock trade will take place. All shares in the company are effectively worthless."
				company.bankrupt = 1
				for (var/X in company.shareholders)
					var/amt = company.shareholders[X]
					GLOB.stockExchange.balanceLog(X, -amt * company.current_value)
				company.shareholders = list()
				company.current_value = 0
				company.borrow_brokers = list()
				GLOB.stockExchange.generateStocks(1)

			var/bailout = (effect > 0 && prob(80)) || (effect < 0 && prob(20))
			current_title = "[company.name] [bailout ? "bailed out" : "on a painful rebound"]"
			if (bailout)
				current_desc = "The company has been bailed out by the government. Investors are highly optimistic."
				company.affectPublicOpinion(abs(effect) * 2)
			else
				current_desc = "The company was not bailed out, but managed to crawl out of bankruptcy. Stockholder trust is severely dented."
				company.affectPublicOpinion(-abs(effect) / 2)
			company.generateEvent(type)

/datum/stockEvent/bankruptcy/proc/generateBankruptcyArticle()
	var/datum/article/A = new
	var/list/bankrupt_reason = list("investor pessimism", "failure of product lines", "economic recession", "overblown inflation", "overblown deflation", "collapsed pyramid schemes", "a Ponzi scheme", "economic terrorism", "extreme hedonism", "unfavourable economic climate", "rampant government corruption", "divine conspiracy", "some total bullshit", "volatile plans")
	A.about = company
	A.headline = pick(	"[company.name] filing for bankruptcy", \
						"[company.name] unable to pay, investors run", \
						"[company.name] crashes, in foreclosure", \
						"[company.name] in dire need of credits")
	A.subtitle = "Investors panic, bailout pending"
	if (prob(15))
		A.opinion = rand(-1, 1)
	var/article = "Another one might bite the dust: [company.current_trend > 0 ? "despite their positive trend" : "in line with their failing model"], [company.name] files for bankruptcy citing [pick(bankrupt_reason)]. The president of %country% has been asked to bail the company out, "
	if (!A.opinion)
		article += "but no answer has been given by the government to date. Our tip to stay safe is: %sell%"
	else if (A.opinion > 0)
		article += "and the government responded positively. When the share value hits its lowest, it is a safe bet to %buy%"
	else
		article += "but the outlook is not good. For investors, now would be an ideal time to %sell%"
	A.article = A.detokenize(article, company.industry.tokens)
	return A

/datum/stockEvent/arrest
	name = "arrest"
	var/female = 0
	var/tname = "Elvis Presley"
	var/position = "CEO"
	var/offenses = "murder"
	var/effect = 0

/datum/stockEvent/arrest/New(var/datum/stock/S)
	hidden = 1
	company = S
	var/mins = rand(10*TIME_MULTIPLIER, 35*TIME_MULTIPLIER)
	next_phase = mins * 600*TIME_MULTIPLIER + world.time
	current_title = ""
	current_desc = ""
	female = prob(50)
	if (prob(50))
		position = "C[prob(20) ? vowel() : consonant()]O"
	else
		position = ucfirsts(company.industry.detokenize("Lead %industrial% Engineer"))
	offenses = ""
	var/list/O = list("corruption", "murder", "grand theft", "assault", "battery", "drug possession", "burglary", "theft", "grand sabotage", "bribery",
						"disorderly conduct", "treason", "sedition", "shoplifting", "tax evasion", "tax fraud", "insurance fraud", "perjury", "kidnapping", "manslaughter", "vandalism", "forgery", "extortion", "embezzlement",
						"public indecency", "public intoxication", "trespassing", "loitering", "littering", "vigilantism", "squatting", "panhandling", "arson", "spacepodjacking", "shuttlejacking", "carjacking", "singularityjacking",
						"dereliction of duty", "spacecraft piracy", "music piracy", "tabletop game piracy", "software piracy", "escaping from space prison", "seniornapping", "clownnapping", "corginapping", "catnapping",
						"sleeping on the job", "terrorism", "counterterrorism", "drug distribution", "insubordination", "jaywalking", "owning a computer", "owning a cellphone", "owning a PDA", "owning a pAI", "adultery",
						"committing an unnatural act with another person", "corrupting public morals", "skateboarding without a license", "shitcurity", "bestiality", "erotic roleplay", "accidentally strangling a prostitute")
	while (prob(60) && O.len > 2)
		var/offense = pick(O)
		O -= offense
		offense = "[prob(20) ? "attempted " : (prob(20) ? "being accessory to " : null)][offense][prob(5) ? " of the [pick("first", "second", "third", "fourth", "fifth", "sixth")] degree" : null]"
		if (offenses == "")
			offenses = offense
		else
			offenses += ", [offense]"
	offenses += " and [prob(20) ? "attempted " : null][pick(O)]" // lazy
	S.addEvent(src)

/datum/stockEvent/arrest/transition()
	switch (phase_id)
		if (0)
			tname = "[female ? pick(GLOB.first_names_female) : pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			next_phase = world.time + rand(300*TIME_MULTIPLIER, 600*TIME_MULTIPLIER) * (10*TIME_MULTIPLIER)
			var/datum/article/A = generateArrestArticle()
			if (!A.opinion)
				effect = rand(5) * (prob(50) ? -1 : 1)
			else
				effect = prob(25) ? -A.opinion * rand(5) : A.opinion * rand(3)
			company.addArticle(A)
			company.affectPublicOpinion(rand(-3, -1))
			hidden = 0
			current_title = "Trial of [tname] ([position]) scheduled"
			current_desc = "[female ? "She": "He"] has been charged with [offenses]; the trial is scheduled to occur at spacetime [spacetime(next_phase)]."
			phase_id = 1
		if (1)
			next_phase = world.time + rand(300*TIME_MULTIPLIER, 600*TIME_MULTIPLIER) * (10*TIME_MULTIPLIER)
			finished = 1
			current_title = "[tname] [effect > 0 ? "acquitted" : "found guilty"]"
			if (effect > 0)
				current_desc = "The accused has been acquitted of all charges. Investors optimistic."
			else
				current_desc = "The accused has been found guilty of all charges. Investor trust takes massive hit."
			company.affectPublicOpinion(effect)
			company.generateEvent(type)

/datum/stockEvent/arrest/proc/generateArrestArticle()
	var/datum/article/A = new
	A.about = company
	A.headline = company.industry.detokenize(pick( \
						"[tname], [position] of [company.name] arrested", \
						"[position] of [company.name] facing jail time", \
						"[tname] behind bars", \
						"[position] of %industrial% company before trial", \
						"Police arrest [tname] in daring raid", \
						"Job vacancy ahead: [company.name]'s [position] in serious trouble"))
	A.subtitle = "[A.author] reporting directly from the courtroom"
	if (prob(15))
		A.opinion = rand(-1, 1)
	var/article = "[pick("Security", "Law enforcement")] forces issued a statement that [tname], the [position] of [company.name], the %famous% %industrial% %company% was arrested %this_time%. The trial has been scheduled and the statement reports that the arrested individual is being charged with [offenses]. "
	if (!A.opinion)
		article += "While we cannot predict the outcome of this trial, our tip to stay safe is: %sell%"
	else if (A.opinion > 0)
		article += "Our own investigation shows that these charges are baseless and the arrest is most likely a publicity stunt. Our advice? You should %buy%"
	else
		article += "[tname] has a prior history of similar misdeeds and we're confident the charges will stand. For investors, now would be an ideal time to %sell%"
	A.article = A.detokenize(article, company.industry.tokens)
	return A
