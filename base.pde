float density = .0; //densidad de dibujado //<>//
float doubleDensity = .2;
float blackCell = .3; //densidad de celdas negras
float victimDensity = .1;
float checkpoint = .015; //densidad de checkpoints
int xSize;
int ySize;

Robot robot = new Robot(0, 0);
Cell lastCheckpoint = new Cell(0, 0, 0);
Cell[] history = new Cell[0];
Cell[][][] arena; //crea arena
Cell example = new Cell(0, 0, 0);
void setup() {

  size(1200, 600); //tamaño pantalla, ahora el doble de ancho
  //habría que destinar la mitad derecha de la pantalla para mostrar la pista desde el punto de vista del robot
  xSize = int((width)/2/example.wid); //determina ancho arena
  ySize = int((height)/example.wid); //determina alto arena
  frameRate(60);
  arena = new Cell[5][ySize][xSize]; //setea tamaño arena al ancho de las arena

  int px, py;



  for (int h = 0; h < 5; h++) {
    for (int i = 0; i < ySize; i++) {
      for (int j = 0; j < xSize; j++) {
        arena[h][i][j] = new Cell(h, j, i); //crea las baldosas
      }
    }
  }
  do {
    if (random(1) > 0.5) { //posiciona el robot en un borde a una altura random
      if (random(1) > 0.5) px = 0;
      else px = xSize-1;
      py = int(random(ySize));
    } else {
      if (random(1) > 0.5) py = 0;
      else py = ySize-1;
      px = int(random(xSize));
    }
  } while (arena[0][py][px].black || arena[0][py][px].exit);

  for (int h = 0; h < 4; h++) {
    int place;
    switch(int(random(4))) {
    case 0:
      do {
        place = int(random(xSize));
      } while (arena[h][0][place].black || arena[h+1][0][place].black || arena[h][0][place].exit);
      arena[h][0][place].exit = true;
      arena[h+1][0][place].exit = true;
      break;
    case 1:
      do {
        place = int(random(xSize));
      } while (arena[h][ySize-1][place].black || arena[h+1][ySize-1][place].black || arena[h][ySize-1][place].exit);
      arena[h][ySize-1][place].exit = true;
      arena[h+1][ySize-1][place].exit = true;
      break;
    case 2:
      do {
        place = int(random(ySize));
      } while (arena[h][place][0].black || arena[h+1][place][0].black || arena[h][place][0].exit);
      arena[h][place][0].exit = true;
      arena[h+1][place][0].exit = true;
      break;
    default:
      do {
        place = int(random(ySize));
      } while (arena[h][place][xSize-1].black || arena[h+1][place][xSize-1].black || arena[h][place][xSize-1].exit);
      arena[h][place][xSize-1].exit = true;
      arena[h+1][place][xSize-1].exit = true;
    }
  }

  robot = new Robot(px, py);
  arena[robot.z][py][px].start = true;
  arena[robot.z][py][px].visited = true;
  robot.start();
  robot.dibujar(0);
  robot.dibujar(xSize);
  lastCheckpoint = arena[robot.z][py][px];
}


void draw() {
  background(255, 255, 240); //fondo
  frameRate(30);
  //println(frameRate);
  fill(0);
  text(robot.z, 20, 20);
  text(robot.floorDir, 20, 40);
  robot.recorrer();
  for (int i = 0; i < ySize; i++) {
    for (int j = 0; j < xSize; j++) {
      arena[robot.z][i][j].dibujar(0); //dibuja las baldosas, ahora con un parámetro
      if (arena[robot.z][i][j].visited)arena[robot.z][i][j].dibujar(xSize);//se replican las baldosas visitadas en la otra mitad de la pantalla.
    }
  }
  robot.dibujar(0);
  robot.dibujar(xSize);
}


class Cell {
  boolean north = false; //resetea todas las paredes para la baldosa nueva
  boolean south = false;
  boolean check = false;
  boolean east = false;
  boolean west = false;
  boolean visited = false;
  boolean start = false;
  boolean black = false;
  boolean exit = false;
  boolean oneKit = false;
  boolean twoKits = false;
  char victim = 'F';
  char victimStatus = 'F';
  int stack = robot.cont++;
  int weight = 9999;
  boolean out = false;
  char[] instructions = {};

  int x, y, z, wid = 30;
  //int px, py;

  Cell(int bz, int bx, int by) { 

    x = bx;
    y = by;
    z = bz;
    //px = x/wid;
    if (by == 0)//dibuja borde superior
      north = true;
    else if (arena[z][by-1][bx].south) //sino si la baldosa superior tiene una pared en sur 
      north = true;
    if (bx == 0)//dibuja borde izquierdo
      west = true;
    else if (arena[z][by][bx-1].east) //sino si la baldosa a su izquierda tiene una pared este
      west = true;
    if (by == ySize-1)//dibuja borde inferior
      south = true;
    if (bx == xSize-1)//dibuja borde derecho
      east = true; 

    if (random(1) < blackCell)black=true;
    if (random(1) < density) { //pregunta si dibuja o no
      if (random(1) < doubleDensity && (!west || !north)) { //pregunta si dibuja 2 paredes o una
        south = true;
        east = true;
      } else if (random(1) < 0.5) south = true;//dibuja abajo
      else east = true;//dibuja a la derecha
    }

    if (random(1) < victimDensity && !black) { //where to place victims (if it does)
      if (random(1) < 0.3)victimStatus = 'U';
      else if (random(1) < 0.5)victimStatus = 'S';
      else victimStatus = 'H';
      if (north)victim = 'N';
      if (east)victim = 'E';
      if (south)victim = 'S';
      if (west)victim = 'W';
    }

    if (random(1) < checkpoint && !black) {
      check = true;
    }
  }

  void dibujar(int off) {//off es un parámetro que indica un desfazaje al pedir el dibujo de la baldosa. Se suma a x y después se revierte al salir.
    x+=off;
    //px+=off;
    strokeWeight(2);
    stroke(0);
    if (north)line(x*wid, y*wid, (x+1)*wid, y*wid);//north
    if (east)line((x+1)*wid, y*wid, (x+1)*wid, (y+1)*wid);//east
    if (south) line(x*wid, (y+1)*wid, (x+1)*wid, (y+1)*wid);//south
    if (west)line(x*wid, y*wid, x*wid, (y+1)*wid);//west

    strokeWeight(0); // cuadricula gris
    stroke(0, 50);
    line(x*wid, y*wid, (x+1)*wid, y*wid);
    line((x+1)*wid, y*wid, (x+1)*wid, (y+1)*wid);

    if (victimStatus == 'H')fill(255, 0, 0);
    if (victimStatus == 'S')fill(255, 255, 0);
    if (victimStatus == 'U')fill(0, 255, 0);
    strokeWeight(0);
    switch(victim) {
    case 'N':
      rect(x*wid +10, y*wid +2, 10, 5);
      break;
    case 'E':
      rect(x*wid +24, y*wid +10, 5, 10);
      break;
    case 'S':
      rect(x*wid +10, y*wid +24, 10, 5);
      break;
    case 'W':
      rect(x*wid +2, y*wid +10, 5, 10);
      break;
    }

    if (visited && off != 0) {
      stroke(50, 170, 50, 100);
      strokeWeight(2);
      fill(50, 170, 50, 50);
      rect(x*wid+6, y*wid+6, wid-12, wid-12);
    }
    if (start) {
      strokeWeight(2);
      fill(0, 255, 0, 200);
      stroke(0, 255, 0);
      rect(x*wid+3, y*wid+3, wid-6, wid-6);
    }
    if (check) {
      stroke(200, 200, 200);
      fill(200, 200, 200, 200);
      strokeWeight(2);
      rect(x*wid+3, y*wid+3, wid-6, wid-6);
    }
    if (black) {
      stroke(0);
      strokeWeight(2);
      fill(0, 200);
      rect(x*wid+4, y*wid+4, wid-8, wid-8);
    }
    if (exit) {
      strokeWeight(2);
      stroke(0, 0, 255);
      fill(0, 0, 255, 200);
      rect(x*wid+5, y*wid+5, wid-10, wid-10);
    }
    if (oneKit) {
      stroke(0, 255, 0);
      strokeWeight(2);
      fill(255, 255, 0);
      rect(x*wid+10, y*wid +10, 10, 10);
    }
    if (twoKits) {
      stroke(0, 255, 0);
      strokeWeight(2);
      fill(255, 255, 0);
      rect(x*wid+5, y*wid+10, 7, 7);
      rect(x*wid+17, y*wid+10, 7, 7);
    }
    x-=off;
    //px-=off;
  }
}


void mousePressed() { //al hacer click refrescar pista
  setup();
}
void keyPressed() {
  for (int h = 0; h < 5; h++) {
    for (int i = 0; i < ySize; i++) {
      for (int j = 0; j < xSize; j++) {
        for (int k = 0; k < history.length; k++) {
          if (h == history[k].z && i == history[k].y && j == history[k].x) {
            arena[h][i][j].visited = false;
          }
        }
      }
    }
  }
  robot.z = lastCheckpoint.z;
  robot.y = lastCheckpoint.y;
  robot.x = lastCheckpoint.x;
}

class Robot {
  int x, y, z;
  //int py, px;
  char dir;//dir podrá ser 'N','S','E', o 'W', indica la dirección actual del robot.
  int cont;
  float wid = 30;
  boolean ignore = false;
  boolean finished = false;
  int floorDir = 1;

  Robot(int bx, int by) {
    cont = 0;
    x = bx;
    y = by;
    z = 0;
  }

  void start() {
    switch(y) {
    case 0:
      dir = 'W';
      break;

    case 19:
      dir = 'E';
      break;

    default:
      switch(x) {
      case 0:
        dir = 'S';
        break;

      default:
        dir = 'N';
      }
    }
  }

  void search(Cell compareFrom) {
    println("SEARCHING...");
    Cell compareTo;// = compareFrom;//Celda que será vista desde compareFrom
    Cell[] options = new Cell[0];//array de opciones que almacena las celdas desde las que se podría comparar después
    int amount = 0;//cantidad de celdas en el arreglo
    arena[z][compareFrom.y][compareFrom.x].weight = 0;//el peso de la celda actual es 0
    compareFrom.weight = 0;
    finished = end();
    while ((!check(compareFrom.y, compareFrom.x) && !finished) || (finished && !compareFrom.start && !compareFrom.exit)) {//hasta que se empiece a comparar desde una celda con vecinos sin visitar.
      arena[z][compareFrom.y][compareFrom.x].out = true;//Se marca la baldosa en la matriz
      if (!compareFrom.north) {//no hay pared arriba
        if (!arena[z][compareFrom.y-1][compareFrom.x].out && !(arena[z][compareFrom.y-1][compareFrom.x].black && arena[z][compareFrom.y-1][compareFrom.x].visited)) {//la baldosa de arriba no ha sido explorada
          compareTo = arena[z][compareFrom.y-1][compareFrom.x];//Se usa para comparar
          if (compareFrom.weight+1 < compareTo.weight) {//Viajar desde el lugar actual hacia allá es mejor que desde el lugar anterior
            compareTo.weight = compareFrom.weight+1;//Se cambia su peso
            compareTo.instructions = compareFrom.instructions;//Se copian las instrucciones para llegar a compareFrom
            compareTo.instructions = append(compareTo.instructions, 'N');//Se añade una instrucción más para llegar a compareTo
            options = (Cell[])append(options, compareTo);//Se añade a las opciones para explorar más tarde
            amount++;//Se suma 1 a la cantidad de opciones
            arena[z][compareTo.y][compareTo.x] = compareTo;//Se actualiza la matriz con la nueva información
          }
        }
      }
      if (!compareFrom.east && compareFrom.x != xSize-1) {//no hay pared a la derecha
        if (!arena[z][compareFrom.y][compareFrom.x+1].out && !(arena[z][compareFrom.y][compareFrom.x+1].black && arena[z][compareFrom.y][compareFrom.x+1].visited)) {//la baldosa de la derecha no ha sido explorada
          compareTo = arena[z][compareFrom.y][compareFrom.x+1];//Se usa para comparar
          if (compareFrom.weight+1 < compareTo.weight) {//Viajar desde el lugar actual hacia allá es mejor que desde el lugar anterior
            compareTo.weight = compareFrom.weight+1;//Se cambia su peso
            compareTo.instructions = compareFrom.instructions;//Se copian las instrucciones para llegar a compareFrom
            compareTo.instructions = append(compareTo.instructions, 'E');//Se añade una instrucción más para llegar a compareTo
            options = (Cell[])append(options, compareTo);//Se añade a las opciones para explorar más tarde
            amount++;//Se suma 1 a la cantidad de opciones
            arena[z][compareTo.y][compareTo.x] = compareTo;//Se actualiza la matriz con la nueva información
          }
        }
      }
      if (!compareFrom.south && compareFrom.y != ySize-1) {//no hay pared abajo
        if (!arena[z][compareFrom.y+1][compareFrom.x].out && !(arena[z][compareFrom.y+1][compareFrom.x].black && arena[z][compareFrom.y+1][compareFrom.x].visited)) {//la baldosa de abajo no ha sido explorada
          compareTo = arena[z][compareFrom.y+1][compareFrom.x];//Se usa para comparar
          if (compareFrom.weight+1 < compareTo.weight) {//Viajar desde el lugar actual hacia allá es mejor que desde el lugar anterior
            compareTo.weight = compareFrom.weight+1;//Se cambia su peso
            compareTo.instructions = compareFrom.instructions;//Se copian las instrucciones para llegar a compareFrom
            compareTo.instructions = append(compareTo.instructions, 'S');//Se añade una instrucción más para llegar a compareTo
            options = (Cell[])append(options, compareTo);//Se añade a las opciones para explorar más tarde
            amount++;//Se suma 1 a la cantidad de opciones
            arena[z][compareTo.y][compareTo.x] = compareTo;//Se actualiza la matriz con la nueva información
          }
        }
      }
      if (!compareFrom.west) {//no hay pared a la izquierda
        if (!arena[z][compareFrom.y][compareFrom.x-1].out && !(arena[z][compareFrom.y][compareFrom.x-1].black && arena[z][compareFrom.y][compareFrom.x-1].visited)) {//la baldosa de la izquierda no ha sido explorada
          compareTo = arena[z][compareFrom.y][compareFrom.x-1];//Se usa para comparar
          //stroke(0, 0, 150);
          //strokeWeight(15);
          //point((compareFrom.x+xSize)*wid+15, compareTo.y*wid+15);
          if (compareFrom.weight+1 < compareTo.weight) {//Viajar desde el lugar actual hacia allá es mejor que desde el lugar anterior
            compareTo.weight = compareFrom.weight+1;//Se cambia su peso
            compareTo.instructions = compareFrom.instructions;//Se copian las instrucciones para llegar a compareFrom
            compareTo.instructions = append(compareTo.instructions, 'W');//Se añade una instrucción más para llegar a compareTo
            options = (Cell[])append(options, compareTo);
            //Se añade a las opciones para explorar más tarde
            amount++;//Se suma 1 a la cantidad de opciones
            arena[z][compareTo.y][compareTo.x] = compareTo;//Se actualiza la matriz con la nueva información
          }
        }
      }

      int bestWeight = 9999;
      for (int i = 0; i < amount; i++) {//Se recorre el arreglo para buscar las celdas con el menor costo
        if (arena[z][options[i].y][options[i].x].weight < bestWeight && !arena[z][options[i].y][options[i].x].out) {
          bestWeight = options[i].weight;
        }
      }
      for (int i = 0; i < amount; i++) {
        if (!arena[z][options[i].y][options[i].x].out && arena[z][options[i].y][options[i].x].weight == bestWeight) {
          compareFrom = options[i];
          break;
        }
      }
    }

    strokeWeight(15);
    for (int i = 0; i < amount; i++) {//Se recorre el arreglo para buscar las celdas con el menor costo
      if (arena[z][options[i].y][options[i].x].out) {
        stroke(0, 0, 0, 200);
        point((options[i].x+xSize)*wid+15, options[i].y*wid+15);
      } else {
        stroke(255, 0, 0);
        point((options[i].x+xSize)*wid+15, options[i].y*wid+15);
      }
    }
    println(compareFrom.y);
    println(compareFrom.x);
    follow(compareFrom);

    for (int i = 0; i < ySize; i++) {
      for (int j = 0; j < xSize; j++) {
        arena[z][i][j].weight = 9999;
        arena[z][i][j].out = false;
        arena[z][i][j].instructions = new char[0];
      }
    }
    ignore = true;
  }

  boolean end() {
    for (int i = 0; i < ySize; i++) {
      for (int j = 0; j < xSize; j++) {
        if (arena[z][i][j].visited && !arena[z][i][j].black) {
          if (check(i, j))return false;
        }
      }
    }
    return true;
  }

  void follow(Cell target) {
    println("FOLLOWING");
    if (target.weight == 0 || target.weight > 4)frameRate(2);
    char heading;
    stroke(0, 0, 255);
    strokeWeight(15);
    for (int i = 0; i < target.weight; i++) {
      println(target.instructions[i]);
      heading = target.instructions[i];
      strokeWeight(15);
      point((x+xSize)*wid+15, y*wid+15);
      dir = heading;
      strokeWeight(5);
      switch(heading) {
      case 'N':
        line((x+xSize)*wid+15, y*wid+15, (x+xSize)*wid+15, (y-1)*wid+15);
        y--;
        break;

      case 'S':
        line((x+xSize)*wid+15, y*wid+15, (x+xSize)*wid+15, (y+1)*wid+15);
        y++;
        break;

      case 'W':
        line((x+xSize)*wid+15, y*wid+15, (x-1+xSize)*wid+15, y*wid+15);
        x--;
        break;

      default:
        line((x+xSize)*wid+15, y*wid+15, (x+1+xSize)*wid+15, y*wid+15);
        x++;
      }
    }
    strokeWeight(15);
    point((x+xSize)*wid+15, y*wid+15);
  }

  boolean check(int y, int x) {
    if (!arena[z][y][x].north) {
      if (!arena[z][y-1][x].visited) {
        return true;
      }
    }
    if (!arena[z][y][x].south) {
      if (!arena[z][y+1][x].visited) {
        return true;
      }
    } 
    if (!arena[z][y][x].east) {
      if (!arena[z][y][x+1].visited) {
        return true;
      }
    }
    if (!arena[z][y][x].west) {
      if (!arena[z][y][x-1].visited) {
        return true;
      }
    }
    return false;
  }

  void init() {
    ignore = true;
    if (check(y, x)) {
      switch(dir) {
      case 'N':
        dir = 'W';
        if (!arena[z][y][x].west) {
          if (!arena[z][y][x-1].visited) {
            ignore = true;
            return;
          } else init();
        } else init();

      case 'W':
        dir = 'S';
        if (!arena[z][y][x].south) {
          if (!arena[z][y+1][x].visited) {
            ignore = true;
            return;
          } else init();
        } else init();

      case 'S':
        dir = 'E';
        if (!arena[z][y][x].east) {
          if (!arena[z][y][x+1].visited) {
            ignore = true;
            return;
          } else init();
        } else init();

      case 'E':
        dir = 'N';
        if (!arena[z][y][x].north) {
          if (!arena[z][y-1][x].visited) {
            ignore = true;
            return;
          } else init();
        } else init();
      }
    } //else ignore = true;
  }

  void dibujar(int off) {
    x+=off;
    fill(0, 0, 255);
    stroke(0, 0, 255, 60);
    strokeWeight(2);
    rect(x*wid+4, y*wid+4, wid-8, wid-8);
    fill(255, 50, 50);
    switch(dir) {
    case 'N' : 
      rect(x*wid+4, y*wid+4, wid-8, wid/6); 
      break;
    case 'E' : 
      rect(x*wid+wid-8, y*wid+4, wid/6, wid-8); 
      break;
    case 'S' : 
      rect(x*wid+4, y*wid+wid-8, wid-8, wid/6); 
      break;
    default : 
      rect(x*wid+4, y*wid+4, wid/6, wid-8);
    }
    x-=off;
    if (arena[z][y][x].victim != 'F' && arena[z][y][x].oneKit == false && arena[z][y][x].victimStatus == 'S')arena[z][y][x].oneKit = true;
    if (arena[z][y][x].victim != 'F' && arena[z][y][x].twoKits == false && arena[z][y][x].victimStatus == 'H')arena[z][y][x].twoKits = true;
  }

  void recorrer() {

    //if (!ignore)arena[z][y][x].stack = cont++;
    //px = x;
    //py = y;

    ignore = false;

    if (finished) floorDir = -1;

    if (!check(y, x))
      if (!arena[z][y][x].exit)search(arena[z][y][x]);
      else {
        z += floorDir;
        if (floorDir < 0) {
          arena[z][y][x].exit = false;
        }
      }
    //if (!ignore) {
    switch (dir) {
    case 'N'://está yendo hacia arriba
      if (!arena[z][y][x].east) {//y encuentra una baldosa a su derecha
        if (!arena[z][y][x+1].visited) {//no está visitada
          dir = 'E';
          ignore = true;
        } else if (arena[z][y][x].north) {//hay una pared al frente
          init();
        } else if (arena[z][y-1][x].visited) {
          init();
        }
      } else if (arena[z][y][x].north) {//o una pared al frente
        init();
      } else if (arena[z][y-1][x].visited) {
        init();
      }
      break;
    case 'W'://está yendo hacia la izquierda
      if (!arena[z][y][x].north) {//y encuentra una baldosa a su derecha
        if (!arena[z][y-1][x].visited) {
          dir = 'N';
          ignore = true;
        } else if (arena[z][y][x].west) {//o una pared al frente
          init();
        } else if (arena[z][y][x-1].visited) {
          init();
        }
      } else if (arena[z][y][x].west) {//o una pared al frente
        init();
      } else if (arena[z][y][x-1].visited) {
        init();
      }
      break;
    case 'S'://está yendo hacia abajo
      if (!arena[z][y][x].west) {//y encuentra una baldosa a su derecha
        if (!arena[z][y][x-1].visited) {
          dir = 'W';
          ignore = true;
        } else if (arena[z][y][x].south) {//o una pared al frente
          init();
        } else if (arena[z][y+1][x].visited) {
          init();
        }
      } else if (arena[z][y][x].south) {//o una pared al frente
        init();
      } else if (arena[z][y+1][x].visited) {
        init();
      }
      break;
    default:
      if (!arena[z][y][x].south) {//está yendo a la derecha y encuentra una baldosa a su derecha
        if (!arena[z][y+1][x].visited) {
          dir = 'S';
          ignore = true;
        } else if (arena[z][y][x].east) {//o una pared al frente
          init();
        } else if (arena[z][y][x+1].visited) {//o está visitada al frente
          init();
        }
      } else if (arena[z][y][x].east) {//o una pared al frente
        init();
      } else if (arena[z][y][x+1].visited) {//o está visitada al frente
        init();
      }
    }
    //}
    if (!ignore) {
      //lo que significa cada dirección en términos de índices
      switch(dir) {
      case 'N': 
        y--; 
        break;
      case 'E': 
        x++; 
        break;
      case 'S': 
        y++; 
        break;
      default: 
        x--;
      }
      //delay(200);
      arena[z][y][x].visited = true;
      //arena[z][y][x].px = px;
      //arena[z][y][x].py = py;

      if (arena[z][y][x].black) {
        ignore = true;
        switch (dir) {
        case 'N': 
          y++; 
          break;
        case 'E': 
          x--; 
          break;
        case 'S': 
          y--; 
          break;
        default: 
          x++;
        }
      } else if (arena[z][y][x].exit) {
        if (!arena[z][y][x].check) {
          history = (Cell[])append(history, arena[z][y][x]);
        } else {
          history = new Cell[0];
          lastCheckpoint = arena[z][y][x];
        }
        arena[z][y][x].visited = true;
        if (z < 5) {
          z += floorDir;
          ignore = true;
          arena[z][y][x].visited = true;
        }
      }
    }
    if (!arena[z][y][x].check) {
      history = (Cell[])append(history, arena[z][y][x]);
    } else { 
      history = new Cell[0];
      lastCheckpoint = arena[z][y][x];
    }
  }
}
