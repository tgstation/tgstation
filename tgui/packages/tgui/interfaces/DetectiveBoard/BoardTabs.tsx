import { Box, Button } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { DataCase } from './DataTypes';

type BoardTabsData = {
  cases: DataCase[];
  current_case: number;
};

const BoardTab = (props) => {
  const { color, selected, onClick = () => {}, children } = props;
  return (
    <Box
      onClick={onClick}
      className={classes([
        'BoardTab',
        selected ? 'BoardTab__Selected' : 'BoardTab__Perspective',
        !selected && 'BoardTab__' + color,
      ])}
    >
      <Box className={'BoardTab__Contain'}>{children}</Box>
    </Box>
  );
};

export const BoardTabs = (props) => {
  const { act, data } = useBackend<BoardTabsData>();
  const { cases, current_case } = data;
  return (
    <Box className="BoardTabs">
      {cases?.map((item, index) => (
        <BoardTab
          selected={index + 1 === current_case}
          color={item.color}
          key={index}
          onClick={() => act('set_case', { case: index + 1 })}
        >
          <span className="BoardTab__Text">{item.name}</span>
          {current_case - 1 === index && (
            <>
              <Button
                color="transparent"
                className="BoardTab__Button"
                icon="times"
                iconColor="black"
                onClick={() => act('remove_case', { case_ref: item.ref })}
              />
              <Button
                color="transparent"
                className="BoardTab__Button"
                icon="pen"
                iconColor="black"
                onClick={() => act('rename_case', { case_ref: item.ref })}
              />
            </>
          )}
        </BoardTab>
      ))}
      <Button color="transparent" icon="plus" onClick={() => act('add_case')} />
    </Box>
  );
};
