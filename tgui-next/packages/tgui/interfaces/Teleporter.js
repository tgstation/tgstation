import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';

export const Teleporter = props => {
  const { act, data } = useBackend(props);
  const {
    power_station,
    teleporter_hub,
    regime_set,
    target,
    calibration,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Current Regime"
          buttons={(
            <Button
              icon='tools'
              content={siphoning ? 'Stop Siphoning' : 'Siphon Credits'}
              onClick={() => act(siphoning ? 'halt' : 'siphon')} />
          )}>
          {regime_set}
        </LabeledList.Item>
          <LabeledList.Item label="Current Target"
          buttons={(
            <Button
              icon='tools'
              content={siphoning ? 'Stop Siphoning' : 'Siphon Credits'}
              onClick={() => act(siphoning ? 'halt' : 'siphon')} />
          )}>
          {target}
        </LabeledList.Item>
          <LabeledList.Item label="Calibration"
          buttons={(
            <Button
              icon='tools'
              content={siphoning ? 'Stop Siphoning' : 'Siphon Credits'}
              onClick={() => act(siphoning ? 'halt' : 'siphon')} />
          )}>
          {calibration}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
