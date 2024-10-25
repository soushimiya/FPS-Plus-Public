package modding;

import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import sys.FileSystem;

using StringTools;

class ScriptingUtil
{

    //Blend mode aliases so you don't have to use an integer in scripts.
    public static var add(get, never):Int;
    public static inline function get_add()         { return 0; }
    public static var difference(get, never):Int;
    public static inline function get_difference()  { return 3; }
    public static var invert(get, never):Int;
    public static inline function get_invert()      { return 6; }
    public static var multiply(get, never):Int;
    public static inline function get_multiply()    { return 9; }
    public static var normal(get, never):Int;
    public static inline function get_normal()      { return 10; }
    public static var screen(get, never):Int;
    public static inline function get_screen()      { return 12; }
    public static var subtract(get, never):Int;
    public static inline function get_subtract()    { return 14; }

    //These ones aren't supported but are included for completeness.
    public static var alpha(get, never):Int;
    public static inline function get_alpha()       { return 1; }
    public static var darken(get, never):Int;
    public static inline function get_darken()      { return 2; }
    public static var erase(get, never):Int;
    public static inline function get_erase()       { return 4; }
    public static var hardlight(get, never):Int;
    public static inline function get_hardlight()   { return 5; }
    public static var layer(get, never):Int;
    public static inline function get_layer()       { return 7; }
    public static var lighten(get, never):Int;
    public static inline function get_lighten()     { return 8; }
    public static var overlay(get, never):Int;
    public static inline function get_overlay()     { return 11; }
    public static var shader(get, never):Int;
    public static inline function get_shader()      { return 13; }

    //FlxAxes aliases.
    public static var axisNone(get, never):Int;
    public static inline function get_axisNone()    { return 0x00; }
    public static var axisX(get, never):Int;
    public static inline function get_axisX()       { return 0x01; }
    public static var axisY(get, never):Int;
    public static inline function get_axisY()       { return 0x11; }
    public static var axisXY(get, never):Int;
    public static inline function get_axisXY()      { return 0x10; }

    public static inline function makeFlxGroup():FlxTypedGroup<FlxBasic>                { return new FlxTypedGroup<FlxBasic>(); }
    public static inline function makeFlxSpriteGroup():FlxTypedSpriteGroup<FlxSprite>   { return new FlxTypedSpriteGroup<FlxSprite>(); }

    //Things that should work but don't... kinda...
    public static inline function contains(a:String, b:String):Bool                     { return a.contains(b); }
    public static inline function startsWith(a:String, b:String):Bool                   { return a.startsWith(b); }
    public static inline function endsWith(a:String, b:String):Bool                     { return a.endsWith(b); }

    public static inline function screenCenter(obj:FlxObject, ?x:Bool = true, ?y:Bool = true):Void{ 
        if (x){ obj.x = (FlxG.width - obj.width)    / 2; }
		if (y){ obj.y = (FlxG.height - obj.height)  / 2; }	
    }
    
    //FileSystem readDirectory but with mods folder
	public static inline function readDirectory(path:String) {
		var files = FileSystem.readDirectory(path);
		for (mod in PolymodHandler.modDirs){
			if (FileSystem.exists('mods/$mod/' + path.split("assets/")[1])){
				var modfile = FileSystem.readDirectory('mods/$mod/' + path.split("assets/")[1]);
				for (file in modfile){
					if (!files.contains(file)){
                        files.push(file);
                    }
				}
			}
		}
		return files;
	}
}