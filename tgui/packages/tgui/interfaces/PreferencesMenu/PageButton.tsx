import { ReactNode } from 'react';
import { Button } from 'tgui-core/components';

export const PageButton = <P extends unknown>(props: {
  currentPage: P;
  page: P;
  otherActivePages?: P[];

  setPage: (page: P) => void;

  children?: ReactNode;
}) => {
  const pageIsActive =
    props.currentPage === props.page ||
    (props.otherActivePages &&
      props.otherActivePages.indexOf(props.currentPage) !== -1);

  return (
    <Button
      align="center"
      fontSize="1.2em"
      fluid
      selected={pageIsActive}
      onClick={() => props.setPage(props.page)}
    >
      {props.children}
    </Button>
  );
};
