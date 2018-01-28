package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.system.FlxAssets;
import haxe.Json;

class LiveThing extends Thing
{
    //var image: FlxSprite;
    public var team: Int;
    public var maxHealth:Float;
    
	public function new (asset: FlxGraphicAsset, maxHealth:Float=1, width: Int = 32, height: Int = 32)
	{
        super(asset, width, height);
        this.maxHealth = maxHealth;
        health = maxHealth;
        team = 0;
	}
}
