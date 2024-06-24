import { FeatureChoiced, FeatureDropdownInput } from '../../base';

export const antag_opt_in_status_pref: FeatureChoiced = {
  name: 'Be Antagonist Target',
  description:
    'This is for objective targetting, if a person has enough of a valid reason, they can still choose to kill you. Its for their consideration.\
    By extension, picking "Round Remove" will allow you to be round removed in applicable situations. \
    Enabling any non-ghost antags \
    (revenant, abductor contractor, etc.) will force your opt-in to be, \
    at minimum, "Temporarily Inconvenience".',
  component: FeatureDropdownInput,
};
