<?php
//header('Content-type: text/plain');

define('BASE_URL', 'http://ss13.nexisonline.net/media');

// include getID3() library (can be in a different directory if full path is specified)
require_once('getid3/getid3.php');

// Initialize getID3 engine
$getID3 = new getID3;

$validExtensions = array('mp3', 'ogg');
$json = array();
foreach (glob('*.*') as $file) {
	list(, $ext) = explode('.', $file);
	if(!in_array($ext, $validExtensions))
		continue;
	$data = $getID3->analyze($file);
	getid3_lib::CopyTagsToComments($data);
	
	if(file_exists($file.'.cache.php'))
		require($file.'.cache.php');
	else{
		$row = array(
			'title' => '???',
			'artist' => 'Unknown',
			'album' => '',
			
			'url' => BASE_URL.'/'.urlencode($file),
			'length' => ''.(int)($data['playtime_seconds']*10)
		);
		if(array_key_exists('artist',$data['comments_html']) || array_key_exists('album',$data['comments_html'])){
			$row['title']=$data['comments_html']['title'][0];
			if(isset($data['comments']['artist']))
				$row['artist']=$data['comments']['artist'][0];
			if(isset($data['comments']['album']))
				$row['album'] = $data['comments']['album'][0];
		} else {
			$matches=array();
    		// Search for something of the form "artist - title (album).ext"
			if (preg_match('/([^\\-]+)\\-([^\\(\\.]+)(\\(([^\\)])\\))?\\.([a-z0-9]{3})/', $file, $matches) !== FALSE)
			{
				if(count($matches)>=2){
					$row['artist'] = trim($matches[1]);
					$row['title'] = trim($matches[2]);
					$row['album'] = trim($matches[3]);
				}
			}
		}
	}
	
	$json[]=$row;
	/*
	echo '<pre>';
	#echo json_encode($row);
	echo htmlentities(print_r($data['comments'], true));
	echo '</pre>';
	*/
		
}
echo json_encode($json);
