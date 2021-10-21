import { useBackend } from '../backend';
import { Button, Box, NumberInput, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const ChemorecepticMicrolaser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    use_effect,
    stealth,
    scanmode,
    intensity,
    wavelength,
    on_cooldown,
    cooldown,
  } = data;
  return (
    <Window
      title="Chemoreceptic Microlaser"
      width={320}
      height={335}
      theme="syndicate">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Laser Status">
              <Box color={on_cooldown ? "average" : "good"}>
                {on_cooldown ? "Recharging" : "Ready"}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Scanner Controls">
          <LabeledList>
            <LabeledList.Item label="Chemoreception">
              <Button
                icon={use_effect ? 'power-off' : 'times'}
                content={use_effect ? 'On' : 'Off'}
                selected={use_effect}
                onClick={() => act('use_effect')} />
            </LabeledList.Item>
            <LabeledList.Item label="Stealth Mode">
              <Button
                icon={stealth ? 'eye-slash' : 'eye'}
                content={stealth ? 'On' : 'Off'}
                disabled={!use_effect}
                selected={stealth}
                onClick={() => act('stealth')} />
            </LabeledList.Item>
            <LabeledList.Item label="Scan Mode">
              <Button
                icon={scanmode ? 'mortar-pestle' : 'heartbeat'}
                content={scanmode ? 'Scan Reagents' : 'Scan Health'}
                disabled={use_effect && stealth}
                onClick={() => act('scanmode')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Laser Settings">
          <LabeledList>
            <LabeledList.Item label="Intensity">
              <Button
                icon="fast-backward"
                onClick={() => act('intensity', { adjust: -5 })} />
              <Button
                icon="backward"
                onClick={() => act('intensity', { adjust: -1 })} />
              {' '}
              <NumberInput
                value={Math.round(intensity)}
                width="40px"
                minValue={1}
                maxValue={10}
                onChange={(e, value) => {
                  return act('intensity', {
                    target: value,
                  });
                }} />
              {' '}
              <Button
                icon="forward"
                onClick={() => act('intensity', { adjust: 1 })} />
              <Button
                icon="fast-forward"
                onClick={() => act('intensity', { adjust: 5 })} />
            </LabeledList.Item>
            <LabeledList.Item label="Wavelength">
              <Button
                icon="fast-backward"
                onClick={() => act('wavelength', { adjust: -5 })} />
              <Button
                icon="backward"
                onClick={() => act('wavelength', { adjust: -1 })} />
              {' '}
              <NumberInput
                value={Math.round(wavelength)}
                width="40px"
                minValue={0}
                maxValue={120}
                onChange={(e, value) => {
                  return act('wavelength', {
                    target: value,
                  });
                }} />
              {' '}
              <Button
                icon="forward"
                onClick={() => act('wavelength', { adjust: 1 })} />
              <Button
                icon="fast-forward"
                onClick={() => act('wavelength', { adjust: 5 })} />
            </LabeledList.Item>
            <LabeledList.Item label="Laser Cooldown">
              <Box inline bold>
                {cooldown}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
