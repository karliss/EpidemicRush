
import nape.geom.Vec2;
import flixel.FlxG;
import flixel.input.gamepad.*;
import flixel.input.gamepad.FlxGamepad;

class MoveState {
    public var moveVec:Vec2;
    public var aim:Vec2;
    public var backPressed:Bool = false;
    public var confirmPressed:Bool = false;
    public var shootPressed:Bool = false;
    public var dashPressed:Bool = false;
    public var startPressed:Bool = false;

    public var controller:Bool = false;

    public function new() {
        moveVec = new  Vec2(0, 0);
        aim = new Vec2(1, 0);
    }
    public function update(cpos: Vec2=null) {
        if (cpos == null) {
            cpos = new Vec2(0, 0);
        }
        var keyboardMove:Vec2 = new Vec2(0, 0);
        var hasKeyDir:Bool = false;
        var hasAim:Bool = false;
        var hasMove:Bool = false;

        backPressed = false;
        confirmPressed = false;
        shootPressed = false;
        dashPressed = false;
        startPressed = false;

        if (FlxG.keys.anyPressed([UP, W])) {
            keyboardMove = keyboardMove.add(new Vec2(0, -100));
            hasKeyDir = true;
        } 
        if (FlxG.keys.anyPressed([DOWN, S])) {
            keyboardMove =keyboardMove.add(new Vec2(0, 100));
            hasKeyDir = true;
        }
        if (FlxG.keys.anyPressed([LEFT, A])) {
            keyboardMove =keyboardMove.add(new Vec2(-100, 0));
            hasKeyDir = true;
        }
        if (FlxG.keys.anyPressed([RIGHT, D])) {
            keyboardMove = keyboardMove.add(new Vec2(100, 0));
            hasKeyDir = true;
        }
        if (hasKeyDir) {
            if (keyboardMove.lsq() > 1) {
                keyboardMove = keyboardMove.unit();
                moveVec = keyboardMove;
                hasMove = true;
            }
        }

        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad != null)  {
            //gamepad.deadZone = 0.15;
            //gamepad.deadZoneMode = FlxGamepadDeadZoneMode.INDEPENDENT_AXES;

            if (gamepad.anyPressed([DPAD_UP, DPAD_DOWN, DPAD_RIGHT, DPAD_LEFT])) {
                var md:Vec2 = new Vec2(0, 0);
                if (gamepad.pressed.DPAD_UP) {
                    md = md.add(new Vec2(0, -100));
                }
                if (gamepad.pressed.DPAD_DOWN) {
                    md = md.add(new Vec2(0, 100));
                }
                if (gamepad.pressed.DPAD_RIGHT) {
                    md = md.add(new Vec2(100, 0));
                }
                if (gamepad.pressed.DPAD_LEFT) {
                    md = md.add(new Vec2(-100, 0));
                }
                if (md.lsq() > 1) {
                    md = md.unit();
                }
                hasMove = true;
                moveVec = md;
            }
            var analog =  gamepad.analog.value;
            if (!hasMove) {
                moveVec = new Vec2(analog.LEFT_STICK_X, analog.LEFT_STICK_Y);
                hasMove = true;
            }
            aim = new Vec2(analog.RIGHT_STICK_X, analog.RIGHT_STICK_Y);
            if (aim.lsq() <= 0.01) {
                aim = new Vec2(1, 0);
            } else {
                aim = aim.unit();
            }
            hasAim = true;
            if (gamepad.pressed.RIGHT_SHOULDER) {
                shootPressed = true;
            }
            if (gamepad.pressed.LEFT_SHOULDER) {
                dashPressed = true;
            }
            if (gamepad.anyPressed([BACK, X]) ) {
                backPressed = true;
            }
            if (gamepad.pressed.START) {
                startPressed = true;
            }
            if (gamepad.pressed.A) {
                confirmPressed = true;
            }
        } else {
            controller=false;
        }

        
        if (!hasMove) {
            moveVec = keyboardMove;
        }
        if (!hasAim) {
            var mousePos = new Vec2(FlxG.mouse.screenX, FlxG.mouse.screenY);
            aim = mousePos.sub(cpos);
            if (aim.lsq() >= 0.001) {
                aim = aim.unit();
            } else {
                aim = new Vec2(1, 0);
            }
        }

        if (FlxG.keys.anyJustPressed([ESCAPE])) {
            backPressed = true;
        }
        if (FlxG.keys.anyPressed([ENTER, SPACE])) {
            confirmPressed = true;
        }
        if (FlxG.keys.anyPressed([SHIFT, ALT])) {
            dashPressed = true;
        }


        if (FlxG.mouse.pressed) {
            shootPressed = true;
            var mousePos = new Vec2(FlxG.mouse.screenX, FlxG.mouse.screenY);
            aim = mousePos.sub(cpos).unit();
        }
        if (FlxG.mouse.pressedRight) {
            dashPressed = true;
        }

        if (FlxG.mouse.pressedRight) {
            shootPressed = true;
            var mousePos = new Vec2(FlxG.mouse.screenX, FlxG.mouse.screenY);
            aim = mousePos.sub(cpos).unit();
        }
    }
}