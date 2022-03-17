const { withInfoPlist } = require('@expo/config-plugins');

module.exports = function appExtensionTestExpoModIosInfoPlistUpdate(config) {
  return withInfoPlist(config, async (config) => {
    config.modResults['ITSAppUsesNonExemptEncryption'] = false;
    return config;
  });
};
