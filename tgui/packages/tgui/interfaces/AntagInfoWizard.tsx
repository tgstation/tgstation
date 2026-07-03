import { Box, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const teleportstyle = {
  color: 'yellow',
};

const robestyle = {
  color: 'lightblue',
};

const destructionstyle = {
  color: 'red',
};

const defensestyle = {
  color: 'orange',
};

const transportstyle = {
  color: 'yellow',
};

const summonstyle = {
  color: 'cyan',
};

const ritualstyle = {
  color: 'violet',
};

const grandritualstyle = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

type GrandRitual = {
  remaining: number;
  next_area: string;
};

type Info = {
  objectives: Objective[];
  ritual: GrandRitual;
  can_change_objective: BooleanLike;
};

export const AntagInfoWizard = (props) => {
  const { data, act } = useBackend<Info>();
  const { ritual, objectives, can_change_objective } = data;

  return (
    <Window width={620} height={630} theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  Вы Космический волшебник!
                </Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout
                    objectives={objectives}
                    titleMessage="Федерация космических волшебников выдала вам следующие задачи:"
                    objectiveFollowup={
                      <ReplaceObjectivesButton
                        can_change_objective={can_change_objective}
                        button_title={'Declare Personal Quest'}
                        button_colour={'violet'}
                      />
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <RitualPrintout ritual={ritual} />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fill title="Книга заклинаний">
              <Stack vertical fill>
                <Stack.Item>
                  У вас есть книга заклинаний, привязанная к вам. Вы можете
                  использовать её, чтобы выбрать ваш магический арсенал.
                  <br />
                  <span style={destructionstyle}>
                    На странице смертоносности содержатся наступающие
                    заклинания, чтобы уничтожить ваших врагов.
                  </span>
                  <br />
                  <span style={defensestyle}>
                    На странице защиты содержатся защитные заклинания, чтобы
                    сохранить себя живым. Помните, что вы можете быть
                    могущественным, но вы все еще просто человек.
                  </span>
                  <br />
                  <span style={transportstyle}>
                    На странице передвижения содержатся заклинания мобильности,
                    очень важный аспект выживания и выполнения поставленных
                    задач.
                  </span>
                  <br />
                  <span style={summonstyle}>
                    На странице призывания содержатся заклинания призыва и
                    другие полезные заклинания для того, чтобы не сражаться в
                    одиночку. Осторожно, не все призванные вами находятся на
                    вашей стороне.
                  </span>
                  <br />
                  <span style={ritualstyle}>
                    На странице ритуалов есть мощные глобальные эффекты, которые
                    поставят станцию против самой себя. Имейте в виду, что они
                    либо дорогие, или просто для пафоса.
                  </span>
                </Stack.Item>
                <Stack.Item textColor="lightgreen">
                  (Если вы не знаете, что взять, или являетесь новичком в
                  Федерации, перейдите в секцию &quot;Наборы снаряжения,
                  одобренные волшебниками&quot;. Там вы найдете несколько
                  наборов, которые хорошо подходят для новых волшебников.)
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Разное снаряжение">
              <Stack>
                <Stack.Item>
                  <span style={teleportstyle}>Свиток телепортации:</span> 4
                  использования для телепортации, куда вы захотите. Вы не
                  сможете вернуться в логово, поэтому убедитесь, что у вас все
                  готово, перед отправкой.
                  <br />
                  <span style={robestyle}>Мантии волшебника:</span> Используется
                  для произношения большинства заклинаний. В вашей книге
                  заклинаний вы узнаете, какие заклинания нельзя использовать
                  без вашего одеяния.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section textAlign="center" textColor="red" fontSize="20px">
              Помните: Не забудьте подготовить свои заклинания.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RitualPrintout = (props: { ritual: GrandRitual }) => {
  const { ritual } = props;
  if (!ritual.next_area) {
    return null;
  }
  return (
    <Box>
      Кроме того, выполните{' '}
      <span style={grandritualstyle}>Великий ритуал </span>
      - вызывая ритуальный круг в нескольких центрах силы.
      <br />
      Вы должны завершить ритуал еще
      <span style={grandritualstyle}> {ritual.remaining}</span> раз.
      <br />
      Следующее место проведения ритуала -
      <span style={grandritualstyle}> {ritual.next_area}</span>.
    </Box>
  );
};
