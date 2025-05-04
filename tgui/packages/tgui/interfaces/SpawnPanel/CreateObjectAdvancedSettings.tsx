import React, { useState } from 'react';
import { Section } from 'tgui-core/components';

export function CreateObjectAdvancedSettings() {
  const [icon, setIcon] = useState();
  const [iconState, setIconState] = useState();
  const [iconSize, setIconSize] = useState();
  const [description, setDescription] = useState();

  return <Section>Something here</Section>;
}
