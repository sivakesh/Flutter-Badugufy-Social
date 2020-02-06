import 'dart:io';
import 'package:budugufy/pages/home.dart';
import 'package:budugufy/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:budugufy/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_tags/tag.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  List<String> imageLabels = [];
  bool labelsSet = false;
  List _items = [];
  double _fontSize = 14;
  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();

  @override
  void initState() { 
    super.initState();
    getUserLocation();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    getLabels(file);
    setState(() {
      this.file = file;
    });
  }

  getLabels(File file) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler(
      ImageLabelerOptions(confidenceThreshold: 0.7),
    );
    imageLabels = [];
    _items = [];
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    for (ImageLabel label in labels) {
      imageLabels.add(label.text);
      _items.add(label.text);
    }
    setState(() {
      this.imageLabels = imageLabels;
      this.labelsSet = true;
    });
  }
  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    getLabels(file);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Create a Post",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade500),),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      // color: Theme.of(context).accentColor.withOpacity(0.6),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: 
              Image(
                image: AssetImage('assets/images/hugo-camera-access.png'),
              )
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: 
            Text(
              "Add a photo from your gallery or click a picture from your phone's camera.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          Divider(),
          FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
              selectImage(context);
            },
            child: Icon(Icons.add_a_photo),
            backgroundColor: Theme.of(context).accentColor,
          ),
          Divider(),
          SizedBox(
            height: 200.0,
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "imageLabels": imageLabels,
      "likes": {},
      "reported" : false,
    });
    mediaRef
      .document(postId)
      .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }


 
  Scaffold buildUploadForm() {
    return Scaffold(
      
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading && labelsSet ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: isUploading && labelsSet ? Colors.grey : Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                  labelsSet ? Tags(
                    key:_tagStateKey,
                    textField: TagsTextField(  
                      textStyle: TextStyle(fontSize: _fontSize),        
                      onSubmitted: (String str) {
                        // Add item to the data source.
                        setState(() {
                            // required
                          _items.add(str);
                          imageLabels.add(str);
                        });
                      },
                    ),
                    itemCount: _items.length, // required
                    itemBuilder: (int index){          
                          final item = _items[index];
                  
                          return ItemTags(
                                // Each ItemTags must contain a Key. Keys allow Flutter to
                                // uniquely identify widgets.
                                key: Key(index.toString()),
                                index: index, // required
                                title: item,
                                active: true,
                                // title: item.title,
                                // active: item.active,
                                // customData: item.customData,
                                textStyle: TextStyle( fontSize: _fontSize, ),
                                combine: ItemTagsCombine.withTextBefore,
                                // image: ItemTagsImage(
                                //   image: AssetImage("img.jpg") OR NetworkImage("https://...image.png")
                                // ) OR null,
                                icon: ItemTagsIcon(
                                  icon: Icons.add,
                                ), 
                                removeButton: ItemTagsRemoveButton(), 
                                onRemoved: (){
                                  // Remove the item from the data source.
                                  setState(() {
                                      // required
                                    _items.removeAt(index); 
                                  });
                                },
                                // onPressed: (item) => print(item),
                                // onLongPressed: (item) => print(item),
                          );
                    },
                  ) : Text(""),
              Container(
                width: 200.0,
                height: 100.0,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  label: Text(
                    "Use Current Location",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.blue,
                  onPressed: getUserLocation,
                  icon: Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    // print(completeAddress);
    // String formattedAddress = "${placemark.locality}, ${placemark.country}";
    // locationController.text = formattedAddress;
    locationController.text = completeAddress;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}

