// /data/user/0/com.example.pic_n_loca_app/cache/CAP422041405340159134.jpg

// def localProperties = new Properties()
// def localPropertiesFile = rootProject.file('local.properties')
// if (localPropertiesFile.exists()) {
//     localPropertiesFile.withReader('UTF-8') { reader ->
//         localProperties.load(reader)
//     }
// }

// def flutterRoot = localProperties.getProperty('flutter.sdk')
// if (flutterRoot == null) {
//     throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
// }

// def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
// if (flutterVersionCode == null) {
//     flutterVersionCode = '1'
// }

// def flutterVersionName = localProperties.getProperty('flutter.versionName')
// if (flutterVersionName == null) {
//     flutterVersionName = '1.0'
// }

// apply plugin: 'com.android.application'
// apply plugin: 'kotlin-android'
// apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// android {
//     compileSdkVersion 33//flutter.compileSdkVersion

//     compileOptions {
//         sourceCompatibility JavaVersion.VERSION_1_8
//         targetCompatibility JavaVersion.VERSION_1_8
//     }

//     kotlinOptions {
//         jvmTarget = '1.8'
//     }

//     sourceSets {
//         main.java.srcDirs += 'src/main/kotlin'
//     }

//     defaultConfig {
//         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//         applicationId "com.example.pic_n_loca_app"
//         minSdkVersion 21
//         targetSdkVersion 30//flutter.targetSdkVersion
//         versionCode flutterVersionCode.toInteger()
//         versionName flutterVersionName
//     }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig signingConfigs.debug
//         }
//     }
// }

// flutter {
//     source '../..'
// }

// dependencies {
//     implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
// }
