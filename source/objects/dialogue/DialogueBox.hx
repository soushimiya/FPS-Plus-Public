package objects.dialogue;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxG;
import haxe.Json;

using StringTools;

typedef DialogueData = {
	var dialogue:Array<DialogueConversation>;
	var ?skin:String;
}

typedef DialogueConversation = {
	var character:String;
	var text:String;
	var box:String;
}

class DialogueBox extends FlxSpriteGroup
{
	public static var skin:DialogueSkinBase = null;

	var dialogue:DialogueData = {
		dialogue: [],
		skin: null
	};
	var finishedDialogue:Bool = false;
	var curLine:Int = 0;

	var curCharacter:String;
	var characters:Map<String, DialogueCharacter> = [];

	var box:FlxSprite;
	var offsetMap:Map<String, Array<Float>> = [];
	var flipMap:Map<String, Bool> = [];

	var dialogueTxt:FlxTypeText;
	var finishedLine:Bool = false;

	public var finishThing:Void->Void;

	override public function new(song:String)
	{
		super();

		if(Utils.exists("assets/data/songs/" + song + "/dialogue.json")){
			dialogue = Json.parse(Utils.getText("assets/data/songs/" + song + "/dialogue.json"));
		}

		if (dialogue.skin != null){
			skin = new DialogueSkinBase(dialogue.skin);
		}

		//Entry characters
		for (conv in dialogue.dialogue)
		{
			if (!characters.exists(conv.character)){
				final character:DialogueCharacter = new DialogueCharacter(conv.character);
				characters.set(conv.character, character);

				add(character);
				character.hide();
			}
		}

		box = new FlxSprite();
		box.antialiasing = skin.info.antialiasing;
		box.frames = Paths.getSparrowAtlas(skin.info.path);
		for (anim in skin.info.animations){
			box.animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);
			offsetMap.set(anim.name, anim.offset);
			flipMap.set(anim.name, anim.flipX);
		}

		box.animation.finishCallback = function(name:String){
			playAnim(name.split("Open")[0]);
		};

		box.scale.set(skin.info.scale, skin.info.scale);
		box.updateHitbox();
		box.setPosition(skin.info.position[0], skin.info.position[1]);
		//Adding Animations

		add(box);

		//Setup Visuals
		dialogueTxt = new FlxTypeText(skin.info.textPosition[0], skin.info.textPosition[1], Std.int(box.width * 0.7), "", Std.int(skin.info.font.size));
		dialogueTxt.font = Paths.font(skin.info.font.name.split(".")[0], skin.info.font.name.split(".")[1]);
		dialogueTxt.color = FlxColor.fromString(skin.info.font.color);
		dialogueTxt.sounds = [FlxG.sound.load(Paths.sound(skin.info.sound), 0.6)];
		//dialogueTxt.showCursor = true;
		add(dialogueTxt);

		startDialogue();
	}

	function startDialogue()
	{
		finishedLine = false;
		curCharacter = dialogue.dialogue[curLine].character;
		if (curLine != 0)
		{
			if (curCharacter != dialogue.dialogue[curLine - 1].character)
			{
				playAnim(dialogue.dialogue[curLine].box + "Open");
				characters.get(dialogue.dialogue[curLine - 1].character).hide();
				characters.get(curCharacter).enter();
			}
		} else {
			playAnim(dialogue.dialogue[curLine].box + "Open");
			characters.get(curCharacter).enter();
		}

		dialogueTxt.resetText(dialogue.dialogue[curLine].text);
		dialogueTxt.start(0.04, true);
		dialogueTxt.completeCallback = function(){
			finishedLine = true;
		};
	}

	public function finishDialogue()
	{
		remove(box);
		remove(dialogueTxt);

		for (character in characters)
		{
			character.hide();
		}

		new FlxTimer().start(1, function(tmr:FlxTimer){finishThing();});
	}

	public function playAnim(animation:String)
	{
		final curOffset = offsetMap.get(animation);
		if (curOffset != null)
			box.offset.set(curOffset[0], curOffset[1]);

		box.animation.play(animation, true);
		box.flipX = flipMap.get(animation);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((FlxG.keys.justPressed.ANY || FlxG.gamepads.anyJustPressed(ANY)) && !finishedDialogue)
		{
			//if dialogue are still playing, skip it
			if (!finishedLine)
			{
				dialogueTxt.skip();
				finishedLine = true;
			}
			//Go to next Dialogue
			if (finishedLine)
			{
				FlxG.sound.play(Paths.sound('week6/clickText'), 0.6);

				if (curLine <= dialogue.dialogue.length - 2)
				{
					curLine += 1;
					startDialogue();
				} else {
					finishedDialogue = true;
					finishDialogue();
				}
			}
		}
	}
}