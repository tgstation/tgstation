import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

const DISEASE_THEASHOLD_LIST = [
  'Positive',
  'Harmless',
  'Minor',
  'Medium',
  'Harmful',
  'Dangerous',
  'BIOHAZARD',
];

const TARGET_NUTRITION_LIST = [
  {
    name: 'Starving',
    value: 150,
  },
  {
    name: 'Obese',
    value: 600,
  },
];

export const ScannerGate = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={400} height={300}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox
          onLockedStatusChange={() => act('toggle_lock')}
        />
        {!data.locked && <ScannerGateControl />}
      </Window.Content>
    </Window>
  );
};

const SCANNER_GATE_ROUTES = {
  Off: {
    title: 'Scanner Mode: Off',
    component: () => ScannerGateOff,
  },
  Wanted: {
    title: 'Scanner Mode: Wanted',
    component: () => ScannerGateWanted,
  },
  Guns: {
    title: 'Scanner Mode: Guns',
    component: () => ScannerGateGuns,
  },
  Mindshield: {
    title: 'Scanner Mode: Mindshield',
    component: () => ScannerGateMindshield,
  },
  Disease: {
    title: 'Scanner Mode: Disease',
    component: () => ScannerGateDisease,
  },
  Species: {
    title: 'Scanner Mode: Species',
    component: () => ScannerGateSpecies,
  },
  Nutrition: {
    title: 'Scanner Mode: Nutrition',
    component: () => ScannerGateNutrition,
  },
};

const ScannerGateControl = (props) => {
  const { act, data } = useBackend();
  const { scan_mode } = data;
  const route = SCANNER_GATE_ROUTES[scan_mode] || SCANNER_GATE_ROUTES.off;
  const Component = route.component();
  return (
    <Section
      title={route.title}
      buttons={
        scan_mode !== 'Off' && (
          <Button
            icon="arrow-left"
            content="back"
            onClick={() => act('set_mode', { new_mode: 'Off' })}
          />
        )
      }
    >
      <Component />
    </Section>
  );
};

const ScannerGateOff = (props) => {
  const { act, data } = useBackend();
  return (
    <>
      <Box mb={2}>Select a scanning mode below.</Box>
      <Box>
        <Button
          content="Wanted"
          onClick={() => act('set_mode', { new_mode: 'Wanted' })}
        />
        <Button
          content="Guns"
          onClick={() => act('set_mode', { new_mode: 'Guns' })}
        />
        <Button
          content="Mindshield"
          onClick={() => act('set_mode', { new_mode: 'Mindshield' })}
        />
        <Button
          content="Disease"
          onClick={() => act('set_mode', { new_mode: 'Disease' })}
        />
        <Button
          content="Species"
          onClick={() => act('set_mode', { new_mode: 'Species' })}
        />
        <Button
          content="Nutrition"
          onClick={() => act('set_mode', { new_mode: 'Nutrition' })}
        />
      </Box>
    </>
  );
};

const ScannerGateWanted = (props) => {
  const { data } = useBackend();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Trigger if the person scanned {reverse ? 'does not have' : 'has'} any
        warrants for their arrest.
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateGuns = (props) => {
  const { data } = useBackend();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Trigger if the person scanned {reverse ? 'does not have' : 'has'} any
        guns.
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateMindshield = (props) => {
  const { data } = useBackend();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Trigger if the person scanned {reverse ? 'does not have' : 'has'} a
        mindshield.
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateDisease = (props) => {
  const { act, data } = useBackend();
  const { reverse, disease_threshold } = data;
  return (
    <>
      <Box mb={2}>
        Trigger if the person scanned {reverse ? 'does not have' : 'has'} a
        disease equal or worse than {disease_threshold}.
      </Box>
      <Box mb={2}>
        {DISEASE_THEASHOLD_LIST.map((threshold) => (
          <Button.Checkbox
            key={threshold}
            checked={threshold === disease_threshold}
            content={threshold}
            onClick={() =>
              act('set_disease_threshold', {
                new_threshold: threshold,
              })
            }
          />
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateSpecies = (props) => {
  const { act, data } = useBackend();
  const { reverse, target_species_id, available_species, target_zombie } = data;
  const species = available_species.find((species) => {
    return species.specie_id === target_species_id;
  });
  return (
    <>
      <Box mb={2}>
        Trigger if the person scanned is {reverse ? 'not' : ''} of the{' '}
        {species.specie_name} species.
        {target_zombie
          ? ' All zombie types will be detected, including dormant zombies.'
          : null}
      </Box>
      <Box mb={2}>
        {available_species.map((species) => (
          <Button.Checkbox
            key={species.specie_id}
            checked={species.specie_id === target_species_id}
            onClick={() =>
              act('set_target_species', {
                new_species_id: species.specie_id,
              })
            }
          >
            {species.specie_name}
          </Button.Checkbox>
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateNutrition = (props) => {
  const { act, data } = useBackend();
  const { reverse, target_nutrition } = data;
  const nutrition = TARGET_NUTRITION_LIST.find((nutrition) => {
    return nutrition.value === target_nutrition;
  });
  return (
    <>
      <Box mb={2}>
        Trigger if the person scanned {reverse ? 'does not have' : 'has'} the{' '}
        {nutrition.name} nutrition level.
      </Box>
      <Box mb={2}>
        {TARGET_NUTRITION_LIST.map((nutrition) => (
          <Button.Checkbox
            key={nutrition.name}
            checked={nutrition.value === target_nutrition}
            content={nutrition.name}
            onClick={() =>
              act('set_target_nutrition', {
                new_nutrition: nutrition.name,
              })
            }
          />
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateMode = (props) => {
  const { act, data } = useBackend();
  const { reverse } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Scanning Mode">
        <Button
          content={reverse ? 'Inverted' : 'Default'}
          icon={reverse ? 'random' : 'long-arrow-alt-right'}
          onClick={() => act('toggle_reverse')}
          color={reverse ? 'bad' : 'good'}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
