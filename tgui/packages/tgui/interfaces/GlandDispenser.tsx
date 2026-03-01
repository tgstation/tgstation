import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  glands: Gland[];
};

type Gland = {
  id: string;
  color: string;
  amount: number;
};

export const GlandDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const { glands = [] } = data;

  return (
    <Window width={300} height={338} theme="abductor">
      <Window.Content>
        <Section>
          {glands.map((gland) => (
            <Button
              key={gland.id}
              width="60px"
              height="60px"
              m={0.75}
              textAlign="center"
              lineHeight="55px"
              icon="eject"
              backgroundColor={gland.color}
              content={gland.amount || '0'}
              disabled={!gland.amount}
              onClick={() =>
                act('dispense', {
                  gland_id: gland.id,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
