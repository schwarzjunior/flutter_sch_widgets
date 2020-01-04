import 'package:flutter/material.dart';
import 'package:flutter_sch_widgets/flutter_sch_widgets.dart';

class SchExpansionTilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.merge(theme.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.cyan));

    return Scaffold(
      appBar: AppBar(title: Text('SchExpansionTile example')),
//      backgroundColor: Colors.white.withAlpha(60),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SchExpansionTile(
              margin: const EdgeInsets.only(top: 26),
              title: _buildTitle(context, 'Default decoration'),
              children: <Widget>[
                Text(_overview, textAlign: TextAlign.justify),
              ],
              decoration: SchExpansionTileDecoration(
                borderWidth: 1.0,
              ),
            ),
            SchExpansionTile(
              margin: const EdgeInsets.only(top: 26),
//              defaultColor: Colors.indigoAccent,
//              backgroundColor: Colors.lightBlue.withAlpha(80),
              decoration: SchExpansionTileDecoration(
                borderWidth: 0.3,
                borderRadius: 8.0,
                borderColorBegin: Colors.blueAccent,
                borderColorEnd: Colors.red,
                headerColorBegin: Colors.orangeAccent,
                headerColorEnd: Colors.purpleAccent[100],
                iconColorBegin: Colors.white,
                iconColorEnd: Colors.orange,
              ),
              title: _buildTitle(context, 'Decorated'),
              children: <Widget>[
                Text(
                  _overview,
                  textAlign: TextAlign.justify,
                  style: textTheme.body1,
                ),
                Text(
                  _overview,
                  textAlign: TextAlign.justify,
                  style: textTheme.body2,
                ),
                DefaultTextStyle(
                  style: textTheme.body1,
                  child: Column(
                    children: <Widget>[
                      Text(_overview, textAlign: TextAlign.justify),
                      Text(_overview, textAlign: TextAlign.start),
                      Text(_overview, textAlign: TextAlign.justify),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent.withAlpha(80),
            border: Border.all(color: Colors.transparent.withAlpha(60), width: 1.5),
          ),
          child: Text(
            '01',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.title.fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline.fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

const _overview = 'Following the events of Captain America: Civil War, Peter '
    'Parker, with the help of his mentor Tony Stark, tries to balance his life as an '
    'ordinary high school student in Queens, New York City, with fighting crime as '
    'his superhero alter ego Spider-Man as a new threat, the Vulture, emerges.';
