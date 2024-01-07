import { useState } from 'react';

export function useCompact() {
  const [compact, setCompact] = useState(false);

  function toggleCompact() {
    setCompact(!compact);
  }

  return { compact, toggleCompact };
}
