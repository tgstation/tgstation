import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const Table = props => {
  const { className, content, children, ...rest } = props;
  return (
    <Box
      as="table"
      className={classes([
        'Table',
        className,
      ])}
      {...rest}>
      <tbody>
        {content}
        {children}
      </tbody>
    </Box>
  );
};

Table.defaultHooks = pureComponentHooks;

export const TableRow = props => {
  const { className, ...rest } = props;
  return (
    <Box
      as="tr"
      className={classes([
        'Table__row',
        className,
      ])}
      {...rest} />
  );
};

TableRow.defaultHooks = pureComponentHooks;

export const TableCell = props => {
  const { className, collapsing, ...rest } = props;
  return (
    <Box
      as="td"
      className={classes([
        'Table__cell',
        collapsing && 'Table__cell--collapsing',
        className,
      ])}
      {...rest} />
  );
};

TableCell.defaultHooks = pureComponentHooks;

Table.Row = TableRow;
Table.Cell = TableCell;
