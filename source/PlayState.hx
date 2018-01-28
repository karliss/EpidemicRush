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
import nape.dynamics.*;
import haxe.ds.Vector;

class PlayState extends FlxState
{
	private var green: FlxSprite;
	private var red: FlxSprite;
	private var player: Player;
	private var paintMask: FlxSprite = new FlxSprite();
	private var holes: Vector<FlxSprite>;

	static var LEVEL_MIN_X: Int;
	static var LEVEL_MAX_X: Int;
	static var LEVEL_MIN_Y: Int;
	static var LEVEL_MAX_Y: Int;

	private var paused: Bool;
	private var guiGroup: FlxTypedGroup<FlxSprite>;
	private var healthText: FlxText;
	private var scoreText: FlxText;
	var healthBar:VBar;
	private var enemyGroup: BodyGroup<Enemy>;

	private var playerCollisionType:CbType=new CbType();
	private var playerEnemyCollision:InteractionListener;

	private var bullets: BulletGroup;

	private var bulletEnemyListener:InteractionListener;

	var inputState = new MoveState();
	var countMax: Float;
	var scoreCurrent: Float;
	var prevScore: Float = 0;
	var level: Int = 0;

	public function new(level:Int=0, prevScore:Float=0) {
		this.prevScore = prevScore;
		this.level = level;
		super();
	}

	override public function create():Void
	{
		FlxNapeSpace.init();
		super.create();

		

		LEVEL_MIN_X = 0;
		LEVEL_MAX_X = 1917;
		LEVEL_MIN_Y = 0;
		LEVEL_MAX_Y = 1080;

		FlxNapeSpace.velocityIterations = 5;
		FlxNapeSpace.positionIterations = 5;

		
		FlxNapeSpace.createWalls(LEVEL_MIN_X, LEVEL_MIN_Y, LEVEL_MAX_X, LEVEL_MAX_Y);

		FlxG.camera.setScrollBoundsRect(LEVEL_MIN_X, LEVEL_MIN_Y,
			LEVEL_MAX_X - LEVEL_MIN_X, LEVEL_MAX_Y - LEVEL_MIN_Y, true);

		green = new FlxSprite();
		green.loadGraphic("assets/images/sick_small.jpg", false, 640, 480, true);
		add(green);
		red = new FlxSprite();
		red.loadGraphic("assets/images/healthy_small.jpg", false, 640, 480, true);
		add(red);
		countMax = red.width * red.height * 256;
		scoreCurrent = 0;

		player = new Player();
		player.setPosition(50, 50);
		add(player);
		player.body.cbTypes.add(playerCollisionType);

		paintMask.loadGraphic("assets/images/SR.png", false);

		camera.follow(player, FlxCameraFollowStyle.TOPDOWN, 1);

		enemyGroup = new BodyGroup<Enemy>(null);
		var enemy = new BigEnemy();
		enemy.setPosition(800, 800);
		enemyGroup.add(enemy);
		add(enemyGroup);
		addSmallEnemies();

		playerEnemyCollision = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, playerCollisionType, enemyGroup.collisionId, playerEnemy);
		FlxNapeSpace.space.listeners.add(playerEnemyCollision);

		bullets = new BulletGroup();
		add(bullets);
		
		bulletEnemyListener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, enemyGroup.collisionId, bullets.collisionId, bulletCollision);
		FlxNapeSpace.space.listeners.add(bulletEnemyListener);

		loadHoles();

		createUI();
	}

	function getSpawnPos(): Vec2 {
		var spawnDistance: Float = 200;
		while (true) {
			var x:Int = Std.random(LEVEL_MAX_X - 100) + 50;
			var y:Int = Std.random(LEVEL_MAX_Y - 100) + 50;
			var res:Vec2 = new Vec2(x, y);
			
			if (player.body.position.sub(res).lsq() > spawnDistance * spawnDistance ) {
				return res;
			}
		}
	}

	function addSmallEnemies() {
		for (i in 0...(20 + level * 5)) {
			var small: SmallEnemy =
			if (i % 5 != 0) {
				new SmallEnemy();
			} else {
				new SmallEnemy("assets/images/candy.json", 30);
			};
			 
			small.body.position.set(getSpawnPos());
			enemyGroup.add(small);
		}
	}

	var spawnDelay:Float = 0;

	function trySpawnEnemies(diff: Float) {
		if (spawnDelay >= 0) {
			spawnDelay -= diff;
		}
		if (spawnDelay <= 0) {
			var enemy: Enemy = enemyGroup.getFirstAvailable();
			if (enemy == null) {
				return;
			}
			spawnDelay = Math.max(0, 0.5 - level*0.1);
			enemy.revive();
			enemy.body.position.set(getSpawnPos());
		}
	}

	private function loadHoles() {
		holes = new Vector<FlxSprite>(5);
		for (i in 1...6) {
			var hole:FlxSprite = new FlxSprite();
			hole.loadGraphic('assets/images/holes/${i}.png');
			holes[i-1] = hole;
		}
	}

	private function playerEnemy(collision:InteractionCallback) {
		player.hurt(1);
	}

	private function boom(cnt:Int, x:Float, y:Float, k:Float=30) {
		if (cnt <= 0) {
			cnt = 1;
		}
		if (cnt >= 30) {
			cnt = 30;
		}
		for (i in 0...cnt) {
			var range: Float =  Math.sqrt(i) * 40;
			var x1: Float = x + Std.random(cast range) - (range/2);
			var y1: Float = y + Std.random(cast range) - (range/2);
			randomHole(cast x1, cast y1);
		}
	}

	private function bulletCollision(collision: InteractionCallback) {
		var a = collision.int1.userData.sprite;
		var b = collision.int2.userData.sprite;
		var bullet: Bullet;
		var thing:LiveThing;
		if (Std.is(a, Bullet)) {
			bullet = cast a;
			thing = cast b;
		} else {
			bullet = cast b;
			thing = cast a;
		}

		if (bullet.team != thing.team) {
			bullet.kill();
			thing.hurt(5);
			if (!thing.alive) {
				boom(cast (thing.maxHealth/10), thing.x, thing.y);
				randomHole(cast bullet.x,cast bullet.y);
			}
		}
	}

	override function onFocusLost() {
		fpause();
	}

	public function fpause() {
		if (this.subState == null) {
			FlxNapeSpace.paused = true;
			openSubState(new EscMenu(this));
			paused = true;
		}
	}
	
	public function unpause() {
		paused = false;
	}
	
	function randomHole(x: Int, y:Int) {
		var data:FlxSprite = holes[Std.random(holes.length)];
		erase_mask(x, y, data.pixels);
	}

	function erase_mask(x: Int, y: Int, mask: BitmapData) {
		x = x & 0xffffffff;
		y = y & 0xffffffff;
		x -= Std.int(mask.width / 2) & 0xffffffff;
		y -= Std.int(mask.height / 2) & 0xffffffff;
	
		var outd = red.pixels;
		outd.lock();
		for (i in 0...mask.height) {
			var py:Int = y + i;
			if (py < 0 || py >= outd.height) {
				continue;
			}
			for (j in 0...mask.width) {
				var px:Int = x + j;
				
				if (px < 0 || px >= outd.width) {
					continue;
				}
				
				var v0:UInt = outd.getPixel32(px&0xffffffff, py&0xffffffff);
				var m0:UInt = mask.getPixel32(j, i);
				if (m0 < v0) {
					scoreCurrent += ((v0 - m0) >> 24);
					var newV = (m0 & 0xff000000)|(v0 & 0xffffff);
					outd.setPixel32(px&0xffffffff, py&0xffffffff, newV);
				}
			}
		}
		outd.unlock();
		red.dirty = true;
	}

	function drawCircle() {
		var middle = player.getGraphicMidpoint();
		erase_mask(cast middle.x, cast middle.y, paintMask.pixels);
	}
	
	public function reset() {
		FlxG.switchState(new PlayState());
	}

	public function createUI() {
		guiGroup = new FlxTypedGroup<FlxSprite>();
		scoreText = new FlxText(3, 3, 340, "", 16);
		guiGroup.add(scoreText);

		var healthFrame:FlxSprite = new FlxSprite();
		healthFrame.loadGraphic("assets/images/health_frame.png");
		healthFrame.x = 10;
		healthFrame.y = 520;
		
		healthBar = new VBar("assets/images/health_bar.png");
		healthBar.x = healthFrame.x;
		healthBar.y = healthFrame.y + 19;
		guiGroup.add(healthBar);
		guiGroup.add(healthFrame);
 
		for (obj in guiGroup) {
			obj.scrollFactor.set(0, 0);
		}
		add(guiGroup);
	}

	public function infectionLevel(x: Int, y: Int): Float {
		if (x >= 0 && x < red.width && y >= 0 && y < red.height) {
			var v: UInt = red.pixels.getPixel32(x & 0xffffffff, y & 0xffffffff);
			v = (v >> 24);
			return (0xff - v) / 0xff;
		} else {
			return 0;
		}
	}

	function getTotalScore():Float {
		return this.prevScore + (scoreCurrent/countMax);
	}

	function grow(amount: Float) {
		var range = amount * 50;
		var ri:Int = cast range;
		var rv:Float = Std.random(cast range);
		var rv2:Float = Std.random(cast range);
		//trace(ri, rv, rv2);
		var pc = player.getGraphicMidpoint();
		var x:Float = pc.x + Std.random(cast range) - range/2;
		var y:Float = pc.y + Std.random(cast range) - range/2;
		
		//trace(range, x, y);
		erase_mask(cast x,cast y, paintMask.pixels);
		
	}

	override public function update(elapsed:Float) {
		//var data = red.pixels;

		var playerPos = player.getScreenPosition();
		inputState.update(new Vec2(playerPos.x, playerPos.y));
		if (!paused) {
			FlxNapeSpace.paused = false;
		}
		scoreText.text = 'Score: ${getTotalScore()}'.substr(0, 12);
		
		var pc = player.getGraphicMidpoint();

		player.update0(inputState, infectionLevel(cast pc.x,cast pc.y), elapsed);
		healthBar.level = 0.01 * player.health;

		trySpawnEnemies(elapsed);

		
		if (!player.alive) {
			if (this.subState == null) {
				openSubState(new GameOver(this, getTotalScore()));
			}
		}
		if (inputState.shootPressed && player.tryShoot()) {
			bullets.shoot(player.body.position, inputState.aim.mul(400));
		}
		if (inputState.confirmPressed) {
			grow(player.confirmTime);
		}
		if (inputState.backPressed)
		{
			fpause();
		}
		for (enemy in enemyGroup) {
			enemy.target = player.body.position;
		}
		super.update(elapsed);
	}


}
