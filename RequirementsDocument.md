## Work Contacts

### Task

Create an iOS application that connects to a server, loads a list of users and shows their current location on a map in real time.

### Communication with the server

Application should communicate with​ `​ios-test.printful.lv:6111​` ​using TCP.

When initially connecting to the server the application should send the following command:​ `​AUTHORIZE <email>​` ​where​ ​`<email>​` ​is your email address. The server will
respond with the list of users in the following format:​ ​`USERLIST <id>,<name>,<image>,<latitude>,<longitude>;<id2>,<name2>,<image2>,<lat itude2>,<longitude2>;...`.

Connection to the server should be left open in order to continuously receive latest user coordinates in the following format: ​`UPDATE <user id>,<latitude>,<longitude>`.

All commands should be separated using a newline character (​`\n`​).

### Design

The app should look as seen in the example image:
- When tapping on user location a bubble shows up displaying the user name,
profile image and current address;
- Address has to update in real time, based on user location;
- User location can be represented with any custom image;
- The user location image has to smoothly animate to the latest coordinates when
they are received from the server.

<img alt="Friend map screenshot" src="https://github.com/esesmuedgars/FriendFinder/blob/assets/friend_map_screen.png" width="50%" />
