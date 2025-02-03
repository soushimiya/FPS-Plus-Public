package debug;

import note.*;
import ui.*;

import flixel.FlxG;

using StringTools;

class InputDebug extends MusicBeatState
{
	var playerStrums:Strumline;
	var enemyStrums:Strumline;

	var boyfriend:Character;

	override public function create() {
		super.create();
		// if (center) FlxG.width / 2;

		var strumLineVerticalPosition = 30;

		playerStrums = new Strumline(FlxG.width / 2, strumLineVerticalPosition, "Default");
		add(playerStrums);

		enemyStrums = new Strumline(0, strumLineVerticalPosition, "Default");
		enemyStrums.autoplay = true;
		add(enemyStrums);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}