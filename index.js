/**
 * @format
 */

import { AppRegistry } from 'react-native';
import {
  getMessaging,
  setBackgroundMessageHandler,
} from '@react-native-firebase/messaging';
import App from './App';
import { name as appName } from './app.json';

// ——— Icon font imports —————————————————————
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
import Ionicons       from 'react-native-vector-icons/Ionicons';
//import FontAwesome    from 'react-native-vector-icons/FontAwesome';
// …import any other icon sets you use here…

// ——— Firebase background handler —————————————————
setBackgroundMessageHandler(getMessaging(), async (message) => {
  setImmediate(() => {
    console.log(
      'This is running from setBackgroundMessageHandler::setImmediate',
    );
  });

  console.log(
    'setBackgroundMessageHandler JS executing. Received message: ' +
      JSON.stringify(message),
  );

  // // Display a notification
  // await notifee.displayNotification({
  //   title: 'Notification Title',
  //   body: 'Main body content of the notification',
  //   android: {
  //     channelId: 'misc',
  //     pressAction: { id: 'default' },
  //   },
  // });
});

// notifee.onBackgroundEvent(async event => {
//   setImmediate(() => {
//     console.log('This is running from notifee.onBacgroundEvent::setImmediate');
//   });
//   console.log('notifee.onBackgroundEvent with event: ' + JSON.stringify(event));
// });

// ——— Load all icon fonts, then register the app —————————————————
Promise.all([
  MaterialIcons.loadFont(),
  Ionicons.loadFont(),
  //FontAwesome.loadFont(),
  // …
])
  .catch(err => {
    console.warn('Icon font load failed, proceeding anyway', err);
  })
  .finally(() => {
    AppRegistry.registerComponent(appName, () => App);
  });

