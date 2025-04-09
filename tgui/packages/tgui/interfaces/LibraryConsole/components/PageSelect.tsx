import { Button, Input, Stack } from 'tgui-core/components';

export function PageSelect(props) {
  const {
    call_on_change,
    current_page,
    disabled,
    minimum_page_count,
    page_count,
  } = props;

  if (page_count === 1) return;

  return (
    <Stack>
      <Stack.Item>
        <Button
          disabled={current_page === minimum_page_count || disabled}
          icon="angle-double-left"
          onClick={() => call_on_change(minimum_page_count)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={current_page === minimum_page_count || disabled}
          icon="chevron-left"
          onClick={() => call_on_change(current_page - 1)}
        />
      </Stack.Item>
      <Stack.Item>
        <Input
          placeholder={current_page + '/' + page_count}
          onChange={(e, value) => {
            // I am so sorry
            if (value !== '') {
              call_on_change(value);
              e.currentTarget.value = '';
            }
          }}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={current_page === page_count || disabled}
          icon="chevron-right"
          onClick={() => call_on_change(current_page + 1)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={current_page === page_count || disabled}
          icon="angle-double-right"
          onClick={() => call_on_change(page_count)}
        />
      </Stack.Item>
    </Stack>
  );
}
