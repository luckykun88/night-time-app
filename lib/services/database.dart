import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:night_life/models/club.dart';
import 'package:night_life/models/event.dart';
import 'package:night_life/models/user.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  //club collection reference
  final CollectionReference clubCollection =
      Firestore.instance.collection('clubs');

  //event collection reference
  final CollectionReference eventCollection =
      Firestore.instance.collection('events');

  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  get userProfile {
    return userCollection.document(uid).snapshots();
  }

  //get clubs stream
  Stream<List<Club>> get clubs {
    return clubCollection.snapshots().map(_clubListFromSnapshot);
  }

  //get events stream
  Stream<List<Event>> get events {
    return eventCollection
        .where('isDone', isEqualTo: false)
        .snapshots()
        .map(_eventListFromSnapShot);
  }

  Stream<List<Club>> get userDataStream {
    return clubCollection
        .where('recommended', isEqualTo: true)
        .snapshots()
        .map(_clubListFromSnapshot);
  }

  //get club favorites list from snapshot
  Stream<List<Club>> get clubFavorites {
    return clubCollection
        .where('userLikes', arrayContains: uid)
        .snapshots()
        .map(_clubListFromSnapshot);
  }

  //club list from snapshot
  List<Club> _clubListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents
        .map((doc) => Club(
            id: doc.documentID,
            name: doc.data['name'] ?? '',
            img: doc.data['image'] ?? '',
            type: doc.data['type'] ?? '',
            location: doc.data['location'] ?? '',
            recommended: doc.data['recommended'] ?? false,
            alcoholPrice: doc.data['alcohol_price'] ?? '',
            likes: doc.data['userLikes'] ?? []))
        .toList();
  }

  //event list from snapshot
  List<Event> _eventListFromSnapShot(QuerySnapshot snapshot) {
    return snapshot.documents
        .map((doc) => Event(
            eventName: doc.data['name'] ?? '',
            img: doc.data['image'] ?? '',
            entranceFee: doc.data['entrance_fee'] ?? '',
            date: doc.data['date'] ?? '',
            isDone: doc.data['isDone'] ?? false,
            location: doc.data['location'] ?? '',
            xFactor: doc.data['xfactor'] ?? '',
            alcoholPrice: doc.data['alcohol_price'] ?? ''))
        .toList();
  }

  //function used to handle user favorites
  Future handleUserFavorites(String clubId) async {
    //get document snapshot for particular club Id
    DocumentSnapshot ref = await clubCollection.document(clubId).get();

    //check if reference exists
    if (ref.exists) {
      //check if reference contains the same clubId
      if (ref.data['userLikes'].contains(uid)) {
        //remove the object if true
        await clubCollection.document(clubId).updateData({
          'userLikes': FieldValue.arrayRemove([uid])
        });
        print('array removed'); //print for debugging
      } else {
        //if club id doesn't exist, add a new one to the array
        await clubCollection.document(clubId).updateData({
          'userLikes': FieldValue.arrayUnion([uid])
        });
        print('array added'); //print for debugging
      }
    } else {
      //if reference doesn't exist, add new record
      await clubCollection.document(clubId).setData({
        'userLikes': [uid]
      }, merge: true).whenComplete(() => print('set new array'));
    }
  }
}
