import { useBackend } from '../../backend';
import { Box, Button, Icon, Section, Table } from '../../components';

export type ContractorItem = {
  id: string;
  name: string;
  desc: string;
  cost: number;
  stock: number;
  item_icon: string;
};

type ContractorMenuProps = {
  items: ContractorItem[];
  rep: number;
};

export const ContractorMenu = (props: ContractorMenuProps) => {
  const { act, data } = useBackend();
  const contractor_hub_items = props.items || [];
  return (
    <Section>
      <Box>Reputation: {props.rep}</Box>
      {contractor_hub_items.map((item) => {
        const repInfo = item.cost ? item.cost + ' Rep' : 'FREE';
        const stock = item.stock !== -1;
        return (
          <Section
            key={item.name}
            title={item.name + ' - ' + repInfo}
            layer={2}
            buttons={
              <>
                {stock && (
                  <Box inline bold mr={1}>
                    {item.stock} remaining
                  </Box>
                )}
                <Button
                  content="Purchase"
                  disabled={props.rep < item.cost || (stock && item.stock <= 0)}
                  onClick={() =>
                    act('buy_contractor', {
                      item: item.name,
                      cost: item.cost,
                    })
                  }
                />
              </>
            }>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Icon fontSize="60px" name={item.item_icon} />
                </Table.Cell>
                <Table.Cell verticalAlign="top">{item.desc}</Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        );
      })}
    </Section>
  );
};
