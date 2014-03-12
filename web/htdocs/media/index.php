<?php
require_once ('config.php');

define('MEDIA_ROOT', dirname(__FILE__));
define('FILE_DIR', MEDIA_ROOT . '/files');
define('LIB_DIR', MEDIA_ROOT . '/lib');
define('PLAYLIST_DIR', MEDIA_ROOT . '/playlists');

require_once (LIB_DIR . '/getid3/getid3.php');

// Don't fuck with this shit.
$getID3 = new getID3;

if (!isset($_GET['playlist']))
    die(json_encode($playlists));
$playlist = $_GET['playlist'];
if (!in_array($playlist, $playlists))
    die('No');

function loadFilesIn($subdir) {
    $pl = array();
	$striplen=strlen(FILE_DIR)+1;
    foreach (new RecursiveIteratorIterator (new RecursiveDirectoryIterator (FILE_DIR.'/'.$subdir)) as $name => $file)
	{
	        $relfile = substr($file->getPathname(),$striplen);// . '/' . $file;
	        if(substr($relfile,-1)=='.') continue;
	        $pl[$relfile] = array();
	}
    return $pl;
}

require (PLAYLIST_DIR . '/' . $playlist . '.php');

if (!file_exists('cache/'))
    mkdir('cache/');

$json = array();
foreach ($playlist as $file => $data) {
    list(, $ext) = explode('.', $file);

    if (!in_array($ext, $validExtensions))
        continue;
	
    $json[]=analyzeFile($file, $data);
}

function analyzeFile($file,$playlist_data) {
    global $validExtensions, $getID3;
    $fileURL = BASE_URL . '/files/' . $file;
    $file = FILE_DIR . '/' . $file;
	
    // use cache, if available
    $cachefile = 'cache/' . md5($file) . '.cache.php';
    if (file_exists($cachefile)) {
        require ($cachefile);
        $row = array_merge($row, $playlist_data);
        return $row;
    }

    // Get ID3 tags and whatnot
    $data = $getID3->analyze($file);
    getid3_lib::CopyTagsToComments($data);

    // We need a playtime. Abort if not found.
    if (!isset($data['playtime_seconds'])) {
        echo "<h2>{$file}</h2>";
        var_dump($data);
        return;
    }

    //@formatter:off
    $row = array(
    	'title' => '???', 
    	'artist' => 'Unknown', 
    	'album' => '', 
    	
    	'url' => $fileURL, 
    	'length' => '' . (int)($data['playtime_seconds'] * 10)
	);
	//@formatter:on

    if (isset($data['comments_html']) && (array_key_exists('artist', $data['comments_html']) || array_key_exists('album', $data['comments_html']))) {
        $row['title'] = $data['comments_html']['title'][0];
        if (isset($data['comments']['artist']))
            $row['artist'] = $data['comments']['artist'][0];
        if (isset($data['comments']['album']))
            $row['album'] = $data['comments']['album'][0];
    } else {
        $matches = array();
        // Search for something of the form "artist - title (album).ext"
        if (preg_match('/([^\\-]+)\\-([^\\(\\.]+)(\\(([^\\)])\\))?\\.([a-z0-9]{3})/', $file, $matches) !== FALSE) {
            if (count($matches) >= 2) {
                $row['artist'] = trim($matches[1]);
                $row['title'] = trim($matches[2]);
                $row['album'] = trim($matches[3]);
            }
        }
    }

    file_put_contents($cachefile, '<?php $row=' . var_export($row, true).';');

    $row = array_merge($row, $playlist_data);
    return $row;
}
header('Content-type: text/plain');
#echo json_encode($json);
echo json_encode($json,JSON_PRETTY_PRINT);
