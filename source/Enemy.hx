package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import openfl.Assets;
import nape.geom.*;

class Enemy extends LiveThing
{
    //var image: FlxSprite;
    public var target:Vec2;
    var follow = true;

	public function new (path:String, maxHealth:Float)
	{
        super(path, maxHealth);
        team = 0;
        health = maxHealth;
		body.allowRotation = false;
		setDrag(0.98, 1);
        //animation.play("idle");
	}

    public static function getRandomVec() : Vec2 {
        var dx:Int = Std.random(100)-50;
        var dy:Int = Std.random(100)-50;
        return (new Vec2(dy, dx)).muleq(0.014142136);
    }

    override public function revive() {
        super.revive();
        health = maxHealth;
    }

    public function aiFollow(elapsed:Float) {
        var speed = 30;
        var diff = target.sub(body.position);
        var follow_dist = 250;
        if (diff.lsq() < follow_dist * follow_dist) {
            diff = diff.unit().muleq(speed);
            body.applyImpulse(diff);
        }
    }

	override public function update(elapsed:Float) {
        if (follow) {
            aiFollow(elapsed);
        }

        super.update(elapsed);
    }
	
}
