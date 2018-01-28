package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.*;
import openfl.display.*;
import flixel.*;
import nape.geom.Vec2;
import flixel.addons.nape.FlxNapeSpace;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import nape.callbacks.*;
import flixel.addons.nape.FlxNapeSprite;

class BodyGroup<T:FlxNapeSprite> extends FlxTypedGroup<T>
{
    public var collisionId:CbType;

    public function new(group: CbType =null) {
        super();
        if (group != null) {
            collisionId = group;
        } else {
            collisionId = new CbType();
        }
    }

    override public function add(obj:T):T {
        
        obj.body.cbTypes.add(collisionId);
        return super.add(obj);
    }
}
