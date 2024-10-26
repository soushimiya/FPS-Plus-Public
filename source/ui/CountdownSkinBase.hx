package ui;

import flixel.math.FlxPoint;

typedef CountdownSegment = {
    var graphicPath:String;
    var audioPath:String;
    var scale:Float;
    var antialiasing:Bool;
    var offset:FlxPoint;
}

typedef CountdownSkinInfo = {
    var first:CountdownSegment;
    var second:CountdownSegment;
    var third:CountdownSegment;
    var fourth:CountdownSegment;
}

@:build(modding.GlobalScriptingTypesMacro.build())
class CountdownSkinBase{

    public var info:CountdownSkinInfo = {
        first: {
            graphicPath: null, 
            audioPath: null, 
            scale: 1, 
            antialiasing: true, 
            offset: new FlxPoint(), 
        },
        second: {
            graphicPath: null, 
            audioPath: null, 
            scale: 1, 
            antialiasing: true, 
            offset: new FlxPoint(), 
        },
        third: {
            graphicPath: null, 
            audioPath: null, 
            scale: 1, 
            antialiasing: true, 
            offset: new FlxPoint(), 
        },
        fourth: {
            graphicPath: null, 
            audioPath: null, 
            scale: 1, 
            antialiasing: true, 
            offset: new FlxPoint(), 
        }
    };

    public function new(){}

    public function toString():String{ return "CountdownSkinBase"; }
}