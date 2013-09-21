<?php
$this->poll->LoadOptions();
$responses=$this->poll->GetVotes();
?>
<p>
	<a href="<?=fmtURL('home')?>">Home</a> 
&gt; <a href="<?=fmtURL('poll')?>">Polls</a>
</p>
<h2>Poll Details</h2>
<h3>Question:</h3>
<p><em><?=$this->poll->question?></em></p>
<h3>Answers:</h3>
<?foreach($responses as $response):?>
<div class="polltext">
	<?=htmlentities($response)?>
</div>
<?endforeach;?>
