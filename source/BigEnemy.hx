package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import openfl.Assets;
import nape.geom.*;

class BigEnemy extends Enemy
{
    //var image: FlxSprite;

	public function new ()
	{
        //super("assets/images/big_bad_guy.png");
        super("assets/images/boss.json", 1000);
        //
        team = 0;

		body.allowRotation = true;
		setDrag(0.98, 1);
        animation.play("idle");
	}

	override public function update(elapsed:Float) {
        var speed = 300;
        var diff = target.sub(body.position);
        diff = diff.unit().muleq(speed);
        body.applyImpulse(diff);
        var speed = body.velocity.mul(-1);
        if (speed.lsq() > 1) {
            body.rotation = (speed.angle);
        }

        super.update(elapsed);
    }
	
}
