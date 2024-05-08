package model;

import java.awt.Point;
import java.util.ArrayList;
import java.util.Random;

import view.MainFrame;


public class Ant {
	
	public static final int ANT_SEEKER = 0;
	public static final int ANT_FOLLOWER = 1;
	public static final int ANT_RETURNER = 2;
	public static final int ANT_RETURNER2 = 3 ;
	
	private final double SEEKER_ANGLE = 70.00;
	private final double FOLLOWER_ANGLE = 360.00;
	
	private int state;
	private ArrayList<Point> way; // Hinweg            
	private Point position;		// aktuelle Position
	private int max_waysize;
	private Point direction;
//	private Point direction2;  //Richtung nach 2 Feldern 
	
	private int max_way;
	
	private final int SEEKER_PROB = (int) Math.round(MapPoint.MAX_CONCENTRATION + MapPoint.MAX_CONCENTRATION*0.05);
	//private final int SEEKER_PROB = 30;
	private final int ASSESS_FOOD_RADIUS = 1;
	
	private final int PH_FOOD_MULTIPLIER = 5; // höherer Pheromonausstoß kurz nach Futter
	private final int PH_FOOD_MULTIPLIER_LENGTH = 10; 
	private final int SIDE_DROP = 2; // Bruchteil des Pheromondrops, der im Umkreis des Zentrums ausgestoßen wird
	
	private double ph_increase;                //PH_INCREASE !!!!!!!!!!!!!!!!!!!!
	private double follower_to_seeker; // Pheromon-Grenzwert unter dem Follower zu Seekern werden
	
	private double hive_radius; // drift away from hive within this radius
	
	private int food; // collected food
	
	private MapPoint[] area= new MapPoint[8]; //Umgebungsfelder einer Follower_ant
	private static Random randomGenerator = new Random(); 
	

	
	
	public Ant (Point spawnPoint, MapPoint[][] Map)       //Timer-Class muss spawnPoint uebergeben  
	{
		max_waysize = 5 * Map.length * Map[0].length / 100;
		hive_radius = 25.0;
		setPhDrop(MainFrame.STD_PH_DROP);
		
		this.position=spawnPoint.getLocation(); 
		this.way = new ArrayList<Point>();
		this.way.add(spawnPoint.getLocation());
		this.direction= new Point(0,0);
		this.food = 0;
		this.max_way=0;
		
		change_state(Map,(int) position.getX(), (int) position.getY());    // change_state: startet nicht unbedingt mit seeker
	}
	
	
	
	public void setPhDrop(double ph_increase) { // setzt den Pheromon-Drop (aufgerufen vom Slider)
		this.ph_increase = ph_increase;
		this.follower_to_seeker = ph_increase / 10;
	}
	
	private double DistFunction(int X,int Y) {
		double hive_dist = HiveDistance(X,Y);
		//return Math.pow(hive_dist, K);
		//if (hive_dist < hive_radius)
			//return (Math.exp(hive_dist)-1) / (Math.exp(hive_radius)-1);
			//return Math.sin((2*Math.PI)/(4*hive_radius) * hive_dist);
			//return 1;//(Math.log(hive_dist+1));
		//else
			return 1;
		//return 100*Math.log(hive_dist+1); 
	}
	
	private double BorderCount(int PosX,int PosY,MapPoint[][] Map) 
	{	
	int bordercount=0;
	for(int xdelta=-1; xdelta<2; xdelta++)
		{ 
 	   for(int ydelta=-1; ydelta<2;ydelta++) 
 	   		{
 		   if(xdelta==0 && ydelta==0) continue;
 		   if( Map[PosX+xdelta][PosY+ydelta].returnType()==MapPoint.TYPE_BORDER2)  bordercount++;    
		 	}	
		}
		return bordercount;	
	}
	
	
	private int RandomFollow()                       // Zufallszahlen zwischen 0 und 100: Folgerameisen gehen nicht nur auf hï¿½chster 
	{
		int result =randomGenerator.nextInt(101); 
		return(result);
	}
	
	private int RandomMove()                         // Zufallszahl zwischen -1 und 1
	{
		int result = randomGenerator.nextInt(3)-1; 
		return(result);
	}
	
	private int SeekOrFollow()            			// Zufallszahl abhï¿½ngig von Seeker_prob           
	{
		int result = randomGenerator.nextInt(SEEKER_PROB); 

		return(result); 
	}
		
	
	private void phIncrease3Felder(MapPoint[][] MP, int PosX, int PosY, int dirX, int dirY)
	{
		//if (dirX >= 0 && dirY >= 0 && dirX < MP.length && dirY < MP[0].length) {
			//System.out.println(Integer.toString(dirX) + " " + Integer.toString(dirY));
		double phinc, phinc_side;
		if (max_way-way.size() < PH_FOOD_MULTIPLIER_LENGTH) {
			phinc = ph_increase * PH_FOOD_MULTIPLIER;
			phinc_side = ph_increase * PH_FOOD_MULTIPLIER / SIDE_DROP;
		}
		else {
			phinc = ph_increase;
			phinc_side = ph_increase / SIDE_DROP;
		}
			
		MP[PosX][PosY].phIncrease(phinc);
		if (Math.abs(dirX) <= 1 && Math.abs(dirY) <= 1)
		{
			for (int idx=-1;idx<=1;idx++){
				for (int idy=-1;idy<=1;idy++) {
					if (idx==0 && idy==0)
						continue;
					MP[PosX+idx][PosY+idy].phIncrease(phinc_side);
				}
			}
		}
		
	}
		
	
	
	private double HiveDistance(int PosX, int PosY)
	{
		Point spawnPoint = null;
		if (way.size() >= 1)
			spawnPoint = way.get(way.size()-1);

		if (spawnPoint != null)
			return Math.sqrt(Math.abs(Math.pow(PosX-spawnPoint.getX(), 2))+Math.abs(Math.pow(PosY-spawnPoint.getY(),2)));
		
		return 0.0;
	}
	
	public int getFood() {
		return food;
	}
	
	private Point nearbyFood(MapPoint[][] MP, int PosX, int PosY) {
		for(int dx=(-1)*ASSESS_FOOD_RADIUS ; dx <= ASSESS_FOOD_RADIUS ; dx++)
		{
			for(int dy=(-1)*ASSESS_FOOD_RADIUS ; dy <=ASSESS_FOOD_RADIUS ; dy++)
			{ 
				if ((PosX+dx) >= 0
						&& (PosY+dy) >= 0
						&& (PosX+dx) < MP.length 
						&& (PosY+dy) < MP[0].length 
						&& MP[PosX+dx][PosY+dy].returnType() == MapPoint.TYPE_FOOD)
					return new Point(dx, dy);
			}	
		}
		return null;
	}
	
	private void change_state(MapPoint[][] MP , int PosX, int PosY)
	{
		int type = MP[PosX][PosY].returnType();
		if(way.size()>max_waysize && state==ANT_SEEKER) state=ANT_RETURNER2;
		else if (type == MapPoint.TYPE_HIVE /* || type == MapPoint.TYPE_EMPTY */)     // Ob Ameise sucht oder folgt entscheidet sich am Hive
		{
			int Random = SeekOrFollow();
			for(int dx=-1 ; dx < 2 ; dx++)
			{
				for(int dy=-1 ; dy < 2 ; dy++)
				{
					if(dx==0 && dy==0) continue; //dy++;
					if( (int)Math.round(MP[PosX+dx][PosY+dy].getPhConcentration()) > Random ) {
											//state = ANT_SEEKER;
											state = ANT_FOLLOWER;
											return;
					}
				}	
			}
			if(state != ANT_FOLLOWER){  
				state = ANT_SEEKER;
				//System.out.println("Ich bin ein neuer Seeker");
			}
		}
		else if(type == MapPoint.TYPE_FOOD)                                    // Stehst du auf Essen gehe zurï¿½ck zum Bau
		{
			if (state != ANT_RETURNER && MP[PosX][PosY].beingCollected() == false) { // "collecting"
				food += 1;
				MP[PosX][PosY].setBeingCollected(true);
				MP[PosX][PosY].FoodDecrease();
			}
			state = ANT_RETURNER;
			max_way = way.size();
			
			//System.out.println("Ich bin ein Returner");
		}
	
	}	
	
	private double RichtungsWinkelInDegree(int dx, int dy)
	{ 
		/*if(direction.getX()!=10 || direction.getY()!=10)
		{*/
			
			double SkalarProd=direction.getX()*(double)dx  +  direction.getY()*(double)dy;
			if(SkalarProd==0.0)
			{
				return 90.0;
			}
			else{
				double betrag_dr= Math.sqrt(Math.pow(dx,2) + Math.pow(dy,2));
				double betrag_adr= Math.sqrt(Math.pow(direction.getX(),2) + Math.pow(direction.getY(),2));
				double cosTheta = SkalarProd / (betrag_adr*betrag_dr);                            // Winkel berechnen
				return Math.acos(cosTheta)*180.0/Math.PI;
			}
		/*}
		else return 0.00;*/
	}
	
	private double RichtungsWinkel2(int dx, int dy)
	{ 
		
			double SkalarProd=direction.getX()*(double)dx  +  direction.getY()*(double)dy;
			if(SkalarProd==0.0){
				return 90.0;
			}
			else{
				double betrag_dr= Math.sqrt(Math.pow(direction.getX(),2) + Math.pow(direction.getY(),2));
				double betrag_adr= Math.sqrt(Math.pow(direction.getX(),2) + Math.pow(direction.getY(),2));
				double cosTheta = SkalarProd / (betrag_adr*betrag_dr);                            // Winkel berechnen
				return Math.acos(cosTheta)*180.0/Math.PI;
			}
		
	}
	
	
	
	public void move(MapPoint[][] Map)               // Bewegung abhaengig ob Ameise Seeker, Follower oder Returner ist
	{
		int PosX = (int) position.getX();                         
		int PosY = (int) position.getY();
		Point nFood;
		
		
		if(state == ANT_SEEKER)						
		{			
			int dx, dy;
			//Ameise sucht die Umgebungsfelder nach Futter ab
			if ((nFood = nearbyFood(Map, PosX, PosY)) != null){
				dx = (int)nFood.getX();
				dy = (int)nFood.getY();
				PosX += dx;
				PosY += dy;
			}				
			//Ameise lï¿½uft zufaellig schraeg links oder rechts, oder gerade aus
			else if(way.size() > 1){// wenn Ameise nicht auf SpawPoint steht	   	    
				int n=0;
				for(int xdelta=-1; xdelta<2; xdelta++){ 
		    	   for(int ydelta=-1; ydelta<2;ydelta++) {
		    		   if(xdelta==0 && ydelta==0) continue;
		    		   // Punkte in Area schreiben, die vor oder schraeg vor der ameise sind, 
		    		   // wenn sie keine borderpunkte sind oder wenn es nicht der hive ist.
		    		   // Dï¿½rfen maximal drei Punkte sein wegen dem Winkel
		    		   if( /*!way.contains(new Point(PosX+xdelta, PosY+ydelta)) &&*/ 
		    				   RichtungsWinkelInDegree(xdelta,ydelta)<=SEEKER_ANGLE && // Winkel zwischen Richtungsvektoren last und next soll kleiner 90grad sein
		        			  !(Map[PosX+xdelta][PosY+ydelta].returnType()==MapPoint.TYPE_BORDER) && !(Map[PosX+xdelta][PosY+ydelta].returnType()==MapPoint.TYPE_BORDER2) && !(Map[PosX+xdelta][PosY+ydelta].returnType()==MapPoint.TYPE_HIVE) )      
		  				{   
		  					area[n]=Map[PosX+xdelta][PosY+ydelta];
				        	n++;
		  				}	
		        	}	
		        }
				//Falls die Felder direkt vor der Ameise vom TYPE_BORDER sind o.ï¿½.:
				if (n == 0) {
					do{
						 dx=RandomMove();
						 dy=RandomMove();
						 PosX = (int) position.getX() + dx;                    
						 PosY = (int) position.getY() + dy;
					}while(Map[PosX][PosY].returnType()==MapPoint.TYPE_BORDER || Map[PosX][PosY].returnType()==MapPoint.TYPE_BORDER2 ); 	
				}
				else{
					int result =randomGenerator.nextInt(n);  
					PosX=(int)area[result].getPosition().getX();
					PosY=(int)area[result].getPosition().getY();
					dx=PosX - (int)way.get(0).getX();
					dy=PosY - (int)way.get(0).getY();
				}
			}       
			// wenn Ameise am SpawnPoint startet:
			else
			{ 
				do{
					dx = RandomMove();                  
					dy = RandomMove();
					PosX = (int) position.getX() + dx;                    
					PosY = (int) position.getY() + dy;
				}while(dx==0 && dy==0 || Map[PosX][PosY].returnType()==MapPoint.TYPE_BORDER || Map[PosX][PosY].returnType()==MapPoint.TYPE_BORDER2);
			}
			direction.setLocation(dx,dy);
			way.add(0,new Point(PosX,PosY));  // Eintragen in Route
	
		}	
	
		
		else if(state == ANT_FOLLOWER){
			
			if (BorderCount( PosX, PosY, Map)>2)
			{
				state=ANT_RETURNER2;
			}
			
			
			  double[] intervall= new double[8];
			  double phSumm=0;
			  double norm=0;
			  int n=0;
			  int Random = RandomFollow();
			  // Ameise sucht Nachbarfelder nach Futter ab
			  if ((nFood = nearbyFood(Map, PosX, PosY)) != null){
					PosX += (int)nFood.getX();
					PosY += (int)nFood.getY();
				}
			  // Informationen der Felder um die Ameise herum in Array sammeln
			  else {
			       for(int dx=-1; dx<2; dx++){ 
			    	   for(int dy=-1; dy<2;dy++) {
			    		   if(dx==0 & dy==0) continue;
			        	   if( HiveDistance(PosX, PosY)<=HiveDistance(PosX+dx, PosY+dy) && !way.contains(new Point(PosX+dx, PosY+dy)) &&
			        			   RichtungsWinkelInDegree(dx,dy)<=FOLLOWER_ANGLE && !(Map[PosX+dx][PosY+dy].returnType()==MapPoint.TYPE_BORDER2) &&
			        			   !(Map[PosX+dx][PosY+dy].returnType()==MapPoint.TYPE_BORDER) && Map[PosX+dx][PosY+dy].getPhConcentration()>0 && (Map[PosX][PosY].returnType()==MapPoint.TYPE_HIVE || !((PosX+dx)==way.get(1).getX()&&(PosY+dy)==way.get(1).getY())) )      
			  				{   
			  					area[n]=Map[PosX+dx][PosY+dy];
			  					phSumm=phSumm+phWeigh(area[n].getPhConcentration());
			  					norm = norm + phWeigh(area[n].getPhConcentration()) * DistFunction((int)area[n].getPosition().getX(), (int)area[n].getPosition().getY());
			  					n++;
			  				}	
			        	}	
			        }

			       
			 		if (phSumm<follower_to_seeker|| n==0) state=ANT_SEEKER;
			 		else {
			 			intervall[0]=phWeigh(area[0].getPhConcentration())*100/norm * DistFunction((int)area[0].getPosition().getX(), (int)area[0].getPosition().getY());
			 			  for(int i=1; i<=n-1; i++){
			 				 intervall[i]=intervall[i-1]+phWeigh(area[i].getPhConcentration())*100/norm  * DistFunction((int)area[i].getPosition().getX(), (int)area[i].getPosition().getY());
			 			} 
			 			 for(int i=0; i<=n-1;i++){
			 				if(Random<=intervall[i]) {
			 				  PosX = (int) area[i].getPosition().getX();			
			  				  PosY = (int) area[i].getPosition().getY();
			  				  break;
			 				}  
			 			 }  
			 		}
			  }
	 		way.add(0,new Point(PosX,PosY));
	  		if(way.size() > 1) direction.setLocation(PosX-(int) way.get(1).getX(), PosY-(int) way.get(1).getY());
		    else if(way.size()==1) direction.setLocation(0, 0);    	
		}	 
		
		
		
		
		else if(state == ANT_RETURNER){
			//if (way.size()<1) {
			//	System.out.println("Aktuelle Position"+Integer.toString(PosX) + ":" + Integer.toString(PosY));
			//}
			if (way.size() >= 1) {
				direction.setLocation((int) way.get(0).getX()-PosX, (int) way.get(0).getY()-PosY); //muss hier schon berechnet werden (mit vorherigen Wegpunkt)
	
				PosX = (int) way.get(0).getX();
				PosY = (int) way.get(0).getY();
				
				if (way.size() > 1) // don't remove spawn point
					way.remove(0);
	
				phIncrease3Felder(Map, PosX, PosY, (int)direction.getX(), (int)direction.getY());
			}
			
		} 
		

		else if(state == ANT_RETURNER2){
			//if (way.size()<1) {
			//	System.out.println("Aktuelle Position"+Integer.toString(PosX) + ":" + Integer.toString(PosY));
			//}
			if (way.size() >= 1) {
				direction.setLocation((int) way.get(0).getX()-PosX, (int) way.get(0).getY()-PosY); //muss hier schon berechnet werden (mit vorherigen Wegpunkt)
				
				PosX = (int) way.get(0).getX();
				PosY = (int) way.get(0).getY();
				if (way.size() > 1) // don't remove spawn point
					way.remove(0);
			}
		} 
		
		
		position.setLocation(PosX, PosY); 
		change_state(Map, PosX, PosY);	
	//	phIncrease3Felder(Map, PosX, PosY, (int)direction.getX(), (int)direction.getY());
	}

		
	public int getState() {
		return state;
	}
	
	public Point getPosition()
	{
		return position.getLocation();
	}
	
	private double phWeigh(double ph) {
		return Math.pow(ph,  2);
	}

}







