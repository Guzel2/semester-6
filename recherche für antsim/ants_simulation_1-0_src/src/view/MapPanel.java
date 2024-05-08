package view;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.util.ArrayList;

import javax.swing.JOptionPane;
import javax.swing.JPanel;


import model.Ant;
import model.MapPoint;



public class MapPanel extends JPanel implements MouseListener{
	private static final long serialVersionUID = 1L;
	private final Color COLOR_BORDER = new Color(156, 93, 82); // color for border and obstacles
	private final Color COLOR_FOOD = new Color(42, 194, 12); // color for food
	private final Color COLOR_HIVE = new Color(88, 88, 88); // color for hive
	private final Color COLOR_ANTS = Color.black; // color for ants
	private final Color COLOR_ANTS_RETURNER = Color.green; // color for returning ants
	private final Color COLOR_ANTS_RETURNER2 = Color.black; // color for returning ants
	private final Color COLOR_ANTS_FOLLOWER = Color.blue; // color for following ants
	private final Color COLOR_EMPTY = Color.white; // color for pheromone-less fields
	
	public static final int BRUSH_LIKE_BEFORE = -1;
	public static final int BRUSH_HIVE = 0;
	public static final int BRUSH_FOOD = 1;
	public static final int BRUSH_EMPTY = 2;
	public static final int BRUSH_BORDER = 3;
	
	private final int HIVE_SIZE = 2; // radius of the painted hive
	
	private MapPoint[][] map;
	private ArrayList<Ant> ants;
	private int num_x_points=1;
	private int num_y_points=1;
	private int x_pixels;
	private int y_pixels;
	private boolean mouse_pressed;
	private int dead_food; // food that has been collected by meanwhile dead ants
	
	//private Image offScreen; // background buffer
	//private Graphics gBuf; // graphics element of buffer
	
	private int brush_size;
	private int brush_type;
	private boolean running;
	
	private int hive_location_x;
	private int hive_location_y;
	private boolean hive_exists;
	
	private MapPanel th;
	
	public MapPanel() {
		super();
		mouse_pressed = false;
		running = false;
		dead_food = 0;
		this.hive_exists = false;
		th = this; // necessary for brush painting thread
		hive_location_x = -1;
		hive_location_y = -1;
		
		this.addMouseListener(this);
		this.setBackground(COLOR_BORDER);
	}
	
	public boolean hiveExists() {
		return hive_exists;
	}
	
	public Point getHiveLocation() {
		if (hive_location_x == (-1) && hive_location_y == (-1))
			return null;
		else
			return new Point(hive_location_x, hive_location_y);
	}
	
	public void setBrush(int brush_size, int brush_type) {
		this.brush_size = brush_size;
		if (brush_type != BRUSH_LIKE_BEFORE)
			this.brush_type = brush_type;
	}
	
	public void setRunning(boolean running) {
		this.running = running;
	}
	
	public int getDeadFood() {
		return dead_food;
	}
	
	public void resetDeadFood() {
		dead_food = 0;
	}
	
	// changes the type of a map point according to the bGroup selection
	private void changeMapPointType(MapPoint mp) {
		if (running == true || mp == null || mp.isBorderPoint(num_x_points, num_y_points)) 
			return;
		
		int plaque_size = brush_size;
		Point pos = mp.getPosition();
		Point antPos;
		int newType = MapPoint.TYPE_EMPTY;
		
		if (brush_type == BRUSH_HIVE) {
			mouse_pressed = false;
			for (int i = 0; i<num_x_points; i++) {
				for (int j = 0; j<num_y_points; j++) {
					if (map[i][j].returnType() == MapPoint.TYPE_HIVE) {
						JOptionPane.showMessageDialog(this, "Only one nest is allowed!", "Information", JOptionPane.INFORMATION_MESSAGE);
						return;
					}
				}
			}
			mp.setType(MapPoint.TYPE_HIVE);
			hive_exists = true;
			hive_location_x = mp.getPosition().x;
			hive_location_y = mp.getPosition().y;
		}
		else {
			if (brush_type == BRUSH_FOOD)
				newType = MapPoint.TYPE_FOOD;
			else if (brush_type == BRUSH_BORDER)
				newType = MapPoint.TYPE_BORDER;

			for(int dx = 0; dx < plaque_size; dx++) {
				for(int dy = 0; dy < plaque_size; dy++) {
					if ((int)pos.getX()+dx < (num_x_points-1) && (int)pos.getY()+dy < (num_y_points-1)) {
						if (newType == MapPoint.TYPE_BORDER) { // remove ants if obstacle is to be painted
							for (int i=0;i<ants.size();i++) {
								antPos = ants.get(i).getPosition();
								if (antPos.getX() == (pos.getX()+dx)
								 && antPos.getY() == (pos.getY()+dy)) {
									dead_food += ants.get(i).getFood();
									ants.remove(i);
								}
							}
						}
						if (map[(int)pos.getX()+dx][(int)pos.getY()+dy].returnType() == MapPoint.TYPE_HIVE)
							hive_exists = false;
						map[(int)pos.getX()+dx][(int)pos.getY()+dy].setType(newType);
					}
				}
			}
		}
	    repaint();
	}
	
	// locates a map point using given coordinates inside mapPanel
	private MapPoint locateMapPoint(Point p) {
		if (p == null) return null;
		int i = (int) Math.floor(p.getX() / x_pixels);
		int j = (int) Math.floor(p.getY() / y_pixels);
		
		if (i < num_x_points && j < num_y_points)
			return map[i][j];
		else
			return null;
	}
	

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		
		x_pixels = (int) Math.floor(this.getWidth() / num_x_points);
		y_pixels = (int) Math.floor(this.getHeight() / num_y_points);
		
		//offScreen = createImage(this.getWidth(), this.getHeight());
		//gBuf = offScreen.getGraphics();
		//gBuf.setColor(MainFrame.COLOR_BORDER);
		//gBuf.fillRect(0, 0, this.getWidth(), this.getHeight()); // for rounding errors in (xy)_pixels
		drawMap(g);
	}
	

	
	public void setMap(MapPoint[][] map, ArrayList<Ant> ants, Point hive_pos){
		this.map = map;
		this.ants = ants;
		num_x_points = map.length;
		num_y_points = map[0].length;
		hive_location_x = (int) hive_pos.getX();
		hive_location_y = (int) hive_pos.getY();
	}
	
	public void clearMap() {
		for(int i=0;i<num_x_points;i++) {
			for(int j=0;j<num_y_points;j++) {
				if (map[i][j].isBorderPoint(num_x_points, num_y_points))
					map[i][j] = new MapPoint(MapPoint.TYPE_BORDER2, new Point(i,j));
				else
					map[i][j] = new MapPoint(MapPoint.TYPE_EMPTY, new Point(i,j));
			}
		}
		hive_exists = false;
	}
	
	private void drawMap(Graphics gBuf)  {
		if (map == null) return;
	
		//Graphics g = this.getGraphics();
		double phConc;
		Point p;
		
		// draw map points (except for hive)
		for (int i = 0; i<num_x_points; i++) {
			for (int j = 0; j<num_y_points; j++) {
				// 'empty' elements, color depending on pheromone concentration
				if (map[i][j].returnType() == MapPoint.TYPE_EMPTY) {
					phConc = map[i][j].getPhConcentration();
					// no pheromones
					if (phConc <= 0) {
						gBuf.setColor(COLOR_EMPTY);
					}
					// yellow (phConc = 1/2 MAX) to red (phConc = MAX):
					else if (phConc > (MapPoint.MAX_CONCENTRATION / 2)) { 
						if (phConc > MapPoint.MAX_CONCENTRATION)
							phConc = MapPoint.MAX_CONCENTRATION;
						gBuf.setColor(new Color(255, 
								(int) (255-Math.floor(2*(phConc-MapPoint.MAX_CONCENTRATION/2)*255/MapPoint.MAX_CONCENTRATION)), 0));
					}
					// white (phConc = 0) to yellow (phConc = 1/2 MAX):
					else { 
						gBuf.setColor(new Color(255, 255, 
								(int) (255-Math.floor(2*phConc*255/MapPoint.MAX_CONCENTRATION))));
					}
					gBuf.fillRect(i * x_pixels, j * y_pixels, x_pixels, y_pixels);
				}
				// 'border' elements
				else if (map[i][j].returnType() == MapPoint.TYPE_BORDER) {
					gBuf.setColor(COLOR_BORDER);
					gBuf.fillRect(i * x_pixels, j * y_pixels, x_pixels, y_pixels);
				}
				// 'border2' elements
				else if (map[i][j].returnType() == MapPoint.TYPE_BORDER2) {
					gBuf.setColor(COLOR_BORDER);
					gBuf.fillRect(i * x_pixels, j * y_pixels, x_pixels, y_pixels);
				}
				// 'food' elements
				else if (map[i][j].returnType() == MapPoint.TYPE_FOOD) {
					gBuf.setColor(COLOR_FOOD);
					gBuf.fillRect(i * x_pixels, j * y_pixels, x_pixels, y_pixels);
				}
			}
		}
		// draw ants
		if (ants != null) {
			
			for (int i = 0; i<ants.size(); i++) {
				Ant ant = ants.get(i);
				if (ant.getState() == Ant.ANT_FOLLOWER)
					gBuf.setColor(COLOR_ANTS_FOLLOWER);
				else if (ant.getState() == Ant.ANT_RETURNER)
					gBuf.setColor(COLOR_ANTS_RETURNER);
				else if (ant.getState() == Ant.ANT_RETURNER2)
					gBuf.setColor(COLOR_ANTS_RETURNER2);
				else
					gBuf.setColor(COLOR_ANTS);
				p = ant.getPosition();
				gBuf.fillRect(p.x * x_pixels, p.y * y_pixels, x_pixels, y_pixels);
			}
		}
		
		// draw hive map points (here because ants in hive shall not be visible)
		for (int i = 0; i<num_x_points; i++) {
			for (int j = 0; j<num_y_points; j++) {
				// 'hive' elements
				if (map[i][j].returnType() == MapPoint.TYPE_HIVE) {
					gBuf.setColor(COLOR_HIVE);
					gBuf.fillRect(i * x_pixels, j * y_pixels, x_pixels, y_pixels);
					hive_location_x = i;
					hive_location_y = j;
					hive_exists = true;
					
					for(int m=(-1)*HIVE_SIZE;m<=HIVE_SIZE;m++) {
						for(int n=(-1)*HIVE_SIZE;n<=HIVE_SIZE;n++) {
							if (!map[i+m][j+n].isBorderPoint(num_x_points, num_y_points) && (m != 0 || n != 0)) {
								map[i+m][j+n].setType(MapPoint.TYPE_EMPTY);
								gBuf.fillRect((i+m) * x_pixels, (j+n) * y_pixels, x_pixels, y_pixels);
							}
						}
					}
				}
			}
		}
		//offScreen.flush();	
		//g.drawImage(offScreen,0,0,this); 
		//g.dispose();
	}

	@Override
	public void mousePressed(MouseEvent e) {
    	//changeMapPointType(locateMapPoint(e.getPoint()));
    	mouse_pressed = true;
    	Thread paintThread = new Thread() {
    		public void run() {
            	do {
            		changeMapPointType(locateMapPoint(th.getMousePosition(true)));
            	} while (mouse_pressed);
    		}
    	};
    	paintThread.start();
    }
	
	@Override
	public void mouseReleased(MouseEvent e) {
        mouse_pressed = false;
    }
	
	@Override
	public void mouseClicked(MouseEvent arg0) {

	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		
	}
}
