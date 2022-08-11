import 'package:ras/models/kml/LookAt.dart';
import 'package:ras/models/kml/Point.dart';

class Placemark {
  String id;
  String name;
  String description;
  LookAt lookAt;
  Point point;
  String type; // seedMarker, polyVertex, landingPoint
  dynamic customData;

  static dynamic style = {
    "hotSpot": {
      "x": 0.5,
      "y": 0.5,
      "xunits": "fraction",
      "yunits": "fraction",
    },
    "high": {
      "scale": "3.0",
    },
    "normal": {
      "scale": "2.0"
    }
  };

  Placemark(this.id, this.name, this.description, this.lookAt, this.point, this.type, {this.customData});

  generateTag(String filename, String density, String co2, String estimatedLongevity, String estimatedFinalHeight, String seedballDiameter) {
    return '''
    <Style id="high-$id">
      <IconStyle>
        <scale>${style['high']['scale']}</scale>
        <Icon>
          <href>http://lg1:81/$filename</href>
        </Icon>
        <hotSpot 
          x="${style['hotSpot']['x']}" 
          y="${style['hotSpot']['y']}" 
          xunits="${style['hotSpot']['xunits']}" 
          yunits="${style['hotSpot']['yunits']}"
        />
      </IconStyle>
    </Style>
    <Style id="normal-$id">
      <IconStyle>
        <scale>${style['normal']['scale']}</scale>
        <Icon>
          <href>http://lg1:81/$filename</href>
        </Icon>
        <hotSpot 
          x="${style['hotSpot']['x']}" 
          y="${style['hotSpot']['y']}" 
          xunits="${style['hotSpot']['xunits']}" 
          yunits="${style['hotSpot']['yunits']}"
        />
      </IconStyle>
    </Style>
    <StyleMap id="$id">
      <Pair>
        <key>normal</key>
        <styleUrl>normal-$id</styleUrl>
      </Pair>
      <Pair>
        <key>highlight</key>
        <styleUrl>high-$id</styleUrl>
      </Pair>
    </StyleMap>
    <Placemark>
      <name>$name</name>
      <description><![CDATA[
          <p><b>Scientific Name:</b> $description</p>
          <p><b>Density:</b> $density</p>
          <p><b>CO2 Capture:</b> $co2 kg/year</p>
          <p><b>Estimated Longevity:</b> $estimatedLongevity</p>
          <p><b>Estimated Final Height:</b> $estimatedFinalHeight</p>
          <p><b>Seedball Diameter:</b> $seedballDiameter</p>
          ]]></description>
      ${this.lookAt.generateTag()}
      <styleUrl>$id</styleUrl>
      ${this.point.generateTag()}
    </Placemark>
    ''';
  }

  generateLandTag(String filename, String projectName, String dateOfProject, String sownMode, String region, String minSwtDate, String maxSwtDate, String minSwtTemp, String maxSwtTemp, String avgNumberOfRains, String totalNumberOfRains, String ph) {
    return '''
    <Style id="high-$id">
      <IconStyle>
        <scale>${style['high']['scale']}</scale>
        <Icon>
          <href>http://lg1:81/$filename</href>
        </Icon>
        <hotSpot 
          x="${style['hotSpot']['x']}" 
          y="${style['hotSpot']['y']}" 
          xunits="${style['hotSpot']['xunits']}" 
          yunits="${style['hotSpot']['yunits']}"
        />
      </IconStyle>
    </Style>
    <Style id="normal-$id">
      <IconStyle>
        <scale>${style['normal']['scale']}</scale>
        <Icon>
          <href>http://lg1:81/$filename</href>
        </Icon>
        <hotSpot 
          x="${style['hotSpot']['x']}" 
          y="${style['hotSpot']['y']}" 
          xunits="${style['hotSpot']['xunits']}" 
          yunits="${style['hotSpot']['yunits']}"
        />
      </IconStyle>
    </Style>
    <StyleMap id="$id">
      <Pair>
        <key>normal</key>
        <styleUrl>normal-$id</styleUrl>
      </Pair>
      <Pair>
        <key>highlight</key>
        <styleUrl>high-$id</styleUrl>
      </Pair>
    </StyleMap>
    <Placemark>
      <name>$name</name>
      <description><![CDATA[
          <p>$description</p>
          <p><b>Project Name:</b> $projectName</p>
          <p><b>Date of Project:</b> $dateOfProject</p>
          <p><b>Sown Mode:</b> $sownMode</p>
          <p><b>Region:</b> $region</p>
          <p><b>Sowing Window Time:</b>
          <b>From: $minSwtDate</b>
          <b>To: $maxSwtDate</b></p>
          <p><b>Min Sowing Temp:</b> $minSwtTemp
          <b>Max Sowing Temp:</b> $maxSwtTemp</p>
          <p><b>Avg No. Of Rains:</b> $avgNumberOfRains
          <b>Total No. of Rains:</b> $totalNumberOfRains</p>
          <p><b>pH:</b> $ph</p>
          ]]></description>
      ${this.lookAt.generateTag()}
      <styleUrl>$id</styleUrl>
      ${this.point.generateTag()}
    </Placemark>
    ''';
  }

  generateCommonMarkerTag(String href) {
    return '''
    <Style id="high-$id">
      <IconStyle>
        <scale>${style['high']['scale']}</scale>
        <Icon>
          <href>$href</href>
        </Icon>
        <hotSpot 
          x="${style['hotSpot']['x']}" 
          y="${style['hotSpot']['y']}" 
          xunits="${style['hotSpot']['xunits']}" 
          yunits="${style['hotSpot']['yunits']}"
        />
      </IconStyle>
    </Style>
    <Style id="normal-$id">
      <IconStyle>
        <scale>${style['normal']['scale']}</scale>
        <Icon>
          <href>$href</href>
        </Icon>
        <hotSpot 
          x="${style['hotSpot']['x']}" 
          y="${style['hotSpot']['y']}" 
          xunits="${style['hotSpot']['xunits']}" 
          yunits="${style['hotSpot']['yunits']}"
        />
      </IconStyle>
    </Style>
    <StyleMap id="$id">
      <Pair>
        <key>normal</key>
        <styleUrl>normal-$id</styleUrl>
      </Pair>
      <Pair>
        <key>highlight</key>
        <styleUrl>high-$id</styleUrl>
      </Pair>
    </StyleMap>
    <Placemark>
      <name>$name</name>
      <description>$description</description>
      ${this.lookAt.generateTag()}
      <styleUrl>$id</styleUrl>
      ${this.point.generateTag()}
    </Placemark>
    ''';
  }

  toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "lookAt": lookAt.toMap(),
      "point": point.toMap(),
      "customData": customData,
      "type": type,
    };
  }

  static List<Placemark> fromMapList(List<dynamic> list) {
    List<Placemark> markers = [];
    list.forEach((element) {
      markers.add(Placemark(
        element['id'],
        element['name'],
        element['description'],
        LookAt.fromMap(element['lookAt']),
        Point.fromMap(element['point']),
        element['type'],
        customData: element['customData'],
      ));
    });
    return markers;
  }

  @override
  String toString() {
    return super.toString();
  }
}
