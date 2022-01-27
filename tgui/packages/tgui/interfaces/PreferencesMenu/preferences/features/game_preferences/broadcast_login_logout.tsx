import { multiline } from "common/string";
import { CheckboxInput, FeatureToggle } from "../base";

export const broadcast_login_logout: FeatureToggle = {
  name: "Broadcast login/logout",
  category: "GAMEPLAY",
  description: multiline`
    When enabled, disconnecting and reconnecting will announce to deadchat.
  `,
  component: CheckboxInput,
};
