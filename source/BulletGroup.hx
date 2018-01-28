
import nape.geom.Vec2;
import flixel.addons.nape.FlxNapeSpace;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.addons.nape.FlxNapeSprite;
import haxe.ds.Vector;
import nape.dynamics.*; 

class BulletGroup extends BodyGroup<Bullet> {

    public function new() {
        super();
        bulletFilter = new InteractionFilter(0);
    }

    var bulletFilter : InteractionFilter;

    public function shoot(start:Vec2, dir: Vec2, team:Int=1) {
        var bullet: Bullet;
        bullet = getFirstAvailable();
        if (bullet == null) {
            if (this.length > 400) {
                return;
            }
            bullet = new Bullet("assets/images/bullet.png");
            
            bullet.body.setShapeFilters(new InteractionFilter(0, -1, 1, -1));
            
            add(bullet);
        }
        bullet.revive();
        bullet.team = team;
        bullet.body.position.set(start);
        bullet.body.velocity.set(dir);
        bullet.lifetime = 160;
    }

}