<?php
$this->poll->LoadOptions();
$responses = $this->poll->GetVotes();
?>
<p>
	<a href="<?=fmtURL('home') ?>">Home</a> 
&gt; <a href="<?=fmtURL('poll') ?>">Polls</a>
</p>
<h2>Poll Details</h2>
<h3>Big Question:</h3>
<p><em><?=$this->poll->question ?></em></p>
<?foreach($this->poll->options as $opt):
	//var_dump($responses[$opt->ID]);
	?>
<table>
	<thead>
		<caption><?=$opt->text ?></caption>
		<th>Answer</th>
		<th>Value</th>
		<th>Respondants</th>
		<th colspan="2">%</th>
	</thead>
	<?
		$midVal = round( ($opt->maxVal + $opt->minVal) / 2);
		$winningCount=$responses[$opt->ID]['winner'];
		$totalRespondants=$responses[$opt->ID]['total'];
		for($i=$opt->minVal;$i<=$opt->maxVal;$i++):
			$respondants=0;
			if(array_key_exists($i,$responses[$opt->ID]))
				$respondants=$responses[$opt->ID][$i];?>
	<tr>
		<th class="clmText">
			<?
			if ($i == $opt->minVal)
				echo htmlentities($opt->descMin);
			elseif ($i == $midVal)
				echo htmlentities($opt->descMid);
			elseif ($i == $opt->maxVal)
				echo htmlentities($opt->descMax);
			?>
		</th>
		<th><?=$i ?></th>
		<td class="clmRespondants"><?=$respondants ?></td>
		<td class="clmPercent">
			<?=sprintf('%0.2f%%', ($respondants / $totalRespondants) * 100) ?>
		</td>
		<td>
			<span class="bar<?=($winningCount == $respondants) ? ' green' : '' ?>" style="width:<?=(500 * ($respondants / $totalRespondants)) ?>px">&nbsp;</span>
		</td>
	</tr>
	<?endfor;endforeach; ?>
</table>