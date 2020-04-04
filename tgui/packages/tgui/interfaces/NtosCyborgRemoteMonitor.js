import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section, LabeledList } from '../components';

export const NtosCyborgRemoteMonitor = props => {
  const { state } = props;
  const { act, data } = useBackend(props);
  const {
	card,
    cyborgs = [],
  } = data;

  return (
    <Cyborgs state={state} cyborgs={cyborgs} card={card} />
  );
};

const Cyborgs = props => {
  const { state, cyborgs, card } = props;
  const { act, data } = useBackend(props);
  
  if (!cyborgs.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">
          No cyborg units detected.
        </NoticeBox>
      </Section>
    );
  }

  return (
	<Fragment>
		{!card && (
		  <Section>
			<NoticeBox textAlign="left">
			  Certain features require an ID card login.
			</NoticeBox>
		  </Section>
		)}
		{cyborgs.map(cyborg => {
		return (
		  <Section
			key={cyborg.ref}
			title={cyborg.name}
			buttons={(
				!!card && (
					<Button
					icon="terminal"
					content="Send Message"
					color="blue"
					onClick={() => act('messagebot', {
					  ref: cyborg.ref,
					})} />
				) || (
					<Button
					icon="terminal"
					content="Send Message"
					color="grey"
					/>
				)
			)}>
			<LabeledList>
			  <LabeledList.Item label="Status">
				<Box color={cyborg.status
				  ? 'bad'
				  : cyborg.locked_down
					? 'average'
					: 'good'}>
				  {cyborg.status
					? "Not Responding"
					: cyborg.locked_down
					  ? "Locked Down"
					  : cyborg.shell_discon
						? "Nominal/Disconnected"
						: "Nominal"}
				</Box>
			  </LabeledList.Item>
			  <LabeledList.Item label="Charge">
				<Box color={cyborg.charge <= 30
				  ? 'bad'
				  : cyborg.charge <= 70
					? 'average'
					: 'good'}>
				  {typeof cyborg.charge === 'number'
					? cyborg.charge + "%"
					: "Not Found"}
				</Box>
			  </LabeledList.Item>
			  <LabeledList.Item label="Module">
				{cyborg.module}
			  </LabeledList.Item>
			  <LabeledList.Item label="Upgrades">
				{cyborg.upgrades}
			  </LabeledList.Item>
			</LabeledList>
		  </Section>
		);
	  })}
    </Fragment>
  )
}
