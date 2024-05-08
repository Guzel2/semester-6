package controller;

import java.awt.Point;
import java.util.ArrayList;
import java.util.Random;

import view.MainFrame;

import model.Ant;
import model.MapPoint;

public abstract class RandomMap {
	public static int RandomX(Random randomGenerator) // Gibt einen zufaelligen x-Wert aus (abzueglich Border)
	{
		int result = randomGenerator.nextInt(MainFrame.NUM_X_POINTS-2)+1; //hoechst moeglicher Wert NUM_X_POINTS-2
		return(result);
	}
	
	public static int RandomY(Random randomGenerator) 
	{
		int result = randomGenerator.nextInt(MainFrame.NUM_Y_POINTS-2)+1; 
		return(result);
	}
	
	
	public static Point getMap(MapPoint[][] Map, ArrayList<Ant> Ants)
			//throws InterruptedException //*
	{
		int X;
		int Y;
		Random randomGenerator = new Random(); 
		
		int hive_location_x; //Muss der Movefunktion als Spwanpunkt uebergeben werden
		int hive_location_y;
		
				
		
		for (int i=0;i<MainFrame.NUM_X_POINTS;i++) 
		{ 
			for(int j=0;j<MainFrame.NUM_Y_POINTS;j++) 
			{ 
				Map[i][j] = new MapPoint(MapPoint.TYPE_EMPTY, new Point(i,j)); 
				if ((i==0) || (j==0) || (i==(MainFrame.NUM_X_POINTS-1)) || (j==(MainFrame.NUM_Y_POINTS-1)))  
					Map[i][j].setType(MapPoint.TYPE_BORDER2);
			} 
		}
		for (int count=0;count<MainFrame.FOOD_AMOUNT;count++) //verteilt Food zufaellig auf Map, mit bestimmter futtergroesse
		{
			X=RandomX(randomGenerator);
			Y=RandomY(randomGenerator);
			for (int count2=0;count2<MainFrame.FOOD_SIZE;count2++)
			{
				for (int count3=0;count3<MainFrame.FOOD_SIZE;count3++)
				{
					if ((X+count2)>=MainFrame.NUM_X_POINTS-1)
						break;
					if ((Y+count3)>=MainFrame.NUM_Y_POINTS-1)
						break;
					Map[X+count2][Y+count3].setType(MapPoint.TYPE_FOOD);
				}
			}
		}
		do 
		{
		X=RandomX(randomGenerator);
		}
		while (X<MainFrame.NUM_X_POINTS/3||X>MainFrame.NUM_X_POINTS-MainFrame.NUM_X_POINTS/3);
		do 
		{
		Y=RandomY(randomGenerator);
		}
		while (Y<MainFrame.NUM_Y_POINTS/3||Y>MainFrame.NUM_Y_POINTS-MainFrame.NUM_Y_POINTS/3);
		Map[X][Y].setType(MapPoint.TYPE_HIVE); //setzt Hive an einen zufälligen Punkt
		hive_location_x=X;
		hive_location_y=Y;
		for(int count1=0;count1<=15;count1++) //setzt die 7*7 Felder um das Hive auf Empty, falls sie keine Border sind
		{
			for(int count2=0;count2<=15;count2++)
			{
				if (((X-3)+count1) >= 0 && ((Y-3)+count2) >= 0 
						&& ((X-7)+count1) < MainFrame.NUM_X_POINTS-1
						&& ((Y-7)+count2) < MainFrame.NUM_Y_POINTS-1) {
					if (Map[(X-7)+count1][(Y-3)+count2].returnType()==MapPoint.TYPE_FOOD)
						{Map[(X-7)+count1][(Y-3)+count2].setType(MapPoint.TYPE_EMPTY);}
					if (Map[(X-7)+count1][(Y-3)+count2].returnType()==MapPoint.TYPE_BORDER || Map[(X-7)+count1][(Y-3)+count2].returnType()==MapPoint.TYPE_BORDER2)
						{break;}
				}
			}
		}
		
		Point hive_pos = new Point(hive_location_x, hive_location_y);
		for(int i=0;i<MainFrame.START_AMOUNT_ANTS;i++) {
			Ants.add(new Ant(hive_pos, Map));
		}
		
		return new Point(hive_location_x, hive_location_y);
	}	
}
