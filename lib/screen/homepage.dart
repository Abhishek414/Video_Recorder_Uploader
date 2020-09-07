import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseStorage _storage =
  FirebaseStorage(storageBucket: 'gs://video-recorder-bb73a.appspot.com');
  StorageUploadTask _uploadTask;
  String fileType = '';
  File _video;
  File _cameraVideo;

  VideoPlayerController _videoPlayerController;
  VideoPlayerController _cameraVideoPlayerController;

  String uid;
  String filename;



  // This funcion will helps you to pick a Video File
 /* _pickVideo() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    _video = video;
    _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
      setState(() { });
      _videoPlayerController.play();
      _videoPlayerController.setLooping(true);
    });
  }*/


  _pickVideoFromCamera() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.camera);
    _cameraVideo = video;
    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)..initialize().then((_) {
      setState(() { });
      _cameraVideoPlayerController.play();
    });
  }


  void _uploadToStorage(){
    String filePath = 'videos/${DateTime.now()}.mp4';
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(_cameraVideo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if(_cameraVideo != null)
                  _cameraVideoPlayerController.value.initialized
                      ? AspectRatio(
                      aspectRatio: _cameraVideoPlayerController.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(_cameraVideoPlayerController),
                          Positioned(
                              bottom: 5,
                              child: FloatingActionButton(
                                onPressed: () {
                                  // Wrap the play or pause in a call to `setState`. This ensures the
                                  // correct icon is shown
                                  setState(() {
                                    // If the video is playing, pause it.
                                    if (_cameraVideoPlayerController.value.isPlaying) {
                                      _cameraVideoPlayerController.pause();
                                    } else {
                                      // If the video is paused, play it.
                                      _cameraVideoPlayerController.play();
                                    }
                                  });
                                },
                                // Display the correct icon depending on the state of the player.
                                child: Icon(
                                  _cameraVideoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                              )
                          )
                        ],
                      )
                  )
                      : Container()
                else
                  Text("Click below record a video", style: TextStyle(fontSize: 10.0),),
                FlatButton.icon(
                  icon: Icon(Icons.camera_enhance),
                  label: Text("Open Camera",style: TextStyle(fontSize: 35.0),),
                  onPressed: () {
                    _pickVideoFromCamera();
                  },
                ),
                if(_uploadTask != null)
                  StreamBuilder<StorageTaskEvent>(
                      stream: _uploadTask.events,
                      builder: (_, snapshot) {
                        var event = snapshot?.data?.snapshot;

                        double progressPercent = event != null
                            ? event.bytesTransferred / event.totalByteCount
                            : 0;

                        return Column(

                          children: [
                            if (_uploadTask.isComplete)
                              Text('Video Uploaded'),


                            if (_uploadTask.isPaused)
                              FlatButton(
                                child: Icon(Icons.play_arrow),
                                onPressed: _uploadTask.resume,
                              ),

                            if (_uploadTask.isInProgress)
                              FlatButton(
                                child: Icon(Icons.pause),
                                onPressed: _uploadTask.pause,
                              ),

                            // Progress bar
                            LinearProgressIndicator(value: progressPercent),
                            Text(
                                '${(progressPercent * 100).toStringAsFixed(2)} % '
                            ),
                          ],
                        );
                      }
                  )
                else
                  FlatButton.icon(
                    label: Text('Upload to Firebase'),
                    icon: Icon(Icons.cloud_upload),
                    onPressed: _uploadToStorage,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
