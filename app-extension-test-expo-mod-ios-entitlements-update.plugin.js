const { withEntitlementsPlist } = require('@expo/config-plugins');

module.exports = function appExtensionTestExpoModIosEntitlementsUpdate(config) {
  return withEntitlementsPlist(config, async (config) => {
    config.modResults['com.apple.developer.siri'] = true;
    return config;
  });
};
