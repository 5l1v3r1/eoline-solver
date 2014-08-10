import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'package:cube/cube.dart' as cube;

StreamSubscription currentSub = null;
cube.EOLineHeuristics heuristics;

Future<List<int>> readHeuristic(String name) {
  return HttpRequest.request(name, responseType: 'arraybuffer').
      then((HttpRequest r) {
    return new List<int>.from(new Uint8List.view(r.response));
  });
}

void main() {
  DateTime start = new DateTime.now();
  readHeuristic('eoline.bin').then((List<int> index) {
    int delay = new DateTime.now().difference(start).inMilliseconds;
    print('took ${delay / 1000} seconds to load heuristic');
    heuristics = new cube.EOLineHeuristics.full(index);
    querySelector('#solve-button').onClick.listen((_) {
      solvePressed();
    });
  });
}

void solvePressed() {
  if (currentSub != null) currentSub.cancel();
  InputElement input = querySelector('#scramble');
  String algoStr = input.value;
  try {
    cube.WcaAlgorithm algo = new cube.WcaAlgorithm.fromString(algoStr);
    cube.StickerAlgorithm stickerAlgo =
        new cube.StickerAlgorithm.fromWca(3, algo);
    cube.StickerEOLineSolver solver =
        new cube.StickerEOLineSolver(stickerAlgo.toState(), heuristics);
    DateTime start = new DateTime.now();
    currentSub = solver.stream.listen((cube.Algorithm algo) {
      int delay = new DateTime.now().difference(start).inMilliseconds;
      print('solve took ${delay / 1000} seconds');
      currentSub.cancel();
      currentSub = null;
      window.alert('solution: $algo');
    });
  } catch (e) {
    window.alert('$e');
  }
}
