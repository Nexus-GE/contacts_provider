# contacts_provider
add these to android manifest file:
```xml
    <uses-permission android:name="android.permission.READ_CONTACTS" />  
    <uses-permission android:name="android.permission.WRITE_CONTACTS" /> 
```


/main.dart initializing the contacts and asking for `permissions`.<br>
You can ask for the permissions wherever you like, it is just for the demonstration purposes.
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final contacts = Contacts();
  await contacts.init();
  await contacts.handlePermissions();
  runApp(const MainApp());
}

```


/home.dart
```dart

class _HomePageState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContactsBuilder(
      onCreate: (event) {
        // on create behavior goes here

        // you can access the event from here.

        // new contact list after event has happend
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
      }
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

  @override
  void dispose() {
    super.dispose();
  }
}

```