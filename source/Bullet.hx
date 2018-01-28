
import nape.geom.Vec2;
import flixel.addons.nape.FlxNapeSpace;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.addons.nape.FlxNapeSprite;
import haxe.ds.Vector;
import nape.dynamics.*; 

class Bullet extends FlxNapeSprite {
    public var lifetime: Int;
    public var team: Int;

    public function new(image:String) {
        super(50, 50);
        loadGraphic(image, false);
        centerOffsets();
        createCircularBody(this.width/2);
        for (shape in body.shapes) {
            shape.sensorEnabled = true;
        }
        body.userData.sprite = this;
    }

    override public function kill() {
        //TODO: reuse
        super.kill();
    }

    override public function update(elapsed: Float) {
        lifetime -= 1;
        if (lifetime <= 0){
            kill();
        }
        super.update(elapsed);
    }
}
