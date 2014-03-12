<?php
// Simple playlist:
// Files MUST be under files/.
$playlist=array(
	'file1.mp3'=>array(),
	'subfolder/file2.mp3'=>array(
		'title'=>'Just a Friend',
		'artist'=>'Biz Markie'
	)
);

// Dynamic Playlist
// Loads files from files/subfolder.
$playlist=loadFilesIn('subfolder');


// Adjust playlist entry's tags.
$playlist['file1.mp3']=array('artist'=>'Kingston','title'=>'SS13 sucks','album'=>'Fuck You');
