package controller;

import java.util.ArrayList;
import java.util.TimerTask;

import view.MainFrame;
import model.Ant;
import model.MapPoint;



public class TimerClass extends TimerTask
{	
	private ArrayList<Ant> Ants;
	private MapPoint[][] Map;
	private MainFrame mFrame;
	
	public static final int DELAY = 0; // start delay in milliseconds
	private static final int MAX_FPS = 25; // maximal frames per second
	
	private int picture_rate; // only draw every nth picture
	private int pic;
	
	public TimerClass(ArrayList<Ant> Ants, MapPoint[][] Map, MainFrame mFrame, int frequency) {
		super();
		this.Ants = Ants;
		this.Map = Map;
		this.mFrame = mFrame;
		this.pic = 1;
		this.picture_rate = (int) Math.ceil((double)frequency / (double)MAX_FPS);
	}
	
	public void run() {
		for (int i=0;i<Map.length;i++) {
			for (int j=0; j<Map[0].length; j++) {
				Map[i][j].phDecay();
				Map[i][j].setBeingCollected(false);
			}
		}
		
		for (int i=0;i<Ants.size();i++) {
			Ants.get(i).move(Map);
		}
		
		mFrame.incFoodRateCounter();
		
		if (pic == picture_rate) {
			mFrame.repaint();
			pic = 0;
		}
		this.pic++;
    }
		 

}
