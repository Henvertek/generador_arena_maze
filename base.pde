float density = .6; //densidad de dibujado
float doubleDensity = .3;//densidad de dibujado de 2 paredes

float blackCell = .01; //densidad de celdas negras

int checkpoint = 2; //densidad de checkpoints

int xSize;


int ySize;

Robot robot = new Robot(3, 0);

Cell[][] arena; //crea arena
Cell ex = new Cell(0, 0);//ejemplo para tomar medidas de la pista

void setup() {
  size(600, 300); //tamaño pantalla, ahora el doble de ancho
  //habría que destinar la mitad derecha de la pantalla para mostrar la pista desde el punto de vista del robot

  xSize = int(width/2/ex.wid); //determina ancho arena
  ySize = int(height/ex.wid); //determina alto arena
  arena = new Cell[ySize][xSize]; //setea tamaño arena al ancho de las arena

  int px, py;//posición inicial del robot

  if (random(1) > 0.5) { //50% prob de iniciar en una pared de los costados
    if (random(1) > 0.5) px = 0;//50% prob. de iniciar en el lado izquierdo
    
    else px = xSize-1;//50% prob. de iniciar en el lado derecho
    
    py = int(random(ySize));//altura aleatoria
  }
  else {//Iniciar en una pared de arriba o abajo
    if (random(1) > 0.5) py = 0;//50% prob. de iniciar  arriba
  
    else py = ySize-1;//50% prob. de iniciar abajo

    px = int(random(xSize));//longitud aleatoria
  }
  
  for (int i = 0; i < xSize; i++) {
    for (int j = 0; j < ySize; j++) {
      arena[i][j] = new Cell(j, i); //crea las baldosas
    }
  }

  robot = new Robot(px, py);//se crea y posiciona el robot
  arena[py][px].start = true;//la baldosa inicial se marca como tal
  
  arena[robot.y][robot.x].stack = robot.cont++;
  arena[robot.y][robot.x].visited = true;

  robot.start();//el robot se acomoda según la pared en la que inició
  robot.dibujar(0);//Se dibuja el robot en su posición actual
  robot.dibujar(xSize);//Se dibuja su copia a la derecha
}


void draw() {

  background(255, 255, 240); //fondo

  robot.recorrer();//se actualiza la posición del robot
  robot.dibujar(0);//Se dibuja el robot en su posición actual
  robot.dibujar(xSize);//Se dibuja su copia a la derecha

  for (int i = 0; i < ySize; i++) {
    for (int j = 0; j < xSize; j++) {
      arena[i][j].dibujar(0); //dibuja las baldosas, ahora con un parámetro
      if (arena[i][j].visited)arena[i][j].dibujar(width/2);//se replican las baldosas visitadas en la otra mitad de la pantalla.
    }
  }
}


class Cell {

  boolean north = false;//resetea todas las paredes para la baldosa nueva
  boolean south = false;//pared al norte
  boolean east = false;//pared al este
  boolean west = false;//pared al oeste
  boolean visited = false;//baldosa visitada
  boolean start = false;//baldosa inicial
  boolean black = false;//baldosa afroamericana
  int stack = 0;//qué número de baldosa visitada es(TEMPORAL HASTA APLICAR DIJKSTRA)


  int x, y;
  int wid = 30;//dimensión de las baldosas, 30px * 30px
  int px = 0, py = 0;//previous X, previous Y, para dibujar el camino de las baldosas

  Cell(int bx, int by){//p determmina si se dibuja o no

    x = bx * wid;
    y = by * wid;
    //px = x/wid;

    if (by == 0)//dibuja borde superior
      north = true;
    else if (arena[by-1][bx].south) //sino si la baldosa superior tiene una pared en sur 
      north = true;
    if (bx == 0)//dibuja borde izquierdo
      west = true;
    else if (arena[by][bx-1].east) //sino si la baldosa a su izquierda tiene una pared este
      west = true;
    if (by == ySize-1)//dibuja borde inferior
      south = true;
    if (bx == xSize-1)//dibuja borde derecho
      east = true; 

    if (random(1)< blackCell)black=true;//ocasionalmente genera una baldosa negra


    if (random(1) < density) { //pregunta si dibuja o no
      if (random(1) < doubleDensity && (!west || !north)) { //pregunta si dibuja 2 paredes o una
        south = true;
        east = true;
      } else if (random(1) < 0.5) {//dibuja abajo
        south = true;
      } else {//dibuja a la derecha
        east = true;
      }
    }
  }


  void dibujar(int off) {//off es un parámetro que indica un desfazaje al pedir el dibujo de la baldosa. Se suma a x y después se revierte al salir.
    x+=off;//se desfaza X
    
    strokeWeight(2);//grosor de paredes
    stroke(0);//color de paredes
    if (north)line(x, y, x+wid, y);//north
    if (east)line(x+wid, y, x+wid, y+wid);//east
    if (south) line(x, y+wid, x+wid, y+wid);//south
    if (west)line(x, y, x, y+wid);//west

    strokeWeight(0);//grosor de cuadrícula
    stroke(0, 50);//color gris de cuadrícula
    line(x, y, x+wid, y);//línea superior
    line(x+wid, y, x+wid, y+wid);//línea derecha
    
    if (visited) {
      strokeWeight(2);//grosor de borde de rectángulo verde
      stroke(50,170,50,100);
      fill(50, 170, 50, 50);//color de rectángulo verde
      rect(x+6, y+6, wid-12, wid-12);//rectángulo pequeño
      //fill(0);
      //text(stack, x + 10, y + 20);
      strokeWeight(2);
      stroke(0, 0, 255, 100);//línea azul que muestra el camino tomado
      if (stack>0)line(px*wid + 15, py*wid + 15, x-off + 15, y + 15);//a partir del primer movimiento, dibuja desde previous px;py a x;y
    }

    if (start) {//casilla inicial
      stroke(0,0,255,100);//borde azul
      strokeWeight(2);//grosor del borde
      fill(0, 255, 0);//relleno
      rect(x+6, y+6, wid-12, wid-12);//marca
    }
    
    if (black) {//casilla negra
      stroke(0);
      strokeWeight(2);
      fill(50);
      rect(x+3, y+3, wid-6, wid-6);//ligeramente más pequeña
    }

    x-=off;//deshacer el desfazaje
  }
}


void mousePressed() { //al hacer click refrescar pista
  delay(30);
  setup();
}


class Robot {
  int x, y;//x e y igual que índices
  int py, px;//previous X e Y
  char dir;//dir podrá ser 'N','S','E', o 'W', indica la dirección actual del robot.
  int cont;//cuántas baldosas ha visitado al momento(HASTA IMPLEMENTAR DIJKSTRA)
  float wid = 30;//el robot es más pequeño, pero se usa el tamaño de las baldosas para

  Robot(int bx, int by) {
    cont = 0;
    x = bx;
    y = by;
  }

  void start() {//decide cómo orientarse según en qué pared empieza
    switch(y) {
    case 0://borde superior
      dir = 'W';
      break;

    case 19://borde inferior
      dir = 'E';
      break;

    default:
      switch(x) {
      case 0://borde izquierdo
        dir = 'S';
        break;

      default://borde derecho
        dir = 'N';
      }
    }
  }

  boolean check(int y, int x) {//devuelve si hay o no baldosas adyacentes sin visitar
    if (!arena[y][x].north) {
      if (!arena[y-1][x].visited && !arena[y-1][x].black) {
        return true;
      }
    }
    if (!arena[y][x].south) {
      if (!arena[y+1][x].visited && !arena[y+1][x].black) {
        return true;
      }
    } 
    if (!arena[y][x].east) {
      if (!arena[y][x+1].visited && !arena[y][x+1].black) {
        return true;
      }
    }
    if (!arena[y][x].west) {
      if (!arena[y][x-1].visited && !arena[y][x-1].black) {
        return true;
      }
    }
    return false;//no las hay
  }

  void stack() {//recorre el laberinto hacia atrás para encontrar una baldosa sin visitar(HASTA IMPLEMENTAR DIJKSTRA)
    int best = 9999;//mejor diferencia (número de baldosa actual - número de baldosa con la que se compara)
    int bestY = 0, bestX = 0;//coordenadas de la mejor opción disponible
    int bestStack = 0;//número de la baldosa elegida
    for (int i = 0; i < ySize; i++) {
      for (int j = 0; j < xSize; j++) {
        if (arena[i][j].visited) {//compara con todas las que ya visitó
          if (arena[y][x].stack - arena[i][j].stack < best && check(i, j)) {//se fija si es la más cercana hasta ahora que tiene baldosas adyacentes por descubrir
            best = arena[y][x].stack - arena[i][j].stack;//guarda la "mejor distancia"
            bestY = i;
            bestX = j;
            bestStack = arena[i][j].stack;
          }
        }
      }
    }
    for (int i = 0; i < ySize; i++) {
      for (int j = 0; j < xSize; j++) {
        if (arena[i][j].visited && arena[i][j].stack == bestStack+1) {//busca la baldosa visitada justo después de la elegida para ver cómo orientarse(debido a que usa un warp para llegar)
          if (i < bestY) {
            dir = 'S';
          } else if (i > bestY) {
            dir = 'N';
          } else if (j < bestX) {
            dir = 'E';
          } else if (j > bestX) {
            dir = 'W';
          }
        }
      }
    }
    if(best  == 9999){//no hay baldosas por descubrir
      delay(1500);
      mousePressed();
    }
    x = bestX;
    y = bestY;
  }


  void init() {//cuando hay un obstáculo, gira
    switch(dir) {
    case 'N':
      dir = 'W';
      if (!arena[y][x].west) {
        if (!arena[y][x-1].visited && !arena[y][x-1].black) {
          return;
        } else init();
      } else init();

    case 'W':
      dir = 'S';
      if (!arena[y][x].south) {
        if (!arena[y+1][x].visited && !arena[y+1][x].black) {
          return;
        } else init();
      } else init();

    case 'S':
      dir = 'E';
      if (!arena[y][x].east) {
        if (!arena[y][x+1].visited && !arena[y][x+1].black) {
          return;
        } else init();
      } else init();

    case 'E':
      dir = 'N';
      if (!arena[y][x].north) {
        if (!arena[y-1][x].visited && !arena[y-1][x].black) {
          return;
        } else init();
      } else init();
    }
  }

  void dibujar(int off) {
    x+=off;
    fill(0, 0, 255);
    stroke(255,50,50,100);
    strokeWeight(2);
    rect(x*wid+4, y*wid+4, wid-8, wid-8);
    fill(255, 50, 50);
    noStroke();
    if (dir=='N')rect(x*wid+4, y*wid+4, 22, 5);
    else if (dir=='E')rect(x*wid+22, y*wid+4, 5, 22);
    else if (dir=='S')rect(x*wid+4, y*wid+22, 22, 5);
    else if (dir=='W')rect(x*wid+4, y*wid+4, 5, 22);

    x-=off;
  }
  void recorrer() {

    
    px = x;
    py = y;

    if (!check(y, x))stack();

    if (dir == 'N') {//está yendo hacia arriba
      if (!arena[y][x].east) {//y encuentra una baldosa a su derecha
        if (!arena[y][x+1].visited && !arena[y][x+1].black) {//no está visitada
          dir = 'E';
        } else if (arena[y][x].north) {//hay una pared al frente
          init();
        } else if (arena[y-1][x].visited || arena[y-1][x].black) {
          init();
        }
      } else if (arena[y][x].north) {//o una pared al frente
        init();
      } else if (arena[y-1][x].visited || arena[y-1][x].black) {
        init();
      }
    } else if (dir == 'W') {//está yendo hacia la izquierda
      if (!arena[y][x].north) {//y encuentra una baldosa a su derecha
        if (!arena[y-1][x].visited && !arena[y-1][x].black) {
          dir = 'N';
        } else if (arena[y][x].west) {//o una pared al frente
          init();
        } else if (arena[y][x-1].visited || arena[y][x-1].black) {
          init();
        }
      } else if (arena[y][x].west) {//o una pared al frente
        init();
      } else if (arena[y][x-1].visited || arena[y][x-1].black) {
        init();
      }
    } else if (dir == 'S') {//está yendo hacia abajo
      if (!arena[y][x].west) {//y encuentra una baldosa a su derecha
        if (!arena[y][x-1].visited && !arena[y][x-1].black) {
          dir = 'W';
        } else if (arena[y][x].south) {//o una pared al frente
          init();
        } else if (arena[y+1][x].visited || arena[y+1][x].black) {
          init();
        }
      } else if (arena[y][x].south) {//o una pared al frente
        init();
      } else if (arena[y+1][x].visited || arena[y+1][x].black) {
        init();
      }
    } else if (!arena[y][x].south) {//está yendo a la derecha y encuentra una baldosa a su derecha
      if (!arena[y+1][x].visited && !arena[y+1][x].black) {
        dir = 'S';
      } else if (arena[y][x].east) {//o una pared al frente
        init();
      } else if (arena[y][x+1].visited || arena[y][x+1].black) {//o está visitada al frente
        init();
      }
    } else if (arena[y][x].east) {//o una pared al frente
      init();
    } else if (arena[y][x+1].visited || arena[y][x+1].black) {//o está visitada al frente
      init();
    }
    //lo que significa cada dirección en términos de índices

    if (dir == 'N') {
      y--;
    } else if (dir == 'E') {
      x++;
    } else if (dir == 'S') {
      y++;
    } else x--;
    arena[y][x].stack = cont++;
    arena[y][x].visited = true;
    //int del = 500;
    //delay(300);
    arena[y][x].px = px;
    arena[y][x].py = py;
  }
}