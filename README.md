# Under development

# contacts_provider
add these to android manifest file:
```xml
    <uses-permission android:name="android.permission.READ_CONTACTS" />  
    <uses-permission android:name="android.permission.WRITE_CONTACTS" /> 
```


## Manual initialization
/main.dart initializing the contacts and asking for `permissions`.<br>
You can ask for the permissions wherever you like, it is just for the demonstration purposes.
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // initializing contacts_provider
  final contacts = Contacts();
  await contacts.handlePermissions();
  await contacts.init();

  runApp(const MainApp());
}

```

## Using `ContactsBuilder`
/home.dart
```dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContactsBuilder(
      onCreate: (event) {
        // on create behavior goes here

        // you can access the event from here.

        // new contact list after event has happened
        event.contactList;

        // only effected contact list, in case of create
        // it will be the contacts that were created
        event.effectedContacts;
        // event type
        event.event;
      },
      onUpdate: (event) {
        // on update behavior goes here
      },
      onDelete: (event) {
        // on delete behavior goes here
      },
      onChange: () {
        // If you specify this, it will be executed on any changes will happen in contacts;
      },
      builder: (context, data) {
        // receive new list of contacts here.
        final allContacts = data.contactList;
        return ListView.builder(
          itemCount: allContacts.length,
          itemBuilder: (BuildContext context, int index) {
            final contact = allContacts[index];
            return ContactListTile(contact: contact);
          },
        );
      },
    );
  }
}

```

## Initializing with `ContactsProvider`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Contacts.handlePermissions();
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContactsProvider(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: HomePage(),
          ),
        ),
      ),
    );
  }
}

```

