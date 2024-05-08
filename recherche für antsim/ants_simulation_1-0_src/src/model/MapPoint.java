package model;

import java.awt.Point;
import view.MainFrame;

public class MapPoint 
{
	public static final int TYPE_FOOD = 0;
	public static final int TYPE_HIVE = 1;
	public static final int TYPE_EMPTY = 2;
	public static final int TYPE_BORDER = 3;
	public static final int TYPE_BORDER2 = 4;  // die Punkte, die die Map begrenzen
	
	public static final double MAX_CONCENTRATION = 100.0; //Maximal WAHRNEHMBARE Pheromonkonzentration
	public static final int MAX_FOOD_CONCENTRATION = 30; // Anfangswert für Foodmenge auf einem Foodfeld
	private static boolean finite_food =  false; //statische Variable; Standardwert: unendliche Foodmenge
	
	private double decay_constant = MainFrame.STD_DECAY_CONSTANT;
	private int type;
	private double phConcentration;
	private Point position;
	private int foodConcentration;
	private boolean beingCollected; // currently being eaten
	
	public MapPoint(int type, Point position) 
	{
		this.type = type;
		this.phConcentration = 0;
		this.position = position;
		this.foodConcentration = 0;
		this.beingCollected = false;
	}
	
	public void setBeingCollected(boolean be) {
		this.beingCollected = be;
	}
	
	public boolean beingCollected() {
		return this.beingCollected;
	}
	
	public static void setFinite(boolean finite) {
		finite_food = finite;
	}
	
	public static boolean getFinite() {
		return finite_food;
	}
	
	public void setDecayConstant(double decay_constant) {
		this.decay_constant = decay_constant;
	}
	
	public void phDecay() 
	{
		phConcentration=(1-decay_constant)*phConcentration;
	}
	public void phIncrease(double delta_ph)
	{
		if (this.type != TYPE_BORDER || this.type != TYPE_BORDER2)
			phConcentration = phConcentration + delta_ph;
	}
	
	public void setType(int type)
	{
		this.type=type;
		if (type == TYPE_BORDER || type== TYPE_BORDER2) {
			phConcentration = 0.0;
			foodConcentration = 0;
		}
		else if (type == TYPE_FOOD) {
			this.setFoodConcentration(MAX_FOOD_CONCENTRATION);
		}
	}
	public int returnType()
	{
		return(type);
	}
	
	public double getPhConcentration() {
		//if (phConcentration > MAX_CONCENTRATION)
			//return MAX_CONCENTRATION;
		//else
			return phConcentration;
	}
	
	public int getFoodConcentration(){
		return foodConcentration;
	}
	
	public void setFoodConcentration(int foodConcentration){
		this.foodConcentration = foodConcentration;
	}
	
	public void FoodDecrease() {
		if (finite_food == true) {
			foodConcentration -= 1;
			if (foodConcentration == 0)
				setType(TYPE_EMPTY);
		}
	}
	
	public Point getPosition() {
		return this.position;
	}
	
	public boolean isBorderPoint(int num_x_points, int num_y_points) {
		if (position.x==0 || position.y==0 || position.x == num_x_points-1 || position.y == num_y_points-1)
			return true;
		else
			return false;
	}
	
}

