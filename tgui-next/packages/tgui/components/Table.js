import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const Table = props => {
  const { collapsing, className, content, children, ...rest } = props;
  return (
    <Box
      as="table"
      className={classes([
        'Table',
        collapsing && 'Table--collapsing',
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
  const { className, header, ...rest } = props;
  return (
    <Box
      as="tr"
      className={classes([
        'Table__row',
        header && 'Table__row--header',
        className,
      ])}
      {...rest} />
  );
};

TableRow.defaultHooks = pureComponentHooks;

export const TableCell = props => {
  const { className, collapsing, header, ...rest } = props;
  return (
    <Box
      as="td"
      className={classes([
        'Table__cell',
        collapsing && 'Table__cell--collapsing',
        header && 'Table__cell--header',
        className,
      ])}
      {...rest} />
  );
};

TableCell.defaultHooks = pureComponentHooks;

Table.Row = TableRow;
Table.Cell = TableCell;
