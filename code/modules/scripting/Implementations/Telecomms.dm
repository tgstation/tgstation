//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

//Span classes that players are allowed to set in a radio transmission.
var/list/allowed_custom_spans = list(SPAN_ROBOT,SPAN_YELL,SPAN_ITALICS,SPAN_SANS)

/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

	HandleError(runtimeError/e)
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")

	GC()
		..()
		Compiler = null


/datum/TCS_Compiler

	var/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Set ourselves to Garbage Collect -- */

	proc/GC()

		Holder = null
		if(interpreter)
			interpreter.GC()


	/* -- Compile a raw block of text -- */

	proc/Compile(code as message)
		var/n_scriptOptions/nS_Options/options = new()
		var/n_Scanner/nS_Scanner/scanner       = new(code, options)
		var/list/tokens                        = scanner.Scan()
		var/n_Parser/nS_Parser/parser          = new(tokens, options)
		var/node/BlockDefinition/GlobalBlock/program   	 = parser.Parse()

		var/list/returnerrors = list()

		returnerrors += scanner.errors
		returnerrors += parser.errors

		if(returnerrors.len)
			return returnerrors

		interpreter 		= new(program)
		interpreter.persist	= 1
		interpreter.Compiler= src

		return returnerrors

	/* -- Execute the compiled code -- */

	proc/Run(datum/signal/signal)

		if(!ready)
			return

		if(!interpreter)
			return

		interpreter.container = src

		interpreter.SetVar("PI"		, 	3.141592653)	// value of pi
		interpreter.SetVar("E" 		, 	2.718281828)	// value of e
		interpreter.SetVar("SQURT2" , 	1.414213562)	// value of the square root of 2
		interpreter.SetVar("FALSE"  , 	0)				// boolean shortcut to 0
		interpreter.SetVar("false"  , 	0)				// boolean shortcut to 0
		interpreter.SetVar("TRUE"	,	1)				// boolean shortcut to 1
		interpreter.SetVar("true"	,	1)				// boolean shortcut to 1

		interpreter.SetVar("NORTH" 	, 	NORTH)			// NORTH (1)
		interpreter.SetVar("SOUTH" 	, 	SOUTH)			// SOUTH (2)
		interpreter.SetVar("EAST" 	, 	EAST)			// EAST  (4)
		interpreter.SetVar("WEST" 	, 	WEST)			// WEST  (8)

		// Channel macros
		interpreter.SetVar("$common",	1459)
		interpreter.SetVar("$science",	1351)
		interpreter.SetVar("$command",	1353)
		interpreter.SetVar("$medical",	1355)
		interpreter.SetVar("$engineering",1357)
		interpreter.SetVar("$security",	1359)
		interpreter.SetVar("$supply",	1347)
		interpreter.SetVar("$service",	1349)

		// Signal data

		interpreter.SetVar("$content", 	html_decode(signal.data["message"]))
		interpreter.SetVar("$freq"   , 	signal.frequency)
		interpreter.SetVar("$source" , 	signal.data["name"])
		interpreter.SetVar("$job"    , 	signal.data["job"])
		interpreter.SetVar("$sign"   ,	signal)
		interpreter.SetVar("$pass"	 ,  !(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0
		interpreter.SetVar("$filters"  ,	signal.data["spans"]) //Important, this is given as a vector! (a list)
		interpreter.SetVar("$say"    , 	signal.data["verb_say"])
		interpreter.SetVar("$ask"    , 	signal.data["verb_ask"])
		interpreter.SetVar("$yell"    , 	signal.data["verb_yell"])
		interpreter.SetVar("$exclaim"    , 	signal.data["verb_exclaim"])

		//Current allowed span classes
		interpreter.SetVar("$robot",	SPAN_ROBOT) //The font used by silicons!
		interpreter.SetVar("$loud",		SPAN_YELL)	//Bolding, applied when ending a message with several exclamation marks.
		interpreter.SetVar("$emphasis",	SPAN_ITALICS) //Italics
		interpreter.SetVar("$wacky",		SPAN_SANS) //Comic sans font, normally seen from the genetics power.

		//Language bitflags
		interpreter.SetVar("HUMAN"   ,	HUMAN)
		interpreter.SetVar("MONKEY"   ,	MONKEY)
		interpreter.SetVar("ALIEN"   ,	ALIEN)
		interpreter.SetVar("ROBOT"   ,	ROBOT)
		interpreter.SetVar("SLIME"   ,	SLIME)
		interpreter.SetVar("DRONE"   ,	DRONE)

		var/curlang = HUMAN
		if(istype(signal.data["mob"], /atom/movable))
			var/atom/movable/M = signal.data["mob"]
			curlang = M.languages

		interpreter.SetVar("$language", curlang)


		/*
		Telecomms procs
		*/

		/*
			-> Send another signal to a server
					@format: broadcast(content, frequency, source, job, lang)

					@param content:		Message to broadcast
					@param frequency:	Frequency to broadcast to
					@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
					@param job:			The name of the job.
					@param spans		What span classes you want to apply to your message. Must be in the "allowed_custom_spans" list.
					@param say			Say verb used in messages ending in ".".
					@param ask			Say verb used in messages ending in "?".
					@param yell			Say verb used in messages ending in "!!" (or more).
					@param exclaim		Say verb used in messages ending in "!".

		*/
		interpreter.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job","spans","say","ask","yell","exclaim"))

		/*
			-> Send a code signal.
					@format: signal(frequency, code)

					@param frequency:		Frequency to send the signal to
					@param code:			Encryption code to send the signal with
		*/
		interpreter.SetProc("signal", "signaler", signal, list("freq", "code"))

		/*
			-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
					@format: mem(address, value)

					@param address:		The memory address (string index) to store a value to
					@param value:		The value to store to the memory address
		*/
		interpreter.SetProc("mem", "mem", signal, list("address", "value"))


		/*
		General NTSL procs
		Should probably be moved to its own place
		*/
		// Vector
		interpreter.SetProc("vector", /proc/n_list)
		interpreter.SetProc("at", /proc/n_listpos)
		interpreter.SetProc("copy", /proc/n_listcopy)
		interpreter.SetProc("push_back", /proc/n_listadd)
		interpreter.SetProc("remove", /proc/n_listremove)
		interpreter.SetProc("cut", /proc/n_listcut)
		interpreter.SetProc("swap", /proc/n_listswap)
		interpreter.SetProc("insert", /proc/n_listinsert)
		interpreter.SetProc("pick", /proc/n_pick)
		interpreter.SetProc("prob", /proc/n_prob)
		interpreter.SetProc("substr", /proc/n_substr)
		interpreter.SetProc("find", /proc/n_smartfind)
		interpreter.SetProc("length", /proc/n_smartlength)

		// Strings
		interpreter.SetProc("lower", /proc/n_lower)
		interpreter.SetProc("upper", /proc/n_upper)
		interpreter.SetProc("explode", /proc/n_explode)
		interpreter.SetProc("implode", /proc/n_implode)
		interpreter.SetProc("repeat", /proc/n_repeat)
		interpreter.SetProc("reverse", /proc/n_reverse)
		interpreter.SetProc("tonum", /proc/n_str2num)
		interpreter.SetProc("replace", /proc/n_replace)
		interpreter.SetProc("proper", /proc/n_proper)

		// Numbers
		interpreter.SetProc("tostring", /proc/n_num2str)
		interpreter.SetProc("sqrt", /proc/n_sqrt)
		interpreter.SetProc("abs", /proc/n_abs)
		interpreter.SetProc("floor", /proc/n_floor)
		interpreter.SetProc("ceil", /proc/n_ceil)
		interpreter.SetProc("round", /proc/n_round)
		interpreter.SetProc("clamp", /proc/n_clamp)
		interpreter.SetProc("inrange", /proc/n_inrange)
		interpreter.SetProc("rand", /proc/n_rand)
		interpreter.SetProc("randseed", /proc/n_randseed)
		interpreter.SetProc("min", /proc/n_min)
		interpreter.SetProc("max", /proc/n_max)
		interpreter.SetProc("sin", /proc/n_sin)
		interpreter.SetProc("cos", /proc/n_cos)
		interpreter.SetProc("asin", /proc/n_asin)
		interpreter.SetProc("acos", /proc/n_acos)
		interpreter.SetProc("log", /proc/n_log)

		// Time
		interpreter.SetProc("time", /proc/n_time)
		interpreter.SetProc("sleep", /proc/n_delay)
		interpreter.SetProc("timestamp", /proc/gameTimestamp)

		// Run the compiled code
		interpreter.Run()

		// Backwards-apply variables onto signal data
		/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

		signal.data["message"] 	= interpreter.GetCleanVar("$content", signal.data["message"])
		signal.frequency 		= interpreter.GetCleanVar("$freq", signal.frequency)

		var/setname = interpreter.GetCleanVar("$source", signal.data["name"])

		if(signal.data["name"] != setname)
			signal.data["realname"] = setname
		signal.data["name"]			= setname
		signal.data["job"]			= interpreter.GetCleanVar("$job", signal.data["job"])
		signal.data["reject"]		= !(interpreter.GetCleanVar("$pass")) // set reject to the opposite of $pass
		signal.data["verb_say"]		= interpreter.GetCleanVar("$say")
		signal.data["verb_ask"]		= interpreter.GetCleanVar("$ask")
		signal.data["verb_yell"]	= interpreter.GetCleanVar("$yell")
		signal.data["verb_exclaim"]	= interpreter.GetCleanVar("$exclaim")
		var/list/setspans 			= interpreter.GetCleanVar("$filters") //Save the span vector/list to a holder list
		setspans &= allowed_custom_spans //Prune out any illegal ones. Go ahead, comment this line out. See the horror you can unleash!
		if(islist(setspans)) //Previous comment block was right. Players cannot be trusted with ANYTHING. At all. Ever.
			signal.data["spans"]	= setspans //Apply new span to the signal only if it is a valid list, made using vector() in the script.

		// If the message is invalid, just don't broadcast it!
		if(signal.data["message"] == "" || !signal.data["message"])
			signal.data["reject"] = 1

/*  -- Actual language proc code --  */

var/const/SIGNAL_COOLDOWN = 20 // 2 seconds

/datum/signal

	proc/mem(address, value)

		if(istext(address))
			var/obj/machinery/telecomms/server/S = data["server"]

			if(!value && value != 0)
				return S.memory[address]

			else
				S.memory[address] = value


	proc/signaler(freq = 1459, code = 30)

		if(isnum(freq) && isnum(code))

			var/obj/machinery/telecomms/server/S = data["server"]

			if(S.last_signal + SIGNAL_COOLDOWN > world.timeofday && S.last_signal < MIDNIGHT_ROLLOVER)
				return
			S.last_signal = world.timeofday

			var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)

			if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
				freq *= 10 // shift the decimal one place

			freq = sanitize_frequency(freq)

			code = round(code)
			code = Clamp(code, 0, 100)

			var/datum/signal/signal = new
			signal.source = S
			signal.encryption = code
			signal.data["message"] = "ACTIVATE"

			connection.post_signal(S, signal)

			var/time = time2text(world.realtime,"hh:mm:ss")
			lastsignalers.Add("[time] <B>:</B> [S.id] sent a signal command, which was triggered by NTSL.<B>:</B> [format_frequency(freq)]/[code]")


	proc/tcombroadcast(message, freq, source, job, spans, say = "says", ask = "asks", yell = "yells", exclaim = "exclaims")

		var/datum/signal/newsign = new
		var/obj/machinery/telecomms/server/S = data["server"]
		var/obj/item/device/radio/hradio = S.server_radio

		if(!hradio)
			throw EXCEPTION("tcombroadcast(): signal has no radio")
			return

		if((!message) && message != 0)
			message = "*beep*"
		if(!source)
			source = "[html_encode(uppertext(S.id))]"
			hradio = new // sets the hradio as a radio intercom
		if(!freq || (!isnum(freq) && text2num(freq) == null))
			freq = 1459
		if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
			freq *= 10 // shift the decimal one place

		if(!job)
			job = "Unknown"

		if(!islist(spans))
			spans = list()
		else
			spans &= allowed_custom_spans //Removes any spans not on the allowed list. Comment this out if want to let players use ANY span in stylesheet.dm!

		//SAY REWRITE RELATED CODE.
		//This code is a little hacky, but it *should* work. Even though it'll result in a virtual speaker referencing another virtual speaker. vOv
		var/atom/movable/virtualspeaker/virt = PoolOrNew(/atom/movable/virtualspeaker,null)
		virt.name = source
		virt.job = job
		virt.languages = HUMAN
		//END SAY REWRITE RELATED CODE.

		newsign.data["mob"] = virt
		newsign.data["mobtype"] = /mob/living/carbon/human
		newsign.data["name"] = source
		newsign.data["realname"] = newsign.data["name"]
		newsign.data["job"] = "[job]"
		newsign.data["compression"] = 0
		newsign.data["message"] = message
		newsign.data["type"] = 2 // artificial broadcast
		newsign.data["spans"] = spans
		newsign.data["verb_say"] = say
		newsign.data["verb_ask"] = ask
		newsign.data["verb_yell"]= yell
		newsign.data["verb_exclaim"] = exclaim
		if(!isnum(freq))
			freq = text2num(freq)
		newsign.frequency = freq


		newsign.data["radio"] = hradio
		newsign.data["vmessage"] = message
		newsign.data["vname"] = source
		newsign.data["vmask"] = 0
		newsign.data["level"] = data["level"]

		newsign.sanitize_data()

		var/pass = S.relay_information(newsign, "/obj/machinery/telecomms/hub")
		if(!pass)
			S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters

