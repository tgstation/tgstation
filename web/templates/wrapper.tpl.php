<?php
$perfData = array(
	'Image::genThumb', 
	'Post::Fix'
);
$pdO = '';
$showPerfData = false;
foreach ($perfData as $what) {
	if (isset($GLOBALS['sw_elapsed'][$what])) {
		$pdO .= '<li>';
		$pdO .= sprintf('%s: %01.5f seconds', $what, $GLOBALS['sw_elapsed'][$what]);
		$pdO .= '</li>';
		$showPerfData = true;
	}
}
?><!DOCREF html>
<html>
	<head>
		<title>/fail/station - <?=$this->title?></title>
		<link rel="stylesheet" href="<?=WEB_ROOT ?>/style.css" />
		<link rel="stylesheet" href="<?=WEB_ROOT ?>/jquery.tagit.css" />
		<link rel="stylesheet" href="<?=WEB_ROOT ?>/jquery-ui-1.10.0.custom.min.css" />
		<script src="<?=WEB_ROOT ?>/js/jquery-1.9.0.js" type="text/javascript"></script>
		<script src="<?=WEB_ROOT ?>/js/jquery-ui-1.10.0.custom.min.js" type="text/javascript"></script>
		<script src="<?=WEB_ROOT ?>/js/tag-it.min.js" type="text/javascript"></script>
		<?=$this->head ?>
	</head>
	<body>
		<section id="wrap">
			<section id="header">
				<h1>/fail/station</h1>
				<ul id="plinks">
				<? foreach($this->links as $name=>$dat): 
				?>
					<li id="link-<?=$name ?>">
						<a href="<?=$dat['url'] ?>"><img src="<?=$dat['image']?>" alt="<?=$dat['desc']?>" /></a>
					</li>
				<? endforeach; ?>
				</ul>
				<?if($this->session!=false):?>
				<div id="sessinfo">
					Welcome back, <?=$this->session->ckey?> (<?=$this->session->role?>)
				</div>
				<?endif?>
			</section>
			<section id="content">
				<?=$this->body ?>
			</section>
		</section>
		<section id="footer">
			<ul>
				<li class="first">vgstation-web</li>
				<li>Powered by PHP5, MySQL5, and Lighttpd</li>
				<li><?=sprintf('Took %01.5f seconds to render this page.', (microtime(true) - $GLOBALS['sw_']['start']) / 1000) ?></li>
			</ul>
			<?if($showPerfData):?>
			<ul>
				<li class="first" style="color:black">Performance Data:</li><?=$pdO ?>
			</ul>
			<?endif; ?>
		</section>
	</body>
</html>