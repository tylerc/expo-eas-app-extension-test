const { withXcodeProject } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

const appJson = require('./app.json');

// These were helpful references:
// https://github.com/apache/cordova-node-xcode/blob/8b98cabc5978359db88dc9ff2d4c015cba40f150/lib/pbxProject.js#L1076
// https://github.com/DavidStrausz/cordova-plugin-today-widget/blob/master/hooks/addTodayWidgetToProject.js
module.exports = function appExtensionTestExpoModIosSiriShortcutsSetup(config) {
  return withXcodeProject(config, async (config) => {
    const appTarget = config.modResults.getFirstProject()['firstProject']['targets'][0];
    const intentsTarget = config.modResults.addTarget(
      'ExpoEasAppExtensionTestIntents',
      'app_extension',
      'ExpoEasAppExtensionTestIntents',
      'com.tylerchurch.expoeasappextensiontest.ExpoEasAppExtensionTestIntents',
    );
    const intentsGroupKey = config.modResults.pbxCreateGroup('ExpoEasAppExtensionTestIntents', '"ExpoEasAppExtensionTestIntents"');

    for (const buildConfig of Object.values(
      config.modResults.hash.project.objects['XCBuildConfiguration'],
    )) {
      if (/Intents/i.test(buildConfig.buildSettings?.INFOPLIST_FILE || '')) {
        buildConfig.buildSettings.IPHONEOS_DEPLOYMENT_TARGET = '14.0';
        buildConfig.buildSettings.SWIFT_VERSION = '5.0';
      }
    }

    const group = Object.entries(config.modResults.hash.project.objects.PBXGroup).find(
      ([_, group]) => group.name === 'ExpoEasAppExtensionTest',
    )[0];
    for (const parentGroup of Object.values(config.modResults.hash.project.objects.PBXGroup)) {
      if (parentGroup.children) {
        const found = parentGroup.children.find((c) => c.value === group);
        if (found) {
          const groupSubItem = Object.create(null);
          groupSubItem.value = intentsGroupKey;
          groupSubItem.comment = 'ExpoEasAppExtensionTestIntents';
          parentGroup.children.push(groupSubItem);
        }
      }
    }

    for (const filename of [
      'ExpoEasAppExtensionTestIntents-Info.plist',
      'Intents.intentdefinition',
      'ShortcutOptions.swift',
      'Shortcuts.m',
      'Shortcuts.swift',
    ]) {
      if (filename === 'ExpoEasAppExtensionTestIntents-Info.plist') {
        fs.mkdirSync(path.join(__dirname, 'ios', 'ExpoEasAppExtensionTestIntents'));
        fs.writeFileSync(
          path.join(__dirname, 'ios', 'ExpoEasAppExtensionTestIntents', filename),
          fs
            .readFileSync(path.join(__dirname, 'ios-app-extension', filename))
            .toString()
            .replace(/1\.6\.0/g, appJson.expo.version),
        );
        config.modResults.addFile(filename, intentsGroupKey);
      } else if (filename === 'Intents.intentdefinition') {
        fs.writeFileSync(
          path.join(__dirname, 'ios', 'ExpoEasAppExtensionTestIntents', filename),
          fs.readFileSync(path.join(__dirname, 'ios-app-extension', filename)),
        );
        config.modResults.addSourceFile(
          'ExpoEasAppExtensionTestIntents/' + filename,
          { target: appTarget.value },
          group,
        );
      } else {
        fs.writeFileSync(
          path.join(__dirname, 'ios', 'ExpoEasAppExtensionTest', filename),
          fs.readFileSync(path.join(__dirname, 'ios-app-extension', filename)),
        );
        config.modResults.addSourceFile('ExpoEasAppExtensionTest/' + filename, { target: appTarget.value }, group);
      }
    }

    const sourcesBuildPhase = config.modResults.addBuildPhase(
      [],
      'PBXSourcesBuildPhase',
      'Sources',
      intentsTarget.uuid,
    );

    // Add Intents.intentdefinition to the intent target's build phase. We can't list it in the files array
    // like expected, because apache/cordova-node-xcode will use the same PBXBuildFile for both the app and intents targets
    // and that makes CocoaPods/Xcodeproj get confused resulting in a refusal to install our CocoaPods dependencies.
    const intentsDefinitionBuildFile = Object.values(
      config.modResults.hash.project.objects['PBXBuildFile'],
    ).find((file) => file.fileRef_comment === 'Intents.intentdefinition');
    const intentsDefinitionBuildFileUuid = config.modResults.generateUuid();
    config.modResults.hash.project.objects['PBXBuildFile'][intentsDefinitionBuildFileUuid] = {
      ...intentsDefinitionBuildFile,
    };
    sourcesBuildPhase.buildPhase.files.push({
      value: intentsDefinitionBuildFileUuid,
      comment: 'Intents.intentdefinition',
    });

    for (const filename of ['IntentHandler.swift']) {
      fs.writeFileSync(
        path.join(__dirname, 'ios', 'ExpoEasAppExtensionTestIntents', filename),
        fs.readFileSync(path.join(__dirname, 'ios-app-extension', filename)),
      );
      config.modResults.addSourceFile(filename, { target: intentsTarget.uuid }, intentsGroupKey);
    }

    fs.writeFileSync(
      path.join(__dirname, 'ios', 'ExpoEasAppExtensionTest', 'ExpoEasAppExtensionTest-Bridging-Header.h'),
      fs.readFileSync(path.join(__dirname, 'ios-app-extension', 'ExpoEasAppExtensionTest-Bridging-Header.h')),
    );

    config.modResults.addTargetAttribute('DevelopmentTeam', 'U352PCLYGX', {
      uuid: appTarget.value,
    });
    config.modResults.addTargetAttribute('DevelopmentTeam', 'U352PCLYGX', intentsTarget);

    if (!config.modResults.hash.project.objects['PBXTargetDependency']) {
      config.modResults.hash.project.objects['PBXTargetDependency'] = {};
    }
    if (!config.modResults.hash.project.objects['PBXContainerItemProxy']) {
      config.modResults.hash.project.objects['PBXContainerItemProxy'] = {};
    }
    config.modResults.addTargetDependency(appTarget.value, [intentsTarget.uuid]);

    return config;
  });
};
