// a single news datum
datum/news/var
	ID     // the ID of the news
	title  // the title of the news
	body   // a body with an exact explanation
	author // key of the author

datum/news_topic_handler
	Topic(href,href_list)
		var/client/C = href_list["client"]
		if(href_list["action"] == "show_all_news")
			C.display_all_news_list()
		else if(href_list["action"] == "show_news")
			C.display_news_list()
		else if(href_list["action"] == "add_news")
			C.add_news()

var/datum/news_topic_handler/news_topic_handler

world/New()
	..()
	news_topic_handler = new

proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

// add a new news datums
proc/make_news(title, body, author)
	var/savefile/News = new("data/news.sav")
	var/list/news
	var/lastID

	News["news"]   >> news
	News["lastID"] >> lastID

	if(!news) 	news = list()
	if(!lastID) lastID = 0

	var/datum/news/created = new()
	created.ID 		= ++lastID
	created.title 	= title
	created.body 	= body
	created.author 	= author

	news.Insert(1, created)

	News["news"]   << news
	News["lastID"] << lastID

// load the news from disk
proc/load_news()
	var/savefile/News = new("data/news.sav")
	var/list/news

	News["news"] >> news

	if(!news) news = list()

	return news

// save the news to disk
proc/save_news(var/list/news)
	var/savefile/News = new("data/news.sav")
	News << news

// check if there are any news in the player's "inbox"
client/proc/has_news()
	var/list/news = load_news()

	// load the list of news already read by this player
	var/path = savefile_path(src.mob)
	if(!fexists(path))
		return

	var/savefile/F = new(path)
	var/list/read_news = list()
	F["read_news"] >> read_news

	for(var/datum/news/N in news)
		if(N.ID in read_news)
			continue
		else return 1

	return 0

// display only the news that haven't been read yet
client/proc/display_news_list()
	var/list/news = load_news()

	var/output = ""
	if(has_news())
		// load the list of news already read by this player
		var/path = savefile_path(src.mob)
		if(!fexists(path))
			return

		var/savefile/F = new(path)
		var/list/read_news = list()
		F["read_news"] >> read_news

		for(var/datum/news/N in news)
			if(N.ID in read_news)
				continue
			read_news += N.ID
			output += "<b>[N.title]</b><br>"
			output += "[N.body]<br>"
			output += "<small>authored by <i>[N.author]</i></small><br>"
			output += "<br>"

		F["read_news"] << read_news
	else
		output += "<b>Nothing new!</b><br><br>"

	output += "<a href='?src=\ref[news_topic_handler];client=\ref[src];action=show_all_news'>Display All</a>"
	if(src.holder && istype(src.holder, /obj/admins))
		output += "<a href='?src=\ref[news_topic_handler];client=\ref[src];action=add_news'>Add</a>"

	usr << browse(output, "window=news;size=600x400")


// display all news, even the ones read already
client/proc/display_all_news_list()
	var/list/news = load_news()

	var/output = ""
	for(var/datum/news/N in news)
		output += "<b>[N.title]</b><br>"
		output += "[N.body]<br>"
		output += "<small>authored by <i>[N.author]</i></small><br>"
		output += "<br>"
	if(src.holder && istype(src.holder, /obj/admins))
		output += "<a href='?src=\ref[news_topic_handler];client=\ref[src];action=add_news'>Add</a>"
	usr << browse(output, "window=news;size=600x400")


client/proc/add_news()
	if(!istype(src.holder, /obj/admins))
		src << "<b>You tried to modify the news, but you're not an admin!"
		return

	var/title = input(src.mob, "Select a title for the news", "Title") as null|text
	if(!title) return

	var/body = input(src.mob, "Enter a body for the news", "Body") as null|message
	if(!body) return

	make_news(title, body, key)

client/verb/read_news()
	set category = "OOC"
	set desc = "Read important news and updates"
	display_all_news_list()