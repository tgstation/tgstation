import { Table } from './Table';
import { pureComponentHooks } from 'common/react';

export const Grid = props => {
  const { children, ...rest } = props;
  return (
    <Table {...rest}>
      <Table.Row>
        {children}
      </Table.Row>
    </Table>
  );
};

Grid.defaultHooks = pureComponentHooks;

export const GridItem = props => {
  return (
    <Table.Cell {...props} />
  );
};

Grid.defaultHooks = pureComponentHooks;

Grid.Item = GridItem;
