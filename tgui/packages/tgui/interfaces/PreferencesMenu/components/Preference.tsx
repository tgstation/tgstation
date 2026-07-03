import type { ReactNode } from 'react';
import { Stack } from 'tgui-core/components';

type PreferenceProps = {
  id: string;
  name?: string;
  description?: string;
  childrenClassName?: string;
  children: ReactNode;
};

export function Preference(props: PreferenceProps) {
  const { id, name, description, childrenClassName, children } = props;
  const className = 'PreferencesMenu__Preference';

  return (
    <Stack key={id} className={className}>
      <Stack.Item grow ml={0.5}>
        <Stack vertical g={0}>
          <Stack.Item className={`${className}--name`}>{name || id}</Stack.Item>
          {description && (
            <Stack.Item className={`${className}--desc`}>
              {description}
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack
        justify="end"
        className={`${className}--controls ${className}--${childrenClassName || 'Preferences'}`}
      >
        {children}
      </Stack>
    </Stack>
  );
}
