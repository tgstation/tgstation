import { toTitleCase } from '../../common/string';
import { Button, Section, Table } from '../../tgui/components';
import { useBackend } from '../../tgui/backend';
import { Window } from '../../tgui/layouts';

type Data = {
  crates: Crates[];
};

type Crates = {
  name: string;
  ref: string;
};

export const ShippingContainer = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { crates } = data;

  return (
    <Window width={335} height={415}>
      <Window.Content scrollable>
        <Section title="Crates">
          <Table>
            {crates.map((crate) => (
              <Table.Row key={crate.ref}>
                <Button
                  content={toTitleCase(crate.name)}
                  onClick={() =>
                    act('remove', {
                      ref: crate.ref,
                    })
                  }
                />
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
