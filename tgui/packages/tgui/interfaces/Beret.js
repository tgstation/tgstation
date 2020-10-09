import { Button, Section, Table, ColorBox } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Beret = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beret_color,
  } = data;
  return (
    <Window
      theme="cult"
      width={250}
      height={100}>
      <Window.Content>
        <Section>
          <Table>
            <Table.Row>
              <Table.Cell>
                <Button
                  content="Change Color"
                  onClick={() => act('color')} />
                <ColorBox color={beret_color} />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Create"
                  onClick={() => act('create')} />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
