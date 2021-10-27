import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Input,
  Collapsible,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type PandemicContext = {
  beaker_empty: number;
  blood: Blood;
  has_beaker: number;
  has_blood: number;
  is_ready: number;
  resistances: Resistance[];
  viruses: Virus[];
};

type Blood = {
  dna: string;
  type: string;
};

type Resistance = {
  id: string;
  name: string;
};

type Virus = {
  name: string;
  can_rename: number;
  is_adv: number;
  symptoms: Symptom[];
  resistance: number;
  stealth: number;
  stage_speed: number;
  transmission: number;
  index: number;
  agent: string;
  description: string;
  spread: string;
  cure: string;
};

type VirusInfoProps = {
  virus: Virus;
};

type Symptom = {
  name: string;
  desc: string;
  stealth: number;
  resistance: number;
  stage_speed: number;
  transmission: number;
  level: number;
  neutered: number;
  threshold_desc: Threshold[];
};

type SymptomDisplayProps = {
  symptoms: Symptom[];
};

type Threshold = {
  label: string;
  descr: string;
};

export const Pandemic = (props, context) => {
  const { data } = useBackend<PandemicContext>(context);
  const { has_blood } = data;
  return (
    <Window width={650} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BeakerDisplay />
          </Stack.Item>
          {!!has_blood && (
            <>
              <Stack.Item>
                <AntibodyDisplay />
              </Stack.Item>
              <Stack.Item grow>
                <SpecimenDisplay />
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BeakerDisplay = (props, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const { has_beaker, beaker_empty, has_blood, blood, resistances } = data;
  const cant_empty = !has_beaker || beaker_empty;

  return (
    <Section
      title="Beaker"
      buttons={
        <>
          <Button
            icon="times"
            content="Empty and Eject"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          />
          <Button
            icon="trash"
            content="Empty"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          />
          <Button
            icon="eject"
            content="Eject"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          />
        </>
      }>
      {has_beaker ? (
        !beaker_empty ? (
          has_blood ? (
            <LabeledList>
              <LabeledList.Item label="DNA">
                {blood.dna.replace(/^\w/, (c) => c.toUpperCase())}
              </LabeledList.Item>
              <LabeledList.Item label="Type">
                {blood.type.replace(/^\w/, (c) => c.toUpperCase())}
              </LabeledList.Item>
              <LabeledList.Item label="Antibodies">
                {!resistances.length ? (
                  'None'
                ) : (
                  <Stack>
                    {resistances.map((resistance) => {
                      return (
                        <Stack.Item key={resistance.name}>
                          <Box color="green">{resistance.name}</Box>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                )}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <NoticeBox>No blood detected</NoticeBox>
          )
        ) : (
          <NoticeBox>Beaker is empty</NoticeBox>
        )
      ) : (
        <NoticeBox>No beaker loaded</NoticeBox>
      )}
    </Section>
  );
};

const SpecimenDisplay = (props, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 0);
  const { viruses } = data;
  const virus = viruses[tab];

  return !viruses.length ? (
    <NoticeBox>No viruses detected</NoticeBox>
  ) : (
    <Section
      fill
      scrollable
      title="Specimen"
      buttons={
        <Stack>
          {
            // Tabs if there's more viruses
            viruses.length > 1 && (
              <Stack.Item>
                <Tabs>
                  {viruses.map((virus, index) => {
                    return (
                      <Tabs.Tab
                        selected={tab === index}
                        onClick={() => setTab(index)}
                        key={virus.name}>
                        {virus.name}
                      </Tabs.Tab>
                    );
                  })}
                </Tabs>
              </Stack.Item>
            )
          }
          <Stack.Item>
            <Button
              icon="flask"
              content="Create culture bottle"
              disabled={!data.is_ready}
              onClick={() =>
                act('create_culture_bottle', {
                  index: virus.index,
                })
              }
            />
          </Stack.Item>
        </Stack>
      }>
      <Stack fill vertical>
        <Stack.Item>
          <VirusInfoDisplay virus={virus} />
        </Stack.Item>
        <Stack.Item>
          <SymptomDisplay symptoms={virus.symptoms} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const VirusInfoDisplay = (props: VirusInfoProps, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const { virus } = props;
  return (
    <Stack fill>
      <Stack.Item grow={3}>
        <LabeledList>
          <LabeledList.Item label="Name">
            {virus.can_rename ? (
              <Input
                value={virus.name}
                onChange={(e, value) =>
                  act('rename_disease', {
                    index: virus.index,
                    name: value,
                  })
                }
              />
            ) : (
              <Box color="bad">{virus.name}</Box>
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Description">
            {virus.description}
          </LabeledList.Item>
          <LabeledList.Item label="Agent">
            {virus.agent.replace(/^\w/, (c) => c.toUpperCase())}
          </LabeledList.Item>
          <LabeledList.Item label="Spread">{virus.spread}</LabeledList.Item>
          <LabeledList.Item label="Possible Cure">
            {virus.cure}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      {!!virus.is_adv && (
        <>
          <Stack.Divider />
          <Stack.Item grow={1}>
            <Section level={2} title="Statistics">
              <LabeledList>
                <Tooltip content="Decides the cure complexity.">
                  <LabeledList.Item
                    color={GetColor(virus.resistance)}
                    label="Resistance">
                    {virus.resistance}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content="Symptomic progression.">
                  <LabeledList.Item
                    color={GetColor(virus.stage_speed)}
                    label="Stage speed">
                    {virus.stage_speed}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content="Detection difficulty from medical equipment.">
                  <LabeledList.Item
                    color={GetColor(virus.stealth)}
                    label="Stealth">
                    {virus.stealth}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content="Decides the spread type.">
                  <LabeledList.Item
                    color={GetColor(virus.transmission)}
                    label="Transmissibility">
                    {virus.transmission}
                  </LabeledList.Item>
                </Tooltip>
              </LabeledList>
            </Section>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

const SymptomDisplay = (props: SymptomDisplayProps, context) => {
  const { data } = useBackend<PandemicContext>(context);
  const { symptoms } = props;
  return (
    symptoms.length && (
      <Section fill level={2} title="Symptoms">
        {symptoms.map((symptom) => {
          return (
            <Collapsible
              key={symptom.name}
              title={
                !symptom.neutered ? symptom.name : `${symptom.name} (Neutered)`
              }>
              <Stack fill>
                <Stack.Item grow={3}>
                  {symptom.desc}
                  <Section level={3} mt={1} title="Thresholds">
                    <LabeledList>
                      {Object.entries(symptom.threshold_desc).map((label) => {
                        return (
                          <LabeledList.Item key={label} label={label[0]}>
                            {label[1]}
                          </LabeledList.Item>
                        );
                      })}
                    </LabeledList>
                  </Section>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item grow={1}>
                  <Section level={2} title="Modifiers">
                    <LabeledList>
                      <Tooltip content="Rarity of the symptom.">
                        <LabeledList.Item
                          color={GetColor(symptom.level)}
                          label="Level">
                          {symptom.level}
                        </LabeledList.Item>
                      </Tooltip>
                      <Tooltip content="Decides the cure complexity.">
                        <LabeledList.Item
                          color={GetColor(symptom.resistance)}
                          label="Resistance">
                          {symptom.resistance}
                        </LabeledList.Item>
                      </Tooltip>
                      <Tooltip content="Symptomic progression.">
                        <LabeledList.Item
                          color={GetColor(symptom.stage_speed)}
                          label="Stage Speed">
                          {symptom.stage_speed}
                        </LabeledList.Item>
                      </Tooltip>
                      <Tooltip content="Detection difficulty from medical equipment.">
                        <LabeledList.Item
                          color={GetColor(symptom.stealth)}
                          label="Stealth">
                          {symptom.stealth}
                        </LabeledList.Item>
                      </Tooltip>
                      <Tooltip content="Decides the spread type.">
                        <LabeledList.Item
                          color={GetColor(symptom.transmission)}
                          label="Transmission">
                          {symptom.transmission}
                        </LabeledList.Item>
                      </Tooltip>
                    </LabeledList>
                  </Section>
                </Stack.Item>
              </Stack>
            </Collapsible>
          );
        })}
      </Section>
    )
  );
};

const AntibodyDisplay = (props, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const { resistances } = data;
  return (
    !!resistances.length && (
      <Section scrollable level={2} title="Available Vaccines">
        {!resistances.length
          ? 'None'
          : resistances.map((resistance) => {
              return (
                <Button
                  key={resistance.name}
                  icon="eye-dropper"
                  disabled={!data.is_ready}
                  tooltip="Creates a vaccine bottle."
                  onClick={() =>
                    act('create_vaccine_bottle', {
                      index: resistance.id,
                    })
                  }>
                  {`Create ${resistance.name} vaccine`}
                </Button>
              );
            })}
      </Section>
    )
  );
};

/** Gives a color gradient based on the severity of the symptom */
const GetColor = (severity: number) => {
  if (severity <= -10) {
    return 'blue';
  } else if (severity <= -5) {
    return 'darkturquoise';
  } else if (severity <= 0) {
    return 'green';
  } else if (severity <= 7) {
    return 'yellow';
  } else if (severity <= 13) {
    return 'orange';
  } else {
    return 'bad';
  }
};
