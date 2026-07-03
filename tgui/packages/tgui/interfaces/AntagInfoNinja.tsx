import { Icon, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const ninja_emphasis = {
  color: 'red',
};

type NinjaInfo = {
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

export const AntagInfoNinja = (props) => {
  const { data } = useBackend<NinjaInfo>();
  const { objectives, can_change_objective } = data;
  return (
    <Window width={550} height={450} theme="hackerman">
      <Window.Content>
        <Icon
          size={30}
          name="spider"
          color="#003300"
          position="absolute"
          top="10%"
          left="10%"
        />
        <Section scrollable fill>
          <Stack vertical textColor="green">
            <Stack.Item textAlign="center" fontSize="20px">
              Я элитный наёмник клана Паука.
              <br />
              <span style={ninja_emphasis}> КОСМИЧЕСКИЙ НИНДЗЯ</span>!
            </Stack.Item>
            <Stack.Item textAlign="center" italic>
              Неожиданность - мое оружие. Тень - моя броня. Без них, Я - ничто.
            </Stack.Item>
            <Stack.Item>
              <Section fill>
                Ваш продвинутый костюм ниндзи содержит множество продвинутых
                модулей.
                <br /> Его можно зарядить, нажав ПКМ по станционным ЛКП или
                другим источникам энергии, чтобы выкачать энергию из них.
                <br />
                ПКМ по некоторым видам техники или предметам при активированном
                костюме, взломает их, с различными эффектами. Экспериментируйте
                и узнайте, на что вы способны! Хаджимимаште.
              </Section>
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout
                objectives={objectives}
                objectiveFollowup={
                  <ReplaceObjectivesButton
                    can_change_objective={can_change_objective}
                    button_title={'Адаптировать параметры миссии'}
                    button_colour={'green'}
                  />
                }
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
