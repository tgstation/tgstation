<?php
require('config.php');
require('classes/classes.php');

$ACT_HANDLERS['web_forum']=new ExternalLinkHandler('Forums','/img/forum.png','http://forums.nexisonline.net');
$ACT_HANDLERS['web_wiki']=new ExternalLinkHandler('Wiki','/img/wiki.png','/wiki/');

		
$PI= explode('/',$_SERVER['PATH_INFO']);
array_shift($PI);
switch($PI[0]) 
{
	// DEBUGGING:  Show all registered ACT HANDLERS
	case 'showact':
		?><h1>Registered Action Handlers</h1><ul><?
		foreach($ACT_HANDLERS as $name => $handler)
		{
			echo "<li>{$name} - {$handler->description} ({$handler->version})</li>";
		}
		echo '</ul>';
		break;
	// Authentication
	case 'auth':
		if(User::Authenticate($_POST['username'], $_POST['password'], false)) 
		{
			Templates::AddGeneralNote('You\'re now logged in.');
			$to = (empty($_POST['to'])) ? '/' : $_POST['to']; 
			Templates::Redirect('/');
		} else {
			Templates::AddError('Nope.');
		}
		break;
	// Find a handler and handle it.
	default:
		$handlerkey='web_'.$PI[0];
		if($handlerkey=='web_')
			$handlerkey='web_home';
		if(key_exists($handlerkey, $ACT_HANDLERS))
			$ACT_HANDLERS[$handlerkey]->handle($PI);
}
