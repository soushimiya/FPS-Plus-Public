package characters.data;

class DarnellBlazin extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "darnellBlazin";
        info.spritePath = "weekend1/darnellBlazin";
        info.frameLoadType = atlas;
        
        info.iconName = "darnell";

        addByLabel('idle', offset(), "Idle", 24, loop(true));
        addByLabel('punchHigh1', offset(), "Punch High 1", 24, loop(false));
        addByLabel('punchHigh2', offset(), "Punch High 2", 24, loop(false));
        addByLabel('punchLow1', offset(), "Punch Low 1", 24, loop(false));
        addByLabel('punchLow2', offset(), "Punch Low 2", 24, loop(false));
        addByLabel('uppercutPrep', offset(), "Uppercut Prep", 24, loop(false));
        addByLabel('uppercutPunch', offset(), "Uppercut Punch", 24, loop(false));
        addByLabel('uppercutPunchLoop', offset(), "Uppercut Punch Loop", 24, loop(false));
        addByLabel('block', offset(), "Block", 24, loop(false));
        addByLabel('dodge', offset(), "Dodge", 24, loop(false));
        addByLabel('hitHigh', offset(), "Hit High", 24, loop(false));
        addByLabel('hitLow', offset(), "Hit Low", 24, loop(false));
        addByLabel('uppercutHit', offset(), "Uppercut Hit", 24, loop(false));
        addByLabel('hitSpin', offset(), "Hit Spin", 24, loop(true));
        addByLabel('cringe', offset(), "Cringe", 24, loop(false));
        addByLabel('pissed', offset(), "Pissed", 24, loop(false));
        
        addExtraData("scale", 1.75);

        addAnimChain("uppercutPunch", "uppercutPunchLoop");
    }

}