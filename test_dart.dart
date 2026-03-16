import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final hfUrl = 'https://sonui-yisol-idm-vton.hf.space';
  
  print("Downloading images...");
  final humanBytes = await http.readBytes(Uri.parse('https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png'));
  final garmentBytes = await http.readBytes(Uri.parse('https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png'));

  print("Uploading to HF...");
  Future<String> upload(List<int> bytes, String name) async {
    final req = http.MultipartRequest('POST', Uri.parse(hfUrl + '/upload'))
      ..files.add(http.MultipartFile.fromBytes('files', bytes, filename: name));
    final res = await req.send();
    final body = await res.stream.bytesToString();
    return (jsonDecode(body) as List).first as String;
  }
  
  final hPath = await upload(humanBytes, 'human.jpg');
  final gPath = await upload(garmentBytes, 'garment.jpg');

  print("Joining IDM-VTON queue...");
  final response = await http.post(
    Uri.parse(hfUrl + '/queue/join'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'data': [
        {
          'background': {
            'path': hPath,
            'url': hfUrl + '/file=' + hPath,
            'orig_name': 'human.jpg',
            'meta': {'_type': 'gradio.FileData'}
          },
          'layers': [],
          'composite': null,
        },
        {
          'path': gPath,
          'url': hfUrl + '/file=' + gPath,
          'orig_name': 'garment.jpg',
          'meta': {'_type': 'gradio.FileData'}
        },
        'upper body clothing',
        true,
        false, // is_checked_crop
        30,
        42,
      ],
      'fn_index': 2,
      'session_hash': 'test12345',
    }),
  );
  
  if (response.statusCode != 200) {
    print("Failed to join: " + response.body);
    return;
  }
  
  final evtId = jsonDecode(response.body)['event_id'];
  print("Joined queue! Event ID: " + evtId.toString());
  
  final pollUrl = Uri.parse(hfUrl + '/queue/data?session_hash=test12345');
  final streamRes = await http.Request('GET', pollUrl).send();
  
  streamRes.stream.transform(utf8.decoder).listen((data) {
     print("CHUNK: " + data);
  });
}
