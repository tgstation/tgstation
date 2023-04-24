import { useBackend, useLocalState } from 'tgui/backend';
import { Input, Stack, Box, Button } from 'tgui/components';

type Props = {
  color?: string;
  field: string;
  target_ref: string;
  text: string;
};

/**
 * Expects a referrence to the thing you're modifying,
 * then attempts to set the field with the value.
 *
 * When user presses ENTER, this is called to Byond:
 * ```
 * act('edit_field', { field: field, ref: target_ref, value: value })
 * ```
 * Ensure that you have the corresponding action case in your Byond code.
 *
 */
export const EditableText = (props: Props, context) => {
  const { color, field, target_ref, text } = props;
  if (!field) return <> </>;

  const { act } = useBackend(context);
  const [editing, setEditing] = useLocalState<boolean>(
    context,
    `editing_${field}`,
    false
  );

  return editing ? (
    <Input
      autoFocus
      autoSelect
      width="50%"
      maxLength={512}
      onEscape={() => setEditing(false)}
      onEnter={(event, value) => {
        setEditing(false);
        act('edit_field', { field: field, ref: target_ref, value: value });
      }}
      value={text}
    />
  ) : (
    <Stack>
      <Stack.Item>
        <Box
          as="span"
          color={!text ? 'grey' : color || 'white'}
          style={{
            'text-decoration': 'underline',
            'text-decoration-color': 'white',
            'text-decoration-thickness': '1px',
            'text-underline-offset': '1px',
          }}
          onClick={() => setEditing(true)}>
          {!text ? '(none)' : text}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="transparent"
          icon="backspace"
          ml={1}
          onClick={() =>
            act('edit_field', { field: field, ref: target_ref, value: '' })
          }
          tooltip="Clear"
          tooltipPosition="bottom"
        />
      </Stack.Item>
    </Stack>
  );
};
