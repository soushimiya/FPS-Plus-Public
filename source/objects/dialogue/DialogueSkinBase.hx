package objects.dialogue;

import haxe.Json;

using StringTools;

typedef DialogueSkinInfo = {
    var path:String;
	var font:DialogueFont;
    var antialiasing:Bool;
    var scale:Float;
	var position:Array<Float>;
	var textPosition:Array<Float>;
	var animations:Array<DialogueAnimation>;
	var sound:String;
}

typedef DialogueAnimation = {
	var name:String;
	var prefix:String;
	var offset:Array<Float>;
	var fps:Float;
	var flipX:Bool;
	var loop:Bool;
}

typedef DialogueFont = {
	var name:String;
	var size:Float;
	var color:String;
}

class DialogueSkinBase
{
	public var info:DialogueSkinInfo = {
        path: "ui/dialogue/default/box",
		font: {
			name: "funkin.otf",
			size: 64,
			color: "0xFF000000"
		},
        antialiasing: true,
        scale: 1,
        position: [130, 500],
		textPosition: [0, 0],
        animations: [],
		sound: "text"
    };

	public function new(_skin:String){
		var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/dialogueBox")));

		if(skinJson.path != null)    { info.path = skinJson.path; }
		if(skinJson.font != null)    { info.font = skinJson.font; }
		if(skinJson.antialiasing != null)    { info.antialiasing = skinJson.antialiasing; }
		if(skinJson.scale != null)    { info.scale = skinJson.scale; }
		if(skinJson.position != null)    { info.position = skinJson.position; }
		if(skinJson.textPosition != null)    { info.textPosition = skinJson.textPosition; }
		if(skinJson.animations != null)    { info.animations = skinJson.animations; }
		if(skinJson.sound != null)    { info.sound = skinJson.sound; }
	}
}