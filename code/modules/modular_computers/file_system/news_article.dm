// /data/ files store data in string format.
// They don't contain other logic for now.
/datum/computer_file/data/news_article
	filetype = "XNML"
	filename = "Unknown News Entry"
	block_size = 1000 		// Results in smaller files
	do_not_edit = 1			// Editing the file breaks most formatting due to some HTML tags not being accepted as input from average user.
	var/server_file_path 	// File path to HTML file that will be loaded on server start. Example: '/news_articles/space_magazine_1.html'. Use the /news_articles/ folder!

/datum/computer_file/data/news_article/New(var/load_from_file = 0)
	..()
	if(server_file_path && load_from_file)
		stored_data = file2text(server_file_path)
	calculate_size()


// NEWS DEFINITIONS BELOW THIS LINE

/datum/computer_file/data/news_article/space/vol_one
	filename = "SPACE Magazine vol. 1"
	server_file_path = 'news_articles/space_magazine_1.html'

/datum/computer_file/data/news_article/space/vol_two
	filename = "SPACE Magazine vol. 2"
	server_file_path = 'news_articles/space_magazine_2.html'

/datum/computer_file/data/news_article/space/vol_three
	filename = "SPACE Magazine vol. 3"
	server_file_path = 'news_articles/space_magazine_3.html'