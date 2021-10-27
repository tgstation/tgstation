import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Input,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type PandemicContext = {
  beaker_empty: number;
  blood: {
    dna: string;
    type: string;
  };
  has_beaker: number;
  has_blood: number;
  is_ready: number;
  resistances: Resistance[];
  viruses: Virus[];
};

type Resistance = {
  id: string;
  name: string;
};

type Virus = {
  name: string;
  can_rename: number;
  is_adv: number;
  symptoms: Symptom;
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
  symptom: Symptom;
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
  threshold_desc: Threshold;
};

type Threshold = {
  [label: string]: [descr: string];
};

export const Pandemic = (props, context) => {
  const { data } = useBackend<PandemicContext>(context);
  return (
    <Window width={520} height={550}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BeakerDisplay />
          </Stack.Item>
          {!!data.has_blood && (
            <Stack.Item grow>
              <SpecimenDisplay />
              {/* <DiseaseDisplay />
              <AntibodyDisplay /> */}
            </Stack.Item>
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
              <LabeledList.Item label="DNA">{blood.dna}</LabeledList.Item>
              <LabeledList.Item label="Type">{blood.type}</LabeledList.Item>
              <LabeledList.Item label="Antibodies">
                {!resistances.length
                  ? 'None'
                  : resistances.map((resistance) => {
                      return `${resistance.name} `;
                    })}
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
  const { viruses } = data;
  const virus = viruses[0];

  return !viruses.length ? (
    <NoticeBox>No specimens detected</NoticeBox>
  ) : (
    <Section
      fill
      title={
        virus.can_rename ? (
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
          virus.name
        )
      }
      buttons={
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
      }>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Description">
              {virus.description}
            </LabeledList.Item>
            <LabeledList.Item label="Agent">{virus.agent}</LabeledList.Item>
            <LabeledList.Item label="Spread">{virus.spread}</LabeledList.Item>
            <LabeledList.Item label="Possible Cure">
              {virus.cure}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        {!!virus.is_adv && (
          <Stack.Item>
            <Section title="Statistics">
              <LabeledList>
                <LabeledList.Item label="Resistance">
                  {virus.resistance}
                </LabeledList.Item>
                <LabeledList.Item label="Stealth">
                  {virus.stealth}
                </LabeledList.Item>

                <LabeledList.Item label="Stage speed">
                  {virus.stage_speed}
                </LabeledList.Item>
                <LabeledList.Item label="Transmissibility">
                  {virus.transmission}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
