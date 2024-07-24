import 'dart:ui';

import 'package:flutter/material.dart';

//// LIGHT MODE ////
// STYLE COLOURS
const Color mainBackground = Color(0xFFFFFFFF);
const Color secondaryBackground = Color(0xFFF4C314);
const Color redAccentButton = Color(0xFFFF9289);
const Color selectedYellowAccentButton = Color(0xFFEAB90C);
const Color notSelectedGreyAccentButton = Color(0xFFF2EEEE);
//  TEXT COLOURS
const Color mainText = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF002128);
const Color failureText = Color(0xFFC62828);

// BUTTON COLOURS
const Color primaryButton = Color(0xFFF88601);
const Color secondaryButton =  Color(0xFF002128);

///// DARK MODE /////
// STYLE COLOURS
const Color mainBackgroundDark = Color(0xFF171717);
// TEXT COLOURS
const Color mainTextDark = Color(0xFFFFFFFF);
const Color secondaryTextDark = Color(0xFFFFFFFF);

// BUTTON COLOURS
const Color primaryButtonDark = Color(0xFFF88601);
const Color secondaryButtonDark =  Color(0xFF002128);

// Google Maps
const String mapStyle = '''
[
    {
        "featureType": "all",
        "elementType": "labels.text",
        "stylers": [
            {
                "color": "#878787"
            }
        ]
    },
    {
        "featureType": "all",
        "elementType": "labels.text.stroke",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "landscape",
        "elementType": "all",
        "stylers": [
            {
                "color": "#f9f5ed"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "all",
        "stylers": [
            {
                "color": "#f5f5f5"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#c9c9c9"
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "all",
        "stylers": [
            {
                "color": "#aee0f4"
            }
        ]
    }
]
''';
