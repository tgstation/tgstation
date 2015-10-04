inserChar = '|'
separator = ';'
dataName = "list"
inserClass = "inserChar"

jAnimConsole = ->
	out = $(@)
	list = $(@).data(dataName).split(separator)
	htmlInser = "<span class=#{inserClass}>#{inserChar}</span>"

	out.html htmlInser
	blinkAnim = ->
		$(".#{inserClass}").delay(1000).hide(100).delay(1000).show(100)
		$(".#{inserClass}").queue((next) -> 
													next()
													blinkAnim()
													return
													)
		return
	
	currentWord = 0
	currentChar = 1
	timeBwtLetters = 50
	timeBwtWords = 2500
	
	printWord = ->
		substr = list[currentWord].substr(0, currentChar++)
		out.html "#{substr}#{htmlInser}"
		if currentChar <= list[currentWord].length
			setTimeout printWord, timeBwtLetters
		else
			setTimeout blinkAnim, timeBwtLetters
			currentWord =  (currentWord + 1) % list.length
			currentChar = 1
			setTimeout printWord, timeBwtWords
		
	#etTimeout blinkAnim, 0
	#setTimeout printWord, timeBwtWords
	setTimeout printWord, 0
	
	return

$(".jAnimConsole").each jAnimConsole// JavaScript Document