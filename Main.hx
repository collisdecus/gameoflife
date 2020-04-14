import Random;

class Main extends hxd.App {
    var world : Array<Array<Bool>>;
    var worldSize : Int = 256;
    var cellSize : Int = 4;
    var running : Bool = true;
    var stepDuration : Float = 0.0;
    var timeSinceLastStep : Float = 0.0;
    var graphics : h2d.Graphics;
    var paintButton : Int = 1;
    var painting : Bool = false;

    override function init() {
        world = createEmptyWorld(true);
        hxd.Window.getInstance().addEventTarget(onEvent);
        graphics = new h2d.Graphics(s2d);
    }

    override function update(timePassed) {
        graphics.beginFill(0x0);
        graphics.drawRect(0, 0, worldSize * cellSize, worldSize * cellSize);
        graphics.endFill();

        graphics.beginFill(0xEA8220);
        for (x in 0 ... worldSize) {
            for (y in 0 ... worldSize) {
                if (world[x][y]) {
                    graphics.drawRect(x * cellSize, y * cellSize, cellSize, cellSize);
                }
            }
        }
        graphics.endFill();

        timeSinceLastStep += timePassed;
        if (timeSinceLastStep >= stepDuration) {
            if (running) {
                simulate();
            }
            timeSinceLastStep = 0.0;
        }
    }

    static function main() {
        new Main();
    }

    function createEmptyWorld(randomize : Bool) {
        var newWorld : Array<Array<Bool>> = [];
        for (x in 0...worldSize) {
            newWorld.push([]);
            for (y in 0...worldSize) {
                if (randomize) {
                    newWorld[x].push(Random.bool());
                } else {
                    newWorld[x].push(false);
                }
            }
        }
        return newWorld;
    }

    function setCellAtMouse(x : Int, y : Int) {
        var cellX = Std.int(x / cellSize);
        var cellY = Std.int(y / cellSize);

        if (cellX >= 0 && cellX < worldSize && cellY >= 0 && cellY < worldSize) {
            world[cellX][cellY] = true;
        }
    }

    function onEvent(event : hxd.Event) {
        if (event.kind == EPush) {
            if (event.button == paintButton) {
                painting = true;
            } else {
                running = !running;
            }
        } else if (event.kind == EMove && painting) {
            setCellAtMouse(cast(s2d.mouseX, Int), cast(s2d.mouseY, Int));
        } else if (event.kind == ERelease && event.button == paintButton) {
            painting = false;
        }
    }

    function minInt(first : Int, second : Int) {
        if (first < second) {
            return first;
        }
        return second;
    }

    function maxInt(first: Int, second : Int) {
        if (first > second) {
            return first;
        }
        return second;
    }

    function simulateCell(cellX : Int, cellY : Int) {
        var alive : Int = 0;

        for ( x in maxInt(cellX - 1, 0) ... minInt(cellX + 1, worldSize - 1) + 1 ) {
            for ( y in maxInt(cellY - 1, 0) ... minInt(cellY + 1, worldSize - 1) + 1 ) {
                if (x == cellX && y == cellY ) {
                    continue;
                } else if (world[x][y]) {
                    alive += 1;
                }
            }
        }

        if (world[cellX][cellY]) {
            return alive == 2 || alive == 3;
        } else {
            return alive == 3;
        }
    }

    function simulate() {
        var newWorld = createEmptyWorld(false);
        for (x in 0...worldSize) {
            for (y in 0...worldSize) {
                newWorld[x][y] = simulateCell(x, y);
            }
        }
        world = newWorld;
    }
}