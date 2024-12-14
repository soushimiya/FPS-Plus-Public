package objects.dialogue;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Json;

using StringTools;

class DialogueCharacter extends FlxSprite
{
	var tween:FlxTween;
	
	override public function new(char:String = "bf-pixel")
	{
		super(0, 0, Paths.image("ui/dialogue/characters/" + char));
		alpha = 0;
		scrollFactor.set();

		//Optional json
		screenCenter();
		y += height + 20;

		updateHitbox();

		if(Utils.exists("assets/images/ui/dialogue/characters/" + char + ".json")){
			final shit = Utils.getText("assets/images/ui/dialogue/characters/" + char + ".json");
			final charJson = Json.parse(shit.trim());
			
			if(charJson.offset != null){
				offset.set(charJson.offset[0], charJson.offset[1]);
			}
			if(charJson.scale != null){
				scale.set(charJson.scale, charJson.scale);
			}

			antialiasing = (charJson.antialiasing != null) ? charJson.antialiasing : true;
		}
	}

	public function enter()
	{
		if (tween != null)
		{
			tween.cancel();
		}
		tween = FlxTween.tween(this, {alpha: 1, y: (FlxG.height - height)/2 - 40}, 0.8, {ease: FlxEase.quintOut});
	}

	public function hide()
	{
		if (tween != null)
		{
			tween.cancel();
		}
		tween = FlxTween.tween(this, {alpha: 0, y: ((FlxG.height - height)/2) + height + 40}, 0.8, {ease: FlxEase.quintOut});
	}
}