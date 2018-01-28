package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import openfl.Assets;
import nape.geom.*;

class SmallEnemy extends Enemy
{
    var jumpDelay:Float = 0;

	public function new (path:String ="assets/images/ab_small.json", maxHealth:Float=10)
	{
        super(path, maxHealth);
        
        team = 0;

		body.allowRotation = true;
		setDrag(0.98, 1);
        animation.play("idle");
	}

	override public function update(elapsed:Float) {
        var speed = 100;
        var diff = target.sub(body.position);
        jumpDelay -= elapsed;
        if (diff.lsq() < 200) {
            diff = diff.unit().muleq(speed);
            body.applyImpulse(diff);
            var speed = body.velocity.mul(-1);
            if (speed.lsq() > 1) {
                body.rotation = (speed.angle);
            }
        } else if (jumpDelay <= 0) {
            jumpDelay = 1 + (Std.random(1024) / 1024);
            diff = Enemy.getRandomVec();
            body.applyImpulse(diff.muleq(1000));
        }

        super.update(elapsed);
    }
	
}
