import { Button, Stack } from 'tgui-core/components';

export const BasicInput = (props) => {
  const { children, name, setValue, defaultValue, value } = props;
  return (
    (value !== null && (
      <Stack onMouseDown={(e) => e.stopPropagation()}>
        <Stack.Item>
          <Button
            color="transparent"
            compact
            icon="times"
            onClick={() => setValue(null, { set_null: true })}
          />
        </Stack.Item>
        <Stack.Item>{children}</Stack.Item>
      </Stack>
    )) || (
      <Button
        content={name}
        color="transparent"
        compact
        onClick={() => setValue(defaultValue)}
      />
    )
  );
};
