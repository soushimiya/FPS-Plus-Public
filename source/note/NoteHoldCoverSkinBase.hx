package note;

typedef HoldCoverAnimInfo = {
    var prefix:String;
    var framerateRange:Array<Int>;
}

typedef HoldCoverAnims = {
    var start:HoldCoverAnimInfo;
    var hold:HoldCoverAnimInfo;
    var splash:HoldCoverAnimInfo;
}

typedef NoteHoldCoverSkinInfo = {
    var path:String;
    var anims:Array<HoldCoverAnims>;
    var offset:Array<Float>;
    var positionOffset:Array<Float>;
    var alpha:Float;
    var antialiasing:Bool;
    var scale:Float;
}

@:build(modding.GlobalScriptingTypesMacro.build())
class NoteHoldCoverSkinBase
{

    public var info:NoteHoldCoverSkinInfo = {
        path: null,
        offset: [0, 0],
        positionOffset: [0, 0],
        alpha: 1,
        antialiasing: true,
        scale: 1,
        anims: [
            {
                start: null,
                hold: null,
                splash: null
            },
            {
                start: null,
                hold: null,
                splash: null
            },
            {
                start: null,
                hold: null,
                splash: null
            },
            {
                start: null,
                hold: null,
                splash: null
            }
        ]
    };

    public function new() {}

    function addStartAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].start = {
            prefix: _prefix,
            framerateRange: _framerateRange
        };
    }

    function addHoldAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].hold = {
            prefix: _prefix,
            framerateRange: _framerateRange
        };
    }

    function addSplashAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].splash = {
            prefix: _prefix,
            framerateRange: _framerateRange
        };
    }

    /**
	 * Generates the x and y offsets for an animation.
	 *
	 * @param   _x  The x offset of the animation.
	 * @param   _y  The y offset of the animation.
	 */
    inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
        return [_x, _y];
    }

    public function toString():String{ return "NoteHoldCoverSkinBase"; }
}