import React from 'react';
import { View, Text } from 'react-native';
import 'expo-dev-client';
import Shortcuts, { useShortcutHelper } from './shortcuts';

(async () => {
  Shortcuts.init();
  Shortcuts.suggestShortcuts();
})();

export default () => {
  const { lastShortcutEvent } = useShortcutHelper();

  return (
    <View>
      <Text style={{textAlign: 'center', marginTop: 100}}>Shortcuts says: {JSON.stringify(lastShortcutEvent)}</Text>
    </View>
  );
};
