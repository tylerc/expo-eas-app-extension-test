const { withXcodeProject, IOSConfig } = require('@expo/config-plugins');

module.exports = function appExtensionTestExpoModIosSquareReaderSdkConfigure(config) {
  return withXcodeProject(config, async (config) => {
    config.modResults.addBuildProperty('IPHONEOS_DEPLOYMENT_TARGET', '14.0');
    return config;
  });
};
