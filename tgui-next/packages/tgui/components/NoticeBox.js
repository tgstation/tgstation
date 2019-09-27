import { classes } from 'react-tools';
import { Box } from './Box';

export const NoticeBox = props => {
  const { className, ...rest } = props;
  return (
    <Box
      className={classes('NoticeBox', className)}
      {...rest} />
  );
};
