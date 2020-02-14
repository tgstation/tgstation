import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Box, Section, LabeledList } from '../components';

export const RadioactiveMicrolaser = props => {
  const { act, data } = useBackend(props);
  const {
    irradiate,
    stealth,
    scanmode,
    intensity,
    wavelength,
    on_cooldown,
    cooldown,
  } = data;
  return (
    <Fragment>
      <Section>
        <LabeledList.Item label="Laser Status">
          <Box color={on_cooldown ? "bad" : "average"}>
            {on_cooldown ? "Ready" : "Recharging"}
          </Box>
        </LabeledList.Item>
      </Section>
      <Section title="Scanner Controls">
        <LabeledList>
          <LabeledList.Item label="Irradiation">
            <Button
              icon={irradiate ? 'power-off' : 'times'}
              content={irradiate ? 'On' : 'Off'}
              selected={irradiate}
              onClick={() => act('irradiate')} />
          </LabeledList.Item>
          <LabeledList.Item label="Stealth Mode">
            <Button
              icon={stealth ? 'eye-slash' : 'eye'}
              content={stealth ? 'On' : 'Off'}
              disabled={!irradiate}
              selected={stealth}
              onClick={() => act('stealth')} />
          </LabeledList.Item>
          <LabeledList.Item label="Scan Mode">
            <Button
              icon={scanmode ? 'mortar-pestle' : 'heartbeat'}
              content={scanmode ? 'Scan Reagents' : 'Scan Health'}
              disabled={irradiate && stealth}
              onClick={() => act('scanmode')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Laser Settings">
        <LabeledList>
          <LabeledList.Item label="Radiation Intensity">
            <Button
              icon="fast-backward"
              disabled={on_cooldown}
              onClick={() => act('radintensity', { adjust: -5 })} />
            <Button
              icon="backward"
              disabled={on_cooldown}
              onClick={() => act('radintensity', { adjust: -1 })} />
            {' '}
            {String(intensity).padStart(2, '0')}
            {' '}
            <Button
              icon="forward"
              disabled={on_cooldown}
              onClick={() => act('radintensity', { adjust: 1 })} />
            <Button
              icon="fast-forward"
              disabled={on_cooldown}
              onClick={() => act('radintensity', { adjust: 5 })} />
          </LabeledList.Item>
          <LabeledList.Item label="Radiation Wavelength">
            <Button
              icon="fast-backward"
              disabled={on_cooldown}
              onClick={() => act('radwavelength', { adjust: -5 })} />
            <Button
              icon="backward"
              disabled={on_cooldown}
              onClick={() => act('radwavelength', { adjust: -1 })} />
            {' '}
            {String(wavelength).padStart(3, '0')}
            {' '}
            <Button
              icon="forward"
              disabled={on_cooldown}
              onClick={() => act('radwavelength', { adjust: 1 })} />
            <Button
              icon="fast-forward"
              disabled={on_cooldown}
              onClick={() => act('radwavelength', { adjust: 5 })} />
          </LabeledList.Item>
          <LabeledList.Item label="Laser Cooldown">
            <Box inline bold>
              {cooldown}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
