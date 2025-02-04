package ui;

import note.*;
import flixel.math.FlxRect;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import flixel.FlxG;

using StringTools;

// just FlxSprite with some additional vars
class StrumSprite extends flixel.FlxSprite
{
	public var inputTime:Int = 0;
	public var releaseTime:Float = -1;

	public var state:StrumState = RELEASE;
}

@:access(PlayState) //Fuck you
class Strumline extends FlxTypedSpriteGroup<StrumSprite>
{
	public var notes:FlxTypedSpriteGroup<Note> = new FlxTypedSpriteGroup<Note>();

	public var character:Character = null;

	public var inputs:Array<String> = ["gameplayUp", "gameplayDown", "gameplayLeft", "gameplayRight"];

	public var autoplay:Bool = false;
	public var downscroll:Bool = false;
	public var scrollSpeed:Float = 1;

	private static final RELEASE_BUFFER = (2 / 60);

	public var onHit = new FlxTypedSignal<(Note) -> Void>();
	// public var onMiss = new FlxTypedSignal<(Int, Void, Float, Bool, Bool, Bool, Int) -> Void>();

	override public function new(x:Float, y:Float, skin:String = "Default", initType:StrumInitType = DEFAULT, ?extraData:Map<String, Dynamic>)
	{
		super(x, y);

		if (extraData == null)
		{
			extraData = [];
		}

		var hudNoteSkin:HudNoteSkinBase = new HudNoteSkinBase(skin);

		var hudNoteSkinInfo = hudNoteSkin.info;

		for (i in 0...4)
		{
			var arrow:StrumSprite = new StrumSprite(50, 0);
			arrow.scrollFactor.set();
			arrow.frames = Paths.getSparrowAtlas(hudNoteSkinInfo.notePath);

			var noteInfo = hudNoteSkinInfo.arrowInfo[i];

			arrow.x += Note.swagWidth * i;
			arrow.ID = i;

			arrow.animation.addByPrefix("static", noteInfo.staticInfo.data.prefix, noteInfo.staticInfo.data.framerate, true, noteInfo.staticInfo.data.flipX,
				noteInfo.staticInfo.data.flipY);
			arrow.animation.addByPrefix("pressed", noteInfo.pressedInfo.data.prefix, noteInfo.pressedInfo.data.framerate, false,
				noteInfo.pressedInfo.data.flipX, noteInfo.pressedInfo.data.flipY);
			arrow.animation.addByPrefix("confirm", noteInfo.confrimedInfo.data.prefix, noteInfo.confrimedInfo.data.framerate, false,
				noteInfo.confrimedInfo.data.flipX, noteInfo.confrimedInfo.data.flipY);

			arrow.animation.finishCallback = function(name:String)
			{
				if (name == "confirm")
				{
					if (arrow.state != HOLD){ arrow.animation.play('static', true); }
				}
			}

			arrow.setGraphicSize(Std.int(arrow.width * hudNoteSkinInfo.scale));
			arrow.updateHitbox();
			arrow.antialiasing = hudNoteSkinInfo.antialiasing;

			arrow.animation.callback = function(name:String, frame:Int, index:Int)
			{
				if (frame == 0)
				{
					arrow.centerOffsets();
					switch (name)
					{
						case "static":
							arrow.offset.x += noteInfo.staticInfo.data.offset[0];
							arrow.offset.y += noteInfo.staticInfo.data.offset[1];
						case "pressed":
							arrow.offset.x += noteInfo.pressedInfo.data.offset[0];
							arrow.offset.y += noteInfo.pressedInfo.data.offset[1];
						case "confirm":
							arrow.offset.x += noteInfo.confrimedInfo.data.offset[0];
							arrow.offset.y += noteInfo.confrimedInfo.data.offset[1];
					}
				}
			}

			arrow.animation.play('static');

			arrow.x += 50;
			add(arrow);

			switch(initType)
			{
				case INSTANT:
					continue;
				default:
					if (extraData.exists("tweenManager"))
					{
						arrow.y -= 10;
						arrow.alpha = 0;
		
						extraData.get("tweenManager").tween(arrow, {y: arrow.y + 10, alpha: 1}, 1, {ease: flixel.tweens.FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
					}
			}
		}
	}

	public function addNotes(notesArray:Array<Array<Dynamic>>){
		for (note in notesArray)
		{
			var daNoteData:Int = Std.int(note[1] % 4);

			var oldNote:Note = null;
			if (notes.length > 0){
				oldNote = notes.members[Std.int(notes.length - 1)];
			}

			var newNote:Note = new Note(note[0], daNoteData, note[3], false, oldNote, false, scrollSpeed);
			newNote.sustainLength = note[2];
			newNote.scrollFactor.set(0, 0);

			setNoteHitCallback(newNote);
			notes.add(newNote);

			var susLength:Float = newNote.sustainLength / Conductor.stepCrochet;
			if(Math.round(susLength) > 0){
				for (susNote in 0...(Math.round(susLength) + 1)){
					oldNote = notes.members[Std.int(notes.length - 1)];
	
					var makeFake = false;
					var timeAdd = 0.0;
					if(susNote == 0){ 
						makeFake = true; 
						timeAdd = 0.1; 
					}
	
					var sustainNote:Note = new Note(note[0] + (Conductor.stepCrochet * susNote) + timeAdd, daNoteData, note[3], false, oldNote, true, scrollSpeed);
					sustainNote.isFake = makeFake;
					sustainNote.scrollFactor.set();

					setNoteHitCallback(sustainNote);
					notes.add(sustainNote);
				}
			}

		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in 0...inputs.length)
		{
			var curStrum = members[i];
			curStrum.inputTime = Binds.pressed(inputs[i]) ? curStrum.inputTime + 1 : 0;

			if (curStrum.inputTime == 1)
			{
				curStrum.state = PRESS;
				curStrum.releaseTime = -1;
			}
			if (curStrum.state == HOLD && curStrum.inputTime == 0)
			{
				curStrum.state = RELEASE;
				curStrum.releaseTime = 0;
			}
			if (curStrum.inputTime > 0)
			{
				curStrum.state = HOLD;
			}

			if (curStrum.releaseTime != -1)
			{
				curStrum.releaseTime += elapsed;
			}
		}

		if (PlayState.instance.generatedMusic && !PlayState.instance.inCutscene && !PlayState.instance.endingSong)
		{
			updateNote();
			checkInput();
		}
	}

	// Todo: stop using PlayState.instance
	private function checkInput():Void
	{
		var hitNotes:Array<Note> = [];
		var anyNoteInRange:Bool = false;

		// Botplay Stuff
		if (autoplay){
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.inRange){ anyNoteInRange = true; }
				if (!daNote.wasGoodHit && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * (!daNote.isSustainNote ? 0.125 : (daNote.prevNote.wasGoodHit ? 1 : 0)))
				{
					hitNotes.push(daNote);
				}
			});
		}
		else{
		}

		if (character.holdTimer > Conductor.stepCrochet * character.stepsUntilRelease * 0.001 && !anyKeyPressing() && character.canAutoAnim){
			if (character.isSinging){
				if(Character.USE_IDLE_END){ 
					character.idleEnd();
				}
				else{ 
					character.dance(); 
					character.danceLockout = true;
				}
			}
		}

		for(note in hitNotes){
			character.holdTimer = 0;
			note.wasGoodHit = true;

			onHit.dispatch(note);

			note.hitCallback(note, character);
			if(character.characterInfo.info.functions.noteHit != null){
				character.characterInfo.info.functions.noteHit(character, note);
			}
			PlayState.instance.stage.noteHit(character, note);
			for(script in PlayState.instance.scripts){ script.noteHit(character, note); }
			
			forEach(function(spr:flixel.FlxSprite){
				if (Math.abs(note.noteData) == spr.ID){
					spr.animation.play('confirm', true);
				}
			});

			if (!note.isSustainNote){
				note.destroy();
			}
		}
	}

	private function setNoteHitCallback(note:Note):Void{
		// call me lazy
		PlayState.instance.setNoteHitCallback(note);
	}

	private function updateNote()
	{
		if (!FlxG.state.members.contains(notes))
		{
			FlxG.state.add(notes);
			notes.cameras = cameras;
		}
		notes.forEachAlive(function(daNote:Note)
		{
			var targetX:Float = members[Math.floor(Math.abs(daNote.noteData))].x;
			var targetY:Float = members[Math.floor(Math.abs(daNote.noteData))].y;

			if (downscroll)
			{
				daNote.y = (targetY + (Conductor.songPosition - daNote.strumTime) * (0.45 * scrollSpeed)) - daNote.yOffset;
				if (daNote.isSustainNote)
				{
					daNote.flipY = true;
					daNote.y -= daNote.height;
					daNote.y += 125;
				}
			}
			else
			{
				daNote.y = (targetY - (Conductor.songPosition - daNote.strumTime) * (0.45 * scrollSpeed)) + daNote.yOffset;
			}

			if (daNote.isSustainNote)
			{	
				if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
					&& daNote.y + daNote.offset.y * daNote.scale.y <= (targetY + Note.swagWidth / 2))
				{
					// Clip to strumline
					var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
					swagRect.y = (targetY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}
			}

			daNote.x = targetX + daNote.xOffset;

			if (daNote.tooLate && !daNote.didTooLateAction && !daNote.isFake)
			{
				//onMiss.dispatch(daNote.noteData, daNote.missCallback, Scoring.MISS_DAMAGE_AMOUNT, true, true);
				daNote.didTooLateAction = true;
			}

			if (downscroll ? (daNote.y > targetY + daNote.height + 50) : (daNote.y < targetY - daNote.height - 50))
			{
				if (daNote.tooLate || daNote.wasGoodHit){ daNote.destroy(); }
			}
		});
		sortNotes();
	}

	// some helper functions
	public function anyKeyPressing():Bool
	{
		for (strum in members){
			if (strum.state == HOLD || strum.state == PRESS){ return true; }
		}
		return false;
	}

	public function anyKeyHolding():Bool{
		for (strum in members){
			if (strum.state == HOLD){ return true; }
		}
		return false;
	}

	public function sortNotes(){
		notes.sort(noteSortThing, FlxSort.DESCENDING);
	}
	public static inline function noteSortThing(Order:Int, Obj1:Note, Obj2:Note):Int{
		return FlxSort.byValues(Order, Obj1.strumTime, Obj2.strumTime);
	}
}

enum abstract StrumState(String) from String
{
	var PRESS = "press";
	var RELEASE = "release";
	var HOLD = "hold";
}

enum abstract StrumInitType(String) from String
{
	var DEFAULT = "default";
	var INSTANT = "instant";
}