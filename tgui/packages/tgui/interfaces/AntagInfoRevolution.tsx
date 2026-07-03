import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Objective } from './common/Objectives';

type Head = {
  name: string;
  role: string;
};

type Info = {
  antag_name: string;
  objectives: Objective[];
  leader: BooleanLike;
  code_phrases?: string[];
  code_responses?: string[];
  heads: Head[];
  lone_wolf: BooleanLike;
};

// Takes [a, b, c] and returns "a, b, and c"
function formatCodes(text: string[]) {
  if (text.length === 0) return '';
  if (text.length === 1) return text[0];
  if (text.length === 2) return `${text[0]} and ${text[1]}`;
  return `${text.slice(0, -1).join(', ')}, and ${text[text.length - 1]}`;
}

export const AntagInfoRevolution = () => {
  const { data } = useBackend<Info>();
  const { leader, code_phrases, code_responses, heads, lone_wolf } = data;
  return (
    <Window width={400} height={400}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="24px" textAlign="center">
              Viva la Revolution!
            </Stack.Item>
            <Stack.Item>
              {leader ? (
                <Stack vertical>
                  {lone_wolf ? (
                    <Stack.Item>
                      - Вы одинокий лидер революции. Рекомендуется действовать
                      быстро и решительно - когда революция станет достаточно
                      большой, будут назначены новые лидеры.
                    </Stack.Item>
                  ) : (
                    <Stack.Item>
                      - У революции несколько лидеров. Рекомендуется действовать
                      сообща и составить план ДО того, как вы начнете обращать
                      экипаж - раннее раскрытие может сильно навредить.
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    - Обращайте экипаж на свою сторону вспышкой - подойдет любая
                    вспышка.
                  </Stack.Item>
                  <Stack.Item>
                    - Щиты разума защищают от обращения. Их можно определить по
                    мигающей синей рамке вокруг иконки должности.
                  </Stack.Item>
                  <Stack.Item>
                    - Революция проиграна, если вы и все ваши лидеры будете
                    убиты или изгнаны. Не допустите этого!
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    - Помогайте своему делу. Не вредите своим товарищам по
                    борьбе за свободу.
                  </Stack.Item>
                  <Stack.Item>
                    - Вы можете узнать своих товарищей по красным значкам "R", а
                    лидеров - по синим значкам "R".
                  </Stack.Item>
                  <Stack.Item>
                    - Революция проиграна, если все ваши лидеры будут убиты или
                    изгнаны. Не допустите этого!
                  </Stack.Item>
                </Stack>
              )}
            </Stack.Item>
            {heads.length > 0 && (
              <>
                <Stack.Divider />
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item fontSize="16px" textAlign="center">
                      Вы должны убить или изгнать глав отделов:
                    </Stack.Item>
                    {heads.map((head, i) => (
                      <Stack.Item key={`head-${i}`}>
                        - {head.name}, {head.role}
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
              </>
            )}
            {code_phrases?.length && code_responses?.length && (
              <>
                <Stack.Divider />
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item italic>
                      Чтобы опознать своих лидеров, используйте следующий код:
                    </Stack.Item>
                    <Stack.Item textColor="blue">
                      Фразы: {formatCodes(code_phrases)}
                    </Stack.Item>
                    <Stack.Item textColor="red">
                      Ответы: {formatCodes(code_responses)}
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
