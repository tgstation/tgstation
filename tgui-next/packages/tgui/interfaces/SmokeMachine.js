import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, NoticeBox, Section } from '../components';

export const SmokeMachine = props => {
  const { act, data } = useBackend(props);
  const {
    TankContents,
    isTankLoaded,
    TankCurrentVolume,
    TankMaxVolume,
    active,
    setting,
    screen,
    maxSetting = [],
  } = data;
  return (
    <Fragment>
      <Section title="Dispersal Tank"
        buttons={(
          <Button
            icon={active ? 'power-off' : 'times'}
            selected={active}
            content={active ? 'On' : 'Off'}
            onClick={() => act('power')} />)}>
        <ProgressBar
          value={TankCurrentVolume / TankMaxVolume}
          ranges={{
            bad: [-Infinity, 0.3],
          }}>
          <AnimatedNumber initial={0} value={TankCurrentVolume || 0} />
          {' / ' + TankMaxVolume}
        </ProgressBar>
        <Box mt={1}>
          <LabeledList>
            <LabeledList.Item label="Range">
              <Button selected={setting === 1} icon="plus" content="3"
                disabled={maxSetting < 1} onClick={() => act('setting', {amount: 1})} />
              <Button selected={setting === 2} icon="plus" content="6"
                disabled={maxSetting < 2} onClick={() => act('setting', {amount: 2})} />
              <Button selected={setting === 3} icon="plus" content="9"
                disabled={maxSetting < 3} onClick={() => act('setting', {amount: 3})} />
              <Button selected={setting === 4} icon="plus" content="12"
                disabled={maxSetting < 4} onClick={() => act('setting', {amount: 4})} />
              <Button selected={setting === 5} icon="plus" content="15"
                disabled={maxSetting < 5} onClick={() => act('setting', {amount: 5})} />
            </LabeledList.Item>
          </LabeledList>
        </Box>
      </Section>
      <Section title="Contents"
        buttons={(
          <Button
            icon="trash"
            content="Purge"
            onClick={() => act('purge')} />
        )}>
        {TankContents.map(chemical => (
          <Box
            key={chemical.name}
            color="label">
            <AnimatedNumber
              initial={0}
              value={chemical.volume} />
            {' '}
          units of {chemical.name}
          </Box>
        ))}
      </Section>
    </Fragment>
  );
};
