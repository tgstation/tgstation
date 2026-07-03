import { useState } from 'react';
import {
  Button,
  Dimmer,
  Dropdown,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const hivestyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const hivemindstyle = {
  color: 'violet',
  fontWeight: 'bold',
};

const fallenstyle = {
  color: 'black',
  fontWeight: 'bold',
};

type Memory = {
  name: string;
  story: string;
};

type Info = {
  true_name: string;
  hive_name: string;
  stolen_antag_info: string;
  memories: Memory[];
  objectives: Objective[];
  can_change_objective: BooleanLike;
  absorbed_dna: number;
};

export const AntagInfoChangeling = (props) => {
  return (
    <Window width={720} height={750}>
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item maxHeight={16}>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
          <BetrayalWarning />
          <Stack.Item grow={3}>
            <Stack fill>
              <Stack.Item grow>
                <MemoriesSection />
              </Stack.Item>
              <Stack.Item grow>
                <VictimPatternsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionSection = (props) => {
  const { act, data } = useBackend<Info>();
  const {
    true_name,
    hive_name,
    objectives,
    can_change_objective,
    absorbed_dna,
  } = data;
  return (
    <Section
      fill
      title="Intro"
      style={{ overflowY: 'auto' }}
      buttons={
        <Button
          icon="dna"
          tooltipPosition="left"
          tooltip={`Absorbed DNA`}
          color="purple"
        >
          {absorbed_dna}
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          Вы {true_name} из
          <span style={hivestyle}> {hive_name}</span>.
        </Stack.Item>
        <Stack.Item>
          <ObjectivePrintout
            objectives={objectives}
            objectiveFollowup={
              <ReplaceObjectivesButton
                can_change_objective={can_change_objective}
                button_title={'Развить новые директивы'}
                button_colour={'green'}
              />
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = () => {
  const { act, data } = useBackend<Info>();
  const { true_name } = data;
  return (
    <Section fill title="Способности">
      <Stack fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Ваша способность<span style={absorbstyle}>&ensp;Absorb DNA</span>{' '}
              позволяет вам украсть ДНК и воспоминания жертвы. Способность
              <span style={absorbstyle}>&ensp;Extract DNA Sting</span> также
              крадет ДНК жертвы и не поддается обнаружению, но не дает вам их
              воспоминаний или образцов речи.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              Ваша способность
              <span style={revivestyle}>&ensp;Reviving Stasis </span>
              позволяет вам возродиться. Это значит, что ничто, кроме полного
              разрушения тела, не сможет остановить вас! Разумеется, это громко,
              поэтому не стоит делать это в присутствии людей, которых вы не
              собираетесь заткнуть.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Ваша способность
              <span style={transformstyle}>&ensp;Transform</span> позволяет вам
              превратиться в форму тех, у кого вы собрали ДНК, летально и
              нелетально. Он также будет имитировать (НЕ НАСТОЯЩУЮ ОДЕЖДУ)
              одежду, в которую они были одеты, для каждого вашего свободного
              слота.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              <span style={storestyle}>&ensp;Cellular Emporium</span> это место,
              где вы приобретаете новые способности, помимо стартового набора. У
              вас есть 10 генетических очков, которые вы можете потратить на
              способности, и вы можете реадаптироваться после поглощения тела,
              возвращая свои очки для разных наборов.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              All abilities require using{' '}
              <span style={hivemindstyle}>chemicals</span>, you can see how much
              you have with the HUD on the left side of the screen. You may also
              hover your cursor over it to see the maximum amount of chemicals
              you can hold. This number can increase by
              <span style={absorbstyle}>&ensp;absorbing</span> other
              Changelings.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              All Changelings, regardless of origin, are linked together by the{' '}
              <span style={hivemindstyle}>hivemind</span>. You may communicate
              to other Changelings under your mental alias,{' '}
              <span style={hivemindstyle}>{true_name}</span>, by starting a
              message with <span style={hivemindstyle}>:g</span>. Work together,
              and you will bring the station to new heights of terror.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BetrayalWarning = (props) => {
  return (
    <NoticeBox danger>
      Other Changelings are strong allies, but some Changelings may betray you.
      Changelings grow in power greatly by absorbing their kind, and getting
      absorbed by another Changeling will leave you as a{' '}
      <span style={fallenstyle}>Fallen Changeling</span>. There is no greater
      humiliation.
    </NoticeBox>
  );
};

const MemoriesSection = (props) => {
  const { data } = useBackend<Info>();
  const { memories } = data;
  const [selectedMemory, setSelectedMemory] = useState(
    (!!memories && memories[0]) || null,
  );
  const memoryMap = {};
  for (const index in memories) {
    const memory = memories[index];
    memoryMap[memory.name] = memory;
  }

  return (
    <Section
      fill
      scrollable={!!memories && !!memories.length}
      title="Украденные воспоминания"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={`
            Поглощая цели, вы можете
            получить их воспоминания. Они должны
            помочь вам выдать себя за свою цель!
          `}
        />
      }
    >
      {(!!memories && !memories.length && (
        <Dimmer fontSize="20px">Сначала поглотите жертву!</Dimmer>
      )) || (
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              selected={selectedMemory?.name}
              options={memories.map((memory) => {
                return memory.name;
              })}
              onSelected={(selected) => setSelectedMemory(memoryMap[selected])}
            />
          </Stack.Item>
          <Stack.Item>{!!selectedMemory && selectedMemory.story}</Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const VictimPatternsSection = (props) => {
  const { data } = useBackend<Info>();
  const { stolen_antag_info } = data;
  return (
    <Section
      fill
      scrollable={!!stolen_antag_info}
      title="Дополнительная украденная информация"
    >
      {(!!stolen_antag_info && stolen_antag_info) || (
        <Dimmer fontSize="20px">Сначала поглотите жертву!</Dimmer>
      )}
    </Section>
  );
};
