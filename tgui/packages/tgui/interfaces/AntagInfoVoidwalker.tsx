import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoVoidwalker = (props) => {
  return (
    <Window width={660} height={660}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">Вы - Войдволкер.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    Вы - существо из пустоты между звездами. Вас привлекли
                    радиосигналы, передаваемые этой станцией.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Выживайте:&ensp;</span>
                  Вы обладаете непревзойдённой свободой. Оставайтесь в космосе,
                  и никто не сможет остановить вас. Вы можете проходить сквозь
                  окна, так что держитесь рядом с ними, чтобы всегда иметь путь
                  к отступлению.
                  <br />
                  <br />
                  <span style={tipstyle}>Охотьтесь:&ensp;</span>
                  Выбирайте неравные схватки. Ищите невнимательных жертв и
                  атакуйте их тогда, когда они меньше всего ожидают.
                  <br />
                  <br />
                  <span style={tipstyle}>Похищайте:&ensp;</span>
                  Ваша способность «Unsettle» оглушает и истощает цели. Вырубите
                  их истощающим ударом, утащите в космос (или рвоту туманности)
                  и просветите их.
                  <br />
                  <br />
                  <span style={tipstyle}>Жатва:&ensp;</span>
                  Наши ученики регулярно извергают нашу сущность. Мы можем
                  воспользоваться этим, чтобы попасть туда, куда иначе не
                  смогли бы добраться, но при уходе вновь её поглощаем.
                  (Вы можете нырять в космическую рвоту.)
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section fill title="Способности">
              <LabeledList>
                <LabeledList.Item label="Space Dive">
                  Вы можете свободно перемещаться по космосу, используйте
                  это для охоты и проникновения в изолированные участки станции.
                </LabeledList.Item>
                <LabeledList.Item label="Draining Slash">
                  Вы вырываете дыхание прямо из лёгких противника и быстро
                  побеждаете даже самых сильных противников. Если же противник
                  сопротивляется, правым кликом можно нанести дополнительный
                  урон. Ваши руки сами по себе довольно примитивны и подходят
                  лишь для захвата предметов.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Physiology">
                  Ваша природная маскировка делает вас невидимым в космосе, а
                  также залечивает любые полученные ранения. Вы свободно
                  проходите сквозь стекло, но замедляетесь из-за гравитации.
                </LabeledList.Item>
                <LabeledList.Item label="Unsettle">
                  Нацельтесь на жертву, оставаясь лишь частично видимыми,
                  чтобы оглушить и ослабить ее, но при этом сообщив о своем
                  присутствии.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Dash">
                  Имея небольшой радиус действия и практически нулевой урон,
                  эта способность плохо подходит для атаки, зато отлично
                  помогает быстро отступить или сменить позицию.
                </LabeledList.Item>
                <LabeledList.Item label="Expand">
                  С каждым уроком, что мы преподаём, мы становимся сильнее. Мы
                  можем превращать стены в стекло, чтобы проникнуть ещё дальше.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
