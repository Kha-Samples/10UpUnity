package com.ktxsoftware.kje.editor;

import javax.swing.BoxLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;

public class InfoBar extends JPanel {
	private static final long serialVersionUID = 1L;
	private static InfoBar instance;
	private JLabel label;
	
	private InfoBar() {
		setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
		label = new JLabel("X: ? Y: ?");
		add(label);
	}
	
	public static InfoBar getInstance() {
		if (instance == null) instance = new InfoBar();
		return instance;
	}
	
	public void update(int x, int y) {
		label.setText("X: " + x + " Y: " + y);
	}
}
