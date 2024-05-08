package view;

import model.*;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Toolkit;
import java.awt.event.*;
import java.util.ArrayList;
import java.util.Timer;

import javax.swing.ButtonGroup;
import javax.swing.JApplet;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JSlider;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import controller.RandomMap;
import controller.TimerClass;


public class MainFrame extends JApplet //TODO JFrame for application
{

	private static final long serialVersionUID = 1L;
	private final float BUTTON_WIDTH = 0.15f; // relative button width
	private final float ABOUTBUTTON_WIDTH = BUTTON_WIDTH; // relative about-button width
	private final float SPINNER_WIDTH = 0.04f; // relative spinner width
	private final float BUTTON_HEIGHT = 0.06f; // relative button height
	private final float ABOUTBUTTON_HEIGHT = 0.04f; // relative about-button height
	private final float RADIO_HEIGHT = 0.04f; // relative radio button height
	private final float SLIDER_HEIGHT = 0.03f; // relative slider height
	private final float LABEL_HEIGHT = 0.03f; // relative label height
	private final float BORDER_SIZE = 0.033f; // relative border size
	private final float BUTTON_DIST = 0.02f; // relative distance between buttons
	
	private final Color COLOR_BACKGROUND = Color.gray; // color for main panel background
	private final Font SLIDER_FONT = new Font ("Arial",0,10); // font for slider labels
	private final Font LABEL_FONT = new Font ("Arial",0,11); // font for display labels
	private final Font RADIO_FONT = new Font ("Arial",0,11); // font for radio buttons
	private final Font BUTTON_FONT = new Font ("Arial",0,12); // font for buttons
	private final float MIN_WIDTH = 0.7f; // minimal window width as fraction of the screen width
	private final float MIN_HEIGHT = 0.6f; // minimal window height as fraction of the screen height
	
	// ant spawn number (max/min/default)
	private final int MAX_ANT_SPAWN = 99;
	private final int MIN_ANT_SPAWN = 1;
	private final int STD_ANT_SPAWN = 50;
		
	// refresh period (max/min/default) - one calculation step per period is performed
	private final int MIN_PERIOD = 5; // minimal period in milliseconds
	private final int MAX_PERIOD = 1000; // maximal period in milliseconds
	private final int STD_PERIOD = 10; // default period in milliseconds
	
	// brush size (max/min/default)
	private final int MAX_BRUSHSIZE = 6;
	private final int MIN_BRUSHSIZE = 1;
	private final int STD_BRUSHSIZE = 3;
	
	// pheromone decay (max/min/default)
	private final double MAX_DECAY_CONSTANT = 0.010;
	private final double MIN_DECAY_CONSTANT = 0.000;
	public static final double STD_DECAY_CONSTANT = 0.006;
	
	// pheromone drop (max/min/default)
	private final double MAX_PH_DROP = 20.0;
	private final double MIN_PH_DROP = 0.0;
	public static final double STD_PH_DROP = 5.0;
	
	private JPanel mainPanel;
	private MapPanel mapPanel = null;
	private JButton startButton;
	private JButton spawnButton;
	private JButton randomButton;
	private JButton clearMapButton;
	private JButton clearAntsButton;
	private JRadioButton foodRadio;
	private JRadioButton hiveRadio;
	private JRadioButton emptyRadio;
	private JRadioButton borderRadio;
	private ButtonGroup bGroup;
	private JSlider speedSlider;
	private JLabel speedLabel;
	private JSlider brushSlider;
	private JLabel brushLabel;
	private JSlider decaySlider;
	private JLabel decayLabel;
	private JSlider dropSlider;
	private JLabel dropLabel;
	private JLabel antcountLabel;
	private JLabel foodLabel;
	private JLabel foodrateLabel;
	private JCheckBox finiteFood;
	private JSpinner antSpinner;
	private JButton aboutButton;
	
	private ArrayList<Ant> ants = null; // the ant array
	private MapPoint[][] map = null; // the map array
	
	private Timer timer; // timer
	private TimerClass action; // timer action of own class TimerClass
	private boolean running; // is simulation running?
	private int old_food; // needed for food rate calculation
	private int foodrate_c; // to guarantee that food rate is not calculated in every step
	
	public final static int NUM_X_POINTS = 150; // horizontal map points
	public final static int NUM_Y_POINTS = 100; // vertical map points
	public final static int FOOD_AMOUNT = 10; // number of randomly placed food spots
	public final static int FOOD_SIZE = 6; // size of randomly placed food spots
	public final static int START_AMOUNT_ANTS = 50; // initial amount of ants
	
	/** TODO FOR APPLICATION **
	// main function for application
	public static void main(String [] args) {
		MainFrame mFrame = new MainFrame();
		mFrame.init();
	}
	
	// constructor for application
	public MainFrame() {
		super("Ants Simulation 1.0");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setResizable(true);
        this.setLocationRelativeTo(null);
	}**/
	
	// initialization
	public void init()  {
		// set variables
		this.running = false; // simulation not running
		this.old_food = 0;
		this.foodrate_c = (int) (1000/STD_PERIOD); // print food rate once in the beginning
		
		// initialize components
		initComponents();
		
		// generate map
		map = new MapPoint[NUM_X_POINTS][NUM_Y_POINTS];
		ants = new ArrayList<Ant>();
		Point hive_pos = RandomMap.getMap(map, ants);
		mapPanel.setMap(map, ants, hive_pos);
		
		// add component listener for resizing the main frame
		this.addComponentListener(new ComponentAdapter() {
            public void componentResized(ComponentEvent e) {
                sizeComponents();
            }
        });
		
		// add mouse listener for speed slider
		final MainFrame th = this;
		speedSlider.addMouseListener(new MouseListener() {
			public void mousePressed(MouseEvent e) {
		    }
			
			public void mouseReleased(MouseEvent e) {
				int freq = speedSlider.getValue();
				speedSlider.setToolTipText(Integer.toString(freq) + " Hz");
				if (running == true) {
					timer.cancel();
					timer = new Timer();
			        action = new TimerClass(ants, map, th, freq);
					timer.schedule(action, TimerClass.DELAY, (int) (1000/freq));
				}
		    }
			
			public void mouseClicked(MouseEvent arg0) {
			}

			public void mouseEntered(MouseEvent arg0) {
			}

			public void mouseExited(MouseEvent arg0) {
			}
        });
		
		// set attributes
		this.setFocusable(true);
	}
	
	// if applet is set to visible
	public void start() {
		
	}
		
	// if applet is set to invisible
	public void stop() {
		
	}
	
	// creates and initializes all components
	private void initComponents() {
		// set frame margins
		int full_width = (int) Math.round(MIN_WIDTH * Toolkit.getDefaultToolkit().getScreenSize().width);
		int full_height = (int) Math.round(MIN_HEIGHT * Toolkit.getDefaultToolkit().getScreenSize().height);
		this.setBounds(Toolkit.getDefaultToolkit().getScreenSize().width/2 - full_width/2, Toolkit.getDefaultToolkit().getScreenSize().height/2 - full_height/2, full_width, full_height);
		this.setMinimumSize(new Dimension(full_width, full_height));
		
		// mainPanel
		mainPanel = new JPanel();
		
		// mapPanel
		mapPanel = new MapPanel();
		mapPanel.setBrush(STD_BRUSHSIZE, MapPanel.BRUSH_FOOD);
		mainPanel.add(mapPanel);
		
		// startButton
		startButton = new JButton("Start");
		startButton.setFont(BUTTON_FONT);
		mainPanel.add(startButton);
		startButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	startButtonActionPerformed(evt);
            }
        });
		
		// spawnButton
		spawnButton = new JButton("Spawn Ants");
		spawnButton.setFont(BUTTON_FONT);
		mainPanel.add(spawnButton);
		spawnButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	spawnButtonActionPerformed(evt);
            }
        });
		
		// antSpinner
		antSpinner = new JSpinner(new SpinnerNumberModel(STD_ANT_SPAWN, 
				  MIN_ANT_SPAWN, MAX_ANT_SPAWN, 1));
		antSpinner.setBackground(COLOR_BACKGROUND);
		antSpinner.setBorder(null);
		((JSpinner.DefaultEditor)antSpinner.getEditor()).getTextField().setEditable(false);
		mainPanel.add(antSpinner);
		
		// antcountLabel
		antcountLabel = new JLabel();
		antcountLabel.setBackground(COLOR_BACKGROUND);
		antcountLabel.setFont(LABEL_FONT);
		mainPanel.add(antcountLabel);
		
		// foodLabel
		foodLabel = new JLabel();
		foodLabel.setBackground(COLOR_BACKGROUND);
		foodLabel.setFont(LABEL_FONT);
		mainPanel.add(foodLabel);
		
		// foodrateLabel
		foodrateLabel = new JLabel();
		foodrateLabel.setBackground(COLOR_BACKGROUND);
		foodrateLabel.setFont(LABEL_FONT);
		mainPanel.add(foodrateLabel);
		
		// finiteFood
		finiteFood = new JCheckBox("Finite food amount");
		finiteFood.setBackground(COLOR_BACKGROUND);
		finiteFood.setSelected(MapPoint.getFinite());
		finiteFood.setFont(LABEL_FONT);
		mainPanel.add(finiteFood);
		finiteFood.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	finiteFoodActionPerformed(evt);
            }
        });
		
		// randomButton
		randomButton = new JButton("Random map");
		randomButton.setFont(BUTTON_FONT);
		mainPanel.add(randomButton);
		randomButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	randomButtonActionPerformed(evt);
            }
        });
		
		// clearMapButton
		clearMapButton = new JButton("Clear map");
		clearMapButton.setFont(BUTTON_FONT);
		mainPanel.add(clearMapButton);
		clearMapButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	clearMapButtonActionPerformed(evt);
            }
        });
		
		// clearAntsButton
		clearAntsButton = new JButton("Clear ants");
		clearAntsButton.setFont(BUTTON_FONT);
		mainPanel.add(clearAntsButton);
		clearAntsButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	clearAntsButtonActionPerformed(evt);
            }
        });
		
		// speedLabel
		speedLabel = new JLabel("Speed:");
		speedLabel.setBackground(COLOR_BACKGROUND);
		speedLabel.setFont(SLIDER_FONT);
		mainPanel.add(speedLabel);
				
		// speedSlider
		speedSlider = new JSlider();
		speedSlider.setBackground(COLOR_BACKGROUND);
		speedSlider.setMaximum((int) (1000/MIN_PERIOD)); // maximal frequency in Hertz
		speedSlider.setMinimum((int) (1000/MAX_PERIOD)); // minimal frequency in Hertz
		speedSlider.setValue((int) (1000/STD_PERIOD)); // default frequency in Hertz
		mainPanel.add(speedSlider);
		/*speedSlider.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
            	speedSliderStateChanged(e);
            }
        });*/
		
		// brushLabel
		brushLabel = new JLabel("Brush size:");
		brushLabel.setBackground(COLOR_BACKGROUND);
		brushLabel.setFont(SLIDER_FONT);
		mainPanel.add(brushLabel);
				
		// brushSlider
		brushSlider = new JSlider();
		brushSlider.setBackground(COLOR_BACKGROUND);
		brushSlider.setMaximum(MAX_BRUSHSIZE);
		brushSlider.setMinimum(MIN_BRUSHSIZE);
		brushSlider.setValue(STD_BRUSHSIZE);
		brushSlider.setMajorTickSpacing(1);
		brushSlider.setPaintTicks(true);
		mainPanel.add(brushSlider);
		brushSlider.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
            	brushSliderStateChanged(e);
            }
        });
		
		// decayLabel
		decayLabel = new JLabel("Pheromone decay constant:");
		decayLabel.setBackground(COLOR_BACKGROUND);
		decayLabel.setFont(SLIDER_FONT);
		mainPanel.add(decayLabel);
				
		// decaySlider
		decaySlider = new JSlider();
		decaySlider.setBackground(COLOR_BACKGROUND);
		decaySlider.setMaximum((int) (MAX_DECAY_CONSTANT*1000));
		decaySlider.setMinimum((int) (MIN_DECAY_CONSTANT*1000));
		decaySlider.setValue((int) (STD_DECAY_CONSTANT*1000));
		decaySlider.setMajorTickSpacing(1);
		decaySlider.setPaintTicks(true);
		mainPanel.add(decaySlider);
		decaySlider.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
            	decaySliderStateChanged(e);
            }
        });
		
		// dropLabel
		dropLabel = new JLabel("Pheromone drop:");
		dropLabel.setBackground(COLOR_BACKGROUND);
		dropLabel.setFont(SLIDER_FONT);
		mainPanel.add(dropLabel);
				
		// dropSlider
		dropSlider = new JSlider();
		dropSlider.setBackground(COLOR_BACKGROUND);
		dropSlider.setMaximum((int) (MAX_PH_DROP)); 
		dropSlider.setMinimum((int) (MIN_PH_DROP));
		dropSlider.setValue((int) (STD_PH_DROP)); 
		dropSlider.setMajorTickSpacing(1);
		dropSlider.setPaintTicks(true);
		mainPanel.add(dropSlider);
		dropSlider.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
            	dropSliderStateChanged(e);
            }
        });
		
		// foodRadio
		foodRadio = new JRadioButton("Food");
		foodRadio.setBackground(COLOR_BACKGROUND);
		foodRadio.setFont(RADIO_FONT);
		mainPanel.add(foodRadio);
		foodRadio.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	foodRadioActionPerformed(evt);
            }
        });

		// hiveRadio
		hiveRadio = new JRadioButton("Nest");
		hiveRadio.setBackground(COLOR_BACKGROUND);
		hiveRadio.setFont(RADIO_FONT);
		mainPanel.add(hiveRadio);
		hiveRadio.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	hiveRadioActionPerformed(evt);
            }
        });

		// borderRadio
		borderRadio = new JRadioButton("Obstacle");
		borderRadio.setBackground(COLOR_BACKGROUND);
		borderRadio.setFont(RADIO_FONT);
		mainPanel.add(borderRadio);
		borderRadio.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	borderRadioActionPerformed(evt);
            }
        });

		// emptyRadio
		emptyRadio = new JRadioButton("Empty");
		emptyRadio.setBackground(COLOR_BACKGROUND);
		emptyRadio.setFont(RADIO_FONT);
		mainPanel.add(emptyRadio);
		emptyRadio.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	emptyRadioActionPerformed(evt);
            }
        });
		
		// group of JRadioButton elements
		bGroup = new ButtonGroup();
		bGroup.add(foodRadio);
		bGroup.add(hiveRadio);
		bGroup.add(borderRadio);
		bGroup.add(emptyRadio);
		foodRadio.setSelected(true);
		
		// aboutButton
		aboutButton = new JButton("About");
		aboutButton.setFont(BUTTON_FONT);
		mainPanel.add(aboutButton);
		aboutButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
            	aboutButtonActionPerformed(evt);
            }
        });

		// miscellaneous
		this.setContentPane(mainPanel);
		this.setVisible(true);
		sizeComponents();
		repaint();
	}
	
	// resizes all components due to the frame size
	private void sizeComponents() {
		// first get window margins and absolute distance values
		Dimension full = mainPanel.getSize();
		int border_size = Math.round(full.height * BORDER_SIZE);
		int button_dist = Math.round(full.height * BUTTON_DIST);
		int button_width = Math.round(full.width * BUTTON_WIDTH);
		int spinner_width = Math.round(full.width * SPINNER_WIDTH);
		int button_height = Math.round(full.height * BUTTON_HEIGHT);
		int radio_height = Math.round(full.height * RADIO_HEIGHT);
		int slider_height = Math.round(full.height * SLIDER_HEIGHT);
		int label_height = Math.round(full.height * LABEL_HEIGHT);
		
		// mainPanel
		mainPanel.setLayout(null);
		mainPanel.setBackground(COLOR_BACKGROUND);

		// mapPanel
		mapPanel.setLayout(null);
		mapPanel.setBounds(0, 
				  		   0, 
				  		   full.width - button_width - 2*border_size, 
				  		   full.height);
				
		// startButton
		startButton.setBounds(full.width-border_size-button_width, 
							  border_size, 
							  button_width, 
							  button_height);
		
		// spawnButton
		spawnButton.setBounds(full.width-border_size-button_width, 
				  			  border_size + button_height + button_dist, 
				  			  button_width - spinner_width, 
				  			  button_height);
		
		// antSpinner
		antSpinner.setBounds(full.width-border_size-spinner_width, 
	  			  border_size + button_height + button_dist + Math.round(0.5f * (button_height-label_height)), 
	  			  spinner_width, 
	  			  label_height);
		antcountLabel.setText(""); // for some stupid reason, something in the panel has to be changed for the antSpinner to resize
				
		//antcountLabel
		antcountLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 2*button_height + 2*button_dist, 
				  			  button_width, 
				  			  label_height);
		
		//foodLabel
		foodLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 2*button_height + 2*button_dist + label_height, 
				  			  button_width, 
				  			  label_height);
		
		//foodrateLabel
		foodrateLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 2*button_height + 2*button_dist + 2*label_height, 
				  			  button_width, 
				  			  label_height);
		
		// finiteFood
		finiteFood.setBounds(full.width-border_size-button_width, 
				  			  border_size + 2*button_height + 2*button_dist + 2*label_height + radio_height, 
				  			  button_width, 
				  			  radio_height);
		
		// randomButton
		randomButton.setBounds(full.width-border_size-button_width, 
				  			  border_size + 2*button_height + 3*button_dist + 3*label_height + radio_height, 
				  			  button_width, 
				  			  button_height);
		
		// clearMapButton
		clearMapButton.setBounds(full.width-border_size-button_width, 
				  			  border_size + 3*button_height + 4*button_dist + 3*label_height + radio_height, 
				  			  button_width, 
				  			  button_height);
		
		// clearAntsButton
		clearAntsButton.setBounds(full.width-border_size-button_width, 
				  			  border_size + 4*button_height + 5*button_dist + 3*label_height + radio_height, 
				  			  button_width, 
				  			  button_height);
		
		// speedLabel
		speedLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + 6*button_dist + 3*label_height + radio_height, 
				  			  button_width, 
				  			  label_height);
				
		// speedSlider
		speedSlider.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + 4*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  slider_height);
		
		// brushLabel
		brushLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + slider_height + 4*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  label_height);
				
		// brushSlider
		brushSlider.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + slider_height + 5*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  slider_height);
		
		// decayLabel
		decayLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + 2*slider_height + 5*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  label_height);
				
		// decaySlider
		decaySlider.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + 2*slider_height + 6*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  slider_height);
		
		// dropLabel
		dropLabel.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + 3*slider_height + 6*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  label_height);
				
		// dropSlider
		dropSlider.setBounds(full.width-border_size-button_width, 
				  			  border_size + 5*button_height + 3*slider_height + 7*label_height + 6*button_dist + radio_height, 
				  			  button_width, 
				  			  slider_height);
		
		// foodRadio
		foodRadio.setBounds(full.width-border_size-button_width, 
	  			  border_size + 5*button_height + 4*slider_height + 7*label_height + 7*button_dist + radio_height, 
	  			  Math.round(button_width/2), 
	  			  radio_height);
		// hiveRadio
		hiveRadio.setBounds(full.width-border_size-button_width, 
	  			  border_size + 5*button_height + 4*slider_height + 7*label_height + 7*button_dist + 2*radio_height, 
	  			  Math.round(button_width/2), 
	  			  radio_height);
		// borderRadio
		borderRadio.setBounds(full.width-border_size-Math.round(button_width/2), 
	  			  border_size + 5*button_height + 4*slider_height + 7*label_height + 7*button_dist + radio_height,
	  			  Math.round(button_width/2), 
	  			  radio_height);
		// emptyRadio
		emptyRadio.setBounds(full.width-border_size-Math.round(button_width/2), 
	  			  border_size + 5*button_height + 4*slider_height + 7*label_height + 7*button_dist + 2*radio_height,  
	  			  Math.round(button_width/2), 
	  			  radio_height);
		
		// aboutButton
		aboutButton.setBounds(full.width-border_size-button_width, 
				border_size + 5*button_height + 4*slider_height + 7*label_height + 8*button_dist + 3*radio_height, 
				Math.round(full.width * ABOUTBUTTON_WIDTH),
				Math.round(full.height * ABOUTBUTTON_HEIGHT));
	}

	// start/stop button pressed
	private void startButtonActionPerformed(ActionEvent evt) {
		if (mapPanel.hiveExists() == false) {
			JOptionPane.showMessageDialog(this, "There has to be a nest somewhere!", "Information", JOptionPane.INFORMATION_MESSAGE);
		}
		else if (running == false) {
	        timer = new Timer();
	        action = new TimerClass(this.ants, this.map, this, speedSlider.getValue());
	        timer.schedule(action, 
	        		TimerClass.DELAY, (int) (1000/speedSlider.getValue()));
	        startButton.setText("Stop");
	        randomButton.setEnabled(false);
	        clearMapButton.setEnabled(false);
	        clearAntsButton.setEnabled(false);
	        foodRadio.setEnabled(false);
	        hiveRadio.setEnabled(false);
	        borderRadio.setEnabled(false);
	        emptyRadio.setEnabled(false);
	        running = true;
	        mapPanel.setRunning(true);
		}
		else {
			timer.cancel();
			startButton.setText("Start");
			randomButton.setEnabled(true);
	        clearMapButton.setEnabled(true);
	        clearAntsButton.setEnabled(true);
			foodRadio.setEnabled(true);
	        hiveRadio.setEnabled(true);
	        borderRadio.setEnabled(true);
	        emptyRadio.setEnabled(true);
	        running = false;
	        mapPanel.setRunning(false);
	        repaint();
		}
		
	}
	
	// spawn button pressed
	private void spawnButtonActionPerformed(ActionEvent evt) {
		if (mapPanel.hiveExists() && mapPanel.getHiveLocation() != null) {
			Integer amount = (Integer) antSpinner.getValue();
			for (int i=0; i<amount; i++)
				ants.add(new Ant(mapPanel.getHiveLocation(), map));
			repaint();
		}
	}
	
	// 'finite food' check box used
	private void finiteFoodActionPerformed(ActionEvent evt) {
		/*for(int i=0;i<NUM_X_POINTS;i++) {
			for(int j=0;j<NUM_Y_POINTS;j++) {
				map[i][j].setFinite(finiteFood.isSelected());
			}
		}*/
		MapPoint.setFinite(finiteFood.isSelected());
	}
	
	// random map button pressed
	private void randomButtonActionPerformed(ActionEvent evt) {
		clearMapButtonActionPerformed(null);		
		Point hive_pos = RandomMap.getMap(map, ants);
		mapPanel.setMap(map, ants, hive_pos);
	}
	
	// clear map button pressed
	private void clearMapButtonActionPerformed(ActionEvent evt) {
		mapPanel.clearMap();
		clearAntsButtonActionPerformed(null);
	}
	
	// clear ants (and pheromone) button pressed
	private void clearAntsButtonActionPerformed(ActionEvent evt) {
		ants.clear();
		mapPanel.resetDeadFood();
		repaint();
	}
	
	// speed slider changed
	/*private void speedSliderStateChanged(ChangeEvent e) {
		int freq = speedSlider.getValue();
		speedSlider.setToolTipText(Integer.toString(freq) + " Hz");
		if (running == true && mouse_pressed == false) {
			timer.cancel();
			timer = new Timer();
	        action = new TimerClass(this.ants, this.map, this, freq);
			timer.schedule(action, TimerClass.DELAY, (int) (1000/freq));
		}
	}*/
	
	// brush slider changed
	private void brushSliderStateChanged(ChangeEvent e) {
		brushSlider.setToolTipText(Integer.toString(brushSlider.getValue()));
		mapPanel.setBrush(brushSlider.getValue(), MapPanel.BRUSH_LIKE_BEFORE);
	}
	
	// decay slider changed
	private void decaySliderStateChanged(ChangeEvent e) {
		double dc = (double)decaySlider.getValue()/1000;
		decaySlider.setToolTipText(Double.toString(dc));
		for(int i=0;i<NUM_X_POINTS;i++) {
			for(int j=0;j<NUM_Y_POINTS;j++) {
				map[i][j].setDecayConstant(dc);
			}
		}
	}
	
	// drop slider changed
	private void dropSliderStateChanged(ChangeEvent e) {
		dropSlider.setToolTipText(Integer.toString(dropSlider.getValue()));
		for(int i=0;i<ants.size();i++) {
			ants.get(i).setPhDrop(dropSlider.getValue());
		}
	}
	
	// 'food' radio button pressed
	private void foodRadioActionPerformed(ActionEvent evt) {
		mapPanel.setBrush(brushSlider.getValue(), MapPanel.BRUSH_FOOD);
	}
	// 'hive' radio button pressed
	private void hiveRadioActionPerformed(ActionEvent evt) {
		mapPanel.setBrush(brushSlider.getValue(), MapPanel.BRUSH_HIVE);
	}
	// 'border' radio button pressed
	private void borderRadioActionPerformed(ActionEvent evt) {
		mapPanel.setBrush(brushSlider.getValue(), MapPanel.BRUSH_BORDER);
	}
	// 'empty' radio button pressed
	private void emptyRadioActionPerformed(ActionEvent evt) {
		mapPanel.setBrush(brushSlider.getValue(), MapPanel.BRUSH_EMPTY);
	}
	
	// aboutButton pressed
	private void aboutButtonActionPerformed(ActionEvent evt) {
		JOptionPane.showMessageDialog(this, "Ants Simulation Version 1.0 (17th July 2014)\n\nby Peter Kuhn, Jannik Luboeinski, Laura Martin, Marius Schneider", "About Ants Simulation", JOptionPane.INFORMATION_MESSAGE);
	}
	
	// increases food rate counter, is once per period called by timer
	public void incFoodRateCounter() {
		foodrate_c++;
	}
	
	// override paint method
	public void paint(Graphics g) {
		super.paint(g);
		if (ants != null) {
			int food = 0;
			antcountLabel.setText("Total ants: " + Integer.toString(ants.size()));
			for (int i = 0; i< ants.size(); i++) {
				food += ants.get(i).getFood();
			}
			food += mapPanel.getDeadFood();
			foodLabel.setText("Collected food: " + Integer.toString(food));
		
			if (foodrate_c >= speedSlider.getValue()) { // calculate only every m-th step
				// division of df (food difference) by dt (period) obsolete because of food rate counter!
				foodrateLabel.setText("Collecting rate: " + Integer.toString(food - old_food) + "/s");
				old_food = food;
				foodrate_c = 0;
			}
		}
		else {
			antcountLabel.setText("Total ants: 0");
			foodLabel.setText("Collected food: 0");
			foodrateLabel.setText("Collecting rate: 0/s");
		}
	}
}
