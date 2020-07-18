import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: PointsScreen(),
    );
  }
}

const colors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.pink,
  Colors.teal
];

class PointsScreen extends StatefulWidget {
  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  KMeans kMeans;
  @override
  void initState() {
    kMeans = KMeans.fromRandom(
      dataLength: 50,
      centroidsLength: 3,
      //seed: 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KMeans in Flutter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.fiber_new),
            onPressed: () {
              setState(() {
                kMeans = KMeans.fromRandom(
                  dataLength: 50,
                  centroidsLength: 3,
                  //seed: 0,
                );
              });
            },
          )
        ],
      ),
      floatingActionButton: Opacity(
        opacity: 0.2,
        child: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () {
            setState(() {
              kMeans = kMeans.next();
            });
          },
        ),
      ),
      body: SafeArea(
        child: Stack(children: [
          for (int i = 0; i < kMeans.data.length; i++)
            Positioned.fill(
              child: Align(
                alignment: Alignment(kMeans.data[i].x, kMeans.data[i].y),
                child: AnimatedContainer(
                  width: 10,
                  height: 10,
                  duration: Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[kMeans.dataCluster[i]].withOpacity(0.6),
                  ),
                ),
              ),
            ),
          for (final centroid in kMeans.centroids)
            Positioned.fill(
              child: AnimatedAlign(
                duration: Duration(milliseconds: 500),
                alignment: Alignment(centroid.x, centroid.y),
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[kMeans.centroids.indexOf(centroid)],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class KMeans {
  final int iteration;
  final List<Point> data;
  final List<int> dataCluster;
  final List<Point> centroids;

  KMeans({
    this.data,
    this.centroids,
    this.iteration,
    this.dataCluster,
  });

  factory KMeans.fromRandom({int dataLength, int centroidsLength, int seed}) {
    Random randomGenerator = Random(seed);

    Point generateRandomPoint() => Point(
          1 - 2 * randomGenerator.nextDouble(),
          1 - 2 * randomGenerator.nextDouble(),
        );

    final data = List<Point>.generate(
      dataLength,
      (_) => generateRandomPoint(),
    );

    final centroids = List<Point>.generate(
      centroidsLength,
      (_) => generateRandomPoint(),
    );

    return KMeans(
        data: data,
        centroids: centroids,
        iteration: 0,
        dataCluster: _findClusters(data, centroids));
  }

  static List<int> _findClusters(List<Point> data, List<Point> centroids) {
    return List.generate(data.length, (dataIndex) {
      final List<double> distancesFromCentroids = List.generate(
        centroids.length,
        (centroidIndex) => data[dataIndex].distanceTo(centroids[centroidIndex]),
      );
      final ordered = [...distancesFromCentroids]..sort();
      return distancesFromCentroids.indexOf(ordered[0]);
    });
  }

  KMeans next() {
    List<int> counters = List<int>.generate(centroids.length, (_) => 0);
    List<Point> newMeans = List<Point>.generate(
      centroids.length,
      (_) => Point(0.0, 0.0),
    );
    for (int index = 0; index < data.length; index++) {
      newMeans[dataCluster[index]] += data[index];
      counters[dataCluster[index]]++;
    }
    for (int index = 0; index < centroids.length; index++) {
      newMeans[index] =
          counters[index] > 0 ? newMeans[index] * (1 / counters[index]) : 0;
    }
    final newDataClusters = _findClusters(data, newMeans);
    return KMeans(
        data: data,
        iteration: this.iteration + 1,
        dataCluster: newDataClusters,
        centroids: newMeans);
  }
}
