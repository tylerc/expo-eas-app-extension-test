import { useEffect, useState } from 'react';
import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

class ShortcutsAbstract {
  eventEmitter;
  supportsPresentShortcut = false;

  pending = null;
  listener = null;

  init() {
    this.eventEmitter.addListener('shortcut', (data) => {
      if (this.listener) {
        this.listener(data);
      } else {
        this.pending = data;
      }
    });
  }

  setListener(listener) {
    this.listener = listener;
    if (this.pending) {
      this.listener(this.pending);
      this.pending = null;
    }
  }

  emit(data) {
    if (this.listener) {
      this.listener(data);
    } else {
      this.pending = data;
    }
  }

  hasListener() {
    return !!this.listener;
  }
}

class ShortcutsIos extends ShortcutsAbstract {
  eventEmitter = new NativeEventEmitter(NativeModules.Shortcuts);
  supportsPresentShortcut = Platform.OS === 'ios' && parseInt(Platform.Version, 10) >= 12;

  donateShortcut(type, options) {
    NativeModules.Shortcuts.donateShortcut(type, options);
  }

  suggestShortcuts() {
    NativeModules.Shortcuts.suggestShortcuts();
  }

  presentIntentShortcut(type) {
    return new Promise((resolve) => {
      NativeModules.Shortcuts.presentIntentShortcut(type, resolve);
    });
  }

  getShortcuts() {
    return NativeModules.Shortcuts.getShortcuts();
  }

  clearAllShortcuts() {
    return NativeModules.Shortcuts.clearAllShortcuts();
  }

  clearShortcutsWithIdentifiers(ids) {
    return NativeModules.Shortcuts.clearShortcutsWithIdentifiers(ids);
  }
}

const Shortcuts = new ShortcutsIos();
export default Shortcuts;

export function useShortcutHelper() {
  const [lastShortcutEvent, setLastShortcutEvent] = useState(null);

  useEffect(() => {
    let active = true;

    Shortcuts.setListener((event) => {
      if (!active) {
        return;
      }

      setLastShortcutEvent(event);
    });

    return () => {
      active = false;
    };
  }, []);

  return { lastShortcutEvent, clearShortcutEvent: () => setLastShortcutEvent(null) };
}
