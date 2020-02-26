import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

typedef void OnError(Exception exception);

class Audio extends StatefulWidget {

  final Map audio;

  Audio({Key key, @required this.audio}) : super(key: key);

  @override
  _AudioState createState() => _AudioState(audio);
}

enum PlayerState { stopped, playing, paused }

enum Language { pt, en }

class _AudioState extends State<Audio> {

  final Map audio;
  double fontSize = 24.0;
  bool showTextConfigs = true;
  bool showText = true;
  _AudioState(this.audio);

  Language language = Language.en;

  String audioPath;

  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;

  @override
  void initState() {
    super.initState();
    setState(() {
      audioPath = audio['audios'][0]['path'];
    });
    initPlayer();
  }

  void initPlayer(){
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    advancedPlayer.positionHandler = (p) => setState(() {
      _position = p;
    });
  }

  void seekToSecond(int second){
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${audio['title']} - ${audio['subtitle']}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: (){
              setState(() {
                showTextConfigs = !showTextConfigs;
              });
            }
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: showTextConfigs,
              child: Container(
                color: Colors.blue[400],
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Icon(showText ? Icons.visibility_off : Icons.visibility, color: Colors.white,),
                      onPressed: (){
                        setState(() {
                          showText = !showText;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text(language == Language.en ? 'PT' : 'EN', style: TextStyle(fontSize: 14,color: Colors.white),),
                      onPressed: (){
                        setState(() {
                          language = language == Language.en ? Language.pt : Language.en;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('A-', style: TextStyle(fontSize: 14,color: Colors.white),),
                      onPressed: (){
                        setState(() {
                          fontSize -= 2;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('A+', style: TextStyle(fontSize: 14,color: Colors.white),),
                      onPressed: (){
                        setState(() {
                          fontSize += 2;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Opacity(
                        opacity: showText ? 1.0 : 0.0,
                        child: Text(language == Language.en ? audio['en_text'] : audio['pt_text'], style: TextStyle(fontSize: fontSize)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
              alignment: Alignment.bottomCenter,
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      child: Icon(Icons.play_arrow, color: Colors.white,),
                      onPressed: () {
                        audioCache.play(audioPath);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      onChanged: (double value) {
                        setState(() {
                          seekToSecond(value.toInt());
                          value = value;
                        });
                      },
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButton(
                      isExpanded: true,
                      value: this.audioPath,
                      items: mountSpeakers(),
                      underline: Container(),
                      //iconSize: 15,
                      iconEnabledColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          this.audioPath = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> mountSpeakers() {
    List<DropdownMenuItem<String>> itens = [];
    for(Map audio in  audio['audios']){
      itens.add(DropdownMenuItem<String>(
        value: audio['path'],
        child: Text(audio['name'].toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.blue)),
      ));
    }

    return itens;
  }
}
