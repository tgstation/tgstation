<?php
$this->poll->LoadOptions();
$responses=$this->poll->GetVotes();
$totalRespondants=$responses['total'];
$winningCount=$responses['winner'];
?>
<p>
	<a href="<?=fmtURL('home')?>">Home</a> 
&gt; <a href="<?=fmtURL('poll')?>">Polls</a>
</p>
<h2>Poll Details</h2>
<h3>Question:</h3>
<p><em><?=$this->poll->question?></em></p>
<h3>Answers:</h3>
<table>
	<thead>
		<th>Answer</th>
		<th>Respondants</th>
		<th>%</th>
	</thead>
	<?foreach($this->poll->options as $opt):
		$respondants=$responses[$opt->ID];
	?>
	<tr>
		<th class="clmText"><?=$opt->text?></th>
		<td class="clmRespondants"><?=$respondants?></td>
		<td class="clmPercent">
			<?=sprintf('%0.2f%%',($respondants/$totalRespondants)*100)?>
			<span class="bar<?=($winningCount==$respondants)?' green':''?>" style="width:<?=(500*($respondants/$totalRespondants))?>px">&nbsp;</span>
		</td>
	</tr>
	<?endforeach;?>
</table>