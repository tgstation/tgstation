import { act } from '../byond';
import { Fragment } from 'inferno';
import { Box, LabeledList, NumberInput, Button, Section } from '../components';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

const DISEASE_THEASHOLD_LIST = [
  "Positive",
  "Harmless",
  "Minor",
  "Medium",
  "Harmful",
  "Dangerous",
  "BIOHAZARD",
];

const TARGET_SPECIES_LIST = [
  {
    name: "Human",
    value: "human",
  },
  {
    name: "Lizardperson",
    value: "lizard",
  },
  {
    name: "Flyperson",
    value: "fly",
  },
  {
    name: "Felinid",
    value: "felinid",
  },
  {
    name: "Plasmaman",
    value: "plasma",
  },
  {
    name: "Mothperson",
    value: "moth",
  },
  {
    name: "Jellyperson",
    value: "jelly",
  },

  {
    name: "Podperson",
    value: "pod",
  },

  {
    name: "Golem",
    value: "golem",
  },

  {
    name: "Zombie",
    value: "zombie",
  },
];

const TARGET_NUTRITION_LIST = [
  {
    name: "Starving",
    value: 150,
  },
  {
    name: "Obese",
    value: 600,
  },
];

export const ScannerGate = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <InterfaceLockNoticeBox
        locked={data.locked}
        onLockedStatusChange={() => act(ref, 'toggle_lock')}
      />
      {!data.locked && (
        <ScannerGateControl state={state} />
      )}
    </Fragment>
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
  Nanites: {
    title: 'Scanner Mode: Nanites',
    component: () => ScannerGateNanites,
  },
};

const ScannerGateControl = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const route = SCANNER_GATE_ROUTES[data.scan_mode] || SCANNER_GATE_ROUTES.off;
  const Component = route.component();

  return (
    <Section
      title={route.title}
      buttons={data.scan_mode !== 'Off' && (
        <Button
          icon="arrow-left"
          content="back"
          onClick={() => act(ref, 'set_mode', { new_mode: "Off" })}
        />
      )}>
      <Component state={state} />
    </Section>
  );
};

const ScannerGateOff = props => {
  const { state } = props;
  const { config } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Box mb={2}>
        Select a scanning mode below.
      </Box>
      <Box>
        <Button
          content="Wanted"
          onClick={() => act(ref, 'set_mode', { new_mode: "Wanted" })}
        />
        <Button
          content="Guns"
          onClick={() => act(ref, 'set_mode', { new_mode: "Guns" })}
        />
        <Button
          content="Mindshield"
          onClick={() => act(ref, 'set_mode', { new_mode: "Mindshield" })}
        />
        <Button
          content="Disease"
          onClick={() => act(ref, 'set_mode', { new_mode: "Disease" })}
        />
        <Button
          content="Species"
          onClick={() => act(ref, 'set_mode', { new_mode: "Species" })}
        />
        <Button
          content="Nutrition"
          onClick={() => act(ref, 'set_mode', { new_mode: "Nutrition" })}
        />
        <Button
          content="Nanites"
          onClick={() => act(ref, 'set_mode', { new_mode: "Nanites" })}
        />
      </Box>
    </Fragment>
  );
};

const ScannerGateWanted = props => {
  const { state } = props;
  const { data } = state;

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned {data.reverse ? "does not have" : "has"} any warrants for their arrest.
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateGuns = props => {
  const { state } = props;
  const { data } = state;

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned {data.reverse ? "does not have" : "has"} any guns.
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateMindshield = props => {
  const { state } = props;
  const { data } = state;

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned {data.reverse ? "does not have" : "has"} a mindshield.
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateDisease = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned {data.reverse ? "does not have" : "has"} a disease equal or worse
      than {data.disease_threshold}.
      </Box>
      <Box mb={2}>
        {DISEASE_THEASHOLD_LIST.map(threshold => (
          <Button
            key={threshold}
            selected={threshold === data.disease_threshold}
            content={threshold}
            onClick={() => act(ref, 'set_disease_threshold', { new_threshold: threshold })}
          />
        ))}
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateSpecies = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  let species_name;
  for (let i = 0; i < TARGET_SPECIES_LIST.length; i++) {
    if (TARGET_SPECIES_LIST[i].value === data.target_species) {
      species_name = TARGET_SPECIES_LIST[i].name;
      break;
    }
  }

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned is {data.reverse ? "not" : ""} of the {species_name} species.
        {data.target_species === "zombie" && (
          " All zombie types will be detected, including dormant zombies."
        )}
      </Box>
      <Box mb={2}>
        {TARGET_SPECIES_LIST.map(species => (
          <Button
            key={species.value}
            selected={species.value === data.target_species}
            content={species.name}
            onClick={() => act(ref, 'set_target_species', { new_species: species.value })}
          />
        ))}
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateNutrition = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  let nutrition_name;
  for (let i = 0; i < TARGET_NUTRITION_LIST.length; i++) {
    if (TARGET_NUTRITION_LIST[i].value === data.target_nutrition) {
      nutrition_name = TARGET_NUTRITION_LIST[i].name;
      break;
    }
  }

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned {data.reverse ? "does not have" : "has"} the {nutrition_name} nutrition level.
      </Box>
      <Box mb={2}>
        {TARGET_NUTRITION_LIST.map(nutrition => (
          <Button
            key={nutrition.name}
            selected={nutrition.value === data.target_nutrition}
            content={nutrition.name}
            onClick={() => act(ref, 'set_target_nutrition', { new_nutrition: nutrition.name })}
          />
        ))}
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateNanites = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Box mb={2}>
      Trigger if the person scanned {data.reverse ? "does not have" : "has"} the nanite cloud id: {data.nanite_cloud}.
      </Box>
      <Box mb={2}>
        <LabeledList>
          <LabeledList.Item label="Cloud ID">
            <NumberInput
              value={data.nanite_cloud}
              width="65px"
              minValue={1}
              maxValue={100}
              stepPixelSize={2}
              onChange={(e, value) => act(ref, 'set_nanite_cloud', { new_cloud: value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Box>
      <ScannerGateMode state={state} />
    </Fragment>
  );
};

const ScannerGateMode = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <LabeledList>
      <LabeledList.Item label="Scanning Mode">
        <Button
          content={data.reverse ? "Inverted" : "Default"}
          onClick={() => act(ref, 'toggle_reverse')}
          color={data.reverse ? "bad" : "good"}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
