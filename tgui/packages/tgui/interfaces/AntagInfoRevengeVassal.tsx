import { useState } from 'react';
import {
  Button,
  Divider,
  Dropdown,
  Image,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

type BloodsuckerInformation = {
  power: PowerInfo[];
};

type PowerInfo = {
  power_name: string;
  power_explanation: string;
  power_icon: string;
};

type Info = {
  objectives: Objective[];
};

const ObjectivePrintout = (props: any) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Ваши текщие задачи:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoRevengeVassal = (props: any) => {
  return (
    <Window width={620} height={300}>
      <Window.Content>
        <VassalInfo />
      </Window.Content>
    </Window>
  );
};

const VassalInfo = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="20rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Вы подданый, задача которого отомстить за смерть своего мастера!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill>
          <Stack vertical>
            <Stack.Item>
              <span>
                Вы получили старые силы Мастера, и новые силы. Вам придется
                выжить и сохранить старую целостность Мастера. Верните старых
                вассалов обратно используя свою новую Способность.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <PowerSection />
      </Stack.Item>
    </Stack>
  );
};

const PowerSection = (props: any) => {
  const { act, data } = useBackend<BloodsuckerInformation>();
  const { power } = data;
  if (!power) {
    return <Section minHeight="220px" />;
  }

  const [selectedPower, setSelectedPower] = useState(power[0]);

  return (
    <Section
      fill
      scrollable={!!power}
      title="Силы"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={'Выберете силу для объяснения.'}
        />
      }
    >
      <Stack>
        <Stack.Item grow>
          <Dropdown
            displayText={selectedPower.power_name}
            selected={selectedPower.power_name}
            width="100%"
            options={power.map((powers) => powers.power_name)}
            onSelected={(powerName: string) =>
              setSelectedPower(
                power.find((p) => p.power_name === powerName) || power[0],
              )
            }
          />
          {selectedPower && (
            <Image
              position="absolute"
              height="12rem"
              src={resolveAsset(`bloodsucker.${selectedPower.power_icon}.png`)}
            />
          )}
          <Divider />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={1} fontSize="16px">
          {selectedPower && selectedPower.power_explanation}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
