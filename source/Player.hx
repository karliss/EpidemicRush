package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import openfl.Assets;
import nape.geom.Vec2;

class Player extends LiveThing
{
    //var image: FlxSprite;
	public static inline var SHOT_DELAY:Int = 10;
    var shotDelay:Int = 0;
	var dashDelay: Float = 0;
	var dashActive: Float = 0;
	var dashDir: Vec2;
	public var confirmTime: Float = 0;

	public function new ()
	{
        super("assets/images/player.json", 100);
		//super("assets/images/main1.png", 67, 64);

		body.allowRotation = true;
		setDrag(0.98, 1);
        animation.play("idle");
        this.health = 100;
		this.team = 1;
	}
	
	public function tryShoot():Bool {
		if (shotDelay == 0) {
			shotDelay = SHOT_DELAY;
			return true;
		}
		return false;
	}

	public function update0(inputState: MoveState, infection: Float, diff: Float ) {
		var speed:Float = 20 + infection * 40;
		//trace(body.velocity.length);
		body.applyImpulse(inputState.moveVec.mul(speed));
		if (inputState.aim.lsq() >= 0.5) {
			body.rotation = (inputState.aim.angle);
		}
		if (infection >= 0.8 && health < 100) {
			health += infection * diff;
		}
		if (dashDelay > 0) {
			dashDelay -= diff; 
		} else {
			if (inputState.dashPressed) {
				dashDelay = 1;
				dashActive = 0.2;
				dashDir = inputState.moveVec.copy();
			}
		}
		if (dashActive > 0) {
			dashActive -= diff;
			body.applyImpulse(dashDir.mul(250));
			setDrag(0.99, 1);
		} else {
			if (body.velocity.length > 300) {
				setDrag(0.8, 1);
			} else{
				setDrag(0.98, 1);
			}
		}
		if (inputState.confirmPressed) {
			body.velocity.setxy(0, 0);
		}
		if (body.velocity.length > 10) {
			confirmTime = 0;
		}
		if (inputState.confirmPressed) {
			confirmTime += diff;
		} else {
			confirmTime = 0;
		}
	}

	override public function update(elapsed:Float):Void 
	{
		if (shotDelay > 0) {
			shotDelay -= 1;
		}
		super.update(elapsed);
	}
}
