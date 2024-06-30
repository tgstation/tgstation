import { Feature, FeatureShortTextInput } from '../base';

export const signature: Feature<string> = {
  name: 'Paperwork - Signature',
  description:
    "Custom signature for your character. Applied when using %s in fields on paper. If left blank, the character's full name is used by default",
  component: FeatureShortTextInput,
};

export const date_format: Feature<string> = {
  name: 'Paperwork - Date Format',
  description:
    'Date format the character uses when using %d in fields on paper. You can use any of the following keywords: YYYY - year (2024), YY - year (24), DD - day of the month, DDD - day of the week (Mon, Tue), MM - number of the month, MMM - month (Jan, Feb). You can use any separators between the above. If left blank, DD/MM/YYYY format is used by default',
  component: FeatureShortTextInput,
};
