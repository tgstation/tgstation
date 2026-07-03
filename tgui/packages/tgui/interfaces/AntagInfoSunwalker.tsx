import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoSunwalker = (props) => {
  return (
    <Window width={660} height={300}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="40%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">Вы - Санволкер</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    Вы древний войдволкер, попавший в ловушку
                    сверхновой. Вы изменились и полны ненависти.
                  </BlockQuote>
                  <BlockQuote>
                    Не будет ни уроков, ни просветления, они не выживут
                    чтобы извлечь из этого урок.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="60%">
            <Section fill title="Способности">
              <LabeledList>
                <LabeledList.Item label="Space Dive">
                  Вы можете перемещаться под станцией по космосу, используйте
                  это для охоты и проникновения в изолированные участки космоса.
                </LabeledList.Item>
                <LabeledList.Item label="Burning Slash">
                  Ваши атаки наносят большой ожоговый урон
                  и поджигают пораженных.
                </LabeledList.Item>
                <LabeledList.Item label="Burning Physiology">
                  Сама ваша кожа нагревает воздух вокруг вас, в то время как
                  вакуум космоса заживляет любые раны, которые могли быть
                  нанесены вашему телу. Вы можете свободно проходить сквозь
                  стекло, но замедляетесь из-за гравитации.
                </LabeledList.Item>
                <LabeledList.Item label="Stellar Charge">
                  С огромной взрывающейся горящей скоростью мчитесь вперёд,
                  нанося урон и сжигая всё вокруг себя.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
